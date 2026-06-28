import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/labels/label_template_editor_screen.dart';
import 'package:nahpu/screens/exports/labels/label_template_fonts.dart';

const double _kPdfPointsPerMm = 72.0 / 25.4;
double _canvasScaleForMmMath(double scale) => scale < 1e-9 ? 1e-9 : scale;

double _clampMm(double value, double bound1, double bound2) {
  final lo = bound1 <= bound2 ? bound1 : bound2;
  final hi = bound1 <= bound2 ? bound2 : bound1;
  if (value.isNaN || value.isInfinite) return lo;
  return value.clamp(lo, hi);
}

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
    this.textAlign = TextAlign.left,
    this.rotationDegrees = 0,
    required this.scale,
    required this.labelWidthMm,
    required this.labelHeightMm,
    this.canvasInsetXPx = 0,
    this.canvasInsetYPx = 0,
    required this.labelPanToMmDelta,
    required this.onMoved,
    this.isCustom = false,
    this.isSelected = false,
    this.isInlineEditing = false,
    this.onInlineEditingComplete,
    this.onInlineTextInsertBinding,
    this.onTap,
    this.onSelect,
    this.maxWidthMm,
    this.onMaxWidthChanged,
    this.colorArgb = 0xFF000000,
    this.onDragStateChanged,
    this.onDoubleTap,
  });

  final String label;

  /// Raw template text for custom chips (may be empty); ignored when not custom.
  final String actualText;
  final Offset position;
  final double fontSize;
  final String fontFamily;
  final bool bold;
  final bool italic;
  final TextAlign textAlign;
  final int rotationDegrees;
  final double scale;
  final double labelWidthMm;
  final double labelHeightMm;

  /// See [_DraggableImageChip.canvasInsetXPx].
  final double canvasInsetXPx;
  final double canvasInsetYPx;
  final LabelPanMmDeltaCallback labelPanToMmDelta;
  final void Function(Offset newPosMm) onMoved;
  final bool isCustom;
  final bool isSelected;
  final bool isInlineEditing;

  /// Called once when inline editing ends (focus lost or Enter); updates template text.
  final ValueChanged<String>? onInlineEditingComplete;

  /// Active while inline editing: non-null inserts at caret; null when edit ends.
  final ValueChanged<void Function(String)?>? onInlineTextInsertBinding;
  final VoidCallback? onTap;

  /// When pan wins over tap (slight movement), [onTap] may not run; parent uses
  /// this to select so the attributes bar appears immediately.
  final VoidCallback? onSelect;
  final VoidCallback? onDoubleTap;

  final double? maxWidthMm;
  final ValueChanged<double>? onMaxWidthChanged;
  final int colorArgb;
  final ValueChanged<bool>? onDragStateChanged;

  @override
  State<DraggableChip> createState() => DraggableChipState();
}

enum _TextCorner { tl, tr, bl, br }

class DraggableChipState extends State<DraggableChip> {
  bool _dragging = false;
  TextEditingController? _inlineCtrl;
  FocusNode? _inlineFocus;
  bool _inlineEditCommitted = false;

  void _deferSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  _TextCorner? _resizeCorner;
  double? _resizeStartWidthMm;
  Offset? _resizeStartGlobal;
  double? _resizeLiveWidthMm;
  Offset? _resizeStartPosMm;
  Offset? _resizeLivePosMm;

  /// [DragUpdateDetails.delta] is local; track global positions for label mm.
  Offset? _labelDragLastGlobal;

  /// Parent template updates are deferred to post-frame; [widget.position] stays
  /// stale across multiple [onPanUpdate] calls, so we accumulate from drag start
  /// and paint from [_dragLiveMm] until the parent catches up.
  Offset? _panOriginMm;
  Offset _panAccumMm = Offset.zero;
  Offset? _dragLiveMm;
  int _labelDragSession = 0;

  Offset _mmDeltaForLabelPan(DragUpdateDetails d) {
    final last = _labelDragLastGlobal ?? d.globalPosition;
    final gDelta = d.globalPosition - last;
    _labelDragLastGlobal = d.globalPosition;
    final s = _canvasScaleForMmMath(widget.scale);
    final fromStack = widget.labelPanToMmDelta(d.globalPosition, gDelta);
    if (fromStack != null) return fromStack;
    return Offset(gDelta.dx / s, gDelta.dy / s);
  }

  void _onResizePanStart(DragStartDetails d, _TextCorner corner) {
    widget.onDragStateChanged?.call(true);
    final fontPx = widget.fontSize * widget.scale / _kPdfPointsPerMm;
    final textStyle = customLabelCanvasTextStyle(
      fontFamilyRaw: widget.fontFamily,
      fontSize: fontPx,
      fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: widget.italic ? FontStyle.italic : FontStyle.normal,
    ).copyWith(color: Color(widget.colorArgb));

    final tp = TextPainter(
      text: TextSpan(text: widget.label, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    _deferSetState(() {
      _resizeCorner = corner;
      _resizeStartWidthMm = widget.maxWidthMm ?? (tp.width / widget.scale);
      _resizeLiveWidthMm = _resizeStartWidthMm;
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
    final s = _canvasScaleForMmMath(widget.scale);
    final fromStack = widget.labelPanToMmDelta(d.globalPosition, gDelta);
    final deltaMm = fromStack != null ? fromStack.dx : (gDelta.dx / s);

    var newWidth = _resizeStartWidthMm!;
    var newX = _resizeStartPosMm!.dx;

    switch (_resizeCorner!) {
      case _TextCorner.tl:
      case _TextCorner.bl:
        newWidth = _resizeStartWidthMm! - deltaMm;
        if (newWidth < 5.0) {
          newWidth = 5.0;
          newX = _resizeStartPosMm!.dx + (_resizeStartWidthMm! - 5.0);
        } else {
          newX = _resizeStartPosMm!.dx + deltaMm;
        }
        break;
      case _TextCorner.tr:
      case _TextCorner.br:
        newWidth = _resizeStartWidthMm! + deltaMm;
        if (newWidth < 5.0) {
          newWidth = 5.0;
        }
        break;
    }

    newWidth = newWidth.clamp(5.0, widget.labelWidthMm);
    newX = newX.clamp(0.0, math.max(0.0, widget.labelWidthMm - 5.0));

    setState(() {
      _resizeLiveWidthMm = newWidth;
      _resizeLivePosMm = Offset(newX, _resizeStartPosMm!.dy);
    });
  }

  void _onResizePanEnd() {
    widget.onDragStateChanged?.call(false);
    if (_resizeLiveWidthMm != null) {
      widget.onMaxWidthChanged?.call(_resizeLiveWidthMm!);
    }
    if (_resizeLivePosMm != null && _resizeLivePosMm != _resizeStartPosMm) {
      widget.onMoved(_resizeLivePosMm!);
    }
    _deferSetState(() {
      _resizeCorner = null;
      _resizeStartGlobal = null;
      _resizeStartWidthMm = null;
      _resizeLiveWidthMm = null;
      _resizeStartPosMm = null;
      _resizeLivePosMm = null;
    });
  }

  void _onLabelPanStart(DragStartDetails d) {
    widget.onDragStateChanged?.call(true);
    if (widget.isCustom && !widget.isSelected) {
      widget.onSelect?.call();
    }
    _labelDragSession++;
    _panOriginMm = widget.position;
    _panAccumMm = Offset.zero;
    _dragLiveMm = null;
    _deferSetState(() => _dragging = true);
    _labelDragLastGlobal = d.globalPosition;
  }

  void _finishLabelPanGesture() {
    final session = _labelDragSession;
    if (_dragLiveMm != null) {
      widget.onMoved(_dragLiveMm!);
    }
    _labelDragLastGlobal = null;
    _panOriginMm = null;
    _panAccumMm = Offset.zero;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || session != _labelDragSession) return;
      setState(() => _dragLiveMm = null);
    });
  }

  void _onLabelPanEnd() {
    _deferSetState(() => _dragging = false);
    _finishLabelPanGesture();
    widget.onDragStateChanged?.call(false);
  }

  void _panMoveClampedToHitInset(DragUpdateDetails details) {
    final dMm = _mmDeltaForLabelPan(details);
    if (dMm.dx.isNaN ||
        dMm.dy.isNaN ||
        dMm.dx.isInfinite ||
        dMm.dy.isInfinite) {
      return;
    }
    final origin = _panOriginMm ?? widget.position;
    _panAccumMm += dMm;
    final maxX = math.max(0.0, widget.labelWidthMm);
    final maxY = math.max(0.0, widget.labelHeightMm);
    final rawX = origin.dx + _panAccumMm.dx;
    final rawY = origin.dy + _panAccumMm.dy;
    final cx = _clampMm(rawX, 0, maxX);
    final cy = _clampMm(rawY, 0, maxY);
    if (cx != rawX || cy != rawY) {
      _panOriginMm = Offset(cx, cy);
      _panAccumMm = Offset.zero;
    }
    final clamped = Offset(cx, cy);
    setState(() => _dragLiveMm = clamped);
  }

  void _startInlineEditing() {
    _inlineEditCommitted = false;
    _inlineCtrl?.dispose();
    _inlineFocus?.removeListener(_onInlineFocusChange);
    _inlineFocus?.dispose();
    _inlineCtrl = TextEditingController(text: widget.actualText);
    _inlineFocus = FocusNode();
    _inlineFocus!.addListener(_onInlineFocusChange);
    widget.onInlineTextInsertBinding?.call(_pasteIntoInlineField);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isInlineEditing) return;
      _inlineFocus?.requestFocus();
      final t = _inlineCtrl?.text ?? '';
      _inlineCtrl?.selection = TextSelection.collapsed(offset: t.length);
    });
  }

  void _pasteIntoInlineField(String insertion) {
    final c = _inlineCtrl;
    if (c == null || !widget.isInlineEditing) return;
    final text = c.text;
    final sel = c.selection;
    var start = sel.isValid ? sel.start : text.length;
    var end = sel.isValid ? sel.end : text.length;
    if (start < 0 || start > text.length) start = text.length;
    if (end < 0 || end > text.length) end = text.length;
    if (start > end) {
      final t = start;
      start = end;
      end = t;
    }
    final newText = text.replaceRange(start, end, insertion);
    final newOffset = start + insertion.length;
    c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
    _inlineFocus?.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isCustom && widget.isInlineEditing) {
      _startInlineEditing();
    }
    if (widget.isCustom) {
      _scheduleCanvasGoogleFontPrime();
    }
  }

  void _scheduleCanvasGoogleFontPrime() {
    if (!labelCanvasFontUsesGoogle(widget.fontFamily)) return;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadCanvasGoogleFontIfNeeded());
  }

  Future<void> _loadCanvasGoogleFontIfNeeded() async {
    if (!mounted || !widget.isCustom) return;
    try {
      await preloadGoogleFontForLabelCanvas(
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
    if (widget.isInlineEditing && !oldWidget.isInlineEditing) {
      _startInlineEditing();
    } else if (!widget.isInlineEditing && oldWidget.isInlineEditing) {
      widget.onInlineTextInsertBinding?.call(null);
      if (!_inlineEditCommitted) {
        _commitInlineToParent();
      }
      _inlineEditCommitted = false;
      _inlineFocus?.removeListener(_onInlineFocusChange);
      _inlineFocus?.dispose();
      _inlineFocus = null;
      _inlineCtrl?.dispose();
      _inlineCtrl = null;
    } else if (widget.isInlineEditing &&
        _inlineCtrl != null &&
        widget.actualText != _inlineCtrl!.text &&
        !(_inlineFocus?.hasFocus ?? false)) {
      _inlineCtrl!.text = widget.actualText;
    }
  }

  void _onInlineFocusChange() {
    if (_inlineFocus == null || _inlineFocus!.hasFocus) return;
    _commitInlineToParent();
  }

  void _commitInlineToParent() {
    if (_inlineEditCommitted) return;
    _inlineEditCommitted = true;
    widget.onInlineEditingComplete?.call(_inlineCtrl?.text ?? '');
  }

  @override
  void dispose() {
    if (widget.isInlineEditing) {
      widget.onInlineTextInsertBinding?.call(null);
    }
    _inlineFocus?.removeListener(_onInlineFocusChange);
    _inlineFocus?.dispose();
    _inlineCtrl?.dispose();
    super.dispose();
  }

  Widget _cornerHandle(_TextCorner corner, ColorScheme scheme) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => _onResizePanStart(d, corner),
      onPanUpdate: _onResizePanUpdate,
      onPanEnd: (_) => _onResizePanEnd(),
      onPanCancel: _onResizePanEnd,
      child: Container(
        width: 16,
        height: 16,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final insetX = widget.canvasInsetXPx;
    final insetY = widget.canvasInsetYPx;
    final posMm = _dragLiveMm ?? widget.position;
    final left = posMm.dx * widget.scale + insetX;
    final top = posMm.dy * widget.scale + insetY;
    final scheme = Theme.of(context).colorScheme;

    if (widget.isCustom) {
      // Match PDF: pw.Text at (xMm,yMm), fontSize in pt, rotateZ about top-left.
      final fontPx = widget.fontSize * widget.scale / _kPdfPointsPerMm;
      final textStyle = customLabelCanvasTextStyle(
        fontFamilyRaw: widget.fontFamily,
        fontSize: fontPx,
        fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: widget.italic ? FontStyle.italic : FontStyle.normal,
      ).copyWith(color: Color(widget.colorArgb));

      if (widget.isInlineEditing &&
          _inlineCtrl != null &&
          _inlineFocus != null) {
        final handle = fontPx.clamp(18.0, 28.0);
        final fieldW =
            ((widget.labelWidthMm - posMm.dx) * widget.scale - handle - 6)
                .clamp(48.0, 2000.0);
        final editor = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onLabelPanStart,
              onPanUpdate: _panMoveClampedToHitInset,
              onPanEnd: (_) => _onLabelPanEnd(),
              onPanCancel: _onLabelPanEnd,
              child: SizedBox(
                width: handle,
                height: handle + 4,
                child: Icon(
                  Icons.drag_indicator,
                  size: handle,
                  color: scheme.primary,
                ),
              ),
            ),
            SizedBox(
              width: fieldW,
              child: TextField(
                controller: _inlineCtrl,
                focusNode: _inlineFocus,
                autofocus: true,
                style: textStyle,
                maxLines: 6,
                minLines: 1,
                cursorColor: Colors.black,
                textAlign: widget.textAlign,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                ),
                onSubmitted: (_) => _inlineFocus?.unfocus(),
              ),
            ),
          ],
        );
        return Positioned(
          left: left,
          top: top,
          child: Transform.rotate(
            angle: widget.rotationDegrees * math.pi / 180,
            alignment: Alignment.topLeft,
            child: editor,
          ),
        );
      }

      final activeWidthMm = _resizeLiveWidthMm ?? widget.maxWidthMm;
      final text = SizedBox(
        width: activeWidthMm != null ? activeWidthMm * widget.scale : null,
        child: Text(
          widget.label,
          style: textStyle,
          softWrap: activeWidthMm != null,
          maxLines: activeWidthMm != null ? null : 1,
          overflow:
              activeWidthMm != null ? TextOverflow.clip : TextOverflow.visible,
          textAlign: widget.textAlign,
        ),
      );
      final handleSize = fontPx.clamp(20.0, 32.0);
      return Positioned(
        left: left,
        top: top,
        child: Transform.rotate(
          angle: widget.rotationDegrees * math.pi / 180,
          alignment: Alignment.topLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              widget.onTap?.call();
              widget.onSelect?.call();
            },
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onPanStart: _onLabelPanStart,
            onPanUpdate: _panMoveClampedToHitInset,
            onPanEnd: (_) => _onLabelPanEnd(),
            onPanCancel: _onLabelPanEnd,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
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
                    Container(
                      foregroundDecoration: (widget.isSelected || _dragging)
                          ? BoxDecoration(
                              border:
                                  Border.all(color: scheme.primary, width: 2),
                            )
                          : null,
                      child: text,
                    ),
                  ],
                ),
                if ((widget.isSelected || _resizeCorner != null) &&
                    widget.onMaxWidthChanged != null) ...[
                  Positioned(
                    left: handleSize - 8,
                    top: -8,
                    child: _cornerHandle(_TextCorner.tl, scheme),
                  ),
                  Positioned(
                    right: -8,
                    top: -8,
                    child: _cornerHandle(_TextCorner.tr, scheme),
                  ),
                  Positioned(
                    left: handleSize - 8,
                    bottom: -8,
                    child: _cornerHandle(_TextCorner.bl, scheme),
                  ),
                  Positioned(
                    right: -8,
                    bottom: -8,
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
        angle: widget.rotationDegrees * math.pi / 180,
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            widget.onTap?.call();
            widget.onSelect?.call();
          },
          onTap: widget.onTap,
          onPanStart: _onLabelPanStart,
          onPanUpdate: _panMoveClampedToHitInset,
          onPanEnd: (_) => _onLabelPanEnd(),
          onPanCancel: _onLabelPanEnd,
          child: chip,
        ),
      ),
    );
  }
}
