import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/statistics_queries.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

void main() {
  late Database db;
  late StatisticsQuery query;

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    query = StatisticsQuery(db);
    await _seedSpatialStatistics(db);
  });

  tearDown(() => db.close());

  test('coordinates are project scoped and preserve coordinate form fields',
      () async {
    final rows = await query
        .watchSpatialStatistics(
          const SpatialStatisticRequest(
            projectUuid: 'project-a',
            kind: SpatialStatisticKind.coordinate,
          ),
        )
        .first;

    expect(rows, hasLength(2));
    expect(rows.first.displayName, 'Alpha coordinate');
    expect(rows.first.decimalLatitude, 45.123456);
    expect(rows.first.decimalLongitude, -93.123456);
    expect(rows.first.elevationInMeter, 320);
    expect(rows.first.datum, 'WGS84');
    expect(rows.first.uncertaintyInMeters, 8);
    expect(rows.first.gpsUnit, 'GPS A');
    expect(rows.first.notes, 'Forest edge');
    expect(rows.last.displayName,
        'Unnamed coordinate (${rows.last.coordinateId})');
  });

  test('spatial counts use only the specimen coordinate assignment', () async {
    final rows = await query
        .watchSpatialStatistics(
          const SpatialStatisticRequest(
            projectUuid: 'project-a',
            kind: SpatialStatisticKind.specimens,
          ),
        )
        .first;

    expect(rows, hasLength(2));
    expect(rows.first.displayName, 'Alpha coordinate');
    expect(rows.first.count, 3);
    expect(rows.last.displayName, startsWith('Unnamed coordinate'));
    expect(rows.last.count, 1);
  });

  test('species and family counts are distinct at each coordinate', () async {
    final species = await query
        .watchSpatialStatistics(
          const SpatialStatisticRequest(
            projectUuid: 'project-a',
            kind: SpatialStatisticKind.species,
          ),
        )
        .first;
    final families = await query
        .watchSpatialStatistics(
          const SpatialStatisticRequest(
            projectUuid: 'project-a',
            kind: SpatialStatisticKind.family,
          ),
        )
        .first;

    expect(species.map((row) => row.count), [2, 1]);
    expect(families.map((row) => row.count), [1, 1]);
  });

  test('spatial helper functions keep invalid positions out of maps', () {
    const valid = SpatialStatisticDatum(
      coordinateId: 1,
      name: 'Valid',
      decimalLatitude: 45,
      decimalLongitude: -93,
      elevationInMeter: null,
      datum: null,
      uncertaintyInMeters: null,
      gpsUnit: null,
      notes: null,
      count: 4,
    );
    const invalid = SpatialStatisticDatum(
      coordinateId: 2,
      name: null,
      decimalLatitude: 100,
      decimalLongitude: -93,
      elevationInMeter: null,
      datum: null,
      uncertaintyInMeters: null,
      gpsUnit: null,
      notes: null,
      count: 1,
    );

    expect(mappableSpatialStatistics([valid, invalid]), [valid]);
    expect(spatialStatisticTotal([valid, invalid]), 5);
    expect(spatialStatisticPercent(valid, 5), 80);
    expect(
      spatialMarkerRadius(
        kind: SpatialStatisticKind.specimens,
        count: 4,
        maximumCount: 4,
      ),
      32,
    );
    expect(
      spatialMarkerRadius(
        kind: SpatialStatisticKind.coordinate,
        count: 0,
        maximumCount: 0,
      ),
      9,
    );
  });
}

Future<void> _seedSpatialStatistics(Database db) async {
  await db.batch((batch) {
    batch.insertAll(db.project, const [
      ProjectCompanion(uuid: Value('project-a'), name: Value('Project A')),
      ProjectCompanion(uuid: Value('project-b'), name: Value('Project B')),
    ]);
  });
  final myotis = await db.into(db.taxonomy).insert(
        const TaxonomyCompanion(
          taxonFamily: Value('Vespertilionidae'),
          genus: Value('Myotis'),
          specificEpithet: Value('lucifugus'),
        ),
      );
  final eptesicus = await db.into(db.taxonomy).insert(
        const TaxonomyCompanion(
          taxonFamily: Value('Vespertilionidae'),
          genus: Value('Eptesicus'),
          specificEpithet: Value('fuscus'),
        ),
      );
  final siteA = await db.into(db.site).insert(
        const SiteCompanion(projectUuid: Value('project-a')),
      );
  final siteB = await db.into(db.site).insert(
        const SiteCompanion(projectUuid: Value('project-b')),
      );
  final firstCoordinate = await db.into(db.coordinate).insert(
        CoordinateCompanion(
          nameId: const Value('Alpha coordinate'),
          decimalLatitude: const Value(45.123456),
          decimalLongitude: const Value(-93.123456),
          elevationInMeter: const Value(320),
          datum: const Value('WGS84'),
          uncertaintyInMeters: const Value(8),
          gpsUnit: const Value('GPS A'),
          notes: const Value('Forest edge'),
          siteID: Value(siteA),
        ),
      );
  final secondCoordinate = await db.into(db.coordinate).insert(
        CoordinateCompanion(
          decimalLatitude: const Value(46),
          siteID: Value(siteA),
        ),
      );
  await db.into(db.coordinate).insert(
        CoordinateCompanion(
          nameId: const Value('Other project coordinate'),
          decimalLatitude: const Value(10),
          decimalLongitude: const Value(10),
          siteID: Value(siteB),
        ),
      );
  final event = await db.into(db.collEvent).insert(
        CollEventCompanion(
          projectUuid: const Value('project-a'),
          siteID: Value(siteA),
        ),
      );
  await db.batch((batch) {
    batch.insertAll(db.specimen, [
      SpecimenCompanion(
        uuid: const Value('a-1'),
        projectUuid: const Value('project-a'),
        speciesID: Value(myotis),
        coordinateID: Value(firstCoordinate),
      ),
      SpecimenCompanion(
        uuid: const Value('a-2'),
        projectUuid: const Value('project-a'),
        speciesID: Value(myotis),
        coordinateID: Value(firstCoordinate),
      ),
      SpecimenCompanion(
        uuid: const Value('a-3'),
        projectUuid: const Value('project-a'),
        speciesID: Value(eptesicus),
        coordinateID: Value(firstCoordinate),
      ),
      SpecimenCompanion(
        uuid: const Value('a-unknown'),
        projectUuid: const Value('project-a'),
        coordinateID: Value(secondCoordinate),
      ),
      SpecimenCompanion(
        uuid: const Value('a-event-only'),
        projectUuid: const Value('project-a'),
        collEventID: Value(event),
      ),
      SpecimenCompanion(
        uuid: const Value('b-leak'),
        projectUuid: const Value('project-b'),
        coordinateID: Value(firstCoordinate),
      ),
    ]);
  });
}
