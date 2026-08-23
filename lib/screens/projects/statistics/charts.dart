import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/statistics.dart';

const _chartTopPadding = 24.0;

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
    this.breakdown,
    this.compact = false,
    this.height = 300,
    this.fitHeight = false,
  });

  final List<StatisticDatum> data;
  final StatisticMeasure measure;
  final StatisticGroup? group;
  final StatisticBreakdown? breakdown;
  final bool compact;
  final double height;
  final bool fitHeight;

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
        child: const Center(child: Text('No data to display')),
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
            measure.countLabel,
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
                  child: Tooltip(
                    message: category.label,
                    child: SizedBox(
                      width: compact ? _compactSlotWidth : _detailSlotWidth,
                      child: _StatisticAxisLabel(
                        label: category.label,
                        isSpecies: group?.displaysSpeciesCategories ?? false,
                        style: Theme.of(context).textTheme.labelSmall,
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
            return BarTooltipItem(
              category.total.toString(),
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
  const StatisticPieChart({super.key, required this.data, this.height = 280});

  final List<StatisticDatum> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data to display')),
      );
    }
    final total = data.fold<int>(0, (sum, datum) => sum + datum.count);
    final colors = _chartColors(Theme.of(context).colorScheme);
    return Semantics(
      label: data.map((datum) => _legendLabel(datum, total)).join(', '),
      child: Column(
        children: [
          SizedBox(
            height: math.max(0, height - _chartTopPadding),
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 38,
                sectionsSpace: 2,
                sections: [
                  for (var index = 0; index < data.length; index++)
                    _pieSection(
                      context,
                      data[index],
                      colors[index % colors.length],
                      total,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              for (var index = 0; index < data.length; index++)
                _LegendItem(
                  key: ValueKey('statistics-pie-${data[index].label}'),
                  label: _legendLabel(data[index], total),
                  color: colors[index % colors.length],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _legendLabel(StatisticDatum datum, int total) {
    final percent = total == 0 ? 0 : datum.count * 100 / total;
    return '${datum.label}: ${datum.count} (${percent.toStringAsFixed(1)}%)';
  }

  PieChartSectionData _pieSection(
    BuildContext context,
    StatisticDatum datum,
    Color color,
    int total,
  ) {
    return PieChartSectionData(
      value: datum.count.toDouble(),
      color: color,
      radius: 66,
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

class StatisticChartSwitcher extends StatefulWidget {
  const StatisticChartSwitcher({
    super.key,
    required this.data,
    required this.measure,
    required this.group,
    this.breakdown,
    required this.usePieByDefault,
    this.compact = false,
    this.height = 300,
    this.fitHeight = false,
    this.toggleKey,
  });

  final List<StatisticDatum> data;
  final StatisticMeasure measure;
  final StatisticGroup group;
  final StatisticBreakdown? breakdown;
  final bool usePieByDefault;
  final bool compact;
  final double height;
  final bool fitHeight;
  final Key? toggleKey;

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
                  ? 'Show bar chart'
                  : 'Show pie chart',
              child: IconButton(
                key: widget.toggleKey,
                tooltip: _view == _StatisticChartView.pie
                    ? 'Show bar chart'
                    : 'Show pie chart',
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
      final pieHeight = widget.fitHeight && height > 32 ? height - 32 : height;
      return StatisticPieChart(data: widget.data, height: pieHeight);
    }
    return StatisticBarChart(
      data: widget.data,
      measure: widget.measure,
      group: widget.group,
      breakdown: widget.breakdown,
      compact: widget.compact,
      height: height,
      fitHeight: widget.fitHeight,
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
