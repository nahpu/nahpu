import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/sites/coordinate_format.dart';

void main() {
  late Database db;
  late CoordinateQuery query;

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    query = CoordinateQuery(db);
    await db
        .into(db.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
  });

  tearDown(() => db.close());

  group('resolveSpecimenCoordinate', () {
    test('prefers the stored coordinate', () async {
      final single = await _insertSite(db, coordinateCount: 1);
      final pair = await _insertSite(db, coordinateCount: 2);

      final resolved = await query.resolveSpecimenCoordinate(
        pair.coordinateIds.last,
        single.eventId,
      );

      expect(resolved?.id, pair.coordinateIds.last);
    });

    test('falls back to the only coordinate of the event site', () async {
      final single = await _insertSite(db, coordinateCount: 1);

      final resolved = await query.resolveSpecimenCoordinate(
        null,
        single.eventId,
      );

      expect(resolved?.id, single.coordinateIds.single);
    });

    test('stays unresolved when the choice is ambiguous or missing', () async {
      final pair = await _insertSite(db, coordinateCount: 2);
      final empty = await _insertSite(db, coordinateCount: 0);

      expect(await query.resolveSpecimenCoordinate(null, pair.eventId), isNull);
      expect(
        await query.resolveSpecimenCoordinate(null, empty.eventId),
        isNull,
      );
      expect(await query.resolveSpecimenCoordinate(null, null), isNull);
      expect(await query.resolveSpecimenCoordinate(999, null), isNull);
    });
  });

  group('coordinateIdForEvent', () {
    test('keeps a coordinate from the same site', () async {
      final pair = await _insertSite(db, coordinateCount: 2);

      final coordinateId = await query.coordinateIdForEvent(
        pair.eventId,
        currentCoordinateId: pair.coordinateIds.last,
      );

      expect(coordinateId, pair.coordinateIds.last);
    });

    test('selects the only coordinate of a different site', () async {
      final pair = await _insertSite(db, coordinateCount: 2);
      final single = await _insertSite(db, coordinateCount: 1);

      final coordinateId = await query.coordinateIdForEvent(
        single.eventId,
        currentCoordinateId: pair.coordinateIds.first,
      );

      expect(coordinateId, single.coordinateIds.single);
    });

    test('clears the coordinate when the new site is ambiguous', () async {
      final single = await _insertSite(db, coordinateCount: 1);
      final pair = await _insertSite(db, coordinateCount: 2);

      expect(
        await query.coordinateIdForEvent(
          pair.eventId,
          currentCoordinateId: single.coordinateIds.single,
        ),
        isNull,
      );
      expect(await query.coordinateIdForEvent(null), isNull);
    });
  });

  group('coordinateLabel', () {
    test('uses the coordinate name when present', () {
      expect(coordinateLabel(_coordinate(nameId: ' PF 1 ')), 'PF 1');
    });

    test('describes unnamed coordinates by position and elevation', () {
      expect(
        coordinateLabel(
          _coordinate(
            nameId: ' ',
            latitude: 7.92282,
            longitude: 124.84347,
            elevation: 1869,
          ),
        ),
        '7.92282, 124.84347 · 1869 m',
      );
      expect(
        coordinateLabel(_coordinate(latitude: 7.5, longitude: 124)),
        '7.5, 124',
      );
    });

    test('falls back to the coordinate id', () {
      expect(coordinateLabel(_coordinate(latitude: 7.5)), 'Coordinate 3');
    });
  });
}

Future<({int eventId, List<int> coordinateIds})> _insertSite(
  Database db, {
  required int coordinateCount,
}) async {
  final siteId = await db
      .into(db.site)
      .insert(const SiteCompanion(projectUuid: Value('project-a')));
  final coordinateIds = <int>[
    for (var i = 0; i < coordinateCount; i++)
      await db
          .into(db.coordinate)
          .insert(
            CoordinateCompanion(
              decimalLatitude: Value(7.9 + i),
              decimalLongitude: const Value(124.8),
              siteID: Value(siteId),
            ),
          ),
  ];
  final eventId = await db
      .into(db.collEvent)
      .insert(
        CollEventCompanion(
          projectUuid: const Value('project-a'),
          siteID: Value(siteId),
        ),
      );
  return (eventId: eventId, coordinateIds: coordinateIds);
}

CoordinateData _coordinate({
  String? nameId,
  double? latitude,
  double? longitude,
  double? elevation,
}) {
  return CoordinateData(
    id: 3,
    nameId: nameId,
    decimalLatitude: latitude,
    decimalLongitude: longitude,
    elevationInMeter: elevation,
  );
}
