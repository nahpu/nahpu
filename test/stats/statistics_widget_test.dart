import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/services/types/export.dart';
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

  testWidgets('species chart keeps genus and epithet on separate lines', (
    tester,
  ) async {
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

  testWidgets('compact chart keeps y-axis labels separated', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: StatisticBarChart(
              compact: true,
              height: 180,
              data: [
                StatisticDatum(label: 'One', count: 12),
                StatisticDatum(label: 'Two', count: 9),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final labels = [
      for (final value in [0, 3, 6, 9, 12])
        tester.getRect(find.byKey(ValueKey('statistics-y-axis-$value'))),
    ]..sort((first, second) => first.top.compareTo(second.top));
    for (var index = 1; index < labels.length; index++) {
      expect(labels[index].top, greaterThanOrEqualTo(labels[index - 1].bottom));
    }
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

  testWidgets('statistics export uses shared file settings and supports JSON', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showTabularExportDialog(
                context: context,
                title: 'Export statistics table',
                defaultFileName: 'statistics',
                headers: const ['Rank', 'Category'],
                rows: const [
                  ['1', 'Myotis lucifugus'],
                ],
              ),
              child: const Text('Open export'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open export'));
    await tester.pumpAndSettle();

    expect(find.byType(FileSettingsCard), findsOneWidget);
    expect(find.byType(ExportShareButton), findsOneWidget);
    expect(find.text('File format'), findsOneWidget);
    expect(find.byType(SegmentedButton<ExportFmt>), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<ExportFmt>));
    await tester.pumpAndSettle();
    expect(find.text('JSON (.json)'), findsOneWidget);
  });

  testWidgets('small statistics export opens as a modal sheet', (tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showTabularExportDialog(
                context: context,
                title: 'Export statistics table',
                defaultFileName: 'statistics',
                headers: const ['Rank', 'Category'],
                rows: const [
                  ['1', 'Myotis lucifugus'],
                ],
              ),
              child: const Text('Open export'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open export'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(FileSettingsCard), findsOneWidget);
    expect(find.text('Close'), findsNothing);
  });
}
