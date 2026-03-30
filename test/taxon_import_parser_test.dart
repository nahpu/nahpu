import 'dart:io';

import 'package:excel/excel.dart' as excel;
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/import/taxon_reader.dart';

void main() {
  const parser = TaxonFileParser();
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('nahpu_taxon_import_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Parses comma-delimited CSV', () async {
    final file = _copyFixtureToTemp(tempDir, 'comma.csv', 'taxa.csv');

    final parsed = (await parser.parseFileDetailed(file)).data;

    expect(parsed.header, [
      'class',
      'Order',
      'family',
      'genus',
      'epithet',
      'scientific name',
      'common name',
    ]);
    expect(parsed.data.length, 2);
    expect(parsed.data.first[0], 'Mammalia');
    expect(parsed.data.first[1], 'Rodentia');
  });

  test('Detailed parse reports comma delimiter from extension', () async {
    final file = _copyFixtureToTemp(tempDir, 'comma.csv', 'taxa.csv');

    final parsed = await parser.parseFileDetailed(file);

    expect(parsed.details.parser, TaxonResolvedParser.delimited);
    expect(parsed.details.delimiter, ',');
    expect(parsed.details.resolution, TaxonParseResolution.extensionDefault);
  });

  test('Parses existing speciesList.csv fixture without regressions', () async {
    final file = File('test/data/taxon_import/speciesList.csv');

    final parsed = (await parser.parseFileDetailed(file)).data;
    final problems = findTaxonImportProblems(parsed.headerMap);

    expect(parsed.header.first.toLowerCase(), 'class');
    expect(parsed.data.length, 4);
    expect(parsed.data.first[3], 'Crocidura');
    expect(problems, isEmpty);
  });

  test('Parses existing speciesList.xlsx fixture without regressions',
      () async {
    final file = File('test/data/taxon_import/speciesList.xlsx');

    final parsed = (await parser.parseFileDetailed(file)).data;
    final problems = findTaxonImportProblems(parsed.headerMap);

    expect(parsed.header.first.toLowerCase(), 'class');
    expect(parsed.data.length, 4);
    expect(parsed.data.first[3], 'Crocidura');
    expect(problems, isEmpty);
  });

  test('Semicolon-delimited CSV needs override', () async {
    final file = _copyFixtureToTemp(tempDir, 'semicolon.csv', 'taxa.csv');

    expect(
      () => parser.parseFileDetailed(file).then((parsed) => parsed.data),
      throwsA(isA<TaxonFileParseException>()),
    );

    final parsed = (await parser.parseFileDetailed(
      file,
      options: const TaxonFileParseOptions.delimiter(';'),
    ))
        .data;

    expect(parsed.header.length, 7);
    expect(parsed.header[0], 'class');
    expect(parsed.data.first[2], 'Muridae');
  });

  test('Auto override detects semicolon for csv extension', () async {
    final file = _copyFixtureToTemp(tempDir, 'semicolon.csv', 'taxa.csv');

    final parsed = await parser.parseFileDetailed(
      file,
      options: const TaxonFileParseOptions.auto(),
    );

    expect(parsed.data.header.length, 7);
    expect(parsed.data.data.first[2], 'Muridae');
    expect(parsed.details.resolution,
        TaxonParseResolution.autoDetectKnownDelimiter);
    expect(parsed.details.delimiter, ';');
  });

  test('Parses TSV', () async {
    final file = _copyFixtureToTemp(tempDir, 'tab.tsv', 'taxa.tsv');

    final parsed = (await parser.parseFileDetailed(file)).data;

    expect(parsed.header.length, 7);
    expect(parsed.data.length, 2);
    expect(parsed.data.first[4], 'coelestis');
    expect(parsed.data.first[0], 'Mammalia,group');
  });

  test('Unknown extension auto-detects semicolon delimiter', () async {
    final file = _copyFixtureToTemp(tempDir, 'semicolon.csv', 'taxa.txt');

    final parsed = (await parser.parseFileDetailed(file)).data;

    expect(parsed.header, [
      'class',
      'Order',
      'family',
      'genus',
      'epithet',
      'scientific name',
      'common name',
    ]);
    expect(parsed.data.first[2], 'Muridae');
  });

  test('Unknown extension auto-detects excel bytes', () async {
    final workbook = excel.Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];

    sheet.appendRow([
      excel.TextCellValue('Class'),
      excel.TextCellValue('Order'),
      excel.TextCellValue('Family'),
      excel.TextCellValue('Genus'),
      excel.TextCellValue('Specific epithet'),
    ]);
    sheet.appendRow([
      excel.TextCellValue('Mammalia'),
      excel.TextCellValue('Rodentia'),
      excel.TextCellValue('Muridae'),
      excel.TextCellValue('Bunomys'),
      excel.TextCellValue('coelestis'),
    ]);

    final file = File('${tempDir.path}/taxa.unknown');
    final bytes = workbook.save();
    await file.writeAsBytes(bytes!);

    final parsed = (await parser.parseFileDetailed(file)).data;

    expect(parsed.header[0], 'Class');
    expect(parsed.data.first[3], 'Bunomys');
  });

  test('Manual override failure includes retry guidance', () async {
    final file = _copyFixtureToTemp(tempDir, 'semicolon.csv', 'taxa.txt');

    expect(
      () => parser
          .parseFileDetailed(
            file,
            options: const TaxonFileParseOptions.excel(),
          )
          .then((parsed) => parsed.data),
      throwsA(
        isA<TaxonFileParseException>().having(
          (e) => e.toString(),
          'message',
          contains('Choose another parser or switch to auto detect.'),
        ),
      ),
    );
  });

  test('Parses XLSX', () async {
    final workbook = excel.Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];

    sheet.appendRow([
      excel.TextCellValue('Class'),
      excel.TextCellValue('Order'),
      excel.TextCellValue('Family'),
      excel.TextCellValue('Genus'),
      excel.TextCellValue('Specific epithet'),
    ]);
    sheet.appendRow([
      excel.TextCellValue('Mammalia'),
      excel.TextCellValue('Rodentia'),
      excel.TextCellValue('Muridae'),
      excel.TextCellValue('Bunomys'),
      excel.TextCellValue('coelestis'),
    ]);

    final file = File('${tempDir.path}/taxa.xlsx');
    final bytes = workbook.save();
    await file.writeAsBytes(bytes!);

    final parsed = (await parser.parseFileDetailed(file)).data;

    expect(parsed.header[0], 'Class');
    expect(parsed.data.first[3], 'Bunomys');
  });

  test('Missing required headers still reported by problem finder', () {
    final data = [
      ['Class', 'Family', 'Genus', 'Specific epithet'],
      ['Mammalia', 'Muridae', 'Bunomys', 'coelestis'],
    ];

    final csvData = parserDataFromRows(data);
    final problems = findTaxonImportProblems(csvData.headerMap);

    expect(problems, contains('Missing Order'));
  });

  test('Missing required values are reported by problem finder', () {
    final data = [
      ['Class', 'Order', 'Family', 'Genus', 'Specific epithet'],
      ['Mammalia', '', 'Muridae', 'Bunomys', 'coelestis'],
      ['', 'Rodentia', 'Muridae', 'Bunomys', 'penitus'],
    ];

    final csvData = parserDataFromRows(data);
    final problems =
        findTaxonImportProblems(csvData.headerMap, rows: csvData.data);

    expect(problems, contains('Missing Order values in 1 row(s)'));
    expect(problems, contains('Missing Class values in 1 row(s)'));
  });

  test('Unknown extension with no clear pattern throws friendly error',
      () async {
    final file =
        _copyFixtureToTemp(tempDir, 'ambiguous_unknown.txt', 'taxa.txt');

    expect(
      () => parser.parseFileDetailed(file).then((parsed) => parsed.data),
      throwsA(
        isA<TaxonFileParseException>().having(
          (e) => e.code,
          'code',
          TaxonFileParseErrorCode.autoDetectExhausted,
        ),
      ),
    );
  });

  test('Unknown extension auto-detects mined pipe delimiter', () async {
    final file =
        _copyFixtureToTemp(tempDir, 'pipe_unknown.txt', 'taxa_unknown.txt');

    final parsed = (await parser.parseFileDetailed(file)).data;

    expect(parsed.header.length, 7);
    expect(parsed.data.length, 2);
    expect(parsed.data.first[3], 'Bunomys');
  });

  test('Detailed parse reports mined delimiter for unknown extension',
      () async {
    final file =
        _copyFixtureToTemp(tempDir, 'pipe_unknown.txt', 'taxa_unknown.txt');

    final parsed = await parser.parseFileDetailed(file);

    expect(parsed.details.parser, TaxonResolvedParser.delimited);
    expect(parsed.details.delimiter, '|');
    expect(
      parsed.details.resolution,
      TaxonParseResolution.autoDetectMinedDelimiter,
    );
  });

  test('Detailed parse reports excel parser for xlsx', () async {
    final workbook = excel.Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];

    sheet.appendRow([
      excel.TextCellValue('Class'),
      excel.TextCellValue('Order'),
      excel.TextCellValue('Family'),
      excel.TextCellValue('Genus'),
      excel.TextCellValue('Specific epithet'),
    ]);
    sheet.appendRow([
      excel.TextCellValue('Mammalia'),
      excel.TextCellValue('Rodentia'),
      excel.TextCellValue('Muridae'),
      excel.TextCellValue('Bunomys'),
      excel.TextCellValue('coelestis'),
    ]);

    final file = File('${tempDir.path}/taxa.xlsx');
    final bytes = workbook.save();
    await file.writeAsBytes(bytes!);

    final parsed = await parser.parseFileDetailed(file);

    expect(parsed.details.parser, TaxonResolvedParser.excel);
    expect(parsed.details.delimiter, isNull);
    expect(parsed.details.resolution, TaxonParseResolution.extensionDefault);
  });

  test('Custom raw text delimiter parses multi-character separator', () async {
    final file = _copyFixtureToTemp(
      tempDir,
      'double_pipe_unknown.txt',
      'taxa_unknown.txt',
    );

    final parsed = (await parser.parseFileDetailed(
      file,
      options: const TaxonFileParseOptions.delimiter('||'),
    ))
        .data;

    expect(parsed.header.length, 7);
    expect(parsed.data.length, 2);
    expect(parsed.data.first[4], 'coelestis');
  });

  test('Auto-detect exhaustion message directs users to custom delimiter',
      () async {
    final file =
        _copyFixtureToTemp(tempDir, 'ambiguous_unknown.txt', 'taxa.txt');

    expect(
      () => parser.parseFileDetailed(file).then((parsed) => parsed.data),
      throwsA(
        isA<TaxonFileParseException>()
            .having(
              (e) => e.code,
              'code',
              TaxonFileParseErrorCode.autoDetectExhausted,
            )
            .having(
              (e) => e.toString(),
              'message',
              contains('Enter a custom delimiter to continue.'),
            ),
      ),
    );
  });

  test('Manual selection failure uses manualSelectionFailed code', () async {
    final file = _copyFixtureToTemp(
      tempDir,
      'pipe_unknown.txt',
      'taxa_unknown.txt',
    );

    expect(
      () => parser
          .parseFileDetailed(
            file,
            options: const TaxonFileParseOptions.delimiter(','),
          )
          .then((parsed) => parsed.data),
      throwsA(
        isA<TaxonFileParseException>().having(
          (e) => e.code,
          'code',
          TaxonFileParseErrorCode.manualSelectionFailed,
        ),
      ),
    );
  });

  test('Unknown extension with no clear pattern includes friendly message',
      () async {
    final file =
        _copyFixtureToTemp(tempDir, 'ambiguous_unknown.txt', 'taxa.txt');

    expect(
      () => parser.parseFileDetailed(file).then((parsed) => parsed.data),
      throwsA(
        isA<TaxonFileParseException>().having(
          (e) => e.toString(),
          'message',
          contains('Unable to auto-detect file format after trying Excel'),
        ),
      ),
    );
  });
}

File _copyFixtureToTemp(Directory tempDir, String fixtureName, String outName) {
  final src = File('test/data/taxon_import/$fixtureName');
  final dst = File('${tempDir.path}/$outName');
  dst.writeAsStringSync(src.readAsStringSync());
  return dst;
}

CsvData parserDataFromRows(List<List<dynamic>> rows) {
  final data = CsvData.empty();
  data.parseTaxonEntryFromList(rows);
  return data;
}
