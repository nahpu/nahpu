import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/components/controls/front_back_page_pickers.dart';
import 'package:nahpu/screens/templates/components/controls/mirror_toggle_button.dart';
import 'package:nahpu/screens/templates/template_size_selector.dart';

class TemplateEditorToolbar extends StatelessWidget {
  const TemplateEditorToolbar({
    super.key,
    required this.savedNames,
    required this.currentTemplateName,
    required this.isDuplex,
    required this.isPage1,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.templateWidthMm,
    required this.templateHeightMm,
    required this.isBorderPanelOpen,
    required this.showGrid,
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
  });

  final List<String> savedNames;
  final String currentTemplateName;
  final bool isDuplex;
  final bool isPage1;
  final bool mirrorFront;
  final bool mirrorBack;
  final double templateWidthMm;
  final double templateHeightMm;
  final bool isBorderPanelOpen;
  final bool showGrid;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _TemplatePicker(this)),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('1 sided')),
                    ButtonSegment(value: true, label: Text('2 sided')),
                  ],
                  selected: {isDuplex},
                  onSelectionChanged: (values) => onDuplexChanged(values.first),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FrontBackPagePickers(
                    isDuplex: isDuplex,
                    isPage1: isPage1,
                    mirrorFront: mirrorFront,
                    mirrorBack: mirrorBack,
                    onPageChanged: onPageChanged,
                  ),
                  if (isDuplex) const SizedBox(width: 8),
                  if (isDuplex) ...[
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 4,
                      endIndent: 4,
                      color: scheme.outlineVariant,
                    ),
                    const SizedBox(width: 12),
                  ],
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
                  const SizedBox(width: 16),
                  IconButton(
                    tooltip: 'Template border',
                    style: IconButton.styleFrom(
                      foregroundColor: isBorderPanelOpen
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      backgroundColor: isBorderPanelOpen
                          ? scheme.primaryContainer.withValues(alpha: 0.45)
                          : null,
                    ),
                    onPressed: onBorderPanelToggled,
                    icon: const Icon(Icons.border_outer, size: 22),
                  ),
                  IconButton(
                    tooltip: showGrid ? 'Hide grid' : 'Show grid',
                    style: IconButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                    ),
                    onPressed: onGridToggled,
                    icon: Icon(
                      showGrid ? Icons.grid_on : Icons.grid_off,
                      size: 22,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Select specimen for text preview',
                    style: IconButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                    ),
                    onPressed: onSelectPreviewSpecimen,
                    icon: const Icon(Icons.manage_search, size: 22),
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
      initialSelection: toolbar.savedNames.contains(toolbar.currentTemplateName)
          ? toolbar.currentTemplateName
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
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
    );
  }
}
