import 'dart:convert';
import 'dart:io';

import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/src/rust/api/import.dart';
import 'package:path/path.dart' as p;

const batchExcelExtensions = {
  '.xlsx',
  '.xls',
  '.xlsm',
  '.xltx',
  '.xltm',
  '.xlsb',
};

const batchDelimitedExtensions = {'.csv', '.tsv', '.txt'};

/// Reads a CSV, TSV, or Excel file into a [BatchImportTable].
class BatchImportReader {
  const BatchImportReader();

  static bool supportsPath(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    return batchDelimitedExtensions.contains(extension) ||
        batchExcelExtensions.contains(extension);
  }

  /// Reads [filePath]. For Excel files, reads [sheetName], or else the
  /// first sheet with a header and a data row.
  Future<BatchImportTable> readFile(
    String filePath, {
    String? sheetName,
  }) async {
    final extension = p.extension(filePath).toLowerCase();
    final fileName = p.basename(filePath);
    final reader = RecordReader(filePath: filePath);
    if (batchExcelExtensions.contains(extension)) {
      final sheets = await reader.getExcelSheetNames();
      if (sheets.isEmpty) {
        throw const FormatException('The workbook has no sheets.');
      }
      final ordered = [
        if (sheetName != null && sheets.contains(sheetName)) sheetName,
        for (final sheet in sheets)
          if (sheet != sheetName) sheet,
      ];
      for (final sheet in ordered) {
        final rows = await reader.importExcelRaw(sheetName: sheet);
        if (_populated(rows).length >= 2 || sheet == sheetName) {
          return fromRows(
            rows,
            fileName: fileName,
            sheetName: sheet,
            sheetNames: sheets,
          );
        }
      }
      throw const FormatException(
        'No sheet has a header row and at least one data row.',
      );
    }
    if (!batchDelimitedExtensions.contains(extension)) {
      throw const FormatException('Choose a CSV, TSV, or Excel file.');
    }
    final text = await _readText(File(filePath));
    final delimiter = extension == '.tsv'
        ? '\t'
        : guessBatchDelimiter(text) ?? (extension == '.csv' ? ',' : '\t');
    final rows = await reader.importDelimitedRaw(delimiter: delimiter);
    return fromRows(rows, fileName: fileName);
  }

  /// Builds a table from raw rows: drops blank rows, trims cells, names
  /// blank or repeated headers, and pads short rows.
  BatchImportTable fromRows(
    List<List<String>> rows, {
    required String fileName,
    String? sheetName,
    List<String> sheetNames = const [],
  }) {
    final populated = _populated(rows);
    if (populated.length < 2) {
      throw const FormatException(
        'The file needs a header row and at least one data row.',
      );
    }
    final (_, headerRow) = populated.first;
    final headers = _headers(headerRow);
    return BatchImportTable(
      fileName: fileName,
      sheetName: sheetName,
      sheetNames: sheetNames,
      headers: headers,
      rows: [
        for (final (_, row) in populated.skip(1))
          [
            for (var i = 0; i < headers.length; i++)
              i < row.length ? row[i].trim() : '',
          ],
      ],
      rowNumbers: [for (final (number, _) in populated.skip(1)) number],
    );
  }

  List<(int, List<String>)> _populated(List<List<String>> rows) => [
    for (final (index, row) in rows.indexed)
      if (row.any((cell) => cell.trim().isNotEmpty)) (index + 1, row),
  ];

  List<String> _headers(List<String> row) {
    final seen = <String, int>{};
    return [
      for (final (index, cell) in row.indexed)
        () {
          var header = cell.replaceFirst('﻿', '').trim();
          if (header.isEmpty) header = 'Column ${index + 1}';
          final count = seen.update(header, (n) => n + 1, ifAbsent: () => 1);
          return count == 1 ? header : '$header ($count)';
        }(),
    ];
  }

  Future<String> _readText(File file) async {
    try {
      return await file.readAsString();
    } on FormatException {
      return file.readAsString(encoding: latin1);
    }
  }
}

/// The delimiter that splits the first lines of [text] into the same
/// number of fields, ignoring quoted text. Null when none does.
String? guessBatchDelimiter(String text) {
  final lines = const LineSplitter()
      .convert(text)
      .where((line) => line.trim().isNotEmpty)
      .take(50)
      .toList();
  if (lines.isEmpty) return null;
  String? best;
  var bestScore = 0.0;
  for (final delimiter in const [',', '\t', ';', '|']) {
    final counts = [
      for (final line in lines) _countOutsideQuotes(line, delimiter),
    ];
    if (counts.first == 0) continue;
    final consistent = counts.where((c) => c == counts.first).length;
    final score = consistent / counts.length + counts.first / 1000;
    if (score > bestScore) {
      best = delimiter;
      bestScore = score;
    }
  }
  return best;
}

int _countOutsideQuotes(String line, String delimiter) {
  var count = 0;
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      quoted = !quoted;
    } else if (!quoted && char == delimiter) {
      count++;
    }
  }
  return count;
}
