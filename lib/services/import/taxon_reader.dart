import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path/path.dart' as p;
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/utility_services.dart';

const Set<String> supportedTaxonExcelExtensions = {
  '.xlsx',
  '.xls',
  '.xlsm',
  '.xltx',
  '.xltm',
  '.xlsb',
};

enum TaxonFileParseMode { auto, delimiter, excel }

enum TaxonResolvedParser { delimited, excel }

enum TaxonParseResolution {
  extensionDefault,
  autoDetectExcel,
  autoDetectKnownDelimiter,
  autoDetectMinedDelimiter,
  manualOverride,
}

class TaxonFileParseOptions {
  const TaxonFileParseOptions.auto()
      : mode = TaxonFileParseMode.auto,
        delimiter = null;

  const TaxonFileParseOptions.delimiter(this.delimiter)
      : mode = TaxonFileParseMode.delimiter;

  const TaxonFileParseOptions.excel()
      : mode = TaxonFileParseMode.excel,
        delimiter = null;

  final TaxonFileParseMode mode;
  final String? delimiter;
}

class TaxonFileParseException implements Exception {
  const TaxonFileParseException(
    this.message, {
    this.code = TaxonFileParseErrorCode.generic,
  });

  final String message;
  final TaxonFileParseErrorCode code;

  @override
  String toString() {
    return message;
  }
}

class TaxonFileParseDetails {
  const TaxonFileParseDetails({
    required this.parser,
    required this.resolution,
    this.delimiter,
  });

  final TaxonResolvedParser parser;
  final TaxonParseResolution resolution;
  final String? delimiter;
}

class TaxonParsedFile {
  const TaxonParsedFile({
    required this.data,
    required this.details,
  });

  final CsvData data;
  final TaxonFileParseDetails details;
}

enum TaxonFileParseErrorCode {
  generic,
  autoDetectExhausted,
  manualSelectionFailed,
}

class _DelimiterCandidateScore {
  const _DelimiterCandidateScore({
    required this.delimiter,
    required this.score,
    required this.consistency,
  });

  final String delimiter;
  final int score;
  final double consistency;
}

class _DelimiterGuess {
  const _DelimiterGuess({
    required this.delimiter,
    required this.resolution,
  });

  final String delimiter;
  final TaxonParseResolution resolution;
}

class TaxonFileParser {
  const TaxonFileParser();

  Future<TaxonParsedFile> parseFileDetailed(
    File inputFile, {
    TaxonFileParseOptions? options,
  }) async {
    final extension = p.extension(inputFile.path).toLowerCase();
    if (options != null) {
      return _parseWithOverridesDetailed(inputFile, options);
    }
    return _parseByExtensionDetailed(inputFile, extension);
  }

  Future<TaxonParsedFile> _parseWithOverridesDetailed(
    File inputFile,
    TaxonFileParseOptions options,
  ) async {
    try {
      switch (options.mode) {
        case TaxonFileParseMode.auto:
          return await _parseUnknownFileDetailed(inputFile);
        case TaxonFileParseMode.delimiter:
          final delimiter = _normalizeDelimiter(options.delimiter ?? '');
          if (delimiter.isEmpty) {
            throw const TaxonFileParseException(
                'Custom delimiter cannot be empty.');
          }
          return await _parseDelimitedFileWithDetails(
            inputFile,
            delimiter,
            TaxonParseResolution.manualOverride,
          );
        case TaxonFileParseMode.excel:
          return await _parseExcelFileWithDetails(
            inputFile,
            TaxonParseResolution.manualOverride,
          );
      }
    } catch (e) {
      if (e is TaxonFileParseException) {
        if (e.code == TaxonFileParseErrorCode.autoDetectExhausted) {
          rethrow;
        }
        throw TaxonFileParseException(
          'Failed to parse with selected option. $e '
          'Choose another parser or switch to auto detect.',
          code: TaxonFileParseErrorCode.manualSelectionFailed,
        );
      }
      throw TaxonFileParseException(
        'Failed to parse with selected option. $e '
        'Choose another parser or switch to auto detect.',
        code: TaxonFileParseErrorCode.manualSelectionFailed,
      );
    }
  }

  Future<TaxonParsedFile> _parseByExtensionDetailed(
      File inputFile, String extension) {
    return _parseByExtensionOrGuessDetailed(inputFile, extension);
  }

  Future<TaxonParsedFile> _parseByExtensionOrGuessDetailed(
    File inputFile,
    String extension,
  ) {
    switch (extension) {
      case '.csv':
        return _parseDelimitedFileWithDetails(
          inputFile,
          ',',
          TaxonParseResolution.extensionDefault,
        );
      case '.tsv':
        return _parseDelimitedFileWithDetails(
          inputFile,
          '\t',
          TaxonParseResolution.extensionDefault,
        );
      default:
        if (supportedTaxonExcelExtensions.contains(extension)) {
          return _parseExcelFileWithDetails(
            inputFile,
            TaxonParseResolution.extensionDefault,
          );
        }
        return _parseUnknownFileDetailed(inputFile);
    }
  }

  Future<TaxonParsedFile> _parseUnknownFileDetailed(File inputFile) async {
    try {
      return await _parseExcelFileWithDetails(
        inputFile,
        TaxonParseResolution.autoDetectExcel,
      );
    } catch (_) {
      final guess = await _guessDelimiter(inputFile);
      if (guess == null) {
        throw const TaxonFileParseException(
          'Unable to auto-detect file format after trying Excel, comma, '
          'tab, and semicolon. Enter a custom delimiter to continue.',
          code: TaxonFileParseErrorCode.autoDetectExhausted,
        );
      }
      return _parseDelimitedFileWithDetails(
        inputFile,
        guess.delimiter,
        guess.resolution,
      );
    }
  }

  Future<TaxonParsedFile> _parseDelimitedFileWithDetails(
    File inputFile,
    String delimiter,
    TaxonParseResolution resolution,
  ) async {
    try {
      final lines = await _readDelimitedRows(inputFile, delimiter);
      List<List<dynamic>> rows = lines
          .where(
              (row) => row.any((value) => value.toString().trim().isNotEmpty))
          .toList();

      if (rows.length < 2) {
        throw const TaxonFileParseException('No data found in file');
      }

      if (rows.first.length < 2) {
        throw const TaxonFileParseException(
          'Unable to parse tabular columns with the selected delimiter.',
        );
      }

      CsvData data = CsvData.empty();
      data.parseTaxonEntryFromList(rows);

      return TaxonParsedFile(
        data: data,
        details: TaxonFileParseDetails(
          parser: TaxonResolvedParser.delimited,
          resolution: resolution,
          delimiter: delimiter,
        ),
      );
    } catch (e) {
      if (e is TaxonFileParseException) {
        rethrow;
      }
      throw TaxonFileParseException('Error parsing delimited file: $e');
    }
  }

  Future<List<List<dynamic>>> _readDelimitedRows(
      File inputFile, String delimiter) async {
    final reader = inputFile.openRead();
    final eolDetector = FirstOccurrenceSettingsDetector(
      fieldDelimiters: [delimiter],
      eols: const ['\r\n', '\n'],
    );
    return await reader
        .transform(utf8.decoder)
        .transform(CsvToListConverter(
          csvSettingsDetector: eolDetector,
          shouldParseNumbers: false,
        ))
        .toList();
  }

  Future<_DelimiterGuess?> _guessDelimiter(File inputFile) async {
    const knownCandidates = [',', '\t', ';'];

    final knownScores = await _scoreDelimiterCandidates(
      inputFile,
      knownCandidates,
    );
    final bestKnown = _pickBestCandidate(knownScores);
    if (bestKnown != null && bestKnown.consistency >= 0.85) {
      return _DelimiterGuess(
        delimiter: bestKnown.delimiter,
        resolution: TaxonParseResolution.autoDetectKnownDelimiter,
      );
    }

    final minedCandidates = await _mineDelimiterCandidatesFromText(inputFile);
    final minedScores = await _scoreDelimiterCandidates(
      inputFile,
      minedCandidates,
    );
    final bestMined = _pickBestCandidate(minedScores);
    if (bestMined != null) {
      return _DelimiterGuess(
        delimiter: bestMined.delimiter,
        resolution: TaxonParseResolution.autoDetectMinedDelimiter,
      );
    }

    final bestOverall = _pickBestCandidate(knownScores);
    if (bestOverall != null) {
      return _DelimiterGuess(
        delimiter: bestOverall.delimiter,
        resolution: TaxonParseResolution.autoDetectKnownDelimiter,
      );
    }

    return null;
  }

  Future<List<_DelimiterCandidateScore>> _scoreDelimiterCandidates(
    File inputFile,
    List<String> candidates,
  ) async {
    final List<_DelimiterCandidateScore> scores = [];
    for (final delimiter in candidates) {
      final candidateScore =
          await _scoreDelimiterCandidate(inputFile, delimiter);
      if (candidateScore != null) {
        scores.add(candidateScore);
      }
    }
    return scores;
  }

  Future<_DelimiterCandidateScore?> _scoreDelimiterCandidate(
    File inputFile,
    String delimiter,
  ) async {
    try {
      final rows = await _readDelimitedRows(inputFile, delimiter);
      final nonEmptyRows = rows
          .where(
              (row) => row.any((value) => value.toString().trim().isNotEmpty))
          .toList();
      if (nonEmptyRows.length < 2) {
        return null;
      }

      final rowLengths = nonEmptyRows.map((row) => row.length).toList();
      final lengthCounts = <int, int>{};
      for (final rowLength in rowLengths) {
        lengthCounts[rowLength] = (lengthCounts[rowLength] ?? 0) + 1;
      }

      int mostCommonLength = 0;
      int mostCommonFrequency = 0;
      lengthCounts.forEach((length, frequency) {
        if (frequency > mostCommonFrequency) {
          mostCommonLength = length;
          mostCommonFrequency = frequency;
        }
      });

      if (mostCommonLength < 2) {
        return null;
      }

      final consistency = mostCommonFrequency / rowLengths.length;
      if (consistency < 0.6) {
        return null;
      }

      final score = (consistency * 1000).round() +
          (mostCommonLength * 25) +
          (nonEmptyRows.length * 5);
      return _DelimiterCandidateScore(
        delimiter: delimiter,
        score: score,
        consistency: consistency,
      );
    } catch (_) {
      return null;
    }
  }

  _DelimiterCandidateScore? _pickBestCandidate(
    List<_DelimiterCandidateScore> scores,
  ) {
    if (scores.isEmpty) {
      return null;
    }

    scores.sort((a, b) => b.score.compareTo(a.score));
    if (scores.length > 1 && (scores[0].score - scores[1].score).abs() < 15) {
      return null;
    }
    return scores.first;
  }

  Future<List<String>> _mineDelimiterCandidatesFromText(File inputFile) async {
    String text;
    try {
      text = await inputFile.readAsString();
    } catch (_) {
      try {
        text = await inputFile.readAsString(encoding: latin1);
      } catch (_) {
        return [];
      }
    }

    final lines = text
        .split(RegExp(r'\r\n|\r|\n'))
        .where((line) => line.trim().isNotEmpty)
        .take(200)
        .toList();
    if (lines.length < 2) {
      return [];
    }

    final counts = <String, int>{};
    for (final line in lines) {
      bool inQuotes = false;
      for (int i = 0; i < line.length; i++) {
        final char = line[i];
        if (char == '"') {
          if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
            i++;
            continue;
          }
          inQuotes = !inQuotes;
          continue;
        }
        if (inQuotes) {
          continue;
        }
        if (!_isMinedDelimiterCandidate(char)) {
          continue;
        }
        counts[char] = (counts[char] ?? 0) + 1;
      }
    }

    final minCount = lines.length;
    final candidates = counts.entries
        .where((entry) => entry.value >= minCount)
        .map((entry) => entry.key)
        .where((char) => char != ',' && char != '\t' && char != ';')
        .toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));

    return candidates.take(8).toList();
  }

  bool _isMinedDelimiterCandidate(String char) {
    const candidatePool = {
      '|',
      ':',
      '^',
      '~',
      '+',
      '=',
      '*',
      '#',
      '@',
      '%',
      '&',
      '!',
      '?',
    };
    return candidatePool.contains(char);
  }

  String _normalizeDelimiter(String rawDelimiter) {
    switch (rawDelimiter) {
      case r'\t':
        return '\t';
      case r'\n':
        return '\n';
      case r'\r':
        return '\r';
      default:
        return rawDelimiter;
    }
  }

  Future<TaxonParsedFile> _parseExcelFileWithDetails(
    File inputFile,
    TaxonParseResolution resolution,
  ) async {
    try {
      final bytes = await inputFile.readAsBytes();
      final workbook = excel.Excel.decodeBytes(bytes);

      List<List<dynamic>>? rows;
      for (final sheet in workbook.tables.values) {
        final sheetRows = sheet.rows
            .map((row) => row.map(_xlsxCellToString).toList())
            .where(
                (row) => row.any((value) => value.toString().trim().isNotEmpty))
            .toList();

        if (sheetRows.isNotEmpty) {
          rows = sheetRows;
          break;
        }
      }

      if (rows == null || rows.length < 2) {
        throw const TaxonFileParseException('No data found in file');
      }

      CsvData data = CsvData.empty();
      data.parseTaxonEntryFromList(rows);
      return TaxonParsedFile(
        data: data,
        details: TaxonFileParseDetails(
          parser: TaxonResolvedParser.excel,
          resolution: resolution,
        ),
      );
    } catch (e) {
      if (e is TaxonFileParseException) {
        rethrow;
      }
      throw TaxonFileParseException(
        'Unable to parse Excel file. Best support is for .xlsx. '
        'Other Excel formats may fail. Try saving as .xlsx, .csv, or .tsv.',
      );
    }
  }

  String _xlsxCellToString(dynamic cell) {
    if (cell == null) {
      return '';
    }

    final dynamic value;
    try {
      value = cell.value;
    } catch (_) {
      return cell.toString().trim();
    }

    if (value == null) {
      return '';
    }

    if (value is excel.TextCellValue) {
      return (value.value.text ?? '').trim();
    }

    return value.toString().trim();
  }
}

List<String> findTaxonImportProblems(
  Map<int, TaxonEntryHeader> headerMap, {
  List<List<String>>? rows,
}) {
  List<String> problemHeaders = _findDuplicateValues(headerMap);

  for (var header in requiredTaxonImportHeaders) {
    if (!headerMap.containsValue(header)) {
      problemHeaders.add('Missing ${matchTaxonEntryHeader(header)}');
    }
  }

  if (rows != null) {
    problemHeaders.addAll(_findMissingRequiredValues(headerMap, rows));
  }

  return problemHeaders;
}

List<String> _findMissingRequiredValues(
  Map<int, TaxonEntryHeader> headerMap,
  List<List<String>> rows,
) {
  final issues = <String>[];
  for (final header in requiredTaxonImportHeaders) {
    int? columnIndex;
    for (final entry in headerMap.entries) {
      if (entry.value == header) {
        columnIndex = entry.key;
        break;
      }
    }
    if (columnIndex == null) {
      continue;
    }

    int missingCount = 0;
    for (final row in rows) {
      if (columnIndex >= row.length || row[columnIndex].trim().isEmpty) {
        missingCount++;
      }
    }
    if (missingCount > 0) {
      issues.add(
        'Missing ${matchTaxonEntryHeader(header)} values in $missingCount row(s)',
      );
    }
  }
  return issues;
}

List<String> _findDuplicateValues(Map<int, TaxonEntryHeader> headerMap) {
  List<String> problemHeaders = [];
  List<TaxonEntryHeader> values = headerMap.values.toList();
  for (var header in values) {
    if (header != TaxonEntryHeader.ignore) {
      if (values.where((element) => element == header).length > 1) {
        problemHeaders.add('Duplicate ${matchTaxonEntryHeader(header)}');
      }
    }
  }
  return problemHeaders.toSet().toList();
}

class TaxonEntryReader extends AppServices {
  const TaxonEntryReader({required super.ref});

  static const TaxonFileParser _fileParser = TaxonFileParser();

  Future<TaxonParsedFile> parseFileDetailed(
    File inputFile, {
    TaxonFileParseOptions? options,
  }) async {
    return _fileParser.parseFileDetailed(inputFile, options: options);
  }

  List<String> findProblems(
    Map<int, TaxonEntryHeader> headerMap, {
    List<List<String>>? rows,
  }) {
    return findTaxonImportProblems(headerMap, rows: rows);
  }

  Future<ParsedCSVdata> parseData(CsvData data) async {
    final problems = findProblems(data.headerMap, rows: data.data);
    if (problems.isNotEmpty) {
      throw Exception('Invalid import data: ${problems.join(', ')}');
    }

    ParsedCSVdata importData = ParsedCSVdata.empty();
    HashSet<String> importedFamilies = HashSet();
    HashSet<String> importedSpecies = HashSet();

    List<TaxonEntryData> parsedData = _parseData(data);

    for (var data in parsedData) {
      bool hasSpecies = await _checkSpeciesExist(data);
      String species = '${data.genus} ${data.specificEpithet}';
      if (hasSpecies) {
        importData.skippedSpecies.add(species);
        continue;
      }
      TaxonomyCompanion dbForm = _getDbForm(data);
      TaxonomyServices(ref: ref).createTaxon(dbForm);
      importData.recordCount++;

      if (!importedFamilies.contains(data.taxonFamily)) {
        importedFamilies.add(data.taxonFamily);
      }

      if (!importedSpecies.contains(species)) {
        importedSpecies.add(species);
      }
    }
    importData.countAll(importedSpecies, importedFamilies);
    ref.invalidate(taxonRegistryProvider);
    return importData;
  }

  List<TaxonEntryData> _parseData(CsvData data) {
    try {
      TaxonParser parser = TaxonParser(
        headerMap: data.headerMap,
        data: data.data,
      );
      return parser.parseData();
    } catch (e) {
      throw Exception("Error parsing data: $e");
    }
  }

  TaxonomyCompanion _getDbForm(TaxonEntryData data) {
    return TaxonomyCompanion(
      taxonClass: db.Value(data.taxonClass.trim().toSentenceCase()),
      taxonOrder: db.Value(data.taxonOrder.trim().toSentenceCase()),
      taxonFamily: db.Value(data.taxonFamily.trim().toSentenceCase()),
      genus: db.Value(data.genus.trim().toSentenceCase()),
      specificEpithet: db.Value(data.specificEpithet.trim().toLowerCase()),
      authors: db.Value(data.authors?.trim()),
      commonName: db.Value(data.commonName?.trim().toLowerCase()),
      citesStatus: db.Value(data.citesStatus?.trim().toUpperCase()),
      redListCategory: db.Value(data.redListCategory?.trim().toUpperCase()),
      countryStatus: db.Value(data.countryStatus?.trim().toUpperCase()),
      sortingOrder: db.Value(data.sortingOrder),
      notes: db.Value(data.notes),
    );
  }

  Future<bool> _checkSpeciesExist(TaxonEntryData data) async {
    try {
      TaxonomyData? species = await TaxonomyServices(ref: ref)
          .getTaxonBySpecies(data.genus, data.specificEpithet);
      return species != null;
    } catch (e) {
      throw Exception('Error checking species: $e');
    }
  }
}
