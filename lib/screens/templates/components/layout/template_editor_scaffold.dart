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
    required this.onSaveTemplate,
    required this.onImportTemplate,
    required this.onExportTemplate,
    required this.onDeleteTemplate,
    required this.onTemplateSelected,
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
  final VoidCallback onSaveTemplate;
  final VoidCallback onImportTemplate;
  final VoidCallback onExportTemplate;
  final VoidCallback onDeleteTemplate;
  final ValueChanged<String> onTemplateSelected;
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
  final Widget? borderPanel;

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isIOS || Platform.isAndroid;
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return Scaffold(
      appBar: _TemplateEditorAppBar(
        canDeleteSavedTemplate: canDeleteSavedTemplate,
        onSaveTemplate: onSaveTemplate,
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
              currentTemplateName: template.name,
              isDuplex: isDuplex,
              isPage1: isPage1,
              mirrorFront: mirrorFront,
              mirrorBack: mirrorBack,
              templateWidthMm: templateWidthMm,
              templateHeightMm: templateHeightMm,
              isBorderPanelOpen: isBorderPanelOpen,
              showGrid: showGrid,
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
              onSelectPreviewSpecimen: onSelectPreviewSpecimen,
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
            ),
            Expanded(
              child: TemplateCanvasWorkspace(
                isDuplex: isDuplex,
                tabController: tabController,
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
              ),
            ),
            if (isBorderPanelOpen && borderPanel != null) borderPanel!,
          ],
        ),
      ),
    );
  }
}

class _TemplateEditorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _TemplateEditorAppBar({
    required this.canDeleteSavedTemplate,
    required this.onSaveTemplate,
    required this.onImportTemplate,
    required this.onExportTemplate,
    required this.onDeleteTemplate,
  });

  final bool canDeleteSavedTemplate;
  final VoidCallback onSaveTemplate;
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
          onPressed: onSaveTemplate,
          icon: const Icon(Icons.save_outlined),
          tooltip: 'Save template',
        ),
        PopupMenuButton<String>(
          tooltip: 'Template Options',
          icon: const Icon(Icons.more_vert),
          onSelected: (action) {
            if (action == 'import') {
              onImportTemplate();
            } else if (action == 'export') {
              onExportTemplate();
            } else if (action == 'delete') {
              onDeleteTemplate();
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'import',
              child: Text('Import template'),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Text('Export template'),
            ),
            if (canDeleteSavedTemplate)
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete template',
                  style: TextStyle(color: scheme.error),
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
  });

  final String? selectedElement;
  final bool isPage1;
  final Template template;
  final void Function(bool page1, CustomTextElement element) onUpdateCustomText;
  final void Function(bool page1, String id) onDeleteCustomText;
  final void Function(bool page1, CustomImageElement element)
      onUpdateCustomImage;
  final void Function(bool page1, String id) onDeleteCustomImage;
  final void Function(bool page1, CustomLineElement element) onUpdateCustomLine;
  final void Function(bool page1, String id) onDeleteCustomLine;
  final void Function(bool page1, CustomShapeElement element)
      onUpdateCustomShape;
  final void Function(bool page1, String id) onDeleteCustomShape;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: selectedElement != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TemplateElementPropertiesPanel(
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
                onDismiss: onDismiss,
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
