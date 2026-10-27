import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// Text the network painter draws, resolved by the screen.
class NetworkCanvasLabels {
  const NetworkCanvasLabels({
    required this.columnLabel,
    required this.overflowLabel,
  });

  /// Name of a record type or field column, for the hub and column headers.
  final String Function(NetworkColumn column) columnLabel;

  /// Name of an overflow node standing for [hiddenRecords] records.
  final String Function(int hiddenRecords) overflowLabel;
}

/// Pan-and-zoom view of a laid-out network.
///
/// Everything is drawn by one painter, so a large network costs one layer
/// rather than a widget per node. Nodes and labels outside the viewport are
/// skipped, and labels hide when zoomed out too far to read.
///
/// When the layout changes, the node last tapped stays where it is on screen
/// and the rest glide to their new places, with new nodes growing out of the
/// node they belong to.
class NetworkCanvas extends StatefulWidget {
  const NetworkCanvas({
    super.key,
    required this.layout,
    required this.selected,
    required this.labels,
    required this.onNodeTap,
    required this.fitSignal,
    this.fitInsets = EdgeInsets.zero,
  });

  final NetworkLayoutResult layout;
  final NetworkNodeKey? selected;
  final NetworkCanvasLabels labels;

  /// Called with the tapped node, or null for a tap on empty space.
  final ValueChanged<NetworkLayoutNode?> onNodeTap;

  /// Fits the network to the view whenever this value changes.
  final Object fitSignal;

  /// Room kept clear around the fitted network for controls laid over the
  /// canvas.
  final EdgeInsets fitInsets;

  @override
  State<NetworkCanvas> createState() => _NetworkCanvasState();
}

class _NetworkCanvasState extends State<NetworkCanvas>
    with SingleTickerProviderStateMixin {
  static const _moveDuration = Duration(milliseconds: 280);
  static const _minScale = 0.05;
  static const _maxScale = 4.0;

  final _transform = TransformationController();
  final _text = _TextCache();
  late final _motion = AnimationController(
    vsync: this,
    duration: _moveDuration,
    value: 1,
  );
  late final _progress = CurvedAnimation(
    parent: _motion,
    curve: Curves.easeOutCubic,
  );

  /// Where each node starts its move, in network space.
  Map<NetworkNodeKey, Offset> _start = const {};
  NetworkNodeKey? _lastTapped;
  Size _viewport = Size.zero;
  bool _needsFit = true;

  @override
  void didUpdateWidget(covariant NetworkCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fitSignal != widget.fitSignal) {
      _needsFit = true;
      _start = const {};
      _motion.value = 1;
    } else if (oldWidget.layout != widget.layout) {
      _moveFrom(oldWidget.layout);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _text.clear();
  }

  @override
  void dispose() {
    _progress.dispose();
    _motion.dispose();
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
            _transform.value = _fitMatrix(
              widget.layout.size,
              _viewport,
              widget.fitInsets,
            );
          });
        }
        return ClipRect(
          child: InteractiveViewer(
            key: const ValueKey('statistics-network-canvas'),
            transformationController: _transform,
            constrained: false,
            boundaryMargin: _boundaryMargin(_viewport),
            minScale: _minScale,
            maxScale: _maxScale,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final node = widget.layout.hitTest(details.localPosition);
                _lastTapped = node?.key;
                widget.onNodeTap(node);
              },
              child: CustomPaint(
                size: _paintSize(widget.layout.size, _viewport),
                painter: _NetworkPainter(
                  layout: widget.layout,
                  selected: widget.selected,
                  labels: widget.labels,
                  transform: _transform,
                  progress: _progress,
                  start: _start,
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

  /// Starts moving every node from where it is drawn now to its place in the
  /// new layout, keeping the anchor node still on screen.
  void _moveFrom(NetworkLayoutResult old) {
    final t = _progress.value;
    final current = {
      for (final node in old.nodes)
        node.key: switch (_start[node.key]) {
          final start? => Offset.lerp(start, node.center, t)!,
          null => node.center,
        },
    };
    final layout = widget.layout;
    final anchor = _anchor(layout, current);
    final shift = anchor == null
        ? Offset.zero
        : layout.nodeFor(anchor)!.center - current[anchor]!;
    if (shift != Offset.zero) {
      // Moves the view with the anchor. The matrix is changed in place
      // because this runs during build: the viewer and painter rebuilding
      // with this widget pick it up, and no listener fires mid-build.
      _transform.value.translateByDouble(-shift.dx, -shift.dy, 0, 1);
    }
    _start = {
      for (final node in layout.nodes)
        if ((current[node.key] ?? current[node.parent]) case final from?)
          node.key: from + shift,
    };
    _motion.forward(from: 0);
  }

  /// Node to hold still: the one last tapped, else the selection, else the
  /// radial hub, as long as it is in both layouts.
  NetworkNodeKey? _anchor(
    NetworkLayoutResult layout,
    Map<NetworkNodeKey, Offset> current,
  ) {
    bool inBoth(NetworkNodeKey? key) =>
        key != null && current.containsKey(key) && layout.nodeFor(key) != null;
    if (inBoth(_lastTapped)) return _lastTapped;
    if (inBoth(widget.selected)) return widget.selected;
    for (final node in layout.nodes) {
      if (node.kind == NetworkNodeKind.hub && inBoth(node.key)) {
        return node.key;
      }
    }
    return null;
  }

  /// Paints at least the viewport so taps on empty space still land.
  static Size _paintSize(Size layout, Size viewport) => Size(
    math.max(layout.width, viewport.width),
    math.max(layout.height, viewport.height),
  );

  /// Room to pan past the network on each side.
  ///
  /// The viewer only pans an axis while the zoomed-out view stays inside the
  /// boundary, and blocks zooming out past where it would leave it. A fixed
  /// margin is outgrown on the long axis of a phone, which then pans only
  /// sideways, so each axis gets enough room to hold the whole view at the
  /// smallest scale.
  static EdgeInsets _boundaryMargin(Size viewport) {
    const base = NahpuSpacing.displayLarge * 8;
    if (!viewport.isFinite) return const EdgeInsets.all(base);
    return EdgeInsets.symmetric(
      horizontal: math.max(base, viewport.width / _minScale),
      vertical: math.max(base, viewport.height / _minScale),
    );
  }

  static Matrix4 _fitMatrix(Size content, Size viewport, EdgeInsets insets) {
    if (content.isEmpty || viewport.isEmpty || !viewport.isFinite) {
      return Matrix4.identity();
    }
    // Controls too big for the view leave the whole view to the network.
    final clear = insets.deflateRect(Offset.zero & viewport);
    final area = clear.isEmpty ? Offset.zero & viewport : clear;
    final scale = math
        .min(area.width / content.width, area.height / content.height)
        .clamp(_minScale, 1.0);
    final dx = area.left + (area.width - content.width * scale) / 2;
    final dy = area.top + (area.height - content.height * scale) / 2;
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
    required this.progress,
    required this.start,
    required this.viewport,
    required this.colors,
    required this.colorScheme,
    required this.textTheme,
    required this.text,
  }) : super(repaint: Listenable.merge([transform, progress]));

  /// Screen-space font size below which labels are skipped.
  static const _minReadableFont = 7.0;

  final NetworkLayoutResult layout;
  final NetworkNodeKey? selected;
  final NetworkCanvasLabels labels;
  final TransformationController transform;

  /// How far nodes have moved from [start] to their place in [layout].
  final Animation<double> progress;
  final Map<NetworkNodeKey, Offset> start;
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
    final offsets = _offsets();

    _paintColumns(canvas, visible);
    _paintEdges(canvas, visible, offsets);
    for (final laidOut in layout.nodes) {
      final node = _moved(laidOut, offsets[laidOut.key]);
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
      // One line above the bars; the type name gives way to the count.
      final count = text.layout('(${_compact(column.totalRecords)})', style);
      final name = text.layout(
        labels.columnLabel(column.column),
        style,
        maxWidth: column.width - count.width - NahpuSpacing.xs,
      );
      const top = NahpuSpacing.lg;
      name.paint(canvas, Offset(column.left, top));
      count.paint(
        canvas,
        Offset(column.left + name.width + NahpuSpacing.xs, top),
      );
    }
  }

  /// How far each moving node still is from its place in [layout].
  Map<NetworkNodeKey, Offset> _offsets() {
    final t = progress.value;
    if (t >= 1 || start.isEmpty) return const {};
    return {
      for (final node in layout.nodes)
        if (start[node.key] case final from?)
          node.key: (from - node.center) * (1 - t),
    };
  }

  static NetworkLayoutNode _moved(NetworkLayoutNode node, Offset? offset) {
    if (offset == null || offset == Offset.zero) return node;
    return NetworkLayoutNode(
      key: node.key,
      kind: node.kind,
      label: node.label,
      count: node.count,
      hiddenRecords: node.hiddenRecords,
      parent: node.parent,
      bounds: node.bounds.shift(offset),
    );
  }

  void _paintEdges(
    Canvas canvas,
    Rect visible,
    Map<NetworkNodeKey, Offset> offsets,
  ) {
    final hasFocus = layout.edges.any((edge) => edge.focusWeight > 0);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    for (final laidOut in layout.edges) {
      final edge = _movedEdge(laidOut, offsets);
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

  static NetworkLayoutEdge _movedEdge(
    NetworkLayoutEdge edge,
    Map<NetworkNodeKey, Offset> offsets,
  ) {
    final from = offsets[edge.from];
    final to = offsets[edge.to];
    if (from == null && to == null) return edge;
    return NetworkLayoutEdge(
      from: edge.from,
      to: edge.to,
      weight: edge.weight,
      focusWeight: edge.focusWeight,
      start: edge.start + (from ?? Offset.zero),
      end: edge.end + (to ?? Offset.zero),
      width: edge.width,
      curved: edge.curved,
    );
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
      // Drawn whole or not at all: a clipped count would misread.
      final count = text.layout(_compact(node.count), countStyle);
      if (count.width <= radius * 2 - NahpuSpacing.xs &&
          count.height <= radius * 2) {
        count.paint(
          canvas,
          node.center - Offset(count.width / 2, count.height / 2),
        );
      }
    }

    final name = switch (node.kind) {
      NetworkNodeKind.hub => labels.columnLabel(node.key.column),
      NetworkNodeKind.overflow => labels.overflowLabel(node.hiddenRecords),
      NetworkNodeKind.record => node.label,
    };
    final nameStyle = textTheme.labelSmall!.copyWith(
      color: colorScheme.onSurface,
    );
    if (node.kind == NetworkNodeKind.hub) {
      // Name and total on their own lines, so a long name never pushes the
      // total out of the circle.
      final style = textTheme.labelLarge!.copyWith(
        color: colorScheme.onSurface,
      );
      final title = text.layout(
        name,
        style,
        maxWidth: radius * 2 - NahpuSpacing.md,
        align: TextAlign.center,
      );
      final total = text.layout(_compact(node.count), style);
      final top = node.center.dy - (title.height + total.height) / 2;
      title.paint(canvas, Offset(node.center.dx - title.width / 2, top));
      total.paint(
        canvas,
        Offset(node.center.dx - total.width / 2, top + title.height),
      );
      return;
    }
    // No wider than the gap between neighbors on a ring, so labels side by
    // side don't run into each other.
    final label = text.layout(
      name,
      nameStyle,
      maxWidth: RadialNetworkLayout.minArc,
      maxLines: 2,
      align: TextAlign.center,
    );
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
    // The count sits at the right edge and is always shown; the name takes
    // what is left, on as many lines as the bar fits, ending in an ellipsis.
    final inner = node.bounds.deflate(NahpuSpacing.md);
    final count = text.layout(_compact(node.count), style);
    final centerY = node.bounds.center.dy;
    count.paint(
      canvas,
      Offset(inner.right - count.width, centerY - count.height / 2),
    );
    final nameWidth = inner.width - count.width - NahpuSpacing.md;
    final lines = math.min(
      _maxBarLines,
      (node.bounds.height - NahpuSpacing.xs * 2) ~/ count.height,
    );
    if (nameWidth < NahpuControlSize.iconSmall || lines < 1) return;
    final label = text.layout(
      name,
      style,
      maxWidth: nameWidth,
      maxLines: lines,
    );
    label.paint(canvas, Offset(inner.left, centerY - label.height / 2));
  }

  /// Most lines a bar label wraps to before it ends in an ellipsis.
  static const _maxBarLines = 2;

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
      oldDelegate.start != start ||
      oldDelegate.viewport != viewport ||
      oldDelegate.colorScheme != colorScheme;
}

/// Laid-out labels reused across frames, so panning and zooming never lay
/// out text again.
class _TextCache {
  static const _maxEntries = 4000;

  final _entries = <(String, TextStyle, double, int, TextAlign), TextPainter>{};

  /// Lays [text] out on at most [maxLines] lines no wider than [maxWidth],
  /// ending in an ellipsis when it doesn't fit. Without a [maxWidth] the text
  /// takes its natural width on one line.
  TextPainter layout(
    String text,
    TextStyle style, {
    double maxWidth = double.infinity,
    int maxLines = 1,
    TextAlign align = TextAlign.start,
  }) {
    final key = (text, style, maxWidth, maxLines, align);
    final cached = _entries[key];
    if (cached != null) return cached;
    if (_entries.length >= _maxEntries) clear();
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
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
