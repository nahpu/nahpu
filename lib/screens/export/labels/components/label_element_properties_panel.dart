import 'package:flutter/material.dart';
import 'package:nahpu/screens/export/labels/label_template_model.dart';
import 'package:nahpu/screens/export/labels/label_template_fonts.dart';
import 'package:nahpu/screens/export/labels/components/synced_font_size_field.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class LabelElementPropertiesPanel extends StatelessWidget {
  const LabelElementPropertiesPanel({
    super.key,
    required this.selectedElement,
    required this.page1,
    required this.template,
    required this.onUpdateCustomText,
    required this.onDeleteCustomText,
    required this.onUpdateCustomImage,
    required this.onDeleteCustomImage,
    required this.onUpdateCustomLine,
    required this.onDeleteCustomLine,
    required this.onUpdateCustomShape,
    required this.onDeleteCustomShape,
  });

  final String selectedElement;
  final bool page1;
  final LabelTemplate template;

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

  CustomTextElement? _findCustomText(bool p1, String id) {
    final page = p1 ? template.page1 : template.page2;
    for (final ct in page.customTexts) {
      if (ct.id == id) return ct;
    }
    return null;
  }

  CustomImageElement? _findCustomImage(bool p1, String id) {
    final page = p1 ? template.page1 : template.page2;
    for (final img in page.customImages) {
      if (img.id == id) return img;
    }
    return null;
  }

  CustomLineElement? _findCustomLine(bool p1, String id) {
    final page = p1 ? template.page1 : template.page2;
    for (final line in page.customLines) {
      if (line.id == id) return line;
    }
    return null;
  }

  CustomShapeElement? _findCustomShape(bool p1, String id) {
    final page = p1 ? template.page1 : template.page2;
    for (final shape in page.customShapes) {
      if (shape.id == id) return shape;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (selectedElement.startsWith('custom:')) {
      return _buildCustomTextPanel(context, selectedElement, inToolbar: true);
    } else if (selectedElement.startsWith('image:')) {
      return _buildImagePanel(context, selectedElement, inToolbar: true);
    } else if (selectedElement.startsWith('line:')) {
      return _buildLinePanel(context, selectedElement, inToolbar: true);
    } else if (selectedElement.startsWith('shape:')) {
      return _buildShapePanel(context, selectedElement, inToolbar: true);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPanelContainer(BuildContext context,
      {required Widget child, required bool inToolbar}) {
    final scheme = Theme.of(context).colorScheme;
    if (inToolbar) {
      return Material(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }
    return Material(
      elevation: 2,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }

  Widget _buildZIndexControls(BuildContext context, String sel) {
    void setZIndex(String sel, int delta) {
      final parts = sel.split(':');
      if (parts.length != 3) return;
      final type = parts[0];
      final p1 = parts[1] == '1';
      final id = parts[2];
      
      if (type == 'custom') {
        final el = _findCustomText(p1, id);
        if (el != null) onUpdateCustomText(p1, el.copyWith(zIndex: el.zIndex + delta));
      } else if (type == 'image') {
        final el = _findCustomImage(p1, id);
        if (el != null) onUpdateCustomImage(p1, el.copyWith(zIndex: el.zIndex + delta));
      } else if (type == 'line') {
        final el = _findCustomLine(p1, id);
        if (el != null) onUpdateCustomLine(p1, el.copyWith(zIndex: el.zIndex + delta));
      } else if (type == 'shape') {
        final el = _findCustomShape(p1, id);
        if (el != null) onUpdateCustomShape(p1, el.copyWith(zIndex: el.zIndex + delta));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_down, size: 20),
          tooltip: 'Send to back',
          onPressed: () => setZIndex(
              sel, -1), // Simplistic, could be improved to find min/max
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          tooltip: 'Send backward',
          onPressed: () => setZIndex(sel, -1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, size: 20),
          tooltip: 'Bring forward',
          onPressed: () => setZIndex(sel, 1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_up, size: 20),
          tooltip: 'Bring to front',
          onPressed: () => setZIndex(sel, 1),
        ),
      ],
    );
  }

  Widget _buildImagePanel(BuildContext context, String sel,
      {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete image',
      onPressed: () => onDeleteCustomImage(page1, id),
    );

    return _buildPanelContainer(
      context,
      inToolbar: inToolbar,
      child: Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildZIndexControls(context, sel),
            const Spacer(),
            deleteButton,
          ],
        ),
      ),
    );
  }

  Widget _buildLinePanel(BuildContext context, String sel,
      {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];
    final ln = _findCustomLine(page1, id);
    if (ln == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete line',
      onPressed: () => onDeleteCustomLine(page1, id),
    );

    final content = Padding(
      padding: inToolbar
          ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
          : const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildZIndexControls(context, sel),
          const SizedBox(width: 16),
          Text('Thickness', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          DropdownButton<double>(
            value: [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0]
                    .contains(ln.thicknessPt)
                ? ln.thicknessPt
                : 1.0,
            isDense: true,
            underline: const SizedBox.shrink(),
            items: [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0]
                .map((t) => DropdownMenuItem(value: t, child: Text('${t}pt')))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                onUpdateCustomLine(page1, ln.copyWith(thicknessPt: v));
              }
            },
          ),
          const SizedBox(width: 16),
          Text('Color', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              Color selectedColor = Color(ln.colorArgb);
              final picked = await ColorPicker(
                color: selectedColor,
                onColorChanged: (c) => selectedColor = c,
                heading: Text('Select color',
                    style: Theme.of(context).textTheme.titleSmall),
                subheading: Text('Select color shade',
                    style: Theme.of(context).textTheme.titleSmall),
                wheelSubheading: Text('Selected color and its shades',
                    style: Theme.of(context).textTheme.titleSmall),
                showColorName: true,
                showColorCode: false,
                copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  copyButton: true,
                  pasteButton: true,
                  longPressMenu: true,
                ),
                colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
                colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.both: false,
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: true,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: true,
                  ColorPickerType.wheel: true,
                },
              ).showPickerDialog(context);
              if (picked) {
                onUpdateCustomLine(
                    page1, ln.copyWith(colorArgb: selectedColor.toARGB32()));
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(ln.colorArgb),
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Spacer(),
          deleteButton,
        ],
      ),
    );

    return _buildPanelContainer(
      context,
      inToolbar: inToolbar,
      child: content,
    );
  }

  Widget _buildShapePanel(BuildContext context, String sel,
      {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];
    final sh = _findCustomShape(page1, id);
    if (sh == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete shape',
      onPressed: () => onDeleteCustomShape(page1, id),
    );

    final content = Padding(
      padding: inToolbar
          ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
          : const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildZIndexControls(context, sel),
          const SizedBox(width: 16),
          Text('Stroke', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          DropdownButton<double>(
            value: [0.0, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0]
                    .contains(sh.strokeThicknessPt)
                ? sh.strokeThicknessPt
                : 1.0,
            isDense: true,
            underline: const SizedBox.shrink(),
            items: [0.0, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0]
                .map((t) => DropdownMenuItem(value: t, child: Text('${t}pt')))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                onUpdateCustomShape(page1, sh.copyWith(strokeThicknessPt: v));
              }
            },
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              Color selectedColor = Color(sh.strokeColorArgb);
              final picked = await ColorPicker(
                color: selectedColor,
                onColorChanged: (c) => selectedColor = c,
                heading: Text('Select stroke color',
                    style: Theme.of(context).textTheme.titleSmall),
                subheading: Text('Select color shade',
                    style: Theme.of(context).textTheme.titleSmall),
                wheelSubheading: Text('Selected color and its shades',
                    style: Theme.of(context).textTheme.titleSmall),
                showColorName: true,
                showColorCode: false,
                copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  copyButton: true,
                  pasteButton: true,
                  longPressMenu: true,
                ),
                colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
                colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.both: false,
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: true,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: true,
                  ColorPickerType.wheel: true,
                },
              ).showPickerDialog(context);
              if (picked) {
                onUpdateCustomShape(page1,
                    sh.copyWith(strokeColorArgb: selectedColor.toARGB32()));
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(sh.strokeColorArgb),
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text('Fill', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              Color selectedColor = sh.fillColorArgb != null
                  ? Color(sh.fillColorArgb!)
                  : Colors.transparent;
              final picked = await ColorPicker(
                color: selectedColor,
                onColorChanged: (c) => selectedColor = c,
                enableShadesSelection: true,
                heading: Text('Select fill color',
                    style: Theme.of(context).textTheme.titleSmall),
                subheading: Text('Select color shade',
                    style: Theme.of(context).textTheme.titleSmall),
                wheelSubheading: Text('Selected color and its shades',
                    style: Theme.of(context).textTheme.titleSmall),
                showColorName: true,
                showColorCode: false,
                copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  copyButton: true,
                  pasteButton: true,
                  longPressMenu: true,
                ),
                colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
                colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.both: false,
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: true,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: true,
                  ColorPickerType.wheel: true,
                },
              ).showPickerDialog(context);
              if (picked) {
                onUpdateCustomShape(page1,
                    sh.copyWith(fillColorArgb: selectedColor.toARGB32()));
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: sh.fillColorArgb != null
                    ? Color(sh.fillColorArgb!)
                    : Colors.transparent,
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: sh.fillColorArgb == null
                  ? Icon(Icons.close, size: 16, color: scheme.onSurfaceVariant)
                  : null,
            ),
          ),
          const SizedBox(width: 4),
          if (sh.fillColorArgb != null)
            IconButton(
              icon: const Icon(Icons.format_color_reset, size: 20),
              tooltip: 'Clear fill',
              onPressed: () =>
                  onUpdateCustomShape(page1, sh.copyWith(clearFillColor: true)),
            ),
          const Spacer(),
          deleteButton,
        ],
      ),
    );

    return _buildPanelContainer(
      context,
      inToolbar: inToolbar,
      child: content,
    );
  }

  Widget _buildCustomTextPanel(BuildContext context, String sel,
      {bool inToolbar = false}) {
    final parts = sel.split(':');
    if (parts.length != 3) return const SizedBox.shrink();
    final page1 = parts[1] == '1';
    final id = parts[2];
    final ct = _findCustomText(page1, id);
    if (ct == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete text box',
      onPressed: () => onDeleteCustomText(page1, id),
    );

    if (isLabelBracketGenderIconText(ct.text)) {
      final content = Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildZIndexControls(context, sel),
            const Spacer(),
            deleteButton
          ],
        ),
      );
      return _buildPanelContainer(context,
          inToolbar: inToolbar, child: content);
    }

    final fontKey = normalizeLabelFontFamily(ct.fontFamily);
    final fontDropdownIds = List<String>.from(kLabelFontDropdownKeys);
    if (fontKey.isNotEmpty && !fontDropdownIds.contains(fontKey)) {
      fontDropdownIds.add(fontKey);
    }
    final content = Padding(
      padding: inToolbar
          ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
          : const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Font', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: fontKey,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final k in fontDropdownIds)
                        DropdownMenuItem<String>(
                          value: k,
                          child: Text(labelFontDropdownLabel(k)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      onUpdateCustomText(page1, ct.copyWith(fontFamily: v));
                    },
                  ),
                  const SizedBox(width: 12),
                  Text('Size (pt)',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: SyncedFontSizeField(
                      key: ValueKey('fs_$id'),
                      fontSizePt: ct.fontSizePt,
                      onValidSize: (p) => onUpdateCustomText(
                        page1,
                        ct.copyWith(fontSizePt: p),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    tooltip: 'Decrease font size',
                    onPressed: ct.fontSizePt > 4
                        ? () => onUpdateCustomText(
                              page1,
                              ct.copyWith(
                                  fontSizePt:
                                      (ct.fontSizePt - 0.5).clamp(4.0, 72.0)),
                            )
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    tooltip: 'Increase font size',
                    onPressed: ct.fontSizePt < 72
                        ? () => onUpdateCustomText(
                              page1,
                              ct.copyWith(
                                  fontSizePt:
                                      (ct.fontSizePt + 0.5).clamp(4.0, 72.0)),
                            )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(width: 12),
                  Text('Max Width (mm)',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: Slider(
                      value: ct.maxWidthMm ?? 0.0,
                      min: 0.0,
                      max: 200.0,
                      divisions: 40,
                      label: ct.maxWidthMm == null || ct.maxWidthMm! == 0.0
                          ? 'Auto'
                          : '${ct.maxWidthMm!.toStringAsFixed(1)} mm',
                      onChanged: (v) {
                        onUpdateCustomText(page1,
                            ct.copyWith(maxWidthMm: v == 0.0 ? null : v));
                      },
                    ),
                  ),
                  FilterChip(
                    label: const Text('Bold'),
                    selected: ct.bold,
                    onSelected: (v) =>
                        onUpdateCustomText(page1, ct.copyWith(bold: v)),
                  ),
                  const SizedBox(width: 6),
                  const SizedBox(width: 12),
                  Text('Max Width (mm)',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: Slider(
                      value: ct.maxWidthMm ?? 0.0,
                      min: 0.0,
                      max: 200.0,
                      divisions: 40,
                      label: ct.maxWidthMm == null || ct.maxWidthMm! == 0.0
                          ? 'Auto'
                          : '${ct.maxWidthMm!.toStringAsFixed(1)} mm',
                      onChanged: (v) {
                        onUpdateCustomText(page1,
                            ct.copyWith(maxWidthMm: v == 0.0 ? null : v));
                      },
                    ),
                  ),
                  FilterChip(
                    label: const Text('Italic'),
                    selected: ct.italic,
                    onSelected: (v) =>
                        onUpdateCustomText(page1, ct.copyWith(italic: v)),
                  ),
                  const SizedBox(width: 12),
                  Text('Rotation',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('0°')),
                      ButtonSegment(value: 90, label: Text('90°')),
                      ButtonSegment(value: -90, label: Text('-90°')),
                      ButtonSegment(value: 180, label: Text('180°')),
                    ],
                    selected: {ct.rotationDegrees},
                    onSelectionChanged: (next) {
                      if (next.isEmpty) return;
                      onUpdateCustomText(
                        page1,
                        ct.copyWith(rotationDegrees: next.first),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          deleteButton,
        ],
      ),
    );

    if (inToolbar) {
      return Material(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return Material(
      elevation: 2,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: content,
      ),
    );
  }
}
