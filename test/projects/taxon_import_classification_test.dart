import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/import/taxon_reader.dart';
import 'package:nahpu/services/types/import.dart';

void main() {
  test('missing classification columns require an explicit class choice', () {
    final csv = _csv([
      ['Order', 'Family', 'Genus', 'Specific epithet'],
      ['Rodentia', 'Muridae', 'Rattus', 'rattus'],
    ]);

    final problems = findTaxonImportProblems(csv.headerMap, rows: csv.data);
    expect(problems.single, contains('Select a class for all rows'));
    expect(problems.single, contains('Taxon rank, Kingdom, Phylum, Class'));
    expect(
      findTaxonImportProblems(
        csv.headerMap,
        rows: csv.data,
        selectedClass: InferableTaxonClass.mammalia,
      ),
      isEmpty,
    );
    expect(
      findTaxonImportProblems(
        csv.headerMap,
        selectedClass: InferableTaxonClass.mammalia,
      ),
      isEmpty,
    );
  });

  test('a class choice cannot supply missing lower classification', () {
    final csv = _csv([
      ['Taxon rank', 'Family', 'Genus', 'Specific epithet'],
      ['species', 'Muridae', 'Rattus', 'rattus'],
    ]);
    expect(
      findTaxonImportProblems(
        csv.headerMap,
        rows: csv.data,
        selectedClass: InferableTaxonClass.mammalia,
      ),
      contains('Missing Order'),
    );

    csv.headerMap[0] = TaxonEntryHeader.ignore;
    expect(
      findTaxonImportProblems(
        csv.headerMap,
        rows: csv.data,
        selectedClass: InferableTaxonClass.mammalia,
      ).single,
      contains('Add Taxon rank'),
    );
  });

  test('a class choice does not replace an empty mapped Class cell', () {
    final csv = _csv([
      ['Taxon rank', 'Class'],
      ['class', ''],
    ]);
    expect(
      findTaxonImportProblems(
        csv.headerMap,
        rows: csv.data,
        selectedClass: InferableTaxonClass.mammalia,
      ),
      contains('Missing Class values in 1 row(s)'),
    );
  });

  test('unknown classes require explicit rank, kingdom, and phylum', () {
    for (final missingColumn in [0, 1, 2]) {
      final csv = _csv([
        ['Taxon rank', 'Kingdom', 'Phylum', 'Class'],
        ['class', 'Plantae', 'Tracheophyta', 'Magnoliopsida'],
      ]);
      csv.headerMap[missingColumn] = TaxonEntryHeader.ignore;
      expect(
        findTaxonImportProblems(csv.headerMap, rows: csv.data).join('\n'),
        contains(
          'NAHPU cannot infer classification for the Class values in rows 2',
        ),
      );
    }
    expect(InferableTaxonClass.fromString('Magnoliopsida'), isNull);
    expect(InferableTaxonClass.fromString('mamalia'), isNull);
  });

  test('full explicit classification accepts unknown and mixed classes', () {
    final csv = _csv([
      ['Taxon rank', 'Kingdom', 'Phylum', 'Class'],
      ['class', 'Plantae', 'Tracheophyta', 'Magnoliopsida'],
      ['class', '', '', ' Mammalia '],
      ['class', '', '', 'INSECTA'],
    ]);
    expect(findTaxonImportProblems(csv.headerMap, rows: csv.data), isEmpty);
    csv.data[0][2] = ' ';
    expect(
      findTaxonImportProblems(csv.headerMap, rows: csv.data).single,
      contains('Taxon rank, Kingdom, Phylum, Class'),
    );
  });

  test('Kingdom and Phylum map, parse, and detect duplicate mappings', () {
    final csv = _csv([
      ['Taxon rank', 'Kingdom', 'Phylum', 'Class', 'Extra'],
      ['class', 'Animalia', 'Chordata', 'Mammalia', 'Chordata'],
    ]);
    final parsed = TaxonParser(
      headerMap: csv.headerMap,
      data: csv.data,
    ).parseData().single;
    expect(parsed.kingdom, 'Animalia');
    expect(parsed.phylum, 'Chordata');
    csv.headerMap[4] = TaxonEntryHeader.phylum;
    expect(
      findTaxonImportProblems(csv.headerMap, rows: csv.data),
      contains('Duplicate Phylum'),
    );
  });
}

CsvData _csv(List<List<String>> rows) {
  return CsvData.empty()..parseTaxonEntryFromList(rows);
}
