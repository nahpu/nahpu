import 'dart:ui' show AppExitResponse;

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_edit_toolbar.dart';
import 'package:nahpu/screens/data_table/components/data_table_toolbar.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/services/data_table/data_table_edits.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/database/app_exit.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/data_table.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> chooseRecordType(WidgetTester tester, String label) async {
    await tester.tap(find.byType(RecordTypeMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, label));
    await tester.pumpAndSettle();
  }

  late AppExitCoordinator exitCoordinator;
  const header = [
    'specimen::specimenUUID',
    'specimen::preparator',
    'measurement::remark',
    'measurement::sex',
    'measurement::testisLength',
    'measurement::lifeStage',
  ];
  final loads = <(DataTableRecordType, DataTableQuery)>[];
  final saves = <List<DataTableEdit>>[];

  DataTablePageData page(DataTableRecordType type, DataTableQuery query) {
    if (type != DataTableRecordType.specimenRecords) {
      return DataTablePageData(
        columns: dataTableColumnsFromHeader(const ['site::site']),
        rows: const [],
        totalRows: 0,
        page: 0,
        pageCount: 1,
        rowsPerPage: query.rowsPerPage,
      );
    }
    return DataTablePageData(
      columns: dataTableColumnsFromHeader(header),
      rows: [
        for (var i = 1; i <= 3; i++)
          DataTableRecordRow(
            key: 'r$i',
            values: {
              'specimen::specimenUUID': 'uuid-$i',
              'specimen::preparator': 'Ana Vale',
              'measurement::remark': 'note $i',
              'measurement::sex': 'Male',
              'measurement::testisLength': '1$i',
              'measurement::lifeStage': 'Adult',
            },
            raw: {
              'measurement::lifeStage': 'Adult',
              'measurement::remark': 'note $i',
              'measurement::sex': '0',
              'measurement::testisLength': '1$i',
            },
            attributeTable: 'mammalAttribute',
          ),
      ],
      totalRows: 3,
      page: 0,
      pageCount: 1,
      rowsPerPage: query.rowsPerPage,
    );
  }

  Future<void> pumpScreen(WidgetTester tester, {bool autoSave = false}) async {
    loads.clear();
    saves.clear();
    SharedPreferences.setMockInitialValues({
      dataTableAutoSavePrefKey: autoSave,
    });
    final prefs = await SharedPreferences.getInstance();
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The default columns for specimens aren't in this small header, so
    // the table falls back to showing all three.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appExitCoordinatorProvider.overrideWithValue(
            exitCoordinator = AppExitCoordinator(),
          ),
          databaseProvider.overrideWithValue(database),
          // The vocabularies come from user settings; fix them for the test.
          dataTableChoicesProvider.overrideWith((ref, fieldKey) async {
            if (fieldKey == 'measurement::sex') {
              return const [
                DataTableChoice('0', 'Male'),
                DataTableChoice('1', 'Female'),
                DataTableChoice('2', 'Unknown'),
              ];
            }
            return const [
              DataTableChoice('Adult', 'Adult'),
              DataTableChoice('Juvenile', 'Juvenile'),
            ];
          }),
          settingProvider.overrideWithValue(prefs),
          dataTablePageLoaderProvider.overrideWithValue((
            ref,
            type,
            query,
            specimenType,
          ) {
            loads.add((type, query));
            return Future.value(page(type, query));
          }),
          dataTableEditSaverProvider.overrideWithValue((ref, type, edits) {
            saves.add(edits);
            return Future.value(
              DataTableSaveResult(
                saved: {for (final edit in edits) edit.cell},
                errors: const {},
              ),
            );
          }),
        ],
        child: const MaterialApp(home: DataTableScreen()),
      ),
    );
    await tester.pumpAndSettle();
    // Sex is a default specimen column, so show the rest of this header too.
    await tester.tap(find.text('Columns'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show all'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  }

  Future<void> withControl(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  Future<void> enterEditMode(WidgetTester tester) async {
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
  }

  testWidgets('loads one page with the visible fields', (tester) async {
    await pumpScreen(tester);
    expect(loads.first.$1, DataTableRecordType.specimenRecords);
    expect(loads.first.$2.rowsPerPage, 50);
    expect(find.text('note 2'), findsOneWidget);
    expect(find.text('1–3 of 3'), findsOneWidget);
  });

  testWidgets('arrows, typing, and Enter edit a cell; Ctrl+S saves', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('note 1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).last;
    expect(tester.widget<TextField>(editor).controller!.text, 'x');
    await tester.enterText(editor, 'checked');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('checked'), findsOneWidget);
    expect(find.text('1 unsaved change'), findsOneWidget);

    await withControl(tester, LogicalKeyboardKey.keyS);
    expect(
      saves.single.single.cell,
      const DataTableCellId('r2', 'measurement::remark'),
    );
    expect(saves.single.single.value, 'checked');
  });

  testWidgets('Escape cancels an edit', (tester) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('note 1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'nope');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('note 1'), findsOneWidget);
    expect(find.text('nope'), findsNothing);
  });

  testWidgets('read-only cells refuse edits; Delete clears editable ones', (
    tester,
  ) async {
    await pumpScreen(tester);
    // View mode: nothing is editable.
    await tester.tap(find.text('note 1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(find.text('note 1'), findsOneWidget);

    await enterEditMode(tester);
    await tester.tap(find.text('uuid-1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(find.text('specimenUUID is read-only here.'), findsOneWidget);

    // Select row 1 from the UUID to the remark, then clear.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(find.text('note 1'), findsNothing);
    expect(find.text('Ana Vale'), findsNWidgets(3));
    expect(find.text('Skipped 2 read-only or linked cells.'), findsOneWidget);
  });

  testWidgets('quick filters live in the filter menu', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Clear filters'), findsNothing);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxMenuButton, 'Missing taxon'));
    await tester.pumpAndSettle();
    expect(loads.last.$2.quickFilters, {DataTableQuickFilter.missingTaxon});
    // The menu stays open so several presets can be picked at once.
    expect(find.byType(CheckboxMenuButton), findsWidgets);

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Missing taxon'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(loads.last.$2.quickFilters, isEmpty);
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('the toolbar fits narrow windows while editing', (tester) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('note 1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(find.text('1 unsaved change'), findsOneWidget);

    for (final width in [900.0, 600.0, 375.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'at $width wide');
      expect(find.byTooltip('Filters'), findsOneWidget, reason: 'icon only');
    }
  });

  testWidgets('leaving with unsaved edits asks first', (tester) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('note 1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();

    await chooseRecordType(tester, 'Sites');
    expect(find.text('Save your changes?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(loads.last.$1, DataTableRecordType.specimenRecords);

    await chooseRecordType(tester, 'Sites');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Discard'),
      ),
    );
    await tester.pumpAndSettle();
    expect(loads.last.$1, DataTableRecordType.sites);
    expect(saves, isEmpty);
  });

  testWidgets('auto-save writes committed edits without asking', (
    tester,
  ) async {
    await pumpScreen(tester, autoSave: true);
    await enterEditMode(tester);
    expect(
      tester.widget<Switch>(find.byType(Switch)).value,
      isTrue,
      reason: 'remembered setting',
    );
    await tester.tap(find.text('note 3'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(saves.single.single.value, '');
    expect(
      find.descendant(
        of: find.byType(DataTableEditToolbar),
        matching: find.text('All changes saved'),
      ),
      findsOneWidget,
      reason: 'the status sits next to the edit controls',
    );

    await chooseRecordType(tester, 'Sites');
    expect(find.text('Save your changes?'), findsNothing);
    expect(loads.last.$1, DataTableRecordType.sites);
  });

  testWidgets('Ctrl+Z undoes the last pending edit', (tester) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('note 2'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(find.text('note 2'), findsNothing);
    await withControl(tester, LogicalKeyboardKey.keyZ);
    expect(find.text('note 2'), findsOneWidget);
    expect(find.text('1 unsaved change'), findsNothing);
    // Without auto-save, a clean table says nothing about saving.
    expect(find.text('All changes saved'), findsNothing);
  });

  testWidgets('Ctrl+E toggles edit mode', (tester) async {
    await pumpScreen(tester);
    final chip = find.widgetWithText(FilterChip, 'Edit');
    expect(tester.widget<FilterChip>(chip).selected, isFalse);
    await tester.tap(find.text('note 1'));
    await tester.pump();
    await withControl(tester, LogicalKeyboardKey.keyE);
    expect(tester.widget<FilterChip>(chip).selected, isTrue);
  });

  testWidgets('a sex change asks, then clears what no longer applies', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('Male').first);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    // A dropdown, not a text field, as in the specimen form.
    expect(find.byType(MenuItemButton), findsNWidgets(4));
    await tester.tap(find.widgetWithText(MenuItemButton, 'Female'));
    await tester.pumpAndSettle();

    expect(find.text('Change sex?'), findsOneWidget);
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('11'), findsNothing, reason: 'testis length cleared');
    expect(find.text('2 unsaved changes'), findsOneWidget);
  });

  testWidgets('linked cells open an adaptive dialog', (tester) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('Ana Vale').first);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(find.text('Choose preparator'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(375, 900);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Vale').first);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(find.text('Choose preparator'), findsOneWidget);
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('double-clicking a linked cell opens its dialog', (tester) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    final cell = find.text('Ana Vale').first;
    await tester.tap(cell);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(cell);
    await tester.pumpAndSettle();
    expect(find.text('Choose preparator'), findsOneWidget);
  });

  testWidgets('vocabulary cells use a dropdown driven by the keyboard', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('Adult').first);
    await tester.pump();
    // Typing opens the list at the first choice starting with the letter.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(1), reason: 'search only');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Juvenile'), findsOneWidget);
    expect(find.text('1 unsaved change'), findsOneWidget);

    // Escape closes the list without changing the cell.
    await tester.tap(find.text('Adult').first);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsWidgets);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsNothing);
    expect(find.text('1 unsaved change'), findsOneWidget);
  });

  testWidgets('pasted values must be in the field\'s list', (tester) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? {'text': 'juvenile\nSubadult'}
          : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.tap(find.text('Adult').first);
    await tester.pump();
    await withControl(tester, LogicalKeyboardKey.keyV);
    expect(find.text('Juvenile'), findsOneWidget, reason: 'matched any case');
    expect(
      find.text('Skipped 1 value that isn\'t in its list.'),
      findsOneWidget,
    );
  });

  testWidgets('quitting the app asks about unsaved edits first', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enterEditMode(tester);
    await tester.tap(find.text('note 1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();

    final quitting = exitCoordinator.handleExitRequest(null);
    await tester.pumpAndSettle();
    expect(find.text('Save your changes?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await quitting, AppExitResponse.cancel);
    expect(find.text('1 unsaved change'), findsOneWidget);
  });
}
