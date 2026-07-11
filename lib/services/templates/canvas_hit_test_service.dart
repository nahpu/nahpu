import 'dart:ui';

/// Geometry rules used when selecting elements on the template canvas.
abstract final class TemplateCanvasHitTestService {
  /// Returns the shortest distance in pixels from [point] to the finite
  /// segment from [start] to [end].
  static double pointToLineSegmentDistance(
    Offset point,
    Offset start,
    Offset end,
  ) {
    final segment = end - start;
    final lengthSquared = segment.dx * segment.dx + segment.dy * segment.dy;
    if (lengthSquared == 0) return (point - start).distance;

    final offset = point - start;
    final projection =
        ((offset.dx * segment.dx + offset.dy * segment.dy) / lengthSquared)
            .clamp(0.0, 1.0)
            .toDouble();
    final closest = start + segment * projection;
    return (point - closest).distance;
  }
}
