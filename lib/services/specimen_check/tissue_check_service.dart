import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/specimen_check/tissue_check_settings.dart';

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
  const TissueCheckService({required this.database, required this.projectUuid});

  final Database database;
  final String projectUuid;

  /// Looks up [code] by barcode ID first, then by tissue ID.
  Future<TissueCheckMatch> find(String code) async {
    final text = code.trim();
    if (text.isEmpty) {
      return const TissueCheckMatch(TissueMatchStatus.notFound, []);
    }
    final records = await SpecimenPartQuery(
      database,
    ).findPartsByCode(projectUuid, text);
    final byBarcode = records.where((e) => e.part.barcodeID == text).toList();
    final candidates = byBarcode.isNotEmpty ? byBarcode : records;
    return switch (candidates.length) {
      0 => const TissueCheckMatch(TissueMatchStatus.notFound, []),
      1 => TissueCheckMatch(TissueMatchStatus.matched, candidates),
      _ => TissueCheckMatch(TissueMatchStatus.ambiguous, candidates),
    };
  }

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
