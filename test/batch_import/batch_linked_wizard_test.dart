import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/batch_import/batch_import.dart';
import 'package:nahpu/services/data_table/data_table_link_service.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_linked_grouper.dart';
import 'package:nahpu/services/import/batch/batch_linked_models.dart';
import 'package:nahpu/services/import/batch/batch_linked_service.dart';
import 'package:nahpu/services/providers/batch_import.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late List<BatchLinkedPlan> applied;

  const table = BatchImportTable(
    fileName: 'mixed.csv',
    headers: [
      'locality',
      'country',
      'lat',
      'long',
      'start date',
      'catalogNumber',
    ],
    rows: [
      ['Camp 3', 'Indonesia', '4.2', '96.3', '2026-04-01', 'A1'],
      ['Camp 3b', 'Indonesia', '4.2', '96.3', '2026-04-01', 'A2'],
    ],
    rowNumbers: [2, 3],
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
            () async => XFile('mixed.csv'),
          ),
          batchImportFileReaderProvider.overrideWithValue(
            (path, {sheetName}) async => table,
          ),
          batchDwcTermsProvider.overrideWith((ref, type) async => const {}),
          batchLinkedGroupLoaderProvider.overrideWithValue(
            (ref, table, matches) async => BatchLinkedGrouper(
              index: const BatchImportIndex(),
            ).group(table, matches),
          ),
          batchLinkOptionsLoaderProvider.overrideWithValue(
            (ref, link) async => const [
              DataTableLinkOption(id: 7, label: 'BK-1'),
            ],
          ),
          batchLinkedApplierProvider.overrideWithValue((
            ref,
            plan, {
            includeMissingLinks = true,
            onProgress,
          }) async {
            applied.add(plan);
            final counts = plan.counts();
            return BatchLinkedResult(
              newSites: counts.newSites,
              linkedSites: counts.linkedSites,
              newEvents: counts.newEvents,
              linkedEvents: counts.linkedEvents,
              specimens: counts.specimens,
              parts: counts.parts,
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

  Future<void> chooseFromMenu(
    WidgetTester tester,
    int card,
    String item,
  ) async {
    await tester.tap(find.byTooltip('Change group').at(card));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  testWidgets('groups rows, then merges and renames sites before import', (
    tester,
  ) async {
    await pumpWizard(tester);
    await tester.tap(find.text('Linked records'));
    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsOneWidget);
    await continueStep(tester);
    await tester.tap(find.text('Select file'));
    await tester.pumpAndSettle();
    await continueStep(tester);
    expect(find.text('Latitude · Coordinates'), findsOneWidget);
    await continueStep(tester);

    expect(find.text('Sites (2)'), findsOneWidget);
    expect(find.text('Events (2)'), findsOneWidget);

    await chooseFromMenu(tester, 1, 'Merge into…');
    await tester.tap(find.text('Camp 3').last);
    await tester.pumpAndSettle();
    expect(find.text('Sites (1)'), findsOneWidget);
    // Both rows are now the same visit.
    expect(find.text('Events (1)'), findsOneWidget);

    await chooseFromMenu(tester, 0, 'Set site ID…');
    await tester.enterText(find.byType(TextField), 'BK-9');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('BK-9'), findsOneWidget);

    await continueStep(tester);
    expect(find.text('Sites: 1 new, 0 linked'), findsOneWidget);
    expect(find.text('Events: 1 new, 0 linked'), findsOneWidget);
    expect(find.text('Specimens: 2'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Import records'));
    await tester.pumpAndSettle();
    expect(find.text('Added 2 specimens and 0 parts.'), findsOneWidget);
    expect(applied.single.sites.single.siteName, 'BK-9');
    expect(applied.single.sites.single.rows, [0, 1]);
  });

  testWidgets('a site can be linked to an existing one', (tester) async {
    await pumpWizard(tester);
    await tester.tap(find.text('Linked records'));
    await tester.pumpAndSettle();
    await continueStep(tester);
    await tester.tap(find.text('Select file'));
    await tester.pumpAndSettle();
    await continueStep(tester);
    await continueStep(tester);

    await chooseFromMenu(tester, 0, 'Link to existing…');
    await tester.tap(find.text('BK-1'));
    await tester.pumpAndSettle();
    expect(find.text('Links to existing'), findsOneWidget);

    await continueStep(tester);
    expect(find.text('Sites: 1 new, 1 linked'), findsOneWidget);
    expect(applied, isEmpty);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Import records'),
          )
          .onPressed,
      isNotNull,
    );
  });
}
