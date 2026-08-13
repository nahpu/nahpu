import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/statistics.dart';

class StatisticBarChart extends StatelessWidget {
  static const _compactSlotWidth = 80.0;
  static const _detailSlotWidth = 112.0;
  static const _leftAxisWidth = 42.0;
  static const _horizontalChartPadding = 16.0;

  const StatisticBarChart({
    super.key,
    required this.data,
    this.kind,
    this.compact = false,
    this.height = 300,
  });

  final List<StatisticDatum> data;
  final StatisticKind? kind;
  final bool compact;
  final double height;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = math.max(
          constraints.maxWidth,
          minimumWidth(categoryCount: data.length, compact: compact),
        );
        return SizedBox(
          height: height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              child: Semantics(
                label: data
                    .map((datum) => '${datum.label}: ${datum.count}')
                    .join(', '),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 24, 12, 0),
                  child: BarChart(_chartData(context)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BarChartData _chartData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maximum =
        data.fold<int>(0, (value, datum) => math.max(value, datum.count));
    final maxY = maximum == 0 ? 1.0 : maximum * 1.22;

    return BarChartData(
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      barGroups: [
        for (var index = 0; index < data.length; index++)
          BarChartGroupData(
            x: index,
            showingTooltipIndicators: const [0],
            barRods: [
              BarChartRodData(
                toY: data[index].count.toDouble(),
                width: compact ? 22 : 30,
                color: colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
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
        getDrawingHorizontalLine: (value) => FlLine(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          strokeWidth: 2,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              if (value != value.roundToDouble()) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
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
              if (index < 0 || index >= data.length) {
                return const SizedBox.shrink();
              }
              final datum = data[index];
              return SideTitleWidget(
                meta: meta,
                space: 8,
                child: Semantics(
                  label: '${datum.label}, ${datum.count}',
                  child: Tooltip(
                    message: datum.label,
                    child: SizedBox(
                      width: compact ? _compactSlotWidth : _detailSlotWidth,
                      child: _StatisticAxisLabel(
                        label: datum.label,
                        isSpecies: kind?.displaysSpeciesCategories ?? false,
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
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          tooltipMargin: 5,
          tooltipBorderRadius: BorderRadius.circular(8),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (_) => colorScheme.surfaceContainerHighest,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final datum = data[group.x];
            return BarTooltipItem(
              datum.count.toString(),
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
