import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:uuid/uuid.dart';
import 'package:nahpu/services/custom_fields/dwc_terms.dart';

class CustomFieldValidationException implements Exception {
  const CustomFieldValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CustomFieldService {
  const CustomFieldService(this.db);

  final Database db;

  Future<List<CustomFieldDefinitionData>> getDefinitions({
    required FieldUISection placement,
    String? projectUuid,
    CatalogFmt? catalogFormat,
    bool includeArchived = false,
  }) {
    final query = db.select(db.customFieldDefinition)
      ..where((row) => row.uiSection.equals(placement.name))
      ..where(
        (row) =>
            row.scope.equals(FieldScope.global.name) |
            (projectUuid == null
                ? const Constant(false)
                : row.projectUuid.equals(projectUuid)),
      )
      ..where(
        (row) =>
            row.catalogFormat.isNull() |
            (catalogFormat == null
                ? const Constant(false)
                : row.catalogFormat.equals(catalogFormat.name)),
      )
      ..orderBy([
        (row) => OrderingTerm(
          expression: row.scope.equals(FieldScope.global.name),
          mode: OrderingMode.desc,
        ),
        (row) => OrderingTerm.asc(row.sortOrder),
        (row) => OrderingTerm.asc(row.name),
      ]);
    if (!includeArchived) {
      query.where((row) => row.isArchived.equals(0));
    }
    return query.get();
  }

  Future<List<CustomFieldDefinitionData>> getManageableDefinitions({
    String? projectUuid,
  }) {
    final query = db.select(db.customFieldDefinition)
      ..where(
        (row) =>
            row.scope.equals(FieldScope.global.name) |
            (projectUuid == null
                ? const Constant(false)
                : row.projectUuid.equals(projectUuid)),
      )
      ..orderBy([
        (row) => OrderingTerm.asc(row.uiSection),
        (row) => OrderingTerm(
          expression: row.scope.equals(FieldScope.global.name),
          mode: OrderingMode.desc,
        ),
        (row) => OrderingTerm.asc(row.sortOrder),
      ]);
    return query.get();
  }

  Future<List<CustomFieldDefinitionData>> getAllDefinitions() {
    return (db.select(db.customFieldDefinition)..orderBy([
          (row) => OrderingTerm.asc(row.uiSection),
          (row) => OrderingTerm.asc(row.sortOrder),
        ]))
        .get();
  }

  Future<CustomFieldDefinitionData> createDefinition(
    CustomFieldDraft draft,
  ) async {
    _validateDraft(draft);
    await _ensureUniqueName(draft);
    await _ensureDwcMappingAvailable(draft);
    final maxSort = db.customFieldDefinition.sortOrder.max();
    final sortRow =
        await (db.selectOnly(db.customFieldDefinition)
              ..addColumns([maxSort])
              ..where(
                db.customFieldDefinition.uiSection.equals(draft.placement.name),
              )
              ..where(db.customFieldDefinition.scope.equals(draft.scope.name))
              ..where(
                draft.scope == FieldScope.global
                    ? db.customFieldDefinition.projectUuid.isNull()
                    : db.customFieldDefinition.projectUuid.equals(
                        draft.projectUuid!,
                      ),
              ))
            .getSingle();
    final now = DateTime.now().toUtc().toIso8601String();
    final id = await db
        .into(db.customFieldDefinition)
        .insert(
          CustomFieldDefinitionCompanion.insert(
            uuid: const Uuid().v4(),
            sourceTemplateUuid: Value(draft.sourceTemplateUuid),
            name: draft.name.trim(),
            type: draft.type.name,
            uiSection: draft.placement.name,
            options: Value(_encodedOptions(draft)),
            scope: draft.scope.name,
            projectUuid: Value(
              draft.scope == FieldScope.project ? draft.projectUuid : null,
            ),
            catalogFormat: Value(
              draft.placement.isSpecimenRelated
                  ? draft.catalogFormat?.name
                  : null,
            ),
            sortOrder: Value((sortRow.read(maxSort) ?? -1) + 1),
            dwcTarget: Value(draft.dwcMapping?.target),
            dwcField: Value(draft.dwcMapping?.field),
            dwcMode: Value(draft.dwcMapping?.mode.name),
            allowDwcConflict: Value(
              draft.dwcMapping?.allowConflict == true ? 1 : 0,
            ),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return (db.select(
      db.customFieldDefinition,
    )..where((row) => row.id.equals(id))).getSingle();
  }

  Future<void> updateDefinition(int id, CustomFieldDraft draft) async {
    final current = await _definition(id);
    if (draft.scope.name != current.scope ||
        draft.placement.name != current.uiSection ||
        (draft.scope == FieldScope.project &&
            draft.projectUuid != current.projectUuid)) {
      throw const CustomFieldValidationException(
        'Scope and placement cannot be changed after creation.',
      );
    }
    _validateDraft(draft);
    await _ensureUniqueName(draft, excludingId: id);
    await _ensureDwcMappingAvailable(draft, excludingId: id);
    await db.transaction(() async {
      await _validateApplicabilityChange(current, draft.catalogFormat);
      await _convertValues(current, draft);
      await (db.update(
        db.customFieldDefinition,
      )..where((row) => row.id.equals(id))).write(
        CustomFieldDefinitionCompanion(
          name: Value(draft.name.trim()),
          type: Value(draft.type.name),
          options: Value(_encodedOptions(draft)),
          catalogFormat: Value(
            draft.placement.isSpecimenRelated
                ? draft.catalogFormat?.name
                : null,
          ),
          dwcTarget: Value(draft.dwcMapping?.target),
          dwcField: Value(draft.dwcMapping?.field),
          dwcMode: Value(draft.dwcMapping?.mode.name),
          allowDwcConflict: Value(
            draft.dwcMapping?.allowConflict == true ? 1 : 0,
          ),
          updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
        ),
      );
    });
  }

  Future<List<CustomFieldEntry>> getEntries(CustomFieldOwner owner) async {
    return _getEntries(owner, includeArchived: false);
  }

  /// Returns all applicable definitions for exports, including archived fields.
  ///
  /// Archived definitions intentionally remain exportable so historical data is
  /// never hidden after a field is removed from entry forms.
  Future<List<CustomFieldEntry>> getExportEntries(
    CustomFieldOwner owner,
  ) async {
    return _getEntries(owner, includeArchived: true);
  }

  Future<List<CustomFieldEntry>> _getEntries(
    CustomFieldOwner owner, {
    required bool includeArchived,
  }) async {
    final ownerInfo = await _ownerInfo(owner);
    final definitions = await getDefinitions(
      placement: owner.placement,
      projectUuid: ownerInfo.projectUuid,
      catalogFormat: ownerInfo.catalogFormat,
      includeArchived: includeArchived,
    );
    if (definitions.isEmpty) return const [];
    final ids = definitions.map((definition) => definition.id!).toList();
    final values =
        await (db.select(db.customFieldValue)
              ..where((row) => row.fieldDefinitionId.isIn(ids))
              ..where(_ownerPredicate(owner)))
            .get();
    final valuesByDefinition = {
      for (final value in values) value.fieldDefinitionId: value,
    };
    return definitions
        .map(
          (definition) => CustomFieldEntry(
            definition: definition,
            value: valuesByDefinition[definition.id],
          ),
        )
        .toList(growable: false);
  }

  Future<List<CustomFieldDefinitionData>> getDefinitionsForSpecimenContext({
    required FieldUISection placement,
    required String specimenUuid,
  }) async {
    final info = await _ownerInfo(CustomFieldOwner.specimen(specimenUuid));
    return getDefinitions(
      placement: placement,
      projectUuid: info.projectUuid,
      catalogFormat: info.catalogFormat,
    );
  }

  Future<void> setValues(
    CustomFieldOwner owner,
    Map<int, String?> values,
  ) async {
    for (final entry in values.entries) {
      await setValue(owner, entry.key, entry.value);
    }
  }

  Future<void> setValue(
    CustomFieldOwner owner,
    int definitionId,
    String? rawValue,
  ) async {
    final definition = await _definition(definitionId);
    final ownerInfo = await _ownerInfo(owner);
    _requireApplicable(definition, owner, ownerInfo);
    final normalized = rawValue == null || rawValue.trim().isEmpty
        ? null
        : _normalizeValue(definition, rawValue);
    await db.transaction(() async {
      final existing =
          await (db.select(db.customFieldValue)..where(
                (row) =>
                    row.fieldDefinitionId.equals(definitionId) &
                    _ownerPredicate(owner)(row),
              ))
              .getSingleOrNull();
      if (normalized == null) {
        if (existing != null) {
          await (db.delete(
            db.customFieldValue,
          )..where((row) => row.id.equals(existing.id!))).go();
        }
        return;
      }
      if (existing != null) {
        await (db.update(db.customFieldValue)
              ..where((row) => row.id.equals(existing.id!)))
            .write(CustomFieldValueCompanion(value: Value(normalized)));
        return;
      }
      await db
          .into(db.customFieldValue)
          .insert(
            CustomFieldValueCompanion.insert(
              fieldDefinitionId: definitionId,
              projectUuid: Value(ownerInfo.projectUuid),
              value: normalized,
              siteId: Value(owner.siteId),
              specimenUuid: Value(owner.specimenUuid),
              specimenPartId: Value(owner.specimenPartId),
              parasiteId: Value(owner.parasiteId),
            ),
          );
    });
  }

  Future<CustomFieldUsage> getUsage(int definitionId) async {
    final count = db.customFieldValue.id.count();
    final legacy = db.customFieldValue.id.count(
      filter: db.customFieldValue.isLegacy.equals(1),
    );
    final row =
        await (db.selectOnly(db.customFieldValue)
              ..addColumns([count, legacy])
              ..where(
                db.customFieldValue.fieldDefinitionId.equals(definitionId),
              ))
            .getSingle();
    return CustomFieldUsage(
      valueCount: row.read(count) ?? 0,
      legacyValueCount: row.read(legacy) ?? 0,
    );
  }

  Future<void> setArchived(int definitionId, bool archived) {
    return (db.update(
      db.customFieldDefinition,
    )..where((row) => row.id.equals(definitionId))).write(
      CustomFieldDefinitionCompanion(
        isArchived: Value(archived ? 1 : 0),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  Future<void> discardLegacyValues(int definitionId) {
    return (db.delete(db.customFieldValue)..where(
          (row) =>
              row.fieldDefinitionId.equals(definitionId) &
              row.isLegacy.equals(1),
        ))
        .go();
  }

  Future<void> deleteDefinition(int definitionId) async {
    final usage = await getUsage(definitionId);
    if (!usage.canDelete) {
      throw const CustomFieldValidationException(
        'A custom field can only be deleted after all values are cleared.',
      );
    }
    await (db.delete(
      db.customFieldDefinition,
    )..where((row) => row.id.equals(definitionId))).go();
  }

  Future<void> reorder(List<int> definitionIds) async {
    await db.transaction(() async {
      for (var index = 0; index < definitionIds.length; index++) {
        await (db.update(db.customFieldDefinition)
              ..where((row) => row.id.equals(definitionIds[index])))
            .write(CustomFieldDefinitionCompanion(sortOrder: Value(index)));
      }
    });
  }

  Future<CustomFieldDefinitionData> _definition(int id) => (db.select(
    db.customFieldDefinition,
  )..where((row) => row.id.equals(id))).getSingle();

  void _validateDraft(CustomFieldDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw const CustomFieldValidationException('Enter a field label.');
    }
    if (draft.scope == FieldScope.project &&
        (draft.projectUuid == null || draft.projectUuid!.isEmpty)) {
      throw const CustomFieldValidationException(
        'A project-scoped field requires a project.',
      );
    }
    if (draft.type == FieldType.dropdown) {
      final labels = <String>{};
      for (final option in draft.options) {
        final label = option.label.trim().toLowerCase();
        if (label.isEmpty || !labels.add(label)) {
          throw const CustomFieldValidationException(
            'Dropdown options must be non-empty and unique.',
          );
        }
      }
      if (draft.options.where((option) => !option.isArchived).isEmpty) {
        throw const CustomFieldValidationException(
          'A dropdown requires at least one active option.',
        );
      }
    }
  }

  Future<void> _ensureUniqueName(
    CustomFieldDraft draft, {
    int? excludingId,
  }) async {
    final candidates =
        await (db.select(db.customFieldDefinition)
              ..where((row) => row.uiSection.equals(draft.placement.name))
              ..where(
                (row) =>
                    row.name.lower().equals(draft.name.trim().toLowerCase()),
              ))
            .get();
    final overlaps = candidates.where((candidate) {
      if (candidate.id == excludingId) return false;
      final scopeOverlaps =
          candidate.scope == FieldScope.global.name ||
          draft.scope == FieldScope.global ||
          candidate.projectUuid == draft.projectUuid;
      final catalogOverlaps =
          candidate.catalogFormat == null ||
          draft.catalogFormat == null ||
          candidate.catalogFormat == draft.catalogFormat?.name;
      return scopeOverlaps && catalogOverlaps;
    });
    if (overlaps.isNotEmpty) {
      throw const CustomFieldValidationException(
        'A field with this label already applies in the same context.',
      );
    }
  }

  Future<void> _ensureDwcMappingAvailable(
    CustomFieldDraft draft, {
    int? excludingId,
  }) async {
    final mapping = draft.dwcMapping;
    if (mapping == null || mapping.mode == DwcMappingMode.assertion) return;
    if (!officialDwcFields.contains(mapping.field)) {
      throw const CustomFieldValidationException(
        'Choose an official Darwin Core or Dublin Core field.',
      );
    }
    final hasBuiltInConflict =
        builtInDwcFieldsByTarget[mapping.target]?.contains(mapping.field) ??
        false;
    final definitions =
        await (db.select(db.customFieldDefinition)
              ..where((row) => row.dwcTarget.equals(mapping.target))
              ..where((row) => row.dwcField.equals(mapping.field))
              ..where((row) => row.dwcMode.equals(DwcMappingMode.direct.name)))
            .get();
    final hasCustomConflict = definitions.any((definition) {
      if (definition.id == excludingId) return false;
      final scopeOverlaps =
          definition.scope == FieldScope.global.name ||
          draft.scope == FieldScope.global ||
          definition.projectUuid == draft.projectUuid;
      final catalogOverlaps =
          definition.catalogFormat == null ||
          draft.catalogFormat == null ||
          definition.catalogFormat == draft.catalogFormat?.name;
      return scopeOverlaps && catalogOverlaps;
    });
    if ((hasBuiltInConflict || hasCustomConflict) && !mapping.allowConflict) {
      throw const CustomFieldValidationException(
        'This Darwin Core field already has a value. Confirm that duplicate '
        'values may be joined before saving.',
      );
    }
  }

  String? _encodedOptions(CustomFieldDraft draft) =>
      draft.type == FieldType.dropdown
      ? encodeCustomFieldOptions(draft.options)
      : null;

  Future<void> _validateApplicabilityChange(
    CustomFieldDefinitionData current,
    CatalogFmt? target,
  ) async {
    if (!current.placement.isSpecimenRelated ||
        current.catalogFormat == target?.name ||
        target == null) {
      return;
    }
    final values = await (db.select(
      db.customFieldValue,
    )..where((row) => row.fieldDefinitionId.equals(current.id!))).get();
    for (final value in values.where((value) => value.isLegacy == 0)) {
      final owner = value.specimenUuid != null
          ? CustomFieldOwner.specimen(value.specimenUuid!)
          : value.specimenPartId != null
          ? CustomFieldOwner.specimenPart(value.specimenPartId!)
          : CustomFieldOwner.parasite(value.parasiteId!);
      if ((await _ownerInfo(owner)).catalogFormat != target) {
        throw CustomFieldValidationException(
          'This field has values outside ${target.name}. Clear them first.',
        );
      }
    }
  }

  Future<void> _convertValues(
    CustomFieldDefinitionData current,
    CustomFieldDraft draft,
  ) async {
    final targetType = draft.type;
    if (current.fieldType == targetType && targetType != FieldType.dropdown) {
      return;
    }
    final values = await (db.select(
      db.customFieldValue,
    )..where((row) => row.fieldDefinitionId.equals(current.id!))).get();
    final converted = <int, String>{};
    final failures = <String>[];
    for (final value in values) {
      try {
        converted[value.id!] = _convertValue(value.value, current, draft);
      } on CustomFieldValidationException {
        if (failures.length < 3) {
          failures.add(current.displayValue(value.value));
        }
      }
    }
    if (failures.isNotEmpty) {
      throw CustomFieldValidationException(
        '${failures.length == values.length ? 'All' : 'Some'} values cannot be '
        'converted to ${targetType.name}: ${failures.join(', ')}.',
      );
    }
    for (final entry in converted.entries) {
      await (db.update(db.customFieldValue)
            ..where((row) => row.id.equals(entry.key)))
          .write(CustomFieldValueCompanion(value: Value(entry.value)));
    }
  }

  String _convertValue(
    String raw,
    CustomFieldDefinitionData current,
    CustomFieldDraft draft,
  ) {
    if (draft.type == FieldType.text) return current.displayValue(raw);
    if (draft.type == FieldType.number) {
      if (current.fieldType == FieldType.boolean) {
        return raw == 'true' ? '1' : '0';
      }
      final parsed = double.tryParse(current.displayValue(raw));
      if (parsed == null || !parsed.isFinite) {
        throw const CustomFieldValidationException('Not a finite number.');
      }
      return current.displayValue(raw);
    }
    if (draft.type == FieldType.boolean) {
      final value = current.displayValue(raw).trim().toLowerCase();
      if (value == 'true' || value == 'yes' || value == '1') return 'true';
      if (value == 'false' || value == 'no' || value == '0') return 'false';
      throw const CustomFieldValidationException('Not a boolean.');
    }
    final display = current.displayValue(raw);
    final option = draft.options
        .where(
          (option) =>
              option.uuid == raw ||
              option.label.toLowerCase() == display.toLowerCase(),
        )
        .firstOrNull;
    if (option == null) {
      throw const CustomFieldValidationException('Missing dropdown option.');
    }
    return option.uuid;
  }

  String _normalizeValue(CustomFieldDefinitionData definition, String raw) {
    final value = raw.trim();
    return switch (definition.fieldType) {
      FieldType.text => raw,
      FieldType.number => _normalizeNumber(value),
      FieldType.boolean => _normalizeBoolean(value),
      FieldType.dropdown => _normalizeDropdown(definition, value),
    };
  }

  String _normalizeNumber(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null || !parsed.isFinite) {
      throw const CustomFieldValidationException('Enter a finite number.');
    }
    return value;
  }

  String _normalizeBoolean(String value) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
      return 'true';
    }
    if (normalized == 'false' || normalized == 'no' || normalized == '0') {
      return 'false';
    }
    throw const CustomFieldValidationException('Choose Yes or No.');
  }

  String _normalizeDropdown(
    CustomFieldDefinitionData definition,
    String value,
  ) {
    final option = definition.dropdownOptions
        .where(
          (option) =>
              !option.isArchived &&
              (option.uuid == value ||
                  option.label.toLowerCase() == value.toLowerCase()),
        )
        .firstOrNull;
    if (option == null) {
      throw const CustomFieldValidationException(
        'Choose an active dropdown option.',
      );
    }
    return option.uuid;
  }

  Expression<bool> Function(CustomFieldValue row) _ownerPredicate(
    CustomFieldOwner owner,
  ) => (row) {
    if (owner.siteId != null) return row.siteId.equals(owner.siteId!);
    if (owner.specimenUuid != null) {
      return row.specimenUuid.equals(owner.specimenUuid!);
    }
    if (owner.specimenPartId != null) {
      return row.specimenPartId.equals(owner.specimenPartId!);
    }
    return row.parasiteId.equals(owner.parasiteId!);
  };

  Future<_OwnerInfo> _ownerInfo(CustomFieldOwner owner) async {
    if (owner.siteId != null) {
      final site = await (db.select(
        db.site,
      )..where((row) => row.id.equals(owner.siteId!))).getSingle();
      return _OwnerInfo(projectUuid: site.projectUuid!);
    }
    if (owner.specimenUuid != null) {
      final specimen = await (db.select(
        db.specimen,
      )..where((row) => row.uuid.equals(owner.specimenUuid!))).getSingle();
      return _OwnerInfo(
        projectUuid: specimen.projectUuid!,
        catalogFormat: matchTaxonGroupToCatFmt(specimen.taxonGroup),
      );
    }
    final specimenUuid = owner.specimenPartId != null
        ? (await (db.select(db.specimenPart)
                    ..where((row) => row.id.equals(owner.specimenPartId!)))
                  .getSingle())
              .specimenUuid
        : (await (db.select(
                db.parasite,
              )..where((row) => row.id.equals(owner.parasiteId!))).getSingle())
              .specimenUuid;
    final specimen = await (db.select(
      db.specimen,
    )..where((row) => row.uuid.equals(specimenUuid!))).getSingle();
    return _OwnerInfo(
      projectUuid: specimen.projectUuid!,
      catalogFormat: matchTaxonGroupToCatFmt(specimen.taxonGroup),
    );
  }

  void _requireApplicable(
    CustomFieldDefinitionData definition,
    CustomFieldOwner owner,
    _OwnerInfo info,
  ) {
    if (definition.archived || definition.placement != owner.placement) {
      throw const CustomFieldValidationException(
        'This custom field is not available for this record.',
      );
    }
    if (definition.fieldScope == FieldScope.project &&
        definition.projectUuid != info.projectUuid) {
      throw const CustomFieldValidationException(
        'This custom field belongs to a different project.',
      );
    }
    if (definition.applicableCatalog != null &&
        definition.applicableCatalog != info.catalogFormat) {
      throw const CustomFieldValidationException(
        'This custom field belongs to a different catalog format.',
      );
    }
  }
}

class _OwnerInfo {
  const _OwnerInfo({required this.projectUuid, this.catalogFormat});

  final String projectUuid;
  final CatalogFmt? catalogFormat;
}
