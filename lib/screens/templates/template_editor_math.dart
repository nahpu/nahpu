import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Converts a pointer movement from global logical pixels to template mm.
///
/// The callback receives the current global pointer position and the global
/// pixel delta since the previous event. It returns null when the render tree
/// is not ready, allowing callers to fall back to simple scale-based math.
typedef TemplatePanMmDeltaCallback =
    Offset? Function(Offset globalPosition, Offset globalDelta);

/// Converts degrees to radians for Flutter transforms.
///
/// Flutter's rotation APIs use radians, while template elements store rotation
/// in degrees because it is easier to expose in segmented controls and JSON.
/// The conversion is:
///
/// `radians = degrees * pi / 180`
double degreesToRadians(num degrees) => degrees * math.pi / 180.0;

/// Converts radians to degrees.
///
/// Gesture angle deltas come from [math.atan2], which returns radians. Template
/// elements store degrees, so drag rotation applies:
///
/// `degrees = radians * 180 / pi`
double radiansToDegrees(num radians) => radians * 180.0 / math.pi;

/// Returns a finite, non-zero scale for px/mm math.
///
/// Template coordinates are stored in millimeters and rendered as logical
/// pixels. Most conversions divide by the current canvas scale (`px / mm`).
/// During the first layout pass the scale can briefly be zero or invalid, so
/// this function clamps it to a tiny positive value to avoid infinities.
double safeCanvasScale(double scale) {
  if (scale.isNaN || scale.isInfinite || scale.abs() < 1e-9) {
    return 1e-9;
  }
  return scale;
}

/// Converts a screen-space drag delta to template millimeters.
///
/// [globalDeltaPx] must be a global logical-pixel delta. Flutter's local
/// [DragUpdateDetails.delta] changes meaning under rotation and nested
/// transforms, so drag code should derive a global delta from consecutive
/// [DragUpdateDetails.globalPosition] values instead.
Offset pixelsToTemplateMm(Offset globalDeltaPx, double scalePxPerMm) {
  final scale = safeCanvasScale(scalePxPerMm);
  return Offset(globalDeltaPx.dx / scale, globalDeltaPx.dy / scale);
}

/// Projects a global drag through a rendered template stack into template mm.
///
/// This handles mirror transforms, scrolling, and any parent transforms by
/// converting both the current and previous global pointer positions into the
/// stack's local coordinate system, then dividing the local pixel delta by the
/// canvas scale.
Offset? globalDragDeltaToTemplateMm({
  required GlobalKey stackKey,
  required Offset globalPosition,
  required Offset globalDelta,
  required double scalePxPerMm,
}) {
  final ctx = stackKey.currentContext;
  if (ctx == null) return null;
  final renderObject = ctx.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.hasSize) return null;

  final currentLocal = renderObject.globalToLocal(globalPosition);
  final previousLocal = renderObject.globalToLocal(
    globalPosition - globalDelta,
  );
  return pixelsToTemplateMm(currentLocal - previousLocal, scalePxPerMm);
}

/// Rotates a template-space delta into an element's unrotated local axes.
///
/// Resize handles change width and height in the element's local coordinate
/// system. Pointer motion arrives in template coordinates. For an element
/// rotated by theta, the local delta is the inverse rotation:
///
/// `localX = dx * cos(theta) + dy * sin(theta)`
/// `localY = -dx * sin(theta) + dy * cos(theta)`
Offset templateDeltaToElementLocalMm(Offset deltaMm, int rotationDegrees) {
  final radians = degreesToRadians(rotationDegrees);
  final cosTheta = math.cos(radians);
  final sinTheta = math.sin(radians);
  return Offset(
    deltaMm.dx * cosTheta + deltaMm.dy * sinTheta,
    -deltaMm.dx * sinTheta + deltaMm.dy * cosTheta,
  );
}

/// Clamps a millimeter value between two bounds after ordering them.
///
/// Resizing rotated elements can produce bounds where min/max are reversed.
/// Invalid values snap to the lower ordered bound so callers never write NaN or
/// infinity into template JSON.
double clampFiniteMm(double value, double bound1, double bound2) {
  final lower = math.min(bound1, bound2);
  final upper = math.max(bound1, bound2);
  if (value.isNaN || value.isInfinite) return lower;
  return value.clamp(lower, upper);
}

/// Normalizes an angle delta to the shortest path around the unit circle.
///
/// Without wrapping, crossing `-pi`/`pi` while rotating would create a nearly
/// full-turn jump. The result is always in `[-pi, pi]`.
double normalizeRadiansDelta(double radians) {
  var normalized = radians;
  if (normalized > math.pi) normalized -= 2 * math.pi;
  if (normalized < -math.pi) normalized += 2 * math.pi;
  return normalized;
}

/// Returns half of the axis-aligned bounds for a rotated rectangle.
///
/// A rectangle with width `w`, height `h`, and rotation theta projects onto the
/// x-axis as `w * abs(cos(theta)) + h * abs(sin(theta))`. The y projection is
/// the complementary expression. Halving those projections gives the distance
/// from the rectangle center to its axis-aligned bounding box edge.
Size rotatedBoundsHalfSize({
  required double widthMm,
  required double heightMm,
  required int rotationDegrees,
}) {
  final radians = degreesToRadians(rotationDegrees);
  final cosTheta = math.cos(radians).abs();
  final sinTheta = math.sin(radians).abs();
  return Size(
    (widthMm * cosTheta + heightMm * sinTheta) / 2.0,
    (widthMm * sinTheta + heightMm * cosTheta) / 2.0,
  );
}

/// Clamps a rotated rectangle's top-left so its visual bounds stay on canvas.
///
/// [positionMm] is the unrotated rectangle top-left. The rotated bounding box
/// extends beyond that point by `halfBounds - size / 2`; those offsets become
/// the legal min/max positions for the unrotated rectangle.
Offset clampRotatedRectTopLeft({
  required Offset positionMm,
  required double widthMm,
  required double heightMm,
  required int rotationDegrees,
  required double canvasWidthMm,
  required double canvasHeightMm,
}) {
  final halfBounds = rotatedBoundsHalfSize(
    widthMm: widthMm,
    heightMm: heightMm,
    rotationDegrees: rotationDegrees,
  );
  final minX = halfBounds.width - widthMm / 2.0;
  final maxX = canvasWidthMm - widthMm / 2.0 - halfBounds.width;
  final minY = halfBounds.height - heightMm / 2.0;
  final maxY = canvasHeightMm - heightMm / 2.0 - halfBounds.height;
  return Offset(
    clampFiniteMm(positionMm.dx, minX, maxX),
    clampFiniteMm(positionMm.dy, minY, maxY),
  );
}

/// Calculates a resized rotated rectangle while keeping one corner fixed.
///
/// The resize handles mutate an unrotated width/height, but visually the
/// opposite corner should remain pinned in template coordinates. For each
/// handle, this uses the rotated-rectangle corner equations to find that fixed
/// corner, applies the local resize delta to width/height, then solves the
/// top-left needed to keep the fixed corner in the same visual position.
Rect resizedRotatedRectFromCorner({
  required Rect startMm,
  required Offset localDeltaMm,
  required String corner,
  required int rotationDegrees,
  required double maxWidthMm,
  required double maxHeightMm,
}) {
  final radians = degreesToRadians(rotationDegrees);
  final cosTheta = math.cos(radians);
  final sinTheta = math.sin(radians);
  final start = startMm;
  final delta = localDeltaMm;

  late double width;
  late double height;
  late double x;
  late double y;

  switch (corner) {
    case 'br':
      final fixedX =
          start.left +
          start.width / 2 * (1 - cosTheta) +
          start.height / 2 * sinTheta;
      final fixedY =
          start.top +
          start.height / 2 * (1 - cosTheta) -
          start.width / 2 * sinTheta;
      width = (start.width + delta.dx).clamp(2.0, maxWidthMm);
      height = (start.height + delta.dy).clamp(2.0, maxHeightMm);
      x = fixedX - width / 2 * (1 - cosTheta) - height / 2 * sinTheta;
      y = fixedY - height / 2 * (1 - cosTheta) + width / 2 * sinTheta;
      break;
    case 'bl':
      final fixedX =
          start.left +
          start.width / 2 * (1 + cosTheta) +
          start.height / 2 * sinTheta;
      final fixedY =
          start.top +
          start.height / 2 * (1 - cosTheta) +
          start.width / 2 * sinTheta;
      width = (start.width - delta.dx).clamp(2.0, maxWidthMm);
      height = (start.height + delta.dy).clamp(2.0, maxHeightMm);
      x = fixedX - width / 2 * (1 + cosTheta) - height / 2 * sinTheta;
      y = fixedY - height / 2 * (1 - cosTheta) - width / 2 * sinTheta;
      break;
    case 'tr':
      final fixedX =
          start.left +
          start.width / 2 * (1 - cosTheta) -
          start.height / 2 * sinTheta;
      final fixedY =
          start.top +
          start.height / 2 * (1 + cosTheta) -
          start.width / 2 * sinTheta;
      width = (start.width + delta.dx).clamp(2.0, maxWidthMm);
      height = (start.height - delta.dy).clamp(2.0, maxHeightMm);
      x = fixedX - width / 2 * (1 - cosTheta) + height / 2 * sinTheta;
      y = fixedY - height / 2 * (1 + cosTheta) + width / 2 * sinTheta;
      break;
    case 'tl':
    default:
      final fixedX =
          start.left +
          start.width / 2 * (1 + cosTheta) -
          start.height / 2 * sinTheta;
      final fixedY =
          start.top +
          start.height / 2 * (1 + cosTheta) +
          start.width / 2 * sinTheta;
      width = (start.width - delta.dx).clamp(2.0, maxWidthMm);
      height = (start.height - delta.dy).clamp(2.0, maxHeightMm);
      x = fixedX - width / 2 * (1 + cosTheta) + height / 2 * sinTheta;
      y = fixedY - height / 2 * (1 + cosTheta) - width / 2 * sinTheta;
      break;
  }

  return Rect.fromLTWH(x, y, width, height);
}
