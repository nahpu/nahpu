import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/components/properties/property_panel_shell.dart';
import 'package:nahpu/screens/templates/components/properties/synced_dim_field.dart';
import 'package:nahpu/screens/templates/template_model.dart';

class ShapePropertiesPanel extends StatefulWidget {
  const ShapePropertiesPanel({
    super.key,
    required this.page1,
    required this.id,
    required this.shape,
    required this.zIndexControls,
    required this.onUpdate,
    required this.onDelete,
    required this.inToolbar,
    this.onDismiss,
  });

  final bool page1;
  final String id;
  final CustomShapeElement shape;
  final Widget zIndexControls;
  final void Function(bool page1, CustomShapeElement element) onUpdate;
  final void Function(bool page1, String id) onDelete;
  final bool inToolbar;
  final VoidCallback? onDismiss;

  @override
  State<ShapePropertiesPanel> createState() => _ShapePropertiesPanelState();
}

class _ShapePropertiesPanelState extends State<ShapePropertiesPanel> {
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
                            'Shape',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          _ShapeTypePicker(
                            value: widget.shape.shapeType,
                            onChanged: (v) => widget.onUpdate(
                              widget.page1,
                              widget.shape.copyWith(shapeType: v),
                            ),
                          ),
                          if (widget.shape.shapeType == 'polygon') ...[
                            const SizedBox(width: 16),
                            _PolygonSidesControl(
                              value: widget.shape.polygonSides,
                              onChanged: (v) => widget.onUpdate(
                                widget.page1,
                                widget.shape.copyWith(polygonSides: v),
                              ),
                            ),
                          ],
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.palette_outlined, size: 22),
                            isSelected: _showStrokeOptions,
                            tooltip: 'Border and fill options',
                            onPressed: () {
                              setState(() {
                                _showStrokeOptions = !_showStrokeOptions;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          _DimensionControl(
                            id: 'shape_w_${widget.id}',
                            label: 'Width (mm)',
                            value: widget.shape.widthMm,
                            onChanged: (v) => widget.onUpdate(
                              widget.page1,
                              widget.shape.copyWith(widthMm: v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          _DimensionControl(
                            id: 'shape_h_${widget.id}',
                            label: 'Height (mm)',
                            value: widget.shape.heightMm,
                            onChanged: (v) => widget.onUpdate(
                              widget.page1,
                              widget.shape.copyWith(heightMm: v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Rotation',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          _RotationPicker(
                            value: widget.shape.rotationDegrees,
                            onChanged: (v) => widget.onUpdate(
                              widget.page1,
                              widget.shape.copyWith(rotationDegrees: v),
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
                              'Stroke',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            _StrokePicker(
                              value: widget.shape.strokeThicknessPt,
                              onChanged: (v) => widget.onUpdate(
                                widget.page1,
                                widget.shape.copyWith(strokeThicknessPt: v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _ColorSwatch(
                              color: Color(widget.shape.strokeColorArgb),
                              borderColor: scheme.outline,
                              title: 'Select stroke color',
                              onPicked: (color) => widget.onUpdate(
                                widget.page1,
                                widget.shape.copyWith(
                                  strokeColorArgb: color.toARGB32(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Style',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            _StylePicker(
                              value: widget.shape.strokeStyle,
                              onChanged: (v) => widget.onUpdate(
                                widget.page1,
                                widget.shape.copyWith(strokeStyle: v),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Fill',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            _NullableFillSwatch(
                              colorArgb: widget.shape.fillColorArgb,
                              borderColor: scheme.outline,
                              onPicked: (color) => widget.onUpdate(
                                widget.page1,
                                widget.shape.copyWith(
                                  fillColorArgb: color.toARGB32(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (widget.shape.fillColorArgb != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.format_color_reset,
                                  size: 20,
                                ),
                                tooltip: 'Clear fill',
                                onPressed: () => widget.onUpdate(
                                  widget.page1,
                                  widget.shape.copyWith(clearFillColor: true),
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
              tooltip: 'Delete shape',
              onPressed: () => widget.onDelete(widget.page1, widget.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShapeTypePicker extends StatelessWidget {
  const _ShapeTypePicker({
    required this.value,
    required this.onChanged,
  });

  static const values = [
    ('rect', 'Rectangle'),
    ('ellipse', 'Ellipse'),
    ('circle', 'Circle'),
    ('triangle', 'Triangle'),
    ('polygon', 'Polygon'),
  ];

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveValue =
        values.any((entry) => entry.$1 == value) ? value : 'rect';
    return DropdownButton<String>(
      value: effectiveValue,
      isDense: true,
      underline: const SizedBox.shrink(),
      items: [
        for (final entry in values)
          DropdownMenuItem(
            value: entry.$1,
            child: Text(entry.$2),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _PolygonSidesControl extends StatelessWidget {
  const _PolygonSidesControl({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Corners', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Slider(
            value: value.clamp(3, 12).toDouble(),
            min: 3,
            max: 12,
            divisions: 9,
            label: '${value.clamp(3, 12)}',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '${value.clamp(3, 12)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

class _DimensionControl extends StatelessWidget {
  const _DimensionControl({
    required this.id,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String id;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: SyncedDimField(
            key: ValueKey(id),
            value: value,
            min: 2.0,
            max: 200.0,
            onValidValue: onChanged,
          ),
        ),
        SizedBox(
          width: 100,
          child: TemplateOptionSlider(
            value: value.clamp(2.0, 200.0),
            min: 2.0,
            max: 200.0,
            divisions: 198,
            label: '${value.toStringAsFixed(1)} mm',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _StrokePicker extends StatelessWidget {
  const _StrokePicker({
    required this.value,
    required this.onChanged,
  });

  static const values = [
    0.0,
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    4.0,
    5.0,
    6.0,
  ];

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

class _NullableFillSwatch extends StatelessWidget {
  const _NullableFillSwatch({
    required this.colorArgb,
    required this.borderColor,
    required this.onPicked,
  });

  final int? colorArgb;
  final Color borderColor;
  final ValueChanged<Color> onPicked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _ColorSwatch(
      color: colorArgb != null ? Color(colorArgb!) : Colors.white,
      borderColor: borderColor,
      title: 'Select fill color',
      onPicked: onPicked,
      child: colorArgb == null
          ? Icon(Icons.close, size: 16, color: scheme.onSurfaceVariant)
          : null,
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.borderColor,
    required this.title,
    required this.onPicked,
    this.child,
  });

  final Color color;
  final Color borderColor;
  final String title;
  final ValueChanged<Color> onPicked;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var selectedColor = color;
        final picked = await ColorPicker(
          color: selectedColor,
          onColorChanged: (c) => selectedColor = c,
          enableShadesSelection: true,
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
          color: child == null ? color : Colors.transparent,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
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
