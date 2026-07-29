import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';

void main() {
  late Database db;

  setUp(() {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  test('project list returns lightweight project summaries', () async {
    await db.into(db.project).insert(const ProjectCompanion(
          uuid: Value('project-a'),
          name: Value('Project A'),
          description: Value('Not part of the summary'),
          created: Value('2026-01-01 08:00'),
          lastAccessed: Value('2026-01-02 09:00'),
        ));

    final summaries = await ProjectQuery(db).getProjectList();

    expect(summaries, hasLength(1));
    expect(summaries.single.uuid, 'project-a');
    expect(summaries.single.name, 'Project A');
    expect(summaries.single.created, '2026-01-01 08:00');
    expect(summaries.single.lastAccessed, '2026-01-02 09:00');
  });

  group('specimen search', () {
    setUp(() async {
      await _seedSpecimenSearchData(db);
    });

    test('matches field number, personnel, and scientific name', () async {
      final query = SpecimenQuery(db);

      for (final search in [
        '10',
        'Alice Cataloger',
        'Bob Preparator',
        'Myotis lucifugus',
      ]) {
        final results = await query.searchSpecimens(
          SpecimenSearchCriteria(
            projectUuid: 'project-a',
            searchQuery: search,
          ),
          limit: 50,
          offset: 0,
        );

        expect(results.map((row) => row.uuid), ['specimen-a-10']);
      }
    });

    test('isolates projects and orders and paginates by field number',
        () async {
      final query = SpecimenQuery(db);
      const criteria = SpecimenSearchCriteria(projectUuid: 'project-a');

      final firstPage = await query.searchSpecimens(
        criteria,
        limit: 1,
        offset: 0,
      );
      final secondPage = await query.searchSpecimens(
        criteria,
        limit: 1,
        offset: 1,
      );

      expect(firstPage.map((row) => row.uuid), ['specimen-a-2']);
      expect(secondPage.map((row) => row.uuid), ['specimen-a-10']);
      expect(await query.countSpecimens(criteria), 2);
    });

    test('applies inclusive collection and preparation date ranges', () async {
      final query = SpecimenQuery(db);
      const criteria = SpecimenSearchCriteria(
        projectUuid: 'project-a',
        hasCollectionDate: true,
        collectionStartDate: '2026-01-10',
        collectionEndDate: '2026-01-10',
        hasPrepDate: true,
        prepStartDate: '2026-02-10',
        prepEndDate: '2026-02-10',
      );

      final results = await query.searchSpecimens(
        criteria,
        limit: 50,
        offset: 0,
      );

      expect(results.map((row) => row.uuid), ['specimen-a-10']);
      expect(await query.countSpecimens(criteria), results.length);
    });

    test('count uses the same search predicates as row retrieval', () async {
      final query = SpecimenQuery(db);
      const criteria = SpecimenSearchCriteria(
        projectUuid: 'project-a',
        searchQuery: 'Alice',
      );

      final results = await query.searchSpecimens(
        criteria,
        limit: 50,
        offset: 0,
      );

      expect(await query.countSpecimens(criteria), results.length);
      expect(results.map((row) => row.uuid), ['specimen-a-10']);
    });
  });
}

Future<void> _seedSpecimenSearchData(Database db) async {
  await db.batch((batch) {
    batch.insertAll(db.project, const [
      ProjectCompanion(
        uuid: Value('project-a'),
        name: Value('Project A'),
      ),
      ProjectCompanion(
        uuid: Value('project-b'),
        name: Value('Project B'),
      ),
    ]);
    batch.insertAll(db.personnel, const [
      PersonnelCompanion(
        uuid: Value('cataloger-a'),
        name: Value('Alice Cataloger'),
      ),
      PersonnelCompanion(
        uuid: Value('preparator-a'),
        name: Value('Bob Preparator'),
      ),
    ]);
  });

  final taxonId = await db.into(db.taxonomy).insert(const TaxonomyCompanion(
        genus: Value('Myotis'),
        specificEpithet: Value('lucifugus'),
      ));

  await db.batch((batch) {
    batch.insertAll(db.specimen, [
      SpecimenCompanion(
        uuid: const Value('specimen-a-10'),
        projectUuid: const Value('project-a'),
        fieldNumber: const Value(10),
        catalogerID: const Value('cataloger-a'),
        preparatorID: const Value('preparator-a'),
        speciesID: Value(taxonId),
        collectionDate: const Value('2026-01-10'),
        prepDate: const Value('2026-02-10'),
      ),
      const SpecimenCompanion(
        uuid: Value('specimen-a-2'),
        projectUuid: Value('project-a'),
        fieldNumber: Value(2),
        collectionDate: Value('2026-01-11'),
        prepDate: Value('2026-02-11'),
      ),
      const SpecimenCompanion(
        uuid: Value('specimen-b-1'),
        projectUuid: Value('project-b'),
        fieldNumber: Value(1),
        catalogerID: Value('cataloger-a'),
        preparatorID: Value('preparator-a'),
        collectionDate: Value('2026-01-10'),
        prepDate: Value('2026-02-10'),
      ),
    ]);
  });
}
