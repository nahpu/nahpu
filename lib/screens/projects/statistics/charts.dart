import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

const _chartTopPadding = 24.0;

/// Called when a chart element is tapped, with the group's label and, for a
/// stacked bar segment, its series label.
typedef StatisticSelectCallback =
    void Function(String label, String? seriesLabel);

class StatisticBarChart extends StatelessWidget {
  static const _compactSlotWidth = 80.0;
  static const _detailSlotWidth = 112.0;
  static const _leftAxisWidth = 64.0;
  static const _horizontalChartPadding = 16.0;
  static const _maximumYAxisIntervals = 4;

  const StatisticBarChart({
    super.key,
    required this.data,
    this.measure = StatisticMeasure.specimens,
    this.group,
    this.rank,
    this.breakdown,
    this.compact = false,
    this.height = 300,
    this.fitHeight = false,
    this.onSelect,
  });

  final List<StatisticDatum> data;
  final StatisticMeasure measure;
  final StatisticGroup? group;

  /// Rank the data is grouped by, when [group] is [StatisticGroup.taxonRank].
  final StatisticTaxonRank? rank;
  final StatisticBreakdown? breakdown;
  final bool compact;
  final double height;
  final bool fitHeight;

  /// Opens the records behind a tapped bar, segment, or axis label.
  final StatisticSelectCallback? onSelect;

  static double minimumWidth({
    required int categoryCount,
    required bool compact,
  }) {
    final slotWidth = compact ? _compactSlotWidth : _detailSlotWidth;
    return _leftAxisWidth + _horizontalChartPadding + categoryCount * slotWidth;
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text(context.l10n.projectStatsNoData)),
      );
    }

    final categories = _categories();
    final chartHeight = fitHeight && breakdown != null
        ? math.max(0, height - 64).toDouble()
        : height;
    final chart = LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = math.max(
          constraints.maxWidth,
          minimumWidth(categoryCount: categories.length, compact: compact),
        );
        return SizedBox(
          height: chartHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              child: Semantics(
                label: _semanticLabel(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    4,
                    _chartTopPadding,
                    12,
                    0,
                  ),
                  child: BarChart(_chartData(context, categories)),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (breakdown == null) return chart;
    if (fitHeight) {
      return SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            chart,
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: _StatisticLegend(
                  labels: _seriesLabels(categories),
                  colors: _chartColors(Theme.of(context).colorScheme),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        chart,
        const SizedBox(height: 8),
        _StatisticLegend(
          labels: _seriesLabels(categories),
          colors: _chartColors(Theme.of(context).colorScheme),
        ),
      ],
    );
  }

  BarChartData _chartData(
    BuildContext context,
    List<_StatisticCategory> categories,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = _chartColors(colorScheme);
    final seriesLabels = _seriesLabels(categories);
    final maximum = categories.fold<int>(
      0,
      (value, category) => math.max(value, category.total),
    );
    final maxY = maximum == 0 ? 1.0 : maximum * 1.22;
    final yAxisInterval = _yAxisInterval(maximum);
    // A species count can't be summed across groups, so it gets no share.
    final grandTotal = measure == StatisticMeasure.species
        ? 0
        : categories.fold<int>(0, (sum, category) => sum + category.total);
    final select = onSelect;

    return BarChartData(
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      barGroups: [
        for (var index = 0; index < categories.length; index++)
          BarChartGroupData(
            x: index,
            showingTooltipIndicators: const [0],
            barRods: [
              _barRod(categories[index], colors, seriesLabels, colorScheme),
            ],
          ),
      ],
      borderData: FlBorderData(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
          left: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: yAxisInterval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          strokeWidth: 2,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          axisNameSize: 18,
          axisNameWidget: Text(
            measure.localizedCountLabel(context.l10n),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: yAxisInterval,
            maxIncluded: false,
            getTitlesWidget: (value, meta) {
              if (value != value.roundToDouble()) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  key: ValueKey('statistics-y-axis-${value.toInt()}'),
                  value.toInt().toString(),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: compact ? 58 : 68,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= categories.length) {
                return const SizedBox.shrink();
              }
              final category = categories[index];
              return SideTitleWidget(
                meta: meta,
                space: 8,
                child: Semantics(
                  label: '${category.label}, ${category.total}',
                  button: select != null,
                  child: Tooltip(
                    message: select == null
                        ? category.label
                        : context.l10n.projectStatsTapToView(category.label),
                    child: _StatisticTapTarget(
                      onTap: select == null
                          ? null
                          : () => select(category.label, null),
                      child: SizedBox(
                        width: compact ? _compactSlotWidth : _detailSlotWidth,
                        child: _StatisticAxisLabel(
                          label: category.label,
                          isSpecies: italicizesCategories(group, rank),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchCallback: select == null
            ? null
            : (event, response) {
                final spot = response?.spot;
                if (event is! FlTapUpEvent || spot == null) return;
                final index = spot.touchedBarGroupIndex;
                if (index < 0 || index >= categories.length) return;
                final category = categories[index];
                select(
                  category.label,
                  _seriesAt(category, seriesLabels, spot.touchedStackItemIndex),
                );
              },
        mouseCursorResolver: select == null
            ? null
            : (_, response) => response?.spot == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          tooltipMargin: 5,
          tooltipBorderRadius: BorderRadius.circular(8),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (_) => colorScheme.surfaceContainerHighest,
          getTooltipItem: (_, groupIndex, _, _) {
            if (groupIndex < 0 || groupIndex >= categories.length) {
              return null;
            }
            final category = categories[groupIndex];
            final share = grandTotal == 0 || compact
                ? ''
                : ' · ${_percent(category.total, grandTotal)}';
            return BarTooltipItem(
              '${category.total}$share',
              TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ),
    );
  }

  BarChartRodData _barRod(
    _StatisticCategory category,
    List<Color> colors,
    List<String> seriesLabels,
    ColorScheme colorScheme,
  ) {
    if (breakdown == null) {
      return BarChartRodData(
        toY: category.total.toDouble(),
        width: compact ? 22 : 30,
        color: colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      );
    }
    var start = 0.0;
    final stacks = <BarChartRodStackItem>[];
    for (final label in seriesLabels) {
      final count = category.series[label] ?? 0;
      if (count == 0) continue;
      final end = start + count;
      stacks.add(
        BarChartRodStackItem(
          start,
          end,
          colors[seriesLabels.indexOf(label) % colors.length],
        ),
      );
      start = end;
    }
    return BarChartRodData(
      toY: category.total.toDouble(),
      width: compact ? 22 : 30,
      rodStackItems: stacks,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
    );
  }

  /// Series of the stack item at [stackIndex], counting only the non-empty
  /// segments [_barRod] draws.
  String? _seriesAt(
    _StatisticCategory category,
    List<String> seriesLabels,
    int stackIndex,
  ) {
    if (breakdown == null || stackIndex < 0) return null;
    final drawn = [
      for (final label in seriesLabels)
        if ((category.series[label] ?? 0) > 0) label,
    ];
    return stackIndex < drawn.length ? drawn[stackIndex] : null;
  }

  List<_StatisticCategory> _categories() {
    final categories = <String, _StatisticCategory>{};
    for (final datum in data) {
      final category = categories.putIfAbsent(
        datum.label,
        () => _StatisticCategory(datum.label),
      );
      category.add(datum.seriesLabel, datum.count);
    }
    return categories.values.toList(growable: false);
  }

  List<String> _seriesLabels(List<_StatisticCategory> categories) {
    final labels = <String>[];
    for (final category in categories) {
      for (final label in category.series.keys) {
        if (!labels.contains(label)) labels.add(label);
      }
    }
    return labels;
  }

  String _semanticLabel() => data
      .map(
        (datum) => [
          datum.label,
          if (datum.seriesLabel != null) datum.seriesLabel,
          datum.count,
        ].join(': '),
      )
      .join(', ');

  double _yAxisInterval(int maximum) {
    if (maximum <= 0) return 1;
    return math.max(1, (maximum / _maximumYAxisIntervals).ceil()).toDouble();
  }
}

class StatisticPieChart extends StatelessWidget {
  const StatisticPieChart({
    super.key,
    required this.data,
    this.height = 280,
    this.onSelect,
  });

  /// Share of the pie radius left open in the middle, matching the compact
  /// dashboard proportions at every size.
  static const _centerSpaceRatio = 0.36;
  static const _minOuterRadius = 60.0;
  static const _pieEdgeInset = 4.0;

  final List<StatisticDatum> data;
  final double height;

  /// Opens the records behind a tapped slice or legend entry.
  final StatisticSelectCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text(context.l10n.projectStatsNoData)),
      );
    }
    final total = data.fold<int>(0, (sum, datum) => sum + datum.count);
    final select = onSelect;
    final colors = _chartColors(Theme.of(context).colorScheme);
    return Semantics(
      label: data.map((datum) => _legendLabel(datum, total)).join(', '),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            const SizedBox(height: _chartTopPadding),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final outerRadius = _outerRadius(constraints);
                  final centerSpaceRadius = outerRadius * _centerSpaceRatio;
                  return PieChart(
                    PieChartData(
                      centerSpaceRadius: centerSpaceRadius,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        enabled: select != null,
                        touchCallback: select == null
                            ? null
                            : (event, response) {
                                final index =
                                    response
                                        ?.touchedSection
                                        ?.touchedSectionIndex ??
                                    -1;
                                if (event is! FlTapUpEvent ||
                                    index < 0 ||
                                    index >= data.length) {
                                  return;
                                }
                                select(data[index].label, null);
                              },
                        mouseCursorResolver: select == null
                            ? null
                            : (_, response) =>
                                  (response
                                              ?.touchedSection
                                              ?.touchedSectionIndex ??
                                          -1) <
                                      0
                                  ? MouseCursor.defer
                                  : SystemMouseCursors.click,
                      ),
                      sections: [
                        for (var index = 0; index < data.length; index++)
                          _pieSection(
                            context,
                            data[index],
                            colors[index % colors.length],
                            total,
                            outerRadius - centerSpaceRadius,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // The legend takes only what it needs and scrolls past half the
            // chart, so long labels never push the pie out of its box.
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height / 2),
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (var index = 0; index < data.length; index++)
                      _StatisticTapTarget(
                        onTap: select == null
                            ? null
                            : () => select(data[index].label, null),
                        child: _LegendItem(
                          key: ValueKey('statistics-pie-${data[index].label}'),
                          label: _legendLabel(data[index], total),
                          color: colors[index % colors.length],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _legendLabel(StatisticDatum datum, int total) =>
      '${datum.label}: ${datum.count} (${_percent(datum.count, total)})';

  /// Radius of the whole pie, so it grows into the space the card gives it
  /// instead of staying at the compact dashboard size.
  double _outerRadius(BoxConstraints constraints) {
    final width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : _minOuterRadius * 2;
    final height = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : _minOuterRadius * 2;
    final radius = math.min(width, height) / 2 - _pieEdgeInset;
    return math.max(radius, _minOuterRadius);
  }

  PieChartSectionData _pieSection(
    BuildContext context,
    StatisticDatum datum,
    Color color,
    int total,
    double radius,
  ) {
    return PieChartSectionData(
      value: datum.count.toDouble(),
      color: color,
      radius: radius,
      title: total == 0
          ? '0%'
          : '${(datum.count * 100 / total).toStringAsFixed(0)}%',
      titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: _bestContrastTextColor(color),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Compact ranked list of the highest counts in [data].
///
/// Each row pairs a category label with its count and a proportional bar. It
/// keeps long species binomials readable inside the narrow dashboard panel,
/// where a vertical bar chart would have to scroll horizontally.
class StatisticRankedBarList extends StatelessWidget {
  static const _barHeight = 6.0;
  static const _countColumnWidth = 44.0;

  /// Vertical extent a row is allowed to claim when the list fills its box.
  ///
  /// Rows spread to fill the available height so the list sits flush against
  /// the panel actions, but only up to this much each. Beyond it a short list
  /// would drift into an airy, accidental-looking layout, so the list centers
  /// itself instead.
  static const _maxRowExtent = 52.0;

  const StatisticRankedBarList({
    super.key,
    required this.data,
    this.isSpecies = false,
    this.onSelect,
  });

  final List<StatisticDatum> data;
  final bool isSpecies;

  /// Opens the records behind a tapped row.
  final StatisticSelectCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text(context.l10n.projectStatsNoData));
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maximum = data.fold<int>(
      0,
      (value, datum) => math.max(value, datum.count),
    );
    final labelStyle = textTheme.labelLarge?.copyWith(
      color: colorScheme.onSurface,
      fontStyle: isSpecies ? FontStyle.italic : FontStyle.normal,
    );
    final countStyle = textTheme.labelLarge?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final rows = [
      for (final datum in data)
        Semantics(
          container: true,
          button: onSelect != null,
          label: '${datum.label}: ${datum.count}',
          child: Tooltip(
            message: onSelect == null
                ? datum.label
                : context.l10n.projectStatsTapToView(datum.label),
            child: _StatisticTapTarget(
              onTap: onSelect == null
                  ? null
                  : () => onSelect!(datum.label, null),
              child: Column(
                key: ValueKey('statistic-ranked-bar-${datum.label}'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          datum.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      ),
                      const SizedBox(width: NahpuSpacing.md),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: _countColumnWidth,
                        ),
                        child: Text(
                          datum.count.toString(),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          style: countStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NahpuSpacing.xs),
                  LinearProgressIndicator(
                    value: maximum == 0 ? 0 : datum.count / maximum,
                    minHeight: _barHeight,
                    borderRadius: BorderRadius.circular(NahpuRadius.xs),
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
          ),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                if (index > 0) const SizedBox(height: NahpuSpacing.lg),
                rows[index],
              ],
            ],
          );
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: rows.length * _maxRowExtent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            ),
          ),
        );
      },
    );
  }
}

class StatisticChartSwitcher extends StatefulWidget {
  const StatisticChartSwitcher({
    super.key,
    required this.data,
    required this.measure,
    required this.group,
    this.rank,
    this.breakdown,
    required this.usePieByDefault,
    this.compact = false,
    this.height = 300,
    this.fitHeight = false,
    this.toggleKey,
    this.onSelect,
  });

  final List<StatisticDatum> data;
  final StatisticMeasure measure;
  final StatisticGroup group;

  /// Rank the data is grouped by, when [group] is [StatisticGroup.taxonRank].
  final StatisticTaxonRank? rank;
  final StatisticBreakdown? breakdown;
  final bool usePieByDefault;
  final bool compact;
  final double height;
  final bool fitHeight;
  final Key? toggleKey;
  final StatisticSelectCallback? onSelect;

  @override
  State<StatisticChartSwitcher> createState() => _StatisticChartSwitcherState();
}

enum _StatisticChartView { pie, bar }

class _StatisticChartSwitcherState extends State<StatisticChartSwitcher> {
  _StatisticChartView _view = _StatisticChartView.pie;

  @override
  void didUpdateWidget(covariant StatisticChartSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.measure != widget.measure ||
        oldWidget.group != widget.group ||
        oldWidget.rank != widget.rank ||
        oldWidget.breakdown != widget.breakdown ||
        oldWidget.usePieByDefault != widget.usePieByDefault ||
        !_sameData(oldWidget.data, widget.data)) {
      _view = _StatisticChartView.pie;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showToggle = widget.usePieByDefault && widget.data.isNotEmpty;
    final toggle = showToggle
        ? Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              label: _view == _StatisticChartView.pie
                  ? context.l10n.projectStatsShowBarChart
                  : context.l10n.projectStatsShowPieChart,
              child: IconButton(
                key: widget.toggleKey,
                tooltip: _view == _StatisticChartView.pie
                    ? context.l10n.projectStatsShowBarChart
                    : context.l10n.projectStatsShowPieChart,
                icon: Icon(
                  _view == _StatisticChartView.pie
                      ? Icons.bar_chart_rounded
                      : Icons.pie_chart_outline,
                ),
                onPressed: () {
                  setState(
                    () => _view = _view == _StatisticChartView.pie
                        ? _StatisticChartView.bar
                        : _StatisticChartView.pie,
                  );
                },
              ),
            ),
          )
        : null;

    if (widget.fitHeight) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (toggle != null) ...[toggle, const SizedBox(height: 8)],
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildChart(constraints.maxHeight),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (toggle != null) ...[toggle, const SizedBox(height: 8)],
        _buildChart(widget.height),
      ],
    );
  }

  Widget _buildChart(double height) {
    if (widget.usePieByDefault && _view == _StatisticChartView.pie) {
      return StatisticPieChart(
        data: widget.data,
        height: height,
        onSelect: widget.onSelect,
      );
    }
    return StatisticBarChart(
      data: widget.data,
      measure: widget.measure,
      group: widget.group,
      rank: widget.rank,
      breakdown: widget.breakdown,
      compact: widget.compact,
      height: height,
      fitHeight: widget.fitHeight,
      onSelect: widget.onSelect,
    );
  }
}

bool _sameData(List<StatisticDatum> first, List<StatisticDatum> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    final firstDatum = first[index];
    final secondDatum = second[index];
    if (firstDatum.label != secondDatum.label ||
        firstDatum.count != secondDatum.count ||
        firstDatum.seriesLabel != secondDatum.seriesLabel) {
      return false;
    }
  }
  return true;
}

String _percent(int count, int total) =>
    '${(total == 0 ? 0 : count * 100 / total).toStringAsFixed(1)}%';

/// Makes [child] tappable, with a pointer cursor, only when [onTap] is set.
class _StatisticTapTarget extends StatelessWidget {
  const _StatisticTapTarget({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NahpuRadius.xs),
      child: child,
    );
  }
}

Color _bestContrastTextColor(Color background) {
  final whiteContrast = _contrastRatio(Colors.white, background);
  final blackContrast = _contrastRatio(Colors.black, background);
  return whiteContrast >= blackContrast ? Colors.white : Colors.black;
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

class _StatisticCategory {
  _StatisticCategory(this.label);

  final String label;
  final Map<String, int> series = {};
  int total = 0;

  void add(String? label, int count) {
    total += count;
    if (label != null) series[label] = (series[label] ?? 0) + count;
  }
}

class _StatisticLegend extends StatelessWidget {
  const _StatisticLegend({required this.labels, required this.colors});

  final List<String> labels;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        for (var index = 0; index < labels.length; index++)
          _LegendItem(
            label: labels[index],
            color: colors[index % colors.length],
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _StatisticAxisLabel extends StatelessWidget {
  const _StatisticAxisLabel({
    required this.label,
    required this.isSpecies,
    required this.style,
  });

  final String label;
  final bool isSpecies;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final parts = label.trim().split(RegExp(r'\s+'));
    if (isSpecies && parts.length >= 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            parts.first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: style,
          ),
          Text(
            parts.skip(1).join(' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: style,
          ),
        ],
      );
    }

    return Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style,
    );
  }
}

List<Color> _chartColors(ColorScheme colorScheme) => [
  colorScheme.primary,
  colorScheme.secondary,
  colorScheme.tertiary,
  colorScheme.error,
  colorScheme.inversePrimary,
  colorScheme.primaryContainer,
  colorScheme.secondaryContainer,
  colorScheme.tertiaryContainer,
];
