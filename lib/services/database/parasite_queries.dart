import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/like_pattern.dart';

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

  /// Returns the project's parasites together with their parent specimen.
  /// The inner join intentionally excludes orphaned parasite rows.
  Future<List<ParasiteProjectRecord>> getParasitesForProject(
    String projectUuid,
  ) async {
    final query =
        select(parasite).join([
            innerJoin(specimen, specimen.uuid.equalsExp(parasite.specimenUuid)),
          ])
          ..where(specimen.projectUuid.equals(projectUuid))
          ..orderBy([
            OrderingTerm.asc(specimen.fieldNumber),
            OrderingTerm.asc(parasite.parasiteID),
            OrderingTerm.asc(parasite.id),
          ]);
    final rows = await query.get();
    return rows
        .map(
          (row) => ParasiteProjectRecord(
            parasite: row.readTable(parasite),
            specimen: row.readTable(specimen),
          ),
        )
        .toList(growable: false);
  }

  /// The project's parasites whose parasite ID is [code].
  Future<List<ParasiteProjectRecord>> findParasitesByCode(
    String projectUuid,
    String code,
  ) {
    return _getProjectParasites(
      projectUuid,
      where: parasite.parasiteID.equals(code),
    );
  }

  /// The parasites of the specimens in [uuids].
  Future<List<ParasiteProjectRecord>> getParasitesForSpecimens(
    String projectUuid,
    Iterable<String> uuids,
  ) {
    return _getProjectParasites(projectUuid, where: specimen.uuid.isIn(uuids));
  }

  /// The project's parasites whose ids are in [ids].
  Future<List<ParasiteProjectRecord>> getParasitesByIds(
    String projectUuid,
    Iterable<int> ids,
  ) {
    return _getProjectParasites(projectUuid, where: parasite.id.isIn(ids));
  }

  /// The project's parasites whose storage location starts with [prefix],
  /// ignoring leading spaces.
  Future<List<ParasiteProjectRecord>> getParasitesWithLocationPrefix(
    String projectUuid,
    String prefix,
  ) async {
    final records = await _getProjectParasites(
      projectUuid,
      where: parasite.storageLocation.like(
        '%${escapeLikePattern(prefix)}%',
        escapeChar: likeEscapeChar,
      ),
    );
    return records
        .where(
          (e) =>
              (e.parasite.storageLocation ?? '').trimLeft().startsWith(prefix),
        )
        .toList(growable: false);
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

  Future<void> deleteParasites(List<int> ids) async {
    await (delete(
      parasiteIndividual,
    )..where((row) => row.parasiteID.isIn(ids))).go();
    await (delete(parasite)..where((row) => row.id.isIn(ids))).go();
  }

  Future<void> deleteAllForSpecimen(String specimenUuid) async {
    final parasiteIds = selectOnly(parasite)
      ..addColumns([parasite.id])
      ..where(parasite.specimenUuid.equals(specimenUuid));
    await (delete(
      parasiteIndividual,
    )..where((row) => row.parasiteID.isInQuery(parasiteIds))).go();
    await (delete(
      parasite,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).go();
    await (delete(
      parasiteDetection,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).go();
  }

  Future<List<ParasiteProjectRecord>> _getProjectParasites(
    String projectUuid, {
    required Expression<bool> where,
  }) async {
    final query =
        select(parasite).join([
            innerJoin(specimen, specimen.uuid.equalsExp(parasite.specimenUuid)),
          ])
          ..where(specimen.projectUuid.equals(projectUuid) & where)
          ..orderBy([OrderingTerm.asc(parasite.id)]);
    final rows = await query.get();
    return rows
        .map(
          (row) => ParasiteProjectRecord(
            parasite: row.readTable(parasite),
            specimen: row.readTable(specimen),
          ),
        )
        .toList(growable: false);
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

/// A parasite paired with the specimen it was collected from.
class ParasiteProjectRecord {
  const ParasiteProjectRecord({required this.parasite, required this.specimen});

  final ParasiteData parasite;
  final SpecimenData specimen;

  String? get recordId => parasite.id?.toString();
}
