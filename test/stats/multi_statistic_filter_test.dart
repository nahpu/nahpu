import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/l10n/app_localizations.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/services/types/statistics.dart';

const _sites = [
  StatisticFilterOption(id: 1, label: 'Camp 1'),
  StatisticFilterOption(id: 2, label: 'Camp 2'),
  StatisticFilterOption(id: 3, label: 'River'),
];

const _species = [
  StatisticFilterOption(
    id: 1,
    label: 'Mus musculus',
    taxonOrder: 'Rodentia',
    taxonFamily: 'muridae',
  ),
  StatisticFilterOption(
    id: 2,
    label: 'Rattus rattus',
    taxonOrder: 'rodentia',
    taxonFamily: 'Muridae',
  ),
  StatisticFilterOption(
    id: 3,
    label: 'Sciurus vulgaris',
    taxonOrder: 'Rodentia',
    taxonFamily: 'Sciuridae',
  ),
  StatisticFilterOption(
    id: 4,
    label: 'Pteropus vampyrus',
    taxonOrder: 'Chiroptera',
    taxonFamily: 'Pteropodidae',
  ),
];

void main() {
  Future<List<Set<int>>> pump(
    WidgetTester tester, {
    List<StatisticFilterOption> options = _sites,
  }) async {
    final changes = <Set<int>>[];
    var selected = <int>{};
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 300,
                child: MultiStatisticFilterPicker(
                  options: AsyncData(options),
                  selected: selected,
                  label: 'Site',
                  placeholder: 'All sites',
                  onChanged: (value) => setState(() {
                    changes.add(value);
                    selected = value;
                  }),
                  onRetry: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return changes;
  }

  testWidgets('picks several options from the menu', (tester) async {
    final changes = await pump(tester);
    expect(find.text('All sites'), findsOneWidget);

    await tester.tap(find.text('All sites'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('statistics-multi-filter-1')));
    await tester.pumpAndSettle();
    expect(changes.last, {1});

    await tester.tap(find.byKey(const ValueKey('statistics-multi-filter-3')));
    await tester.pumpAndSettle();
    expect(changes.last, {1, 3});

    // Closing the menu shows the count in the field.
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
  });

  testWidgets('search narrows the list and select all picks the matches', (
    tester,
  ) async {
    final changes = await pump(tester);

    await tester.tap(find.text('All sites'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('statistics-multi-filter-search')),
      'camp',
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('statistics-multi-filter-3')),
      findsNothing,
    );

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(changes.last, {1, 2});

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(changes.last, isEmpty);
  });

  testWidgets('one pick shows its name and the clear button resets', (
    tester,
  ) async {
    final changes = await pump(tester);

    await tester.tap(find.text('All sites'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('statistics-multi-filter-2')));
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();
    expect(find.text('Camp 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear selection'));
    await tester.pumpAndSettle();
    expect(changes.last, isEmpty);
    expect(find.text('All sites'), findsOneWidget);
  });

  testWidgets('phones pick from a bottom sheet', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final changes = await pump(tester);

    await tester.tap(find.text('All sites'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('statistics-multi-filter-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('statistics-multi-filter-2')));
    await tester.pumpAndSettle();
    expect(changes.last, {1, 2});

    await tester.tap(
      find.byKey(const ValueKey('statistics-multi-filter-done')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('2 selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sites have no taxon filter button', (tester) async {
    await pump(tester);
    await tester.tap(find.text('All sites'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('statistics-multi-filter-taxon')),
      findsNothing,
    );
  });

  testWidgets('the filter button narrows species to an order or family', (
    tester,
  ) async {
    final changes = await pump(tester, options: _species);
    bool shown(int id) => find
        .byKey(ValueKey('statistics-multi-filter-$id'))
        .evaluate()
        .isNotEmpty;

    await tester.tap(find.text('All sites'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('statistics-multi-filter-taxon')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('statistics-multi-filter-family')),
    );
    await tester.pumpAndSettle();
    // Names differing only in case are one family, shown capitalized.
    expect(
      find.byKey(const ValueKey('statistics-multi-filter-family-muridae')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const ValueKey('statistics-multi-filter-family-Muridae')),
    );
    await tester.pumpAndSettle();

    // The checklist menu stays open, narrowed to the family.
    expect([1, 2, 3, 4].where(shown), [1, 2]);
    expect(find.text('Family: Muridae'), findsOneWidget);
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(changes.last, {1, 2});

    // Picking an order outside the family drops the family filter.
    await tester.tap(
      find.byKey(const ValueKey('statistics-multi-filter-taxon')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('statistics-multi-filter-order')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('statistics-multi-filter-order-Chiroptera')),
    );
    await tester.pumpAndSettle();
    expect([1, 2, 3, 4].where(shown), [4]);
    expect(find.text('Order: Chiroptera'), findsOneWidget);
    expect(find.text('Family: Muridae'), findsNothing);

    // Deleting the chip shows every species again; picks are kept.
    await tester.tap(
      find
          .descendant(
            of: find.byKey(
              const ValueKey('statistics-multi-filter-chip-order'),
            ),
            matching: find.byType(Icon),
          )
          .last,
    );
    await tester.pumpAndSettle();
    expect([1, 2, 3, 4].where(shown), [1, 2, 3, 4]);
    expect(changes.last, {1, 2});
    expect(tester.takeException(), isNull);
  });
}
