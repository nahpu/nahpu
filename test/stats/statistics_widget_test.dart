import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
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
    await _pumpRecordStatisticsPanel(tester, const Size(600, 600));

    expect(find.text('Record Statistics'), findsOneWidget);
    expect(find.text('Record counts'), findsNothing);
    expect(find.text('Top species'), findsNothing);
    expect(find.byType(StatisticBarChart), findsNothing);
    _expectRecordMetric(tester, 'specimens', label: 'Specimens', count: 4);
    _expectRecordMetric(tester, 'species', label: 'Species', count: 2);
    _expectRecordMetric(tester, 'families', label: 'Families', count: 1);
    _expectRecordMetric(tester, 'sites', label: 'Sites', count: 2);
    _expectRecordMetric(tester, 'events', label: 'Events', count: 3);
    _expectRecordMetric(tester, 'narratives', label: 'Narratives', count: 5);
    expect(find.text('Explore more stats'), findsOneWidget);
    expect(find.text('Open statistics'), findsNothing);
  });

  testWidgets('record statistics preserves its hierarchy on narrow panels', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(tester, const Size(280, 600));

    expect(tester.takeException(), isNull);
    final hero = tester.getRect(
      find.byKey(const ValueKey('record-stat-specimens')),
    );
    final secondary = tester.getRect(
      find.byKey(const ValueKey('record-stat-secondary')),
    );
    expect(hero.width, secondary.width);

    final specimenCount = _metricTexts(tester, 'specimens').first;
    final speciesCount = _metricTexts(tester, 'species').first;
    final siteCount = _metricTexts(tester, 'sites').first;
    expect(
      specimenCount.style!.fontSize,
      greaterThan(speciesCount.style!.fontSize!),
    );
    expect(
      speciesCount.style!.fontSize,
      greaterThan(siteCount.style!.fontSize!),
    );
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
    expect(find.byType(StatisticPieChart), findsOneWidget);
  });

  testWidgets('full-screen summary omits total days without project dates', (
    tester,
  ) async {
    await _pumpRecordStatisticsPanel(tester, const Size(599, 1200));

    await tester.tap(find.text('Explore more stats'));
    await tester.pumpAndSettle();

    expect(find.text('Project days'), findsNothing);
    expect(find.text('Capture days'), findsOneWidget);
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
    'record statistics uses accessible summary colors in light theme',
    (tester) async {
      final theme = NahpuTheme.lightTheme();
      await _pumpRecordStatisticsPanel(
        tester,
        const Size(600, 600),
        theme: theme,
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

void _expectRecordSummaryColors(WidgetTester tester, ThemeData theme) {
  final hero = tester.widget<Container>(
    find.byKey(const ValueKey('record-stat-specimens')),
  );
  final heroDecoration = hero.decoration! as BoxDecoration;
  final secondaryForeground = theme.colorScheme.onSecondaryContainer;
  final secondaryBackground = theme.colorScheme.secondaryContainer.withValues(
    alpha: 0.16,
  );
  expect(heroDecoration.color, secondaryBackground);
  for (final text in tester.widgetList<Text>(
    find.descendant(
      of: find.byKey(const ValueKey('record-stat-specimens')),
      matching: find.byType(Text),
    ),
  )) {
    expect(text.style?.color, secondaryForeground);
    expect(text.textAlign, TextAlign.center);
  }
  expect(
    _contrastRatio(
      secondaryForeground,
      Color.alphaBlend(secondaryBackground, theme.colorScheme.surface),
    ),
    greaterThanOrEqualTo(4.5),
  );

  final secondary = tester.widget<Container>(
    find.byKey(const ValueKey('record-stat-secondary')),
  );
  final secondaryDecoration = secondary.decoration! as BoxDecoration;
  expect(secondaryDecoration.color, theme.colorScheme.surfaceContainerLow);
  for (final text in tester.widgetList<Text>(
    find.descendant(
      of: find.byKey(const ValueKey('record-stat-secondary')),
      matching: find.byType(Text),
    ),
  )) {
    expect(text.style?.color, theme.colorScheme.onSurface);
    expect(text.textAlign, TextAlign.center);
  }
  expect(
    _contrastRatio(
      theme.colorScheme.onSurface,
      theme.colorScheme.surfaceContainerLow,
    ),
    greaterThanOrEqualTo(4.5),
  );
}

void _expectRecordMetric(
  WidgetTester tester,
  String key, {
  required String label,
  required int count,
}) {
  final metric = find.byKey(ValueKey('record-stat-$key'));
  expect(
    find.descendant(of: metric, matching: find.text(label)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: metric, matching: find.text(count.toString())),
    findsOneWidget,
  );
}

List<Text> _metricTexts(WidgetTester tester, String key) {
  return tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(ValueKey('record-stat-$key')),
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
      CollEventCompanion(projectUuid: Value(projectUuid)),
      CollEventCompanion(projectUuid: Value(projectUuid)),
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
        home: const Scaffold(body: StatisticViewer()),
      ),
    ),
  );
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
