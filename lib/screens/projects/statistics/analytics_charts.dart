import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// Most groups the score plot gives a color of their own; the rest share one.
const int pcaMaxColoredGroups = 7;

/// Assigns the records of a plot to colored groups.
///
/// Groups are ordered by size, so the largest ones keep their own color when
/// there are more groups than colors.
class AnalyticsGroupPalette {
  AnalyticsGroupPalette({
    required List<AnalyticsRecord> records,
    required AnalyticsColorBy colorBy,
    required ColorScheme colorScheme,
    required String otherLabel,
  }) : _colors = NahpuTheme.categoricalColors(colorScheme),
       _neutral = colorScheme.primary {
    if (colorBy == AnalyticsColorBy.none) {
      _groupOf = List.filled(records.length, -1);
      labels = const [];
      return;
    }
    final counts = <String, int>{};
    for (final record in records) {
      final group = record.group(colorBy) ?? '';
      counts[group] = (counts[group] ?? 0) + 1;
    }
    final ordered = counts.keys.toList()
      ..sort((left, right) {
        final bySize = counts[right]!.compareTo(counts[left]!);
        return bySize != 0 ? bySize : left.compareTo(right);
      });
    final named = ordered.take(pcaMaxColoredGroups).toList();
    hasOther = ordered.length > named.length;
    labels = [...named, if (hasOther) otherLabel];
    _groupOf = [
      for (final record in records) named.indexOf(record.group(colorBy) ?? ''),
    ];
  }

  final List<Color> _colors;
  final Color _neutral;

  /// The neutral last color of the palette, shared by the smaller groups.
  Color get _other => _colors.last;
  late final List<int> _groupOf;

  /// Legend labels, the shared `other` group last.
  late final List<String> labels;

  /// Whether some groups share the last label.
  bool hasOther = false;

  /// Color of legend entry [index].
  Color legendColor(int index) =>
      hasOther && index == labels.length - 1 ? _other : _colors[index];

  /// Color of the point of record [index].
  Color recordColor(int index) {
    if (labels.isEmpty) return _neutral;
    final group = _groupOf[index];
    return group < 0 ? _other : _colors[group];
  }
}

/// Scatter plot of records, colored by a record attribute: the scores of a
/// principal component analysis, or one measurement against another.
class AnalyticsScatterChart extends StatelessWidget {
  const AnalyticsScatterChart({
    super.key,
    required this.records,
    required this.points,
    required this.xTitle,
    required this.yTitle,
    required this.colorBy,
    required this.semanticLabel,
    this.height = 440,
  });

  /// Plotted records, in the order of [points].
  final List<AnalyticsRecord> records;
  final List<({double x, double y})> points;
  final String xTitle;
  final String yTitle;
  final AnalyticsColorBy colorBy;
  final String semanticLabel;
  final double height;

  static const _dotRadius = 4.5;
  static const _axisReserved = 44.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final palette = AnalyticsGroupPalette(
      records: records,
      colorBy: colorBy,
      colorScheme: colorScheme,
      otherLabel: l10n.projectAnalyticsOtherGroups,
    );
    final spots = [
      for (final (index, point) in points.indexed)
        ScatterSpot(
          point.x,
          point.y,
          dotPainter: FlDotCirclePainter(
            radius: _dotRadius,
            color: palette.recordColor(index).withValues(alpha: 0.85),
            strokeWidth: NahpuStroke.thin,
            strokeColor: colorScheme.surface,
          ),
        ),
    ];
    final indexOf = Map<ScatterSpot, int>.identity();
    for (final (index, spot) in spots.indexed) {
      indexOf[spot] = index;
    }
    final xRange = _range(points.map((point) => point.x));
    final yRange = _range(points.map((point) => point.y));
    final xInterval = _interval(xRange.max - xRange.min);
    final yInterval = _interval(yRange.max - yRange.min);
    final axisStyle = theme.textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final gridLine = FlLine(
      color: colorScheme.outlineVariant,
      strokeWidth: NahpuStroke.thin,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: semanticLabel,
          child: SizedBox(
            key: const ValueKey('analytics-score-plot'),
            height: height,
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: spots,
                minX: xRange.min,
                maxX: xRange.max,
                minY: yRange.min,
                maxY: yRange.max,
                gridData: FlGridData(
                  horizontalInterval: yInterval,
                  verticalInterval: xInterval,
                  getDrawingHorizontalLine: (_) => gridLine,
                  getDrawingVerticalLine: (_) => gridLine,
                ),
                borderData: FlBorderData(
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    axisNameSize: NahpuSpacing.xxl,
                    axisNameWidget: Text(
                      xTitle,
                      style: theme.textTheme.labelMedium,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: NahpuSpacing.xxxl,
                      interval: xInterval,
                      getTitlesWidget: (value, meta) =>
                          _AxisTick(meta: meta, style: axisStyle),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameSize: NahpuSpacing.xxl,
                    axisNameWidget: Text(
                      yTitle,
                      style: theme.textTheme.labelMedium,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: _axisReserved,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) =>
                          _AxisTick(meta: meta, style: axisStyle),
                    ),
                  ),
                ),
                scatterTouchData: ScatterTouchData(
                  touchTooltipData: ScatterTouchTooltipData(
                    maxContentWidth: NahpuContentWidth.statisticsDetails,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipColor: (_) => colorScheme.inverseSurface,
                    getTooltipItems: (spot) {
                      final index = indexOf[spot];
                      if (index == null) return null;
                      return ScatterTooltipItem(
                        _tooltip(l10n, records[index]),
                        textStyle: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onInverseSurface,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        if (palette.labels.isNotEmpty) ...[
          const SizedBox(height: NahpuSpacing.lg),
          PcaLegend(
            key: const ValueKey('analytics-score-legend'),
            labels: palette.labels,
            colors: [
              for (var index = 0; index < palette.labels.length; index++)
                palette.legendColor(index),
            ],
          ),
        ],
      ],
    );
  }

  String _tooltip(AppLocalizations l10n, AnalyticsRecord record) {
    final group = record.group(colorBy);
    final fieldNumber = record.fieldNumber;
    return [
      record.species,
      if (fieldNumber != null) l10n.projectAnalyticsFieldNumber(fieldNumber),
      if (group != null && colorBy != AnalyticsColorBy.species) group,
    ].join('\n');
  }

  /// A round tick spacing that puts about eight ticks across [span].
  static double _interval(double span) {
    final rough = span / 8;
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor());
    final step = [1, 2, 5, 10].firstWhere((step) => step * magnitude >= rough);
    return (step * magnitude).toDouble();
  }

  /// Axis range padded so no point sits on the plot border.
  static ({double min, double max}) _range(Iterable<double> values) {
    if (values.isEmpty) return (min: 0, max: 1);
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    // A variable that does not vary gets a unit-wide span around its value.
    final padding = high > low
        ? (high - low) * 0.08
        : math.max(high.abs() * 0.1, 1.0);
    return (min: low - padding, max: high + padding);
  }
}

/// Tick label of a score axis. The padded axis ends are not round numbers,
/// so their labels are left out rather than crowding the round ones.
class _AxisTick extends StatelessWidget {
  const _AxisTick({required this.meta, required this.style});

  final TitleMeta meta;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final value = meta.axisPosition;
    final isEnd = value <= 0 || value >= meta.parentAxisSize;
    return SideTitleWidget(
      meta: meta,
      child: isEnd
          ? const SizedBox.shrink()
          : Text(meta.formattedValue, style: style),
    );
  }
}

/// Line plot of the variance each component explains, with the running total.
class PcaScreeChart extends StatelessWidget {
  const PcaScreeChart({super.key, required this.result, this.height});

  final PcaAnalysisResult result;

  /// Height of the plot, or null to fill the height left by the legend.
  final double? height;

  static const _axisReserved = 36.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final axisStyle = theme.textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    // Two hues that stay apart in both themes, unlike primary and tertiary.
    final colors = NahpuTheme.categoricalColors(colorScheme).take(2).toList();
    LineChartBarData line(
      List<double> shares,
      Color color, {
      bool dashed = false,
    }) {
      return LineChartBarData(
        spots: [
          for (final (index, share) in shares.indexed)
            FlSpot(index + 1, share * 100),
        ],
        color: color,
        barWidth: NahpuStroke.regular,
        dashArray: dashed ? const [6, 4] : null,
        dotData: const FlDotData(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FlexibleHeight(
          height: height,
          child: Semantics(
            label: l10n.projectAnalyticsScree,
            child: SizedBox(
              key: const ValueKey('analytics-scree-plot'),
              height: height,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: math.max(result.componentCount, 2).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    line(result.explainedVariance, colors[0]),
                    line(result.cumulativeVariance, colors[1], dashed: true),
                  ],
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: colorScheme.outlineVariant,
                      strokeWidth: NahpuStroke.thin,
                    ),
                  ),
                  borderData: FlBorderData(
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: NahpuSpacing.xxxl,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            l10n.projectAnalyticsComponent(value.round()),
                            style: axisStyle,
                          ),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: _axisReserved,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text('${value.round()}', style: axisStyle),
                        ),
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.inverseSurface,
                      getTooltipItems: (spots) => [
                        for (final spot in spots)
                          LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)}%',
                            (theme.textTheme.labelSmall ?? const TextStyle())
                                .copyWith(color: colorScheme.onInverseSurface),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        PcaLegend(
          labels: [
            l10n.projectAnalyticsVariancePercent,
            l10n.projectAnalyticsCumulativePercent,
          ],
          colors: colors,
        ),
      ],
    );
  }
}

/// A fixed [height], or the space its parent column has left when it is null.
class _FlexibleHeight extends StatelessWidget {
  const _FlexibleHeight({required this.height, required this.child});

  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      height == null ? Expanded(child: child) : child;
}

/// Signed bars of the loadings of every variable on one component.
class PcaLoadingsChart extends StatelessWidget {
  const PcaLoadingsChart({
    super.key,
    required this.result,
    required this.component,
  });

  final PcaAnalysisResult result;
  final int component;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('analytics-loadings-chart'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, variable) in result.variables.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.xs),
            child: _LoadingBar(
              label: variable.localizedName(l10n),
              value: result.loadings[index][component],
            ),
          ),
      ],
    );
  }
}

/// One loading drawn from a center line: right for positive, left for
/// negative. Loadings are unit-length, so the track spans -1 to 1.
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.label, required this.value});

  final String label;
  final double value;

  static const _barHeight = 14.0;
  static const _valueWidth = 52.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final text = value.toStringAsFixed(3);
    final share = value.abs().clamp(0.0, 1.0);
    final bar = FractionallySizedBox(
      widthFactor: share,
      alignment: value < 0 ? Alignment.centerRight : Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: value < 0 ? colorScheme.tertiary : colorScheme.primary,
          borderRadius: BorderRadius.circular(NahpuRadius.xs),
        ),
      ),
    );
    return Semantics(
      container: true,
      label: '$label: $text',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                SizedBox(
                  width: _valueWidth,
                  child: Text(
                    text,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.xxs),
            SizedBox(
              height: _barHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(NahpuRadius.xs),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: value < 0 ? bar : const SizedBox()),
                        Expanded(child: value < 0 ? const SizedBox() : bar),
                      ],
                    ),
                    Center(
                      child: VerticalDivider(
                        width: NahpuStroke.thin,
                        thickness: NahpuStroke.thin,
                        color: colorScheme.outline,
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
}

/// Color key of a plot.
class PcaLegend extends StatelessWidget {
  const PcaLegend({super.key, required this.labels, required this.colors});

  final List<String> labels;
  final List<Color> colors;

  static const _swatch = 10.0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: NahpuSpacing.lg,
      runSpacing: NahpuSpacing.sm,
      children: [
        for (final (index, label) in labels.indexed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _swatch,
                height: _swatch,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: NahpuSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
