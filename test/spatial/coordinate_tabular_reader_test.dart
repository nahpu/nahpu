import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/import/coordinate_tabular_reader.dart';
import 'package:nahpu/services/types/coordinate_import.dart';
import 'package:nahpu/src/rust/frb_generated.dart';

void main() {
  const reader = CoordinateTabularReader();
  late Directory tempDirectory;

  setUpAll(() async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final libraryPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust/target/debug/rust_lib_nahpu.dll'
          : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(externalLibrary: ExternalLibrary.open(libraryPath));
    } else {
      await RustLib.init();
    }
  });

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'nahpu-coordinate-import-',
    );
  });

  tearDown(() {
    tempDirectory.deleteSync(recursive: true);
  });

  test('infers coordinate columns and preserves optional values', () {
    final data = reader.fromRows(const [
      [
        'Coordinate ID',
        'decimal latitude',
        'LONGITUDE',
        'GPS Receiver',
        'Remarks',
        'Altitude',
      ],
      ['Camp A', '12.3', '-45.6', 'Garmin 64s', 'Ridge', '78.5'],
      ['', '', '', '', '', ''],
    ]);

    expect(data.inferredMapping[CoordinateImportField.nameId], 0);
    expect(data.inferredMapping[CoordinateImportField.decimalLatitude], 1);
    expect(data.inferredMapping[CoordinateImportField.decimalLongitude], 2);
    expect(data.inferredMapping[CoordinateImportField.gpsUnit], 3);
    expect(data.inferredMapping[CoordinateImportField.notes], 4);
    expect(data.inferredMapping[CoordinateImportField.elevationInMeter], 5);

    final result = reader.parse(data, data.inferredMapping);
    expect(result.coordinates, hasLength(1));
    expect(result.skippedCount, 0);
    expect(result.coordinates.single.nameId, 'Camp A');
    expect(result.coordinates.single.decimalLatitude, 12.3);
    expect(result.coordinates.single.decimalLongitude, -45.6);
    expect(result.coordinates.single.gpsUnit, 'Garmin 64s');
    expect(result.coordinates.single.notes, 'Ridge');
    expect(result.coordinates.single.elevationInMeter, 78.5);
  });

  test('leaves ambiguous aliases unmatched for user override', () {
    final data = reader.fromRows(const [
      ['lat', 'Latitude', 'longitude'],
      ['12.3', '12.4', '45.6'],
    ]);

    expect(data.inferredMapping[CoordinateImportField.decimalLatitude], isNull);
    expect(data.inferredMapping[CoordinateImportField.decimalLongitude], 2);
    expect(
      reader.validateMapping(data.inferredMapping),
      contains('Select a source column for Latitude.'),
    );
  });

  test('manual mappings recover unmatched headers', () {
    final data = reader.fromRows(const [
      ['north coordinate', 'west coordinate'],
      ['12.3', '-45.6'],
    ]);
    final mapping = Map<CoordinateImportField, int?>.of(data.inferredMapping)
      ..[CoordinateImportField.decimalLatitude] = 0
      ..[CoordinateImportField.decimalLongitude] = 1;

    final result = reader.parse(data, mapping);

    expect(result.coordinates.single.nameId, 'Coordinate 2');
    expect(result.coordinates.single.decimalLatitude, 12.3);
    expect(result.coordinates.single.decimalLongitude, -45.6);
  });

  test('optional GPS unit and notes can remain unmapped', () {
    final data = reader.fromRows(const [
      ['latitude', 'longitude'],
      ['12.3', '45.6'],
    ]);

    final result = reader.parse(data, data.inferredMapping);

    expect(result.coordinates.single.gpsUnit, isNull);
    expect(result.coordinates.single.notes, isNull);
  });

  test(
    'invalid coordinate and elevation rows are skipped with row warnings',
    () {
      final data = reader.fromRows(const [
        ['latitude', 'longitude', 'elevation'],
        ['12.3', '45.6', '10'],
        ['', '', ''],
        ['91', '45.6', '10'],
        ['12.3', 'west', '10'],
        ['12.3', '45.6', 'high'],
      ]);

      final result = reader.parse(data, data.inferredMapping);

      expect(result.coordinates, hasLength(1));
      expect(result.skippedCount, 3);
      expect(result.warnings[0], startsWith('Row 4 skipped:'));
      expect(result.warnings[1], startsWith('Row 5 skipped:'));
      expect(result.warnings[2], startsWith('Row 6 skipped:'));
    },
  );

  test('the same source column cannot be mapped twice', () {
    final data = reader.fromRows(const [
      ['latitude', 'longitude'],
      ['12.3', '45.6'],
    ]);
    final mapping = Map<CoordinateImportField, int?>.of(data.inferredMapping)
      ..[CoordinateImportField.notes] = 0;

    expect(
      reader.validateMapping(mapping),
      contains('Latitude and Notes cannot use the same source column.'),
    );
    expect(() => reader.parse(data, mapping), throwsFormatException);
  });

  test('recognizes CSV, TSV, and common Excel extensions', () {
    expect(CoordinateTabularReader.supportsPath('coordinates.csv'), isTrue);
    expect(CoordinateTabularReader.supportsPath('coordinates.tsv'), isTrue);
    expect(CoordinateTabularReader.supportsPath('coordinates.xlsx'), isTrue);
    expect(CoordinateTabularReader.supportsPath('coordinates.xls'), isTrue);
    expect(
      CoordinateTabularReader.supportsPath('coordinates.geojson'),
      isFalse,
    );
  });

  test('reads CSV and TSV files with their extension delimiters', () async {
    final csv = File('${tempDirectory.path}/coordinates.csv');
    final tsv = File('${tempDirectory.path}/coordinates.tsv');
    await csv.writeAsString('latitude,longitude,notes\n12.3,45.6,ridge\n');
    await tsv.writeAsString(
      'latitude\tlongitude\tgps unit\n-12.3\t-45.6\tGarmin\n',
    );

    final csvData = await reader.readFile(csv.path);
    final tsvData = await reader.readFile(tsv.path);
    final csvResult = reader.parse(csvData, csvData.inferredMapping);
    final tsvResult = reader.parse(tsvData, tsvData.inferredMapping);

    expect(csvResult.coordinates.single.notes, 'ridge');
    expect(tsvResult.coordinates.single.gpsUnit, 'Garmin');
  });

  test('reads the first populated Excel worksheet', () async {
    final data = await reader.readFile(
      'test/data/taxon_import/speciesList.xlsx',
    );

    expect(data.worksheetName, isNotEmpty);
    expect(data.headers, isNotEmpty);
    expect(data.rows, hasLength(4));
  });
}
