import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/template_outline.dart'
    show templateAreaStackDecoration, TemplateOutlineOverlayPainter;
import 'package:nahpu/screens/templates/template_gender_icon.dart'
    show templateGenderIconForFieldKey;
import 'package:nahpu/services/export/document_writer.dart'
    show substituteDocumentPlaceholders;
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_chip.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_image_chip.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_line_chip.dart';
import 'package:nahpu/screens/templates/components/canvas/draggable_shape_chip.dart';
import 'package:nahpu/screens/shared/media/qr.dart' show QrImageView;

import 'dart:math' as math;
import 'package:nahpu/screens/templates/template_canvas_stack.dart';
import 'package:nahpu/screens/templates/components/canvas/grid_painter.dart';

const double _kTemplateCanvasHitPadPx = 72.0;

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

class TemplateCanvasEditor extends StatefulWidget {
  const TemplateCanvasEditor({
    super.key,
    required this.page1,
    required this.template,
    required this.templateWidthMm,
    required this.templateHeightMm,
    required this.zoom,
    required this.showGrid,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.isPreviewMode,
    required this.editorTemplateFieldPreview,
    required this.selectedElement,
    required this.templateStackKey,
    required this.templatePanGlobalDeltaToMm,
    required this.onClearSelection,
    required this.onSelectElement,
    required this.onStartInlineEditing,
    required this.onScheduleTemplateImageUpdate,
    required this.onRemoveCustomImage,
    required this.onScheduleTemplateTextPositionUpdate,
    required this.onScheduleTemplateLineUpdate,
    required this.onRemoveCustomLine,
    required this.onScheduleTemplateShapeUpdate,
    required this.onRemoveCustomShape,
    this.fieldDisplayOption = 'short',
  });

  final bool page1;
  final Template template;
  final double templateWidthMm;
  final double templateHeightMm;
  final double zoom;
  final bool showGrid;
  final bool mirrorFront;
  final bool mirrorBack;
  final bool isPreviewMode;
  final Map<String, String> editorTemplateFieldPreview;
  final String? selectedElement;
  final GlobalKey templateStackKey;
  final String fieldDisplayOption;

  final Offset? Function(GlobalKey stackKey, Offset globalPosition,
      Offset globalDelta, double scale) templatePanGlobalDeltaToMm;
  final VoidCallback onClearSelection;
  final void Function(String id) onSelectElement;
  final void Function(String id) onStartInlineEditing;
  final void Function(CustomImageElement element) onScheduleTemplateImageUpdate;
  final void Function(String id) onRemoveCustomImage;
  final void Function(CustomTextElement element)
      onScheduleTemplateTextPositionUpdate;
  final void Function(CustomLineElement element) onScheduleTemplateLineUpdate;
  final void Function(String id) onRemoveCustomLine;
  final void Function(CustomShapeElement element) onScheduleTemplateShapeUpdate;
  final void Function(String id) onRemoveCustomShape;

  @override
  State<TemplateCanvasEditor> createState() => _TemplateCanvasEditorState();
}

class _TemplateCanvasEditorState extends State<TemplateCanvasEditor> {
  bool _canvasPanEnabled = true;

  @override
  Widget build(BuildContext context) {
    final page1 = widget.page1;
    final template = widget.template;
    final templateWidthMm = widget.templateWidthMm;
    final templateHeightMm = widget.templateHeightMm;
    final zoom = widget.zoom;
    final showGrid = widget.showGrid;
    final mirrorFront = widget.mirrorFront;
    final mirrorBack = widget.mirrorBack;
    final isPreviewMode = widget.isPreviewMode;
    final editorTemplateFieldPreview = widget.editorTemplateFieldPreview;
    final selectedElement = widget.selectedElement;
    final templateStackKey = widget.templateStackKey;
    final templatePanGlobalDeltaToMm = widget.templatePanGlobalDeltaToMm;
    final onClearSelection = widget.onClearSelection;
    final onSelectElement = widget.onSelectElement;
    final onScheduleTemplateImageUpdate = widget.onScheduleTemplateImageUpdate;
    final onRemoveCustomImage = widget.onRemoveCustomImage;
    final onScheduleTemplateTextPositionUpdate =
        widget.onScheduleTemplateTextPositionUpdate;
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
          (availW / templateWidthMm).clamp(1.0, availH / templateHeightMm);
      final scale = baseScale * zoom;
      final canvasW = templateWidthMm * scale;
      final canvasH = templateHeightMm * scale;
      final stackW = canvasW + _kTemplateCanvasHitPadPx;
      final stackH = canvasH + 2 * _kTemplateCanvasHitPadPx;

      Offset? templatePanToMmDelta(Offset globalPosition, Offset globalDelta) {
        return templatePanGlobalDeltaToMm(
          templateStackKey,
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
                      child: TemplateCanvasStack(
                        key: templateStackKey,
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            left: 0,
                            top: _kTemplateCanvasHitPadPx,
                            width: canvasW,
                            height: canvasH,
                            child: IgnorePointer(
                              child: Stack(
                                fit: StackFit.expand,
                                clipBehavior: Clip.none,
                                children: [
                                  DecoratedBox(
                                    decoration: templateAreaStackDecoration(),
                                    child: showGrid
                                        ? CustomPaint(
                                            painter: GridPainter(
                                              templateWidthMm: templateWidthMm,
                                              templateHeightMm:
                                                  templateHeightMm,
                                              scale: scale,
                                            ),
                                            child: const SizedBox.expand(),
                                          )
                                        : const SizedBox.expand(),
                                  ),
                                  if (template.outline != null)
                                    CustomPaint(
                                      painter: TemplateOutlineOverlayPainter(
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
                                  templateWidthMm: templateWidthMm,
                                  templateHeightMm: templateHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kTemplateCanvasHitPadPx,
                                  templatePanToMmDelta: templatePanToMmDelta,
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
                                  final textVal = formatTemplateText(
                                    isPreviewMode
                                        ? substituteDocumentPlaceholders(
                                            rawText,
                                            editorTemplateFieldPreview,
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
                                    templateWidthMm: templateWidthMm,
                                    templateHeightMm: templateHeightMm,
                                    canvasInsetXPx: 0,
                                    canvasInsetYPx: _kTemplateCanvasHitPadPx,
                                    templatePanToMmDelta: templatePanToMmDelta,
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
                                } else if (templateGenderIconFieldKeyFromBracketText(
                                        element.text)
                                    case final gKey?) {
                                  return DraggableImageChip(
                                    key: ValueKey(
                                        'p${page1 ? '1' : '2'}_gct_${element.id}'),
                                    imagePath: '',
                                    vectorChild: Icon(
                                        templateGenderIconForFieldKey(
                                            editorTemplateFieldPreview, gKey)),
                                    position: Offset(element.xMm, element.yMm),
                                    widthMm: element.iconWidthMm ??
                                        kTemplateGenderIconDefaultWidthMm,
                                    heightMm: element.iconHeightMm ??
                                        kTemplateGenderIconDefaultHeightMm,
                                    rotationDegrees: element.rotationDegrees,
                                    scale: scale,
                                    templateWidthMm: templateWidthMm,
                                    templateHeightMm: templateHeightMm,
                                    canvasInsetXPx: 0,
                                    canvasInsetYPx: _kTemplateCanvasHitPadPx,
                                    templatePanToMmDelta: templatePanToMmDelta,
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
                                        : formatTemplateText(
                                            isPreviewMode
                                                ? substituteDocumentPlaceholders(
                                                    element.text,
                                                    editorTemplateFieldPreview,
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
                                    templateWidthMm: templateWidthMm,
                                    templateHeightMm: templateHeightMm,
                                    canvasInsetXPx: 0,
                                    canvasInsetYPx: _kTemplateCanvasHitPadPx,
                                    templatePanToMmDelta: templatePanToMmDelta,
                                    isCustom: true,
                                    maxWidthMm: element.maxWidthMm,
                                    heightMm: element.heightMm,
                                    colorArgb: element.colorArgb,
                                    isDynamic: element.isDynamic,
                                    onMaxWidthChanged: (w) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(maxWidthMm: w),
                                      );
                                    },
                                    onHeightChanged: (h) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(heightMm: h),
                                      );
                                    },
                                    onResizeChanged: (pos, w, h) {
                                      onScheduleTemplateTextPositionUpdate(
                                        element.copyWith(
                                          xMm: pos.dx,
                                          yMm: pos.dy,
                                          maxWidthMm: w,
                                          heightMm: element.isDynamic ? null : h,
                                        ),
                                      );
                                    },
                                    isSelected: selectedElement ==
                                        'custom:${page1 ? '1' : '2'}:${element.id}',
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
                                  strokeStyle: element.strokeStyle,
                                  rotationDegrees: element.rotationDegrees,
                                  scale: scale,
                                  templateWidthMm: templateWidthMm,
                                  templateHeightMm: templateHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kTemplateCanvasHitPadPx,
                                  templatePanToMmDelta: templatePanToMmDelta,
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
                                  polygonSides: element.polygonSides,
                                  position: Offset(element.xMm, element.yMm),
                                  widthMm: element.widthMm,
                                  heightMm: element.heightMm,
                                  strokeThicknessPt: element.strokeThicknessPt,
                                  strokeColorArgb: element.strokeColorArgb,
                                  fillColorArgb: element.fillColorArgb,
                                  strokeStyle: element.strokeStyle,
                                  rotationDegrees: element.rotationDegrees,
                                  scale: scale,
                                  templateWidthMm: templateWidthMm,
                                  templateHeightMm: templateHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kTemplateCanvasHitPadPx,
                                  templatePanToMmDelta: templatePanToMmDelta,
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
