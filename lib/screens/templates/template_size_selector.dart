import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/templates/template_settings_services.dart';

class TemplatePreset {
  final String name;
  final double widthMm;
  final double heightMm;
  final String dimensionsIn;
  final String description;

  const TemplatePreset({
    required this.name,
    required this.widthMm,
    required this.heightMm,
    required this.dimensionsIn,
    required this.description,
  });
}

const List<TemplatePreset> globalPaperPresets = [
  TemplatePreset(
    name: 'A4',
    widthMm: 210.0,
    heightMm: 297.0,
    dimensionsIn: '8.27 × 11.69 in',
    description:
        'International standard default for catalogs, reports, and label sheets.',
  ),
  TemplatePreset(
    name: 'Letter',
    widthMm: 215.9,
    heightMm: 279.4,
    dimensionsIn: '8.5 × 11.0 in',
    description:
        'North American standard default for documentation and matrix printing.',
  ),
  TemplatePreset(
    name: 'Legal',
    widthMm: 215.9,
    heightMm: 355.6,
    dimensionsIn: '8.5 × 14.0 in',
    description:
        'Extended canvas for long field logs, history sheets, or oversized tables.',
  ),
  TemplatePreset(
    name: 'A5',
    widthMm: 148.0,
    heightMm: 210.0,
    dimensionsIn: '5.83 × 8.27 in',
    description:
        'Compact size ideal for pocket field books and small log inserts.',
  ),
  TemplatePreset(
    name: 'A3',
    widthMm: 297.0,
    heightMm: 420.0,
    dimensionsIn: '11.69 × 16.54 in',
    description:
        'Oversized sheet for map generation, collection drawer layouts, and system grids.',
  ),
];

const List<TemplatePreset> cryotubePresets = [
  TemplatePreset(
    name: '1.5 - 2.0 mL Vial Side',
    widthMm: 33.0,
    heightMm: 13.0,
    dimensionsIn: '1.30 × 0.50 in',
    description:
        'Standard side-wall label. Fits 3-4 lines of text plus a barcode.',
  ),
  TemplatePreset(
    name: '0.5 - 1.0 mL Vial Side',
    widthMm: 24.0,
    heightMm: 13.0,
    dimensionsIn: '0.94 × 0.50 in',
    description:
        'Compact side-wall profile for smaller tissue or DNA aliquots.',
  ),
  TemplatePreset(
    name: 'Small Vial Cap Dot',
    widthMm: 9.5,
    heightMm: 9.5,
    dimensionsIn: '0.375 in Ø',
    description:
        'Circular top dot fitting 0.5–1.5 mL tube caps for top-down scanning.',
  ),
  TemplatePreset(
    name: 'Large Vial Cap Dot',
    widthMm: 13.0,
    heightMm: 13.0,
    dimensionsIn: '0.50 in Ø',
    description:
        'Circular top dot fitting 2.0 mL or larger cryovial screw caps.',
  ),
  TemplatePreset(
    name: 'Self-Laminating Wrap',
    widthMm: 25.4,
    heightMm: 31.8,
    dimensionsIn: '1.00 × 1.25 in',
    description:
        'Text prints on a 25.4x12.7mm zone; clear tail wraps over to protect against liquid nitrogen.',
  ),
];

const List<TemplatePreset> specimenPresets = [
  TemplatePreset(
    name: 'Arthropod Pinned (Locality)',
    widthMm: 18.0,
    heightMm: 8.0,
    dimensionsIn: '0.70 × 0.31 in',
    description:
        'Rigid boundary for pinned insects; fits 5-6 lines of ultra-compact metadata.',
  ),
  TemplatePreset(
    name: 'Arthropod Pinned (Taxon ID)',
    widthMm: 15.0,
    heightMm: 7.0,
    dimensionsIn: '0.59 × 0.28 in',
    description:
        'Smallest footprint; contains Genus species, author, and determiner info.',
  ),
  TemplatePreset(
    name: 'Fluid Collection (Jar Insert)',
    widthMm: 75.0,
    heightMm: 25.0,
    dimensionsIn: '3.00 × 1.00 in',
    description:
        'Placed inside wet jars (alcohol/formalin). High legibility through curved glass.',
  ),
  TemplatePreset(
    name: 'Vertebrate Specimen Tag (Medium)',
    widthMm: 100.0,
    heightMm: 34.0,
    dimensionsIn: '3.94 × 1.34 in',
    description: 'Standard medium-sized vertebrate curation and hang tag.',
  ),
  TemplatePreset(
    name: 'Skull Box / Micro-Vial',
    widthMm: 40.0,
    heightMm: 17.0,
    dimensionsIn: '1.57 × 0.67 in',
    description:
        'Optimized for 1-to-2 dram glass vials or small cardboard osteological boxes.',
  ),
];

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
    final s = DocumentSettingsServices();
    final w = await s.getDocumentWidthMm();
    final h = await s.getDocumentHeightMm();
    if (!mounted) return;
    setState(() {
      _w = w;
      _h = h;
      _loaded = true;
    });
  }

  Future<void> _apply(double w, double h) async {
    final s = DocumentSettingsServices();
    await s.setDocumentWidthMm(w);
    await s.setDocumentHeightMm(h);
    if (mounted) {
      setState(() {
        _w = w;
        _h = h;
      });
    }
    widget.onDimensionsApplied?.call();
    widget.onControlledDimensionsApplied?.call(w, h);
  }

  Future<void> _showSelectorDialog() async {
    final result = await showDialog<(double, double)>(
      context: context,
      builder: (context) =>
          TemplateSizeDialog(currentWidth: _w, currentHeight: _h),
    );

    if (result != null && mounted) {
      await _apply(result.$1, result.$2);
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

    if (widget.compact) {
      return InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: _showSelectorDialog,
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

    return OutlinedButton.icon(
      onPressed: _showSelectorDialog,
      icon: const Icon(Icons.arrow_drop_down),
      label: Text(label),
    );
  }
}

class TemplateSizeDialog extends StatefulWidget {
  const TemplateSizeDialog({
    super.key,
    required this.currentWidth,
    required this.currentHeight,
  });

  final double currentWidth;
  final double currentHeight;

  @override
  State<TemplateSizeDialog> createState() => _TemplateSizeDialogState();
}

class _TemplateSizeDialogState extends State<TemplateSizeDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _wController;
  late TextEditingController _hController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _wController = TextEditingController(
      text: widget.currentWidth.toStringAsFixed(1),
    );
    _hController = TextEditingController(
      text: widget.currentHeight.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wController.dispose();
    _hController.dispose();
    super.dispose();
  }

  bool _isCurrentSize(double w, double h) {
    return (widget.currentWidth - w).abs() < 0.05 &&
        (widget.currentHeight - h).abs() < 0.05;
  }

  void _applyCustom() {
    if (_formKey.currentState?.validate() ?? false) {
      final w =
          double.tryParse(_wController.text.replaceAll(',', '.')) ??
          widget.currentWidth;
      final h =
          double.tryParse(_hController.text.replaceAll(',', '.')) ??
          widget.currentHeight;
      Navigator.pop(context, (w.clamp(10.0, 500.0), h.clamp(10.0, 500.0)));
    }
  }

  Widget _buildPresetsList(List<TemplatePreset> presets) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: presets.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final preset = presets[index];
        final isSelected = _isCurrentSize(preset.widthMm, preset.heightMm);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isSelected ? 4 : 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
              : null,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              preset.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${preset.widthMm.toStringAsFixed(1)} × ${preset.heightMm.toStringAsFixed(1)} mm (${preset.dimensionsIn})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                : null,
            onTap: () {
              Navigator.pop(context, (preset.widthMm, preset.heightMm));
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 500,
        height: 520,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Template Size Preset',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Paper'),
                Tab(text: 'Cryotubes'),
                Tab(text: 'Curation'),
                Tab(text: 'Custom'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPresetsList(globalPaperPresets),
                  _buildPresetsList(cryotubePresets),
                  _buildPresetsList(specimenPresets),
                  // Custom size view
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            key: const Key('custom-width-field'),
                            controller: _wController,
                            decoration: const InputDecoration(
                              labelText: 'Width (mm)',
                              border: OutlineInputBorder(),
                              helperText: 'Enter value between 10 and 500 mm',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter a width';
                              }
                              final d = double.tryParse(
                                val.replaceAll(',', '.'),
                              );
                              if (d == null) {
                                return 'Please enter a valid number';
                              }
                              if (d < 10.0 || d > 500.0) {
                                return 'Must be between 10 and 500';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            key: const Key('custom-height-field'),
                            controller: _hController,
                            decoration: const InputDecoration(
                              labelText: 'Height (mm)',
                              border: OutlineInputBorder(),
                              helperText: 'Enter value between 10 and 500 mm',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter a height';
                              }
                              final d = double.tryParse(
                                val.replaceAll(',', '.'),
                              );
                              if (d == null) {
                                return 'Please enter a valid number';
                              }
                              if (d < 10.0 || d > 500.0) {
                                return 'Must be between 10 and 500';
                              }
                              return null;
                            },
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              key: const Key('custom-apply-button'),
                              onPressed: _applyCustom,
                              child: const Text('Apply Custom Size'),
                            ),
                          ),
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
