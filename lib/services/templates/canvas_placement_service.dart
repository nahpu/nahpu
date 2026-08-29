import 'dart:math' as math;
import 'dart:ui';

/// Calculates initial positions for newly added template canvas elements.
abstract final class TemplateCanvasPlacementService {
  /// Returns an element's top-left position that centers it within a template.
  ///
  /// All measurements are template millimeters. Elements larger than the
  /// template are anchored at zero on that axis instead of receiving a
  /// negative initial position.
  static Offset centeredPosition({
    required double templateWidthMm,
    required double templateHeightMm,
    double elementWidthMm = 0,
    double elementHeightMm = 0,
  }) {
    final canvasWidth = _nonNegativeFinite(templateWidthMm);
    final canvasHeight = _nonNegativeFinite(templateHeightMm);
    final elementWidth = _nonNegativeFinite(elementWidthMm);
    final elementHeight = _nonNegativeFinite(elementHeightMm);
    return Offset(
      math.max(0, (canvasWidth - elementWidth) / 2),
      math.max(0, (canvasHeight - elementHeight) / 2),
    );
  }

  static double _nonNegativeFinite(double value) {
    return value.isFinite ? math.max(0, value) : 0;
  }
}
