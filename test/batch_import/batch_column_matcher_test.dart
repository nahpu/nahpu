import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_column_matcher.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';

void main() {
  final matcher = BatchColumnMatcher(
    targets: batchImportTargets(DataTableRecordType.specimenRecords),
    dwcTerms: const {
      'specimen::genus': 'dwc:genus',
      'specimen::specificEpithet': 'dwc:specificEpithet',
      'measurement::sex': 'dwc:sex',
      'specimen::cataloger': 'dwc:recordedBy',
      batchCatalogNumberKey: 'catalogNumber',
    },
  );

  Map<String, String?> keys(List<BatchColumnMatch> matches) => {
    for (final match in matches) match.header: match.fieldKey,
  };

  test('Darwin Core terms map, with or without a prefix or URI', () {
    final matches = matcher.match([
      'catalogNumber',
      'dwc:genus',
      'http://rs.tdwg.org/dwc/terms/specificEpithet',
      'recordedBy',
      'sex',
    ]);
    expect(keys(matches), {
      'catalogNumber': batchCatalogNumberKey,
      'dwc:genus': 'specimen::genus',
      'http://rs.tdwg.org/dwc/terms/specificEpithet':
          'specimen::specificEpithet',
      'recordedBy': 'specimen::cataloger',
      'sex': 'measurement::sex',
    });
    expect(
      matches.every((m) => m.origin == BatchMatchOrigin.darwinCore),
      isTrue,
    );
  });

  test('field sheet names map by alias and loosely', () {
    final matches = matcher.match([
      'TL',
      'Hind foot',
      'Collector',
      'Ear Lenght',
      'Weight (g)',
    ]);
    expect(keys(matches), {
      'TL': 'measurement::totalLength',
      'Hind foot': 'measurement::hindFootLength',
      'Collector': 'specimen::cataloger',
      'Ear Lenght': 'measurement::earLength',
      'Weight (g)': 'measurement::weight',
    });
    expect(matches[3].origin, BatchMatchOrigin.fuzzyName);
  });

  test('a field takes one column, the first exact one', () {
    final matches = matcher.match(['genus', 'Genus']);
    expect(matches[0].fieldKey, 'specimen::genus');
    expect(matches[1].fieldKey, isNull);
  });

  test('unrelated names stay unmapped', () {
    final matches = matcher.match(['Photo folder', 'xyz']);
    expect(matches.map((m) => m.fieldKey), [null, null]);
    expect(matches.first.origin, BatchMatchOrigin.none);
  });

  test('saved choices win, including skipped columns', () {
    final matches = matcher.match(
      ['genus', 'TL', 'Notes'],
      saved: {'genus': '', 'notes': 'specimen::iDMethod'},
    );
    expect(keys(matches), {
      'genus': null,
      'TL': 'measurement::totalLength',
      'Notes': 'specimen::iDMethod',
    });
    expect(matches[0].origin, BatchMatchOrigin.saved);
  });

  test('Darwin Core mode ignores column names', () {
    final matches = matcher.match([
      'sex',
      'TL',
    ], mode: BatchImportHeaderMode.darwinCore);
    expect(keys(matches), {'sex': 'measurement::sex', 'TL': null});
  });

  test('column names mode ignores Darwin Core terms', () {
    final matches = matcher.match([
      'recordedBy',
    ], mode: BatchImportHeaderMode.names);
    expect(matches.single.origin, isNot(BatchMatchOrigin.darwinCore));
  });

  test('similarity scores identical names 1 and unrelated ones low', () {
    expect(batchNameSimilarity('hind foot', 'hind foot'), 1);
    expect(
      batchNameSimilarity('tail length', 'tail lenght'),
      greaterThan(0.75),
    );
    expect(batchNameSimilarity('weight', 'locality'), lessThan(0.5));
  });

  test('normalized headers split camelCase and punctuation', () {
    expect(normalizeBatchHeader('hindFootLength'), 'hind foot length');
    expect(normalizeBatchHeader(' Hind_Foot-Length '), 'hind foot length');
    expect(normalizeBatchHeader('dwc:catalogNumber'), 'catalog number');
  });
}
