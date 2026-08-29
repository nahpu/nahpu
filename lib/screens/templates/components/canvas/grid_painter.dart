import 'package:material_ui/material_ui.dart';

class GridPainter extends CustomPainter {
  GridPainter({
    required this.templateWidthMm,
    required this.templateHeightMm,
    required this.scale,
  });

  final double templateWidthMm;
  final double templateHeightMm;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    final thickPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    const smallStep = 1.0;
    const bigStep = 5.0;

    for (double x = 0; x <= templateWidthMm; x += smallStep) {
      final px = x * scale;
      final isMajor = (x % bigStep) < 0.01;
      canvas.drawLine(
        Offset(px, 0),
        Offset(px, size.height),
        isMajor ? thickPaint : thinPaint,
      );
    }
    for (double y = 0; y <= templateHeightMm; y += smallStep) {
      final py = y * scale;
      final isMajor = (y % bigStep) < 0.01;
      canvas.drawLine(
        Offset(0, py),
        Offset(size.width, py),
        isMajor ? thickPaint : thinPaint,
      );
    }

    final textStyle = TextStyle(color: Colors.grey.shade500, fontSize: 9);
    for (double x = 0; x <= templateWidthMm; x += 10) {
      final tp = TextPainter(
        text: TextSpan(text: '${x.toInt()}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x * scale + 2, 2));
    }
    for (double y = 10; y <= templateHeightMm; y += 10) {
      final tp = TextPainter(
        text: TextSpan(text: '${y.toInt()}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y * scale + 2));
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) =>
      old.scale != scale ||
      old.templateWidthMm != templateWidthMm ||
      old.templateHeightMm != templateHeightMm;
}
