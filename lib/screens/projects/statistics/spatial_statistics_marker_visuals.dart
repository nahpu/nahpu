import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// One coordinate's circle, with its count inside when the count fits.
///
/// Purely visual: each map renderer adds its own tap and tooltip handling.
class SpatialPointCircle extends StatelessWidget {
  const SpatialPointCircle({
    super.key,
    required this.diameter,
    this.countLabel,
  });

  final double diameter;
  final String? countLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    return SizedBox.square(
      dimension: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withValues(alpha: 0.32),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.86),
            width: 2,
          ),
        ),
        child: countLabel != null && _fitsInside(context, labelStyle)
            ? Center(
                child: ExcludeSemantics(
                  child: Text(countLabel!, style: labelStyle),
                ),
              )
            : null,
      ),
    );
  }

  /// Whether the count fits in the square inscribed in the circle, so the
  /// text never touches the outline.
  bool _fitsInside(BuildContext context, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: countLabel, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final room = _innerSquare(diameter) - NahpuSpacing.xs;
    final fits = painter.width <= room && painter.height <= room;
    painter.dispose();
    return fits;
  }
}

/// Solid bubble standing in for coordinates whose circles overlap.
///
/// Purely visual: each map renderer adds its own tap and tooltip handling.
class SpatialClusterBubble extends StatelessWidget {
  const SpatialClusterBubble({
    super.key,
    required this.diameter,
    required this.countLabel,
    required this.coordinateCount,
  });

  /// Smallest bubble that also shows how many sites it groups.
  static const _sitesLabelDiameter = 56.0;

  final double diameter;
  final String countLabel;
  final int coordinateCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox.square(
      dimension: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withValues(alpha: 0.88),
          border: Border.all(color: colorScheme.surface, width: 2),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.35),
              spreadRadius: 3,
            ),
          ],
        ),
        // Labels scale down inside the square inscribed in the circle, so
        // long counts shrink instead of touching the outline.
        child: Center(
          child: SizedBox.square(
            dimension: _innerSquare(diameter) - NahpuSpacing.xs,
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (diameter >= _sitesLabelDiameter)
                      Text(
                        context.l10n.projectStatsSiteCount(coordinateCount),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Side of the square inscribed in a circle of [diameter], less its 2px
/// outline on each side.
double _innerSquare(double diameter) => (diameter - 4) / math.sqrt2;
