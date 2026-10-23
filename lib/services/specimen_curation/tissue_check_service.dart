import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_entry.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';

enum TissueMatchStatus { matched, notFound, ambiguous }

/// The parts a scanned code points to.
class TissueCheckMatch {
  const TissueCheckMatch(this.status, this.records);

  final TissueMatchStatus status;

  /// One record when matched, several when ambiguous, none when not found.
  final List<SpecimenPartProjectRecord> records;
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

/// Finds scanned tubes and writes their check-in values. It works on the
/// database directly; callers refresh any providers that show parts.
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

  /// Finds the parts [query] points to, by tissue ID or barcode, or by
  /// field ID, then narrows them by part type and treatment. The query's
  /// own type and treatment win over [partType] and [preservation].
  Future<TissueCheckMatch> find(
    TissueQuery query, {
    TissueIdentifyBy identifyBy = TissueIdentifyBy.tissueId,
    String? partType,
    String? preservation,
  }) async {
    final text = query.id.trim();
    if (text.isEmpty) {
      return const TissueCheckMatch(TissueMatchStatus.notFound, []);
    }
    final records = switch (identifyBy) {
      TissueIdentifyBy.tissueId => await _findByCode(text),
      TissueIdentifyBy.fieldId => await _findByFieldId(text),
    };
    final type = query.partType ?? partType;
    final treatment = query.preservation ?? preservation;
    final candidates = records
        .where(
          (e) =>
              matchesTissueFilter(e.part.type, type) &&
              matchesTissueFilter(e.part.treatment, treatment),
        )
        .toList(growable: false);
    return switch (candidates.length) {
      0 => const TissueCheckMatch(TissueMatchStatus.notFound, []),
      1 => TissueCheckMatch(TissueMatchStatus.matched, candidates),
      _ => TissueCheckMatch(TissueMatchStatus.ambiguous, candidates),
    };
  }

  /// The project's parts without a storage location that match
  /// [partType] and [preservation], in field ID order.
  Future<List<SpecimenPartProjectRecord>> workList({
    String? partType,
    String? preservation,
  }) async {
    await loadFieldIds();
    final records = await SpecimenPartQuery(
      database,
    ).getSpecimenPartsForProject(projectUuid);
    final parts = records
        .where(
          (e) =>
              (e.part.storageLocation ?? '').trim().isEmpty &&
              matchesTissueFilter(e.part.type, partType) &&
              matchesTissueFilter(e.part.treatment, preservation),
        )
        .toList();
    parts.sort(_compareByFieldId);
    return parts;
  }

  Future<List<SpecimenPartProjectRecord>> _findByCode(String code) async {
    final records = await SpecimenPartQuery(
      database,
    ).findPartsByCode(projectUuid, code);
    final byBarcode = records.where((e) => e.part.barcodeID == code).toList();
    return byBarcode.isNotEmpty ? byBarcode : records;
  }

  /// Matches the whole field ID first. A bare number matches every
  /// specimen with that number, whatever its prefix or initial.
  Future<List<SpecimenPartProjectRecord>> _findByFieldId(String text) async {
    await loadFieldIds();
    final key = normalizeBatchId(text);
    final uuids = _byFieldId[key] ?? _byNumber[key] ?? const <String>[];
    if (uuids.isEmpty) return const [];
    return SpecimenPartQuery(database).getPartsForSpecimens(projectUuid, uuids);
  }

  int _compareByFieldId(
    SpecimenPartProjectRecord a,
    SpecimenPartProjectRecord b,
  ) {
    final aId = fieldIdOf(a.specimen.uuid);
    final bId = fieldIdOf(b.specimen.uuid);
    final byPrefix = _prefixOf(aId).compareTo(_prefixOf(bId));
    if (byPrefix != 0) return byPrefix;
    final aNumber = a.specimen.projectFieldNumber ?? a.specimen.fieldNumber;
    final bNumber = b.specimen.projectFieldNumber ?? b.specimen.fieldNumber;
    final byNumber = (aNumber ?? 0).compareTo(bNumber ?? 0);
    if (byNumber != 0) return byNumber;
    return (a.part.id ?? 0).compareTo(b.part.id ?? 0);
  }

  String _prefixOf(String fieldId) =>
      fieldId.replaceAll(RegExp(r'\d'), '').toLowerCase();

  /// Writes [value] to [field] and [location] to the storage location.
  ///
  /// Without [overwrite], a part that already has a storage location or a
  /// different field value is left as is and reported as a conflict.
  Future<TissueCheckWrite> apply(
    SpecimenPartData part, {
    required TissueCheckField field,
    required String value,
    required String location,
    required bool overwrite,
  }) async {
    final previousValue = readField(part, field);
    final previousLocation = part.storageLocation;
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
    await _write(part.id!, field, value, location);
    return TissueCheckWrite(
      status: TissueWriteStatus.written,
      previousValue: previousValue,
      previousLocation: previousLocation,
    );
  }

  /// Puts back the values a check replaced.
  Future<void> revert(
    int partId, {
    required TissueCheckField field,
    required String? value,
    required String? location,
  }) {
    return _write(partId, field, value, location);
  }

  /// The storage locations already written in the box named [boxName].
  Future<List<String>> locationsInBox(String boxName) {
    return SpecimenPartQuery(
      database,
    ).getStorageLocationsWithPrefix(projectUuid, '$boxName: ');
  }

  static String? readField(SpecimenPartData part, TissueCheckField field) {
    return switch (field) {
      TissueCheckField.museumPermanent => part.museumPermanent,
      TissueCheckField.museumLoan => part.museumLoan,
    };
  }

  Future<void> _write(
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
