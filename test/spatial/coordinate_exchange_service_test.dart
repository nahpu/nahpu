import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/record_exchange/coordinate_exchange_service.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/src/rust/api/gis.dart' as rust_gis;

void main() {
  test('coordinate QR payload round-trips every persisted field', () {
    const coordinate = CoordinateData(
      id: 8,
      nameId: 'Camp A',
      decimalLatitude: 12.3,
      decimalLongitude: -45.6,
      elevationInMeter: 78,
      datum: 'WGS84',
      uncertaintyInMeters: 4,
      gpsUnit: 'GPS 1',
      notes: 'ridge',
      siteID: 9,
    );

    final decoded = CoordinateExchangeService.decodeQr(
      CoordinateExchangeService.encodeQr(coordinate),
    );

    expect(decoded.toJson(), coordinate.toJson());
  });

  test('coordinate QR rejects unsupported payload versions', () {
    expect(
      () => CoordinateExchangeService.decodeQr(
        '{"nahpu_coordinate":2,"data":{}}',
      ),
      throwsFormatException,
    );
  });

  test('coordinate export filename is sanitized with an id fallback', () {
    expect(
      CoordinateExchangeService.defaultFileName(
        const CoordinateData(id: 4, nameId: '  Camp / Ridge.geojson  '),
      ),
      'camp-ridge',
    );
    expect(
      CoordinateExchangeService.defaultFileName(
        const CoordinateData(id: 17, nameId: '***'),
      ),
      'coordinate-17',
    );
    expect(
      CoordinateExchangeService.defaultCoordinatesFileName(),
      'coordinates',
    );
  });

  test('coordinate file imports use the configured default datum', () {
    final companions = CoordinateExchangeService.companionsForSite(
      const [
        rust_gis.CoordinateTransferRecord(
          nameId: 'Imported coordinate',
          decimalLatitude: 12.3,
          decimalLongitude: 45.6,
        ),
      ],
      9,
      defaultDatum: 'NAD83',
    );

    expect(companions.single.datum, const Value('NAD83'));
  });

  test('project coordinate query excludes other projects', () async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final siteA = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
    final siteB = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-b')));
    await database
        .into(database.coordinate)
        .insert(
          CoordinateCompanion(nameId: const Value('A'), siteID: Value(siteA)),
        );
    await database
        .into(database.coordinate)
        .insert(
          CoordinateCompanion(nameId: const Value('B'), siteID: Value(siteB)),
        );

    final coordinates = await CoordinateQuery(
      database,
    ).getCoordinatesByProject('project-a');

    expect(coordinates.map((coordinate) => coordinate.nameId), ['A']);
  });
}
