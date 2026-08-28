import 'package:material_ui/material_ui.dart';

class EndSidebarPanelIcon extends StatelessWidget {
  const EndSidebarPanelIcon({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: EndSidebarPanelIconPainter(color: color),
    );
  }
}

class EndSidebarPanelIconPainter extends CustomPainter {
  EndSidebarPanelIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final m = w * 0.1;
    final radius = w * 0.12;
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(m, m, w - 2 * m, h - 2 * m),
      Radius.circular(radius),
    );
    final stroke = (w * 0.09).clamp(1.5, 2.5);
    canvas.drawRRect(
      outer,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final innerPad = w * 0.06;
    final barW = w * 0.24;
    final barRight = w - m - innerPad;
    final barLeft = barRight - barW;
    final barTop = m + innerPad;
    final barBottom = h - m - innerPad;
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTRB(barLeft, barTop, barRight, barBottom),
      Radius.circular(stroke * 0.35),
    );
    canvas.drawRRect(bar, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant EndSidebarPanelIconPainter old) =>
      old.color != color;
}
