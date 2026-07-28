import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'parasite_queries.g.dart';

@DriftAccessor(include: {'tables.drift'})
class ParasiteQuery extends DatabaseAccessor<Database>
    with _$ParasiteQueryMixin {
  ParasiteQuery(super.db);

  Future<ParasiteDetectionData?> getDetection(String specimenUuid) {
    return (select(
      parasiteDetection,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).getSingleOrNull();
  }

  Future<void> ensureDetection(String specimenUuid) async {
    final current = await getDetection(specimenUuid);
    if (current != null) return;
    await into(
      parasiteDetection,
    ).insert(ParasiteDetectionCompanion.insert(specimenUuid: specimenUuid));
  }

  Future<void> updateDetection(
    String specimenUuid,
    ParasiteDetectionCompanion form,
  ) async {
    await ensureDetection(specimenUuid);
    await (update(
      parasiteDetection,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).write(form);
  }

  Future<List<ParasiteData>> getParasites(String specimenUuid) {
    return (select(parasite)
          ..where((row) => row.specimenUuid.equals(specimenUuid))
          ..orderBy([(row) => OrderingTerm(expression: row.id)]))
        .get();
  }

  Future<List<String>> getDistinctCategories() {
    return _getDistinctValues(parasite.category);
  }

  Future<List<String>> getDistinctDetectionMethods() {
    return _getDistinctValues(parasite.detectionMethod);
  }

  Future<List<String>> getDistinctPreparationMethods() {
    return _getDistinctValues(parasite.preparationMethod);
  }

  Future<List<String>> getDistinctAnatomicalLocations() {
    return _getDistinctValues(parasite.anatomicalLocation);
  }

  Future<List<String>> getDistinctStorageValues() {
    return _getDistinctValues(parasite.storage);
  }

  Future<List<String>> getDistinctTreatments() {
    return _getDistinctValues(parasite.treatment);
  }

  Future<int> createParasite(ParasiteCompanion form) {
    return into(parasite).insert(form);
  }

  Future<void> updateParasite(int id, ParasiteCompanion form) {
    return (update(parasite)..where((row) => row.id.equals(id))).write(form);
  }

  Future<void> deleteParasites(List<int> ids) {
    return (delete(parasite)..where((row) => row.id.isIn(ids))).go();
  }

  Future<void> deleteAllForSpecimen(String specimenUuid) async {
    await (delete(
      parasite,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).go();
    await (delete(
      parasiteDetection,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).go();
  }

  Future<List<String>> _getDistinctValues(
    GeneratedColumn<String> column,
  ) async {
    final query = selectOnly(parasite, distinct: true)
      ..addColumns([column])
      ..where(column.isNotNull() & column.isNotValue(''))
      ..orderBy([OrderingTerm.asc(column)]);
    final rows = await query.get();
    return rows.map((row) => row.read(column)).whereType<String>().toList();
  }
}
