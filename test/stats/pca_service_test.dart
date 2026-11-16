import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/analytics_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/statistics/pca_export.dart';
import 'package:nahpu/services/statistics/pca_service.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/services/types/export.dart';

import '../helpers/rust_library.dart';

const _totalLength = AnalyticsVariable.column(MeasurementColumn.totalLength);
const _tailLength = AnalyticsVariable.column(MeasurementColumn.tailLength);
const _earLength = AnalyticsVariable.column(MeasurementColumn.earLength);

/// Total and tail lengths with a correlation of 0.8, so a standardized
/// analysis has eigenvalues 1.8 and 0.2.
const _lengths = [
  (10.0, 20.0),
  (20.0, 10.0),
  (30.0, 40.0),
  (40.0, 30.0),
  (50.0, 50.0),
];

void main() {
  late Database db;
  late PcaService service;

  setUpAll(initRustLibForTest);

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    service = PcaService(AnalyticsQuery(db));
    await db
        .into(db.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project'),
            name: Value('Project'),
          ),
        );
    for (final (index, (total, tail)) in _lengths.indexed) {
      await _insertMammal(db, 'mammal-$index', total: total, tail: tail);
    }
  });

  tearDown(() => db.close());

  PcaRequest request(
    List<AnalyticsVariable> variables, {
    PcaScalingMode scaling = PcaScalingMode.correlation,
  }) => PcaRequest(
    projectUuid: 'project',
    taxonGroup: SpecimenRecordType.mammals,
    variables: variables,
    scaling: scaling,
  );

  test('analysis matches the hand-computed components', () async {
    final result = await service.run(request([_totalLength, _tailLength]));

    expect(result.records, hasLength(5));
    expect(result.excludedCount, 0);
    expect(result.eigenvalues[0], closeTo(1.8, 1e-9));
    expect(result.eigenvalues[1], closeTo(0.2, 1e-9));
    expect(result.explainedVariance[0], closeTo(0.9, 1e-9));
    expect(result.cumulativeVariance[1], closeTo(1, 1e-9));
    expect(result.loadings[0][0], closeTo(0.7071067811865476, 1e-9));
    expect(result.correlations[0][1], closeTo(0.8, 1e-9));
    expect(result.scores, hasLength(5));
    expect(result.summaries[0].count, 5);
    expect(result.summaries[0].mean, closeTo(30, 1e-9));
    expect(result.summaries[0].median, closeTo(30, 1e-9));
  });

  test('covariance scaling keeps the original variances', () async {
    final result = await service.run(
      request([_totalLength, _tailLength], scaling: PcaScalingMode.covariance),
    );

    expect(result.eigenvalues[0], closeTo(450, 1e-6));
    expect(result.eigenvalues[1], closeTo(50, 1e-6));
  });

  test('records with a missing value are excluded and reported', () async {
    await _insertMammal(db, 'mammal-missing', total: 60);

    final result = await service.run(request([_totalLength, _tailLength]));

    expect(result.excludedCount, 1);
    expect(
      result.records.map((record) => record.specimenUuid),
      isNot(contains('mammal-missing')),
    );
    // The summary still counts the value the analysis could not use.
    expect(result.summaries[0].count, 6);
    expect(result.summaries[1].missing, 1);
    expect(result.eigenvalues[0], closeTo(1.8, 1e-9));
  });

  test('too few complete records is a typed failure', () async {
    final run = service.run(request([_totalLength, _earLength]));

    await expectLater(
      run,
      throwsA(
        isA<PcaFailure>()
            .having((e) => e.kind, 'kind', PcaFailureKind.tooFewRecords)
            .having((e) => e.completeCount, 'completeCount', 0)
            .having((e) => e.minimum, 'minimum', 3),
      ),
    );
  });

  test('a constant variable is named in the failure', () async {
    await db
        .update(db.mammalAttribute)
        .write(const MammalAttributeCompanion(earLength: Value(12)));

    await expectLater(
      service.run(request([_totalLength, _earLength])),
      throwsA(
        isA<PcaFailure>()
            .having((e) => e.kind, 'kind', PcaFailureKind.constantVariable)
            .having((e) => e.variable, 'variable', _earLength),
      ),
    );
  });

  test('a single variable fails before any data is read', () async {
    await expectLater(
      service.run(request([_totalLength])),
      throwsA(
        isA<PcaFailure>().having(
          (e) => e.kind,
          'kind',
          PcaFailureKind.tooFewVariables,
        ),
      ),
    );
  });

  test('export tables line up with the result', () async {
    final result = await service.run(request([_totalLength, _tailLength]));
    final export = PcaExportBuilder(result);
    final scores = export.scores();
    final loadings = export.loadings();
    final summary = export.summary();

    expect(scores.headers.sublist(9), [
      'totalLength (mm)',
      'tailLength (mm)',
      'PC1',
      'PC2',
    ]);
    expect(scores.rows, hasLength(5));
    expect(scores.rows.first.first, 'mammal-0');
    expect(
      scores.rows.every((row) => row.length == scores.headers.length),
      true,
    );
    expect(loadings.headers, ['Variable', 'PC1', 'PC2']);
    expect(loadings.rows.map((row) => row.first), [
      'totalLength (mm)',
      'tailLength (mm)',
      'Eigenvalue',
      'Variance explained (%)',
      'Cumulative variance (%)',
    ]);
    expect(loadings.rows[3][1], '90.000000');
    expect(summary.rows.first.sublist(0, 4), [
      'totalLength (mm)',
      '5',
      '0',
      '30.000000',
    ]);
  });
}

Future<void> _insertMammal(
  Database db,
  String uuid, {
  required double total,
  double? tail,
}) async {
  await db
      .into(db.specimen)
      .insert(
        SpecimenCompanion(
          uuid: Value(uuid),
          projectUuid: const Value('project'),
          taxonGroup: const Value('Mammals'),
        ),
      );
  await db
      .into(db.mammalAttribute)
      .insert(
        MammalAttributeCompanion(
          specimenUuid: Value(uuid),
          totalLength: Value(total),
          tailLength: Value(tail),
        ),
      );
}
