import 'package:flutter/material.dart';
import 'package:nahpu/screens/template_editor/components/canvas/template_canvas_editor.dart';
import 'package:nahpu/screens/template_editor/components/controls/zoom_controls.dart';
import 'package:nahpu/screens/template_editor/template_model.dart';

class TemplateCanvasWorkspace extends StatelessWidget {
  const TemplateCanvasWorkspace({
    super.key,
    required this.isDuplex,
    required this.tabController,
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
    required this.frontStackKey,
    required this.backStackKey,
    required this.templatePanGlobalDeltaToMm,
    required this.fieldDisplayOption,
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
    required this.onZoomChanged,
  });

  final bool isDuplex;
  final TabController tabController;
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
  final GlobalKey frontStackKey;
  final GlobalKey backStackKey;
  final Offset? Function(
    GlobalKey stackKey,
    Offset globalPosition,
    Offset globalDelta,
    double scale,
  ) templatePanGlobalDeltaToMm;
  final String fieldDisplayOption;
  final VoidCallback onClearSelection;
  final ValueChanged<String> onSelectElement;
  final ValueChanged<String> onStartInlineEditing;
  final void Function(bool page1, CustomImageElement element)
      onScheduleTemplateImageUpdate;
  final void Function(bool page1, String id) onRemoveCustomImage;
  final void Function(bool page1, CustomTextElement element)
      onScheduleTemplateTextPositionUpdate;
  final void Function(bool page1, CustomLineElement element)
      onScheduleTemplateLineUpdate;
  final void Function(bool page1, String id) onRemoveCustomLine;
  final void Function(bool page1, CustomShapeElement element)
      onScheduleTemplateShapeUpdate;
  final void Function(bool page1, String id) onRemoveCustomShape;
  final ValueChanged<double> onZoomChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: isDuplex
              ? TabBarView(
                  controller: tabController,
                  children: [
                    _buildCanvas(page1: true),
                    _buildCanvas(page1: false),
                  ],
                )
              : _buildCanvas(page1: true),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: ZoomControls(
            zoom: zoom,
            onZoomChanged: onZoomChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCanvas({required bool page1}) {
    return TemplateCanvasEditor(
      page1: page1,
      template: template,
      templateWidthMm: templateWidthMm,
      templateHeightMm: templateHeightMm,
      zoom: zoom,
      showGrid: showGrid,
      mirrorFront: mirrorFront,
      mirrorBack: mirrorBack,
      isPreviewMode: isPreviewMode,
      editorTemplateFieldPreview: editorTemplateFieldPreview,
      selectedElement: selectedElement,
      templateStackKey: page1 ? frontStackKey : backStackKey,
      templatePanGlobalDeltaToMm: templatePanGlobalDeltaToMm,
      fieldDisplayOption: fieldDisplayOption,
      onClearSelection: onClearSelection,
      onSelectElement: onSelectElement,
      onStartInlineEditing: onStartInlineEditing,
      onScheduleTemplateImageUpdate: (element) =>
          onScheduleTemplateImageUpdate(page1, element),
      onRemoveCustomImage: (id) => onRemoveCustomImage(page1, id),
      onScheduleTemplateTextPositionUpdate: (element) =>
          onScheduleTemplateTextPositionUpdate(page1, element),
      onScheduleTemplateLineUpdate: (element) =>
          onScheduleTemplateLineUpdate(page1, element),
      onRemoveCustomLine: (id) => onRemoveCustomLine(page1, id),
      onScheduleTemplateShapeUpdate: (element) =>
          onScheduleTemplateShapeUpdate(page1, element),
      onRemoveCustomShape: (id) => onRemoveCustomShape(page1, id),
    );
  }
}
