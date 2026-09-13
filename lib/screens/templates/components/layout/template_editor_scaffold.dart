import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_workspace.dart';
import 'package:nahpu/screens/templates/components/controls/template_editor_toolbar.dart';
import 'package:nahpu/screens/templates/components/controls/template_picker_sheet.dart';
import 'package:nahpu/screens/templates/components/properties/template_element_properties_panel.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/styles/design_tokens.dart';

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
    required this.onTemplateSettingsPressed,
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
    required this.onShowElements,
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
    required this.onCopyElement,
    required this.onPasteElement,
    required this.canPasteElement,
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
  )
  templatePanGlobalDeltaToMm;
  final String fieldDisplayOption;
  final bool canDeleteSavedTemplate;
  final VoidCallback onCreateNewTemplate;
  final VoidCallback onSaveTemplate;
  final VoidCallback onSaveAsTemplate;
  final VoidCallback onImportTemplate;
  final VoidCallback onExportTemplate;
  final VoidCallback onDeleteTemplate;
  final ValueChanged<String> onTemplateSelected;
  final VoidCallback onTemplateSettingsPressed;
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
  final VoidCallback onShowElements;
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
  final ValueChanged<String> onCopyElement;
  final VoidCallback onPasteElement;
  final bool canPasteElement;
  final ValueChanged<bool>? onDragStateChanged;
  final Widget? borderPanel;

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isIOS || Platform.isAndroid;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final isCompact =
        MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    final selected = selectedElement;

    final properties = _TemplatePropertiesStrip(
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
      onCopyElement: onCopyElement,
      onPasteElement: onPasteElement,
      canPasteElement: canPasteElement,
      borderPanel: borderPanel,
      isCompact: isCompact,
    );

    return Scaffold(
      appBar: _TemplateEditorAppBar(
        isCompact: isCompact,
        templateName: template.name,
        savedNames: savedNames,
        onTemplateSelected: onTemplateSelected,
        canDeleteSavedTemplate: canDeleteSavedTemplate,
        onCreateNewTemplate: onCreateNewTemplate,
        onSaveTemplate: onSaveTemplate,
        onSaveAsTemplate: onSaveAsTemplate,
        onImportTemplate: onImportTemplate,
        onExportTemplate: onExportTemplate,
        onDeleteTemplate: onDeleteTemplate,
        onTemplateSettingsPressed: onTemplateSettingsPressed,
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
              onTemplateSettingsPressed: onTemplateSettingsPressed,
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
              onShowElements: onShowElements,
              onUndo: onUndo,
              onRedo: onRedo,
              canUndo: canUndo,
              canRedo: canRedo,
            ),
            properties,
            Expanded(
              child: TemplateCanvasWorkspace(
                isDuplex: isDuplex,
                isPage1: isPage1,
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
                onPageChanged: onPageChanged,
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
                onCopySelectedElement: selected == null
                    ? null
                    : () => onCopyElement(selected),
                onPasteElement: canPasteElement ? onPasteElement : null,
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
    required this.isCompact,
    required this.templateName,
    required this.savedNames,
    required this.onTemplateSelected,
    required this.canDeleteSavedTemplate,
    required this.onCreateNewTemplate,
    required this.onSaveTemplate,
    required this.onSaveAsTemplate,
    required this.onImportTemplate,
    required this.onExportTemplate,
    required this.onDeleteTemplate,
    required this.onTemplateSettingsPressed,
  });

  final bool canDeleteSavedTemplate;
  final VoidCallback onCreateNewTemplate;
  final VoidCallback onSaveTemplate;
  final VoidCallback onSaveAsTemplate;
  final VoidCallback onImportTemplate;
  final VoidCallback onExportTemplate;
  final VoidCallback onDeleteTemplate;
  final VoidCallback onTemplateSettingsPressed;

  /// Phone width: the title becomes the template picker.
  final bool isCompact;
  final String templateName;
  final List<String> savedNames;
  final ValueChanged<String> onTemplateSelected;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isCompact
          ? _TemplateTitlePicker(
              templateName: templateName,
              savedNames: savedNames,
              onTemplateSelected: onTemplateSelected,
            )
          : const Text('Template Editor'),
      actions: [
        IconButton(
          onPressed: onCreateNewTemplate,
          icon: const Icon(Icons.add_circle_outline_rounded),
          tooltip: 'Create new template',
        ),
        AdaptiveMenuButton<_TemplateEditorAction>(
          tooltip: 'Template Options',
          itemBuilder: _items,
          onSelected: _onSelected,
        ),
      ],
    );
  }

  List<AdaptiveMenuItem<_TemplateEditorAction>> _items() => [
    const AdaptiveMenuItem(
      value: _TemplateEditorAction.create,
      icon: Icons.add_circle_outline_rounded,
      label: 'Create new',
    ),
    const AdaptiveMenuItem(
      value: _TemplateEditorAction.save,
      icon: Icons.save_outlined,
      label: 'Save',
      hasDividerBefore: true,
    ),
    const AdaptiveMenuItem(
      value: _TemplateEditorAction.saveAs,
      icon: Icons.save_as_outlined,
      label: 'Save as...',
    ),
    const AdaptiveMenuItem(
      value: _TemplateEditorAction.import,
      icon: Icons.file_download_outlined,
      label: 'Import',
      hasDividerBefore: true,
    ),
    const AdaptiveMenuItem(
      value: _TemplateEditorAction.export,
      icon: Icons.file_upload_outlined,
      label: 'Export',
    ),
    const AdaptiveMenuItem(
      value: _TemplateEditorAction.settings,
      icon: Icons.settings_outlined,
      label: 'Template settings',
      hasDividerBefore: true,
    ),
    if (canDeleteSavedTemplate)
      const AdaptiveMenuItem(
        value: _TemplateEditorAction.delete,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        isDestructive: true,
        hasDividerBefore: true,
      ),
  ];

  void _onSelected(_TemplateEditorAction action) {
    switch (action) {
      case _TemplateEditorAction.create:
        onCreateNewTemplate();
      case _TemplateEditorAction.save:
        onSaveTemplate();
      case _TemplateEditorAction.saveAs:
        onSaveAsTemplate();
      case _TemplateEditorAction.import:
        onImportTemplate();
      case _TemplateEditorAction.export:
        onExportTemplate();
      case _TemplateEditorAction.settings:
        onTemplateSettingsPressed();
      case _TemplateEditorAction.delete:
        onDeleteTemplate();
    }
  }
}

/// The template picker collapsed into the app bar title on phones. Tapping it
/// opens a sheet of saved templates.
class _TemplateTitlePicker extends StatelessWidget {
  const _TemplateTitlePicker({
    required this.templateName,
    required this.savedNames,
    required this.onTemplateSelected,
  });

  final String templateName;
  final List<String> savedNames;
  final ValueChanged<String> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Choose template',
      child: InkWell(
        borderRadius: BorderRadius.circular(NahpuRadius.sm),
        onTap: () => _choose(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  templateName.trim().isEmpty
                      ? 'Untitled template'
                      : templateName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _choose(BuildContext context) async {
    final name = await showTemplatePickerSheet(
      context: context,
      savedNames: savedNames,
      currentName: templateName,
    );
    if (name != null && name != templateName) onTemplateSelected(name);
  }
}

enum _TemplateEditorAction {
  create,
  save,
  saveAs,
  import,
  export,
  settings,
  delete,
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
    required this.onCopyElement,
    required this.onPasteElement,
    required this.canPasteElement,
    this.isCompact = false,
    this.borderPanel,
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
  final bool isBorderPanelOpen;
  final ValueChanged<String> onDuplicateElement;
  final ValueChanged<String> onCopyElement;
  final VoidCallback onPasteElement;
  final bool canPasteElement;

  /// Phone width: the panel scrolls within a capped height under the toolbar,
  /// so a tall panel never pushes the canvas off screen.
  final bool isCompact;
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
        onCopyElement: onCopyElement,
        onPasteElement: onPasteElement,
        canPasteElement: canPasteElement,
        onDismiss: onDismiss,
      );
    } else if (isBorderPanelOpen && borderPanel != null) {
      activeChild = borderPanel;
    }

    if (activeChild == null) {
      return const SizedBox(width: double.infinity, height: 0);
    }

    final content = AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xs),
        child: activeChild,
      ),
    );
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: isCompact
          ? ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: SingleChildScrollView(child: content),
            )
          : content,
    );
  }
}
