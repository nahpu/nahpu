import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/symbiont_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_entry.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';

enum TissueMatchStatus { matched, notFound, ambiguous }

/// The tubes a scanned code points to.
class TissueCheckMatch {
  const TissueCheckMatch(this.status, this.records);

  final TissueMatchStatus status;

  /// One record when matched, several when ambiguous, none when not found.
  final List<TissueItemRecord> records;
}

enum TissueWriteStatus { written, conflict }

/// The outcome of writing a tissue check to a part.
class TissueCheckWrite {
  const TissueCheckWrite({
    required this.status,
    this.previousValue,
    this.previousLocation,
  });

  final TissueWriteStatus status;
  final String? previousValue;
  final String? previousLocation;
}

/// Finds scanned tubes, specimen parts and optionally symbionts, and writes
/// their check-in values. It works on the database directly; callers refresh
/// any providers that show parts.
class TissueCheckService {
  TissueCheckService({required this.database, required this.projectUuid});

  final Database database;
  final String projectUuid;

  /// Field IDs by specimen uuid, and specimen uuids by normalized field ID
  /// and by bare number. Built once, since field IDs rarely change while a
  /// box is filled.
  Map<String, String>? _fieldIds;
  final Map<String, List<String>> _byFieldId = {};
  final Map<String, List<String>> _byNumber = {};

  /// The field ID of [specimenUuid], once [loadFieldIds] has run.
  String fieldIdOf(String specimenUuid) => _fieldIds?[specimenUuid] ?? '';

  /// Builds the field ID lookup for the project.
  Future<void> loadFieldIds() async {
    if (_fieldIds != null) return;
    final project = await (database.select(
      database.project,
    )..where((t) => t.uuid.equals(projectUuid))).getSingleOrNull();
    final rows = await SpecimenPartQuery(database).getFieldIdRows(projectUuid);
    final fieldIds = <String, String>{};
    for (final row in rows) {
      final fieldId = formatSpecimenFieldId(
        catalogNumberPrefix: project?.catalogNumberPrefix,
        catalogNumberSuffix: project?.catalogNumberSuffix,
        catalogerInitial: row.catalogerInitial,
        fieldNumber: row.fieldNumber,
        projectFieldNumber: row.projectFieldNumber,
      );
      if (fieldId.isEmpty) continue;
      fieldIds[row.uuid] = fieldId;
      _byFieldId.putIfAbsent(normalizeBatchId(fieldId), () => []).add(row.uuid);
      final number = row.projectFieldNumber ?? row.fieldNumber;
      if (number != null) {
        _byNumber.putIfAbsent('$number', () => []).add(row.uuid);
      }
    }
    _fieldIds = fieldIds;
  }

  /// Finds the tubes [query] points to, by tissue ID, barcode, or symbiont
  /// ID, or by field ID, then narrows them by part type and treatment. The
  /// query's own type and treatment win over [partTypes] and
  /// [preservations]. Symbionts are searched only with [includeSymbionts].
  Future<TissueCheckMatch> find(
    TissueQuery query, {
    TissueIdentifyBy identifyBy = TissueIdentifyBy.tissueId,
    Set<String> partTypes = const {},
    Set<String> preservations = const {},
    bool includeSymbionts = false,
    Set<String> symbiontCategories = const {},
  }) async {
    final text = query.id.trim();
    if (text.isEmpty) {
      return const TissueCheckMatch(TissueMatchStatus.notFound, []);
    }
    final records = switch (identifyBy) {
      TissueIdentifyBy.tissueId => await _findByCode(text, includeSymbionts),
      TissueIdentifyBy.fieldId => await _findByFieldId(text, includeSymbionts),
    };
    final types = query.partType != null ? {query.partType!} : partTypes;
    final treatments = query.preservation != null
        ? {query.preservation!}
        : preservations;
    final candidates = records
        .where((e) => _matchesFilters(e, types, treatments, symbiontCategories))
        .toList(growable: false);
    return switch (candidates.length) {
      0 => const TissueCheckMatch(TissueMatchStatus.notFound, []),
      1 => TissueCheckMatch(TissueMatchStatus.matched, candidates),
      _ => TissueCheckMatch(TissueMatchStatus.ambiguous, candidates),
    };
  }

  /// The project's tubes without a storage location that match
  /// [partTypes] and [preservations], in field ID order. Symbionts are
  /// listed only with [includeSymbionts].
  Future<List<TissueItemRecord>> workList({
    Set<String> partTypes = const {},
    Set<String> preservations = const {},
    bool includeSymbionts = false,
    Set<String> symbiontCategories = const {},
  }) async {
    await loadFieldIds();
    final parts = await SpecimenPartQuery(
      database,
    ).getSpecimenPartsForProject(projectUuid);
    final symbionts = includeSymbionts
        ? await SymbiontQuery(database).getSymbiontsForProject(projectUuid)
        : const <SymbiontProjectRecord>[];
    final items = [
      ...parts.map(TissueItemRecord.part),
      ...symbionts.map(TissueItemRecord.symbiont),
    ];
    final unplaced = items
        .where(
          (e) =>
              (e.storageLocation ?? '').trim().isEmpty &&
              _matchesFilters(e, partTypes, preservations, symbiontCategories),
        )
        .toList();
    unplaced.sort(_compareByFieldId);
    return unplaced;
  }

  /// The codes a scan can match, for suggestions while typing: tissue IDs,
  /// barcodes, and symbiont IDs, or field IDs, plus symbiont IDs when
  /// [includeSymbionts]. Sorted and without repeats.
  Future<List<String>> scanCodes({
    TissueIdentifyBy identifyBy = TissueIdentifyBy.tissueId,
    bool includeSymbionts = false,
  }) async {
    final codes = <String>{};
    if (identifyBy == TissueIdentifyBy.fieldId) {
      await loadFieldIds();
      codes.addAll(_fieldIds!.values);
    } else {
      final parts = await SpecimenPartQuery(
        database,
      ).getSpecimenPartsForProject(projectUuid);
      for (final record in parts) {
        codes
          ..add(record.part.tissueID ?? '')
          ..add(record.part.barcodeID ?? '');
      }
    }
    if (includeSymbionts) {
      final symbionts = await SymbiontQuery(
        database,
      ).getSymbiontsForProject(projectUuid);
      codes.addAll(symbionts.map((e) => e.symbiont.symbiontID ?? ''));
    }
    return codes
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  /// Symbionts have no part type, so the type filter passes them; the
  /// category filter applies to symbionts only.
  bool _matchesFilters(
    TissueItemRecord record,
    Set<String> partTypes,
    Set<String> preservations,
    Set<String> symbiontCategories,
  ) {
    final kindMatches = record.isSymbiont
        ? matchesAnyTissueFilter(record.category, symbiontCategories)
        : matchesAnyTissueFilter(record.type, partTypes);
    return kindMatches &&
        matchesAnyTissueFilter(record.treatment, preservations);
  }

  Future<List<TissueItemRecord>> _findByCode(
    String code,
    bool includeSymbionts,
  ) async {
    final records = await SpecimenPartQuery(
      database,
    ).findPartsByCode(projectUuid, code);
    final byBarcode = records.where((e) => e.part.barcodeID == code).toList();
    final parts = byBarcode.isNotEmpty ? byBarcode : records;
    final symbionts = includeSymbionts
        ? await SymbiontQuery(database).findSymbiontsByCode(projectUuid, code)
        : const <SymbiontProjectRecord>[];
    return [
      ...parts.map(TissueItemRecord.part),
      ...symbionts.map(TissueItemRecord.symbiont),
    ];
  }

  /// Matches the whole field ID first. A bare number matches every
  /// specimen with that number, whatever its prefix or initial. With
  /// [includeSymbionts], a symbiont ID matches too, since symbiont tubes
  /// are labeled by their own ID.
  Future<List<TissueItemRecord>> _findByFieldId(
    String text,
    bool includeSymbionts,
  ) async {
    await loadFieldIds();
    final key = normalizeBatchId(text);
    final uuids = _byFieldId[key] ?? _byNumber[key] ?? const <String>[];
    final bySymbiontId = includeSymbionts
        ? await SymbiontQuery(database).findSymbiontsByCode(projectUuid, text)
        : const <SymbiontProjectRecord>[];
    if (uuids.isEmpty) {
      return bySymbiontId.map(TissueItemRecord.symbiont).toList();
    }
    final parts = await SpecimenPartQuery(
      database,
    ).getPartsForSpecimens(projectUuid, uuids);
    final symbionts = includeSymbionts
        ? await SymbiontQuery(
            database,
          ).getSymbiontsForSpecimens(projectUuid, uuids)
        : const <SymbiontProjectRecord>[];
    final symbiontIds = {for (final e in symbionts) e.symbiont.id};
    return [
      ...parts.map(TissueItemRecord.part),
      ...symbionts.map(TissueItemRecord.symbiont),
      for (final e in bySymbiontId)
        if (!symbiontIds.contains(e.symbiont.id)) TissueItemRecord.symbiont(e),
    ];
  }

  int _compareByFieldId(TissueItemRecord a, TissueItemRecord b) {
    final aId = fieldIdOf(a.specimen.uuid);
    final bId = fieldIdOf(b.specimen.uuid);
    final byPrefix = _prefixOf(aId).compareTo(_prefixOf(bId));
    if (byPrefix != 0) return byPrefix;
    final aNumber = a.specimen.projectFieldNumber ?? a.specimen.fieldNumber;
    final bNumber = b.specimen.projectFieldNumber ?? b.specimen.fieldNumber;
    final byNumber = (aNumber ?? 0).compareTo(bNumber ?? 0);
    if (byNumber != 0) return byNumber;
    final bySpecimen = a.specimen.uuid.compareTo(b.specimen.uuid);
    if (bySpecimen != 0) return bySpecimen;
    final byKind = a.kind.index.compareTo(b.kind.index);
    if (byKind != 0) return byKind;
    return a.id.compareTo(b.id);
  }

  String _prefixOf(String fieldId) =>
      fieldId.replaceAll(RegExp(r'\d'), '').toLowerCase();

  /// Writes [value] to [field] and [location] to the storage location.
  ///
  /// Without [overwrite], a tube that already has a storage location or a
  /// different field value is left as is and reported as a conflict.
  Future<TissueCheckWrite> apply(
    TissueItemRecord record, {
    required TissueCheckField field,
    required String value,
    required String location,
    required bool overwrite,
  }) async {
    final previousValue = record.readField(field);
    final previousLocation = record.storageLocation;
    final hasValue =
        previousValue != null &&
        previousValue.trim().isNotEmpty &&
        previousValue.trim() != value.trim();
    final hasLocation =
        previousLocation != null && previousLocation.trim().isNotEmpty;
    if (!overwrite && (hasValue || hasLocation)) {
      return TissueCheckWrite(
        status: TissueWriteStatus.conflict,
        previousValue: previousValue,
        previousLocation: previousLocation,
      );
    }
    await _write(record.kind, record.id, field, value, location);
    return TissueCheckWrite(
      status: TissueWriteStatus.written,
      previousValue: previousValue,
      previousLocation: previousLocation,
    );
  }

  /// Puts back the values a check replaced.
  Future<void> revert(
    TissueItemKind kind,
    int id, {
    required TissueCheckField field,
    required String? value,
    required String? location,
  }) {
    return _write(kind, id, field, value, location);
  }

  /// Writes only the storage location, as when a tube is moved out of a
  /// cell another tube replaces it in. Null clears it.
  Future<void> setLocation(TissueItemKind kind, int id, String? location) {
    return switch (kind) {
      TissueItemKind.part => SpecimenPartQuery(database).updateSpecimenPart(
        id,
        SpecimenPartCompanion(storageLocation: db.Value(location)),
      ),
      TissueItemKind.symbiont => SymbiontQuery(database).updateSymbiont(
        id,
        SymbiontCompanion(storageLocation: db.Value(location)),
      ),
    };
  }

  /// The tubes stored in the box named [boxName], parts and symbionts
  /// alike, since both fill the same cells. Their locations may come from
  /// this tool or be typed in the part and symbiont forms.
  Future<List<TissueItemRecord>> itemsInBox(
    String boxName, {
    TissueLabelFormat format = const TissueLabelFormat.standard(),
  }) async {
    await loadFieldIds();
    final prefix = tissueLocationPrefix(boxName, format: format);
    final parts = await SpecimenPartQuery(
      database,
    ).getPartsWithLocationPrefix(projectUuid, prefix);
    final symbionts = await SymbiontQuery(
      database,
    ).getSymbiontsWithLocationPrefix(projectUuid, prefix);
    return [
      ...parts.map(TissueItemRecord.part),
      ...symbionts.map(TissueItemRecord.symbiont),
    ];
  }

  /// The tubes [keys] point to, read fresh so they carry this session's
  /// writes. Tubes deleted since they were logged are left out.
  Future<Map<(TissueItemKind, int), TissueItemRecord>> recordsFor(
    Iterable<(TissueItemKind, int)> keys,
  ) async {
    await loadFieldIds();
    final partIds = {
      for (final (kind, id) in keys)
        if (kind == TissueItemKind.part) id,
    };
    final symbiontIds = {
      for (final (kind, id) in keys)
        if (kind == TissueItemKind.symbiont) id,
    };
    final parts = partIds.isEmpty
        ? const <SpecimenPartProjectRecord>[]
        : await SpecimenPartQuery(database).getPartsByIds(projectUuid, partIds);
    final symbionts = symbiontIds.isEmpty
        ? const <SymbiontProjectRecord>[]
        : await SymbiontQuery(
            database,
          ).getSymbiontsByIds(projectUuid, symbiontIds);
    return {
      for (final record in [
        ...parts.map(TissueItemRecord.part),
        ...symbionts.map(TissueItemRecord.symbiont),
      ])
        record.key: record,
    };
  }

  Future<void> _write(
    TissueItemKind kind,
    int id,
    TissueCheckField field,
    String? value,
    String? location,
  ) {
    return switch (kind) {
      TissueItemKind.part => _writePart(id, field, value, location),
      TissueItemKind.symbiont => _writeSymbiont(id, field, value, location),
    };
  }

  Future<void> _writeSymbiont(
    int symbiontId,
    TissueCheckField field,
    String? value,
    String? location,
  ) {
    final entry = switch (field) {
      TissueCheckField.museumPermanent => SymbiontCompanion(
        museumPermanent: db.Value(value),
        storageLocation: db.Value(location),
      ),
      TissueCheckField.museumLoan => SymbiontCompanion(
        museumLoan: db.Value(value),
        storageLocation: db.Value(location),
      ),
    };
    return SymbiontQuery(database).updateSymbiont(symbiontId, entry);
  }

  Future<void> _writePart(
    int partId,
    TissueCheckField field,
    String? value,
    String? location,
  ) {
    final entry = switch (field) {
      TissueCheckField.museumPermanent => SpecimenPartCompanion(
        museumPermanent: db.Value(value),
        storageLocation: db.Value(location),
      ),
      TissueCheckField.museumLoan => SpecimenPartCompanion(
        museumLoan: db.Value(value),
        storageLocation: db.Value(location),
      ),
    };
    return SpecimenPartQuery(database).updateSpecimenPart(partId, entry);
  }
}
