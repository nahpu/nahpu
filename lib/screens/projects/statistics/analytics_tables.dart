import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/statistic_metric_strip.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/types/analytics.dart';

/// Headline numbers of an analysis: how many records it used and how much of
/// the variance the plotted components show.
class PcaMetricStrip extends StatelessWidget {
  const PcaMetricStrip({
    super.key,
    required this.result,
    required this.xComponent,
    required this.yComponent,
  });

  final PcaAnalysisResult result;
  final int xComponent;
  final int yComponent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shown =
        result.explainedVariance[xComponent] +
        (xComponent == yComponent ? 0 : result.explainedVariance[yComponent]);
    return StatisticMetricStrip(
      key: const ValueKey('analytics-metric-strip'),
      tiles: [
        StatisticMetricTile(
          value: '${result.records.length}',
          label: l10n.projectAnalyticsRecordsUsed,
        ),
        StatisticMetricTile(
          value: '${result.excludedCount}',
          label: l10n.projectAnalyticsRecordsExcluded,
        ),
        StatisticMetricTile(
          value: '${result.variables.length}',
          label: l10n.projectAnalyticsVariables,
        ),
        StatisticMetricTile(
          value: '${(shown * 100).toStringAsFixed(1)}%',
          label: l10n.projectAnalyticsVarianceShown,
        ),
      ],
    );
  }
}

/// Descriptive statistics of every analyzed variable.
class PcaSummaryTable extends StatelessWidget {
  const PcaSummaryTable({super.key, required this.result});

  final PcaAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ScrollableTable(
      key: const ValueKey('analytics-summary-table'),
      columns: [
        DataColumn(label: Text(l10n.projectAnalyticsColumnVariable)),
        for (final label in [
          l10n.projectAnalyticsColumnCount,
          l10n.projectAnalyticsColumnMissing,
          l10n.projectAnalyticsColumnMean,
          l10n.projectAnalyticsColumnSd,
          l10n.projectAnalyticsColumnMin,
          l10n.projectAnalyticsColumnMax,
          l10n.projectAnalyticsColumnMedian,
        ])
          DataColumn(label: Text(label), numeric: true),
      ],
      rows: [
        for (final (index, variable) in result.variables.indexed)
          DataRow(
            cells: [
              DataCell(Text(variable.localizedLabel(l10n))),
              DataCell(Text('${result.summaries[index].count}')),
              DataCell(Text('${result.summaries[index].missing}')),
              for (final value in [
                result.summaries[index].mean,
                result.summaries[index].standardDeviation,
                result.summaries[index].min,
                result.summaries[index].max,
                result.summaries[index].median,
              ])
                DataCell(Text(value?.toStringAsFixed(2) ?? '—')),
            ],
          ),
      ],
    );
  }
}

/// Eigenvalue and share of variance of every component.
class PcaVarianceTable extends StatelessWidget {
  const PcaVarianceTable({super.key, required this.result});

  final PcaAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ScrollableTable(
      key: const ValueKey('analytics-variance-table'),
      columns: [
        DataColumn(label: Text(l10n.projectAnalyticsComponentLabel)),
        DataColumn(label: Text(l10n.projectAnalyticsEigenvalue), numeric: true),
        DataColumn(
          label: Text(l10n.projectAnalyticsVariancePercent),
          numeric: true,
        ),
        DataColumn(
          label: Text(l10n.projectAnalyticsCumulativePercent),
          numeric: true,
        ),
      ],
      rows: [
        for (var index = 0; index < result.componentCount; index++)
          DataRow(
            cells: [
              DataCell(Text(l10n.projectAnalyticsComponent(index + 1))),
              DataCell(Text(result.eigenvalues[index].toStringAsFixed(3))),
              DataCell(
                Text(
                  (result.explainedVariance[index] * 100).toStringAsFixed(1),
                ),
              ),
              DataCell(
                Text(
                  (result.cumulativeVariance[index] * 100).toStringAsFixed(1),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// A compact data table that scrolls sideways when it is wider than its card.
class _ScrollableTable extends StatelessWidget {
  const _ScrollableTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(columns: columns, rows: rows),
        ),
      ),
    );
  }
}
