import 'package:drift/drift.dart' as db;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/types/fossils.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Loads the stratigraphy recorded for the selected site.
class Stratigraphy extends ConsumerWidget {
  const Stratigraphy({super.key, required this.siteId});

  final int siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(fossilSiteProvider(siteId))
        .when(
          data: (data) => StratigraphyFields(
            key: ValueKey(siteId),
            siteId: siteId,
            fossilSite: data,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Column(
            children: [
              Text('Could not load stratigraphy: $error'),
              TextButton(
                onPressed: () => ref.invalidate(fossilSiteProvider(siteId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
  }
}

class StratigraphyFields extends ConsumerStatefulWidget {
  const StratigraphyFields({
    super.key,
    required this.siteId,
    required this.fossilSite,
  });

  final int siteId;
  final FossilSiteData? fossilSite;

  @override
  ConsumerState<StratigraphyFields> createState() => _StratigraphyFieldsState();
}

class _StratigraphyFieldsState extends ConsumerState<StratigraphyFields> {
  final _formation = TextEditingController();
  final _stage = TextEditingController();
  final _biozone = TextEditingController();
  final _remarks = TextEditingController();
  final _source = TextEditingController();
  String? _era;
  String? _period;
  String? _series;
  String? _epoch;
  String? _saveError;
  int _pendingWrites = 0;
  int _saveGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant StratigraphyFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.siteId != widget.siteId) {
      _saveGeneration++;
      _saveError = null;
      _load();
    } else if (_pendingWrites == 0 &&
        _saveError == null &&
        oldWidget.fossilSite != widget.fossilSite) {
      _load();
    }
  }

  @override
  void dispose() {
    _formation.dispose();
    _stage.dispose();
    _biozone.dispose();
    _remarks.dispose();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _formation,
          decoration: const InputDecoration(
            labelText: 'Formation',
            hintText: 'E.g. "Hell Creek Formation"',
          ),
          onChanged: (_) => _save(),
        ),
        DropdownButtonFormField<String>(
          key: ValueKey(('era', _era)),
          isExpanded: true,
          initialValue: _era,
          decoration: const InputDecoration(
            labelText: 'Geologic Era',
            hintText: 'Select a geologic era',
          ),
          items: _menuItems(geologicEraList),
          onChanged: _onEraChanged,
        ),
        DropdownButtonFormField<String>(
          key: ValueKey(('period', _era, _period)),
          isExpanded: true,
          initialValue: _period,
          decoration: InputDecoration(
            labelText: 'Geologic Period',
            hintText: _periodOptions.isNotEmpty
                ? 'Select a geologic period'
                : 'Select an era first',
          ),
          items: _menuItems(_periodOptions),
          onChanged: _periodOptions.isNotEmpty ? _onPeriodChanged : null,
        ),
        DropdownButtonFormField<String>(
          key: ValueKey(('series', _period, _series)),
          isExpanded: true,
          initialValue: _series,
          decoration: InputDecoration(
            labelText: 'Geologic Series',
            hintText: _seriesOptions.isNotEmpty
                ? 'Select a geologic series'
                : 'Select a period first',
          ),
          items: _menuItems(_seriesOptions),
          onChanged: _seriesOptions.isEmpty
              ? null
              : (value) {
                  setState(() => _series = value);
                  _save();
                },
        ),
        DropdownButtonFormField<String>(
          key: ValueKey(('epoch', _period, _epoch)),
          isExpanded: true,
          initialValue: _epoch,
          decoration: InputDecoration(
            labelText: 'Geologic Epoch',
            hintText: _epochOptions.isNotEmpty
                ? 'Select a geologic epoch'
                : 'Select a period first',
          ),
          items: _menuItems(_epochOptions),
          onChanged: _epochOptions.isEmpty
              ? null
              : (value) {
                  setState(() => _epoch = value);
                  _save();
                },
        ),
        TextFormField(
          controller: _stage,
          decoration: const InputDecoration(
            labelText: 'Narrower Geologic Stage',
            hintText: 'Local or non-standardized substage',
          ),
          onChanged: (_) => _save(),
        ),
        TextFormField(
          controller: _biozone,
          decoration: const InputDecoration(
            labelText: 'Biozone',
            hintText: 'E.g. "Triceratops biozone"',
          ),
          onChanged: (_) => _save(),
        ),
        TextFormField(
          controller: _remarks,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Comments',
            hintText: 'Notes on the stratigraphy or geological age',
          ),
          onChanged: (_) => _save(),
        ),
        TextFormField(
          controller: _source,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Reference source(s) for stratigraphy',
            hintText: 'Citation(s) or link(s) to relevant paper(s)',
          ),
          onChanged: (_) => _save(),
        ),
        if (_saveError != null) ...[
          const SizedBox(height: NahpuSpacing.md),
          Text(
            _saveError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextButton(onPressed: _save, child: const Text('Retry saving')),
        ],
      ],
    );
  }

  List<String> get _periodOptions {
    final periods = geologicPeriodsByEra[_era];
    return periods == null ? const [] : withStratigraphyFallback(periods);
  }

  List<String> get _seriesOptions {
    final series = geologicSeriesByPeriod[_period];
    return series == null ? const [] : withStratigraphyFallback(series);
  }

  List<String> get _epochOptions {
    final epochs = geologicEpochsByPeriod[_period];
    return epochs == null ? const [] : withStratigraphyFallback(epochs);
  }

  List<DropdownMenuItem<String>> _menuItems(List<String> options) => [
    for (final option in options)
      DropdownMenuItem(
        value: option,
        child: CommonDropdownText(text: option),
      ),
  ];

  void _onEraChanged(String? value) {
    if (value == _era) return;
    setState(() {
      _era = value;
      _period = null;
      _series = null;
      _epoch = null;
    });
    _save();
  }

  void _onPeriodChanged(String? value) {
    if (value == _period) return;
    setState(() {
      _period = value;
      _series = null;
      _epoch = null;
    });
    _save();
  }

  void _load() {
    final data = widget.fossilSite;
    _setText(_formation, data?.formation);
    _setText(_stage, data?.narrowerGeologicStage);
    _setText(_biozone, data?.biozone);
    _setText(_remarks, data?.stratigraphyRemark);
    _setText(_source, data?.stratigraphicSource);
    _era = stratigraphyValueAt(geologicEraList, data?.geologicEra);
    _period = stratigraphyValueAt(_periodOptions, data?.geologicPeriod);
    _series = stratigraphyValueAt(_seriesOptions, data?.geologicSeries);
    _epoch = stratigraphyValueAt(_epochOptions, data?.geologicEpoch);
  }

  void _setText(TextEditingController controller, String? value) {
    if (controller.text != (value ?? '')) controller.text = value ?? '';
  }

  Future<void> _save() async {
    final generation = ++_saveGeneration;
    _pendingWrites++;
    final entries = FossilSiteCompanion(
      formation: db.Value(_formation.text),
      geologicEra: db.Value(stratigraphyIndexOf(geologicEraList, _era)),
      geologicPeriod: db.Value(stratigraphyIndexOf(_periodOptions, _period)),
      geologicSeries: db.Value(stratigraphyIndexOf(_seriesOptions, _series)),
      geologicEpoch: db.Value(stratigraphyIndexOf(_epochOptions, _epoch)),
      narrowerGeologicStage: db.Value(_stage.text),
      biozone: db.Value(_biozone.text),
      stratigraphyRemark: db.Value(_remarks.text),
      stratigraphicSource: db.Value(_source.text),
    );
    try {
      await FossilSiteServices(
        ref: ref,
      ).updateFossilSite(widget.siteId, entries);
      if (mounted && generation == _saveGeneration) {
        setState(() => _saveError = null);
      }
    } catch (error) {
      if (mounted && generation == _saveGeneration) {
        setState(() => _saveError = 'Could not save stratigraphy: $error');
      }
    } finally {
      _pendingWrites--;
    }
  }
}
