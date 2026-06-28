import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/labels/label_template_model.dart';

/// PDF points per mm (same as label PDF helpers).
const double kLabelOutlinePdfPointsPerMm = 72.0 / 25.4;

double labelOutlineStrokeWidthPx(double widthPt, double scaleMmToPx) =>
    widthPt * scaleMmToPx / kLabelOutlinePdfPointsPerMm;

List<BoxShadow> labelAreaBoxShadows() => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

/// White fill; when an outline is configured, stroke is drawn by [LabelOutlineOverlayPainter].
BoxDecoration labelAreaStackDecoration() {
  return BoxDecoration(
    color: Colors.white,
    boxShadow: labelAreaBoxShadows(),
  );
}

void _strokeRectSolid(Canvas canvas, Rect r, Paint paint) {
  canvas.drawRect(r, paint);
}

void _strokeRectDashed(
  Canvas canvas,
  Rect r,
  Paint paint, {
  required double dashLen,
  required double gapLen,
}) {
  final path = Path()..addRect(r);
  for (final metric in path.computeMetrics()) {
    var d = 0.0;
    while (d < metric.length) {
      final len = math.min(dashLen, metric.length - d);
      canvas.drawPath(metric.extractPath(d, d + len), paint);
      d += len + gapLen;
    }
  }
}

/// Paints the configured outline on top of the label rectangle.
class LabelOutlineOverlayPainter extends CustomPainter {
  LabelOutlineOverlayPainter({
    required this.outline,
    required this.scaleMmToPx,
  });

  final LabelTemplateOutline outline;
  final double scaleMmToPx;

  @override
  void paint(Canvas canvas, Size size) {
    final w = labelOutlineStrokeWidthPx(outline.widthPt, scaleMmToPx)
        .clamp(0.25, 24.0);
    final paint = Paint()
      ..color = Color(outline.colorArgb)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..isAntiAlias = true;

    final outer = Rect.fromLTWH(
      w / 2,
      w / 2,
      (size.width - w).clamp(0.0, size.width),
      (size.height - w).clamp(0.0, size.height),
    );

    switch (outline.style) {
      case LabelTemplateOutlineStyle.solid:
        _strokeRectSolid(canvas, outer, paint);
        break;
      case LabelTemplateOutlineStyle.dashed:
        _strokeRectDashed(
          canvas,
          outer,
          paint,
          dashLen: w * 4,
          gapLen: w * 2.5,
        );
        break;
      case LabelTemplateOutlineStyle.dotted:
        _strokeRectDashed(
          canvas,
          outer,
          paint,
          dashLen: math.max(0.35, w * 0.35),
          gapLen: w * 2,
        );
        break;
      case LabelTemplateOutlineStyle.doubleLine:
        _strokeRectSolid(canvas, outer, paint);
        final gap = (w * 1.25).clamp(1.0, 10.0);
        final inset = w + gap;
        final iw = (size.width - 2 * inset - w).clamp(0.0, size.width);
        final ih = (size.height - 2 * inset - w).clamp(0.0, size.height);
        if (iw > 0 && ih > 0) {
          final inner = Rect.fromLTWH(inset + w / 2, inset + w / 2, iw, ih);
          _strokeRectSolid(canvas, inner, paint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant LabelOutlineOverlayPainter oldDelegate) {
    return oldDelegate.outline != outline ||
        oldDelegate.scaleMmToPx != scaleMmToPx;
  }
}
