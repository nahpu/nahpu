import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/utility_services.dart';

class SpatialStatisticsLegend extends StatelessWidget {
  const SpatialStatisticsLegend({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
    required this.maximumCount,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final int maximumCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final counts = spatialLegendCounts(rows);
    final indicatorDiameter = counts.fold<double>(
      0,
      (maximum, count) => math.max(
        maximum,
        _diameter(
          spatialMarkerRadius(
            kind: kind,
            count: count,
            maximumCount: maximumCount,
          ),
        ),
      ),
    );
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: colorScheme.surface.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: kind.hasCounts
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kind.countLabel.toSentenceCase(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  for (final count in counts)
                    _LegendSample(
                      count: count,
                      total: total,
                      indicatorDiameter: indicatorDiameter,
                      radius: spatialMarkerRadius(
                        kind: kind,
                        count: count,
                        maximumCount: maximumCount,
                      ),
                    ),
                ],
              )
            : Text(
                'Each circle represents\none coordinate',
                style: Theme.of(context).textTheme.bodySmall,
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
          const SizedBox(width: 8),
          Text(
            '$count (${total == 0 ? '0.0' : (count * 100 / total).toStringAsFixed(1)}%)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
