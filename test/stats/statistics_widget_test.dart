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
    expect(find.text('Project Statistics'), findsOneWidget);
    expect(find.text('Species counts'), findsWidgets);
  });

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

void _expectRecordSummaryColors(WidgetTester tester, ThemeData theme) {
  final hero = tester.widget<Container>(
    find.byKey(const ValueKey('record-stat-specimens')),
  );
  final heroDecoration = hero.decoration! as BoxDecoration;
  final primaryForeground = theme.colorScheme.onPrimaryContainer;
  final primaryBackground = theme.colorScheme.primaryContainer.withValues(
    alpha: 0.16,
  );
  expect(heroDecoration.color, primaryBackground);
  for (final text in tester.widgetList<Text>(
    find.descendant(
      of: find.byKey(const ValueKey('record-stat-specimens')),
      matching: find.byType(Text),
    ),
  )) {
    expect(text.style?.color, primaryForeground);
    expect(text.textAlign, TextAlign.center);
  }
  expect(
    _contrastRatio(
      primaryForeground,
      Color.alphaBlend(primaryBackground, theme.colorScheme.surface),
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
        const ProjectCompanion(
          uuid: Value(projectUuid),
          name: Value('Record Statistics Project'),
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
      SiteCompanion(projectUuid: Value(projectUuid)),
      SiteCompanion(projectUuid: Value(projectUuid)),
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
      ),
      SpecimenCompanion(
        uuid: const Value('record-specimen-2'),
        projectUuid: const Value(projectUuid),
        speciesID: Value(myotis),
      ),
      SpecimenCompanion(
        uuid: const Value('record-specimen-3'),
        projectUuid: const Value(projectUuid),
        speciesID: Value(eptesicus),
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
