import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/template_editor_math.dart';
import 'package:nahpu/screens/templates/template_model.dart';

enum _ImageCorner { tl, tr, bl, br }

class DraggableImageChip extends StatefulWidget {
  const DraggableImageChip({
    super.key,
    required this.imagePath,
    required this.position,
    required this.widthMm,
    required this.heightMm,
    this.rotationDegrees = 0,
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
    this.vectorChild,
    this.onDragStateChanged,
  });

  final String imagePath;
  final Offset position;
  final double widthMm;
  final double heightMm;
  final int rotationDegrees;
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

  /// When set, drawn instead of [imagePath] (e.g. sex icon for `[*.sex]-img`).
  final Widget? vectorChild;

  @override
  State<DraggableImageChip> createState() => DraggableImageChipState();
}

class DraggableImageChipState extends State<DraggableImageChip> {
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
  _ImageCorner? _resizeCorner;
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

  void _onResizePanStart(DragStartDetails d, _ImageCorner c) {
    widget.onDragStateChanged?.call(true);
    _beginResize(c);
    _resizePanLastGlobal = d.globalPosition;
  }

  void _beginResize(_ImageCorner c) {
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
  Widget _cornerHandle(
    ColorScheme scheme,
    _ImageCorner corner, {
    required double innerLeft,
    required double innerTop,
    required double innerW,
    required double innerH,
  }) {
    final o = _handleHit / 2;
    late final double left;
    late final double top;
    switch (corner) {
      case _ImageCorner.tl:
        left = innerLeft - o;
        top = innerTop - o;
        break;
      case _ImageCorner.tr:
        left = innerLeft + innerW - o;
        top = innerTop - o;
        break;
      case _ImageCorner.bl:
        left = innerLeft - o;
        top = innerTop + innerH - o;
        break;
      case _ImageCorner.br:
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
                        if (widget.vectorChild != null)
                          Center(
                            child: IconTheme(
                              data: IconThemeData(
                                size: math.min(w, h) * 0.88,
                                color: scheme.onSurface,
                              ),
                              child: widget.vectorChild!,
                            ),
                          )
                        else if (isTemplateImagePathUsable(widget.imagePath))
                          Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                              child:
                                  Icon(Icons.broken_image_outlined, size: 28),
                            ),
                          )
                        else
                          const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 28),
                          ),
                        if (widget.vectorChild == null)
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
                _cornerHandle(scheme, _ImageCorner.tl,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(scheme, _ImageCorner.tr,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(scheme, _ImageCorner.bl,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(scheme, _ImageCorner.br,
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
                          tooltip: 'Remove image',
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
