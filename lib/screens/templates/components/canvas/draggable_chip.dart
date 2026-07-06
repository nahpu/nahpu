import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/template_editor_math.dart';
import 'package:nahpu/screens/templates/template_fonts.dart';

const double _kPdfPointsPerMm = 72.0 / 25.4;

class DraggableChip extends StatefulWidget {
  const DraggableChip({
    super.key,
    required this.label,
    this.actualText = '',
    required this.position,
    required this.fontSize,
    this.fontFamily = '',
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.textAlign = TextAlign.left,
    this.rotationDegrees = 0,
    required this.scale,
    required this.templateWidthMm,
    required this.templateHeightMm,
    this.canvasInsetXPx = 0,
    this.canvasInsetYPx = 0,
    required this.templatePanToMmDelta,
    required this.onMoved,
    this.isCustom = false,
    this.isSelected = false,
    this.onTap,
    this.onSelect,
    this.maxWidthMm,
    this.heightMm,
    this.onMaxWidthChanged,
    this.onHeightChanged,
    this.onResizeChanged,
    this.colorArgb = 0xFF000000,
    this.onDragStateChanged,
    this.onDoubleTap,
    this.isDynamic = false,
    this.backgroundColorArgb,
    this.borderColorArgb,
    this.borderWidthPt = 0.0,
    this.borderStrokeStyle = 'solid',
    this.cornerRadiusPt = 0.0,
    this.paddingPt = 2.0,
    this.isLocked = false,
    this.isVisible = true,
  });

  final String label;

  /// Raw template text for custom chips (may be empty); ignored when not custom.
  final String actualText;
  final Offset position;
  final double fontSize;
  final String fontFamily;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final TextAlign textAlign;
  final int rotationDegrees;
  final double scale;
  final double templateWidthMm;
  final double templateHeightMm;

  /// See [_DraggableImageChip.canvasInsetXPx].
  final double canvasInsetXPx;
  final double canvasInsetYPx;
  final TemplatePanMmDeltaCallback templatePanToMmDelta;
  final void Function(Offset newPosMm) onMoved;
  final bool isCustom;
  final bool isSelected;
  final VoidCallback? onTap;

  /// When pan wins over tap (slight movement), [onTap] may not run; parent uses
  /// this to select so the attributes bar appears immediately.
  final VoidCallback? onSelect;
  final VoidCallback? onDoubleTap;

  final double? maxWidthMm;
  final double? heightMm;
  final ValueChanged<double>? onMaxWidthChanged;
  final ValueChanged<double>? onHeightChanged;
  final void Function(Offset newPosMm, double maxWidthMm, double heightMm)?
      onResizeChanged;
  final int colorArgb;
  final ValueChanged<bool>? onDragStateChanged;
  final bool isDynamic;
  final int? backgroundColorArgb;
  final int? borderColorArgb;
  final double borderWidthPt;
  final String borderStrokeStyle;
  final double cornerRadiusPt;
  final double paddingPt;
  final bool isLocked;
  final bool isVisible;

  @override
  State<DraggableChip> createState() => DraggableChipState();
}

enum _TextCorner { tl, tr, bl, br }

class DraggableChipState extends State<DraggableChip> {
  static const double _handleVisual = 18;
  static const double _handleHit = 36;

  bool _dragging = false;

  void _deferSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  _TextCorner? _resizeCorner;
  double? _resizeStartWidthMm;
  double? _resizeStartHeightMm;
  Offset? _resizeStartGlobal;
  double? _resizeLiveWidthMm;
  double? _resizeLiveHeightMm;
  Offset? _resizeStartPosMm;
  Offset? _resizeLivePosMm;

  /// [DragUpdateDetails.delta] is local; track global positions for template mm.
  Offset? _templateDragLastGlobal;

  /// Parent template updates are deferred to post-frame; [widget.position] stays
  /// stale across multiple [onPanUpdate] calls, so we accumulate from drag start
  /// and paint from [_dragLiveMm] until the parent catches up.
  Offset? _panOriginMm;
  Offset _panAccumMm = Offset.zero;
  Offset? _dragLiveMm;
  int _templateDragSession = 0;

  Offset _mmDeltaForTemplatePan(DragUpdateDetails d) {
    final last = _templateDragLastGlobal ?? d.globalPosition;
    final gDelta = d.globalPosition - last;
    _templateDragLastGlobal = d.globalPosition;
    final fromStack = widget.templatePanToMmDelta(d.globalPosition, gDelta);
    if (fromStack != null) return fromStack;
    return pixelsToTemplateMm(gDelta, widget.scale);
  }

  void _onResizePanStart(DragStartDetails d, _TextCorner corner) {
    widget.onDragStateChanged?.call(true);
    final fontPx = widget.fontSize * widget.scale / _kPdfPointsPerMm;
    final textStyle = customTemplateCanvasTextStyle(
      fontFamilyRaw: widget.fontFamily,
      fontSize: fontPx,
      fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: widget.italic ? FontStyle.italic : FontStyle.normal,
      underline: widget.underline,
      strikethrough: widget.strikethrough,
    ).copyWith(color: Color(widget.colorArgb));

    final tp = TextPainter(
      text: TextSpan(text: widget.label, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final initialHeight = widget.heightMm ?? (tp.height / widget.scale);

    _deferSetState(() {
      _resizeCorner = corner;
      _resizeStartWidthMm = widget.maxWidthMm ?? (tp.width / widget.scale);
      _resizeLiveWidthMm = _resizeStartWidthMm;
      _resizeStartHeightMm = initialHeight;
      _resizeLiveHeightMm = initialHeight;
      _resizeStartPosMm = widget.position;
      _resizeLivePosMm = widget.position;
    });
    _resizeStartGlobal = d.globalPosition;
  }

  void _onResizePanUpdate(DragUpdateDetails d) {
    if (_resizeStartGlobal == null ||
        _resizeStartWidthMm == null ||
        _resizeCorner == null ||
        _resizeStartPosMm == null) {
      return;
    }
    final gDelta = d.globalPosition - _resizeStartGlobal!;
    final fromStack = widget.templatePanToMmDelta(d.globalPosition, gDelta);
    final templateDeltaMm =
        fromStack ?? pixelsToTemplateMm(gDelta, widget.scale);
    final localDeltaMm = templateDeltaToElementLocalMm(
      templateDeltaMm,
      widget.rotationDegrees,
    );

    if (widget.isDynamic) {
      final deltaMm = localDeltaMm.dx;
      var newWidth = _resizeStartWidthMm!;
      var newPos = _resizeStartPosMm!;

      switch (_resizeCorner!) {
        case _TextCorner.tl:
        case _TextCorner.bl:
          newWidth = (_resizeStartWidthMm! - deltaMm).clamp(
            5.0,
            widget.templateWidthMm,
          );
          final appliedDeltaMm = _resizeStartWidthMm! - newWidth;
          final radians = degreesToRadians(widget.rotationDegrees);
          newPos = _resizeStartPosMm! +
              Offset(
                appliedDeltaMm * math.cos(radians),
                appliedDeltaMm * math.sin(radians),
              );
          break;
        case _TextCorner.tr:
        case _TextCorner.br:
          newWidth = (_resizeStartWidthMm! + deltaMm).clamp(
            5.0,
            widget.templateWidthMm,
          );
          break;
      }

      setState(() {
        _resizeLiveWidthMm = newWidth;
        _resizeLivePosMm = newPos;
      });
    } else {
      final rect = resizedRotatedRectFromCorner(
        startMm: Rect.fromLTWH(
          _resizeStartPosMm!.dx,
          _resizeStartPosMm!.dy,
          _resizeStartWidthMm!,
          _resizeStartHeightMm ?? 0.0,
        ),
        localDeltaMm: localDeltaMm,
        corner: _resizeCorner!.name,
        rotationDegrees: widget.rotationDegrees,
        maxWidthMm: widget.templateWidthMm,
        maxHeightMm: widget.templateHeightMm,
      );
      setState(() {
        _resizeLiveWidthMm = rect.width;
        _resizeLiveHeightMm = rect.height;
        _resizeLivePosMm = rect.topLeft;
      });
    }
  }

  void _onResizePanEnd() {
    widget.onDragStateChanged?.call(false);
    if (_resizeLiveWidthMm != null) {
      final pos = _resizeLivePosMm ?? _resizeStartPosMm ?? widget.position;
      if (widget.onResizeChanged != null) {
        widget.onResizeChanged!(
          pos,
          _resizeLiveWidthMm!,
          widget.isDynamic
              ? 0.0
              : (_resizeLiveHeightMm ?? widget.heightMm ?? 0.0),
        );
      } else {
        widget.onMaxWidthChanged?.call(_resizeLiveWidthMm!);
        if (widget.onHeightChanged != null &&
            !widget.isDynamic &&
            _resizeLiveHeightMm != null) {
          widget.onHeightChanged!(_resizeLiveHeightMm!);
        }
        if (_resizeLivePosMm != null && _resizeLivePosMm != _resizeStartPosMm) {
          widget.onMoved(_resizeLivePosMm!);
        }
      }
    }
    _deferSetState(() {
      _resizeCorner = null;
      _resizeStartGlobal = null;
      _resizeStartWidthMm = null;
      _resizeLiveWidthMm = null;
      _resizeStartHeightMm = null;
      _resizeLiveHeightMm = null;
      _resizeStartPosMm = null;
      _resizeLivePosMm = null;
    });
  }

  void _onTemplatePanStart(DragStartDetails d) {
    widget.onDragStateChanged?.call(true);
    if (widget.isCustom && !widget.isSelected) {
      widget.onSelect?.call();
    }
    _templateDragSession++;
    _panOriginMm = widget.position;
    _panAccumMm = Offset.zero;
    _dragLiveMm = null;
    _deferSetState(() => _dragging = true);
    _templateDragLastGlobal = d.globalPosition;
  }

  void _finishTemplatePanGesture() {
    final session = _templateDragSession;
    if (_dragLiveMm != null) {
      widget.onMoved(_dragLiveMm!);
    }
    _templateDragLastGlobal = null;
    _panOriginMm = null;
    _panAccumMm = Offset.zero;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || session != _templateDragSession) return;
      setState(() => _dragLiveMm = null);
    });
  }

  void _onTemplatePanEnd() {
    _deferSetState(() => _dragging = false);
    _finishTemplatePanGesture();
    widget.onDragStateChanged?.call(false);
  }

  void _panMoveClampedToHitInset(DragUpdateDetails details) {
    final dMm = _mmDeltaForTemplatePan(details);
    if (dMm.dx.isNaN ||
        dMm.dy.isNaN ||
        dMm.dx.isInfinite ||
        dMm.dy.isInfinite) {
      return;
    }
    final origin = _panOriginMm ?? widget.position;
    _panAccumMm += dMm;
    final maxX = math.max(0.0, widget.templateWidthMm);
    final maxY = math.max(0.0, widget.templateHeightMm);
    final rawX = origin.dx + _panAccumMm.dx;
    final rawY = origin.dy + _panAccumMm.dy;
    final cx = clampFiniteMm(rawX, 0, maxX);
    final cy = clampFiniteMm(rawY, 0, maxY);
    if (cx != rawX || cy != rawY) {
      _panOriginMm = Offset(cx, cy);
      _panAccumMm = Offset.zero;
    }
    final clamped = Offset(cx, cy);
    setState(() => _dragLiveMm = clamped);
  }

  @override
  void initState() {
    super.initState();
    if (widget.isCustom) {
      _scheduleCanvasGoogleFontPrime();
    }
  }

  void _scheduleCanvasGoogleFontPrime() {
    if (!templateCanvasFontUsesGoogle(widget.fontFamily)) return;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadCanvasGoogleFontIfNeeded());
  }

  Future<void> _loadCanvasGoogleFontIfNeeded() async {
    if (!mounted || !widget.isCustom) return;
    try {
      await preloadGoogleFontForTemplateCanvas(
        widget.fontFamily,
        widget.bold ? FontWeight.bold : FontWeight.normal,
        widget.italic ? FontStyle.italic : FontStyle.normal,
      );
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant DraggableChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isCustom) return;
    if (oldWidget.fontFamily != widget.fontFamily ||
        oldWidget.bold != widget.bold ||
        oldWidget.italic != widget.italic) {
      _scheduleCanvasGoogleFontPrime();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _cornerHandle(_TextCorner corner, ColorScheme scheme) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => _onResizePanStart(d, corner),
      onPanUpdate: _onResizePanUpdate,
      onPanEnd: (_) => _onResizePanEnd(),
      onPanCancel: _onResizePanEnd,
      child: SizedBox(
        width: _handleHit,
        height: _handleHit,
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

  @override
  Widget build(BuildContext context) {
    final insetX = widget.canvasInsetXPx;
    final insetY = widget.canvasInsetYPx;
    final posMm = _resizeLivePosMm ?? _dragLiveMm ?? widget.position;
    final left = posMm.dx * widget.scale + insetX;
    final top = posMm.dy * widget.scale + insetY;
    final scheme = Theme.of(context).colorScheme;

    if (widget.isCustom) {
      // Match PDF: pw.Text at (xMm,yMm), fontSize in pt, rotateZ about top-left.
      final fontPx = widget.fontSize * widget.scale / _kPdfPointsPerMm;
      final textStyle = customTemplateCanvasTextStyle(
        fontFamilyRaw: widget.fontFamily,
        fontSize: fontPx,
        fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: widget.italic ? FontStyle.italic : FontStyle.normal,
        underline: widget.underline,
        strikethrough: widget.strikethrough,
      ).copyWith(color: Color(widget.colorArgb));

      final activeWidthMm = _resizeLiveWidthMm ?? widget.maxWidthMm;
      final activeHeightMm =
          widget.isDynamic ? null : (_resizeLiveHeightMm ?? widget.heightMm);
      final hasTextBoxStyle = widget.backgroundColorArgb != null ||
          (widget.borderColorArgb != null && widget.borderWidthPt > 0);
      final textBoxPaddingPx = hasTextBoxStyle
          ? widget.paddingPt * widget.scale / _kPdfPointsPerMm
          : 0.0;
      final textBoxBorderWidthPx =
          widget.borderWidthPt * widget.scale / _kPdfPointsPerMm;
      final textBoxRadiusPx =
          widget.cornerRadiusPt * widget.scale / _kPdfPointsPerMm;
      final text = SizedBox(
        width: activeWidthMm != null ? activeWidthMm * widget.scale : null,
        height: activeHeightMm != null ? activeHeightMm * widget.scale : null,
        child: CustomPaint(
          foregroundPainter:
              widget.borderColorArgb == null || widget.borderWidthPt <= 0
                  ? null
                  : _TextBoxStrokePainter(
                      color: Color(widget.borderColorArgb!),
                      width: textBoxBorderWidthPx,
                      style: widget.borderStrokeStyle,
                      radius: textBoxRadiusPx,
                    ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.backgroundColorArgb == null
                  ? null
                  : Color(widget.backgroundColorArgb!),
              borderRadius: BorderRadius.circular(textBoxRadiusPx),
            ),
            child: Padding(
              padding: EdgeInsets.all(textBoxPaddingPx),
              child: Text(
                widget.label,
                style: textStyle,
                softWrap: activeWidthMm != null,
                maxLines: activeWidthMm != null ? null : 1,
                overflow: activeWidthMm != null
                    ? TextOverflow.clip
                    : TextOverflow.visible,
                textAlign: widget.textAlign,
              ),
            ),
          ),
        ),
      );
      final handleSize = fontPx.clamp(20.0, 32.0);
      final handlePad = _handleHit / 2;
      final rot = Matrix4.identity()
        ..translateByDouble(handlePad, handlePad, 0, 1)
        ..rotateZ(degreesToRadians(widget.rotationDegrees))
        ..translateByDouble(-handlePad, -handlePad, 0, 1);
      return Positioned(
        left: left - handlePad,
        top: top - handlePad,
        child: Transform(
          transform: rot,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              widget.onTap?.call();
              widget.onSelect?.call();
            },
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onPanStart: _onTemplatePanStart,
            onPanUpdate: _panMoveClampedToHitInset,
            onPanEnd: (_) => _onTemplatePanEnd(),
            onPanCancel: _onTemplatePanEnd,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(handlePad),
                  child: Container(
                    foregroundDecoration: (widget.isSelected || _dragging)
                        ? BoxDecoration(
                            border: Border.all(
                              color: scheme.primary,
                              width: 2,
                            ),
                          )
                        : (widget.isDynamic
                            ? BoxDecoration(
                                border: Border.all(
                                  color:
                                      scheme.secondary.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              )
                            : null),
                    child: text,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: handlePad,
                  width: handleSize,
                  height: handleSize,
                  child: Center(
                    child: Icon(
                      Icons.drag_indicator,
                      size: handleSize * 0.65,
                      color: scheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                if (!widget.isLocked &&
                    (widget.isSelected || _resizeCorner != null) &&
                    (widget.onMaxWidthChanged != null ||
                        widget.onHeightChanged != null)) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    child: _cornerHandle(_TextCorner.tl, scheme),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: _cornerHandle(_TextCorner.tr, scheme),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: _cornerHandle(_TextCorner.bl, scheme),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _cornerHandle(_TextCorner.br, scheme),
                  ),
                ]
              ],
            ),
          ),
        ),
      );
    }

    final Color bgColor;
    final Color fgColor;
    final Color borderColor;
    if (_dragging) {
      bgColor = scheme.primaryContainer;
      fgColor = Colors.black;
      borderColor = scheme.primary;
    } else if (widget.isSelected) {
      bgColor = Colors.amber.shade50;
      fgColor = Colors.black;
      borderColor = scheme.primary;
    } else {
      bgColor = Colors.grey.shade200;
      fgColor = Colors.black87;
      borderColor = Colors.grey.shade500;
    }

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: (widget.isSelected || _dragging) ? 2.0 : 1.0,
        ),
        boxShadow: _dragging
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.drag_indicator, size: 16, color: fgColor),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fgColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.fontSize.toStringAsFixed(0)}pt',
            style:
                TextStyle(fontSize: 9, color: fgColor.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: degreesToRadians(widget.rotationDegrees),
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            widget.onTap?.call();
            widget.onSelect?.call();
          },
          onTap: widget.onTap,
          onPanStart: widget.isLocked ? null : _onTemplatePanStart,
          onPanUpdate: widget.isLocked ? null : _panMoveClampedToHitInset,
          onPanEnd: widget.isLocked ? null : (_) => _onTemplatePanEnd(),
          onPanCancel: widget.isLocked ? null : _onTemplatePanEnd,
          child: widget.isVisible ? chip : Opacity(opacity: 0.35, child: chip),
        ),
      ),
    );
  }
}

class _TextBoxStrokePainter extends CustomPainter {
  const _TextBoxStrokePainter({
    required this.color,
    required this.width,
    required this.style,
    required this.radius,
  });

  final Color color;
  final double width;
  final String style;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (width <= 0 || size.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(width / 2),
      Radius.circular(math.max(0, radius)),
    );

    if (style == 'double') {
      canvas.drawRRect(rrect, paint);
      final gap = math.max(1.0, width * 1.25);
      final inner = rrect.deflate(width + gap);
      if (inner.width > 0 && inner.height > 0) {
        canvas.drawRRect(inner, paint);
      }
      return;
    }

    final path = Path()..addRRect(rrect);
    if (style == 'dashed' || style == 'dotted') {
      final dashLength = style == 'dotted' ? width : width * 4;
      final gapLength = style == 'dotted' ? width * 2 : width * 2.5;
      for (final metric in path.computeMetrics()) {
        var distance = 0.0;
        while (distance < metric.length) {
          final end = math.min(distance + dashLength, metric.length);
          canvas.drawPath(metric.extractPath(distance, end), paint);
          distance = end + gapLength;
        }
      }
      return;
    }

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _TextBoxStrokePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.width != width ||
        oldDelegate.style != style ||
        oldDelegate.radius != radius;
  }
}
