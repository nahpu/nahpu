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
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.species,
          ),
        )
        .first;
    final families = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.family,
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
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.species,
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
            measure: StatisticMeasure.partQuantity,
            group: StatisticGroup.partType,
          ),
        )
        .first;
    final treatments = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.partQuantity,
            group: StatisticGroup.partTreatment,
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
        .watchFilterOptions('project-a', StatisticFilterKind.site)
        .first;
    final taxa = await query
        .watchFilterOptions('project-a', StatisticFilterKind.species)
        .first;
    final siteRows = await query
        .watchStatistics(
          StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.species,
            siteId: sites.single.id,
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
            measure: StatisticMeasure.partQuantity,
            group: StatisticGroup.partType,
            speciesId: myotis.id,
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

  test('site, date, and assigned method group specimen counts', () async {
    final event = await (db.select(
      db.collEvent,
    )..where((row) => row.projectUuid.equals('project-a'))).getSingle();
    final method = await db
        .into(db.collEffort)
        .insert(
          CollEffortCompanion(
            eventID: Value(event.id),
            method: const Value('Mist net'),
          ),
        );
    for (final uuid in const ['a-1', 'a-2']) {
      await (db.update(db.specimen)..where((row) => row.uuid.equals(uuid)))
          .write(SpecimenCompanion(collMethodID: Value(method)));
    }

    final sites = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.site,
          ),
        )
        .first;
    final dates = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.date,
          ),
        )
        .first;
    final methods = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.method,
          ),
        )
        .first;
    final speciesBySite = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.species,
            group: StatisticGroup.site,
          ),
        )
        .first;

    expect(sites.map((row) => (row.label, row.count)), [
      ('Site Alpha', 3),
      ('No site', 1),
    ]);
    expect(dates.map((row) => (row.label, row.count)), [
      ('2026-01-10', 2),
      ('2026-01-11', 1),
      ('No date', 1),
    ]);
    expect(methods.map((row) => (row.label, row.count)), [
      ('Mist net', 2),
      ('No method', 2),
    ]);
    expect(speciesBySite.map((row) => (row.label, row.count)), [
      ('Site Alpha', 2),
    ]);
  });

  test('sex and life-stage data normalize across attribute tables', () async {
    final myotis = await (db.select(
      db.taxonomy,
    )..where((row) => row.genus.equals('Myotis'))).getSingle();
    await db.batch((batch) {
      batch.insertAll(db.specimen, [
        SpecimenCompanion(
          uuid: const Value('a-herp'),
          projectUuid: const Value('project-a'),
          speciesID: Value(myotis.id),
        ),
        SpecimenCompanion(
          uuid: const Value('a-arthropod'),
          projectUuid: const Value('project-a'),
          speciesID: Value(myotis.id),
        ),
      ]);
      batch.insertAll(db.mammalAttribute, const [
        MammalAttributeCompanion(
          specimenUuid: Value('a-1'),
          sex: Value(0),
          lifeStage: Value('Adult'),
        ),
      ]);
      batch.insertAll(db.birdAttribute, const [
        BirdAttributeCompanion(
          specimenUuid: Value('a-2'),
          sex: Value(1),
          lifeStage: Value('Adult'),
        ),
      ]);
      batch.insertAll(db.fossilAttribute, const [
        FossilAttributeCompanion(
          specimenUuid: Value('a-3'),
          sex: Value(2),
          ontogeneticStage: Value('Late'),
        ),
      ]);
      batch.insertAll(db.herpAttribute, const [
        HerpAttributeCompanion(
          specimenUuid: Value('a-herp'),
          sex: Value(3),
          lifeStage: Value('Juvenile'),
        ),
      ]);
      batch.insertAll(db.arthropodAttribute, const [
        ArthropodAttributeCompanion(
          specimenUuid: Value('a-arthropod'),
          sex: Value(4),
          lifeStage: Value('Larva'),
        ),
      ]);
    });

    final availability = await query.watchAvailability('project-a').first;
    final sex = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.sex,
          ),
        )
        .first;
    final breakdown = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.species,
            breakdown: StatisticBreakdown.sex,
          ),
        )
        .first;
    final lifeStages = await query
        .watchStatistics(
          const StatisticRequest(
            projectUuid: 'project-a',
            measure: StatisticMeasure.specimens,
            group: StatisticGroup.lifeStage,
          ),
        )
        .first;

    expect(availability.hasSex, isTrue);
    expect(availability.hasLifeStage, isTrue);
    expect(sex.map((row) => (row.label, row.count)), [
      ('Female', 1),
      ('Gynandromorph', 1),
      ('Hermaphrodite', 1),
      ('Male', 1),
      ('Not recorded', 1),
      ('Unknown', 1),
    ]);
    expect(
      breakdown
          .where((row) => row.label == 'Myotis lucifugus')
          .map((row) => (row.seriesLabel, row.count)),
      [('Female', 1), ('Gynandromorph', 1), ('Hermaphrodite', 1), ('Male', 1)],
    );
    expect(lifeStages.map((row) => (row.label, row.count)), [
      ('Adult', 2),
      ('Not recorded', 2),
      ('Juvenile', 1),
      ('Larva', 1),
    ]);
  });

  test('elevation only includes sites with specimen records', () async {
    final unusedSite = await db
        .into(db.site)
        .insert(
          const SiteCompanion(
            siteID: Value('Unused'),
            projectUuid: Value('project-a'),
          ),
        );
    final coordinateSite = await db
        .into(db.site)
        .insert(
          const SiteCompanion(
            siteID: Value('Coordinate site'),
            projectUuid: Value('project-a'),
          ),
        );
    await db
        .into(db.coordinate)
        .insert(
          CoordinateCompanion(
            siteID: Value(unusedSite),
            elevationInMeter: const Value(-100),
          ),
        );
    final coordinate = await db
        .into(db.coordinate)
        .insert(
          CoordinateCompanion(
            siteID: Value(coordinateSite),
            elevationInMeter: const Value(800),
          ),
        );
    await db
        .into(db.specimen)
        .insert(
          SpecimenCompanion(
            uuid: const Value('coordinate-only'),
            projectUuid: const Value('project-a'),
            coordinateID: Value(coordinate),
          ),
        );

    final totals = await query.watchRecordTotals('project-a').first;
    expect(totals.minimumElevationInMeter, 120.5);
    expect(totals.maximumElevationInMeter, 800);
  });

  test('record totals include project summary metrics', () async {
    final totals = await query.watchRecordTotals('project-a').first;

    expect(totals.siteCount, 1);
    expect(totals.eventCount, 1);
    expect(totals.specimenCount, 4);
    expect(totals.speciesCount, 2);
    expect(totals.familyCount, 1);
    expect(totals.narrativeCount, 1);
    expect(totals.minimumElevationInMeter, 120.5);
    expect(totals.maximumElevationInMeter, 350.25);
    expect(totals.totalDays, 3);
    expect(totals.totalCaptureDays, 0);

    final otherProjectTotals = await query.watchRecordTotals('project-b').first;
    expect(otherProjectTotals.siteCount, 0);
    expect(otherProjectTotals.eventCount, 0);
    expect(otherProjectTotals.specimenCount, 1);
    expect(otherProjectTotals.speciesCount, 1);
    expect(otherProjectTotals.familyCount, 1);
    expect(otherProjectTotals.narrativeCount, 1);
    expect(otherProjectTotals.minimumElevationInMeter, equals(null));
    expect(otherProjectTotals.maximumElevationInMeter, equals(null));
    expect(otherProjectTotals.totalDays, equals(null));
    expect(otherProjectTotals.totalCaptureDays, 0);

    final normalizedDuplicate = await db
        .into(db.taxonomy)
        .insert(
          const TaxonomyCompanion(
            taxonFamily: Value(' vespertilionidae '),
            genus: Value(' myotis '),
            specificEpithet: Value(' LUCIFUGUS '),
          ),
        );
    final incompleteSpecies = await db
        .into(db.taxonomy)
        .insert(
          const TaxonomyCompanion(
            taxonFamily: Value('Molossidae'),
            genus: Value('Tadarida'),
          ),
        );
    await db.batch((batch) {
      batch.insertAll(db.specimen, [
        SpecimenCompanion(
          uuid: const Value('a-normalized-duplicate'),
          projectUuid: const Value('project-a'),
          speciesID: Value(normalizedDuplicate),
        ),
        SpecimenCompanion(
          uuid: const Value('a-incomplete-species'),
          projectUuid: const Value('project-a'),
          speciesID: Value(incompleteSpecies),
        ),
      ]);
    });

    final updatedTotals = await query.watchRecordTotals('project-a').first;
    expect(updatedTotals.specimenCount, 6);
    expect(updatedTotals.speciesCount, 2);
    expect(updatedTotals.familyCount, 2);
    expect(updatedTotals.totalCaptureDays, 0);
  });

  test('record totals treat blank project dates as not recorded', () async {
    await (db.update(
      db.project,
    )..where((project) => project.uuid.equals('project-b'))).write(
      const ProjectCompanion(startDate: Value(' '), endDate: Value('')),
    );

    final totals = await query.watchRecordTotals('project-b').first;

    expect(totals.totalDays, equals(null));
  });

  test(
    'capture days expand linked event ranges and deduplicate overlaps',
    () async {
      final event = await (db.select(
        db.collEvent,
      )..where((row) => row.projectUuid.equals('project-a'))).getSingle();
      await (db.update(
        db.collEvent,
      )..where((row) => row.id.equals(event.id))).write(
        const CollEventCompanion(
          startDate: Value(' 2026-01-10T08:00:00 '),
          endDate: Value('2026-01-12 18:00:00'),
        ),
      );

      final overlappingEvent = await db
          .into(db.collEvent)
          .insert(
            const CollEventCompanion(
              projectUuid: Value('project-a'),
              startDate: Value('2026-01-12'),
              endDate: Value('2026-01-14'),
            ),
          );
      final startOnlyEvent = await db
          .into(db.collEvent)
          .insert(
            const CollEventCompanion(
              projectUuid: Value('project-a'),
              startDate: Value('2026-01-20'),
            ),
          );
      final invalidEvent = await db
          .into(db.collEvent)
          .insert(
            const CollEventCompanion(
              projectUuid: Value('project-a'),
              startDate: Value('2026-01-30'),
              endDate: Value('2026-01-29'),
            ),
          );

      await (db.update(db.specimen)..where((row) => row.uuid.equals('a-3')))
          .write(SpecimenCompanion(collEventID: Value(overlappingEvent)));
      await (db.update(
        db.specimen,
      )..where((row) => row.uuid.equals('a-unknown'))).write(
        SpecimenCompanion(
          collEventID: Value(startOnlyEvent),
          captureDate: const Value('2099-01-01'),
        ),
      );
      await db
          .into(db.specimen)
          .insert(
            SpecimenCompanion(
              uuid: const Value('a-invalid-event'),
              projectUuid: const Value('project-a'),
              collEventID: Value(invalidEvent),
              captureDate: const Value('2099-01-02'),
            ),
          );

      final totals = await query.watchRecordTotals('project-a').first;

      expect(totals.totalCaptureDays, 6);
    },
  );

  test('table rows include stable rank and percentages', () {
    final rows = buildStatisticTableRows(const [
      StatisticDatum(label: 'A', count: 3),
      StatisticDatum(label: 'B', count: 1),
    ]);

    expect(rows.map((row) => row.rank), [1, 2]);
    expect(rows.map((row) => row.percent), [75, 25]);
  });

  test('statistic titles name measures, groups, and filters accurately', () {
    const specimens = StatisticRequest(
      projectUuid: 'project-a',
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.species,
    );
    const parts = StatisticRequest(
      projectUuid: 'project-a',
      measure: StatisticMeasure.partQuantity,
      group: StatisticGroup.partType,
    );

    expect(
      specimens.title(siteLabel: 'Site Alpha'),
      'Specimens by species at Site Alpha',
    );
    expect(
      parts.title(speciesLabel: 'Myotis lucifugus'),
      'Part quantity by part type for Myotis lucifugus',
    );
  });
}

Future<void> _seedStatistics(Database db) async {
  await db.batch((batch) {
    batch.insertAll(db.project, const [
      ProjectCompanion(
        uuid: Value('project-a'),
        name: Value('Project A'),
        startDate: Value('2026-01-10'),
        endDate: Value('2026-01-12'),
      ),
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
  await db.batch((batch) {
    batch.insertAll(db.coordinate, [
      CoordinateCompanion(
        elevationInMeter: const Value(120.5),
        siteID: Value(site),
      ),
      CoordinateCompanion(
        elevationInMeter: const Value(350.25),
        siteID: Value(site),
      ),
      CoordinateCompanion(siteID: Value(site)),
    ]);
  });
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
        captureDate: const Value('2026-01-10'),
      ),
      SpecimenCompanion(
        uuid: const Value('a-2'),
        projectUuid: const Value('project-a'),
        speciesID: Value(myotis),
        collEventID: Value(event),
        captureDate: const Value(' 2026-01-10 '),
      ),
      SpecimenCompanion(
        uuid: const Value('a-3'),
        projectUuid: const Value('project-a'),
        speciesID: Value(eptesicus),
        collEventID: Value(event),
        captureDate: const Value('2026-01-11'),
      ),
      const SpecimenCompanion(
        uuid: Value('a-unknown'),
        projectUuid: Value('project-a'),
      ),
      SpecimenCompanion(
        uuid: const Value('b-1'),
        projectUuid: const Value('project-b'),
        speciesID: Value(myotis),
        captureDate: const Value('2026-02-01'),
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
