import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
import 'package:nahpu/screens/projects/statistics/record_statistic_metrics.dart';
import 'package:nahpu/screens/projects/statistics/statistics.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  testWidgets('record statistics panel shows project record counts', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(
      tester,
      const Size(600, 600),
      includeProjectDates: true,
      showMetrics: true,
    );

    expect(find.text('Record Statistics'), findsOneWidget);
    expect(find.text('Record counts'), findsOneWidget);
    expect(find.text('Top recorded species'), findsNothing);
    expect(find.byType(StatisticBarChart), findsNothing);
    expect(find.byType(StatisticRankedBarList), findsNothing);
    _expectRecordMetric(
      tester,
      RecordMetricKind.specimens,
      count: 4,
      expectIcon: false,
    );
    _expectRecordMetric(
      tester,
      RecordMetricKind.species,
      count: 2,
      expectIcon: false,
    );
    _expectRecordMetric(
      tester,
      RecordMetricKind.families,
      count: 1,
      expectIcon: false,
    );
    _expectRecordMetric(tester, RecordMetricKind.sites, count: 2);
    _expectRecordMetric(tester, RecordMetricKind.events, count: 3);
    _expectRecordMetric(tester, RecordMetricKind.narratives, count: 5);
    _expectRecordMetric(tester, RecordMetricKind.projectDays, count: 3);
    expect(find.text('Explore more stats'), findsOneWidget);
    expect(find.text('Open statistics'), findsNothing);
  });

  testWidgets('record statistics shows not recorded project days', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(
      tester,
      const Size(600, 600),
      showMetrics: true,
    );

    _expectRecordMetricValue(
      tester,
      RecordMetricKind.projectDays,
      value: 'Not recorded',
    );
  });

  testWidgets('record statistics preserves its hierarchy on narrow panels', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(
      tester,
      const Size(280, 600),
      showMetrics: true,
    );

    expect(tester.takeException(), isNull);
    final hero = tester.getRect(
      find.byKey(const ValueKey('record-stat-specimens')),
    );
    final secondary = tester.getRect(
      find.byKey(const ValueKey('record-stat-secondary')),
    );
    expect(hero.width, secondary.width);

    final specimenCount = _metricTexts(
      tester,
      RecordMetricKind.specimens,
    ).first;
    final speciesCount = _metricTexts(tester, RecordMetricKind.species).first;
    final siteCount = _metricTexts(tester, RecordMetricKind.sites).first;
    expect(
      specimenCount.style!.fontSize,
      greaterThan(speciesCount.style!.fontSize!),
    );
    expect(
      speciesCount.style!.fontSize,
      greaterThan(siteCount.style!.fontSize!),
    );
  });

  testWidgets('record statistics fits the dashboard panel at large text', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(
      tester,
      const Size(420, 700),
      textScaler: const TextScaler.linear(1.3),
    );

    expect(tester.takeException(), isNull);

    await _toggleRecordPanelView(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('record statistics opens on the top recorded species chart', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(tester, const Size(600, 600));

    expect(find.text('Top recorded species'), findsOneWidget);
    expect(find.byType(StatisticRankedBarList), findsOneWidget);
    expect(
      find.byKey(const ValueKey('statistic-ranked-bar-Myotis lucifugus')),
      findsOneWidget,
    );
    expect(find.byKey(RecordMetricKind.specimens.dashboardKey), findsNothing);
    expect(find.text('Explore more stats'), findsOneWidget);

    await _toggleRecordPanelView(tester);

    expect(find.text('Record counts'), findsOneWidget);
    expect(find.byType(StatisticRankedBarList), findsNothing);
    expect(find.byKey(RecordMetricKind.specimens.dashboardKey), findsOneWidget);

    await _toggleRecordPanelView(tester);

    expect(find.byType(StatisticRankedBarList), findsOneWidget);
    expect(find.byKey(RecordMetricKind.specimens.dashboardKey), findsNothing);
  });

  testWidgets('record statistics opens help and detailed species statistics', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(tester, const Size(600, 600));

    await tester.tap(find.byTooltip('Show information'));
    await tester.pumpAndSettle();
    expect(find.text('Record statistics'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore more stats'));
    await tester.pumpAndSettle();
    expect(find.text('Record Statistics'), findsOneWidget);
    expect(find.text('Specimens by species'), findsWidgets);
  });

  testWidgets('full-screen record statistics shows a consistent summary', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(
      tester,
      const Size(599, 1200),
      includeProjectDates: true,
    );

    await tester.tap(find.text('Explore more stats'));
    await tester.pumpAndSettle();

    expect(find.text('Record Statistics'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Top five'), findsNothing);
    expect(
      find.text('Record totals and top five counts by category.'),
      findsOneWidget,
    );
    expect(find.text('Records'), findsOneWidget);
    expect(find.text('Sampling'), findsOneWidget);
    expect(find.text('Site elevation'), findsOneWidget);
    expect(find.text('120.5–350.25 m'), findsOneWidget);
    expect(find.text('Project days'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('Capture days'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    for (final title in const [
      'Specimens by species',
      'Specimens by family',
      'Specimens by site',
      'Specimens by date',
      'Specimens by method',
      'Part quantity by type',
      'Part quantity by treatment',
      'Specimens by sex',
    ]) {
      expect(find.text(title), findsWidgets);
    }
    expect(find.byType(StatisticPieChart), findsNWidgets(2));
    final methodTitle = tester.getRect(find.text('Specimens by method'));
    final sexTitle = tester.getRect(find.text('Specimens by sex'));
    final partTypeTitle = tester.getRect(find.text('Part quantity by type'));
    expect(methodTitle.bottom, lessThan(sexTitle.top));
    expect(sexTitle.bottom, lessThan(partTypeTitle.top));
  });

  testWidgets('summary pie charts can switch between pie and bar', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(tester, const Size(599, 1200));
    await tester.tap(find.text('Explore more stats'));
    for (var index = 0; index < 4; index++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    for (final group in const ['method', 'sex']) {
      final card = find.ancestor(
        of: find.text('Specimens by $group'),
        matching: find.byType(Card),
      );
      final toggle = find.byKey(
        ValueKey('statistics-summary-chart-toggle-$group'),
      );
      expect(find.descendant(of: card, matching: toggle), findsOneWidget);
      await tester.ensureVisible(toggle);
      expect(
        find.descendant(of: card, matching: find.byType(StatisticPieChart)),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.bar_chart_rounded),
        ),
        findsOneWidget,
      );
      await tester.tap(toggle);
      await tester.pump();
      expect(
        find.descendant(of: card, matching: find.byType(StatisticBarChart)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.byType(StatisticPieChart)),
        findsNothing,
      );

      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.pie_chart_outline),
        ),
        findsOneWidget,
      );
      await tester.tap(toggle);
      await tester.pump();
      expect(
        find.descendant(of: card, matching: find.byType(StatisticPieChart)),
        findsOneWidget,
      );
    }
  });

  testWidgets('full-screen summary shows not recorded without project dates', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(tester, const Size(599, 1200));

    await tester.tap(find.text('Explore more stats'));
    await tester.pumpAndSettle();

    expect(find.text('Project days'), findsOneWidget);
    expect(find.text('Not recorded'), findsWidgets);
    expect(find.text('Capture days'), findsOneWidget);
  });

  testWidgets('wide summary stacks records above sampling at full width', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(
      tester,
      const Size(1000, 1400),
      includeProjectDates: true,
    );

    await tester.tap(find.text('Explore more stats'));
    for (var index = 0; index < 4; index++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    final records = tester.getRect(
      find.byKey(const ValueKey('full-screen-record-stat-records')),
    );
    final sampling = tester.getRect(
      find.byKey(const ValueKey('full-screen-record-stat-sampling')),
    );
    expect(records.width, closeTo(sampling.width, 0.1));
    expect(sampling.top, greaterThanOrEqualTo(records.bottom));
    for (final kind in const [
      RecordMetricKind.elevation,
      RecordMetricKind.captureDays,
      RecordMetricKind.projectDays,
      RecordMetricKind.sites,
      RecordMetricKind.events,
      RecordMetricKind.narratives,
    ]) {
      expect(
        find.descendant(
          of: find.byKey(kind.fullScreenKey),
          matching: find.byIcon(kind.icon),
        ),
        findsOneWidget,
        reason: '${kind.label} should keep its icon on the full-screen page',
      );
    }
    for (final kind in const [
      RecordMetricKind.specimens,
      RecordMetricKind.species,
      RecordMetricKind.families,
    ]) {
      expect(
        find.descendant(
          of: find.byKey(kind.fullScreenKey),
          matching: find.byIcon(kind.icon),
        ),
        findsNothing,
        reason: '${kind.label} is iconless on the dashboard, so also here',
      );
    }
  });

  testWidgets(
    'detailed statistics use dependent measures and accurate titles',
    (tester) async {
      await _pumpRecordStatisticsPanel(tester, const Size(800, 1200));
      await tester.tap(find.text('Explore more stats'));
      for (var index = 0; index < 4; index++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      final measureControl = find.byKey(
        const ValueKey('statistics-measure-control'),
      );
      final groupControl = find.byKey(
        const ValueKey('statistics-group-control'),
      );
      await tester.ensureVisible(measureControl);
      await tester.tap(
        find.descendant(of: measureControl, matching: find.text('Species')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Species by family'), findsOneWidget);

      await tester.tap(
        find.descendant(of: groupControl, matching: find.text('Site')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Species by site'), findsOneWidget);

      await tester.tap(
        find.descendant(of: measureControl, matching: find.text('Specimens')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.byKey(const ValueKey('statistics-breakdown-control')),
        findsOneWidget,
      );
      expect(find.text('All sites'), findsOneWidget);

      final detail = find.byKey(const ValueKey('detailed-statistics-content'));
      final breakdownControl = find.byKey(
        const ValueKey('statistics-breakdown-control'),
      );
      await tester.tap(
        find.descendant(of: breakdownControl, matching: find.text('Sex')),
      );
      for (var index = 0; index < 4; index++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(
        find.descendant(of: detail, matching: find.byType(StatisticBarChart)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: detail,
          matching: find.byKey(
            const ValueKey('statistics-detail-chart-toggle'),
          ),
        ),
        findsNothing,
      );

      await tester.tap(
        find.descendant(
          of: measureControl,
          matching: find.text('Part quantity'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Part quantity by part type'), findsOneWidget);
      expect(
        find.descendant(of: groupControl, matching: find.text('Treatment')),
        findsOneWidget,
      );
      expect(find.text('All species'), findsOneWidget);
    },
  );

  testWidgets(
    'detailed standalone category charts use pies below five categories',
    (tester) async {
      await _pumpRecordStatisticsPanel(tester, const Size(800, 1200));
      await tester.tap(find.text('Explore more stats'));
      for (var index = 0; index < 4; index++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      final detail = find.byKey(const ValueKey('detailed-statistics-content'));
      final groupControl = find.byKey(
        const ValueKey('statistics-group-control'),
      );
      await tester.ensureVisible(groupControl);

      for (final group in const ['Method', 'Sex', 'Life stage']) {
        await tester.tap(
          find.descendant(of: groupControl, matching: find.text(group)),
        );
        for (var index = 0; index < 4; index++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(
          find.descendant(of: detail, matching: find.byType(StatisticPieChart)),
          findsOneWidget,
          reason: '$group should use a pie chart below five categories',
        );
        expect(
          find.descendant(of: detail, matching: find.byType(StatisticBarChart)),
          findsNothing,
          reason: '$group should not use a bar chart below five categories',
        );

        final toggle = find.byKey(
          const ValueKey('statistics-detail-chart-toggle'),
        );
        expect(find.descendant(of: detail, matching: toggle), findsOneWidget);
        await tester.tap(toggle);
        await tester.pump();
        expect(
          find.descendant(of: detail, matching: find.byType(StatisticBarChart)),
          findsOneWidget,
        );
        await tester.tap(toggle);
        await tester.pump();
        expect(
          find.descendant(of: detail, matching: find.byType(StatisticPieChart)),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets(
    'detailed standalone category charts use bars at five or more categories',
    (tester) async {
      await _pumpRecordStatisticsPanel(
        tester,
        const Size(800, 1200),
        includeAdditionalCategoryValues: true,
      );
      await tester.tap(find.text('Explore more stats'));
      for (var index = 0; index < 4; index++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      expect(
        find.byKey(const ValueKey('statistics-summary-chart-toggle-method')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('statistics-summary-chart-toggle-sex')),
        findsNothing,
      );

      final detail = find.byKey(const ValueKey('detailed-statistics-content'));
      final groupControl = find.byKey(
        const ValueKey('statistics-group-control'),
      );
      await tester.ensureVisible(groupControl);

      for (final group in const ['Method', 'Sex', 'Life stage']) {
        await tester.tap(
          find.descendant(of: groupControl, matching: find.text(group)),
        );
        for (var index = 0; index < 4; index++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(
          find.descendant(of: detail, matching: find.byType(StatisticBarChart)),
          findsOneWidget,
          reason: '$group should use a bar chart at five or more categories',
        );
        expect(
          find.descendant(of: detail, matching: find.byType(StatisticPieChart)),
          findsNothing,
          reason:
              '$group should not use a pie chart at five or more categories',
        );
      }

      await tester.tap(
        find.descendant(of: groupControl, matching: find.text('Method')),
      );
      for (var index = 0; index < 4; index++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      for (final label in const [
        'Mist net',
        'No method',
        'Hand capture',
        'Light trap',
        'Cage trap',
        'Malaise trap',
      ]) {
        expect(
          find.descendant(of: detail, matching: find.text(label)),
          findsWidgets,
        );
      }
    },
  );

  testWidgets(
    'record statistics uses accessible summary colors in light theme',
    (tester) async {
      final theme = NahpuTheme.lightTheme();
      await _pumpRecordStatisticsPanel(
        tester,
        const Size(600, 600),
        theme: theme,
        showMetrics: true,
      );
      _expectRecordSummaryColors(tester, theme);
    },
  );

  testWidgets(
    'record statistics uses accessible summary colors in dark theme',
    (tester) async {
      final theme = NahpuTheme.darkTheme();
      await _pumpRecordStatisticsPanel(
        tester,
        const Size(600, 600),
        theme: theme,
        showMetrics: true,
      );
      _expectRecordSummaryColors(tester, theme);
    },
  );

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
              group: StatisticGroup.species,
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

  testWidgets('summary pie plot matches bar plot height', (tester) async {
    const chartHeight = 280.0;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 320,
                child: StatisticBarChart(
                  compact: true,
                  height: chartHeight,
                  data: [StatisticDatum(label: 'One', count: 3)],
                ),
              ),
              SizedBox(
                width: 320,
                child: StatisticPieChart(
                  height: chartHeight,
                  data: [StatisticDatum(label: 'One', count: 3)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final barPlot = tester.getSize(find.byType(BarChart));
    final piePlot = tester.getSize(find.byType(PieChart));
    expect(piePlot.height, closeTo(barPlot.height, 0.1));
  });

  testWidgets('detailed statistics keeps a fixed card and expands its chart', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(tester, const Size(1000, 1400));
    await tester.tap(find.text('Explore more stats'));
    for (var index = 0; index < 4; index++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    final detail = find.byKey(const ValueKey('detailed-statistics-content'));
    final measureControl = find.byKey(
      const ValueKey('statistics-measure-control'),
    );
    await tester.ensureVisible(measureControl);

    final initialDetailHeight = tester.getRect(detail).height;
    final initialChart = find.descendant(
      of: detail,
      matching: find.byType(StatisticBarChart),
    );
    final initialChartHeight = tester.getRect(initialChart).height;
    await tester.tap(
      find.descendant(of: measureControl, matching: find.text('Part quantity')),
    );
    for (var index = 0; index < 4; index++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(tester.getRect(detail).height, closeTo(initialDetailHeight, 0.1));
    expect(
      tester.getRect(initialChart).height,
      greaterThan(initialChartHeight),
    );
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
    expect(find.text('Specimens'), findsOneWidget);
  });

  testWidgets('stacked species chart shows breakdown legend', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: StatisticBarChart(
              measure: StatisticMeasure.specimens,
              group: StatisticGroup.species,
              breakdown: StatisticBreakdown.sex,
              data: [
                StatisticDatum(
                  label: 'Myotis lucifugus',
                  seriesLabel: 'Male',
                  count: 3,
                ),
                StatisticDatum(
                  label: 'Myotis lucifugus',
                  seriesLabel: 'Female',
                  count: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Myotis'), findsOneWidget);
    expect(find.text('lucifugus'), findsOneWidget);
  });

  testWidgets('sex pie reports counts and percentages', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatisticPieChart(
            data: [
              StatisticDatum(label: 'Male', count: 3),
              StatisticDatum(label: 'Not recorded', count: 1),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Male: 3 (75.0%)'), findsOneWidget);
    expect(find.text('Not recorded: 1 (25.0%)'), findsOneWidget);
  });

  testWidgets('pie percentage labels keep contrast in both themes', (
    tester,
  ) async {
    for (final theme in [NahpuTheme.lightTheme(), NahpuTheme.darkTheme()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: StatisticPieChart(
              data: [
                StatisticDatum(label: 'One', count: 4),
                StatisticDatum(label: 'Two', count: 3),
                StatisticDatum(label: 'Three', count: 2),
                StatisticDatum(label: 'Four', count: 1),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chart = tester.widget<PieChart>(find.byType(PieChart));
      for (final section in chart.data.sections) {
        final textColor = section.titleStyle?.color;
        expect(textColor, isNotNull);
        expect(
          _contrastRatio(textColor!, section.color),
          greaterThanOrEqualTo(4.5),
        );
      }
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

  testWidgets('statistics table scrolls within a short viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 314);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatisticDataTable(
            rows: [
              for (var index = 0; index < 10; index++)
                StatisticTableRow(
                  rank: index + 1,
                  category: 'Category ${index + 1}',
                  count: index + 1,
                  percent: 10,
                ),
            ],
            onExport: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Category 1'), findsOneWidget);
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

void _expectRecordSummaryColors(WidgetTester tester, ThemeData theme) {
  final colorScheme = theme.colorScheme;
  final emphasisBackground = colorScheme.secondaryContainer.withValues(
    alpha: 0.16,
  );
  final emphasisForeground = colorScheme.onSecondaryContainer;

  for (final kind in const [
    RecordMetricKind.specimens,
    RecordMetricKind.species,
    RecordMetricKind.families,
  ]) {
    _expectTileColors(
      tester,
      kind,
      background: emphasisBackground,
      countColor: emphasisForeground,
      labelColor: emphasisForeground,
      hasIcon: false,
    );
  }
  expect(
    _contrastRatio(
      emphasisForeground,
      Color.alphaBlend(emphasisBackground, colorScheme.surface),
    ),
    greaterThanOrEqualTo(4.5),
  );

  for (final kind in const [
    RecordMetricKind.sites,
    RecordMetricKind.events,
    RecordMetricKind.narratives,
  ]) {
    _expectTileColors(
      tester,
      kind,
      background: colorScheme.surfaceContainerLow,
      countColor: colorScheme.onSurface,
      labelColor: colorScheme.onSurfaceVariant,
    );
  }
  expect(
    _contrastRatio(colorScheme.onSurface, colorScheme.surfaceContainerLow),
    greaterThanOrEqualTo(4.5),
  );
  expect(
    _contrastRatio(
      colorScheme.onSurfaceVariant,
      colorScheme.surfaceContainerLow,
    ),
    greaterThanOrEqualTo(4.5),
  );
}

void _expectTileColors(
  WidgetTester tester,
  RecordMetricKind kind, {
  required Color background,
  required Color countColor,
  required Color labelColor,
  bool hasIcon = true,
}) {
  final tile = find.byKey(kind.dashboardKey);
  final container = tester.widget<Container>(tile);
  expect((container.decoration! as BoxDecoration).color, background);

  final texts = _metricTexts(tester, kind);
  expect(texts.first.style?.color, countColor);
  expect(texts.last.style?.color, labelColor);
  expect(texts.last.textAlign, TextAlign.center);

  final iconFinder = find.descendant(
    of: tile,
    matching: find.byIcon(kind.icon),
  );
  if (!hasIcon) {
    expect(iconFinder, findsNothing);
    return;
  }
  expect(tester.widget<Icon>(iconFinder).color, labelColor);
}

void _expectRecordMetric(
  WidgetTester tester,
  RecordMetricKind kind, {
  required int count,
  bool expectIcon = true,
}) {
  _expectRecordMetricValue(
    tester,
    kind,
    value: count.toString(),
    expectIcon: expectIcon,
  );
}

void _expectRecordMetricValue(
  WidgetTester tester,
  RecordMetricKind kind, {
  required String value,
  bool expectIcon = true,
}) {
  final metric = find.byKey(kind.dashboardKey);
  expect(
    find.descendant(of: metric, matching: find.text(kind.label)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: metric, matching: find.text(value)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: metric, matching: find.byIcon(kind.icon)),
    expectIcon ? findsOneWidget : findsNothing,
  );
}

List<Text> _metricTexts(WidgetTester tester, RecordMetricKind kind) {
  return tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(kind.dashboardKey),
          matching: find.byType(Text),
        ),
      )
      .toList(growable: false);
}

Future<void> _pumpRecordStatisticsPanel(
  WidgetTester tester,
  Size size, {
  ThemeData? theme,
  bool includeProjectDates = false,
  bool includeAdditionalCategoryValues = false,
  TextScaler textScaler = TextScaler.noScaling,
  bool showMetrics = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  addTearDown(database.close);
  const projectUuid = 'record-statistics-project';

  await database
      .into(database.project)
      .insert(
        ProjectCompanion(
          uuid: const Value(projectUuid),
          name: const Value('Record Statistics Project'),
          startDate: includeProjectDates
              ? const Value('2026-01-10')
              : const Value.absent(),
          endDate: includeProjectDates
              ? const Value('2026-01-12')
              : const Value.absent(),
        ),
      );
  final myotis = await database
      .into(database.taxonomy)
      .insert(
        const TaxonomyCompanion(
          taxonFamily: Value('Vespertilionidae'),
          genus: Value('Myotis'),
          specificEpithet: Value('lucifugus'),
        ),
      );
  final eptesicus = await database
      .into(database.taxonomy)
      .insert(
        const TaxonomyCompanion(
          taxonFamily: Value('Vespertilionidae'),
          genus: Value('Eptesicus'),
          specificEpithet: Value('fuscus'),
        ),
      );
  await database.batch((batch) {
    batch.insertAll(database.site, [
      SiteCompanion(
        siteID: const Value('Site Alpha'),
        projectUuid: Value(projectUuid),
      ),
      SiteCompanion(
        siteID: const Value('Site Beta'),
        projectUuid: Value(projectUuid),
      ),
    ]);
    batch.insertAll(database.collEvent, [
      CollEventCompanion(
        projectUuid: Value(projectUuid),
        startDate: const Value('2026-01-10'),
        endDate: const Value('2026-01-10'),
      ),
      CollEventCompanion(
        projectUuid: Value(projectUuid),
        startDate: const Value('2026-01-11'),
        endDate: const Value('2026-01-11'),
      ),
      CollEventCompanion(projectUuid: Value(projectUuid)),
    ]);
    batch.insertAll(database.specimen, [
      SpecimenCompanion(
        uuid: const Value('record-specimen-1'),
        projectUuid: const Value(projectUuid),
        speciesID: Value(myotis),
        captureDate: const Value('2026-01-10'),
      ),
      SpecimenCompanion(
        uuid: const Value('record-specimen-2'),
        projectUuid: const Value(projectUuid),
        speciesID: Value(myotis),
        captureDate: const Value(' 2026-01-10 '),
      ),
      SpecimenCompanion(
        uuid: const Value('record-specimen-3'),
        projectUuid: const Value(projectUuid),
        speciesID: Value(eptesicus),
        captureDate: const Value('2026-01-11'),
      ),
      const SpecimenCompanion(
        uuid: Value('record-specimen-4'),
        projectUuid: Value(projectUuid),
      ),
    ]);
    batch.insertAll(database.narrative, [
      NarrativeCompanion(projectUuid: Value(projectUuid)),
      NarrativeCompanion(projectUuid: Value(projectUuid)),
      NarrativeCompanion(projectUuid: Value(projectUuid)),
      NarrativeCompanion(projectUuid: Value(projectUuid)),
      NarrativeCompanion(projectUuid: Value(projectUuid)),
    ]);
  });

  final projectSites = await (database.select(
    database.site,
  )..where((site) => site.projectUuid.equals(projectUuid))).get();
  final projectEvents = await (database.select(
    database.collEvent,
  )..where((event) => event.projectUuid.equals(projectUuid))).get();
  await (database.update(database.collEvent)
        ..where((event) => event.id.equals(projectEvents[0].id)))
      .write(CollEventCompanion(siteID: Value(projectSites.first.id)));
  await (database.update(database.collEvent)
        ..where((event) => event.id.equals(projectEvents[1].id)))
      .write(CollEventCompanion(siteID: Value(projectSites.last.id)));
  await (database.update(database.collEvent)
        ..where((event) => event.id.equals(projectEvents[2].id)))
      .write(CollEventCompanion(siteID: Value(projectSites.first.id)));
  final method = await database
      .into(database.collEffort)
      .insert(
        CollEffortCompanion(
          eventID: Value(projectEvents.first.id),
          method: const Value('Mist net'),
        ),
      );
  for (final entry in [
    ('record-specimen-1', projectEvents[0].id, method),
    ('record-specimen-2', projectEvents[0].id, method),
    ('record-specimen-3', projectEvents[1].id, null),
    ('record-specimen-4', projectEvents[2].id, null),
  ]) {
    await (database.update(
      database.specimen,
    )..where((specimen) => specimen.uuid.equals(entry.$1))).write(
      SpecimenCompanion(
        collEventID: Value(entry.$2),
        collMethodID: Value(entry.$3),
      ),
    );
  }
  await database.batch((batch) {
    batch.insertAll(database.coordinate, [
      CoordinateCompanion(
        elevationInMeter: const Value(120.5),
        siteID: Value(projectSites.first.id),
      ),
      CoordinateCompanion(
        elevationInMeter: const Value(350.25),
        siteID: Value(projectSites.last.id),
      ),
    ]);
    batch.insertAll(database.mammalAttribute, const [
      MammalAttributeCompanion(
        specimenUuid: Value('record-specimen-1'),
        sex: Value(0),
        lifeStage: Value('Adult'),
      ),
      MammalAttributeCompanion(
        specimenUuid: Value('record-specimen-2'),
        sex: Value(1),
        lifeStage: Value('Adult'),
      ),
      MammalAttributeCompanion(
        specimenUuid: Value('record-specimen-3'),
        sex: Value(2),
        lifeStage: Value('Juvenile'),
      ),
    ]);
  });

  if (includeAdditionalCategoryValues) {
    final additionalMethods = <int>[];
    for (final methodName in const [
      'Hand capture',
      'Light trap',
      'Cage trap',
      'Malaise trap',
    ]) {
      additionalMethods.add(
        await database
            .into(database.collEffort)
            .insert(
              CollEffortCompanion(
                eventID: Value(projectEvents.first.id),
                method: Value(methodName),
              ),
            ),
      );
    }
    await database.batch((batch) {
      for (var index = 0; index < additionalMethods.length; index++) {
        batch.insert(
          database.specimen,
          SpecimenCompanion(
            uuid: Value('record-statistics-extra-${index + 1}'),
            projectUuid: const Value(projectUuid),
            speciesID: Value(myotis),
            collEventID: Value(projectEvents.first.id),
            collMethodID: Value(additionalMethods[index]),
          ),
        );
      }
      batch.insertAll(database.mammalAttribute, const [
        MammalAttributeCompanion(
          specimenUuid: Value('record-statistics-extra-1'),
          sex: Value(3),
          lifeStage: Value('Larva'),
        ),
        MammalAttributeCompanion(
          specimenUuid: Value('record-statistics-extra-2'),
          sex: Value(4),
          lifeStage: Value('Pupa'),
        ),
        MammalAttributeCompanion(
          specimenUuid: Value('record-statistics-extra-3'),
          sex: Value(5),
          lifeStage: Value('Egg'),
        ),
        MammalAttributeCompanion(
          specimenUuid: Value('record-statistics-extra-4'),
          sex: Value(6),
          lifeStage: Value('Nymph'),
        ),
      ]);
    });
  }

  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(database)],
  );
  addTearDown(container.dispose);
  container.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const Scaffold(body: StatisticViewer()),
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (showMetrics) {
    await _toggleRecordPanelView(tester);
  }
}

Future<void> _toggleRecordPanelView(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('record-statistics-view-toggle')));
  await tester.pumpAndSettle();
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
