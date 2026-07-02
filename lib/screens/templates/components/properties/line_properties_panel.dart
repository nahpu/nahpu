import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/components/properties/property_panel_shell.dart';
import 'package:nahpu/screens/templates/components/properties/synced_dim_field.dart';
import 'package:nahpu/screens/templates/template_model.dart';

class LinePropertiesPanel extends StatelessWidget {
  const LinePropertiesPanel({
    super.key,
    required this.page1,
    required this.id,
    required this.line,
    required this.zIndexControls,
    required this.onUpdate,
    required this.onDelete,
    required this.inToolbar,
    this.onDismiss,
  });

  final bool page1;
  final String id;
  final CustomLineElement line;
  final Widget zIndexControls;
  final void Function(bool page1, CustomLineElement element) onUpdate;
  final void Function(bool page1, String id) onDelete;
  final bool inToolbar;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TemplatePropertyPanelShell(
      inToolbar: inToolbar,
      onDismiss: onDismiss,
      child: Padding(
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
                    zIndexControls,
                    const SizedBox(width: 16),
                    Text(
                      'Thickness',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 8),
                    _ThicknessPicker(
                      value: line.thicknessPt,
                      onChanged: (v) =>
                          onUpdate(page1, line.copyWith(thicknessPt: v)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Color',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 8),
                    _ColorSwatch(
                      color: Color(line.colorArgb),
                      borderColor: scheme.outline,
                      title: 'Select color',
                      onPicked: (color) => onUpdate(
                        page1,
                        line.copyWith(colorArgb: color.toARGB32()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Length (mm)',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 64,
                      child: SyncedDimField(
                        key: ValueKey('line_len_$id'),
                        value: line.lengthMm,
                        min: 2.0,
                        max: 200.0,
                        onValidValue: (p) =>
                            onUpdate(page1, line.copyWith(lengthMm: p)),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TemplateOptionSlider(
                        value: line.lengthMm.clamp(2.0, 200.0),
                        min: 2.0,
                        max: 200.0,
                        divisions: 198,
                        label: '${line.lengthMm.toStringAsFixed(1)} mm',
                        onChanged: (v) =>
                            onUpdate(page1, line.copyWith(lengthMm: v)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Rotation',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 8),
                    _RotationPicker(
                      value: line.rotationDegrees,
                      onChanged: (v) => onUpdate(
                        page1,
                        line.copyWith(rotationDegrees: v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
              tooltip: 'Delete line',
              onPressed: () => onDelete(page1, id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThicknessPicker extends StatelessWidget {
  const _ThicknessPicker({
    required this.value,
    required this.onChanged,
  });

  static const values = [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0];

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<double>(
      value: values.contains(value) ? value : 1.0,
      isDense: true,
      underline: const SizedBox.shrink(),
      items: values
          .map((thickness) => DropdownMenuItem(
                value: thickness,
                child: Text('${thickness}pt'),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _RotationPicker extends StatelessWidget {
  const _RotationPicker({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('0°')),
        ButtonSegment(value: 90, label: Text('90°')),
        ButtonSegment(value: -90, label: Text('-90°')),
        ButtonSegment(value: 180, label: Text('180°')),
      ],
      selected: {value},
      onSelectionChanged: (next) {
        if (next.isNotEmpty) onChanged(next.first);
      },
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.borderColor,
    required this.title,
    required this.onPicked,
  });

  final Color color;
  final Color borderColor;
  final String title;
  final ValueChanged<Color> onPicked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var selectedColor = color;
        final picked = await ColorPicker(
          color: selectedColor,
          onColorChanged: (c) => selectedColor = c,
          heading: Text(title, style: Theme.of(context).textTheme.titleSmall),
          subheading: Text(
            'Select color shade',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          wheelSubheading: Text(
            'Selected color and its shades',
            style: Theme.of(context).textTheme.titleSmall,
          ),
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
        if (picked) onPicked(selectedColor);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
