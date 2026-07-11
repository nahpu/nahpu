import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_editor.dart';
import 'package:nahpu/screens/templates/components/controls/zoom_controls.dart';
import 'package:nahpu/screens/templates/template_model.dart';

/// Hosts the editable template canvas and owns workspace-level interactions.
///
/// The workspace coordinates view controls that should behave the same for
/// every canvas element type: viewport pan lock, keyboard shortcuts, and zoom
/// changes from buttons or gestures. Element editing remains inside the
/// concrete draggable widgets below [TemplateCanvasEditor].
class TemplateCanvasWorkspace extends StatefulWidget {
  const TemplateCanvasWorkspace({
    super.key,
    required this.isDuplex,
    required this.tabController,
    required this.template,
    required this.templateWidthMm,
    required this.templateHeightMm,
    required this.zoom,
    required this.canvasMovementLocked,
    required this.showGrid,
    required this.snapEnabled,
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
    required this.onCanvasMovementLockToggled,
    required this.onGridToggled,
    required this.onSnapToggled,
    this.onUndo,
    this.onRedo,
    this.onDeleteSelectedElement,
    this.onDuplicateSelectedElement,
    this.onCopySelectedElement,
    this.onPasteElement,
    this.canUndo = false,
    this.canRedo = false,
    this.onDragStateChanged,
  });

  final bool isDuplex;
  final ValueChanged<bool>? onDragStateChanged;
  final TabController tabController;
  final Template template;
  final double templateWidthMm;
  final double templateHeightMm;
  final double zoom;
  final bool canvasMovementLocked;
  final bool showGrid;
  final bool snapEnabled;
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
  final VoidCallback onCanvasMovementLockToggled;
  final VoidCallback onGridToggled;
  final VoidCallback onSnapToggled;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onDeleteSelectedElement;
  final VoidCallback? onDuplicateSelectedElement;
  final VoidCallback? onCopySelectedElement;
  final VoidCallback? onPasteElement;
  final bool canUndo;
  final bool canRedo;

  @override
  State<TemplateCanvasWorkspace> createState() =>
      _TemplateCanvasWorkspaceState();
}

class _TemplateCanvasWorkspaceState extends State<TemplateCanvasWorkspace> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'Template canvas');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: CallbackShortcuts(
        bindings: _shortcutBindings,
        child: Listener(
          onPointerDown: (_) => _focusNode.requestFocus(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: widget.isDuplex
                    ? TabBarView(
                        controller: widget.tabController,
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
                  zoom: widget.zoom,
                  onZoomChanged: widget.onZoomChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> get _shortcutBindings => {
        const SingleActivator(LogicalKeyboardKey.equal, meta: true): _zoomIn,
        const SingleActivator(LogicalKeyboardKey.equal, control: true): _zoomIn,
        const SingleActivator(LogicalKeyboardKey.add, meta: true): _zoomIn,
        const SingleActivator(LogicalKeyboardKey.add, control: true): _zoomIn,
        const SingleActivator(LogicalKeyboardKey.minus, meta: true): _zoomOut,
        const SingleActivator(LogicalKeyboardKey.minus, control: true):
            _zoomOut,
        const SingleActivator(LogicalKeyboardKey.digit0, meta: true):
            _resetZoom,
        const SingleActivator(LogicalKeyboardKey.digit0, control: true):
            _resetZoom,
        const SingleActivator(LogicalKeyboardKey.keyL, meta: true):
            widget.onCanvasMovementLockToggled,
        const SingleActivator(LogicalKeyboardKey.keyL, control: true):
            widget.onCanvasMovementLockToggled,
        const SingleActivator(LogicalKeyboardKey.keyG, meta: true):
            widget.onGridToggled,
        const SingleActivator(LogicalKeyboardKey.keyG, control: true):
            widget.onGridToggled,
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true, shift: true):
            widget.onSnapToggled,
        const SingleActivator(
          LogicalKeyboardKey.keyS,
          control: true,
          shift: true,
        ): widget.onSnapToggled,
        if (widget.canUndo && widget.onUndo != null)
          const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
              widget.onUndo!,
        if (widget.canUndo && widget.onUndo != null)
          const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
              widget.onUndo!,
        if (widget.canRedo && widget.onRedo != null)
          const SingleActivator(
            LogicalKeyboardKey.keyZ,
            meta: true,
            shift: true,
          ): widget.onRedo!,
        if (widget.canRedo && widget.onRedo != null)
          const SingleActivator(
            LogicalKeyboardKey.keyZ,
            control: true,
            shift: true,
          ): widget.onRedo!,
        if (widget.canRedo && widget.onRedo != null)
          const SingleActivator(LogicalKeyboardKey.keyY, control: true):
              widget.onRedo!,
        if (widget.onDeleteSelectedElement != null)
          const SingleActivator(LogicalKeyboardKey.delete):
              widget.onDeleteSelectedElement!,
        if (widget.onDeleteSelectedElement != null)
          const SingleActivator(LogicalKeyboardKey.backspace):
              widget.onDeleteSelectedElement!,
        if (widget.onDuplicateSelectedElement != null)
          const SingleActivator(LogicalKeyboardKey.keyD, meta: true):
              widget.onDuplicateSelectedElement!,
        if (widget.onDuplicateSelectedElement != null)
          const SingleActivator(LogicalKeyboardKey.keyD, control: true):
              widget.onDuplicateSelectedElement!,
        if (widget.onCopySelectedElement != null)
          const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
              widget.onCopySelectedElement!,
        if (widget.onCopySelectedElement != null)
          const SingleActivator(LogicalKeyboardKey.keyC, control: true):
              widget.onCopySelectedElement!,
        if (widget.onPasteElement != null)
          const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
              widget.onPasteElement!,
        if (widget.onPasteElement != null)
          const SingleActivator(LogicalKeyboardKey.keyV, control: true):
              widget.onPasteElement!,
        const SingleActivator(LogicalKeyboardKey.escape):
            widget.onClearSelection,
      };

  void _zoomIn() {
    widget.onZoomChanged((widget.zoom + 0.25).clamp(0.5, 4.0).toDouble());
  }

  void _zoomOut() {
    widget.onZoomChanged((widget.zoom - 0.25).clamp(0.5, 4.0).toDouble());
  }

  void _resetZoom() {
    widget.onZoomChanged(1.0);
  }

  Widget _buildCanvas({required bool page1}) {
    return TemplateCanvasEditor(
      page1: page1,
      template: widget.template,
      templateWidthMm: widget.templateWidthMm,
      templateHeightMm: widget.templateHeightMm,
      zoom: widget.zoom,
      canvasMovementLocked: widget.canvasMovementLocked,
      showGrid: widget.showGrid,
      snapEnabled: widget.snapEnabled,
      mirrorFront: widget.mirrorFront,
      mirrorBack: widget.mirrorBack,
      isPreviewMode: widget.isPreviewMode,
      editorTemplateFieldPreview: widget.editorTemplateFieldPreview,
      selectedElement: widget.selectedElement,
      templateStackKey: page1 ? widget.frontStackKey : widget.backStackKey,
      templatePanGlobalDeltaToMm: widget.templatePanGlobalDeltaToMm,
      fieldDisplayOption: widget.fieldDisplayOption,
      onClearSelection: widget.onClearSelection,
      onSelectElement: widget.onSelectElement,
      onStartInlineEditing: widget.onStartInlineEditing,
      onDragStateChanged: widget.onDragStateChanged,
      onZoomChanged: widget.onZoomChanged,
      onScheduleTemplateImageUpdate: (element) =>
          widget.onScheduleTemplateImageUpdate(page1, element),
      onRemoveCustomImage: (id) => widget.onRemoveCustomImage(page1, id),
      onScheduleTemplateTextPositionUpdate: (element) =>
          widget.onScheduleTemplateTextPositionUpdate(page1, element),
      onScheduleTemplateLineUpdate: (element) =>
          widget.onScheduleTemplateLineUpdate(page1, element),
      onRemoveCustomLine: (id) => widget.onRemoveCustomLine(page1, id),
      onScheduleTemplateShapeUpdate: (element) =>
          widget.onScheduleTemplateShapeUpdate(page1, element),
      onRemoveCustomShape: (id) => widget.onRemoveCustomShape(page1, id),
    );
  }
}
