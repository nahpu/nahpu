import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'package:nahpu/screens/shared/maps/maplibre_viewport_projection.dart';

/// A compact callout shown above a map feature after it is tapped.
class MapTooltipCard extends StatelessWidget {
  const MapTooltipCard({
    super.key,
    required this.title,
    this.details = const [],
  });

  final String title;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final detail in details)
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

/// Positions a tooltip at a geographic map point while keeping it in bounds.
class MapTooltipLayer extends StatelessWidget {
  const MapTooltipLayer({
    super.key,
    required this.point,
    required this.title,
    this.details = const [],
  });

  final Geographic point;
  final String title;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.maybeOf(context);
    if (camera == null) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final anchor = mapLibreViewportScreenLocation(
            camera: camera,
            viewportSize: constraints.biggest,
            point: point,
          );
          return IgnorePointer(
            child: CustomSingleChildLayout(
              delegate: _MapTooltipLayoutDelegate(anchor: anchor),
              child: Semantics(
                container: true,
                liveRegion: true,
                label: [title, ...details].join(', '),
                child: MapTooltipCard(title: title, details: details),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapTooltipLayoutDelegate extends SingleChildLayoutDelegate {
  const _MapTooltipLayoutDelegate({required this.anchor});

  final Offset anchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxWidth = math
        .max(0, math.min(260.0, constraints.maxWidth - 16))
        .toDouble();
    final maxHeight = math.max(0, constraints.maxHeight - 16).toDouble();
    return BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = (anchor.dx - childSize.width / 2).clamp(
      8.0,
      math.max(8.0, size.width - childSize.width - 8),
    );
    final above = anchor.dy - childSize.height - 12;
    final below = anchor.dy + 12;
    final top = above >= 8
        ? above
        : below.clamp(8.0, math.max(8.0, size.height - childSize.height - 8));
    return Offset(left.toDouble(), top.toDouble());
  }

  @override
  bool shouldRelayout(covariant _MapTooltipLayoutDelegate oldDelegate) =>
      oldDelegate.anchor != anchor;
}
