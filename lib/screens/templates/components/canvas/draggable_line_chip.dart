import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/template_editor_math.dart';
import 'package:nahpu/screens/templates/template_model.dart';

enum _LineHandle { left, right }

const double _kPdfPointsPerMm = 72.0 / 25.4;

class DraggableLineChip extends StatefulWidget {
  const DraggableLineChip({
    super.key,
    required this.position,
    required this.lengthMm,
    this.rotationDegrees = 0,
    this.thicknessPt = 1.0,
    this.colorArgb = 0xFF000000,
    this.strokeStyle = 'solid',
    required this.scale,
    required this.templateWidthMm,
    required this.templateHeightMm,
    this.canvasInsetXPx = 0,
    this.canvasInsetYPx = 0,
    required this.templatePanToMmDelta,
    required this.onMoved,
    required this.onBoundsChanged,
    required this.onRotationChanged,
    this.onDelete,
    this.isSelected = false,
    this.onTap,
    this.onDragStateChanged,
    this.isLocked = false,
    this.isVisible = true,
  });

  final Offset position;
  final double lengthMm;
  final int rotationDegrees;
  final double thicknessPt;
  final int colorArgb;
  final String strokeStyle;
  final double scale;
  final double templateWidthMm;
  final double templateHeightMm;

  /// Pixels added to [position] so chips align with the white template when the
  /// interactive stack is asymmetrically padded (e.g. hit area on one side).
  final double canvasInsetXPx;
  final double canvasInsetYPx;
  final TemplatePanMmDeltaCallback templatePanToMmDelta;
  final void Function(Offset newPosMm) onMoved;
  final void Function(double xMm, double yMm, double widthMm, double heightMm)
      onBoundsChanged;
  final void Function(int rotationDegrees) onRotationChanged;
  final VoidCallback? onDelete;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onDragStateChanged;
  final bool isLocked;
  final bool isVisible;

  @override
  State<DraggableLineChip> createState() => DraggableLineChipState();
}

class DraggableLineChipState extends State<DraggableLineChip> {
  static const double _handleVisual = 16;
  static const double _handleHit = 36;

  void _deferSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  final GlobalKey _measureKey = GlobalKey();

  bool _moving = false;
  _LineHandle? _resizeHandle;
  Rect? _resizeStart;
  Offset _resizeAccum = Offset.zero;

  /// During corner resize, parent template updates post-frame; local rect keeps UI in sync.
  Rect? _resizeLiveRect;

  double? _rotateStartFingerRad;
  int? _rotateStartElemDeg;
  int? _rotateLiveDeg;

  /// Last global position for this drag; [DragUpdateDetails.delta] is local.
  Offset? _imageMovePanLastGlobal;
  Offset? _resizePanLastGlobal;

  Offset? _imagePanOriginMm;
  Offset _imagePanAccumMm = Offset.zero;
  Offset? _imageDragLiveMm;
  int _imageMoveSession = 0;

  Offset _mmDeltaFromGlobalDrag(Offset globalPos, Offset globalDelta) {
    final fromStack = widget.templatePanToMmDelta(globalPos, globalDelta);
    if (fromStack != null) return fromStack;
    return pixelsToTemplateMm(globalDelta, widget.scale);
  }

  int get _effectiveRotationDeg => _rotateLiveDeg ?? widget.rotationDegrees;

  /// Drag in template mm -> delta along the line's unrotated local axis.
  Offset _labelDeltaToImageLocalMm(Offset dLabelMm) {
    return templateDeltaToElementLocalMm(dLabelMm, _effectiveRotationDeg);
  }

  void _onResizePanStart(DragStartDetails d, _LineHandle h) {
    widget.onDragStateChanged?.call(true);
    _beginResize(h);
    _resizePanLastGlobal = d.globalPosition;
  }

  void _beginResize(_LineHandle h) {
    _resizeHandle = h;
    _resizeStart = Rect.fromLTWH(
      widget.position.dx,
      widget.position.dy,
      widget.lengthMm,
      math.max(2.0,
          widget.thicknessPt * 0.3527), // convert pt to mm approx for bounds
    );
    _resizeAccum = Offset.zero;
  }

  void _onResizePanUpdate(DragUpdateDetails d) {
    if (_resizeHandle == null || _resizeStart == null) return;
    final last = _resizePanLastGlobal ?? d.globalPosition;
    final gDelta = d.globalPosition - last;
    _resizePanLastGlobal = d.globalPosition;
    final dLabelMm = _mmDeltaFromGlobalDrag(d.globalPosition, gDelta);
    _resizeAccum += _labelDeltaToImageLocalMm(dLabelMm);
    final s = _resizeStart!;
    final a = _resizeAccum;

    final rad = degreesToRadians(_effectiveRotationDeg);
    final cosT = math.cos(rad);
    final sinT = math.sin(rad);

    final hMm = math.max(2.0, widget.thicknessPt * 0.3527);
    final lStart = s.width;

    late double rw;
    late double x;
    late double y;

    switch (_resizeHandle!) {
      case _LineHandle.right:
        final startXFixed = s.left + lStart / 2 * (1 - cosT);
        final startYFixed = s.top + hMm / 2 - lStart / 2 * sinT;

        rw = (s.width + a.dx).clamp(2.0, widget.templateWidthMm);

        x = startXFixed - rw / 2 * (1 - cosT);
        y = startYFixed - hMm / 2 + rw / 2 * sinT;
        break;

      case _LineHandle.left:
        final endXFixed = s.left + lStart / 2 * (1 + cosT);
        final endYFixed = s.top + hMm / 2 + lStart / 2 * sinT;

        rw = (s.width - a.dx).clamp(2.0, widget.templateWidthMm);

        x = endXFixed - rw / 2 * (1 + cosT);
        y = endYFixed - hMm / 2 - rw / 2 * sinT;
        break;
    }

    setState(() => _resizeLiveRect = Rect.fromLTWH(x, y, rw, s.height));
  }

  void _endResize() {
    widget.onDragStateChanged?.call(false);
    if (_resizeLiveRect != null) {
      widget.onBoundsChanged(
        _resizeLiveRect!.left,
        _resizeLiveRect!.top,
        _resizeLiveRect!.width,
        _resizeLiveRect!.height,
      );
    }
    _resizeHandle = null;
    _resizeStart = null;
    _resizeAccum = Offset.zero;
    _resizePanLastGlobal = null;
    _resizeLiveRect = null;
  }

  void _beginRotate(DragStartDetails d) {
    widget.onDragStateChanged?.call(true);
    _rotateStartElemDeg = widget.rotationDegrees;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final c =
        box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
    _rotateStartFingerRad =
        math.atan2(d.globalPosition.dy - c.dy, d.globalPosition.dx - c.dx);
  }

  void _onRotatePanUpdate(DragUpdateDetails d) {
    if (_rotateStartFingerRad == null || _rotateStartElemDeg == null) return;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final c =
        box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
    final cur =
        math.atan2(d.globalPosition.dy - c.dy, d.globalPosition.dx - c.dx);
    final delta = normalizeRadiansDelta(cur - _rotateStartFingerRad!);
    final deg = CustomImageElement.normalizeImageRotationDegrees(
      _rotateStartElemDeg! + radiansToDegrees(delta),
    );
    setState(() => _rotateLiveDeg = deg);
  }

  void _endRotate() {
    widget.onDragStateChanged?.call(false);
    if (_rotateLiveDeg != null) {
      widget.onRotationChanged(_rotateLiveDeg!);
    }
    _rotateStartFingerRad = null;
    _rotateStartElemDeg = null;
    _rotateLiveDeg = null;
  }

  /// [innerLeft]/[innerTop] = top-left of the image rect inside the padded stack.
  Widget _lineHandle(
    _LineHandle handle,
    ColorScheme scheme, {
    required double innerLeft,
    required double innerTop,
    required double innerW,
    required double innerH,
  }) {
    final o = _handleHit / 2;
    late final double left;
    final double top = innerTop + innerH / 2 - o;
    switch (handle) {
      case _LineHandle.left:
        left = innerLeft - o;
        break;
      case _LineHandle.right:
        left = innerLeft + innerW - o;
        break;
    }
    return Positioned(
      left: left,
      top: top,
      width: _handleHit,
      height: _handleHit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _onResizePanStart(d, handle),
        onPanUpdate: _onResizePanUpdate,
        onPanEnd: (_) => _deferSetState(_endResize),
        onPanCancel: () => _deferSetState(_endResize),
        child: Center(
          child: Container(
            width: _handleVisual,
            height: _handleVisual,
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _finishImageMoveGesture() {
    final session = _imageMoveSession;
    if (_imageDragLiveMm != null) {
      widget.onMoved(_imageDragLiveMm!);
    }
    _imageMovePanLastGlobal = null;
    _imagePanOriginMm = null;
    _imagePanAccumMm = Offset.zero;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || session != _imageMoveSession) return;
      setState(() => _imageDragLiveMm = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final insetX = widget.canvasInsetXPx;
    final insetY = widget.canvasInsetYPx;
    final liveR = _resizeLiveRect;
    final posMm = liveR != null
        ? Offset(liveR.left, liveR.top)
        : (_imageDragLiveMm ?? widget.position);
    final effWmm = liveR?.width ?? widget.lengthMm;
    final left = posMm.dx * widget.scale + insetX;
    final top = posMm.dy * widget.scale + insetY;
    final w = (effWmm * widget.scale).clamp(0.0, double.infinity);
    final lineThicknessPx =
        math.max(1.0, widget.thicknessPt * widget.scale / _kPdfPointsPerMm);
    final double gapPx = lineThicknessPx * 1.25;
    final double h = widget.strokeStyle == 'double'
        ? lineThicknessPx * 2.0 + gapPx
        : lineThicknessPx;
    final scheme = Theme.of(context).colorScheme;

    final borderColor = _moving
        ? scheme.primary
        : widget.isSelected
            ? scheme.primary
            : scheme.outline;

    // Padded outer stack so handles/rotate sit inside hit-test bounds (Flutter
    // does not hit-test children outside a tight w×h Stack).
    final padL = _handleHit / 2 + 6;
    final padR = _handleHit / 2 + 6;
    final padT = 52.0;
    final padB = _handleHit / 2 + 6;
    final outerW = w + padL + padR;
    final outerH = h + padT + padB;

    final rad = degreesToRadians(_effectiveRotationDeg);
    final pivotX = padL + w / 2;
    final pivotY = padT + h / 2;
    final rot = Matrix4.identity()
      ..translateByDouble(pivotX, pivotY, 0, 1)
      ..rotateZ(rad)
      ..translateByDouble(-pivotX, -pivotY, 0, 1);

    return Positioned(
      left: left - padL,
      top: top - padT,
      child: Transform(
        transform: rot,
        child: SizedBox(
          width: outerW,
          height: outerH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: padL,
                top: padT,
                width: w,
                height: h,
                child: GestureDetector(
                  key: _measureKey,
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => widget.onTap?.call(),
                  onTap: widget.onTap,
                  onPanStart: widget.isLocked
                      ? null
                      : (d) {
                          widget.onDragStateChanged?.call(true);
                          _imageMoveSession++;
                          _imagePanOriginMm = widget.position;
                          _imagePanAccumMm = Offset.zero;
                          _imageDragLiveMm = null;
                          _deferSetState(() => _moving = true);
                          _imageMovePanLastGlobal = d.globalPosition;
                        },
                  onPanUpdate: widget.isLocked
                      ? null
                      : (details) {
                          final last =
                              _imageMovePanLastGlobal ?? details.globalPosition;
                          final gDelta = details.globalPosition - last;
                          _imageMovePanLastGlobal = details.globalPosition;
                          final dMm = _mmDeltaFromGlobalDrag(
                              details.globalPosition, gDelta);
                          final origin = _imagePanOriginMm ?? widget.position;
                          _imagePanAccumMm += dMm;
                          final lr = _resizeLiveRect;
                          final w = lr?.width ?? widget.lengthMm;
                          final h = lr?.height ??
                              math.max(1.0, widget.thicknessPt * 0.3527);
                          final rad = degreesToRadians(_effectiveRotationDeg);
                          final cosT = math.cos(rad).abs();
                          final sinT = math.sin(rad).abs();
                          final halfBoundX = (w * cosT + h * sinT) / 2;
                          final halfBoundY = (w * sinT + h * cosT) / 2;
                          final minX = halfBoundX - w / 2;
                          final maxX =
                              widget.templateWidthMm - w / 2 - halfBoundX;
                          final minY = halfBoundY - h / 2;
                          final maxY =
                              widget.templateHeightMm - h / 2 - halfBoundY;
                          final rawX = origin.dx + _imagePanAccumMm.dx;
                          final rawY = origin.dy + _imagePanAccumMm.dy;
                          final cx = clampFiniteMm(rawX, minX, maxX);
                          final cy = clampFiniteMm(rawY, minY, maxY);
                          if (cx != rawX || cy != rawY) {
                            _imagePanOriginMm = Offset(cx, cy);
                            _imagePanAccumMm = Offset.zero;
                          }
                          final clamped = Offset(cx, cy);
                          setState(() => _imageDragLiveMm = clamped);
                        },
                  onPanEnd: widget.isLocked
                      ? null
                      : (_) {
                          _deferSetState(() => _moving = false);
                          _finishImageMoveGesture();
                          widget.onDragStateChanged?.call(false);
                        },
                  onPanCancel: widget.isLocked
                      ? null
                      : () {
                          _deferSetState(() => _moving = false);
                          _finishImageMoveGesture();
                          widget.onDragStateChanged?.call(false);
                        },
                  child: widget.isVisible
                      ? AnimatedContainer(
                          duration: (_resizeHandle != null ||
                                  _rotateStartFingerRad != null ||
                                  _moving)
                              ? Duration.zero
                              : const Duration(milliseconds: 100),
                          width: w,
                          height: h,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: borderColor,
                              width: (widget.isSelected || _moving) ? 2.0 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: scheme.surfaceContainerHighest,
                            boxShadow: _moving
                                ? [
                                    BoxShadow(
                                      color: scheme.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            clipBehavior: Clip.none,
                            fit: StackFit.expand,
                            children: [
                              CustomPaint(
                                size: Size(w, h),
                                painter: LinePainter(
                                  color: Color(widget.colorArgb),
                                  thicknessPx: lineThicknessPx,
                                  strokeStyle: widget.strokeStyle,
                                ),
                              ),
                              Positioned(
                                left: 2,
                                top: 2,
                                child: Icon(
                                  Icons.drag_indicator,
                                  size: 14,
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Opacity(
                          opacity: 0.35,
                          child: AnimatedContainer(
                            duration: (_resizeHandle != null ||
                                    _rotateStartFingerRad != null ||
                                    _moving)
                                ? Duration.zero
                                : const Duration(milliseconds: 100),
                            width: w,
                            height: h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor,
                                width:
                                    (widget.isSelected || _moving) ? 2.0 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: scheme.surfaceContainerHighest,
                              boxShadow: _moving
                                  ? [
                                      BoxShadow(
                                        color: scheme.primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              clipBehavior: Clip.none,
                              fit: StackFit.expand,
                              children: [
                                CustomPaint(
                                  size: Size(w, h),
                                  painter: LinePainter(
                                    color: Color(widget.colorArgb),
                                    thicknessPx: lineThicknessPx,
                                    strokeStyle: widget.strokeStyle,
                                  ),
                                ),
                                Positioned(
                                  left: 2,
                                  top: 2,
                                  child: Icon(
                                    Icons.drag_indicator,
                                    size: 14,
                                    color:
                                        scheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              if (widget.isSelected && !widget.isLocked) ...[
                _lineHandle(_LineHandle.left, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _lineHandle(_LineHandle.right, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                Positioned(
                  left: padL + w / 2 - 24,
                  top: math.max(
                    0.0,
                    padT - 42 - (widget.onDelete != null ? 34.0 : 0.0),
                  ),
                  width: 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onDelete != null) ...[
                        IconButton.filled(
                          tooltip: 'Remove shape',
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.close, size: 13),
                          style: IconButton.styleFrom(
                            backgroundColor: scheme.error,
                            foregroundColor: scheme.onError,
                            fixedSize: const Size(26, 26),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: _beginRotate,
                          onPanUpdate: _onRotatePanUpdate,
                          onPanEnd: (_) => _deferSetState(_endRotate),
                          onPanCancel: () => _deferSetState(_endRotate),
                          child: Tooltip(
                            message: 'Drag to rotate',
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                                border: Border.all(color: scheme.primary),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.rotate_right,
                                size: 22,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  const LinePainter({
    required this.color,
    required this.thicknessPx,
    required this.strokeStyle,
  });

  final Color color;
  final double thicknessPx;
  final String strokeStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thicknessPx
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final y = size.height / 2;
    if (strokeStyle == 'solid') {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    } else if (strokeStyle == 'dashed') {
      final dashLen = thicknessPx * 4;
      final gapLen = thicknessPx * 2.5;
      _drawDashedLine(
        canvas,
        Offset(0, y),
        Offset(size.width, y),
        paint,
        dashLen,
        gapLen,
      );
    } else if (strokeStyle == 'dotted') {
      final dashLen = math.max(0.35, thicknessPx * 0.35);
      final gapLen = thicknessPx * 2.0;
      _drawDashedLine(
        canvas,
        Offset(0, y),
        Offset(size.width, y),
        paint,
        dashLen,
        gapLen,
      );
    } else if (strokeStyle == 'double') {
      final gap = thicknessPx * 1.25;
      final halfOffset = (thicknessPx + gap) / 2;

      final paintDouble = Paint()
        ..color = color
        ..strokeWidth = thicknessPx
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(0, y - halfOffset),
        Offset(size.width, y - halfOffset),
        paintDouble,
      );
      canvas.drawLine(
        Offset(0, y + halfOffset),
        Offset(size.width, y + halfOffset),
        paintDouble,
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint,
    double dashLen,
    double gapLen,
  ) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    double d = 0.0;
    while (d < len) {
      final end = math.min(d + dashLen, len);
      canvas.drawLine(
        Offset(p1.dx + ux * d, p1.dy + uy * d),
        Offset(p1.dx + ux * end, p1.dy + uy * end),
        paint,
      );
      d += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thicknessPx != thicknessPx ||
        oldDelegate.strokeStyle != strokeStyle;
  }
}
