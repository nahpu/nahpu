import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/batch_import/batch_import.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_planner.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/import/batch/batch_mapping_store.dart';
import 'package:nahpu/services/providers/batch_import.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late List<BatchImportReview> applied;

  const table = BatchImportTable(
    fileName: 'specimens.csv',
    headers: ['scientificName', 'HF', 'Notes'],
    rows: [
      ['Rattus tiomanicus', '35', 'Good'],
      ['Mus caroli', 'x', 'Good'],
    ],
    rowNumbers: [2, 3],
  );

  const index = BatchImportIndex(
    taxa: [TaxonomyData(id: 1, genus: 'Rattus', specificEpithet: 'tiomanicus')],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    preferences = await SharedPreferences.getInstance();
    applied = [];
  });

  Future<void> pumpWizard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingProvider.overrideWithValue(preferences),
          batchImportFilePickerProvider.overrideWithValue(
            () async => XFile('specimens.csv'),
          ),
          batchImportFileReaderProvider.overrideWithValue(
            (path, {sheetName}) async => table,
          ),
          batchDwcTermsProvider.overrideWith(
            (ref, type) async => batchExtraDwcTerms,
          ),
          batchImportReviewerProvider.overrideWithValue(
            (
              ref, {
              required table,
              required type,
              required mode,
              required matches,
              key,
            }) async => BatchImportPlanner(
              type: type,
              mode: mode,
              index: index,
              key: key,
            ).review(table, matches),
          ),
          batchImportApplierProvider.overrideWithValue((
            ref,
            review, {
            includeMissingLinks = true,
            onProgress,
          }) async {
            applied.add(review);
            final rows = review.importable(
              includeMissingLinks: includeMissingLinks,
            );
            return BatchImportResult(
              type: review.type,
              mode: review.mode,
              written: rows.length,
              skipped: review.rows.length - rows.length,
              errors: const {},
            );
          }),
        ],
        child: const MaterialApp(home: BatchImportPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> continueStep(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets('imports specimens after matching and overriding columns', (
    tester,
  ) async {
    await pumpWizard(tester);
    expect(find.text('Import new records'), findsOneWidget);
    await continueStep(tester);

    await tester.tap(find.text('Select file'));
    await tester.pumpAndSettle();
    expect(find.text('2 rows · 3 columns'), findsOneWidget);
    await continueStep(tester);

    // Darwin Core and alias matches are found. "Notes" reads as a remark,
    // and the user moves it to the condition.
    expect(find.text('Darwin Core'), findsWidgets);
    expect(find.text('Scientific name · Specimen'), findsOneWidget);
    expect(find.text('Hind foot length · Measurements'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    expect(find.text('Remark · Measurements'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Condition'),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Condition'));
    await tester.pumpAndSettle();
    expect(find.text('Your choice'), findsOneWidget);

    await continueStep(tester);
    expect(find.text('Ready: 1'), findsOneWidget);
    expect(find.text('Invalid values: 1'), findsOneWidget);
    expect(find.textContaining('Hind foot length: Enter a number'), findsOne);

    await tester.tap(find.widgetWithText(FilledButton, 'Import records'));
    await tester.pumpAndSettle();
    expect(find.text('Added 1 specimen records.'), findsOneWidget);
    final row = applied.single.importable().single;
    expect(row.values, {
      'measurement::hindFootLength': '35',
      'specimen::condition': 'Good',
    });

    // The override is kept for the next file with these columns.
    expect(
      BatchMappingStore(
        preferences,
      ).load(applied.single.type, BatchImportMode.create, table.headers),
      {'notes': 'specimen::condition'},
    );
  });

  testWidgets('update mode needs a key column', (tester) async {
    await pumpWizard(tester);
    await tester.tap(find.text('Update existing records'));
    await tester.pumpAndSettle();
    await continueStep(tester);
    await tester.tap(find.text('Select file'));
    await tester.pumpAndSettle();
    await continueStep(tester);

    expect(find.text('Key column'), findsOneWidget);
    expect(find.textContaining('Map a column to one of'), findsOneWidget);
    final next = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(next.onPressed, isNull);
  });
}
