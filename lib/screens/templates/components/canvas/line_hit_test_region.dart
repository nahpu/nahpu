import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nahpu/services/templates/canvas_hit_test_service.dart';

/// Only contributes to hit testing close to a line segment.
///
/// This prevents a line's padded gesture area from selecting it when a tap is
/// merely inside its bounding rectangle. The child still receives normal
/// gestures, including taps for locked elements.
class LineHitTestRegion extends SingleChildRenderObjectWidget {
  const LineHitTestRegion({
    super.key,
    required this.start,
    required this.end,
    required this.tolerancePx,
    required super.child,
  });

  final Offset start;
  final Offset end;
  final double tolerancePx;

  @override
  RenderLineHitTestRegion createRenderObject(BuildContext context) {
    return RenderLineHitTestRegion(
      start: start,
      end: end,
      tolerancePx: tolerancePx,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLineHitTestRegion renderObject,
  ) {
    renderObject
      ..start = start
      ..end = end
      ..tolerancePx = tolerancePx;
  }
}

class RenderLineHitTestRegion extends RenderProxyBox {
  RenderLineHitTestRegion({
    required Offset start,
    required Offset end,
    required double tolerancePx,
  })  : _start = start,
        _end = end,
        _tolerancePx = tolerancePx;

  Offset _start;
  Offset _end;
  double _tolerancePx;

  set start(Offset value) {
    if (value == _start) return;
    _start = value;
    markNeedsPaint();
  }

  set end(Offset value) {
    if (value == _end) return;
    _end = value;
    markNeedsPaint();
  }

  set tolerancePx(double value) {
    final normalized = math.max(0.0, value);
    if (normalized == _tolerancePx) return;
    _tolerancePx = normalized;
    markNeedsPaint();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position) ||
        TemplateCanvasHitTestService.pointToLineSegmentDistance(
              position,
              _start,
              _end,
            ) >
            _tolerancePx) {
      return false;
    }
    return super.hitTest(result, position: position);
  }
}
