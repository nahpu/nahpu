import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/statistics.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/analytics.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/analytics.dart';

const _projectUuid = 'analytics-project';

void main() {
  testWidgets('Analytics runs a PCA on the default measurements', (
    tester,
  ) async {
    final requests = await _pumpAnalytics(tester);

    expect(find.byKey(const ValueKey('analytics-results')), findsOneWidget);
    expect(find.byType(ScatterChart), findsOneWidget);
    expect(find.byKey(const ValueKey('analytics-scree-plot')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('analytics-summary-table')),
      findsOneWidget,
    );
    // Total length, tail length, and weight have data; ear length has none.
    expect(requests.last.projectUuid, _projectUuid);
    expect(requests.last.variables.map((variable) => variable.id), [
      'totalLength',
      'tailLength',
      'weight',
    ]);
    expect(find.text('Total length (mm) (4)'), findsOneWidget);
    expect(_chip(tester, 'earLength').onSelected, isNull);
    expect(_chip(tester, 'totalLength').selected, isTrue);
    // Species color the points by default.
    expect(find.text('Rattus rattus'), findsWidgets);
  });

  testWidgets('fewer than two variables asks for a selection', (tester) async {
    final requests = await _pumpAnalytics(tester);
    final runs = requests.length;

    await _tapChip(tester, 'weight');
    expect(requests.last.variables.map((variable) => variable.id), [
      'totalLength',
      'tailLength',
    ]);
    await _tapChip(tester, 'tailLength');

    expect(
      find.byKey(const ValueKey('analytics-select-variables')),
      findsOneWidget,
    );
    expect(
      find.text('Select at least two variables to run the analysis.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('analytics-results')), findsNothing);
    // One run for the two-variable selection, none for the single variable.
    expect(requests, hasLength(runs + 1));
  });

  testWidgets('scaling and log options are part of the request', (
    tester,
  ) async {
    final requests = await _pumpAnalytics(tester);

    await tester.tap(find.text('Raw variance'));
    await tester.pumpAndSettle();
    final logChip = find.byKey(const ValueKey('analytics-log-transform'));
    await tester.ensureVisible(logChip);
    await tester.tap(logChip);
    await tester.pumpAndSettle();

    expect(requests.last.scaling, PcaScalingMode.covariance);
    expect(requests.last.logTransform, isTrue);
  });

  testWidgets('the database-wide view analyzes every project', (tester) async {
    final requests = await _pumpAnalytics(tester, allProjects: true);

    expect(find.byKey(const ValueKey('analytics-results')), findsOneWidget);
    expect(requests.last.projectUuid, isNull);
    // The second project adds one more measured specimen.
    expect(find.text('Total length (mm) (5)'), findsOneWidget);
  });

  testWidgets('an analysis failure explains what to change', (tester) async {
    await _pumpAnalytics(
      tester,
      failure: const PcaFailure(
        PcaFailureKind.tooFewRecords,
        completeCount: 2,
        minimum: 3,
      ),
    );

    expect(find.byKey(const ValueKey('analytics-failure')), findsOneWidget);
    expect(
      find.textContaining('Only 2 records have a value for every selected'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('analytics-results')), findsNothing);
  });

  testWidgets('Analytics fits a phone-width screen', (tester) async {
    await _pumpAnalytics(tester, size: const Size(390, 844));

    expect(find.byKey(const ValueKey('analytics-results')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

FilterChip _chip(WidgetTester tester, String variable) =>
    tester.widget(find.byKey(ValueKey('analytics-variable-$variable')));

Future<void> _tapChip(WidgetTester tester, String variable) async {
  final chip = find.byKey(ValueKey('analytics-variable-$variable'));
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

/// Opens the statistics page on Analytics and returns the analyses it asks
/// for, in order. The analysis itself is replaced: Rust runs in the service
/// tests.
Future<List<PcaRequest>> _pumpAnalytics(
  WidgetTester tester, {
  bool allProjects = false,
  PcaFailure? failure,
  Size size = const Size(1400, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  addTearDown(database.close);
  await _seed(database);

  final requests = <PcaRequest>[];
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      pcaResultProvider.overrideWith((ref, request) {
        requests.add(request);
        if (failure != null) throw failure;
        return _result(request);
      }),
    ],
  );
  addTearDown(container.dispose);
  container.read(projectUuidProvider.notifier).updateProjectUuid(_projectUuid);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: StatisticFullScreen(allProjects: allProjects)),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Analytics'));
  await tester.pumpAndSettle();
  return requests;
}

/// A plausible result for [request]: four records and one component per
/// variable, with shares of variance that halve from one to the next.
PcaAnalysisResult _result(PcaRequest request) {
  final count = request.variables.length;
  final weights = [
    for (var index = 0; index < count; index++) 1 / (1 << index),
  ];
  final total = weights.reduce((sum, weight) => sum + weight);
  final explained = [for (final weight in weights) weight / total];
  var running = 0.0;
  return PcaAnalysisResult(
    variables: request.variables,
    records: [
      for (var index = 0; index < 4; index++)
        AnalyticsRecord(
          specimenUuid: 'specimen-$index',
          fieldNumber: index + 1,
          values: List.filled(count, 10.0 + index),
          species: index.isEven ? 'Rattus rattus' : 'Mus musculus',
          genus: index.isEven ? 'Rattus' : 'Mus',
          family: 'Muridae',
          sex: index < 2 ? 'Male' : 'Female',
          lifeStage: 'Adult',
          site: 'Camp 1',
          project: 'Analytics Project',
        ),
    ],
    excludedCount: 1,
    summaries: List.filled(
      count,
      const AnalyticsColumnSummary(
        count: 5,
        missing: 0,
        mean: 12,
        standardDeviation: 1.5,
        min: 10,
        max: 14,
        median: 12,
      ),
    ),
    eigenvalues: [for (final share in explained) share * count],
    explainedVariance: explained,
    cumulativeVariance: [for (final share in explained) running += share],
    loadings: [
      for (var variable = 0; variable < count; variable++)
        [
          for (var component = 0; component < count; component++)
            variable == component ? 0.8 : -0.3,
        ],
    ],
    scores: [
      for (var record = 0; record < 4; record++)
        [
          for (var component = 0; component < count; component++)
            (record - 1.5) * (component.isEven ? 1 : -0.5),
        ],
    ],
    correlations: [
      for (var row = 0; row < count; row++)
        [
          for (var column = 0; column < count; column++)
            row == column ? 1 : 0.5,
        ],
    ],
  );
}

Future<void> _seed(Database database) async {
  await database.batch((batch) {
    batch.insertAll(database.project, const [
      ProjectCompanion(
        uuid: Value(_projectUuid),
        name: Value('Analytics Project'),
      ),
      ProjectCompanion(uuid: Value('other-project'), name: Value('Other')),
    ]);
  });
  for (var index = 0; index < 5; index++) {
    final uuid = 'mammal-$index';
    await database
        .into(database.specimen)
        .insert(
          SpecimenCompanion(
            uuid: Value(uuid),
            // The last specimen belongs to the other project.
            projectUuid: Value(index < 4 ? _projectUuid : 'other-project'),
            taxonGroup: const Value('Mammals'),
          ),
        );
    await database
        .into(database.mammalAttribute)
        .insert(
          MammalAttributeCompanion(
            specimenUuid: Value(uuid),
            totalLength: Value(200.0 + index * 7),
            tailLength: Value(90.0 + index * 3),
            weight: Value(100.0 + index * 11),
            weightUnit: const Value('g'),
          ),
        );
  }
}
