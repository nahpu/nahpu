import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/label_settings_services.dart';

/// Avery-style presets (mm). Round templates use [diameter × diameter] bounding box.
const List<(String label, double w, double h)> _kMailingAddressPresets = [
  ('5160 / 8160 — Standard address', 66.7, 25.4),
  ('5167 / 8167 — Return address', 44.4, 12.7),
  ('5161 / 8161 — Large address', 101.6, 25.4),
  ('5162 / 8162 — Large address / shipping', 101.6, 33.9),
  ('5195 / 8195 — Mini return address', 44.4, 16.9),
  ('5366 / 8366 — File folder', 87.3, 16.9),
];

const List<(String label, double w, double h)> _kShippingPresets = [
  ('5163 / 8163 — Standard shipping', 101.6, 50.8),
  ('5164 / 8164 — Large shipping', 101.6, 84.7),
  ('5165 / 8165 — Full sheet (letter)', 215.9, 279.4),
  ('5168 / 8168 — Large shipping / wine', 127.0, 88.9),
  ('5126 / 8126 — Half sheet shipping', 215.9, 139.7),
];

const List<(String label, double w, double h)> _kRoundSquarePresets = [
  ('22807 / 94500 — Round Ø50.8 (bbox)', 50.8, 50.8),
  ('22830 / 94501 — Round Ø63.5 (bbox)', 63.5, 63.5),
  ('5293 / 94503 — Round Ø42.4 (bbox)', 42.4, 42.4),
  ('22805 / 94107 — Square 38.1×38.1', 38.1, 38.1),
  ('22806 / 94101 — Square 50.8×50.8', 50.8, 50.8),
];

const List<(String label, double w, double h)> _kSpecialtyPresets = [
  ('5395 / 8395 — Name badges', 85.7, 59.3),
  ('60505 — GHS chemical (full sheet)', 215.9, 279.4),
  ('60517 — Durable asset tag', 38.1, 19.1),
  ('5371 / 8371 — Business cards', 88.9, 50.8),
];

const List<(String label, double w, double h)> _kUkIntlPresets = [
  ('L7160 / J8160 — Address (A4 family)', 63.5, 38.1),
];

const List<(String label, double w, double h)> _kOtherPresets = [
  ('50 × 25 mm', 50, 25),
  ('70 × 35 mm', 70, 35),
  ('100 × 50 mm', 100, 50),
];

String _formatPresetMm(double v) {
  final t = v.truncateToDouble();
  return (v - t).abs() < 1e-9 ? t.toInt().toString() : v.toStringAsFixed(1);
}

String _presetDimensionsLabel(double w, double h) =>
    '${_formatPresetMm(w)}×${_formatPresetMm(h)} mm';

List<PopupMenuEntry<String>> _labelSizePresetMenuEntries() {
  PopupMenuItem<String> item((String label, double w, double h) p) {
    return PopupMenuItem<String>(
      value: '${p.$2},${p.$3}',
      child: Text(_presetDimensionsLabel(p.$2, p.$3)),
    );
  }

  return [
    ..._kMailingAddressPresets.map(item),
    ..._kShippingPresets.map(item),
    ..._kRoundSquarePresets.map(item),
    ..._kSpecialtyPresets.map(item),
    ..._kUkIntlPresets.map(item),
    ..._kOtherPresets.map(item),
  ];
}

class TemplateSizeSelector extends ConsumerStatefulWidget {
  const TemplateSizeSelector({
    super.key,
    this.compact = false,
    this.onDimensionsApplied,
    this.controlledWidthMm,
    this.controlledHeightMm,
    this.onControlledDimensionsApplied,
  });

  final bool compact;
  final VoidCallback? onDimensionsApplied;

  /// When both are non-null, size is driven by the parent (e.g. template editor).
  final double? controlledWidthMm;
  final double? controlledHeightMm;

  /// Called with new width/height after a preset or custom apply (parent should update state).
  final void Function(double widthMm, double heightMm)?
      onControlledDimensionsApplied;

  @override
  ConsumerState<TemplateSizeSelector> createState() =>
      _TemplateSizeSelectorState();
}

class _TemplateSizeSelectorState extends ConsumerState<TemplateSizeSelector> {
  double _w = 50;
  double _h = 25;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.controlledWidthMm != null && widget.controlledHeightMm != null) {
      _w = widget.controlledWidthMm!;
      _h = widget.controlledHeightMm!;
      _loaded = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void didUpdateWidget(TemplateSizeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controlledWidthMm != null && widget.controlledHeightMm != null) {
      final nw = widget.controlledWidthMm!;
      final nh = widget.controlledHeightMm!;
      if (nw != oldWidget.controlledWidthMm ||
          nh != oldWidget.controlledHeightMm) {
        setState(() {
          _w = nw;
          _h = nh;
        });
      }
    }
  }

  Future<void> _load() async {
    final s = LabelSettingsServices();
    final w = await s.getLabelWidthMm();
    final h = await s.getLabelHeightMm();
    if (!mounted) return;
    setState(() {
      _w = w;
      _h = h;
      _loaded = true;
    });
  }

  Future<void> _apply(double w, double h) async {
    final s = LabelSettingsServices();
    await s.setLabelWidthMm(w);
    await s.setLabelHeightMm(h);
    if (mounted) {
      setState(() {
        _w = w;
        _h = h;
      });
    }
    widget.onDimensionsApplied?.call();
    widget.onControlledDimensionsApplied?.call(w, h);
  }

  Future<void> _openCustomDialog() async {
    final wCtr = TextEditingController(text: _w.toStringAsFixed(1));
    final hCtr = TextEditingController(text: _h.toStringAsFixed(1));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Template size (mm)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wCtr,
              decoration: const InputDecoration(labelText: 'Width (mm)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: hCtr,
              decoration: const InputDecoration(labelText: 'Height (mm)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final nw = double.tryParse(wCtr.text.replaceAll(',', '.')) ?? _w;
      final nh = double.tryParse(hCtr.text.replaceAll(',', '.')) ?? _h;
      await _apply(nw.clamp(10.0, 500.0), nh.clamp(10.0, 500.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final label = '${_w.toStringAsFixed(0)}×${_h.toStringAsFixed(0)} mm';

    final menuItems = <PopupMenuEntry<String>>[
      ..._labelSizePresetMenuEntries(),
      const PopupMenuDivider(),
      const PopupMenuItem<String>(
        value: 'custom',
        child: Text('Custom…'),
      ),
    ];

    Future<void> onMenuSelected(String? v) async {
      if (v == null) return;
      if (v == 'custom') {
        await _openCustomDialog();
      } else {
        final parts = v.split(',');
        if (parts.length == 2) {
          await _apply(double.parse(parts[0]), double.parse(parts[1]));
        }
      }
    }

    if (widget.compact) {
      return PopupMenuButton<String>(
        tooltip: 'Template size',
        padding: EdgeInsets.zero,
        itemBuilder: (ctx) => menuItems,
        onSelected: onMenuSelected,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: Theme.of(context).textTheme.labelMedium?.color,
              ),
            ],
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Template size',
      itemBuilder: (ctx) => menuItems,
      onSelected: onMenuSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
