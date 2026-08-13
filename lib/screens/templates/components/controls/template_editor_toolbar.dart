import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/controls/mirror_toggle_button.dart';
import 'package:nahpu/screens/templates/template_size_selector.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/types/export.dart';

/// Command bar for template editing actions and canvas-level view toggles.
///
/// The toolbar intentionally exposes canvas view state such as grid, snapping,
/// and movement lock beside editing commands so keyboard shortcuts and visible
/// buttons stay aligned.
class TemplateEditorToolbar extends StatelessWidget {
  const TemplateEditorToolbar({
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
    required this.onSaveTemplate,
    required this.onTemplateSelected,
    required this.onTemplateSettingsPressed,
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
    this.onUndo,
    this.onRedo,
    this.canUndo = false,
    this.canRedo = false,
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
  final VoidCallback onSaveTemplate;
  final ValueChanged<String> onTemplateSelected;
  final VoidCallback onTemplateSettingsPressed;
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
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(color: scheme.secondary.withAlpha(50)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _TemplatePicker(this)),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  Text(
                    'Template size:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onSurface,
                        ),
                  ),
                  const SizedBox(width: 4),
                  TemplateSizeSelector(
                    compact: true,
                    controlledWidthMm: templateWidthMm,
                    controlledHeightMm: templateHeightMm,
                    onControlledDimensionsApplied: onTemplateSizeChanged,
                  ),
                  const SizedBox(width: 8),
                  _ToolbarIconButton(
                    icon: Icons.text_fields,
                    tooltip: 'Add text',
                    onPressed: onAddText,
                  ),
                  const SizedBox(width: 4),
                  _ToolbarIconButton(
                    icon: Icons.image_outlined,
                    tooltip: 'Add image',
                    onPressed: onAddImage,
                  ),
                  const SizedBox(width: 4),
                  _ToolbarIconButton(
                    icon: Icons.horizontal_rule,
                    tooltip: 'Add line',
                    onPressed: onAddLine,
                  ),
                  const SizedBox(width: 4),
                  _ToolbarIconButton(
                    icon: Icons.crop_square,
                    tooltip: 'Add shape',
                    onPressed: onAddShape,
                  ),
                  const SizedBox(width: 16),
                  MirrorToggleButton(
                    isMirrorActive: isPage1 ? mirrorFront : mirrorBack,
                    sideLabel:
                        isDuplex ? (isPage1 ? 'Front' : 'Back') : 'Front',
                    onToggle: onMirrorToggled,
                  ),
                  const SizedBox(width: 8),
                  _ToolbarIconButton(
                    tooltip: 'Save template',
                    icon: Icons.save_outlined,
                    onPressed: onSaveTemplate,
                  ),
                  const SizedBox(width: 12),
                  _ToolbarIconButton(
                    tooltip: 'Undo',
                    icon: Icons.undo,
                    onPressed: canUndo ? onUndo : null,
                  ),
                  const SizedBox(width: 4),
                  _ToolbarIconButton(
                    tooltip: 'Redo',
                    icon: Icons.redo,
                    onPressed: canRedo ? onRedo : null,
                  ),
                  const SizedBox(width: 12),
                  _TemplateEditorIconButton(
                    isActive: isBorderPanelOpen,
                    tooltip: 'Template border',
                    onPressed: onBorderPanelToggled,
                    icon: Icons.border_outer,
                  ),
                  _TemplateEditorIconButton(
                    tooltip: showGrid ? 'Hide grid' : 'Show grid',
                    onPressed: onGridToggled,
                    icon: showGrid ? Icons.grid_on : Icons.grid_off,
                  ),
                  _TemplateEditorIconButton(
                    isActive: snapEnabled,
                    tooltip: snapEnabled ? 'Disable snap' : 'Enable snap',
                    onPressed: onSnapToggled,
                    icon: snapEnabled
                        ? Icons.center_focus_strong
                        : Icons.center_focus_weak,
                  ),
                  _TemplateEditorIconButton(
                    isActive: canvasMovementLocked,
                    tooltip: canvasMovementLocked
                        ? 'Unlock canvas movement'
                        : 'Lock canvas movement',
                    onPressed: onCanvasMovementLockToggled,
                    icon: canvasMovementLocked
                        ? Icons.lock_outline
                        : Icons.lock_open_outlined,
                  ),
                  if (template.recordType != RecordType.none)
                    _TemplateEditorIconButton(
                      tooltip: 'Select specimen for text preview',
                      onPressed: onSelectPreviewSpecimen,
                      icon: Icons.manage_search,
                    ),
                  const SizedBox(width: 8),
                  _TemplateEditorIconButton(
                    tooltip: 'Template settings',
                    onPressed: onTemplateSettingsPressed,
                    icon: Icons.settings_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker(this.toolbar);

  final TemplateEditorToolbar toolbar;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: toolbar.savedNames.contains(toolbar.template.name)
          ? toolbar.template.name
          : null,
      label: const Text('Preset template'),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(),
      ),
      dropdownMenuEntries: [
        for (final name in toolbar.savedNames)
          DropdownMenuEntry(value: name, label: name),
      ],
      onSelected: (value) {
        if (value != null) toolbar.onTemplateSelected(value);
      },
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
    );
  }
}

/// Shared icon-button styling for template-editor tools and toggles.
class _TemplateEditorIconButton extends StatelessWidget {
  const _TemplateEditorIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        foregroundColor: isActive ? scheme.primary : scheme.onSurfaceVariant,
        backgroundColor:
            isActive ? scheme.primaryContainer.withValues(alpha: 0.45) : null,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
    );
  }
}
