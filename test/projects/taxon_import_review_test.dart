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
      expect(await database.select(database.taxonomy).get(), hasLength(1));
    },
  );
}

CsvData _csv(List<List<String>> rows) {
  final csv = CsvData.empty();
  csv.parseTaxonEntryFromList([
    ['Class', 'Order', 'Family', 'Genus', 'Specific epithet'],
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
