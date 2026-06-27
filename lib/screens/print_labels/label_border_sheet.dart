import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:nahpu/screens/print_labels/label_template_model.dart';

/// Line style, thickness, and color for the label outline. Updates
/// [onOutlineChanged] on every change; `null` means no border.
class LabelBorderEditorSheet extends StatefulWidget {
  const LabelBorderEditorSheet({
    super.key,
    required this.initialOutline,
    required this.onOutlineChanged,
    this.maxHeightFraction = 0.85,
    this.embeddedPanel = false,
  });

  /// Snapshot when first built (e.g. panel session key in parent).
  final LabelTemplateOutline? initialOutline;

  final ValueChanged<LabelTemplateOutline?> onOutlineChanged;

  /// Max height as a fraction of screen height; embedded layout fills this height (no scroll).
  final double maxHeightFraction;

  /// When true, omits modal-style bottom padding (used above the editor bottom bar).
  final bool embeddedPanel;

  @override
  State<LabelBorderEditorSheet> createState() => _LabelBorderEditorSheetState();
}

class _LabelBorderEditorSheetState extends State<LabelBorderEditorSheet> {
  static const _lineStyles = <LabelTemplateOutlineStyle>[
    LabelTemplateOutlineStyle.solid,
    LabelTemplateOutlineStyle.dashed,
    LabelTemplateOutlineStyle.dotted,
    LabelTemplateOutlineStyle.doubleLine,
  ];

  static const _widthMin = 0.25;
  static const _widthMax = 6.0;
  static const _widthStep = 0.25;

  /// Null = no border (no style chip selected).
  LabelTemplateOutlineStyle? _style;
  late double _widthPt;
  late int _colorArgb;
  late final TextEditingController _widthCtrl;
  late final TextEditingController _hexRgbCtrl;

  static int _rChannel(int argb) => (argb >> 16) & 0xFF;
  static int _gChannel(int argb) => (argb >> 8) & 0xFF;
  static int _bChannel(int argb) => argb & 0xFF;
  static int _aChannel(int argb) => (argb >> 24) & 0xFF;

  static String _rgbHexString(int argb) {
    final r = _rChannel(argb);
    final g = _gChannel(argb);
    final b = _bChannel(argb);
    return '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    final o = widget.initialOutline;
    _style = o?.style;
    _widthPt = (o?.widthPt ?? 1.5).clamp(_widthMin, _widthMax);
    _colorArgb = o?.colorArgb ?? 0xFF757575;
    _widthCtrl = TextEditingController(text: _widthPt.toStringAsFixed(2));
    _hexRgbCtrl = TextEditingController(text: _rgbHexString(_colorArgb));
  }

  @override
  void dispose() {
    _widthCtrl.dispose();
    _hexRgbCtrl.dispose();
    super.dispose();
  }

  void _syncHexField() {
    final hex = _rgbHexString(_colorArgb);
    if (_hexRgbCtrl.text.toUpperCase() != hex) {
      _hexRgbCtrl.text = hex;
    }
  }

  void _tryApplyHexRgbIfComplete() {
    var h = _hexRgbCtrl.text.trim();
    if (h.startsWith('#')) h = h.substring(1);
    if (h.length == 3) {
      h = h.split('').map((ch) => '$ch$ch').join();
    }
    if (h.length != 6) return;
    final r = int.tryParse(h.substring(0, 2), radix: 16);
    final g = int.tryParse(h.substring(2, 4), radix: 16);
    final b = int.tryParse(h.substring(4, 6), radix: 16);
    if (r == null || g == null || b == null) return;
    final a = _aChannel(_colorArgb);
    final next = (a << 24) | (r << 16) | (g << 8) | b;
    if (next != _colorArgb) {
      setState(() => _colorArgb = next);
      if (_style != null) _pushOutline();
    }
  }

  void _commitHexRgbField() {
    _tryApplyHexRgbIfComplete();
    _syncHexField();
  }

  LabelTemplateOutline? _currentOutline() {
    final s = _style;
    if (s == null) return null;
    return LabelTemplateOutline(
      style: s,
      widthPt: _widthPt,
      colorArgb: _colorArgb,
    );
  }

  void _pushOutline() {
    widget.onOutlineChanged(_currentOutline());
  }

  void _onChipSelected(LabelTemplateOutlineStyle e, bool selected) {
    if (selected) {
      setState(() => _style = e);
      _pushOutline();
    } else if (_style == e) {
      setState(() => _style = null);
      widget.onOutlineChanged(null);
    }
  }

  void _setWidthPt(double v) {
    final clamped = v.clamp(_widthMin, _widthMax);
    setState(() => _widthPt = clamped);
    _widthCtrl.text = clamped.toStringAsFixed(2);
    if (_style != null) _pushOutline();
  }

  void _bumpWidth(double delta) {
    _setWidthPt(_widthPt + delta);
  }

  void _commitWidthFromField() {
    final raw = _widthCtrl.text.trim().replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v == null) {
      _widthCtrl.text = _widthPt.toStringAsFixed(2);
      return;
    }
    _setWidthPt(v);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = widget.embeddedPanel
        ? 10.0
        : (10.0 + MediaQuery.paddingOf(context).bottom);
    final screenH = MediaQuery.sizeOf(context).height;
    final panelH = screenH * widget.maxHeightFraction;

    return SizedBox(
      height: panelH,
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Border',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Style',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final e in _lineStyles)
                              ChoiceChip(
                                label: Text(_styleLabel(e)),
                                selected: _style == e,
                                onSelected: (sel) => _onChipSelected(e, sel),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Thickness (pt)',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => _bumpWidth(-_widthStep),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(40, 40),
                                padding: const EdgeInsets.all(8),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              iconSize: 20,
                              icon: const Icon(Icons.remove),
                              tooltip: 'Decrease',
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: SizedBox(
                                width: 76,
                                child: TextField(
                                  controller: _widthCtrl,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontSize: 14),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: false,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d.]'),
                                    ),
                                  ],
                                  textAlign: TextAlign.left,
                                  decoration: const InputDecoration(
                                    suffixText: 'pt',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  onEditingComplete: _commitWidthFromField,
                                  onSubmitted: (_) => _commitWidthFromField,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => _bumpWidth(_widthStep),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(40, 40),
                                padding: const EdgeInsets.all(8),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              iconSize: 20,
                              icon: const Icon(Icons.add),
                              tooltip: 'Increase',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 54,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Color',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 118,
                              child: TextField(
                                controller: _hexRgbCtrl,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 13),
                                decoration: const InputDecoration(
                                  labelText: 'Hex',
                                  hintText: '#RRGGBB',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9a-fA-F#]'),
                                  ),
                                  LengthLimitingTextInputFormatter(7),
                                ],
                                textCapitalization:
                                    TextCapitalization.characters,
                                onChanged: (_) => _tryApplyHexRgbIfComplete(),
                                onEditingComplete: _commitHexRgbField,
                                onSubmitted: (_) => _commitHexRgbField,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: ColorPicker(
                              color: Color(_colorArgb),
                              onColorChanged: (Color color) {
                                setState(() {
                                  _colorArgb = color.toARGB32();
                                  _syncHexField();
                                });
                                if (_style != null) _pushOutline();
                              },
                              width: 32,
                              height: 32,
                              borderRadius: 4,
                              spacing: 5,
                              runSpacing: 5,
                              wheelDiameter: 155,
                              heading: Text(
                                'Select color',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              subheading: Text(
                                'Select color shade',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              wheelSubheading: Text(
                                'Selected color and its shades',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              showMaterialName: true,
                              showColorName: true,
                              showColorCode: false,
                              copyPasteBehavior:
                                  const ColorPickerCopyPasteBehavior(
                                longPressMenu: true,
                              ),
                              materialNameTextStyle:
                                  Theme.of(context).textTheme.bodySmall,
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
                            ),
                          ),
                        ),
                      ],
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

  static String _styleLabel(LabelTemplateOutlineStyle s) {
    switch (s) {
      case LabelTemplateOutlineStyle.solid:
        return 'Solid';
      case LabelTemplateOutlineStyle.dashed:
        return 'Dashed';
      case LabelTemplateOutlineStyle.dotted:
        return 'Dotted';
      case LabelTemplateOutlineStyle.doubleLine:
        return 'Double';
    }
  }
}
