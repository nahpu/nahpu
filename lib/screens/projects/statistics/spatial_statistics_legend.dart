import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/utility_services.dart';

class SpatialStatisticsLegend extends StatefulWidget {
  const SpatialStatisticsLegend({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
    required this.maximumCount,
    this.initiallyExpanded = true,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final int maximumCount;
  final bool initiallyExpanded;

  @override
  State<SpatialStatisticsLegend> createState() =>
      _SpatialStatisticsLegendState();
}

class _SpatialStatisticsLegendState extends State<SpatialStatisticsLegend> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final counts = spatialLegendCounts(widget.rows);
    final indicatorDiameter = counts.fold<double>(
      0,
      (maximum, count) => math.max(
        maximum,
        _diameter(
          spatialMarkerRadius(
            kind: widget.kind,
            count: count,
            maximumCount: widget.maximumCount,
          ),
        ),
      ),
    );
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: colorScheme.surface.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  key: const ValueKey('spatial-statistics-legend-toggle'),
                  tooltip: _isExpanded
                      ? 'Collapse map legend'
                      : 'Expand map legend',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.kind.hasCounts
                        ? widget.kind.countLabel.toSentenceCase()
                        : 'Legend',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 4),
              if (widget.kind.hasCounts)
                for (final count in counts)
                  _LegendSample(
                    count: count,
                    total: widget.total,
                    indicatorDiameter: indicatorDiameter,
                    radius: spatialMarkerRadius(
                      kind: widget.kind,
                      count: count,
                      maximumCount: widget.maximumCount,
                    ),
                  )
              else
                Text(
                  'Each circle represents\none coordinate',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }

  double _diameter(double radius) => radius * 2 + 3;
}

class _LegendSample extends StatelessWidget {
  const _LegendSample({
    required this.count,
    required this.total,
    required this.indicatorDiameter,
    required this.radius,
  });

  final int count;
  final int total;
  final double indicatorDiameter;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final circleDiameter = radius * 2 + 3;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: indicatorDiameter,
            height: indicatorDiameter,
            child: Center(
              child: SizedBox(
                width: circleDiameter,
                height: circleDiameter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.32),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.86),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count (${total == 0 ? '0.0' : (count * 100 / total).toStringAsFixed(1)}%)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
