import 'dart:ui' show AppExitResponse;

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_edit_toolbar.dart';
import 'package:nahpu/screens/data_table/components/data_table_find_replace_panel.dart';
import 'package:nahpu/screens/data_table/components/data_table_grid.dart';
import 'package:nahpu/screens/data_table/components/data_table_toolbar.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/data_table/data_table_edits.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/database/app_exit.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/data_table.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/file_format.dart';
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
            specimenUuid: 'r$i',
            mediaKinds: i == 1
                ? const {MediaKind.image, MediaKind.audio}
                : const {},
          ),
      ],
      totalRows: 3,
      page: 0,
      pageCount: 1,
      rowsPerPage: query.rowsPerPage,
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool autoSave = false,
    DataTableScreen screen = const DataTableScreen(),
  }) async {
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
          dataTableRawRowsLoaderProvider.overrideWithValue((
            ref,
            type,
            query,
            specimenType,
            columns,
          ) {
            // One record beyond the page, as on a later page.
            return Future.value([
              ...page(type, query).rows,
              const DataTableRecordRow(
                key: 'r4',
                values: {},
                raw: {'measurement::remark': 'note 4'},
                attributeTable: 'mammalAttribute',
              ),
            ]);
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
        child: MaterialApp(home: screen),
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

  testWidgets('dragging a header edge resizes; double-click resets', (
    tester,
  ) async {
    await pumpScreen(tester);
    final header = find.widgetWithText(DataTableHeaderCell, 'preparator');
    final before = tester.getSize(header).width;
    final handle = find.descendant(
      of: header,
      matching: find.byType(DataTableColumnResizeHandle),
    );
    await tester.drag(handle, const Offset(80, 0));
    await tester.pumpAndSettle();
    expect(tester.getSize(header).width, greaterThan(before + 40));

    await tester.tap(handle);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(handle);
    await tester.pumpAndSettle();
    expect(tester.getSize(header).width, before);
  });

  testWidgets('hovering a cut-off value shows it in full', (tester) async {
    await pumpScreen(tester);
    final header = find.widgetWithText(DataTableHeaderCell, 'preparator');
    final handle = find.descendant(
      of: header,
      matching: find.byType(DataTableColumnResizeHandle),
    );
    // Short values fit and need no tooltip.
    expect(
      find.ancestor(of: find.text('Ana Vale'), matching: find.byType(Tooltip)),
      findsNothing,
    );
    await tester.drag(handle, const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(
      find.ancestor(
        of: find.text('Ana Vale').first,
        matching: find.byWidgetPredicate(
          (widget) => widget is Tooltip && widget.message == 'Ana Vale',
        ),
      ),
      findsOneWidget,
    );
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
    await tester.ensureVisible(find.text('Ana Vale').first);
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

  testWidgets('rows show their media kinds and an open-form button', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.byTooltip('Open form'), findsNWidgets(3));
    expect(find.byIcon(Icons.photo_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
    expect(find.byIcon(Icons.videocam_outlined), findsNothing);

    await tester.tap(find.byTooltip('Open form').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.widget<SpecimenFormView>(find.byType(SpecimenFormView)),
      isA<SpecimenFormView>().having((v) => v.specimenUuid, 'uuid', 'r1'),
    );
  });

  testWidgets('an initial scope shows as a chip and can be cleared', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      screen: const DataTableScreen(
        initialScope: DataTableKeyScope(
          keys: {'r1', 'r2'},
          label: 'Species: Myotis lucifugus',
        ),
      ),
    );
    expect(loads.first.$2.scope?.keys, {'r1', 'r2'});
    final chip = find.widgetWithText(
      InputChip,
      'Species: Myotis lucifugus (2)',
    );
    expect(chip, findsOneWidget);

    await tester.tap(
      find.descendant(of: chip, matching: find.byIcon(Icons.clear)),
    );
    await tester.pumpAndSettle();
    expect(loads.last.$2.scope, isNull);
    expect(chip, findsNothing);
  });

  testWidgets('refresh lives in the app bar menu', (tester) async {
    await pumpScreen(tester);
    expect(find.widgetWithText(TextButton, 'Refresh'), findsNothing);
    final count = loads.length;
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(loads.length, count + 1);
  });

  testWidgets('phones keep one toolbar row and pick filters in sheets', (
    tester,
  ) async {
    await pumpScreen(tester);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // The record type sits inside the search field, on the same row as the
    // filter and column buttons, and the taxon group menu is gone.
    final field = tester.getRect(find.byType(DataTableSearchField));
    final recordType = tester.getRect(find.byType(RecordTypeMenu));
    expect(recordType.top, greaterThanOrEqualTo(field.top));
    expect(recordType.bottom, lessThanOrEqualTo(field.bottom));
    expect(
      tester.getCenter(find.byTooltip('Filters')).dy,
      moreOrLessEquals(field.center.dy),
    );
    expect(find.byType(SpecimenTypeMenu), findsNothing);
    expect(find.byType(DataTableSearchScopeMenu), findsNothing);

    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    expect(find.byType(DataTableFilterSheet), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Mammals'));
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Missing taxon'));
    await tester.pumpAndSettle();
    expect(loads.last.$2.quickFilters, {DataTableQuickFilter.missingTaxon});
    // The sheet stays open with both picks shown.
    final tile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Missing taxon'),
    );
    expect(tile.value, isTrue);
    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Mammals'),
    );
    expect(chip.selected, isTrue);

    // Picking the search field closes the filter sheet for its own sheet.
    await tester.tap(find.text('All visible fields'));
    await tester.pumpAndSettle();
    expect(find.byType(DataTableFilterSheet), findsNothing);
    expect(find.byType(DataTableSearchScopeSheet), findsOneWidget);
    // The first tile searches every field; the next is the first column.
    final first = find.byType(DataTableSearchScopeTile).at(1);
    final label = tester.widget<DataTableSearchScopeTile>(first).label;
    await tester.tap(first);
    await tester.pumpAndSettle();
    expect(loads.last.$2.searchField, isNotNull);

    // Both show as chips, and the badge counts them with the preset.
    expect(find.widgetWithText(InputChip, 'Mammals'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Searching $label'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('3')),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Clear filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
    expect(loads.last.$2.searchField, isNull);
    expect(loads.last.$2.quickFilters, isEmpty);

    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add field rules'));
    await tester.pumpAndSettle();
    expect(find.byType(DataTableFilterSheet), findsNothing);
    expect(find.text('Filter rules'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Columns'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Show all'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Specimen records'));
    await tester.pumpAndSettle();
    expect(find.text('Record type'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Sites'));
    await tester.pumpAndSettle();
    expect(loads.last.$1, DataTableRecordType.sites);
    expect(find.byTooltip('Sites'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('the app bar menu offers find and replace and export', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    expect(find.text('Find and replace'), findsOneWidget);
    expect(find.text('Export table'), findsOneWidget);

    await tester.tap(find.text('Export table'));
    await tester.pumpAndSettle();
    expect(find.text('Column headers'), findsOneWidget);
    expect(find.textContaining('3 records'), findsOneWidget);
    await tester.tap(find.text('Darwin Core'));
    await tester.pumpAndSettle();
    expect(find.text('Darwin Core-mapped columns only'), findsOneWidget);
  });

  testWidgets('replace all queues edits for every matching record', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Find and replace'));
    await tester.pumpAndSettle();

    final panel = find.byType(DataTableFindReplacePanel);
    expect(panel, findsOneWidget);
    final fields = find.descendant(of: panel, matching: find.byType(TextField));
    await tester.enterText(fields.first, 'note');
    await tester.pumpAndSettle();
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.text('Replace all'), findsNothing);

    // Edit mode turns on from the panel; the table stays behind it.
    await tester.tap(find.text('Turn on edit mode'));
    await tester.pumpAndSettle();
    await tester.enterText(fields.last, 'memo');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Replace all'));
    await tester.pumpAndSettle();
    expect(find.text('Replace all?'), findsOneWidget);
    expect(find.textContaining('4 values in 4 records'), findsOneWidget);
    await tester.tap(find.text('Replace').last);
    await tester.pumpAndSettle();
    expect(find.text('memo 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
    expect(find.text('4 unsaved changes'), findsOneWidget);
    expect(find.text('memo 2'), findsOneWidget);
    expect(saves, isEmpty);
  });
}
