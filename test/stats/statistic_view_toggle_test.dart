import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/statistic_view_toggle.dart';

void main() {
  Future<List<String>> pump(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final picks = <String>[];
    var selected = 'chart';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) => StatisticViewToggle<String>(
                segments: const [
                  StatisticViewSegment(
                    value: 'chart',
                    icon: Icons.bar_chart_rounded,
                    label: 'Chart',
                  ),
                  StatisticViewSegment(
                    value: 'table',
                    icon: Icons.table_rows_outlined,
                    label: 'Table',
                  ),
                ],
                selected: selected,
                onSelected: (value) => setState(() {
                  picks.add(value);
                  selected = value;
                }),
              ),
            ),
          ),
        ),
      ),
    );
    return picks;
  }

  testWidgets('medium and large screens label the segments', (tester) async {
    final picks = await pump(tester, 600);

    expect(find.text('Chart'), findsOneWidget);
    expect(find.byIcon(Icons.table_rows_outlined), findsOneWidget);
    await tester.tap(find.text('Table'));
    await tester.pump();
    expect(picks, ['table']);
  });

  testWidgets('phones show icons with the label as a tooltip', (tester) async {
    final picks = await pump(tester, 599);

    expect(find.text('Chart'), findsNothing);
    expect(find.text('Table'), findsNothing);
    expect(find.byTooltip('Table'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.table_rows_outlined));
    await tester.pump();
    expect(picks, ['table']);
  });
}
