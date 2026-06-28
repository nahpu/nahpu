import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/labels/label_template_model.dart';
import 'package:nahpu/screens/exports/labels/label_template_fonts.dart';
import 'package:nahpu/screens/exports/labels/components/synced_font_size_field.dart';
import 'package:nahpu/screens/exports/labels/components/synced_max_width_field.dart';
import 'package:nahpu/screens/exports/labels/components/synced_dim_field.dart';
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
    this.onDismiss,
  });

  final String selectedElement;
  final bool page1;
  final LabelTemplate template;
  final VoidCallback? onDismiss;

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

    final wrappedChild = Row(
      children: [
        Expanded(child: child),
        if (onDismiss != null) ...[
          SizedBox(
            height: 32,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outlineVariant,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Dismiss toolbar',
            onPressed: onDismiss,
          ),
          const SizedBox(width: 4),
        ],
      ],
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
        child: wrappedChild,
      );
    }
    return Material(
      elevation: 2,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: wrappedChild,
      ),
    );
  }

  Widget _buildOptionSlider(
    BuildContext context, {
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.12),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: TextStyle(color: scheme.onPrimary),
        valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
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
        if (el != null) {
          onUpdateCustomText(p1, el.copyWith(zIndex: el.zIndex + delta));
        }
      } else if (type == 'image') {
        final el = _findCustomImage(p1, id);
        if (el != null) {
          onUpdateCustomImage(p1, el.copyWith(zIndex: el.zIndex + delta));
        }
      } else if (type == 'line') {
        final el = _findCustomLine(p1, id);
        if (el != null) {
          onUpdateCustomLine(p1, el.copyWith(zIndex: el.zIndex + delta));
        }
      } else if (type == 'shape') {
        final el = _findCustomShape(p1, id);
        if (el != null) {
          onUpdateCustomShape(p1, el.copyWith(zIndex: el.zIndex + delta));
        }
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildZIndexControls(context, sel),
                  const SizedBox(width: 16),
                  Text('Thickness',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  DropdownButton<double>(
                    value: [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0]
                            .contains(ln.thicknessPt)
                        ? ln.thicknessPt
                        : 1.0,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0]
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text('${t}pt')))
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
                        colorNameTextStyle:
                            Theme.of(context).textTheme.bodySmall,
                        colorCodeTextStyle:
                            Theme.of(context).textTheme.bodySmall,
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
                        onUpdateCustomLine(page1,
                            ln.copyWith(colorArgb: selectedColor.toARGB32()));
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
                  const SizedBox(width: 16),
                  Text('Length (mm)',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: SyncedDimField(
                      key: ValueKey('line_len_$id'),
                      value: ln.lengthMm,
                      min: 2.0,
                      max: 200.0,
                      onValidValue: (p) => onUpdateCustomLine(
                        page1,
                        ln.copyWith(lengthMm: p),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: _buildOptionSlider(
                      context,
                      value: ln.lengthMm.clamp(2.0, 200.0),
                      min: 2.0,
                      max: 200.0,
                      divisions: 198,
                      label: '${ln.lengthMm.toStringAsFixed(1)} mm',
                      onChanged: (v) {
                        onUpdateCustomLine(page1, ln.copyWith(lengthMm: v));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
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
                    selected: {ln.rotationDegrees},
                    onSelectionChanged: (next) {
                      if (next.isEmpty) return;
                      onUpdateCustomLine(
                        page1,
                        ln.copyWith(rotationDegrees: next.first),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildZIndexControls(context, sel),
                  const SizedBox(width: 16),
                  Text('Stroke',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  DropdownButton<double>(
                    value: [0.0, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0]
                            .contains(sh.strokeThicknessPt)
                        ? sh.strokeThicknessPt
                        : 1.0,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [0.0, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0]
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text('${t}pt')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        onUpdateCustomShape(
                            page1, sh.copyWith(strokeThicknessPt: v));
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
                        colorNameTextStyle:
                            Theme.of(context).textTheme.bodySmall,
                        colorCodeTextStyle:
                            Theme.of(context).textTheme.bodySmall,
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
                        onUpdateCustomShape(
                            page1,
                            sh.copyWith(
                                strokeColorArgb: selectedColor.toARGB32()));
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
                          : Colors.white;
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
                        colorNameTextStyle:
                            Theme.of(context).textTheme.bodySmall,
                        colorCodeTextStyle:
                            Theme.of(context).textTheme.bodySmall,
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
                        onUpdateCustomShape(
                            page1,
                            sh.copyWith(
                                fillColorArgb: selectedColor.toARGB32()));
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
                          ? Icon(Icons.close,
                              size: 16, color: scheme.onSurfaceVariant)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (sh.fillColorArgb != null)
                    IconButton(
                      icon: const Icon(Icons.format_color_reset, size: 20),
                      tooltip: 'Clear fill',
                      onPressed: () => onUpdateCustomShape(
                          page1, sh.copyWith(clearFillColor: true)),
                    ),
                  const SizedBox(width: 16),
                  Text('Width (mm)',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: SyncedDimField(
                      key: ValueKey('shape_w_$id'),
                      value: sh.widthMm,
                      min: 2.0,
                      max: 200.0,
                      onValidValue: (p) => onUpdateCustomShape(
                        page1,
                        sh.copyWith(widthMm: p),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: _buildOptionSlider(
                      context,
                      value: sh.widthMm.clamp(2.0, 200.0),
                      min: 2.0,
                      max: 200.0,
                      divisions: 198,
                      label: '${sh.widthMm.toStringAsFixed(1)} mm',
                      onChanged: (v) {
                        onUpdateCustomShape(page1, sh.copyWith(widthMm: v));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Height (mm)',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: SyncedDimField(
                      key: ValueKey('shape_h_$id'),
                      value: sh.heightMm,
                      min: 2.0,
                      max: 200.0,
                      onValidValue: (p) => onUpdateCustomShape(
                        page1,
                        sh.copyWith(heightMm: p),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: _buildOptionSlider(
                      context,
                      value: sh.heightMm.clamp(2.0, 200.0),
                      min: 2.0,
                      max: 200.0,
                      divisions: 198,
                      label: '${sh.heightMm.toStringAsFixed(1)} mm',
                      onChanged: (v) {
                        onUpdateCustomShape(page1, sh.copyWith(heightMm: v));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
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
                    selected: {sh.rotationDegrees},
                    onSelectionChanged: (next) {
                      if (next.isEmpty) return;
                      onUpdateCustomShape(
                        page1,
                        sh.copyWith(rotationDegrees: next.first),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
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

    final content = _CustomTextToolbar(
      ct: ct,
      page1: page1,
      inToolbar: inToolbar,
      onUpdateCustomText: onUpdateCustomText,
      zIndexControls: _buildZIndexControls(context, sel),
      deleteButton: deleteButton,
      buildOptionSlider: _buildOptionSlider,
    );

    return _buildPanelContainer(
      context,
      inToolbar: inToolbar,
      child: content,
    );
  }
}

class _CustomTextToolbar extends StatefulWidget {
  const _CustomTextToolbar({
    required this.ct,
    required this.page1,
    required this.inToolbar,
    required this.onUpdateCustomText,
    required this.zIndexControls,
    required this.deleteButton,
    required this.buildOptionSlider,
  });

  final CustomTextElement ct;
  final bool page1;
  final bool inToolbar;
  final void Function(bool page1, CustomTextElement element) onUpdateCustomText;
  final Widget zIndexControls;
  final Widget deleteButton;
  final Widget Function(
    BuildContext, {
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) buildOptionSlider;

  @override
  State<_CustomTextToolbar> createState() => _CustomTextToolbarState();
}

class _CustomTextToolbarState extends State<_CustomTextToolbar> {
  bool _showFormattingRow = false;

  @override
  Widget build(BuildContext context) {
    final ct = widget.ct;
    final page1 = widget.page1;
    final inToolbar = widget.inToolbar;
    final onUpdateCustomText = widget.onUpdateCustomText;
    final scheme = Theme.of(context).colorScheme;

    final fontKey = normalizeLabelFontFamily(ct.fontFamily);
    final fontDropdownIds = List<String>.from(kLabelFontDropdownKeys);
    if (fontKey.isNotEmpty && !fontDropdownIds.contains(fontKey)) {
      fontDropdownIds.add(fontKey);
    }

    final row1 = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          widget.zIndexControls,
          const SizedBox(width: 12),
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
          Text('Size (pt)', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: SyncedFontSizeField(
              key: ValueKey('fs_${ct.id}'),
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
                          fontSizePt: (ct.fontSizePt - 0.5).clamp(4.0, 72.0)),
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
                          fontSizePt: (ct.fontSizePt + 0.5).clamp(4.0, 72.0)),
                    )
                : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.text_format, size: 24),
            isSelected: _showFormattingRow,
            tooltip: 'Text formatting options',
            onPressed: () {
              setState(() {
                _showFormattingRow = !_showFormattingRow;
              });
            },
          ),
          const SizedBox(width: 12),
          Text('Color', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              Color selectedColor = Color(ct.colorArgb);
              final picked = await ColorPicker(
                color: selectedColor,
                onColorChanged: (c) => selectedColor = c,
                heading: Text('Select text color',
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
                onUpdateCustomText(
                    page1, ct.copyWith(colorArgb: selectedColor.toARGB32()));
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(ct.colorArgb),
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Max Width (mm)',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: SyncedMaxWidthField(
              key: ValueKey('mw_${ct.id}'),
              maxWidthMm: ct.maxWidthMm,
              onValidSize: (p) => onUpdateCustomText(
                page1,
                ct.copyWith(maxWidthMm: p),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: widget.buildOptionSlider(
              context,
              value: ct.maxWidthMm ?? 0.0,
              min: 0.0,
              max: 200.0,
              divisions: 40,
              label: ct.maxWidthMm == null || ct.maxWidthMm! == 0.0
                  ? 'Auto'
                  : '${ct.maxWidthMm!.toStringAsFixed(1)} mm',
              onChanged: (v) {
                onUpdateCustomText(
                    page1, ct.copyWith(maxWidthMm: v == 0.0 ? null : v));
              },
            ),
          ),
          const SizedBox(width: 12),
          Text('Rotation', style: Theme.of(context).textTheme.labelMedium),
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
    );

    return Padding(
      padding: inToolbar
          ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
          : const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                row1,
                if (_showFormattingRow) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'left',
                              icon: Icon(Icons.format_align_left, size: 20),
                              tooltip: 'Align left',
                            ),
                            ButtonSegment(
                              value: 'center',
                              icon: Icon(Icons.format_align_center, size: 20),
                              tooltip: 'Align center',
                            ),
                            ButtonSegment(
                              value: 'right',
                              icon: Icon(Icons.format_align_right, size: 20),
                              tooltip: 'Align right',
                            ),
                          ],
                          selected: {ct.textAlign},
                          onSelectionChanged: (next) {
                            if (next.isEmpty) return;
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(textAlign: next.first),
                            );
                          },
                          showSelectedIcon: false,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          isSelected: ct.bold,
                          icon: const Icon(Icons.format_bold, size: 20),
                          selectedIcon: Icon(Icons.format_bold,
                              color: scheme.primary, size: 20),
                          onPressed: () => onUpdateCustomText(
                            page1,
                            ct.copyWith(bold: !ct.bold),
                          ),
                          tooltip: 'Bold',
                        ),
                        IconButton(
                          isSelected: ct.italic,
                          icon: const Icon(Icons.format_italic, size: 20),
                          selectedIcon: Icon(Icons.format_italic,
                              color: scheme.primary, size: 20),
                          onPressed: () => onUpdateCustomText(
                            page1,
                            ct.copyWith(italic: !ct.italic),
                          ),
                          tooltip: 'Italic',
                        ),
                        const SizedBox(width: 12),
                        Text('Case',
                            style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: ct.caseFormat,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                                value: 'normal', child: Text('Normal')),
                            DropdownMenuItem(
                                value: 'uppercase', child: Text('Uppercase')),
                            DropdownMenuItem(
                                value: 'lowercase', child: Text('Lowercase')),
                            DropdownMenuItem(
                                value: 'capitalize', child: Text('Capitalize')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            onUpdateCustomText(
                              page1,
                              ct.copyWith(caseFormat: v),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          widget.deleteButton,
        ],
      ),
    );
  }
}
