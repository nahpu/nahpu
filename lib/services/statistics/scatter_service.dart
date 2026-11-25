import 'dart:math' as math;

import 'package:nahpu/services/database/analytics_queries.dart';
import 'package:nahpu/services/statistics/pca_export.dart';
import 'package:nahpu/services/statistics/pca_service.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/src/rust/api/analytics.dart';

/// Builds scatter plots of one specimen measurement against another.
class ScatterService {
  const ScatterService(this._query);

  final AnalyticsQuery _query;

  /// Plots the records matching [request].
  ///
  /// Like the principal component analysis, zero and negative values count
  /// as missing, so both plots cover the same records.
  Future<ScatterResult> run(ScatterRequest request) async {
    final records = await _query.fetchRecords(request.recordRequest);
    // The same Rust statistics as the PCA summary, so both tables agree.
    final summaries = await MeasurementSummary(
      rows: [for (final record in records) record.values],
    ).run();
    return build(
      request,
      records,
      summaries: summaries.map(PcaService.columnSummary).toList(),
    );
  }

  /// The plot of [records], whose values are in `x`, `y` order, with the
  /// [summaries] of both variables.
  static ScatterResult build(
    ScatterRequest request,
    List<AnalyticsRecord> records, {
    List<AnalyticsColumnSummary> summaries = const [],
  }) {
    final kept = <AnalyticsRecord>[];
    final points = <({double x, double y})>[];
    for (final record in records) {
      final x = _usable(record.values[0], request.logTransform);
      final y = _usable(record.values[1], request.logTransform);
      if (x == null || y == null) continue;
      kept.add(record);
      points.add((x: x, y: y));
    }
    return ScatterResult(
      request: request,
      records: kept,
      points: points,
      excludedCount: records.length - kept.length,
      summaries: summaries,
      correlation: pearson(points),
    );
  }

  /// Pearson correlation of [points], or null when it is undefined.
  static double? pearson(List<({double x, double y})> points) {
    if (points.length < 2) return null;
    final count = points.length;
    final meanX = points.fold(0.0, (sum, point) => sum + point.x) / count;
    final meanY = points.fold(0.0, (sum, point) => sum + point.y) / count;
    var covariance = 0.0;
    var varianceX = 0.0;
    var varianceY = 0.0;
    for (final point in points) {
      final dx = point.x - meanX;
      final dy = point.y - meanY;
      covariance += dx * dy;
      varianceX += dx * dx;
      varianceY += dy * dy;
    }
    if (varianceX == 0 || varianceY == 0) return null;
    return (covariance / math.sqrt(varianceX * varianceY)).clamp(-1.0, 1.0);
  }

  static double? _usable(double? value, bool logTransform) {
    if (value == null || !value.isFinite || value <= 0) return null;
    return logTransform ? math.log(value) : value;
  }
}

/// Builds the export table of a scatter plot.
///
/// Headers are English and unit-qualified, like the PCA exports.
class ScatterExportBuilder {
  const ScatterExportBuilder(this.result);

  final ScatterResult result;

  /// One row per variable with its descriptive statistics, like the PCA
  /// summary export.
  PcaExportTable summary() => PcaExportBuilder.summaryTable([
    result.request.x,
    result.request.y,
  ], result.summaries);

  /// One row per plotted record: its identity and both plotted values.
  PcaExportTable points() {
    final request = result.request;
    String header(AnalyticsVariable variable) {
      final name = PcaExportBuilder.variableHeader(variable);
      return request.logTransform ? 'ln $name' : name;
    }

    return (
      headers: [
        'Specimen UUID',
        'Field number',
        'Project',
        'Species',
        'Genus',
        'Family',
        'Sex',
        'Life stage',
        'Site',
        header(request.x),
        header(request.y),
      ],
      rows: [
        for (final (index, record) in result.records.indexed)
          [
            record.specimenUuid,
            record.fieldNumber?.toString() ?? '',
            record.project,
            record.species,
            record.genus,
            record.family,
            record.sex,
            record.lifeStage,
            record.site,
            result.points[index].x.toStringAsFixed(6),
            result.points[index].y.toStringAsFixed(6),
          ],
      ],
    );
  }
}
