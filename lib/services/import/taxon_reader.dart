import 'dart:convert';
import 'dart:io';

import 'package:nahpu/src/rust/api/import.dart';
import 'package:path/path.dart' as p;
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/record_exchange/taxon_exchange_service.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/utility_services.dart';

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
  const TaxonParsedFile({required this.data, required this.details});

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
  const _DelimiterGuess({required this.delimiter, required this.resolution});

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
              'Custom delimiter cannot be empty.',
            );
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
    File inputFile,
    String extension,
  ) {
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
            (row) => row.any((value) => value.toString().trim().isNotEmpty),
          )
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
    File inputFile,
    String delimiter,
  ) async {
    return await RecordReader(
      filePath: inputFile.path,
    ).importDelimitedRaw(delimiter: delimiter);
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
      final candidateScore = await _scoreDelimiterCandidate(
        inputFile,
        delimiter,
      );
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
            (row) => row.any((value) => value.toString().trim().isNotEmpty),
          )
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

      final score =
          (consistency * 1000).round() +
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
    final candidates =
        counts.entries
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
      final reader = RecordReader(filePath: inputFile.path);
      final sheetNames = await reader.getExcelSheetNames();

      List<List<dynamic>>? rows;
      for (final sheet in sheetNames) {
        try {
          final sheetRows = await reader.importExcelRaw(sheetName: sheet);
          if (sheetRows.isNotEmpty && sheetRows.length > 1) {
            rows = sheetRows;
            break;
          }
        } catch (_) {
          continue;
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
        'Other Excel formats may fail. Try saving as .xlsx, .csv, or .tsv. Error: $e',
      );
    }
  }
}

List<String> findTaxonImportProblems(
  Map<int, TaxonEntryHeader> headerMap, {
  List<List<String>>? rows,
  InferableTaxonClass? selectedClass,
}) {
  final problems = _findDuplicateValues(headerMap);
  final hasClass = headerMap.containsValue(TaxonEntryHeader.taxonClass);
  if (!hasClass && selectedClass == null) {
    problems.add(
      'Missing Class. Select a class for all rows to let NAHPU infer the '
      'missing classification. $taxonImportRequiredColumnsGuidance',
    );
  }
  if (rows == null) {
    final hasRank = headerMap.containsValue(TaxonEntryHeader.taxonRank);
    final hasSpeciesFields = requiredTaxonImportHeaders.every(
      (header) =>
          headerMap.containsValue(header) ||
          (header == TaxonEntryHeader.taxonClass && selectedClass != null),
    );
    if (!hasRank && !hasSpeciesFields) {
      problems.add(
        'Add Taxon rank when the complete species columns are not available',
      );
    }
    return problems;
  }

  problems.addAll(
    _findRankAwareProblems(headerMap, rows, selectedClass: selectedClass),
  );
  return problems;
}

List<String> _findRankAwareProblems(
  Map<int, TaxonEntryHeader> headerMap,
  List<List<String>> rows, {
  InferableTaxonClass? selectedClass,
}) {
  final issues = <String>[];
  final requiredRows = <TaxonEntryHeader, Set<int>>{};
  final invalidRanks = <String>[];
  final missingRankRows = <int>[];
  final rankColumn = _columnFor(headerMap, TaxonEntryHeader.taxonRank);
  final classColumn = _columnFor(headerMap, TaxonEntryHeader.taxonClass);
  final unsupportedClassRows = <int>[];

  for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
    final row = rows[rowIndex];
    final className = classColumn == null
        ? selectedClass?.label ?? ''
        : _valueAt(row, classColumn).trim();
    final knownClass = InferableTaxonClass.fromString(className);
    final rawRank = _valueAt(row, rankColumn).trim();
    if (className.isNotEmpty && knownClass == null) {
      final missingClassification =
          [
            TaxonEntryHeader.taxonRank,
            TaxonEntryHeader.kingdom,
            TaxonEntryHeader.phylum,
          ].any(
            (header) =>
                _valueAt(row, _columnFor(headerMap, header)).trim().isEmpty,
          );
      if (missingClassification) unsupportedClassRows.add(rowIndex + 2);
    }
    // The class prompt already explains how to recover these rows. Do not
    // suggest adding a rank until the user has supplied a class.
    if (classColumn == null && selectedClass == null) continue;
    if (rawRank.isEmpty &&
        !_hasCompleteSpeciesFields(headerMap, row, selectedClass)) {
      missingRankRows.add(rowIndex + 2);
      continue;
    }
    final rank = rawRank.isEmpty
        ? _inferredSpeciesRank(
            _valueAt(
              row,
              _columnFor(headerMap, TaxonEntryHeader.subspecificEpithet),
            ),
          )
        : taxonRankFromString(rawRank);
    if (rank == null) {
      invalidRanks.add('$rawRank (row ${rowIndex + 2})');
      continue;
    }
    for (final header in taxonImportRankHeaders.take(rank.index + 1)) {
      if (header == TaxonEntryHeader.taxonClass && classColumn == null) {
        continue;
      }
      requiredRows.putIfAbsent(header, () => <int>{}).add(rowIndex);
    }
  }

  if (unsupportedClassRows.isNotEmpty) {
    issues.add(
      'NAHPU cannot infer classification for the Class values in rows '
      '${unsupportedClassRows.join(', ')}. $taxonImportRequiredColumnsGuidance',
    );
  }
  if (invalidRanks.isNotEmpty) {
    issues.add(
      'Invalid Taxon rank values in ${invalidRanks.length} row(s): '
      '${invalidRanks.join(', ')}',
    );
  }
  if (missingRankRows.isNotEmpty) {
    issues.add(
      'Add Taxon rank for rows without a complete species classification: '
      '${missingRankRows.join(', ')}',
    );
  }

  for (final entry in requiredRows.entries) {
    final header = entry.key;
    final column = _columnFor(headerMap, header);
    if (column == null) {
      issues.add('Missing ${matchTaxonEntryHeader(header)}');
      continue;
    }
    final missingCount = entry.value
        .where((rowIndex) => _valueAt(rows[rowIndex], column).trim().isEmpty)
        .length;
    if (missingCount == 0) continue;
    issues.add(
      'Missing ${matchTaxonEntryHeader(header)} values in '
      '$missingCount row(s)',
    );
  }
  return issues;
}

bool _hasCompleteSpeciesFields(
  Map<int, TaxonEntryHeader> headerMap,
  List<String> row,
  InferableTaxonClass? selectedClass,
) {
  return requiredTaxonImportHeaders.every((header) {
    final column = _columnFor(headerMap, header);
    if (header == TaxonEntryHeader.taxonClass && column == null) {
      return selectedClass != null;
    }
    return _valueAt(row, column).trim().isNotEmpty;
  });
}

TaxonRank _inferredSpeciesRank(String subspecificEpithet) {
  return subspecificEpithet.trim().isEmpty
      ? TaxonRank.species
      : TaxonRank.subspecies;
}

int? _columnFor(Map<int, TaxonEntryHeader> headerMap, TaxonEntryHeader header) {
  for (final entry in headerMap.entries) {
    if (entry.value == header) return entry.key;
  }
  return null;
}

String _valueAt(List<String> row, int? column) {
  if (column == null || column >= row.length) return '';
  return row[column];
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
    InferableTaxonClass? selectedClass,
  }) {
    return findTaxonImportProblems(
      headerMap,
      rows: rows,
      selectedClass: selectedClass,
    );
  }

  Future<ParsedCSVdata> parseData(
    CsvData data, {
    InferableTaxonClass? selectedClass,
  }) async {
    final review = await reviewData(data, selectedClass: selectedClass);
    final selected = {
      for (var index = 0; index < review.candidates.length; index++)
        if (review.candidates[index].isSelectable) index,
    };
    final result = await importSelected(review, selected);
    final importData = ParsedCSVdata.empty()
      ..recordCount = result.importedTaxaCount
      ..importedSpeciesCount = result.importedTaxaCount
      ..importedFamilyCount = result.importedFamilyCount;
    for (final candidate in review.candidates) {
      if (!candidate.isSelectable) {
        importData.skippedSpecies.add(candidate.displayName);
      }
    }
    return importData;
  }

  Future<TaxonImportReview> reviewData(
    CsvData data, {
    InferableTaxonClass? selectedClass,
  }) async {
    final problems = findProblems(
      data.headerMap,
      rows: data.data,
      selectedClass: selectedClass,
    );
    if (problems.isNotEmpty) {
      throw Exception('Invalid import data: ${problems.join(', ')}');
    }

    final entries = _parseData(data)
        .map(
          (parsedEntry) => _normalizeData(
            data.headerMap.containsValue(TaxonEntryHeader.taxonClass)
                ? parsedEntry
                : parsedEntry.copyWith(taxonClass: selectedClass?.label),
          ),
        )
        .toList();
    return _reviewEntries(entries, firstSourceRow: 2);
  }

  Future<TaxonImportReview> reviewQrData(List<TaxonEntryData> entries) {
    final validated = entries.map(TaxonExchangeService.validateQrData).toList();
    return _reviewEntries(validated, firstSourceRow: 1);
  }

  Future<TaxonImportResult> importSelected(
    TaxonImportReview review,
    Set<int> selectedIndexes,
  ) async {
    final currentTaxa = await TaxonomyServices(ref: ref).getTaxonList();
    final currentKeys = currentTaxa.map(_taxonomyKey).toSet();
    final selectedIndexesInOrder = selectedIndexes.toList()..sort();
    final selected = <TaxonImportCandidate>[];
    final selectedKeys = <String>{};
    for (final index in selectedIndexesInOrder) {
      if (index < 0 || index >= review.candidates.length) continue;
      final candidate = review.candidates[index];
      final key = _entryKey(candidate.data);
      if (candidate.isSelectable &&
          !currentKeys.contains(key) &&
          selectedKeys.add(key)) {
        selected.add(candidate);
      }
    }
    final families = selected
        .map((candidate) => candidate.data.taxonFamily.trim())
        .where((family) => family.isNotEmpty)
        .toSet();

    await dbAccess.transaction(() async {
      for (final candidate in selected) {
        await dbAccess
            .into(dbAccess.taxonomy)
            .insert(_getDbForm(candidate.data));
      }
    });
    ref.invalidate(taxonRegistryProvider);
    ref.invalidate(taxonProvider);
    return TaxonImportResult(
      importedTaxaCount: selected.length,
      importedFamilyCount: families.length,
    );
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

  Future<TaxonImportReview> _reviewEntries(
    List<TaxonEntryData> entries, {
    required int firstSourceRow,
  }) async {
    final existingTaxa = await TaxonomyServices(ref: ref).getTaxonList();
    final existingKeys = existingTaxa.map(_taxonomyKey).toSet();
    final seenKeys = <String>{};
    final candidates = <TaxonImportCandidate>[];
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final key = _entryKey(entry);
      final status = existingKeys.contains(key)
          ? TaxonImportStatus.alreadyRegistered
          : seenKeys.contains(key)
          ? TaxonImportStatus.duplicateInFile
          : TaxonImportStatus.ready;
      seenKeys.add(key);
      candidates.add(
        TaxonImportCandidate(
          sourceRow: index + firstSourceRow,
          data: entry,
          status: status,
        ),
      );
    }
    return TaxonImportReview(candidates: candidates);
  }

  TaxonomyCompanion _getDbForm(TaxonEntryData data) {
    final rank = taxonRankFromString(data.taxonRank) ?? TaxonRank.species;
    return TaxonomyCompanion(
      taxonRank: db.Value(rank.databaseValue),
      kingdom: db.Value(_nullable(data.kingdom)),
      phylum: db.Value(_nullable(data.phylum)),
      taxonClass: db.Value(_nullable(data.taxonClass)),
      taxonOrder: db.Value(_nullable(data.taxonOrder)),
      taxonFamily: db.Value(_nullable(data.taxonFamily)),
      genus: db.Value(_nullable(data.genus)),
      specificEpithet: db.Value(_nullable(data.specificEpithet)),
      subspecificEpithet: db.Value(_nullable(data.subspecificEpithet)),
      authors: db.Value(_nullable(data.authors)),
      commonName: db.Value(_nullable(data.commonName)),
      citesStatus: db.Value(_nullable(data.citesStatus)),
      redListCategory: db.Value(_nullable(data.redListCategory)),
      countryStatus: db.Value(_nullable(data.countryStatus)),
      sortingOrder: db.Value(data.sortingOrder),
      notes: db.Value(_nullable(data.notes)),
    );
  }

  TaxonEntryData _normalizeData(TaxonEntryData data) {
    final rank =
        taxonRankFromString(data.taxonRank) ??
        _inferredSpeciesRank(data.subspecificEpithet);
    final knownClass = InferableTaxonClass.fromString(data.taxonClass);
    return data.copyWith(
      taxonRank: rank.databaseValue,
      kingdom: _nullable(data.kingdom) ?? knownClass?.kingdom,
      phylum: _nullable(data.phylum) ?? knownClass?.phylum,
      taxonClass: _throughRank(
        rank,
        TaxonRank.taxonClass,
        data.taxonClass.trim().toSentenceCase(),
      ),
      taxonOrder: _throughRank(
        rank,
        TaxonRank.order,
        data.taxonOrder.trim().toSentenceCase(),
      ),
      taxonFamily: _throughRank(
        rank,
        TaxonRank.family,
        data.taxonFamily.trim().toSentenceCase(),
      ),
      genus: _throughRank(
        rank,
        TaxonRank.genus,
        data.genus.trim().toSentenceCase(),
      ),
      specificEpithet: _throughRank(
        rank,
        TaxonRank.species,
        data.specificEpithet.trim().toLowerCase(),
      ),
      subspecificEpithet: _throughRank(
        rank,
        TaxonRank.subspecies,
        data.subspecificEpithet.trim().toLowerCase(),
      ),
      authors: data.authors?.trim(),
      commonName: data.commonName?.trim().toLowerCase(),
      citesStatus: data.citesStatus?.trim().toUpperCase(),
      redListCategory: data.redListCategory?.trim().toUpperCase(),
      countryStatus: data.countryStatus?.trim().toUpperCase(),
      notes: data.notes?.trim(),
    );
  }

  String _throughRank(TaxonRank rank, TaxonRank fieldRank, String value) {
    return rank.index >= fieldRank.index ? value : '';
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String _entryKey(TaxonEntryData data) {
    final candidate = TaxonImportCandidate(
      sourceRow: 0,
      data: data,
      status: TaxonImportStatus.ready,
    );
    return candidate.identityKey;
  }

  String _taxonomyKey(TaxonomyData data) {
    final rank = taxonRankFromString(data.taxonRank) ?? _inferRank(data);
    final name = switch (rank) {
      TaxonRank.taxonClass => data.taxonClass ?? '',
      TaxonRank.order => data.taxonOrder ?? '',
      TaxonRank.family => data.taxonFamily ?? '',
      TaxonRank.genus => data.genus ?? '',
      TaxonRank.species => '${data.genus ?? ''} ${data.specificEpithet ?? ''}',
      TaxonRank.subspecies =>
        '${data.genus ?? ''} ${data.specificEpithet ?? ''} '
            '${data.subspecificEpithet ?? ''}',
    };
    return _rankNameKey(rank, name);
  }

  TaxonRank _inferRank(TaxonomyData data) {
    if (data.subspecificEpithet?.trim().isNotEmpty == true) {
      return TaxonRank.subspecies;
    }
    if (data.specificEpithet?.trim().isNotEmpty == true) {
      return TaxonRank.species;
    }
    if (data.genus?.trim().isNotEmpty == true) return TaxonRank.genus;
    if (data.taxonFamily?.trim().isNotEmpty == true) return TaxonRank.family;
    if (data.taxonOrder?.trim().isNotEmpty == true) return TaxonRank.order;
    return TaxonRank.taxonClass;
  }

  String _rankNameKey(TaxonRank rank, String name) {
    final normalizedName = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    return '${rank.databaseValue}|${normalizedName.toLowerCase()}';
  }
}
