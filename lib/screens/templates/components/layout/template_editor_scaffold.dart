import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_workspace.dart';
import 'package:nahpu/screens/templates/components/controls/template_editor_toolbar.dart';
import 'package:nahpu/screens/templates/components/properties/template_element_properties_panel.dart';
import 'package:nahpu/screens/templates/template_model.dart';

class TemplateEditorScaffold extends StatelessWidget {
  const TemplateEditorScaffold({
    super.key,
    required this.savedNames,
    required this.template,
    required this.isDuplex,
    required this.isPage1,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.templateWidthMm,
    required this.templateHeightMm,
    required this.isBorderPanelOpen,
    required this.showGrid,
    required this.snapEnabled,
    required this.canvasMovementLocked,
    required this.selectedElement,
    required this.tabController,
    required this.zoom,
    required this.isPreviewMode,
    required this.editorTemplateFieldPreview,
    required this.frontStackKey,
    required this.backStackKey,
    required this.templatePanGlobalDeltaToMm,
    required this.fieldDisplayOption,
    required this.canDeleteSavedTemplate,
    required this.onCreateNewTemplate,
    required this.onSaveTemplate,
    required this.onSaveAsTemplate,
    required this.onImportTemplate,
    required this.onExportTemplate,
    required this.onDeleteTemplate,
    required this.onTemplateSelected,
    required this.onDescriptionChanged,
    required this.onDuplexChanged,
    required this.onPageChanged,
    required this.onTemplateSizeChanged,
    required this.onAddText,
    required this.onAddImage,
    required this.onAddLine,
    required this.onAddShape,
    required this.onMirrorToggled,
    required this.onBorderPanelToggled,
    required this.onGridToggled,
    required this.onSnapToggled,
    required this.onCanvasMovementLockToggled,
    required this.onSelectPreviewSpecimen,
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
    required this.onUpdateCustomText,
    required this.onDeleteCustomText,
    required this.onUpdateCustomImage,
    required this.onUpdateCustomLine,
    required this.onUpdateCustomShape,
    required this.onDismissProperties,
    required this.onZoomChanged,
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
    required this.onDuplicateElement,
    this.onDragStateChanged,
    this.borderPanel,
  });

  final List<String> savedNames;
  final Template template;
  final bool isDuplex;
  final bool isPage1;
  final bool mirrorFront;
  final bool mirrorBack;
  final double templateWidthMm;
  final double templateHeightMm;
  final bool isBorderPanelOpen;
  final bool showGrid;
  final bool snapEnabled;
  final bool canvasMovementLocked;
  final String? selectedElement;
  final TabController tabController;
  final double zoom;
  final bool isPreviewMode;
  final Map<String, String> editorTemplateFieldPreview;
  final GlobalKey frontStackKey;
  final GlobalKey backStackKey;
  final Offset? Function(
    GlobalKey stackKey,
    Offset globalPosition,
    Offset globalDelta,
    double scale,
  ) templatePanGlobalDeltaToMm;
  final String fieldDisplayOption;
  final bool canDeleteSavedTemplate;
  final VoidCallback onCreateNewTemplate;
  final VoidCallback onSaveTemplate;
  final VoidCallback onSaveAsTemplate;
  final VoidCallback onImportTemplate;
  final VoidCallback onExportTemplate;
  final VoidCallback onDeleteTemplate;
  final ValueChanged<String> onTemplateSelected;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<bool> onDuplexChanged;
  final ValueChanged<int> onPageChanged;
  final void Function(double widthMm, double heightMm) onTemplateSizeChanged;
  final VoidCallback onAddText;
  final VoidCallback onAddImage;
  final VoidCallback onAddLine;
  final VoidCallback onAddShape;
  final VoidCallback onMirrorToggled;
  final VoidCallback onBorderPanelToggled;
  final VoidCallback onGridToggled;
  final VoidCallback onSnapToggled;
  final VoidCallback onCanvasMovementLockToggled;
  final VoidCallback onSelectPreviewSpecimen;
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
  final void Function(bool page1, CustomTextElement element) onUpdateCustomText;
  final void Function(bool page1, String id) onDeleteCustomText;
  final void Function(bool page1, CustomImageElement element)
      onUpdateCustomImage;
  final void Function(bool page1, CustomLineElement element) onUpdateCustomLine;
  final void Function(bool page1, CustomShapeElement element)
      onUpdateCustomShape;
  final VoidCallback onDismissProperties;
  final ValueChanged<double> onZoomChanged;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo;
  final ValueChanged<String> onDuplicateElement;
  final ValueChanged<bool>? onDragStateChanged;
  final Widget? borderPanel;

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isIOS || Platform.isAndroid;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final selected = selectedElement;

    return Scaffold(
      appBar: _TemplateEditorAppBar(
        canDeleteSavedTemplate: canDeleteSavedTemplate,
        onCreateNewTemplate: onCreateNewTemplate,
        onSaveTemplate: onSaveTemplate,
        onSaveAsTemplate: onSaveAsTemplate,
        onImportTemplate: onImportTemplate,
        onExportTemplate: onExportTemplate,
        onDeleteTemplate: onDeleteTemplate,
      ),
      body: Padding(
        padding: isMobile
            ? EdgeInsets.only(
                left: viewPadding.left,
                right: viewPadding.right,
                bottom: viewPadding.bottom,
              )
            : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TemplateEditorToolbar(
              savedNames: savedNames,
              template: template,
              onDescriptionChanged: onDescriptionChanged,
              isDuplex: isDuplex,
              isPage1: isPage1,
              mirrorFront: mirrorFront,
              mirrorBack: mirrorBack,
              templateWidthMm: templateWidthMm,
              templateHeightMm: templateHeightMm,
              isBorderPanelOpen: isBorderPanelOpen,
              showGrid: showGrid,
              snapEnabled: snapEnabled,
              canvasMovementLocked: canvasMovementLocked,
              onSaveTemplate: onSaveTemplate,
              onTemplateSelected: onTemplateSelected,
              onDuplexChanged: onDuplexChanged,
              onPageChanged: onPageChanged,
              onTemplateSizeChanged: onTemplateSizeChanged,
              onAddText: onAddText,
              onAddImage: onAddImage,
              onAddLine: onAddLine,
              onAddShape: onAddShape,
              onMirrorToggled: onMirrorToggled,
              onBorderPanelToggled: onBorderPanelToggled,
              onGridToggled: onGridToggled,
              onSnapToggled: onSnapToggled,
              onCanvasMovementLockToggled: onCanvasMovementLockToggled,
              onSelectPreviewSpecimen: onSelectPreviewSpecimen,
              onUndo: onUndo,
              onRedo: onRedo,
              canUndo: canUndo,
              canRedo: canRedo,
            ),
            _TemplatePropertiesStrip(
              selectedElement: selectedElement,
              isPage1: isPage1,
              template: template,
              onUpdateCustomText: onUpdateCustomText,
              onDeleteCustomText: onDeleteCustomText,
              onUpdateCustomImage: onUpdateCustomImage,
              onDeleteCustomImage: onRemoveCustomImage,
              onUpdateCustomLine: onUpdateCustomLine,
              onDeleteCustomLine: onRemoveCustomLine,
              onUpdateCustomShape: onUpdateCustomShape,
              onDeleteCustomShape: onRemoveCustomShape,
              onDismiss: onDismissProperties,
              isBorderPanelOpen: isBorderPanelOpen,
              onDuplicateElement: onDuplicateElement,
              borderPanel: borderPanel,
            ),
            Expanded(
              child: TemplateCanvasWorkspace(
                isDuplex: isDuplex,
                tabController: tabController,
                template: template,
                templateWidthMm: templateWidthMm,
                templateHeightMm: templateHeightMm,
                zoom: zoom,
                canvasMovementLocked: canvasMovementLocked,
                showGrid: showGrid,
                snapEnabled: snapEnabled,
                mirrorFront: mirrorFront,
                mirrorBack: mirrorBack,
                isPreviewMode: isPreviewMode,
                editorTemplateFieldPreview: editorTemplateFieldPreview,
                selectedElement: selectedElement,
                frontStackKey: frontStackKey,
                backStackKey: backStackKey,
                templatePanGlobalDeltaToMm: templatePanGlobalDeltaToMm,
                fieldDisplayOption: fieldDisplayOption,
                onClearSelection: onClearSelection,
                onSelectElement: onSelectElement,
                onStartInlineEditing: onStartInlineEditing,
                onScheduleTemplateImageUpdate: onScheduleTemplateImageUpdate,
                onRemoveCustomImage: onRemoveCustomImage,
                onScheduleTemplateTextPositionUpdate:
                    onScheduleTemplateTextPositionUpdate,
                onScheduleTemplateLineUpdate: onScheduleTemplateLineUpdate,
                onRemoveCustomLine: onRemoveCustomLine,
                onScheduleTemplateShapeUpdate: onScheduleTemplateShapeUpdate,
                onRemoveCustomShape: onRemoveCustomShape,
                onZoomChanged: onZoomChanged,
                onCanvasMovementLockToggled: onCanvasMovementLockToggled,
                onGridToggled: onGridToggled,
                onSnapToggled: onSnapToggled,
                onUndo: onUndo,
                onRedo: onRedo,
                canUndo: canUndo,
                canRedo: canRedo,
                onDeleteSelectedElement: selected == null
                    ? null
                    : () => _deleteSelectedElement(selected),
                onDuplicateSelectedElement: selected == null
                    ? null
                    : () => onDuplicateElement(selected),
                onDragStateChanged: onDragStateChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSelectedElement(String selected) {
    final selection = TemplateSelection.parse(selected);
    if (selection == null) return;
    switch (selection.type) {
      case TemplateElementType.text:
        onDeleteCustomText(selection.page1, selection.id);
      case TemplateElementType.image:
        onRemoveCustomImage(selection.page1, selection.id);
      case TemplateElementType.line:
        onRemoveCustomLine(selection.page1, selection.id);
      case TemplateElementType.shape:
        onRemoveCustomShape(selection.page1, selection.id);
    }
  }
}

class _TemplateEditorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _TemplateEditorAppBar({
    required this.canDeleteSavedTemplate,
    required this.onCreateNewTemplate,
    required this.onSaveTemplate,
    required this.onSaveAsTemplate,
    required this.onImportTemplate,
    required this.onExportTemplate,
    required this.onDeleteTemplate,
  });

  final bool canDeleteSavedTemplate;
  final VoidCallback onCreateNewTemplate;
  final VoidCallback onSaveTemplate;
  final VoidCallback onSaveAsTemplate;
  final VoidCallback onImportTemplate;
  final VoidCallback onExportTemplate;
  final VoidCallback onDeleteTemplate;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      title: const Text('Template Editor'),
      actions: [
        IconButton(
          onPressed: onCreateNewTemplate,
          icon: const Icon(Icons.add_circle_outline_rounded),
          tooltip: 'Create new template',
        ),
        PopupMenuButton<String>(
          tooltip: 'Template Options',
          onSelected: (action) {
            if (action == 'create') {
              onCreateNewTemplate();
            } else if (action == 'save') {
              onSaveTemplate();
            } else if (action == 'save_as') {
              onSaveAsTemplate();
            } else if (action == 'import') {
              onImportTemplate();
            } else if (action == 'export') {
              onExportTemplate();
            } else if (action == 'delete') {
              onDeleteTemplate();
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'create',
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded),
                  SizedBox(width: 8),
                  Text('Create new'),
                ],
              ),
            ),
            const PopupMenuDivider(height: 8),
            const PopupMenuItem(
              value: 'save',
              child: Row(
                children: [
                  Icon(Icons.save_outlined),
                  SizedBox(width: 8),
                  Text('Save'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'save_as',
              child: Row(
                children: [
                  Icon(Icons.save_as_outlined),
                  SizedBox(width: 8),
                  Text('Save as...'),
                ],
              ),
            ),
            const PopupMenuDivider(height: 8),
            const PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.file_download_outlined),
                  SizedBox(width: 8),
                  Text('Import'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.file_upload_outlined),
                  SizedBox(width: 8),
                  Text('Export'),
                ],
              ),
            ),
            const PopupMenuDivider(height: 8),
            if (canDeleteSavedTemplate)
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: scheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: scheme.error),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TemplatePropertiesStrip extends StatelessWidget {
  const _TemplatePropertiesStrip({
    required this.selectedElement,
    required this.isPage1,
    required this.template,
    required this.onUpdateCustomText,
    required this.onDeleteCustomText,
    required this.onUpdateCustomImage,
    required this.onDeleteCustomImage,
    required this.onUpdateCustomLine,
    required this.onDeleteCustomLine,
    required this.onUpdateCustomShape,
    required this.onDeleteCustomShape,
    required this.onDismiss,
    required this.isBorderPanelOpen,
    required this.onDuplicateElement,
    this.borderPanel,
  });

  final String? selectedElement;
  final bool isPage1;
  final Template template;
  final void Function(
    bool page1,
    CustomTextElement element,
  ) onUpdateCustomText;
  final void Function(
    bool page1,
    String id,
  ) onDeleteCustomText;
  final void Function(
    bool page1,
    CustomImageElement element,
  ) onUpdateCustomImage;
  final void Function(
    bool page1,
    String id,
  ) onDeleteCustomImage;
  final void Function(
    bool page1,
    CustomLineElement element,
  ) onUpdateCustomLine;
  final void Function(
    bool page1,
    String id,
  ) onDeleteCustomLine;
  final void Function(
    bool page1,
    CustomShapeElement element,
  ) onUpdateCustomShape;
  final void Function(
    bool page1,
    String id,
  ) onDeleteCustomShape;
  final VoidCallback onDismiss;
  final bool isBorderPanelOpen;
  final ValueChanged<String> onDuplicateElement;
  final Widget? borderPanel;

  @override
  Widget build(BuildContext context) {
    Widget? activeChild;
    if (selectedElement != null) {
      activeChild = TemplateElementPropertiesPanel(
        selectedElement: selectedElement!,
        page1: isPage1,
        template: template,
        onUpdateCustomText: onUpdateCustomText,
        onDeleteCustomText: onDeleteCustomText,
        onUpdateCustomImage: onUpdateCustomImage,
        onDeleteCustomImage: onDeleteCustomImage,
        onUpdateCustomLine: onUpdateCustomLine,
        onDeleteCustomLine: onDeleteCustomLine,
        onUpdateCustomShape: onUpdateCustomShape,
        onDeleteCustomShape: onDeleteCustomShape,
        onDuplicateElement: onDuplicateElement,
        onDismiss: onDismiss,
      );
    } else if (isBorderPanelOpen && borderPanel != null) {
      activeChild = borderPanel;
    }

    if (activeChild == null) {
      return const SizedBox(width: double.infinity, height: 0);
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: activeChild,
      ),
    );
  }
}
