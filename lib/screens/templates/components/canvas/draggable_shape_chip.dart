import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_chip.dart';
import 'package:nahpu/screens/templates/template_editor_math.dart';
import 'package:nahpu/screens/templates/template_model.dart';

enum _ShapeCorner { tl, tr, bl, br }

const double _kPdfPointsPerMm = 72.0 / 25.4;

class DraggableShapeChip extends StatefulWidget {
  const DraggableShapeChip({
    super.key,
    required this.shapeType,
    required this.polygonSides,
    required this.position,
    required this.widthMm,
    required this.heightMm,
    this.rotationDegrees = 0,
    this.strokeThicknessPt = 1.0,
    this.strokeColorArgb = 0xFF000000,
    this.fillColorArgb,
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
    this.snapEnabled = true,
    this.snapTargets = const [],
  });

  final String shapeType; // 'rect', 'ellipse', 'circle', 'triangle', 'polygon'
  final int polygonSides;
  final Offset position;
  final double widthMm;
  final double heightMm;
  final int rotationDegrees;
  final double strokeThicknessPt;
  final int strokeColorArgb;
  final int? fillColorArgb;
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
  final bool snapEnabled;
  final List<CanvasSnapTarget> snapTargets;

  @override
  State<DraggableShapeChip> createState() => DraggableShapeChipState();
}

class DraggableShapeChipState extends State<DraggableShapeChip> {
  static const double _handleVisual = 16;
  static const double _handleHit = 36;
  static const double _snapTolerancePx = 4;
  static const double _snapGuideWidthPx = 1.5;

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
  final CanvasSnapSession _snapSession = CanvasSnapSession();
  CanvasSnapResult? _snapResult;
  int _imageMoveSession = 0;

  Offset _mmDeltaFromGlobalDrag(Offset globalPos, Offset globalDelta) {
    final fromStack = widget.templatePanToMmDelta(globalPos, globalDelta);
    if (fromStack != null) return fromStack;
    return pixelsToTemplateMm(globalDelta, widget.scale);
  }

  int get _effectiveRotationDeg => _rotateLiveDeg ?? widget.rotationDegrees;

  Rect get _widgetRect => Rect.fromLTWH(
        widget.position.dx,
        widget.position.dy,
        widget.widthMm,
        widget.heightMm,
      );

  bool _isSameRect(Rect a, Rect b) {
    const tolerance = 1e-6;
    return (a.left - b.left).abs() < tolerance &&
        (a.top - b.top).abs() < tolerance &&
        (a.width - b.width).abs() < tolerance &&
        (a.height - b.height).abs() < tolerance;
  }

  void _onResizePanStart(DragStartDetails d, _ShapeCorner c) {
    widget.onDragStateChanged?.call(true);
    _beginResize(c);
    _resizePanLastGlobal = d.globalPosition;
  }

  void _beginResize(_ShapeCorner c) {
    _resizeCorner = c;
    _resizeStart = _resizeLiveRect ?? _widgetRect;
    _resizeAccum = Offset.zero;
  }

  void _onResizePanUpdate(DragUpdateDetails d) {
    if (_resizeCorner == null || _resizeStart == null) return;
    final last = _resizePanLastGlobal ?? d.globalPosition;
    final gDelta = d.globalPosition - last;
    _resizePanLastGlobal = d.globalPosition;
    final dLabelMm = _mmDeltaFromGlobalDrag(d.globalPosition, gDelta);
    _resizeAccum += templateDeltaToElementLocalMm(
      dLabelMm,
      _effectiveRotationDeg,
    );
    setState(() {
      _resizeLiveRect = resizedRotatedRectFromCorner(
        startMm: _resizeStart!,
        localDeltaMm: _resizeAccum,
        corner: _resizeCorner!.name,
        rotationDegrees: _effectiveRotationDeg,
        maxWidthMm: widget.templateWidthMm,
        maxHeightMm: widget.templateHeightMm,
      );
    });
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
  }

  @override
  void didUpdateWidget(covariant DraggableShapeChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected && !widget.isSelected) {
      _clearTransientInteractionState();
    }
    if (oldWidget.snapEnabled && !widget.snapEnabled) {
      _snapSession.reset();
      _snapResult = null;
    }
    final liveRect = _resizeLiveRect;
    if (liveRect == null) return;

    final currentRect = _widgetRect;
    if (_isSameRect(liveRect, currentRect)) {
      _resizeLiveRect = null;
      return;
    }

    final oldRect = Rect.fromLTWH(
      oldWidget.position.dx,
      oldWidget.position.dy,
      oldWidget.widthMm,
      oldWidget.heightMm,
    );
    if (!_isSameRect(oldRect, currentRect)) {
      _resizeLiveRect = null;
    }
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
        onPanEnd: (_) => setState(_endResize),
        onPanCancel: () => setState(_endResize),
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
    _snapSession.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || session != _imageMoveSession) return;
      setState(() {
        _imageDragLiveMm = null;
        _snapResult = null;
      });
    });
  }

  void _clearTransientInteractionState() {
    _moving = false;
    _imageDragLiveMm = null;
    _imageMovePanLastGlobal = null;
    _imagePanOriginMm = null;
    _imagePanAccumMm = Offset.zero;
    _snapSession.reset();
    _snapResult = null;
    _resizeCorner = null;
    _resizeStart = null;
    _resizeAccum = Offset.zero;
    _resizeLiveRect = null;
    _resizePanLastGlobal = null;
    _rotateStartFingerRad = null;
    _rotateStartElemDeg = null;
    _rotateLiveDeg = null;
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

    final rad = degreesToRadians(_effectiveRotationDeg);
    final pivotX = padL + w / 2;
    final pivotY = padT + h / 2;
    final rot = Matrix4.identity()
      ..translateByDouble(pivotX, pivotY, 0, 1)
      ..rotateZ(rad)
      ..translateByDouble(-pivotX, -pivotY, 0, 1);

    final chip = Positioned(
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
                          _snapSession.reset();
                          _snapResult = null;
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
                          final w = lr?.width ?? widget.widthMm;
                          final h = lr?.height ?? widget.heightMm;
                          final rawX = origin.dx + _imagePanAccumMm.dx;
                          final rawY = origin.dy + _imagePanAccumMm.dy;
                          final clamped = clampRotatedRectTopLeft(
                            positionMm: Offset(rawX, rawY),
                            widthMm: w,
                            heightMm: h,
                            rotationDegrees: _effectiveRotationDeg,
                            canvasWidthMm: widget.templateWidthMm,
                            canvasHeightMm: widget.templateHeightMm,
                          );
                          final cx = clamped.dx;
                          final cy = clamped.dy;
                          if (cx != rawX || cy != rawY) {
                            _imagePanOriginMm = Offset(cx, cy);
                            _imagePanAccumMm = Offset.zero;
                          }
                          final snapResult = _snapSession.resolve(
                            position: clamped,
                            snapEnabled: widget.snapEnabled,
                            snapTargets: [
                              CanvasSnapTarget(
                                xMm: widget.templateWidthMm / 2,
                                yMm: widget.templateHeightMm / 2,
                              ),
                              ...widget.snapTargets,
                            ],
                            toleranceMm: _snapTolerancePx / widget.scale,
                          );
                          setState(() {
                            _imageDragLiveMm = snapResult.position;
                            _snapResult =
                                snapResult.hasGuide ? snapResult : null;
                          });
                        },
                  onPanEnd: widget.isLocked
                      ? null
                      : (_) {
                          setState(() {
                            _moving = false;
                            _snapResult = null;
                          });
                          _finishImageMoveGesture();
                          widget.onDragStateChanged?.call(false);
                        },
                  onPanCancel: widget.isLocked
                      ? null
                      : () {
                          setState(() {
                            _moving = false;
                            _snapResult = null;
                          });
                          _finishImageMoveGesture();
                          widget.onDragStateChanged?.call(false);
                        },
                  child: widget.isVisible
                      ? AnimatedContainer(
                          duration: (_resizeCorner != null ||
                                  _rotateStartFingerRad != null ||
                                  _moving)
                              ? Duration.zero
                              : const Duration(milliseconds: 100),
                          width: w,
                          height: h,
                          decoration: BoxDecoration(
                            border: (widget.isSelected || _moving)
                                ? Border.all(color: borderColor, width: 2.0)
                                : null,
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.transparent,
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
                                painter: ShapePainter(
                                  shapeType: widget.shapeType,
                                  polygonSides: widget.polygonSides,
                                  strokeColor: Color(widget.strokeColorArgb),
                                  fillColor: widget.fillColorArgb != null
                                      ? Color(widget.fillColorArgb!)
                                      : null,
                                  strokeThicknessPx: widget.strokeThicknessPt *
                                      widget.scale /
                                      _kPdfPointsPerMm,
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
                            duration: (_resizeCorner != null ||
                                    _rotateStartFingerRad != null ||
                                    _moving)
                                ? Duration.zero
                                : const Duration(milliseconds: 100),
                            width: w,
                            height: h,
                            decoration: BoxDecoration(
                              border: (widget.isSelected || _moving)
                                  ? Border.all(color: borderColor, width: 2.0)
                                  : null,
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.transparent,
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
                                  painter: ShapePainter(
                                    shapeType: widget.shapeType,
                                    polygonSides: widget.polygonSides,
                                    strokeColor: Color(widget.strokeColorArgb),
                                    fillColor: widget.fillColorArgb != null
                                        ? Color(widget.fillColorArgb!)
                                        : null,
                                    strokeThicknessPx:
                                        widget.strokeThicknessPt *
                                            widget.scale /
                                            _kPdfPointsPerMm,
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
                _cornerHandle(_ShapeCorner.tl, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(_ShapeCorner.tr, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(_ShapeCorner.bl, scheme,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(_ShapeCorner.br, scheme,
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
    final snapResult = _snapResult;
    if (snapResult == null) return chip;
    final guideColor = scheme.primary.withValues(alpha: 0.65);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (snapResult.verticalGuideMm != null)
          Positioned(
            left: snapResult.verticalGuideMm! * widget.scale +
                widget.canvasInsetXPx -
                _snapGuideWidthPx / 2,
            top: widget.canvasInsetYPx,
            width: _snapGuideWidthPx,
            height: widget.templateHeightMm * widget.scale,
            child: IgnorePointer(child: ColoredBox(color: guideColor)),
          ),
        if (snapResult.horizontalGuideMm != null)
          Positioned(
            left: widget.canvasInsetXPx,
            top: widget.canvasInsetYPx +
                snapResult.horizontalGuideMm! * widget.scale -
                _snapGuideWidthPx / 2,
            width: widget.templateWidthMm * widget.scale,
            height: _snapGuideWidthPx,
            child: IgnorePointer(child: ColoredBox(color: guideColor)),
          ),
        chip,
      ],
    );
  }
}

class ShapePainter extends CustomPainter {
  const ShapePainter({
    required this.shapeType,
    required this.polygonSides,
    required this.strokeColor,
    required this.fillColor,
    required this.strokeThicknessPx,
    required this.strokeStyle,
  });

  final String shapeType; // 'rect', 'ellipse', 'circle', 'triangle', 'polygon'
  final int polygonSides;
  final Color strokeColor;
  final Color? fillColor;
  final double strokeThicknessPx;
  final String strokeStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor ?? Colors.transparent
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeThicknessPx
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Draw fill
    if (fillColor != null) {
      canvas.drawPath(_shapePath(rect), fillPaint);
    }

    // 2. Draw stroke
    if (strokeThicknessPx > 0) {
      final inset = strokeThicknessPx / 2;
      final strokeRect = Rect.fromLTWH(
        inset,
        inset,
        (size.width - strokeThicknessPx).clamp(0.0, double.infinity),
        (size.height - strokeThicknessPx).clamp(0.0, double.infinity),
      );

      if (strokeStyle == 'solid') {
        canvas.drawPath(_shapePath(strokeRect), strokePaint);
      } else if (strokeStyle == 'dashed') {
        _drawDashedBorder(
          canvas,
          strokeRect,
          strokePaint,
          strokeThicknessPx * 4,
          strokeThicknessPx * 2.5,
        );
      } else if (strokeStyle == 'dotted') {
        _drawDashedBorder(
          canvas,
          strokeRect,
          strokePaint,
          math.max(0.35, strokeThicknessPx * 0.35),
          strokeThicknessPx * 2.0,
        );
      } else if (strokeStyle == 'double') {
        // Outer stroke
        canvas.drawPath(_shapePath(strokeRect), strokePaint);

        // Inner stroke
        final gap = (strokeThicknessPx * 1.25).clamp(1.0, 10.0);
        final doubleInset = strokeThicknessPx + gap;
        final innerRect = Rect.fromLTWH(
          doubleInset + strokeThicknessPx / 2,
          doubleInset + strokeThicknessPx / 2,
          (size.width - 2 * doubleInset - strokeThicknessPx)
              .clamp(0.0, double.infinity),
          (size.height - 2 * doubleInset - strokeThicknessPx)
              .clamp(0.0, double.infinity),
        );
        if (innerRect.width > 0 && innerRect.height > 0) {
          canvas.drawPath(_shapePath(innerRect), strokePaint);
        }
      }
    }
  }

  Path _shapePath(Rect rect) {
    final path = Path();
    switch (shapeType) {
      case 'ellipse':
        path.addOval(rect);
        break;
      case 'circle':
        final side = math.min(rect.width, rect.height);
        final circleRect = Rect.fromCenter(
          center: rect.center,
          width: side,
          height: side,
        );
        path.addOval(circleRect);
        break;
      case 'triangle':
        _addRegularPolygon(path, rect, 3);
        break;
      case 'polygon':
        _addRegularPolygon(path, rect, polygonSides.clamp(3, 12));
        break;
      case 'rect':
      default:
        path.addRect(rect);
        break;
    }
    return path;
  }

  void _addRegularPolygon(Path path, Rect rect, int sides) {
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;
    final center = rect.center;
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      final point = Offset(
        center.dx + radiusX * math.cos(angle),
        center.dy + radiusY * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
  }

  void _drawDashedBorder(
    Canvas canvas,
    Rect r,
    Paint paint,
    double dashLen,
    double gapLen,
  ) {
    final path = _shapePath(r);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final len = math.min(dashLen, metric.length - d);
        canvas.drawPath(metric.extractPath(d, d + len), paint);
        d += len + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.polygonSides != polygonSides ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeThicknessPx != strokeThicknessPx ||
        oldDelegate.strokeStyle != strokeStyle;
  }
}
