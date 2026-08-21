import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/statistics_queries.dart';
import 'package:nahpu/services/types/statistics.dart';

void main() {
  late Database db;
  late StatisticsQuery query;

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    query = StatisticsQuery(db);
    await _seedStatistics(db);
  });

  tearDown(() => db.close());

  test('species and family counts are grouped and project scoped', () async {
    final species = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            kind: StatisticKind.species,
          ),
        )
        .first;
    final families = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            kind: StatisticKind.families,
          ),
        )
        .first;

    expect(species.map((row) => (row.label, row.count)), [
      ('Myotis lucifugus', 2),
      ('Eptesicus fuscus', 1),
      ('Unidentified species', 1),
    ]);
    expect(families.map((row) => (row.label, row.count)), [
      ('Vespertilionidae', 3),
      ('No family', 1),
    ]);
  });

  test('top statistics are limited and ties sort by label', () async {
    final rows = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-limit',
            kind: StatisticKind.species,
            limit: 5,
          ),
        )
        .first;

    expect(rows, hasLength(5));
    expect(rows.map((row) => row.label), [
      'Genus0 species0',
      'Genus1 species1',
      'Genus2 species2',
      'Genus3 species3',
      'Genus4 species4',
    ]);
  });

  test('part statistics sum quantities and normalize missing values', () async {
    final types = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            kind: StatisticKind.partTypes,
          ),
        )
        .first;
    final treatments = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            kind: StatisticKind.partTreatments,
          ),
        )
        .first;

    expect(types.map((row) => (row.label, row.count)), [
      ('Wing', 5),
      ('No part type', 1),
    ]);
    expect(treatments.map((row) => (row.label, row.count)), [
      ('No treatment', 4),
      ('Frozen', 2),
    ]);
  });

  test('site and species filters aggregate only matching records', () async {
    final sites = await query
        .watchFilterOptions('project-a', StatisticKind.speciesBySite)
        .first;
    final taxa = await query
        .watchFilterOptions('project-a', StatisticKind.partTypesBySpecies)
        .first;
    final siteRows = await query
        .watchStatistics(
          StatisticRequest(
            projectUuid: 'project-a',
            kind: StatisticKind.speciesBySite,
            filterId: sites.single.id,
          ),
        )
        .first;
    final myotis = taxa.singleWhere(
      (option) => option.label.startsWith('Myotis'),
    );
    final partRows = await query
        .watchStatistics(
          StatisticRequest(
            projectUuid: 'project-a',
            kind: StatisticKind.partTypesBySpecies,
            filterId: myotis.id,
          ),
        )
        .first;

    expect(sites.single.label, 'Site Alpha');
    expect(siteRows.map((row) => (row.label, row.count)), [
      ('Myotis lucifugus', 2),
      ('Eptesicus fuscus', 1),
    ]);
    expect(partRows.map((row) => (row.label, row.count)), [
      ('Wing', 5),
      ('No part type', 1),
    ]);
  });

  test('record totals are calculated in SQLite', () async {
    final totals = await query.watchRecordTotals('project-a').first;

    expect(totals.siteCount, 1);
    expect(totals.eventCount, 1);
    expect(totals.specimenCount, 4);
    expect(totals.narrativeCount, 1);

    final otherProjectTotals = await query.watchRecordTotals('project-b').first;
    expect(otherProjectTotals.siteCount, 0);
    expect(otherProjectTotals.eventCount, 0);
    expect(otherProjectTotals.specimenCount, 1);
    expect(otherProjectTotals.narrativeCount, 1);
  });

  test('table rows include stable rank and percentages', () {
    final rows = buildStatisticTableRows(const [
      StatisticDatum(label: 'A', count: 3),
      StatisticDatum(label: 'B', count: 1),
    ]);

    expect(rows.map((row) => row.rank), [1, 2]);
    expect(rows.map((row) => row.percent), [75, 25]);
  });
}

Future<void> _seedStatistics(Database db) async {
  await db.batch((batch) {
    batch.insertAll(db.project, const [
      ProjectCompanion(uuid: Value('project-a'), name: Value('Project A')),
      ProjectCompanion(uuid: Value('project-b'), name: Value('Project B')),
      ProjectCompanion(
        uuid: Value('project-limit'),
        name: Value('Project Limit'),
      ),
    ]);
  });

  final myotis = await db
      .into(db.taxonomy)
      .insert(
        const TaxonomyCompanion(
          taxonFamily: Value('Vespertilionidae'),
          genus: Value('Myotis'),
          specificEpithet: Value('lucifugus'),
        ),
      );
  final eptesicus = await db
      .into(db.taxonomy)
      .insert(
        const TaxonomyCompanion(
          taxonFamily: Value('Vespertilionidae'),
          genus: Value('Eptesicus'),
          specificEpithet: Value('fuscus'),
        ),
      );
  final site = await db
      .into(db.site)
      .insert(
        const SiteCompanion(
          siteID: Value('Site Alpha'),
          projectUuid: Value('project-a'),
        ),
      );
  final event = await db
      .into(db.collEvent)
      .insert(
        CollEventCompanion(
          projectUuid: const Value('project-a'),
          siteID: Value(site),
        ),
      );

  await db.batch((batch) {
    batch.insertAll(db.narrative, const [
      NarrativeCompanion(
        projectUuid: Value('project-a'),
        narrative: Value('Project A note'),
      ),
      NarrativeCompanion(
        projectUuid: Value('project-b'),
        narrative: Value('Project B note'),
      ),
    ]);
  });

  await db.batch((batch) {
    batch.insertAll(db.specimen, [
      SpecimenCompanion(
        uuid: const Value('a-1'),
        projectUuid: const Value('project-a'),
        speciesID: Value(myotis),
        collEventID: Value(event),
      ),
      SpecimenCompanion(
        uuid: const Value('a-2'),
        projectUuid: const Value('project-a'),
        speciesID: Value(myotis),
        collEventID: Value(event),
      ),
      SpecimenCompanion(
        uuid: const Value('a-3'),
        projectUuid: const Value('project-a'),
        speciesID: Value(eptesicus),
        collEventID: Value(event),
      ),
      const SpecimenCompanion(
        uuid: Value('a-unknown'),
        projectUuid: Value('project-a'),
      ),
      SpecimenCompanion(
        uuid: const Value('b-1'),
        projectUuid: const Value('project-b'),
        speciesID: Value(myotis),
      ),
    ]);
    batch.insertAll(db.specimenPart, const [
      SpecimenPartCompanion(
        specimenUuid: Value('a-1'),
        type: Value('Wing'),
        count: Value('3'),
        treatment: Value('None'),
      ),
      SpecimenPartCompanion(
        specimenUuid: Value('a-2'),
        type: Value('Wing'),
        count: Value('2'),
        treatment: Value('Frozen'),
      ),
      SpecimenPartCompanion(
        specimenUuid: Value('a-2'),
        type: Value(''),
        count: Value('invalid'),
        treatment: Value(''),
      ),
      SpecimenPartCompanion(
        specimenUuid: Value('b-1'),
        type: Value('Foreign project part'),
        count: Value('99'),
      ),
    ]);
  });

  for (var index = 0; index < 6; index++) {
    final taxon = await db
        .into(db.taxonomy)
        .insert(
          TaxonomyCompanion(
            genus: Value('Genus$index'),
            specificEpithet: Value('species$index'),
          ),
        );
    await db
        .into(db.specimen)
        .insert(
          SpecimenCompanion(
            uuid: Value('limit-$index'),
            projectUuid: const Value('project-limit'),
            speciesID: Value(taxon),
          ),
        );
  }
}
