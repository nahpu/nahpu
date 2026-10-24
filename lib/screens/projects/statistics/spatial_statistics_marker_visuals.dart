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
    // The circle is see-through, so the count carries its own halo to stay
    // legible over any basemap, light or dark.
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      shadows: mapLabelHalo(colorScheme),
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
    this.coordinateCount,
    this.color,
    this.foregroundColor,
  });

  /// Smallest bubble that also shows how many sites it groups.
  static const _sitesLabelDiameter = 56.0;

  final double diameter;
  final String countLabel;

  /// Sites in the group, shown under the count on large bubbles. Null leaves
  /// that line out, for bubbles whose count already is the site count.
  final int? coordinateCount;

  /// Bubble fill, the primary color by default.
  final Color? color;

  /// Text color over [color], the on-primary color by default.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fill = color ?? colorScheme.primary;
    final foreground = foregroundColor ?? colorScheme.onPrimary;
    return SizedBox.square(
      dimension: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill.withValues(alpha: 0.88),
          border: Border.all(color: colorScheme.surface, width: 2),
          boxShadow: [
            BoxShadow(color: fill.withValues(alpha: 0.35), spreadRadius: 3),
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
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (coordinateCount != null &&
                        diameter >= _sitesLabelDiameter)
                      Text(
                        context.l10n.projectStatsSiteCount(coordinateCount!),
                        style: textTheme.labelSmall?.copyWith(
                          color: foreground,
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

/// A surface-colored outline for text drawn straight on a map, so it reads
/// over light and dark basemaps alike.
List<Shadow> mapLabelHalo(ColorScheme colorScheme) {
  final color = colorScheme.surface;
  return [
    for (final offset in const [
      Offset(-1, -1),
      Offset(1, -1),
      Offset(-1, 1),
      Offset(1, 1),
    ])
      Shadow(color: color, offset: offset, blurRadius: 1.5),
  ];
}

/// Side of the square inscribed in a circle of [diameter], less its 2px
/// outline on each side.
double _innerSquare(double diameter) => (diameter - 4) / math.sqrt2;
