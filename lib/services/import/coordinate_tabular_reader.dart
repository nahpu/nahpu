import 'package:nahpu/services/types/coordinate_import.dart';
import 'package:nahpu/src/rust/api/import.dart';
import 'package:path/path.dart' as path;

const Set<String> coordinateExcelExtensions = {
  '.xlsx',
  '.xls',
  '.xlsm',
  '.xltx',
  '.xltm',
  '.xlsb',
};

class CoordinateTabularData {
  const CoordinateTabularData({
    required this.headers,
    required this.rows,
    required this.rowNumbers,
    required this.inferredMapping,
    this.worksheetName,
  });

  final List<String> headers;
  final List<List<String>> rows;
  final List<int> rowNumbers;
  final Map<CoordinateImportField, int?> inferredMapping;
  final String? worksheetName;
}

class CoordinateTabularParseResult {
  const CoordinateTabularParseResult({
    required this.coordinates,
    required this.skippedCount,
    required this.warnings,
  });

  final List<CoordinateImportRecord> coordinates;
  final int skippedCount;
  final List<String> warnings;
}

class CoordinateTabularReader {
  const CoordinateTabularReader();

  static bool supportsPath(String inputPath) {
    final extension = path.extension(inputPath).toLowerCase();
    return extension == '.csv' ||
        extension == '.tsv' ||
        coordinateExcelExtensions.contains(extension);
  }

  Future<CoordinateTabularData> readFile(String inputPath) async {
    final extension = path.extension(inputPath).toLowerCase();
    final reader = RecordReader(filePath: inputPath);
    if (extension == '.csv' || extension == '.tsv') {
      final rows = await reader.importDelimitedRaw(
        delimiter: extension == '.csv' ? ',' : '\t',
      );
      return fromRows(rows);
    }
    if (coordinateExcelExtensions.contains(extension)) {
      return _readExcel(reader);
    }
    throw const FormatException(
      'Choose a CSV, TSV, or supported Excel coordinate file.',
    );
  }

  CoordinateTabularData fromRows(
    List<List<String>> inputRows, {
    String? worksheetName,
  }) {
    final populatedRows = <List<String>>[];
    final populatedRowNumbers = <int>[];
    for (var index = 0; index < inputRows.length; index++) {
      final row = inputRows[index];
      if (!row.any((value) => value.trim().isNotEmpty)) continue;
      populatedRows.add(
        row.map((value) => value.trim()).toList(growable: false),
      );
      populatedRowNumbers.add(index + 1);
    }
    if (populatedRows.length < 2) {
      throw const FormatException(
        'The selected table must contain a header and at least one data row.',
      );
    }
    final headers = List<String>.from(populatedRows.first, growable: false);
    if (headers.isNotEmpty) {
      headers[0] = headers[0].replaceFirst('\uFEFF', '');
    }
    if (headers.length < 2) {
      throw const FormatException(
        'The selected table must contain at least two columns.',
      );
    }
    return CoordinateTabularData(
      headers: headers,
      rows: populatedRows.sublist(1),
      rowNumbers: populatedRowNumbers.sublist(1),
      inferredMapping: inferMapping(headers),
      worksheetName: worksheetName,
    );
  }

  Map<CoordinateImportField, int?> inferMapping(List<String> headers) {
    final normalizedHeaders = headers.map(_normalizeHeader).toList();
    return {
      for (final field in CoordinateImportField.values)
        field: _uniqueAliasMatch(normalizedHeaders, _aliases[field]!),
    };
  }

  List<String> validateMapping(Map<CoordinateImportField, int?> mapping) {
    final problems = <String>[];
    for (final field in CoordinateImportField.values.where(
      (field) => field.isRequired,
    )) {
      if (mapping[field] == null) {
        problems.add('Select a source column for ${field.label}.');
      }
    }

    final selections = <int, List<CoordinateImportField>>{};
    for (final entry in mapping.entries) {
      final column = entry.value;
      if (column != null) {
        selections.putIfAbsent(column, () => []).add(entry.key);
      }
    }
    for (final fields in selections.values.where(
      (fields) => fields.length > 1,
    )) {
      problems.add(
        '${fields.map((field) => field.label).join(' and ')} cannot use the same source column.',
      );
    }
    return problems;
  }

  CoordinateTabularParseResult parse(
    CoordinateTabularData data,
    Map<CoordinateImportField, int?> mapping,
  ) {
    final mappingProblems = validateMapping(mapping);
    if (mappingProblems.isNotEmpty) {
      throw FormatException(mappingProblems.join(' '));
    }

    final coordinates = <CoordinateImportRecord>[];
    final warnings = <String>[];
    for (var index = 0; index < data.rows.length; index++) {
      final row = data.rows[index];
      final sourceRow = data.rowNumbers[index];
      final latitudeText = _value(
        row,
        mapping[CoordinateImportField.decimalLatitude],
      );
      final longitudeText = _value(
        row,
        mapping[CoordinateImportField.decimalLongitude],
      );
      final latitude = double.tryParse(latitudeText ?? '');
      final longitude = double.tryParse(longitudeText ?? '');
      final coordinateProblem = _coordinateProblem(
        latitudeText: latitudeText,
        longitudeText: longitudeText,
        latitude: latitude,
        longitude: longitude,
      );
      if (coordinateProblem != null) {
        warnings.add('Row $sourceRow skipped: $coordinateProblem');
        continue;
      }

      final elevationText = _value(
        row,
        mapping[CoordinateImportField.elevationInMeter],
      );
      final elevation = elevationText == null
          ? null
          : double.tryParse(elevationText);
      if (elevationText != null && elevation == null) {
        warnings.add(
          'Row $sourceRow skipped: elevation "$elevationText" is not a number.',
        );
        continue;
      }

      final importedName = _value(row, mapping[CoordinateImportField.nameId]);
      coordinates.add(
        CoordinateImportRecord(
          nameId: importedName ?? 'Coordinate $sourceRow',
          decimalLatitude: latitude!,
          decimalLongitude: longitude!,
          elevationInMeter: elevation,
          gpsUnit: _value(row, mapping[CoordinateImportField.gpsUnit]),
          notes: _value(row, mapping[CoordinateImportField.notes]),
        ),
      );
    }

    if (coordinates.isEmpty) {
      throw FormatException(
        warnings.isEmpty
            ? 'No valid coordinate rows were found in the selected table.'
            : 'No valid coordinate rows were found. ${warnings.join(' ')}',
      );
    }
    return CoordinateTabularParseResult(
      coordinates: coordinates,
      skippedCount: data.rows.length - coordinates.length,
      warnings: warnings,
    );
  }

  Future<CoordinateTabularData> _readExcel(RecordReader reader) async {
    final sheetNames = await reader.getExcelSheetNames();
    for (final sheetName in sheetNames) {
      try {
        final rows = await reader.importExcelRaw(sheetName: sheetName);
        if (rows
                .where((row) => row.any((value) => value.trim().isNotEmpty))
                .length >=
            2) {
          return fromRows(rows, worksheetName: sheetName);
        }
      } catch (_) {
        continue;
      }
    }
    throw const FormatException(
      'No Excel worksheet with a header and coordinate rows was found.',
    );
  }

  int? _uniqueAliasMatch(List<String> headers, Set<String> aliases) {
    final matches = <int>[];
    for (var index = 0; index < headers.length; index++) {
      if (aliases.contains(headers[index])) matches.add(index);
    }
    return matches.length == 1 ? matches.single : null;
  }

  String _normalizeHeader(String value) => value
      .replaceFirst('\uFEFF', '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]'), '');

  String? _value(List<String> row, int? column) {
    if (column == null || column < 0 || column >= row.length) return null;
    final value = row[column].trim();
    return value.isEmpty ? null : value;
  }

  String? _coordinateProblem({
    required String? latitudeText,
    required String? longitudeText,
    required double? latitude,
    required double? longitude,
  }) {
    if (latitude == null || !latitude.isFinite) {
      return 'latitude "${latitudeText ?? ''}" is not a number.';
    }
    if (latitude < -90 || latitude > 90) {
      return 'latitude "$latitudeText" must be between -90 and 90.';
    }
    if (longitude == null || !longitude.isFinite) {
      return 'longitude "${longitudeText ?? ''}" is not a number.';
    }
    if (longitude < -180 || longitude > 180) {
      return 'longitude "$longitudeText" must be between -180 and 180.';
    }
    return null;
  }
}

const Map<CoordinateImportField, Set<String>> _aliases = {
  CoordinateImportField.nameId: {
    'name',
    'id',
    'nameid',
    'coordinateid',
    'coordinate',
    'label',
    'waypoint',
    'waypointname',
    'siteid',
  },
  CoordinateImportField.decimalLatitude: {
    'latitude',
    'lat',
    'decimallatitude',
    'latitudedecimaldegrees',
    'latitudeunitsdecimaldegrees',
    'y',
  },
  CoordinateImportField.decimalLongitude: {
    'longitude',
    'lon',
    'long',
    'lng',
    'decimallongitude',
    'longitudedecimaldegrees',
    'longitudeunitsdecimaldegrees',
    'x',
  },
  CoordinateImportField.elevationInMeter: {
    'elevation',
    'elevationm',
    'elevationmeter',
    'elevationmeters',
    'elevationinmeter',
    'elevationinmeters',
    'altitude',
    'altitudem',
    'alt',
  },
  CoordinateImportField.gpsUnit: {
    'gps',
    'gpsunit',
    'gpsdevice',
    'gpsreceiver',
    'receiver',
    'device',
  },
  CoordinateImportField.notes: {
    'note',
    'notes',
    'remark',
    'remarks',
    'comment',
    'comments',
    'description',
  },
};
