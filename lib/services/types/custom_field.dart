import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:uuid/uuid.dart';

enum FieldType { number, text, boolean, dropdown }

enum FieldUISection {
  specimenAttribute,
  siteAttribute,
  environmentalData,
  specimenPart,
  parasite,
}

enum FieldScope { global, project }

enum DwcMappingMode { direct, assertion }

class CustomFieldOption {
  const CustomFieldOption({
    required this.uuid,
    required this.label,
    this.isArchived = false,
  });

  factory CustomFieldOption.create(String label) =>
      CustomFieldOption(uuid: const Uuid().v4(), label: label.trim());

  factory CustomFieldOption.fromJson(Map<String, dynamic> json) =>
      CustomFieldOption(
        uuid: json['uuid'] as String,
        label: json['label'] as String,
        isArchived: json['isArchived'] as bool? ?? false,
      );

  final String uuid;
  final String label;
  final bool isArchived;

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'label': label,
    'isArchived': isArchived,
  };

  CustomFieldOption copyWith({String? label, bool? isArchived}) =>
      CustomFieldOption(
        uuid: uuid,
        label: label ?? this.label,
        isArchived: isArchived ?? this.isArchived,
      );
}

class DwcFieldMapping {
  const DwcFieldMapping({
    required this.target,
    required this.field,
    required this.mode,
    this.allowConflict = false,
  });

  final String target;
  final String field;
  final DwcMappingMode mode;
  final bool allowConflict;
}

class CustomFieldDraft {
  const CustomFieldDraft({
    required this.name,
    required this.type,
    required this.placement,
    required this.scope,
    this.projectUuid,
    this.catalogFormat,
    this.options = const [],
    this.dwcMapping,
    this.sourceTemplateUuid,
  });

  final String name;
  final FieldType type;
  final FieldUISection placement;
  final FieldScope scope;
  final String? projectUuid;
  final CatalogFmt? catalogFormat;
  final List<CustomFieldOption> options;
  final DwcFieldMapping? dwcMapping;
  final String? sourceTemplateUuid;
}

class CustomFieldCreationContext {
  const CustomFieldCreationContext({
    required this.projectUuid,
    this.catalogFormat,
  });

  final String projectUuid;
  final CatalogFmt? catalogFormat;
}

class CustomFieldDraftController extends ChangeNotifier {
  final Map<int, String?> _values = {};

  Map<int, String?> get values => Map.unmodifiable(_values);

  String? valueFor(int definitionId) => _values[definitionId];

  void setValue(int definitionId, String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      if (_values.remove(definitionId) != null) notifyListeners();
      return;
    }
    if (_values[definitionId] == normalized) return;
    _values[definitionId] = normalized;
    notifyListeners();
  }

  void retainDefinitionIds(Iterable<int> definitionIds) {
    final retained = definitionIds.toSet();
    final previousLength = _values.length;
    _values.removeWhere((definitionId, _) => !retained.contains(definitionId));
    if (_values.length != previousLength) notifyListeners();
  }
}

class CustomFieldOwner {
  const CustomFieldOwner._({
    required this.placement,
    this.eventId,
    this.siteId,
    this.specimenUuid,
    this.specimenPartId,
    this.parasiteId,
  });

  const CustomFieldOwner.site(int id)
    : this._(placement: FieldUISection.siteAttribute, siteId: id);

  const CustomFieldOwner.environment(int id)
    : this._(placement: FieldUISection.environmentalData, eventId: id);

  const CustomFieldOwner.specimen(String uuid)
    : this._(placement: FieldUISection.specimenAttribute, specimenUuid: uuid);

  const CustomFieldOwner.specimenPart(int id)
    : this._(placement: FieldUISection.specimenPart, specimenPartId: id);

  const CustomFieldOwner.parasite(int id)
    : this._(placement: FieldUISection.parasite, parasiteId: id);

  final FieldUISection placement;
  final int? eventId;
  final int? siteId;
  final String? specimenUuid;
  final int? specimenPartId;
  final int? parasiteId;

  @override
  bool operator ==(Object other) =>
      other is CustomFieldOwner &&
      other.placement == placement &&
      other.eventId == eventId &&
      other.siteId == siteId &&
      other.specimenUuid == specimenUuid &&
      other.specimenPartId == specimenPartId &&
      other.parasiteId == parasiteId;

  @override
  int get hashCode => Object.hash(
    placement,
    eventId,
    siteId,
    specimenUuid,
    specimenPartId,
    parasiteId,
  );
}

class CustomFieldEntry {
  const CustomFieldEntry({required this.definition, this.value});

  final CustomFieldDefinitionData definition;
  final CustomFieldValueData? value;
}

class CustomFieldUsage {
  const CustomFieldUsage({
    required this.valueCount,
    required this.legacyValueCount,
  });

  final int valueCount;
  final int legacyValueCount;

  bool get canDelete => valueCount == 0;
}

extension CustomFieldDefinitionX on CustomFieldDefinitionData {
  FieldType get fieldType => FieldType.values.byName(type);
  FieldUISection get placement => FieldUISection.values.byName(uiSection);
  FieldScope get fieldScope => FieldScope.values.byName(scope);
  CatalogFmt? get applicableCatalog =>
      catalogFormat == null ? null : CatalogFmt.values.byName(catalogFormat!);
  bool get archived => isArchived == 1;
  bool get permitsDwcConflict => allowDwcConflict == 1;

  List<CustomFieldOption> get dropdownOptions {
    if (options == null || options!.trim().isEmpty) return const [];
    final decoded = jsonDecode(options!) as List<dynamic>;
    return decoded
        .map(
          (item) => CustomFieldOption.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }

  DwcFieldMapping? get dwcMapping {
    if (dwcTarget == null || dwcField == null || dwcMode == null) return null;
    return DwcFieldMapping(
      target: dwcTarget!,
      field: dwcField!,
      mode: DwcMappingMode.values.byName(dwcMode!),
      allowConflict: permitsDwcConflict,
    );
  }

  String displayValue(String raw) {
    if (fieldType == FieldType.boolean) return raw == 'true' ? 'Yes' : 'No';
    if (fieldType != FieldType.dropdown) return raw;
    return dropdownOptions
            .where((option) => option.uuid == raw)
            .map((option) => option.label)
            .firstOrNull ??
        raw;
  }
}

extension FieldUISectionLabel on FieldUISection {
  String get label => switch (this) {
    FieldUISection.specimenAttribute => 'Specimen Attributes',
    FieldUISection.siteAttribute => 'Site Attributes',
    FieldUISection.environmentalData => 'Environmental Data',
    FieldUISection.specimenPart => 'Specimen Part',
    FieldUISection.parasite => 'Parasite',
  };

  bool get isSpecimenRelated =>
      this == FieldUISection.specimenAttribute ||
      this == FieldUISection.specimenPart ||
      this == FieldUISection.parasite;
}

String encodeCustomFieldOptions(List<CustomFieldOption> options) => jsonEncode(
  options.map((option) => option.toJson()).toList(growable: false),
);
