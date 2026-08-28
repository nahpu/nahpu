import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/properties/property_panel_shell.dart';
import 'package:nahpu/screens/templates/components/properties/template_color_picker.dart';
import 'package:nahpu/screens/templates/template_model.dart';

/// Line style, thickness, and color for the template outline.
class TemplateBorderEditorSheet extends StatefulWidget {
  const TemplateBorderEditorSheet({
    super.key,
    required this.initialOutline,
    required this.onOutlineChanged,
    this.inToolbar = false,
    this.onDismiss,
  });

  final TemplateOutline? initialOutline;
  final ValueChanged<TemplateOutline?> onOutlineChanged;
  final bool inToolbar;
  final VoidCallback? onDismiss;

  @override
  State<TemplateBorderEditorSheet> createState() =>
      _TemplateBorderEditorSheetState();
}

class _TemplateBorderEditorSheetState extends State<TemplateBorderEditorSheet> {
  TemplateOutlineStyle? _style;
  late double _widthPt;
  late int _colorArgb;

  @override
  void initState() {
    super.initState();
    final o = widget.initialOutline;
    _style = o?.style;
    _widthPt = o?.widthPt ?? 1.5;
    _colorArgb = o?.colorArgb ?? 0xFF757575;
  }

  void _pushOutline() {
    final s = _style;
    if (s == null) {
      widget.onOutlineChanged(null);
    } else {
      widget.onOutlineChanged(
        TemplateOutline(style: s, widthPt: _widthPt, colorArgb: _colorArgb),
      );
    }
  }

  void _onStyleChanged(String val) {
    if (val == 'none') {
      setState(() {
        _style = null;
      });
      widget.onOutlineChanged(null);
    } else {
      final nextStyle = switch (val) {
        'solid' => TemplateOutlineStyle.solid,
        'dashed' => TemplateOutlineStyle.dashed,
        'dotted' => TemplateOutlineStyle.dotted,
        'double' => TemplateOutlineStyle.doubleLine,
        _ => TemplateOutlineStyle.solid,
      };
      setState(() {
        _style = nextStyle;
      });
      _pushOutline();
    }
  }

  String _styleString(TemplateOutlineStyle s) {
    switch (s) {
      case TemplateOutlineStyle.solid:
        return 'solid';
      case TemplateOutlineStyle.dashed:
        return 'dashed';
      case TemplateOutlineStyle.dotted:
        return 'dotted';
      case TemplateOutlineStyle.doubleLine:
        return 'double';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TemplatePropertyPanelShell(
      inToolbar: widget.inToolbar,
      onDismiss: widget.onDismiss,
      child: Padding(
        padding: widget.inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
                          Text(
                            'Border',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Style',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          _StylePicker(
                            value: _style == null
                                ? 'none'
                                : _styleString(_style!),
                            onChanged: _onStyleChanged,
                          ),
                          if (_style != null) ...[
                            const SizedBox(width: 16),
                            Text(
                              'Thickness',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            _ThicknessPicker(
                              value: _widthPt,
                              onChanged: (v) {
                                setState(() {
                                  _widthPt = v;
                                });
                                _pushOutline();
                              },
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Color',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            TemplateColorSwatch(
                              color: Color(_colorArgb),
                              borderColor: scheme.outline,
                              title: 'Select border color',
                              onPicked: (color) {
                                setState(() {
                                  _colorArgb = color.toARGB32();
                                });
                                _pushOutline();
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
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

class _StylePicker extends StatelessWidget {
  const _StylePicker({required this.value, required this.onChanged});

  static const values = ['none', 'solid', 'dashed', 'dotted', 'double'];

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return DropdownButton<String>(
      value: values.contains(value) ? value : 'none',
      isDense: true,
      underline: const SizedBox.shrink(),
      items: [
        for (final val in values)
          DropdownMenuItem(
            value: val,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (val == 'none')
                  const Icon(Icons.block, size: 16)
                else
                  SizedBox(
                    width: 48,
                    height: 20,
                    child: CustomPaint(
                      painter: _StylePreviewPainter(style: val, color: color),
                    ),
                  ),
                const SizedBox(width: 12),
                Text(
                  val == 'none'
                      ? 'None'
                      : val[0].toUpperCase() + val.substring(1),
                ),
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
  const _StylePreviewPainter({required this.style, required this.color});

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
      canvas.drawLine(Offset(d, y), Offset(end, y), paint);
      d += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant _StylePreviewPainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.color != color;
  }
}

class _ThicknessPicker extends StatelessWidget {
  const _ThicknessPicker({required this.value, required this.onChanged});

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
          .map(
            (thickness) => DropdownMenuItem(
              value: thickness,
              child: Text('${thickness}pt'),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
