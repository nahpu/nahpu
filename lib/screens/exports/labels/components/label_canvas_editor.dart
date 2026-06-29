import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/labels/label_outline.dart'
    show labelAreaStackDecoration, LabelOutlineOverlayPainter;
import 'package:nahpu/screens/exports/labels/label_gender_icon.dart'
    show labelGenderIconForFieldKey;
import 'package:nahpu/services/export/label_writer.dart'
    show substituteLabelPlaceholders;
import 'package:nahpu/screens/exports/labels/label_template_model.dart';
import 'package:nahpu/screens/exports/labels/components/draggable_chip.dart';
import 'package:nahpu/screens/exports/labels/components/draggable_image_chip.dart';
import 'package:nahpu/screens/exports/labels/components/draggable_line_chip.dart';
import 'package:nahpu/screens/exports/labels/components/draggable_shape_chip.dart';
import 'package:nahpu/screens/shared/qr.dart' show QrImageView;

import 'dart:math' as math;
import 'package:nahpu/screens/exports/labels/label_canvas_stack.dart';
import 'package:nahpu/screens/exports/labels/components/grid_painter.dart';

const double _kLabelCanvasHitPadPx = 72.0;

TextAlign _parseTextAlign(String align) {
  switch (align) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'left':
    default:
      return TextAlign.left;
  }
}

class LabelCanvasEditor extends StatefulWidget {
  const LabelCanvasEditor({
    super.key,
    required this.page1,
    required this.template,
    required this.labelWidthMm,
    required this.labelHeightMm,
    required this.zoom,
    required this.showGrid,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.isPreviewMode,
    required this.editorLabelFieldPreview,
    required this.selectedElement,
    required this.inlineCanvasCustomKey,
    required this.labelStackKey,
    required this.labelPanGlobalDeltaToMm,
    required this.onClearSelection,
    required this.onSelectElement,
    required this.onStartInlineEditing,
    required this.onScheduleTemplateImageUpdate,
    required this.onRemoveCustomImage,
    required this.onScheduleTemplateTextPositionUpdate,
    required this.onInlineEditingComplete,
    required this.onInlineTextInsertBinding,
    required this.onScheduleTemplateLineUpdate,
    required this.onRemoveCustomLine,
    required this.onScheduleTemplateShapeUpdate,
    required this.onRemoveCustomShape,
    this.fieldDisplayOption = 'short',
  });

  final bool page1;
  final LabelTemplate template;
  final double labelWidthMm;
  final double labelHeightMm;
  final double zoom;
  final bool showGrid;
  final bool mirrorFront;
  final bool mirrorBack;
  final bool isPreviewMode;
  final Map<String, String> editorLabelFieldPreview;
  final String? selectedElement;
  final String? inlineCanvasCustomKey;
  final GlobalKey labelStackKey;
  final String fieldDisplayOption;

  final Offset? Function(GlobalKey stackKey, Offset globalPosition,
      Offset globalDelta, double scale) labelPanGlobalDeltaToMm;
  final VoidCallback onClearSelection;
  final void Function(String id) onSelectElement;
  final void Function(String id) onStartInlineEditing;
  final void Function(CustomImageElement element) onScheduleTemplateImageUpdate;
  final void Function(String id) onRemoveCustomImage;
  final void Function(CustomTextElement element)
      onScheduleTemplateTextPositionUpdate;
  final void Function(CustomTextElement element, String text)
      onInlineEditingComplete;
  final void Function(void Function(String)?) onInlineTextInsertBinding;
  final void Function(CustomLineElement element) onScheduleTemplateLineUpdate;
  final void Function(String id) onRemoveCustomLine;
  final void Function(CustomShapeElement element) onScheduleTemplateShapeUpdate;
  final void Function(String id) onRemoveCustomShape;

  @override
  State<LabelCanvasEditor> createState() => _LabelCanvasEditorState();
}

class _LabelCanvasEditorState extends State<LabelCanvasEditor> {
  bool _canvasPanEnabled = true;

  @override
  Widget build(BuildContext context) {
    final page1 = widget.page1;
    final template = widget.template;
    final labelWidthMm = widget.labelWidthMm;
    final labelHeightMm = widget.labelHeightMm;
    final zoom = widget.zoom;
    final showGrid = widget.showGrid;
    final mirrorFront = widget.mirrorFront;
    final mirrorBack = widget.mirrorBack;
    final isPreviewMode = widget.isPreviewMode;
    final editorLabelFieldPreview = widget.editorLabelFieldPreview;
    final selectedElement = widget.selectedElement;
    final inlineCanvasCustomKey = widget.inlineCanvasCustomKey;
    final labelStackKey = widget.labelStackKey;
    final labelPanGlobalDeltaToMm = widget.labelPanGlobalDeltaToMm;
    final onClearSelection = widget.onClearSelection;
    final onSelectElement = widget.onSelectElement;
    final onScheduleTemplateImageUpdate = widget.onScheduleTemplateImageUpdate;
    final onRemoveCustomImage = widget.onRemoveCustomImage;
    final onScheduleTemplateTextPositionUpdate =
        widget.onScheduleTemplateTextPositionUpdate;
    final onInlineEditingComplete = widget.onInlineEditingComplete;
    final onInlineTextInsertBinding = widget.onInlineTextInsertBinding;
    final onScheduleTemplateLineUpdate = widget.onScheduleTemplateLineUpdate;
    final onRemoveCustomLine = widget.onRemoveCustomLine;
    final onScheduleTemplateShapeUpdate = widget.onScheduleTemplateShapeUpdate;
    final onRemoveCustomShape = widget.onRemoveCustomShape;

    final page = page1 ? template.page1 : template.page2;

    return LayoutBuilder(builder: (context, constraints) {
      const edgePadH = 16.0;
      const edgePadCanvasEnd = 0.0;
      final availW =
          (constraints.maxWidth - edgePadCanvasEnd).clamp(0.0, double.infinity);
      final availH =
          (constraints.maxHeight - 2 * edgePadH).clamp(0.0, double.infinity);
      final baseScale =
          (availW / labelWidthMm).clamp(1.0, availH / labelHeightMm);
      final scale = baseScale * zoom;
      final canvasW = labelWidthMm * scale;
      final canvasH = labelHeightMm * scale;
      final stackW = canvasW + _kLabelCanvasHitPadPx;
      final stackH = canvasH + 2 * _kLabelCanvasHitPadPx;

      Offset? labelPanToMmDelta(Offset globalPosition, Offset globalDelta) {
        return labelPanGlobalDeltaToMm(
          labelStackKey,
          globalPosition,
          globalDelta,
          scale,
        );
      }

      void onDragStateChanged(bool dragging) {
        setState(() {
          _canvasPanEnabled = !dragging;
        });
      }

      return InteractiveViewer(
        constrained: false,
        scaleEnabled: false,
        panEnabled: _canvasPanEnabled,
        clipBehavior: Clip.none,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            0,
            edgePadH,
            edgePadCanvasEnd,
            edgePadH,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: availW,
              minHeight: availH,
            ),
            child: Stack(
              fit: StackFit.loose,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => onClearSelection(),
                  ),
                ),
                Container(
                  width: availW,
                  height: availH,
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: (page1 ? mirrorFront : mirrorBack) ? math.pi : 0,
                    child: SizedBox(
                      width: stackW,
                      height: stackH,
                      child: LabelCanvasStack(
                        key: labelStackKey,
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            left: 0,
                            top: _kLabelCanvasHitPadPx,
                            width: canvasW,
                            height: canvasH,
                            child: IgnorePointer(
                              child: Stack(
                                fit: StackFit.expand,
                                clipBehavior: Clip.none,
                                children: [
                                  DecoratedBox(
                                    decoration: labelAreaStackDecoration(),
                                    child: showGrid
                                        ? CustomPaint(
                                            painter: GridPainter(
                                              labelWidthMm: labelWidthMm,
                                              labelHeightMm: labelHeightMm,
                                              scale: scale,
                                            ),
                                            child: const SizedBox.expand(),
                                          )
                                        : const SizedBox.expand(),
                                  ),
                                  if (template.outline != null)
                                    CustomPaint(
                                      painter: LabelOutlineOverlayPainter(
                                        outline: template.outline!,
                                        scaleMmToPx: scale,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          ...(() {
                            final allElements = <dynamic>[
                              ...page.customImages,
                              ...page.customTexts,
                              ...page.customLines,
                              ...page.customShapes,
                            ]..sort((a, b) =>
                                (a.zIndex as int).compareTo(b.zIndex as int));

                            return allElements.map<Widget>((element) {
                              if (element is CustomImageElement) {
                                return DraggableImageChip(
                                  key: ValueKey(
                                      'p${page1 ? '1' : '2'}_img_${element.id}'),
                                  imagePath: element.imagePath,
                                  position: Offset(element.xMm, element.yMm),
                                  widthMm: element.widthMm,
                                  heightMm: element.heightMm,
                                  rotationDegrees: element.rotationDegrees,
                                  scale: scale,
                                  labelWidthMm: labelWidthMm,
                                  labelHeightMm: labelHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kLabelCanvasHitPadPx,
                                  labelPanToMmDelta: labelPanToMmDelta,
                                  isSelected: selectedElement ==
                                      'image:${page1 ? '1' : '2'}:${element.id}',
                                  onTap: () => onSelectElement(
                                      'image:${page1 ? '1' : '2'}:${element.id}'),
                                  onDragStateChanged: onDragStateChanged,
                                  onMoved: (pos) {
                                    onScheduleTemplateImageUpdate(
                                      element.copyWith(
                                        xMm: pos.dx,
                                        yMm: pos.dy,
                                      ),
                                    );
                                  },
                                  onBoundsChanged: (x, y, w, h) {
                                    onScheduleTemplateImageUpdate(
                                      element.copyWith(
                                        xMm: x,
                                        yMm: y,
                                        widthMm: w,
                                        heightMm: h,
                                      ),
                                    );
                                  },
                                  onRotationChanged: (deg) {
                                    onScheduleTemplateImageUpdate(
                                      element.copyWith(rotationDegrees: deg),
                                    );
                                  },
                                  onDelete: () =>
                                      onRemoveCustomImage(element.id),
                                );
                              } else if (element is CustomTextElement) {
                                if (element.isQrCode) {
                                  final rawText = element.text;
                                  final textVal = formatLabelText(
                                    isPreviewMode
                                        ? substituteLabelPlaceholders(
                                            rawText,
                                            editorLabelFieldPreview,
                                          )
                                        : formatFieldPlaceholderText(
                                            rawText,
                                            widget.fieldDisplayOption ==
                                                'short',
                                          ),
                                    element.textType,
                                    element.formatOption,
                                    element.caseFormat,
                                  );
                                  return DraggableImageChip(
                                    key: ValueKey(
                                        'p${page1 ? '1' : '2'}_qr_${element.id}'),
                                    imagePath: '',
                                    vectorChild: QrImageView(
                                      data: textVal.isEmpty ? ' ' : textVal,
                                      size: element.qrSizeMm * scale,
                                      color: Color(element.colorArgb),
                                      backgroundColor:
                                          Color(element.qrBgColorArgb),
                                      shape: element.qrShape,
                                    ),
                                    position: Offset(element.xMm, element.yMm),
                                    widthMm: element.qrSizeMm,
                                    heightMm: element.qrSizeMm,
                                    rotationDegrees: element.rotationDegrees,
                                    scale: scale,
                                    labelWidthMm: labelWidthMm,
                                    labelHeightMm: labelHeightMm,
                                    canvasInsetXPx: 0,
                                    canvasInsetYPx: _kLabelCanvasHitPadPx,
                                    labelPanToMmDelta: labelPanToMmDelta,
                                    isSelected: selectedElement ==
                                        'custom:${page1 ? '1' : '2'}:${element.id}',
                                    onTap: () => onSelectElement(
                                        'custom:${page1 ? '1' : '2'}:${element.id}'),
                                    onDragStateChanged: onDragStateChanged,
                                    onMoved: (pos) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(
                                          xMm: pos.dx,
                                          yMm: pos.dy,
                                        ),
                                      );
                                    },
                                    onBoundsChanged: (x, y, w, h) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(
                                          xMm: x,
                                          yMm: y,
                                          qrSizeMm: w,
                                        ),
                                      );
                                    },
                                    onRotationChanged: (deg) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(rotationDegrees: deg),
                                      );
                                    },
                                    onDelete: null,
                                  );
                                } else if (labelGenderIconFieldKeyFromBracketText(
                                        element.text)
                                    case final gKey?) {
                                  return DraggableImageChip(
                                    key: ValueKey(
                                        'p${page1 ? '1' : '2'}_gct_${element.id}'),
                                    imagePath: '',
                                    vectorChild: Icon(
                                        labelGenderIconForFieldKey(
                                            editorLabelFieldPreview, gKey)),
                                    position: Offset(element.xMm, element.yMm),
                                    widthMm: element.iconWidthMm ??
                                        kLabelGenderIconDefaultWidthMm,
                                    heightMm: element.iconHeightMm ??
                                        kLabelGenderIconDefaultHeightMm,
                                    rotationDegrees: element.rotationDegrees,
                                    scale: scale,
                                    labelWidthMm: labelWidthMm,
                                    labelHeightMm: labelHeightMm,
                                    canvasInsetXPx: 0,
                                    canvasInsetYPx: _kLabelCanvasHitPadPx,
                                    labelPanToMmDelta: labelPanToMmDelta,
                                    isSelected: selectedElement ==
                                        'custom:${page1 ? '1' : '2'}:${element.id}',
                                    onTap: () => onSelectElement(
                                        'custom:${page1 ? '1' : '2'}:${element.id}'),
                                    onDragStateChanged: onDragStateChanged,
                                    onMoved: (pos) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(
                                          xMm: pos.dx,
                                          yMm: pos.dy,
                                        ),
                                      );
                                    },
                                    onBoundsChanged: (x, y, w, h) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(
                                          xMm: x,
                                          yMm: y,
                                          iconWidthMm: w,
                                          iconHeightMm: h,
                                        ),
                                      );
                                    },
                                    onRotationChanged: (deg) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(rotationDegrees: deg),
                                      );
                                    },
                                    onDelete: null,
                                  );
                                } else {
                                  return DraggableChip(
                                    key: ValueKey(
                                        'p${page1 ? '1' : '2'}_ct_${element.id}_${element.rotationDegrees}_${element.fontFamily}'),
                                    label: element.text.isEmpty
                                        ? '(empty)'
                                        : formatLabelText(
                                            isPreviewMode
                                                ? substituteLabelPlaceholders(
                                                    element.text,
                                                    editorLabelFieldPreview,
                                                  )
                                                : formatFieldPlaceholderText(
                                                    element.text,
                                                    widget.fieldDisplayOption ==
                                                        'short',
                                                  ),
                                            element.textType,
                                            element.formatOption,
                                            element.caseFormat,
                                          ),
                                    actualText: element.text,
                                    position: Offset(element.xMm, element.yMm),
                                    fontSize: element.fontSizePt,
                                    fontFamily: element.fontFamily,
                                    bold: element.bold,
                                    italic: element.italic,
                                    textAlign:
                                        _parseTextAlign(element.textAlign),
                                    rotationDegrees: element.rotationDegrees,
                                    scale: scale,
                                    labelWidthMm: labelWidthMm,
                                    labelHeightMm: labelHeightMm,
                                    canvasInsetXPx: 0,
                                    canvasInsetYPx: _kLabelCanvasHitPadPx,
                                    labelPanToMmDelta: labelPanToMmDelta,
                                    isCustom: true,
                                    maxWidthMm: element.maxWidthMm,
                                    colorArgb: element.colorArgb,
                                    onMaxWidthChanged: (w) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(maxWidthMm: w),
                                      );
                                    },
                                    isInlineEditing: inlineCanvasCustomKey ==
                                        'custom:${page1 ? '1' : '2'}:${element.id}',
                                    isSelected: selectedElement ==
                                        'custom:${page1 ? '1' : '2'}:${element.id}',
                                    onInlineEditingComplete: (v) {
                                      onInlineEditingComplete(element, v);
                                    },
                                    onInlineTextInsertBinding:
                                        onInlineTextInsertBinding,
                                    onTap: () {
                                      onSelectElement(
                                          'custom:${page1 ? '1' : '2'}:${element.id}');
                                    },
                                    onSelect: () {
                                      onSelectElement(
                                          'custom:${page1 ? '1' : '2'}:${element.id}');
                                    },
                                    onDoubleTap: () {
                                      widget.onStartInlineEditing(
                                          'custom:${page1 ? '1' : '2'}:${element.id}');
                                    },
                                    onDragStateChanged: onDragStateChanged,
                                    onMoved: (pos) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(
                                            xMm: pos.dx, yMm: pos.dy),
                                      );
                                    },
                                  );
                                }
                              } else if (element is CustomLineElement) {
                                return DraggableLineChip(
                                  key: ValueKey(
                                      'p${page1 ? '1' : '2'}_line_${element.id}'),
                                  position: Offset(element.xMm, element.yMm),
                                  lengthMm: element.lengthMm,
                                  thicknessPt: element.thicknessPt,
                                  colorArgb: element.colorArgb,
                                  rotationDegrees: element.rotationDegrees,
                                  scale: scale,
                                  labelWidthMm: labelWidthMm,
                                  labelHeightMm: labelHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kLabelCanvasHitPadPx,
                                  labelPanToMmDelta: labelPanToMmDelta,
                                  isSelected: selectedElement ==
                                      'line:${page1 ? '1' : '2'}:${element.id}',
                                  onTap: () => onSelectElement(
                                      'line:${page1 ? '1' : '2'}:${element.id}'),
                                  onDragStateChanged: onDragStateChanged,
                                  onMoved: (pos) {
                                    onScheduleTemplateLineUpdate(element
                                        .copyWith(xMm: pos.dx, yMm: pos.dy));
                                  },
                                  onBoundsChanged: (x, y, w, h) {
                                    onScheduleTemplateLineUpdate(element
                                        .copyWith(xMm: x, yMm: y, lengthMm: w));
                                  },
                                  onRotationChanged: (deg) {
                                    onScheduleTemplateLineUpdate(
                                        element.copyWith(rotationDegrees: deg));
                                  },
                                  onDelete: () =>
                                      onRemoveCustomLine(element.id),
                                );
                              } else if (element is CustomShapeElement) {
                                return DraggableShapeChip(
                                  key: ValueKey(
                                      'p${page1 ? '1' : '2'}_shape_${element.id}'),
                                  shapeType: element.shapeType,
                                  position: Offset(element.xMm, element.yMm),
                                  widthMm: element.widthMm,
                                  heightMm: element.heightMm,
                                  strokeThicknessPt: element.strokeThicknessPt,
                                  strokeColorArgb: element.strokeColorArgb,
                                  fillColorArgb: element.fillColorArgb,
                                  rotationDegrees: element.rotationDegrees,
                                  scale: scale,
                                  labelWidthMm: labelWidthMm,
                                  labelHeightMm: labelHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kLabelCanvasHitPadPx,
                                  labelPanToMmDelta: labelPanToMmDelta,
                                  isSelected: selectedElement ==
                                      'shape:${page1 ? '1' : '2'}:${element.id}',
                                  onTap: () => onSelectElement(
                                      'shape:${page1 ? '1' : '2'}:${element.id}'),
                                  onDragStateChanged: onDragStateChanged,
                                  onMoved: (pos) {
                                    onScheduleTemplateShapeUpdate(element
                                        .copyWith(xMm: pos.dx, yMm: pos.dy));
                                  },
                                  onBoundsChanged: (x, y, w, h) {
                                    onScheduleTemplateShapeUpdate(
                                        element.copyWith(
                                            xMm: x,
                                            yMm: y,
                                            widthMm: w,
                                            heightMm: h));
                                  },
                                  onRotationChanged: (deg) {
                                    onScheduleTemplateShapeUpdate(
                                        element.copyWith(rotationDegrees: deg));
                                  },
                                  onDelete: () =>
                                      onRemoveCustomShape(element.id),
                                );
                              }
                              return const SizedBox.shrink();
                            }).toList();
                          })(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
