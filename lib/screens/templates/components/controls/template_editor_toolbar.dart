import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/controls/mirror_toggle_button.dart';
import 'package:nahpu/screens/templates/template_size_selector.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Command bar for template editing actions and canvas-level view toggles.
///
/// The toolbar intentionally exposes canvas view state such as grid, snapping,
/// and movement lock beside editing commands so keyboard shortcuts and visible
/// buttons stay aligned. On phones the template picker moves into the app bar
/// and the tools are grouped, so the canvas keeps as much height as possible.
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
    required this.onShowElements,
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

  /// Opens the list of elements on the current side.
  final VoidCallback onShowElements;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCompact =
        MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: isCompact
            ? const EdgeInsets.fromLTRB(
                NahpuSpacing.md,
                NahpuSpacing.sm,
                NahpuSpacing.xs,
                NahpuSpacing.xs,
              )
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCompact) ...[
              Row(children: [Expanded(child: _TemplatePicker(this))]),
              const SizedBox(height: 8),
            ],
            if (isCompact)
              _CompactToolRows(toolbar: this)
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12),
                    Text(
                      'Template size:',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: scheme.onSurface),
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
                      sideLabel: isDuplex
                          ? (isPage1 ? 'Front' : 'Back')
                          : 'Front',
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
                      tooltip: 'Elements',
                      onPressed: onShowElements,
                      icon: Icons.layers_outlined,
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

/// Tool groups shown one at a time on phone-width screens.
enum _TemplateToolGroup {
  add('Add'),
  page('Page'),
  view('View'),
  template('Template');

  const _TemplateToolGroup(this.label);

  final String label;
}

/// Phone-width tools: pick a group, and its few tools fit on screen without
/// scrolling sideways. Elements, undo, and redo stay beside whichever group is
/// open.
class _CompactToolRows extends StatefulWidget {
  const _CompactToolRows({required this.toolbar});

  final TemplateEditorToolbar toolbar;

  @override
  State<_CompactToolRows> createState() => _CompactToolRowsState();
}

class _CompactToolRowsState extends State<_CompactToolRows> {
  _TemplateToolGroup _group = _TemplateToolGroup.add;

  @override
  Widget build(BuildContext context) {
    final toolbar = widget.toolbar;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_TemplateToolGroup>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: [
            for (final group in _TemplateToolGroup.values)
              ButtonSegment(value: group, label: Text(group.label)),
          ],
          selected: {_group},
          onSelectionChanged: (selection) {
            setState(() => _group = selection.single);
          },
        ),
        const SizedBox(height: NahpuSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: NahpuSpacing.sm,
                runSpacing: NahpuSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: switch (_group) {
                  _TemplateToolGroup.add => [
                    _ToolbarIconButton(
                      icon: Icons.text_fields,
                      tooltip: 'Add text',
                      onPressed: toolbar.onAddText,
                    ),
                    _ToolbarIconButton(
                      icon: Icons.image_outlined,
                      tooltip: 'Add image',
                      onPressed: toolbar.onAddImage,
                    ),
                    _ToolbarIconButton(
                      icon: Icons.horizontal_rule,
                      tooltip: 'Add line',
                      onPressed: toolbar.onAddLine,
                    ),
                    _ToolbarIconButton(
                      icon: Icons.crop_square,
                      tooltip: 'Add shape',
                      onPressed: toolbar.onAddShape,
                    ),
                  ],
                  _TemplateToolGroup.page => [
                    TemplateSizeSelector(
                      compact: true,
                      controlledWidthMm: toolbar.templateWidthMm,
                      controlledHeightMm: toolbar.templateHeightMm,
                      onControlledDimensionsApplied:
                          toolbar.onTemplateSizeChanged,
                    ),
                    MirrorToggleButton(
                      isMirrorActive: toolbar.isPage1
                          ? toolbar.mirrorFront
                          : toolbar.mirrorBack,
                      sideLabel: toolbar.isDuplex
                          ? (toolbar.isPage1 ? 'Front' : 'Back')
                          : 'Front',
                      onToggle: toolbar.onMirrorToggled,
                    ),
                    _TemplateEditorIconButton(
                      isActive: toolbar.isBorderPanelOpen,
                      tooltip: 'Template border',
                      onPressed: toolbar.onBorderPanelToggled,
                      icon: Icons.border_outer,
                    ),
                  ],
                  _TemplateToolGroup.view => [
                    _TemplateEditorIconButton(
                      tooltip: toolbar.showGrid ? 'Hide grid' : 'Show grid',
                      onPressed: toolbar.onGridToggled,
                      icon: toolbar.showGrid ? Icons.grid_on : Icons.grid_off,
                    ),
                    _TemplateEditorIconButton(
                      isActive: toolbar.snapEnabled,
                      tooltip: toolbar.snapEnabled
                          ? 'Disable snap'
                          : 'Enable snap',
                      onPressed: toolbar.onSnapToggled,
                      icon: toolbar.snapEnabled
                          ? Icons.center_focus_strong
                          : Icons.center_focus_weak,
                    ),
                    _TemplateEditorIconButton(
                      isActive: toolbar.canvasMovementLocked,
                      tooltip: toolbar.canvasMovementLocked
                          ? 'Unlock canvas movement'
                          : 'Lock canvas movement',
                      onPressed: toolbar.onCanvasMovementLockToggled,
                      icon: toolbar.canvasMovementLocked
                          ? Icons.lock_outline
                          : Icons.lock_open_outlined,
                    ),
                    if (toolbar.template.recordType != RecordType.none)
                      _TemplateEditorIconButton(
                        tooltip: 'Select specimen for text preview',
                        onPressed: toolbar.onSelectPreviewSpecimen,
                        icon: Icons.manage_search,
                      ),
                  ],
                  _TemplateToolGroup.template => [
                    _ToolbarIconButton(
                      tooltip: 'Save template',
                      icon: Icons.save_outlined,
                      onPressed: toolbar.onSaveTemplate,
                    ),
                    _TemplateEditorIconButton(
                      tooltip: 'Template settings',
                      onPressed: toolbar.onTemplateSettingsPressed,
                      icon: Icons.settings_outlined,
                    ),
                  ],
                },
              ),
            ),
            _TemplateEditorIconButton(
              tooltip: 'Elements',
              onPressed: toolbar.onShowElements,
              icon: Icons.layers_outlined,
            ),
            _TemplateEditorIconButton(
              tooltip: 'Undo',
              icon: Icons.undo,
              onPressed: toolbar.canUndo ? toolbar.onUndo : null,
            ),
            _TemplateEditorIconButton(
              tooltip: 'Redo',
              icon: Icons.redo,
              onPressed: toolbar.canRedo ? toolbar.onRedo : null,
            ),
          ],
        ),
      ],
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
        backgroundColor: isActive
            ? scheme.primaryContainer.withValues(alpha: 0.45)
            : null,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
    );
  }
}
