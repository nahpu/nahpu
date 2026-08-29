import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/coordinate_import.dart';
import 'package:nahpu/src/rust/api/gis.dart' as rust_gis;

const coordinateFileTypeGroup = XTypeGroup(
  label: 'Coordinates (GIS, CSV, TSV, Excel)',
  extensions: [
    'geojson',
    'json',
    'kml',
    'zip',
    'gpx',
    'csv',
    'tsv',
    'xlsx',
    'xls',
    'xlsm',
    'xltx',
    'xltm',
    'xlsb',
  ],
  mimeTypes: [
    'application/geo+json',
    'application/json',
    'application/vnd.google-earth.kml+xml',
    'application/zip',
    'application/gpx+xml',
    'text/csv',
    'text/tab-separated-values',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ],
);

enum CoordinateFileFormat { geoJson, kml, shapefile }

class CoordinateImportReview {
  const CoordinateImportReview({
    required this.coordinates,
    required this.skippedCount,
    required this.warnings,
  });

  final List<CoordinateImportRecord> coordinates;
  final int skippedCount;
  final List<String> warnings;
}

class CoordinateExchangeService extends AppServices {
  const CoordinateExchangeService({required super.ref});

  Future<File> exportCoordinates(
    Iterable<CoordinateData> coordinates,
    CoordinateFileFormat format, {
    required String fileName,
    Directory? destinationDirectory,
  }) async {
    final entries = coordinates.toList(growable: false);
    if (entries.isEmpty) {
      throw const FormatException('Select at least one coordinate to export.');
    }
    for (final coordinate in entries) {
      _validateExportCoordinate(coordinate);
    }
    final extension = switch (format) {
      CoordinateFileFormat.geoJson => 'geojson',
      CoordinateFileFormat.kml => 'kml',
      CoordinateFileFormat.shapefile => 'zip',
    };
    final rustFormat = switch (format) {
      CoordinateFileFormat.geoJson => rust_gis.CoordinateExportFormat.geoJson,
      CoordinateFileFormat.kml => rust_gis.CoordinateExportFormat.kml,
      CoordinateFileFormat.shapefile =>
        rust_gis.CoordinateExportFormat.shapefile,
    };
    final baseName = _safeFileStem(fileName, null);
    final output = await AppIOServices(
      dir: destinationDirectory,
      fileStem: baseName,
      ext: extension,
    ).getSavePath();
    await rust_gis.exportCoordinates(
      coordinates: entries.map(_toTransferRecord).toList(growable: false),
      format: rustFormat,
      outputPath: output.path,
    );
    return output;
  }

  static String defaultFileName(CoordinateData coordinate) =>
      _safeFileStem(coordinate.nameId ?? '', coordinate.id);

  static String defaultCoordinatesFileName() => 'coordinates';

  Future<CoordinateImportReview> importFile(String inputPath) async {
    final result = await rust_gis.importCoordinates(inputPath: inputPath);
    final coordinates = <CoordinateImportRecord>[];
    var skippedCount = result.skippedCount.toInt();
    final warnings = List<String>.from(result.warnings);
    for (final record in result.coordinates) {
      try {
        _validateCoordinatePair(
          record.decimalLatitude,
          record.decimalLongitude,
        );
        coordinates.add(
          CoordinateImportRecord(
            nameId: record.nameId,
            decimalLatitude: record.decimalLatitude!,
            decimalLongitude: record.decimalLongitude!,
            elevationInMeter: record.elevationInMeter,
            notes: record.notes,
          ),
        );
      } on FormatException {
        skippedCount++;
        warnings.add('${record.nameId} was skipped: invalid coordinates.');
      }
    }
    if (coordinates.isEmpty) {
      throw const FormatException(
        'No valid point coordinates were found in the selected file.',
      );
    }
    return CoordinateImportReview(
      coordinates: coordinates,
      skippedCount: skippedCount,
      warnings: warnings,
    );
  }

  static List<CoordinateCompanion> companionsForSite(
    Iterable<CoordinateImportRecord> records,
    int siteId, {
    required String? defaultDatum,
  }) {
    return records.map((record) {
      _validateCoordinatePair(record.decimalLatitude, record.decimalLongitude);
      return CoordinateCompanion(
        nameId: db.Value(record.nameId),
        decimalLatitude: db.Value(record.decimalLatitude),
        decimalLongitude: db.Value(record.decimalLongitude),
        elevationInMeter: db.Value(record.elevationInMeter),
        datum: db.Value(defaultDatum),
        gpsUnit: db.Value(record.gpsUnit),
        siteID: db.Value(siteId),
        notes: db.Value(record.notes),
      );
    }).toList();
  }

  static String encodeQr(CoordinateData coordinate) {
    return jsonEncode({'nahpu_coordinate': 1, 'data': coordinate.toJson()});
  }

  static CoordinateData decodeQr(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map || decoded['nahpu_coordinate'] != 1) {
      throw const FormatException(
        'Invalid or unsupported NAHPU coordinate QR code.',
      );
    }
    final data = decoded['data'];
    if (data is! Map) {
      throw const FormatException(
        'Coordinate QR code does not contain coordinate data.',
      );
    }
    final coordinate = CoordinateData.fromJson(Map<String, dynamic>.from(data));
    _validateCoordinatePair(
      coordinate.decimalLatitude,
      coordinate.decimalLongitude,
    );
    return coordinate;
  }

  rust_gis.CoordinateTransferRecord _toTransferRecord(
    CoordinateData coordinate,
  ) {
    return rust_gis.CoordinateTransferRecord(
      nameId: coordinate.nameId ?? 'Coordinate',
      notes: coordinate.notes,
      decimalLongitude: coordinate.decimalLongitude,
      decimalLatitude: coordinate.decimalLatitude,
      elevationInMeter: coordinate.elevationInMeter,
    );
  }

  void _validateExportCoordinate(CoordinateData coordinate) {
    _validateCoordinatePair(
      coordinate.decimalLatitude,
      coordinate.decimalLongitude,
    );
  }

  static void _validateCoordinatePair(double? latitude, double? longitude) {
    if (latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException(
        'A valid latitude and longitude are required.',
      );
    }
  }

  static String _safeFileStem(String value, int? id) {
    final withoutExtension = value.trim().replaceFirst(
      RegExp(r'\.(geojson|json|kml|zip)$', caseSensitive: false),
      '',
    );
    final cleaned = withoutExtension
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'coordinate-${id ?? 'export'}' : cleaned;
  }
}
