import 'dart:math' as math;
import 'dart:ui';

/// Sizes and centres the template canvas inside the editor workspace.
///
/// At 100% zoom the whole template fits the workspace with a small margin and
/// clears the side switcher and zoom controls that float along the bottom
/// edge. The same fit area is used to centre the canvas at any zoom.
abstract final class TemplateCanvasViewportService {
  /// Gap kept between the template and the workspace edges, in pixels.
  static const double margin = 16;

  /// Height kept free for the floating controls along the bottom, in pixels.
  static const double bottomControlsReserve = 72;

  /// Pixels per millimetre at 100% zoom for a template in [viewport].
  ///
  /// Falls back to 1 when the template or viewport has no usable size.
  static double fitScale({
    required Size viewport,
    required double templateWidthMm,
    required double templateHeightMm,
  }) {
    final fitArea = _fitArea(viewport);
    if (templateWidthMm <= 0 ||
        templateHeightMm <= 0 ||
        fitArea.width <= 0 ||
        fitArea.height <= 0) {
      return 1;
    }
    final scale = math.min(
      fitArea.width / templateWidthMm,
      fitArea.height / templateHeightMm,
    );
    return scale.isFinite && scale > 0 ? scale : 1;
  }

  /// The viewer translation that moves [canvasCenter], given in the viewer's
  /// content coordinates, to the centre of the fit area of [viewport].
  static Offset centeringTranslation({
    required Size viewport,
    required Offset canvasCenter,
  }) {
    return _fitArea(viewport).center - canvasCenter;
  }

  static Rect _fitArea(Size viewport) {
    return Rect.fromLTRB(
      margin,
      margin,
      viewport.width - margin,
      viewport.height - bottomControlsReserve,
    );
  }
}
