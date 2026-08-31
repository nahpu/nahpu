import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/document/document_settings_pane.dart';
import 'package:nahpu/screens/shared/document/specimen_part_filter_dialog.dart';
import 'package:nahpu/screens/shared/document/specimen_part_selection.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/export/specimen_part_filter.dart';
import 'package:nahpu/services/providers/document_selection.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/types/export.dart';

import '../data/specimen_part_fixture.dart';

const _param = BlockRecordSelectionParam(
  blockIndex: 0,
  recordType: RecordType.specimenParts,
);

List<SpecimenPartProjectRecord> _parts() => [
  specimenPartFixture(id: 1, type: 'Blood', fieldNumber: 10),
  specimenPartFixture(id: 2, type: 'Liver', fieldNumber: 20),
  specimenPartFixture(id: 3, type: 'blood', fieldNumber: 30),
  specimenPartFixture(id: 4, type: 'Skin', projectNumber: 200),
  specimenPartFixture(id: 5),
];

void main() {
  testWidgets('bulk text buttons sit at the left below search', (tester) async {
    await _pumpPicker(tester);
    final search = find.byType(TextField);
    final clear = find.widgetWithText(TextButton, 'Clear');
    final selectAll = find.widgetWithText(TextButton, 'Select All');
    expect(
      tester.getTopLeft(clear).dy,
      greaterThan(tester.getBottomLeft(search).dy),
    );
    expect(tester.getTopLeft(clear).dx, lessThan(32));
    expect(
      tester.getTopLeft(selectAll).dx,
      greaterThan(tester.getTopLeft(clear).dx),
    );
    expect(tester.getTopLeft(selectAll).dx, lessThan(200));
    expect(find.byIcon(Icons.select_all), findsNothing);
    expect(find.byIcon(Icons.clear_all), findsNothing);
    expect(tester.widget<TextButton>(selectAll).onPressed, isNull);
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
  });

  for (final width in [500.0, 600.0, 1000.0]) {
    testWidgets('filter presentation at width $width', (tester) async {
      await _pumpPicker(tester, size: Size(width, 900));
      await _openFilters(tester);
      expect(
        find.byType(BottomSheet),
        width < 600 ? findsOneWidget : findsNothing,
      );
      expect(find.byType(Dialog), width < 600 ? findsNothing : findsOneWidget);
      expect(find.byType(SpecimenPartFilterForm), findsOneWidget);
      await _tap(tester, find.text('Cancel'));
      expect(find.byType(SpecimenPartFilterForm), findsNothing);
    });
  }

  testWidgets(
    'filters preserve selections and Select All replaces them exactly',
    (tester) async {
      final container = await _pumpPicker(tester);
      await _openFilters(tester);
      await _tap(tester, find.widgetWithText(CheckboxListTile, 'Blood'));
      await _tap(tester, find.widgetWithText(CheckboxListTile, 'Liver'));
      await _enter(tester, 'From', '10');
      await _enter(tester, 'To', '20');
      await _tap(tester, find.text('Apply'));

      expect(
        find.text('Showing 2 of 5 parts · Selected 5 (3 hidden)'),
        findsOneWidget,
      );
      expect(find.text('T-1 · Blood'), findsOneWidget);
      expect(find.text('T-2 · Liver'), findsOneWidget);
      expect(find.text('T-3 · blood'), findsNothing);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
      expect(
        container
            .read(blockRecordSelectionProvider(_param).notifier)
            .hasUserSelection,
        isFalse,
      );
      expect(container.read(blockRecordSelectionProvider(_param)), {
        '1',
        '2',
        '3',
        '4',
        '5',
      });

      // All visible parts were already selected, but hidden IDs must be removed.
      await _tap(tester, find.text('Select All'));
      expect(container.read(blockRecordSelectionProvider(_param)), {'1', '2'});
      expect(
        container
            .read(blockRecordSelectionProvider(_param).notifier)
            .hasUserSelection,
        isTrue,
      );
      expect(find.text('Showing 2 of 5 parts · Selected 2'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Select All'))
            .onPressed,
        isNull,
      );

      await _tap(tester, find.text('Clear'));
      expect(container.read(blockRecordSelectionProvider(_param)), isEmpty);
      expect(find.text('Showing 2 of 5 parts · Selected 0'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Clear'))
            .onPressed,
        isNull,
      );
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    },
  );

  testWidgets(
    'project number supports search, row context, and range selection',
    (tester) async {
      await _pumpPicker(tester);
      expect(find.text('Project no. 200'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '200');
      await tester.pumpAndSettle();
      expect(
        find.text('Showing 1 of 5 parts · Selected 5 (4 hidden)'),
        findsOneWidget,
      );
      await _openFilters(tester);
      // Type choices come from the entire project, not just search matches.
      expect(find.widgetWithText(CheckboxListTile, 'Blood'), findsOneWidget);
      expect(
        find.widgetWithText(CheckboxListTile, 'Unspecified'),
        findsOneWidget,
      );
      await _chooseProjectNumber(tester);
      await _enter(tester, 'From', '200');
      await _enter(tester, 'To', '200');
      await _tap(tester, find.text('Apply'));
      expect(find.text('T-4 · Skin'), findsOneWidget);
      await _tap(tester, find.text('Clear'));
      expect(find.text('Showing 1 of 5 parts · Selected 0'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '200',
      );

      await _openFilters(tester);
      final dropdown = find.byType(
        DropdownButtonFormField<SpecimenPartNumberType>,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<SpecimenPartNumberType>>(dropdown)
            .initialValue,
        SpecimenPartNumberType.projectNumber,
      );
      await _tap(tester, find.text('Reset filters'));
      await _tap(tester, find.text('Apply'));
      // Reset filters also leaves the search intact.
      expect(find.text('Showing 1 of 5 parts · Selected 0'), findsOneWidget);
      expect(find.text('T-4 · Skin'), findsOneWidget);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
    },
  );

  testWidgets('cancel, dismissal, and reset affect only filter drafts', (
    tester,
  ) async {
    final container = await _pumpPicker(tester);
    await _openFilters(tester);
    await _tap(tester, find.widgetWithText(CheckboxListTile, 'Blood'));
    await _tap(tester, find.text('Cancel'));
    expect(find.text('Showing 5 of 5 parts · Selected 5'), findsOneWidget);

    await _openFilters(tester);
    await _tap(tester, find.widgetWithText(CheckboxListTile, 'Blood'));
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(SpecimenPartFilterForm), findsNothing);
    expect(find.text('Showing 5 of 5 parts · Selected 5'), findsOneWidget);

    await _openFilters(tester);
    await _tap(tester, find.widgetWithText(CheckboxListTile, 'Blood'));
    await _tap(tester, find.text('Apply'));
    await _openFilters(tester);
    expect(
      tester
          .widget<CheckboxListTile>(
            find.widgetWithText(CheckboxListTile, 'Blood'),
          )
          .value,
      isTrue,
    );
    await _tap(tester, find.text('Reset filters'));
    await _tap(tester, find.text('Cancel'));
    expect(
      find.text('Showing 2 of 5 parts · Selected 5 (3 hidden)'),
      findsOneWidget,
    );

    await _openFilters(tester);
    await _tap(tester, find.text('Reset filters'));
    await _tap(tester, find.text('Apply'));
    expect(find.text('Showing 5 of 5 parts · Selected 5'), findsOneWidget);
    expect(
      container
          .read(blockRecordSelectionProvider(_param).notifier)
          .hasUserSelection,
      isFalse,
    );
  });

  testWidgets('invalid ranges stay open until corrected or reset', (
    tester,
  ) async {
    await _pumpPicker(tester);
    await _openFilters(tester);
    for (final value in ['-1', '1.5', 'letters']) {
      await _enter(tester, 'From', value);
      await _tap(tester, find.text('Apply'));
      expect(find.text('Enter a non-negative whole number.'), findsOneWidget);
      expect(find.byType(SpecimenPartFilterForm), findsOneWidget);
    }
    await _enter(tester, 'From', '20');
    await _enter(tester, 'To', '10');
    await _tap(tester, find.text('Apply'));
    expect(find.text('From must be less than or equal to To.'), findsOneWidget);
    await _tap(tester, find.text('Reset filters'));
    expect(find.text('From must be less than or equal to To.'), findsNothing);
    await _enter(tester, 'From', '10');
    await _enter(tester, 'To', '20');
    await _tap(tester, find.text('Apply'));
    expect(find.byType(SpecimenPartFilterForm), findsNothing);
    expect(
      find.text('Showing 2 of 5 parts · Selected 5 (3 hidden)'),
      findsOneWidget,
    );
  });

  testWidgets(
    'no matches cannot select all or silently change export selection',
    (tester) async {
      final container = await _pumpPicker(tester);
      await _openFilters(tester);
      await _enter(tester, 'From', '999');
      await _tap(tester, find.text('Apply'));
      expect(find.text('No specimen parts found'), findsOneWidget);
      expect(
        find.text('Showing 0 of 5 parts · Selected 5 (5 hidden)'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Select All'))
            .onPressed,
        isNull,
      );
      expect(
        container.read(blockRecordSelectionProvider(_param)),
        hasLength(5),
      );
      await _tap(tester, find.text('Clear'));
      expect(container.read(blockRecordSelectionProvider(_param)), isEmpty);
    },
  );

  testWidgets(
    'single selection retains filters and replaces the selected part',
    (tester) async {
      final container = await _pumpPicker(tester, single: true);
      container
          .read(blockRecordSelectionProvider(_param).notifier)
          .updateSelection({'4'});
      await tester.pumpAndSettle();
      expect(find.text('Clear'), findsNothing);
      expect(find.text('Select All'), findsNothing);
      await _openFilters(tester);
      await _tap(tester, find.widgetWithText(CheckboxListTile, 'Blood'));
      await _tap(tester, find.text('Apply'));
      expect(container.read(blockRecordSelectionProvider(_param)), {'4'});
      await _tap(tester, find.text('T-1 · Blood'));
      expect(container.read(blockRecordSelectionProvider(_param)), {'1'});
      await _tap(tester, find.text('T-3 · blood'));
      expect(container.read(blockRecordSelectionProvider(_param)), {'3'});
      await _tap(tester, find.text('T-3 · blood'));
      expect(container.read(blockRecordSelectionProvider(_param)), isEmpty);
    },
  );

  testWidgets(
    'compact sheet scrolls with many types, large text, and a keyboard',
    (tester) async {
      await _pumpPicker(
        tester,
        size: const Size(320, 640),
        textScale: 1.5,
        records: List.generate(
          20,
          (index) => specimenPartFixture(
            id: index,
            type: 'Type $index',
            fieldNumber: index,
          ),
        ),
      );
      await _openFilters(tester);
      await _enter(tester, 'From', '10');
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      await tester.pumpAndSettle();
      await _enter(tester, 'To', '12');
      await tester.ensureVisible(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(find.text('Apply')).dy,
        lessThanOrEqualTo(380),
      );
      expect(tester.takeException(), isNull);
      await _tap(tester, find.text('Apply'));
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(
        find.text('Showing 3 of 20 parts · Selected 20 (17 hidden)'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'document navigation saves selected IDs and resets local filters on return',
    (tester) async {
      final container = await _pumpPicker(tester, navigation: true);
      await _tap(tester, find.text('Select'));
      await _openFilters(tester);
      await _tap(tester, find.widgetWithText(CheckboxListTile, 'Unspecified'));
      await _tap(tester, find.text('Apply'));
      await _tap(tester, find.text('Select All'));
      expect(container.read(blockRecordSelectionProvider(_param)), {'5'});
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Select'));
      expect(find.text('Showing 5 of 5 parts · Selected 1'), findsOneWidget);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
      expect(container.read(blockRecordSelectionProvider(_param)), {'5'});
    },
  );
}

Future<ProviderContainer> _pumpPicker(
  WidgetTester tester, {
  Size size = const Size(1000, 900),
  bool single = false,
  bool navigation = false,
  double textScale = 1,
  List<SpecimenPartProjectRecord>? records,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        specimenPartEntryProvider.overrideWith(
          (ref) async => records ?? _parts(),
        ),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Consumer(
          builder: (context, ref, child) {
            final selectedIds = ref.watch(blockRecordSelectionProvider(_param));
            return Scaffold(
              body: navigation
                  ? RecordNavigationButton(
                      recordType: RecordType.specimenParts,
                      selectedIds: selectedIds,
                      param: _param,
                    )
                  : SpecimenPartSelectionView(
                      selectedIds: selectedIds,
                      isSingleSelection: single,
                      onSelectionChanged: ref
                          .read(blockRecordSelectionProvider(_param).notifier)
                          .updateSelection,
                    ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
}

Future<void> _openFilters(WidgetTester tester) =>
    _tap(tester, find.byIcon(Icons.filter_alt_outlined));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

Future<void> _chooseProjectNumber(WidgetTester tester) async {
  await _tap(
    tester,
    find.byType(DropdownButtonFormField<SpecimenPartNumberType>),
  );
  await _tap(tester, find.text('Project number').last);
}
