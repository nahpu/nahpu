import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/components/properties/property_panel_shell.dart';
import 'package:nahpu/screens/templates/components/properties/synced_dim_field.dart';
import 'package:nahpu/screens/templates/template_model.dart';

class LinePropertiesPanel extends StatefulWidget {
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
  State<LinePropertiesPanel> createState() => _LinePropertiesPanelState();
}

class _LinePropertiesPanelState extends State<LinePropertiesPanel> {
  bool _showStrokeOptions = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TemplatePropertyPanelShell(
      inToolbar: widget.inToolbar,
      onDismiss: widget.onDismiss,
      child: Padding(
        padding: widget.inToolbar
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
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.zIndexControls,
                          const SizedBox(width: 16),
                          Text(
                            'Length (mm)',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 64,
                            child: SyncedDimField(
                              key: ValueKey('line_len_${widget.id}'),
                              value: widget.line.lengthMm,
                              min: 2.0,
                              max: 200.0,
                              onValidValue: (p) => widget.onUpdate(
                                widget.page1,
                                widget.line.copyWith(lengthMm: p),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TemplateOptionSlider(
                              value: widget.line.lengthMm.clamp(2.0, 200.0),
                              min: 2.0,
                              max: 200.0,
                              divisions: 198,
                              label:
                                  '${widget.line.lengthMm.toStringAsFixed(1)} mm',
                              onChanged: (v) => widget.onUpdate(
                                widget.page1,
                                widget.line.copyWith(lengthMm: v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.palette_outlined, size: 22),
                            isSelected: _showStrokeOptions,
                            tooltip: 'Line stroke options',
                            onPressed: () {
                              setState(() {
                                _showStrokeOptions = !_showStrokeOptions;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rotation',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          _RotationPicker(
                            value: widget.line.rotationDegrees,
                            onChanged: (v) => widget.onUpdate(
                              widget.page1,
                              widget.line.copyWith(rotationDegrees: v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showStrokeOptions) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Thickness',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            _ThicknessPicker(
                              value: widget.line.thicknessPt,
                              onChanged: (v) => widget.onUpdate(
                                widget.page1,
                                widget.line.copyWith(thicknessPt: v),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Color',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            _ColorSwatch(
                              color: Color(widget.line.colorArgb),
                              borderColor: scheme.outline,
                              title: 'Select color',
                              onPicked: (color) => widget.onUpdate(
                                widget.page1,
                                widget.line
                                    .copyWith(colorArgb: color.toARGB32()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Style',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            _StylePicker(
                              value: widget.line.strokeStyle,
                              onChanged: (v) => widget.onUpdate(
                                widget.page1,
                                widget.line.copyWith(strokeStyle: v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
              tooltip: 'Delete line',
              onPressed: () => widget.onDelete(widget.page1, widget.id),
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

class _StylePicker extends StatelessWidget {
  const _StylePicker({
    required this.value,
    required this.onChanged,
  });

  static const values = ['solid', 'dashed', 'dotted', 'double'];

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return DropdownButton<String>(
      value: values.contains(value) ? value : 'solid',
      isDense: true,
      underline: const SizedBox.shrink(),
      items: [
        for (final val in values)
          DropdownMenuItem(
            value: val,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 20,
                  child: CustomPaint(
                    painter: _StylePreviewPainter(style: val, color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(val[0].toUpperCase() + val.substring(1)),
              ],
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _StylePreviewPainter extends CustomPainter {
  const _StylePreviewPainter({
    required this.style,
    required this.color,
  });

  final String style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;

    if (style == 'solid') {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    } else if (style == 'dashed') {
      _drawDashedLine(canvas, size.width, y, paint, 6.0, 3.0);
    } else if (style == 'dotted') {
      _drawDashedLine(canvas, size.width, y, paint, 1.5, 3.0);
    } else if (style == 'double') {
      final paintDouble = Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, y - 2), Offset(size.width, y - 2), paintDouble);
      canvas.drawLine(Offset(0, y + 2), Offset(size.width, y + 2), paintDouble);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    double width,
    double y,
    Paint paint,
    double dashLen,
    double gapLen,
  ) {
    double d = 0.0;
    while (d < width) {
      final end = (d + dashLen).clamp(0.0, width);
      canvas.drawLine(
        Offset(d, y),
        Offset(end, y),
        paint,
      );
      d += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant _StylePreviewPainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.color != color;
  }
}
