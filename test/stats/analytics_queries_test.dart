import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/analytics_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/services/types/export.dart';

const _totalLength = AnalyticsVariable.column(MeasurementColumn.totalLength);
const _tailLength = AnalyticsVariable.column(MeasurementColumn.tailLength);
const _weight = AnalyticsVariable.column(MeasurementColumn.weight);
const _standardLength = AnalyticsVariable.column(
  MeasurementColumn.standardLength,
);

void main() {
  late Database db;
  late AnalyticsQuery query;

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    query = AnalyticsQuery(db);
    await _seed(db);
  });

  tearDown(() => db.close());

  PcaRequest mammals({
    String? projectUuid = 'project-a',
    List<AnalyticsVariable> variables = const [
      _totalLength,
      _tailLength,
      _weight,
    ],
    Set<int> siteIds = const {},
    Set<int> speciesIds = const {},
  }) => PcaRequest(
    projectUuid: projectUuid,
    taxonGroup: SpecimenRecordType.mammals,
    variables: variables,
    siteIds: siteIds,
    speciesIds: speciesIds,
  );

  test('records are limited to the project and its taxon group', () async {
    final project = await query.fetchRecords(mammals());
    final everything = await query.fetchRecords(mammals(projectUuid: null));

    expect(project.map((record) => record.specimenUuid), [
      'mammal-1',
      'mammal-2',
      'mammal-3',
    ]);
    expect(everything.map((record) => record.specimenUuid), [
      'mammal-1',
      'mammal-2',
      'mammal-3',
      'mammal-b',
    ]);
    expect(everything.last.project, 'Project B');
  });

  test('records carry their measurements and grouping labels', () async {
    final records = await query.fetchRecords(mammals());
    final first = records.first;

    expect(first.values, [200, 90, 120]);
    expect(first.species, 'Rattus rattus');
    expect(first.genus, 'Rattus');
    expect(first.family, 'Muridae');
    expect(first.sex, 'Male');
    expect(first.lifeStage, 'Adult');
    expect(first.site, 'Camp 1');
    expect(first.project, 'Project A');
    expect(first.fieldNumber, 11);
    // No taxon, sex, life stage, or site recorded.
    expect(records[2].species, 'Unidentified species');
    expect(records[2].genus, 'No genus');
    expect(records[2].sex, 'Not recorded');
    expect(records[2].lifeStage, 'Not recorded');
    expect(records[2].site, 'No site');
  });

  test(
    'weights are converted to grams and unknown units are missing',
    () async {
      final records = await query.fetchRecords(mammals(variables: [_weight]));

      expect(records.map((record) => record.values.single), [120, 1500, null]);
    },
  );

  test('only the first attribute row of a specimen is read', () async {
    await db
        .into(db.mammalAttribute)
        .insert(
          const MammalAttributeCompanion(
            specimenUuid: Value('mammal-1'),
            totalLength: Value(999),
          ),
        );

    final records = await query.fetchRecords(mammals());

    expect(records, hasLength(3));
    expect(records.first.values.first, 200);
  });

  test('site and species filters narrow the records', () async {
    final site = await db.select(db.site).getSingle();
    final rattus = await (db.select(
      db.taxonomy,
    )..where((taxon) => taxon.genus.equals('Rattus'))).getSingle();

    final bySite = await query.fetchRecords(mammals(siteIds: {site.id}));
    final bySpecies = await query.fetchRecords(
      mammals(speciesIds: {rattus.id}),
    );

    expect(bySite.map((record) => record.specimenUuid), ['mammal-1']);
    expect(bySpecies.map((record) => record.specimenUuid), [
      'mammal-1',
      'mammal-2',
    ]);
    // Several IDs match any of them; an unknown ID adds nothing.
    final bySites = await query.fetchRecords(
      mammals(siteIds: {site.id, site.id + 100}),
    );
    final bySpeciesSet = await query.fetchRecords(
      mammals(speciesIds: {rattus.id, rattus.id + 100}),
    );
    expect(bySites.map((record) => record.specimenUuid), ['mammal-1']);
    expect(bySpeciesSet.map((record) => record.specimenUuid), [
      'mammal-1',
      'mammal-2',
    ]);
  });

  test('a fish lot contributes its individuals, not its ranges', () async {
    final records = await query.fetchRecords(
      const PcaRequest(
        projectUuid: 'project-a',
        taxonGroup: SpecimenRecordType.fishes,
        variables: [_standardLength, _weight],
      ),
    );

    expect(records.map((record) => record.specimenUuid), [
      'fish-lot',
      'fish-lot',
      'fish-single',
    ]);
    expect(records.map((record) => record.values), [
      [41, 2],
      [43, 3],
      [80, 10],
    ]);
    expect(records.first.sex, 'Female');
    expect(records.last.sex, 'Male');
  });

  test('numeric custom fields are offered and read as numbers', () async {
    final options = await query
        .watchVariableOptions('project-a', SpecimenRecordType.mammals)
        .first;
    final custom = options.where((option) => option.variable.column == null);

    expect(custom.map((option) => option.variable.customFieldName), [
      'Skull length',
    ]);
    expect(custom.single.count, 2);

    final records = await query.fetchRecords(
      mammals(variables: [_totalLength, custom.single.variable]),
    );

    expect(records.map((record) => record.values.last), [31.5, 29, null]);
  });

  test('variable options count the usable values in scope', () async {
    Future<Map<String, int>> counts(String? projectUuid) async {
      final options = await query
          .watchVariableOptions(projectUuid, SpecimenRecordType.mammals)
          .first;
      return {for (final option in options) option.variable.id: option.count};
    }

    final project = await counts('project-a');
    final everything = await counts(null);

    expect(project['totalLength'], 3);
    // One tail length is zero, which reads as missing.
    expect(project['tailLength'], 2);
    expect(project['forearm'], 0);
    expect(everything['totalLength'], 4);
  });

  test('taxon groups list those with specimens', () async {
    final project = await query.watchTaxonGroups('project-a').first;
    final other = await query.watchTaxonGroups('project-b').first;
    final empty = await query.watchTaxonGroups('missing').first;

    expect(project, [SpecimenRecordType.mammals, SpecimenRecordType.fishes]);
    expect(other, [SpecimenRecordType.mammals]);
    expect(empty, isEmpty);
  });
}

Future<void> _seed(Database db) async {
  await db.batch((batch) {
    batch.insertAll(db.project, const [
      ProjectCompanion(uuid: Value('project-a'), name: Value('Project A')),
      ProjectCompanion(uuid: Value('project-b'), name: Value('Project B')),
    ]);
  });
  final rattus = await db
      .into(db.taxonomy)
      .insert(
        const TaxonomyCompanion(
          taxonFamily: Value('Muridae'),
          genus: Value('Rattus'),
          specificEpithet: Value('rattus'),
        ),
      );
  final site = await db
      .into(db.site)
      .insert(
        const SiteCompanion(
          projectUuid: Value('project-a'),
          siteID: Value('Camp 1'),
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
    batch.insertAll(db.specimen, [
      SpecimenCompanion(
        uuid: const Value('mammal-1'),
        projectUuid: const Value('project-a'),
        taxonGroup: const Value('Mammals'),
        speciesID: Value(rattus),
        collEventID: Value(event),
        fieldNumber: const Value(11),
      ),
      // A legacy mammal label.
      SpecimenCompanion(
        uuid: const Value('mammal-2'),
        projectUuid: const Value('project-a'),
        taxonGroup: const Value('Bats'),
        speciesID: Value(rattus),
      ),
      // No taxon group reads as a mammal.
      const SpecimenCompanion(
        uuid: Value('mammal-3'),
        projectUuid: Value('project-a'),
      ),
      const SpecimenCompanion(
        uuid: Value('mammal-b'),
        projectUuid: Value('project-b'),
        taxonGroup: Value('Mammals'),
      ),
      const SpecimenCompanion(
        uuid: Value('fish-single'),
        projectUuid: Value('project-a'),
        taxonGroup: Value('Fishes'),
      ),
      const SpecimenCompanion(
        uuid: Value('fish-lot'),
        projectUuid: Value('project-a'),
        taxonGroup: Value('Fishes'),
      ),
    ]);
    batch.insertAll(db.mammalAttribute, const [
      MammalAttributeCompanion(
        specimenUuid: Value('mammal-1'),
        totalLength: Value(200),
        tailLength: Value(90),
        weight: Value(120),
        weightUnit: Value('g'),
        sex: Value(0),
        lifeStage: Value('Adult'),
      ),
      MammalAttributeCompanion(
        specimenUuid: Value('mammal-2'),
        totalLength: Value(210),
        tailLength: Value(95),
        weight: Value(1.5),
        weightUnit: Value('kg'),
        sex: Value(1),
      ),
      MammalAttributeCompanion(
        specimenUuid: Value('mammal-3'),
        totalLength: Value(190),
        tailLength: Value(0),
        weight: Value(3),
        weightUnit: Value('stone'),
      ),
      MammalAttributeCompanion(
        specimenUuid: Value('mammal-b'),
        totalLength: Value(150),
        tailLength: Value(70),
        weight: Value(40),
      ),
    ]);
    batch.insertAll(db.fishAttribute, const [
      FishAttributeCompanion(
        specimenUuid: Value('fish-single'),
        specimenType: Value(0),
        standardLength: Value(80),
        weight: Value(10),
        weightUnit: Value('g'),
        sex: Value(0),
      ),
      FishAttributeCompanion(
        specimenUuid: Value('fish-lot'),
        specimenType: Value(1),
        minStandardLength: Value(41),
        maxStandardLength: Value(43),
        // A stale single-fish value the lot must not report.
        standardLength: Value(500),
      ),
    ]);
    batch.insertAll(db.specimenIndividual, const [
      SpecimenIndividualCompanion(
        specimenUuid: Value('fish-lot'),
        standardLength: Value(41),
        weight: Value(2),
        weightUnit: Value('g'),
        sex: Value(1),
      ),
      SpecimenIndividualCompanion(
        specimenUuid: Value('fish-lot'),
        standardLength: Value(43),
        weight: Value(0.003),
        weightUnit: Value('kg'),
        sex: Value(1),
      ),
    ]);
  });
  final skull = await db
      .into(db.customFieldDefinition)
      .insert(
        const CustomFieldDefinitionCompanion(
          uuid: Value('field-skull'),
          name: Value('Skull length'),
          type: Value('number'),
          uiSection: Value('specimenAttribute'),
          scope: Value('global'),
        ),
      );
  final note = await db
      .into(db.customFieldDefinition)
      .insert(
        const CustomFieldDefinitionCompanion(
          uuid: Value('field-note'),
          name: Value('Collector note'),
          type: Value('text'),
          uiSection: Value('specimenAttribute'),
          scope: Value('global'),
        ),
      );
  await db.batch((batch) {
    batch.insertAll(db.customFieldValue, [
      CustomFieldValueCompanion(
        fieldDefinitionId: Value(skull),
        projectUuid: const Value('project-a'),
        specimenUuid: const Value('mammal-1'),
        value: const Value('31.5'),
      ),
      CustomFieldValueCompanion(
        fieldDefinitionId: Value(skull),
        projectUuid: const Value('project-a'),
        specimenUuid: const Value('mammal-2'),
        value: const Value('29'),
      ),
      CustomFieldValueCompanion(
        fieldDefinitionId: Value(note),
        projectUuid: const Value('project-a'),
        specimenUuid: const Value('mammal-1'),
        value: const Value('7 traps'),
      ),
    ]);
  });
}
