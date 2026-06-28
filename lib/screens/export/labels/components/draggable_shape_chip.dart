import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nahpu/screens/export/labels/label_template_editor_screen.dart';
import 'package:nahpu/screens/export/labels/label_template_model.dart';

enum _ShapeCorner { tl, tr, bl, br }

const double _kPdfPointsPerMm = 72.0 / 25.4;

double _canvasScaleForMmMath(double scale) => scale < 1e-9 ? 1e-9 : scale;

double _clampMm(double value, double bound1, double bound2) {
  final lo = bound1 <= bound2 ? bound1 : bound2;
  final hi = bound1 <= bound2 ? bound2 : bound1;
  if (value.isNaN || value.isInfinite) return lo;
  return value.clamp(lo, hi);
}

class DraggableShapeChip extends StatefulWidget {
  const DraggableShapeChip({
    super.key,
    required this.shapeType,
    required this.position,
    required this.widthMm,
    required this.heightMm,
    this.rotationDegrees = 0,
    this.strokeThicknessPt = 1.0,
    this.strokeColorArgb = 0xFF000000,
    this.fillColorArgb,
    required this.scale,
    required this.labelWidthMm,
    required this.labelHeightMm,
    this.canvasInsetXPx = 0,
    this.canvasInsetYPx = 0,
    required this.labelPanToMmDelta,
    required this.onMoved,
    required this.onBoundsChanged,
    required this.onRotationChanged,
    this.onDelete,
    this.isSelected = false,
    this.onTap,
    this.onDragStateChanged,
  });

  final String shapeType; // 'rect' or 'ellipse'
  final Offset position;
  final double widthMm;
  final double heightMm;
  final int rotationDegrees;
  final double strokeThicknessPt;
  final int strokeColorArgb;
  final int? fillColorArgb;
  final double scale;
  final double labelWidthMm;
  final double labelHeightMm;

  /// Pixels added to [position] so chips align with the white label when the
  /// interactive stack is asymmetrically padded (e.g. hit area on one side).
  final double canvasInsetXPx;
  final double canvasInsetYPx;
  final LabelPanMmDeltaCallback labelPanToMmDelta;
  final void Function(Offset newPosMm) onMoved;
  final void Function(double xMm, double yMm, double widthMm, double heightMm)
      onBoundsChanged;
  final void Function(int rotationDegrees) onRotationChanged;
  final VoidCallback? onDelete;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onDragStateChanged;

  @override
  State<DraggableShapeChip> createState() => DraggableShapeChipState();
}

class DraggableShapeChipState extends State<DraggableShapeChip> {
  static const double _handleVisual = 10;
  static const double _handleHit = 24;

  void _deferSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  final GlobalKey _measureKey = GlobalKey();

  bool _moving = false;
  _ShapeCorner? _resizeCorner;
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
    final s = _canvasScaleForMmMath(widget.scale);
    final fromStack = widget.labelPanToMmDelta(globalPos, globalDelta);
    if (fromStack != null) return fromStack;
    return Offset(globalDelta.dx / s, globalDelta.dy / s);
  }

  int get _effectiveRotationDeg => _rotateLiveDeg ?? widget.rotationDegrees;

  /// Drag in label mm → delta along image unrotated width/height (mm).
  Offset _labelDeltaToImageLocalMm(Offset dLabelMm) {
    final rad = _effectiveRotationDeg * math.pi / 180;
    final cosT = math.cos(rad);
    final sinT = math.sin(rad);
    final dlx = dLabelMm.dx * cosT - dLabelMm.dy * sinT;
    final dly = dLabelMm.dx * sinT + dLabelMm.dy * cosT;
    return Offset(dlx, dly);
  }

  void _onResizePanStart(DragStartDetails d, _ShapeCorner c) {
    widget.onDragStateChanged?.call(true);
    _beginResize(c);
    _resizePanLastGlobal = d.globalPosition;
  }

  void _beginResize(_ShapeCorner c) {
    _resizeCorner = c;
    _resizeStart = Rect.fromLTWH(
      widget.position.dx,
      widget.position.dy,
      widget.widthMm,
      widget.heightMm,
    );
    _resizeAccum = Offset.zero;
  }

  void _onResizePanUpdate(DragUpdateDetails d) {
    if (_resizeCorner == null || _resizeStart == null) return;
    final last = _resizePanLastGlobal ?? d.globalPosition;
    final gDelta = d.globalPosition - last;
    _resizePanLastGlobal = d.globalPosition;
    final dLabelMm = _mmDeltaFromGlobalDrag(d.globalPosition, gDelta);
    _resizeAccum += _labelDeltaToImageLocalMm(dLabelMm);
    final s = _resizeStart!;
    final a = _resizeAccum;
    late double x;
    late double y;
    late double rw;
    late double rh;
    switch (_resizeCorner!) {
      case _ShapeCorner.br:
        x = s.left;
        y = s.top;
        rw = s.width + a.dx;
        rh = s.height + a.dy;
        break;
      case _ShapeCorner.tr:
        x = s.left;
        y = s.top + a.dy;
        rw = s.width + a.dx;
        rh = s.height - a.dy;
        break;
      case _ShapeCorner.bl:
        x = s.left + a.dx;
        y = s.top;
        rw = s.width - a.dx;
        rh = s.height + a.dy;
        break;
      case _ShapeCorner.tl:
        x = s.left + a.dx;
        y = s.top + a.dy;
        rw = s.width - a.dx;
        rh = s.height - a.dy;
        break;
    }
    rw = rw.clamp(2.0, widget.labelWidthMm);
    rh = rh.clamp(2.0, widget.labelHeightMm);
    x = _clampMm(x, 0, math.max(0.0, widget.labelWidthMm - rw));
    y = _clampMm(y, 0, math.max(0.0, widget.labelHeightMm - rh));
    setState(() => _resizeLiveRect = Rect.fromLTWH(x, y, rw, rh));
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
    _resizeCorner = null;
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
    var delta = cur - _rotateStartFingerRad!;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    final deg = CustomImageElement.normalizeImageRotationDegrees(
      _rotateStartElemDeg! + delta * 180 / math.pi,
    );
    setState(() => _rotateLiveDeg = deg);
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
  Widget _cornerHandle(
    _ShapeCorner corner,
    ColorScheme scheme, {
    required double innerLeft,
    required double innerTop,
    required double innerW,
    required double innerH,
  }) {
    final o = _handleHit / 2;
    late final double left;
    late final double top;
    switch (corner) {
      case _ShapeCorner.tl:
        left = innerLeft - o;
        top = innerTop - o;
        break;
      case _ShapeCorner.tr:
        left = innerLeft + innerW - o;
        top = innerTop - o;
        break;
      case _ShapeCorner.bl:
        left = innerLeft - o;
        top = innerTop + innerH - o;
        break;
      case _ShapeCorner.br:
        left = innerLeft + innerW - o;
        top = innerTop + innerH - o;
        break;
    }
    return Positioned(
      left: left,
      top: top,
      width: _handleHit,
      height: _handleHit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _onResizePanStart(d, corner),
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
    final effWmm = liveR?.width ?? widget.widthMm;
    final effHmm = liveR?.height ?? widget.heightMm;
    final left = posMm.dx * widget.scale + insetX;
    final top = posMm.dy * widget.scale + insetY;
    final w = effWmm * widget.scale;
    final h = effHmm * widget.scale;
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

    final rad = _effectiveRotationDeg * math.pi / 180;
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
                  onPanStart: (d) {
                    widget.onDragStateChanged?.call(true);
                    _imageMoveSession++;
                    _imagePanOriginMm = widget.position;
                    _imagePanAccumMm = Offset.zero;
                    _imageDragLiveMm = null;
                    _deferSetState(() => _moving = true);
                    _imageMovePanLastGlobal = d.globalPosition;
                  },
                  onPanUpdate: (details) {
                    final last =
                        _imageMovePanLastGlobal ?? details.globalPosition;
                    final gDelta = details.globalPosition - last;
                    _imageMovePanLastGlobal = details.globalPosition;
                    final dMm =
                        _mmDeltaFromGlobalDrag(details.globalPosition, gDelta);
                    final origin = _imagePanOriginMm ?? widget.position;
                    _imagePanAccumMm += dMm;
                    final lr = _resizeLiveRect;
                    final w = lr?.width ?? widget.widthMm;
                    final h = lr?.height ?? widget.heightMm;
                    final rad = _effectiveRotationDeg * math.pi / 180;
                    final cosT = math.cos(rad).abs();
                    final sinT = math.sin(rad).abs();
                    final halfBoundX = (w * cosT + h * sinT) / 2;
                    final halfBoundY = (w * sinT + h * cosT) / 2;
                    final minX = halfBoundX - w / 2;
                    final maxX = widget.labelWidthMm - w / 2 - halfBoundX;
                    final minY = halfBoundY - h / 2;
                    final maxY = widget.labelHeightMm - h / 2 - halfBoundY;
                    final rawX = origin.dx + _imagePanAccumMm.dx;
                    final rawY = origin.dy + _imagePanAccumMm.dy;
                    final cx = _clampMm(rawX, minX, maxX);
                    final cy = _clampMm(rawY, minY, maxY);
                    if (cx != rawX || cy != rawY) {
                      _imagePanOriginMm = Offset(cx, cy);
                      _imagePanAccumMm = Offset.zero;
                    }
                    final clamped = Offset(cx, cy);
                    setState(() => _imageDragLiveMm = clamped);
                  },
                  onPanEnd: (_) {
                    _deferSetState(() => _moving = false);
                    _finishImageMoveGesture();
                    widget.onDragStateChanged?.call(false);
                  },
                  onPanCancel: () {
                    _deferSetState(() => _moving = false);
                    _finishImageMoveGesture();
                    widget.onDragStateChanged?.call(false);
                  },
                  child: AnimatedContainer(
                    duration: (_resizeCorner != null ||
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
                                color: scheme.primary.withValues(alpha: 0.25),
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
                        Container(
                          width: w,
                          height: h,
                          decoration: BoxDecoration(
                            color: widget.fillColorArgb != null
                                ? Color(widget.fillColorArgb!)
                                : null,
                            border: Border.all(
                              color: Color(widget.strokeColorArgb),
                              width: widget.strokeThicknessPt *
                                  widget.scale /
                                  _kPdfPointsPerMm,
                            ),
                            shape: widget.shapeType == 'ellipse'
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                          ),
                        ),
                        Positioned(
                          left: 2,
                          top: 2,
                          child: Icon(
                            Icons.drag_indicator,
                            size: 14,
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.isSelected) ...[
                _cornerHandle(_ShapeCorner.tl, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(_ShapeCorner.tr, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(_ShapeCorner.bl, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(_ShapeCorner.br, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                Positioned(
                  left: padL + w / 2 - 20,
                  top: math.max(
                    0.0,
                    padT - 42 - (widget.onDelete != null ? 34.0 : 0.0),
                  ),
                  width: 40,
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
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: _beginRotate,
                          onPanUpdate: _onRotatePanUpdate,
                          onPanEnd: (_) => _deferSetState(_endRotate),
                          onPanCancel: () => _deferSetState(_endRotate),
                          child: Tooltip(
                            message: 'Drag to rotate',
                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                size: 18,
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
