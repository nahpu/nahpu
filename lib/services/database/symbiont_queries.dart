import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/like_pattern.dart';

part 'symbiont_queries.g.dart';

@DriftAccessor(include: {'tables.drift'})
class SymbiontQuery extends DatabaseAccessor<Database>
    with _$SymbiontQueryMixin {
  SymbiontQuery(super.db);

  Future<SymbiontDetectionData?> getDetection(String specimenUuid) {
    return (select(
      symbiontDetection,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).getSingleOrNull();
  }

  Future<void> ensureDetection(String specimenUuid) async {
    final current = await getDetection(specimenUuid);
    if (current != null) return;
    await into(
      symbiontDetection,
    ).insert(SymbiontDetectionCompanion.insert(specimenUuid: specimenUuid));
  }

  Future<void> updateDetection(
    String specimenUuid,
    SymbiontDetectionCompanion form,
  ) async {
    await ensureDetection(specimenUuid);
    await (update(
      symbiontDetection,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).write(form);
  }

  Future<List<SymbiontData>> getSymbionts(String specimenUuid) {
    return (select(symbiont)
          ..where((row) => row.specimenUuid.equals(specimenUuid))
          ..orderBy([(row) => OrderingTerm(expression: row.id)]))
        .get();
  }

  /// Returns the project's symbionts together with their parent specimen.
  /// The inner join intentionally excludes orphaned symbiont rows.
  Future<List<SymbiontProjectRecord>> getSymbiontsForProject(
    String projectUuid,
  ) async {
    final query =
        select(symbiont).join([
            innerJoin(specimen, specimen.uuid.equalsExp(symbiont.specimenUuid)),
          ])
          ..where(specimen.projectUuid.equals(projectUuid))
          ..orderBy([
            OrderingTerm.asc(specimen.fieldNumber),
            OrderingTerm.asc(symbiont.symbiontID),
            OrderingTerm.asc(symbiont.id),
          ]);
    final rows = await query.get();
    return rows
        .map(
          (row) => SymbiontProjectRecord(
            symbiont: row.readTable(symbiont),
            specimen: row.readTable(specimen),
          ),
        )
        .toList(growable: false);
  }

  /// The project's symbionts whose symbiont ID is [code].
  Future<List<SymbiontProjectRecord>> findSymbiontsByCode(
    String projectUuid,
    String code,
  ) {
    return _getProjectSymbionts(
      projectUuid,
      where: symbiont.symbiontID.equals(code),
    );
  }

  /// The symbionts of the specimens in [uuids].
  Future<List<SymbiontProjectRecord>> getSymbiontsForSpecimens(
    String projectUuid,
    Iterable<String> uuids,
  ) {
    return _getProjectSymbionts(projectUuid, where: specimen.uuid.isIn(uuids));
  }

  /// The project's symbionts whose ids are in [ids].
  Future<List<SymbiontProjectRecord>> getSymbiontsByIds(
    String projectUuid,
    Iterable<int> ids,
  ) {
    return _getProjectSymbionts(projectUuid, where: symbiont.id.isIn(ids));
  }

  /// The project's symbionts whose storage location starts with [prefix],
  /// ignoring leading spaces.
  Future<List<SymbiontProjectRecord>> getSymbiontsWithLocationPrefix(
    String projectUuid,
    String prefix,
  ) async {
    final records = await _getProjectSymbionts(
      projectUuid,
      where: symbiont.storageLocation.like(
        '%${escapeLikePattern(prefix)}%',
        escapeChar: likeEscapeChar,
      ),
    );
    return records
        .where(
          (e) =>
              (e.symbiont.storageLocation ?? '').trimLeft().startsWith(prefix),
        )
        .toList(growable: false);
  }

  Future<List<String>> getDistinctCategories() {
    return _getDistinctValues(symbiont.category);
  }

  Future<List<String>> getDistinctInteractionTypes() {
    return _getDistinctValues(symbiont.interactionType);
  }

  Future<List<String>> getDistinctDetectionMethods() {
    return _getDistinctValues(symbiont.detectionMethod);
  }

  Future<List<String>> getDistinctPreparationMethods() {
    return _getDistinctValues(symbiont.preparationMethod);
  }

  Future<List<String>> getDistinctAnatomicalLocations() {
    return _getDistinctValues(symbiont.anatomicalLocation);
  }

  Future<List<String>> getDistinctStorageValues() {
    return _getDistinctValues(symbiont.storage);
  }

  Future<List<String>> getDistinctTreatments() {
    return _getDistinctValues(symbiont.treatment);
  }

  Future<int> createSymbiont(SymbiontCompanion form) {
    return into(symbiont).insert(form);
  }

  Future<void> updateSymbiont(int id, SymbiontCompanion form) {
    return (update(symbiont)..where((row) => row.id.equals(id))).write(form);
  }

  Future<void> deleteSymbionts(List<int> ids) async {
    await (delete(
      symbiontIndividual,
    )..where((row) => row.symbiontID.isIn(ids))).go();
    await (delete(symbiont)..where((row) => row.id.isIn(ids))).go();
  }

  Future<void> deleteAllForSpecimen(String specimenUuid) async {
    final symbiontIds = selectOnly(symbiont)
      ..addColumns([symbiont.id])
      ..where(symbiont.specimenUuid.equals(specimenUuid));
    await (delete(
      symbiontIndividual,
    )..where((row) => row.symbiontID.isInQuery(symbiontIds))).go();
    await (delete(
      symbiont,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).go();
    await (delete(
      symbiontDetection,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).go();
  }

  Future<List<SymbiontProjectRecord>> _getProjectSymbionts(
    String projectUuid, {
    required Expression<bool> where,
  }) async {
    final query =
        select(symbiont).join([
            innerJoin(specimen, specimen.uuid.equalsExp(symbiont.specimenUuid)),
          ])
          ..where(specimen.projectUuid.equals(projectUuid) & where)
          ..orderBy([OrderingTerm.asc(symbiont.id)]);
    final rows = await query.get();
    return rows
        .map(
          (row) => SymbiontProjectRecord(
            symbiont: row.readTable(symbiont),
            specimen: row.readTable(specimen),
          ),
        )
        .toList(growable: false);
  }

  Future<List<String>> _getDistinctValues(
    GeneratedColumn<String> column,
  ) async {
    final query = selectOnly(symbiont, distinct: true)
      ..addColumns([column])
      ..where(column.isNotNull() & column.isNotValue(''))
      ..orderBy([OrderingTerm.asc(column)]);
    final rows = await query.get();
    return rows.map((row) => row.read(column)).whereType<String>().toList();
  }
}

/// A symbiont paired with the specimen it was collected from.
class SymbiontProjectRecord {
  const SymbiontProjectRecord({required this.symbiont, required this.specimen});

  final SymbiontData symbiont;
  final SpecimenData specimen;

  String? get recordId => symbiont.id?.toString();
}
