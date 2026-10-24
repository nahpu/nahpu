import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// Text the network painter draws, resolved by the screen.
class NetworkCanvasLabels {
  const NetworkCanvasLabels({
    required this.typeLabel,
    required this.overflowLabel,
  });

  /// Plural name of a record type, for the hub and column headers.
  final String Function(NetworkNodeType type) typeLabel;

  /// Name of an overflow node standing for [hiddenRecords] records.
  final String Function(int hiddenRecords) overflowLabel;
}

/// Pan-and-zoom view of a laid-out network.
///
/// Everything is drawn by one painter, so a large network costs one layer
/// rather than a widget per node. Nodes and labels outside the viewport are
/// skipped, and labels hide when zoomed out too far to read.
class NetworkCanvas extends StatefulWidget {
  const NetworkCanvas({
    super.key,
    required this.layout,
    required this.selected,
    required this.labels,
    required this.onNodeTap,
    required this.fitSignal,
  });

  final NetworkLayoutResult layout;
  final NetworkNodeKey? selected;
  final NetworkCanvasLabels labels;

  /// Called with the tapped node, or null for a tap on empty space.
  final ValueChanged<NetworkLayoutNode?> onNodeTap;

  /// Fits the network to the view whenever this value changes.
  final Object fitSignal;

  @override
  State<NetworkCanvas> createState() => _NetworkCanvasState();
}

class _NetworkCanvasState extends State<NetworkCanvas> {
  final _transform = TransformationController();
  final _text = _TextCache();
  Size _viewport = Size.zero;
  bool _needsFit = true;

  @override
  void didUpdateWidget(covariant NetworkCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fitSignal != widget.fitSignal) _needsFit = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _text.clear();
  }

  @override
  void dispose() {
    _transform.dispose();
    _text.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        if (_needsFit) {
          _needsFit = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _transform.value = _fitMatrix(widget.layout.size, _viewport);
          });
        }
        return ClipRect(
          child: InteractiveViewer(
            key: const ValueKey('statistics-network-canvas'),
            transformationController: _transform,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(NahpuSpacing.displayLarge * 8),
            minScale: 0.05,
            maxScale: 4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => widget.onNodeTap(
                widget.layout.hitTest(details.localPosition),
              ),
              child: CustomPaint(
                size: _paintSize(widget.layout.size, _viewport),
                painter: _NetworkPainter(
                  layout: widget.layout,
                  selected: widget.selected,
                  labels: widget.labels,
                  transform: _transform,
                  viewport: _viewport,
                  colors: NahpuTheme.networkTypeColors(theme.colorScheme),
                  colorScheme: theme.colorScheme,
                  textTheme: theme.textTheme,
                  text: _text,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Paints at least the viewport so taps on empty space still land.
  static Size _paintSize(Size layout, Size viewport) => Size(
    math.max(layout.width, viewport.width),
    math.max(layout.height, viewport.height),
  );

  static Matrix4 _fitMatrix(Size content, Size viewport) {
    if (content.isEmpty || viewport.isEmpty || !viewport.isFinite) {
      return Matrix4.identity();
    }
    final scale = math
        .min(viewport.width / content.width, viewport.height / content.height)
        .clamp(0.05, 1.0);
    final dx = (viewport.width - content.width * scale) / 2;
    final dy = (viewport.height - content.height * scale) / 2;
    return Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }
}

class _NetworkPainter extends CustomPainter {
  _NetworkPainter({
    required this.layout,
    required this.selected,
    required this.labels,
    required this.transform,
    required this.viewport,
    required this.colors,
    required this.colorScheme,
    required this.textTheme,
    required this.text,
  }) : super(repaint: transform);

  /// Screen-space font size below which labels are skipped.
  static const _minReadableFont = 7.0;

  final NetworkLayoutResult layout;
  final NetworkNodeKey? selected;
  final NetworkCanvasLabels labels;
  final TransformationController transform;
  final Size viewport;
  final List<Color> colors;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final _TextCache text;

  Color _typeColor(NetworkNodeType type) => colors[type.index % colors.length];

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = transform.value;
    final scale = matrix.getMaxScaleOnAxis();
    final visible = MatrixUtils.inverseTransformRect(
      matrix,
      Offset.zero & viewport,
    ).inflate(NahpuSpacing.display);
    final showLabels = scale * 11 >= _minReadableFont;

    _paintColumns(canvas, visible);
    _paintEdges(canvas, visible);
    for (final node in layout.nodes) {
      if (!visible.overlaps(node.bounds)) continue;
      if (layout.columns.isEmpty) {
        _paintCircle(canvas, node, scale, showLabels);
      } else {
        _paintBar(canvas, node, showLabels);
      }
    }
  }

  void _paintColumns(Canvas canvas, Rect visible) {
    final style = textTheme.titleSmall!.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    for (final column in layout.columns) {
      final painter = text.layout(
        '${labels.typeLabel(column.type)} (${column.totalRecords})',
        style,
        column.width,
      );
      painter.paint(canvas, Offset(column.left, NahpuSpacing.lg));
    }
  }

  void _paintEdges(Canvas canvas, Rect visible) {
    final hasFocus = layout.edges.any((edge) => edge.focusWeight > 0);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    for (final edge in layout.edges) {
      if (!visible.overlaps(Rect.fromPoints(edge.start, edge.end))) continue;
      final touchesSelected = edge.from == selected || edge.to == selected;
      final color = edge.curved
          ? _typeColor(edge.from.type)
          : colorScheme.outline;
      final alpha = switch ((edge.curved, hasFocus || selected != null)) {
        (true, true) => 0.1,
        (true, false) => 0.3,
        (false, true) => touchesSelected ? 0.9 : 0.2,
        (false, false) => 0.45,
      };
      base
        ..color =
            (touchesSelected && !edge.curved
                    ? _typeColor(selected!.type)
                    : color)
                .withValues(alpha: alpha)
        ..strokeWidth = edge.width;
      _drawEdge(canvas, edge, base);
      if (edge.focusWeight > 0) {
        final focusPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = _typeColor(
            selected?.type ?? edge.from.type,
          ).withValues(alpha: 0.75)
          ..strokeWidth = math.max(
            NahpuStroke.regular,
            edge.width * edge.focusWeight / edge.weight,
          );
        _drawEdge(canvas, edge, focusPaint);
      }
    }
  }

  void _drawEdge(Canvas canvas, NetworkLayoutEdge edge, Paint paint) {
    if (!edge.curved) {
      canvas.drawLine(edge.start, edge.end, paint);
      return;
    }
    final midX = (edge.start.dx + edge.end.dx) / 2;
    final path = Path()
      ..moveTo(edge.start.dx, edge.start.dy)
      ..cubicTo(
        midX,
        edge.start.dy,
        midX,
        edge.end.dy,
        edge.end.dx,
        edge.end.dy,
      );
    canvas.drawPath(path, paint);
  }

  void _paintCircle(
    Canvas canvas,
    NetworkLayoutNode node,
    double scale,
    bool showLabels,
  ) {
    final color = _typeColor(node.key.type);
    final radius = node.bounds.width / 2;
    final isSelected = node.key == selected;
    final fill = Paint()
      ..color = switch (node.kind) {
        NetworkNodeKind.hub => colorScheme.surfaceContainerHighest,
        NetworkNodeKind.overflow => colorScheme.surfaceContainerLow,
        NetworkNodeKind.record => color,
      };
    canvas.drawCircle(node.center, radius, fill);
    if (node.kind != NetworkNodeKind.record || isSelected) {
      canvas.drawCircle(
        node.center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected
              ? NahpuStroke.regular * 2
              : NahpuStroke.regular
          ..color = isSelected ? colorScheme.onSurface : color,
      );
    }
    if (!showLabels && node.kind != NetworkNodeKind.hub) return;

    final countStyle = textTheme.labelMedium!.copyWith(
      color: node.kind == NetworkNodeKind.record
          ? _onColor(color)
          : colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    if (radius * scale >= 9 && node.kind != NetworkNodeKind.hub) {
      final count = text.layout(_compact(node.count), countStyle, radius * 2);
      count.paint(
        canvas,
        node.center - Offset(count.width / 2, count.height / 2),
      );
    }

    final name = switch (node.kind) {
      NetworkNodeKind.hub => labels.typeLabel(node.key.type),
      NetworkNodeKind.overflow => labels.overflowLabel(node.hiddenRecords),
      NetworkNodeKind.record => node.label,
    };
    final nameStyle = textTheme.labelSmall!.copyWith(
      color: colorScheme.onSurface,
    );
    if (node.kind == NetworkNodeKind.hub) {
      final hub = text.layout(
        '$name\n${_compact(node.count)}',
        textTheme.labelLarge!.copyWith(color: colorScheme.onSurface),
        radius * 2,
        align: TextAlign.center,
      );
      hub.paint(canvas, node.center - Offset(hub.width / 2, hub.height / 2));
      return;
    }
    final label = text.layout(name, nameStyle, 120, align: TextAlign.center);
    label.paint(
      canvas,
      Offset(node.center.dx - label.width / 2, node.bounds.bottom + 2),
    );
  }

  void _paintBar(Canvas canvas, NetworkLayoutNode node, bool showLabels) {
    final color = _typeColor(node.key.type);
    final isSelected = node.key == selected;
    final rect = RRect.fromRectAndRadius(
      node.bounds,
      const Radius.circular(NahpuRadius.xs),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = node.kind == NetworkNodeKind.overflow
            ? colorScheme.surfaceContainerHigh
            : color.withValues(alpha: 0.85),
    );
    if (isSelected || node.kind == NetworkNodeKind.overflow) {
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected
              ? NahpuStroke.regular * 2
              : NahpuStroke.thin
          ..color = isSelected ? colorScheme.onSurface : color,
      );
    }
    if (!showLabels) return;
    final name = node.kind == NetworkNodeKind.overflow
        ? labels.overflowLabel(node.hiddenRecords)
        : node.label;
    final style = textTheme.labelMedium!.copyWith(
      color: node.kind == NetworkNodeKind.overflow
          ? colorScheme.onSurface
          : _onColor(color),
    );
    final label = text.layout(
      '$name · ${_compact(node.count)}',
      style,
      node.bounds.width - NahpuSpacing.md * 2,
    );
    if (label.height > node.bounds.height) return;
    label.paint(
      canvas,
      Offset(
        node.bounds.left + NahpuSpacing.md,
        node.bounds.center.dy - label.height / 2,
      ),
    );
  }

  static Color _onColor(Color background) =>
      background.computeLuminance() > 0.4 ? Colors.black : Colors.white;

  static String _compact(int value) {
    if (value < 1000) return '$value';
    if (value < 1000000) return '${(value / 1000).toStringAsFixed(1)}k';
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.selected != selected ||
      oldDelegate.viewport != viewport ||
      oldDelegate.colorScheme != colorScheme;
}

/// Laid-out labels reused across frames, so panning and zooming never lay
/// out text again.
class _TextCache {
  static const _maxEntries = 4000;

  final _entries = <(String, TextStyle, double, TextAlign), TextPainter>{};

  TextPainter layout(
    String text,
    TextStyle style,
    double maxWidth, {
    TextAlign align = TextAlign.start,
  }) {
    final key = (text, style, maxWidth, align);
    final cached = _entries[key];
    if (cached != null) return cached;
    if (_entries.length >= _maxEntries) clear();
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: math.max(0, maxWidth));
    return _entries[key] = painter;
  }

  void clear() {
    for (final painter in _entries.values) {
      painter.dispose();
    }
    _entries.clear();
  }
}
