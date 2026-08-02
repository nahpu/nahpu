import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/src/rust/api/gis.dart' as rust_gis;

const coordinateFileTypeGroup = XTypeGroup(
  label: 'Coordinates (GeoJSON, KML, Shapefile ZIP, GPX)',
  extensions: ['geojson', 'json', 'kml', 'zip', 'gpx'],
  mimeTypes: [
    'application/geo+json',
    'application/json',
    'application/vnd.google-earth.kml+xml',
    'application/zip',
    'application/gpx+xml',
  ],
);

enum CoordinateFileFormat { geoJson, kml, shapefile }

class CoordinateImportReview {
  const CoordinateImportReview({
    required this.coordinates,
    required this.skippedCount,
    required this.warnings,
  });

  final List<rust_gis.CoordinateTransferRecord> coordinates;
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
    return CoordinateImportReview(
      coordinates: result.coordinates,
      skippedCount: result.skippedCount.toInt(),
      warnings: result.warnings,
    );
  }

  static List<CoordinateCompanion> companionsForSite(
    Iterable<rust_gis.CoordinateTransferRecord> records,
    int siteId, {
    required String? defaultDatum,
  }) {
    return records
        .map(
          (record) => CoordinateCompanion(
            nameId: db.Value(record.nameId),
            decimalLatitude: db.Value(record.decimalLatitude),
            decimalLongitude: db.Value(record.decimalLongitude),
            elevationInMeter: db.Value(record.elevationInMeter),
            datum: db.Value(defaultDatum),
            siteID: db.Value(siteId),
            notes: db.Value(record.notes),
          ),
        )
        .toList();
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
    return CoordinateData.fromJson(Map<String, dynamic>.from(data));
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
    final latitude = coordinate.decimalLatitude;
    final longitude = coordinate.decimalLongitude;
    if (latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException(
        'Every exported coordinate needs a valid latitude and longitude.',
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
