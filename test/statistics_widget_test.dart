import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/services/types/statistics.dart';

void main() {
  testWidgets('bar chart keeps complete labels available', (tester) async {
    const longLabel = 'Extremely long scientific category label';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: StatisticBarChart(
              data: [StatisticDatum(label: longLabel, count: 12)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(longLabel), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('species chart keeps genus and epithet on separate lines',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: StatisticBarChart(
              kind: StatisticKind.species,
              data: [StatisticDatum(label: 'Myotis lucifugus', count: 12)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Myotis'), findsOneWidget);
    expect(find.text('lucifugus'), findsOneWidget);
  });

  testWidgets('statistics table shows fields and invokes export', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var exported = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatisticDataTable(
            rows: const [
              StatisticTableRow(
                rank: 1,
                category: 'Myotis lucifugus',
                count: 3,
                percent: 100,
              ),
            ],
            onExport: () => exported = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rank'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Count'), findsOneWidget);
    expect(find.text('Percent'), findsOneWidget);
    expect(find.text('Myotis lucifugus'), findsOneWidget);

    await tester.tap(find.byTooltip('Export table'));
    expect(exported, isTrue);
  });
}
