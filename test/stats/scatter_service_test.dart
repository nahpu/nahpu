import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/statistics/scatter_service.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/services/types/export.dart';

const _x = AnalyticsVariable.column(MeasurementColumn.totalLength);
const _y = AnalyticsVariable.column(MeasurementColumn.weight);

void main() {
  ScatterRequest request({bool logTransform = false}) => ScatterRequest(
    projectUuid: 'project',
    taxonGroup: SpecimenRecordType.mammals,
    x: _x,
    y: _y,
    logTransform: logTransform,
  );

  test('records missing either value are left out', () {
    final result = ScatterService.build(request(), [
      _record('a', 10, 1),
      _record('b', 20, null),
      _record('c', 0, 3),
      _record('d', 30, -2),
      _record('e', 40, 4),
    ]);

    expect(result.records.map((record) => record.specimenUuid), ['a', 'e']);
    expect(result.points, [(x: 10.0, y: 1.0), (x: 40.0, y: 4.0)]);
    expect(result.excludedCount, 3);
  });

  test('the log option plots natural logs', () {
    final result = ScatterService.build(request(logTransform: true), [
      _record('a', math.e, 1),
    ]);

    expect(result.points.single.x, closeTo(1, 1e-12));
    expect(result.points.single.y, 0);
  });

  test('Pearson correlation of the plotted values', () {
    expect(
      ScatterService.pearson([(x: 1, y: 2), (x: 2, y: 4), (x: 3, y: 6)]),
      closeTo(1, 1e-12),
    );
    expect(
      ScatterService.pearson([(x: 1, y: 3), (x: 2, y: 2), (x: 3, y: 1)]),
      closeTo(-1, 1e-12),
    );
    // Undefined with one point or a constant variable.
    expect(ScatterService.pearson([(x: 1, y: 1)]), isNull);
    expect(ScatterService.pearson([(x: 1, y: 1), (x: 1, y: 2)]), isNull);
  });

  test('the export names both plotted columns', () {
    final result = ScatterService.build(request(logTransform: true), [
      _record('a', 10, 2),
    ]);
    final table = ScatterExportBuilder(result).points();

    expect(table.headers.sublist(table.headers.length - 2), [
      'ln totalLength (mm)',
      'ln weight (g)',
    ]);
    expect(table.rows.single.first, 'a');
  });
}

AnalyticsRecord _record(String uuid, double? x, double? y) => AnalyticsRecord(
  specimenUuid: uuid,
  values: [x, y],
  species: 'Rattus rattus',
  genus: 'Rattus',
  family: 'Muridae',
  sex: 'Male',
  lifeStage: 'Adult',
  site: 'Camp 1',
  project: 'Project',
);
