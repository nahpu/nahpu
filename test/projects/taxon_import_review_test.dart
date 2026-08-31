import 'dart:async';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/import/taxon_reader.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/import.dart';

void main() {
  testWidgets(
    'taxon review marks existing and repeated species without writes',
    (tester) async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);
      await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Rattus'),
              specificEpithet: Value('rattus'),
            ),
          );
      final csv = _csv([
        ['Mammalia', 'Rodentia', 'Muridae', 'Bunomys', 'coelestis'],
        ['Mammalia', 'Rodentia', 'Muridae', 'Rattus', 'rattus'],
        ['Mammalia', 'Rodentia', 'Muridae', 'Bunomys', 'coelestis'],
      ]);

      final review = await _run(tester, database, (ref) {
        return TaxonEntryReader(ref: ref).reviewData(csv);
      });

      expect(review.candidates.map((candidate) => candidate.status), [
        TaxonImportStatus.ready,
        TaxonImportStatus.alreadyRegistered,
        TaxonImportStatus.duplicateInFile,
      ]);
      expect(await database.select(database.taxonomy).get(), hasLength(1));
    },
  );

  testWidgets(
    'selected taxon import writes one atomic batch and reports counts',
    (tester) async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);
      final csv = _csv([
        ['Mammalia', 'Rodentia', 'Muridae', 'Bunomys', 'coelestis'],
        ['Mammalia', 'Rodentia', 'Muridae', 'Crocidura', 'foetida'],
      ]);

      final result = await _run(tester, database, (ref) async {
        final reader = TaxonEntryReader(ref: ref);
        final review = await reader.reviewData(csv);
        return reader.importSelected(review, {0});
      });

      expect(result.importedTaxaCount, 1);
      expect(result.importedFamilyCount, 1);
      final imported = await database.select(database.taxonomy).getSingle();
      expect(imported.taxonRank, 'species');
      expect(imported.kingdom, 'Animalia');
      expect(imported.phylum, 'Chordata');
    },
  );

  testWidgets('ranked import writes all six ranks and clears lower fields', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final csv = _rankedCsv([
      [
        'class',
        'Mammalia',
        'Rodentia',
        'Muridae',
        'Rattus',
        'rattus',
        'rattus',
      ],
      [
        'order',
        'Mammalia',
        'Rodentia',
        'Muridae',
        'Rattus',
        'rattus',
        'rattus',
      ],
      [
        'family',
        'Mammalia',
        'Rodentia',
        'Muridae',
        'Rattus',
        'rattus',
        'rattus',
      ],
      [
        'genus',
        'Mammalia',
        'Rodentia',
        'Muridae',
        'Rattus',
        'rattus',
        'rattus',
      ],
      [
        'species',
        'Mammalia',
        'Rodentia',
        'Muridae',
        'Rattus',
        'rattus',
        'rattus',
      ],
      [
        'SubSpecies',
        'Mammalia',
        'Rodentia',
        'Muridae',
        'Rattus',
        'rattus',
        'rattus',
      ],
    ]);

    final review = await _run(tester, database, (ref) {
      return TaxonEntryReader(ref: ref).reviewData(csv);
    });
    final result = await _run(tester, database, (ref) {
      return TaxonEntryReader(
        ref: ref,
      ).importSelected(review, {0, 1, 2, 3, 4, 5});
    });
    final imported = await database.select(database.taxonomy).get();

    expect(result.importedTaxaCount, 6);
    expect(imported.map((taxon) => taxon.taxonRank), [
      'class',
      'order',
      'family',
      'genus',
      'species',
      'subspecies',
    ]);
    expect(imported[0].taxonOrder, isNull);
    expect(imported[2].genus, isNull);
    expect(imported[4].subspecificEpithet, isNull);
    expect(imported[5].subspecificEpithet, 'rattus');
    expect(review.candidates.map((candidate) => candidate.displayName), [
      'Mammalia',
      'Rodentia',
      'Muridae',
      'Rattus',
      'Rattus rattus',
      'Rattus rattus rattus',
    ]);
  });

  testWidgets('rank-aware review detects existing and repeated taxa', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.taxonomy)
        .insert(
          const TaxonomyCompanion(
            taxonRank: Value('family'),
            taxonClass: Value('Mammalia'),
            taxonOrder: Value('Rodentia'),
            taxonFamily: Value('Muridae'),
          ),
        );
    final csv = _rankedCsv([
      ['family', 'Mammalia', 'Rodentia', 'Muridae', '', '', ''],
      ['genus', 'Mammalia', 'Rodentia', 'Muridae', 'Rattus', '', ''],
      ['genus', 'Mammalia', 'Rodentia', 'Muridae', 'Rattus', '', ''],
    ]);

    final review = await _run(tester, database, (ref) {
      return TaxonEntryReader(ref: ref).reviewData(csv);
    });

    expect(review.candidates.map((candidate) => candidate.status), [
      TaxonImportStatus.alreadyRegistered,
      TaxonImportStatus.ready,
      TaxonImportStatus.duplicateInFile,
    ]);
  });

  testWidgets('class selection is required before review or database writes', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final csv = CsvData.empty()
      ..parseTaxonEntryFromList([
        ['Order', 'Family', 'Genus', 'Specific epithet'],
        ['Rodentia', 'Muridae', 'Rattus', 'rattus'],
      ]);
    await _run(tester, database, (ref) async {
      await expectLater(
        TaxonEntryReader(ref: ref).reviewData(csv),
        throwsA(
          predicate((error) => error.toString().contains('Select a class')),
        ),
      );
    });
    expect(await database.select(database.taxonomy).get(), isEmpty);
  });

  testWidgets('selected class imports infer species and preserve subspecies', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final csv = CsvData.empty()
      ..parseTaxonEntryFromList([
        ['Order', 'Family', 'Genus', 'Specific epithet', 'Subspecific epithet'],
        ['Rodentia', 'Muridae', 'Rattus', 'rattus', ''],
        ['Rodentia', 'Muridae', 'Rattus', 'rattus', 'RATTUS'],
        ['Rodentia', 'Muridae', 'Rattus', 'rattus', 'rattus'],
      ]);
    await _run(tester, database, (ref) async {
      final reader = TaxonEntryReader(ref: ref);
      final review = await reader.reviewData(
        csv,
        selectedClass: InferableTaxonClass.mammalia,
      );
      expect(review.candidates[2].status, TaxonImportStatus.duplicateInFile);
      expect(review.candidates[1].displayName, 'Rattus rattus rattus');
      final result = await reader.importSelected(review, {0, 1, 2});
      expect(result.importedTaxaCount, 2);
    });
    final imported = await database.select(database.taxonomy).get();
    expect(imported.map((row) => row.taxonRank), ['species', 'subspecies']);
    for (final row in imported) {
      expect(row.taxonClass, 'Mammalia');
      expect(row.kingdom, 'Animalia');
      expect(row.phylum, 'Chordata');
    }
    // A subsequent file or mapping must not inherit synthetic columns.
    expect(csv.headerMap.containsValue(TaxonEntryHeader.taxonClass), isFalse);
    expect(csv.data.first, ['Rodentia', 'Muridae', 'Rattus', 'rattus', '']);
  });

  testWidgets('inferred and supplied higher classification persist per row', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final csv = CsvData.empty()
      ..parseTaxonEntryFromList([
        ['Taxon rank', 'Kingdom', 'Phylum', 'Class'],
        ['class', '', '', 'INSECTA'],
        ['class', '', '', ' Gastropoda '],
        ['class', 'Plantae', 'Tracheophyta', 'Magnoliopsida'],
        ['class', ' supplied kingdom ', ' supplied phylum ', 'Mammalia'],
      ]);
    await _run(tester, database, (ref) async {
      final reader = TaxonEntryReader(ref: ref);
      final review = await reader.reviewData(
        csv,
        selectedClass: InferableTaxonClass.aves,
      );
      await reader.importSelected(review, {0, 1, 2, 3});
    });
    final imported = await database.select(database.taxonomy).get();
    expect(imported.map((row) => row.taxonClass), [
      'Insecta',
      'Gastropoda',
      'Magnoliopsida',
      'Mammalia',
    ]);
    expect(imported.map((row) => row.kingdom), [
      'Animalia',
      'Animalia',
      'Plantae',
      'supplied kingdom',
    ]);
    expect(imported.map((row) => row.phylum), [
      'Arthropoda',
      'Mollusca',
      'Tracheophyta',
      'supplied phylum',
    ]);
  });
}

CsvData _csv(List<List<String>> rows) {
  final csv = CsvData.empty();
  csv.parseTaxonEntryFromList([
    ['Class', 'Order', 'Family', 'Genus', 'Specific epithet'],
    ...rows,
  ]);
  return csv;
}

CsvData _rankedCsv(List<List<String>> rows) {
  final csv = CsvData.empty();
  csv.parseTaxonEntryFromList([
    [
      'Taxon rank',
      'Class',
      'Order',
      'Family',
      'Genus',
      'Specific epithet',
      'Subspecific epithet',
    ],
    ...rows,
  ]);
  return csv;
}

Future<T> _run<T>(
  WidgetTester tester,
  Database database,
  Future<T> Function(WidgetRef ref) action,
) async {
  final completer = Completer<T>();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: Consumer(
        builder: (context, ref, child) {
          if (!completer.isCompleted) {
            action(
              ref,
            ).then(completer.complete, onError: completer.completeError);
          }
          return const SizedBox();
        },
      ),
    ),
  );
  return completer.future;
}
