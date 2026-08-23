import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/document/document_settings_pane.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/document_selection.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

void main() {
  late Database database;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => database.close());

  testWidgets('preset editor shows block ordering without expansion', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      database: database,
      showBlockOrderingImmediately: true,
    );
    expect(find.text('Order by'), findsOneWidget);
    expect(find.text('Direction'), findsOneWidget);
  });

  testWidgets('export block hides ordering until Show more is opened', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      database: database,
      showBlockOrderingImmediately: false,
    );

    expect(find.text('Order by'), findsNothing);
    // The section itself is a panel now, so "Block #1" has two Card ancestors.
    // The innermost one is the block's own card.
    final blockCard = find
        .ancestor(of: find.text('Block #1'), matching: find.byType(Card))
        .first;
    final showMore = find.descendant(
      of: blockCard,
      matching: find.text('Show more'),
    );
    await tester.tap(showMore);
    await tester.pumpAndSettle();

    expect(find.text('Order by'), findsOneWidget);
  });

  testWidgets('wide order field picker expands searchable table groups', (
    tester,
  ) async {
    _setTestSurfaceSize(tester, const Size(1000, 800));
    rust_config.DocumentLayoutPreset? changedLayout;
    await _pumpSection(
      tester,
      database: database,
      showBlockOrderingImmediately: true,
      onLayoutChanged: (layout) => changedLayout = layout,
    );

    await tester.tap(_orderFieldControl());
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Order records by'), findsOneWidget);
    final dialog = find.byType(Dialog);
    final searchField = find.descendant(
      of: dialog,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Search fields or tables',
      ),
    );
    expect(tester.widget<TextField>(searchField).autofocus, isTrue);
    await tester.enterText(searchField, 'field number');
    await tester.pumpAndSettle();

    final specimenHeader = find.descendant(
      of: dialog,
      matching: find.text('Specimen'),
    );
    expect(specimenHeader, findsOneWidget);
    expect(
      tester.widget<Text>(specimenHeader).style?.fontWeight,
      FontWeight.bold,
    );
    expect(find.text('Field Number'), findsOneWidget);

    await tester.tap(find.text('Field Number'));
    await tester.pumpAndSettle();

    expect(changedLayout?.blocks.single.sortField, 'specimen::fieldNumber');
    expect(find.text('Field Number'), findsOneWidget);
    expect(find.text('Specimen'), findsOneWidget);
  });

  testWidgets('narrow order field picker uses a bottom sheet', (tester) async {
    _setTestSurfaceSize(tester, const Size(500, 800));
    await _pumpSection(
      tester,
      database: database,
      showBlockOrderingImmediately: true,
    );
    expect(
      MediaQuery.sizeOf(tester.element(find.byType(MaterialApp))),
      const Size(500, 800),
    );

    await tester.tap(_orderFieldControl());
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Order records by'), findsOneWidget);
    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Search fields or tables',
    );
    expect(tester.widget<TextField>(searchField).autofocus, isFalse);
  });

  testWidgets('selected table starts expanded and original order clears it', (
    tester,
  ) async {
    _setTestSurfaceSize(tester, const Size(1000, 800));
    rust_config.DocumentLayoutPreset? changedLayout;
    await _pumpSection(
      tester,
      database: database,
      showBlockOrderingImmediately: true,
      initialSortField: 'specimen::fieldNumber',
      onLayoutChanged: (layout) => changedLayout = layout,
    );

    await tester.tap(_orderFieldControl('specimen::fieldNumber'));
    await tester.pumpAndSettle();

    final dialog = find.byType(Dialog);
    final dialogList = find.descendant(
      of: dialog,
      matching: find.byType(ListView),
    );
    var specimenHeader = find.descendant(
      of: dialog,
      matching: find.text('Specimen'),
    );
    for (var i = 0; i < 6 && specimenHeader.evaluate().isEmpty; i++) {
      await tester.drag(dialogList, const Offset(0, -300));
      await tester.pumpAndSettle();
      specimenHeader = find.descendant(
        of: dialog,
        matching: find.text('Specimen'),
      );
    }
    final specimenTile = find.ancestor(
      of: specimenHeader,
      matching: find.byType(ExpansionTile),
    );
    expect(
      tester.widget<ExpansionTile>(specimenTile).initiallyExpanded,
      isTrue,
    );

    await tester.fling(dialogList, const Offset(0, 2000), 1000);
    await tester.pumpAndSettle();
    final originalOrder = find.descendant(
      of: dialog,
      matching: find.text('Original order'),
    );
    await tester.tap(originalOrder);
    await tester.pumpAndSettle();

    expect(changedLayout?.blocks.single.sortField, null);
    expect(find.text('Original order'), findsOneWidget);
  });

  testWidgets('missing imported order field stays visible until replaced', (
    tester,
  ) async {
    _setTestSurfaceSize(tester, const Size(1000, 800));
    await _pumpSection(
      tester,
      database: database,
      showBlockOrderingImmediately: true,
      initialSortField: 'legacyTable::oldField',
    );

    expect(find.text('Missing: Old Field'), findsOneWidget);
    expect(find.text('Legacy Table'), findsOneWidget);
    await tester.tap(_orderFieldControl('legacyTable::oldField'));
    await tester.pumpAndSettle();

    expect(find.text('Missing: Old Field'), findsNWidgets(2));
    expect(
      find.text('Legacy Table · Not available for this template'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Close order field picker'));
    await tester.pumpAndSettle();
    expect(find.text('Missing: Old Field'), findsOneWidget);
  });
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required Database database,
  required bool showBlockOrderingImmediately,
  String? initialSortField,
  ValueChanged<rust_config.DocumentLayoutPreset>? onLayoutChanged,
}) async {
  final layout = rust_config.DocumentLayoutPreset(
    name: 'Test',
    layoutType: 'WholePage',
    pageSizeKey: 'Letter',
    pageOrientation: 'portrait',
    pagePadTopMm: 8,
    pagePadLeftMm: 8,
    pagePadRightMm: 8,
    pagePadBottomMm: 8,
    blocks: [
      rust_config.DocumentLayoutBlock(
        templateName: 'template',
        templateCount: 1,
        rows: 1,
        cols: 1,
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
        pageBreakAfter: false,
        sortField: initialSortField,
        sortDirection: rust_config.DocumentSortDirection.ascending,
      ),
    ],
    fillPage: false,
    multiBlockMode: 'Continuous',
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        templateRecordTypeProvider.overrideWith(
          (ref, templateName) async => RecordType.specimenRecord,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: _DocumentOrderHarness(
            layout: layout,
            showBlockOrderingImmediately: showBlockOrderingImmediately,
            onLayoutChanged: onLayoutChanged,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _orderFieldControl([String field = '']) {
  return find.byKey(ValueKey('block-order-field-0-template-$field'));
}

void _setTestSurfaceSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

class _DocumentOrderHarness extends StatefulWidget {
  const _DocumentOrderHarness({
    required this.layout,
    required this.showBlockOrderingImmediately,
    required this.onLayoutChanged,
  });

  final rust_config.DocumentLayoutPreset layout;
  final bool showBlockOrderingImmediately;
  final ValueChanged<rust_config.DocumentLayoutPreset>? onLayoutChanged;

  @override
  State<_DocumentOrderHarness> createState() => _DocumentOrderHarnessState();
}

class _DocumentOrderHarnessState extends State<_DocumentOrderHarness> {
  late rust_config.DocumentLayoutPreset _layout;

  @override
  void initState() {
    super.initState();
    _layout = widget.layout;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DocumentLayoutSection(
        layout: _layout,
        setupNames: const [],
        selectedSetupName: 'Test',
        templateNames: const ['template'],
        onLayoutChanged: _onLayoutChanged,
        onSetupSelected: (_) {},
        showProfileDropdown: false,
        showBlockOverrideToggle: false,
        showBlockOrderingImmediately: widget.showBlockOrderingImmediately,
      ),
    );
  }

  void _onLayoutChanged(rust_config.DocumentLayoutPreset layout) {
    setState(() => _layout = layout);
    widget.onLayoutChanged?.call(layout);
  }
}
