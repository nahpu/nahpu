import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/types/fossils.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';

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
          loading: () => const CommonProgressIndicator(),
          error: (error, _) => Text('Error loading stratigraphy data: $error'),
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
  late final TextEditingController _formationCtr;
  late final TextEditingController _stageCtr;
  late final TextEditingController _biozoneCtr;
  late final TextEditingController _commentsCtr;
  late final TextEditingController _referencesCtr;
  String? _era;
  String? _period;
  String? _series;
  String? _epoch;

  @override
  void initState() {
    super.initState();
    final data = widget.fossilSite;
    _formationCtr = TextEditingController(text: data?.formation);
    _stageCtr = TextEditingController(text: data?.narrowerGeologicStage);
    _biozoneCtr = TextEditingController(text: data?.biozone);
    _commentsCtr = TextEditingController(text: data?.stratigraphyRemark);
    _referencesCtr = TextEditingController(text: data?.stratigraphicSource);
    _era = stratigraphyValueAt(geologicEraList, data?.geologicEra);
    _period = stratigraphyValueAt(_periodOptions, data?.geologicPeriod);
    _series = stratigraphyValueAt(_seriesOptions, data?.geologicSeries);
    _epoch = stratigraphyValueAt(_epochOptions, data?.geologicEpoch);
  }

  @override
  void dispose() {
    _formationCtr.dispose();
    _stageCtr.dispose();
    _biozoneCtr.dispose();
    _commentsCtr.dispose();
    _referencesCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _formationCtr,
          onChanged: (value) =>
              _save(FossilSiteCompanion(formation: db.Value(value))),
          decoration: const InputDecoration(
            labelText: 'Formation',
            hintText: 'E.g. "Hell Creek Formation"',
          ),
        ),
        DropdownButtonFormField<String>(
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
          // Keyed by the parent so the field is rebuilt, and its selection
          // cleared, whenever the era changes.
          key: ValueKey('period-$_era'),
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
          key: ValueKey('series-$_period'),
          isExpanded: true,
          initialValue: _series,
          decoration: InputDecoration(
            labelText: 'Geologic Series',
            hintText: _seriesOptions.isNotEmpty
                ? 'Select a geologic series'
                : 'Select a period first',
          ),
          items: _menuItems(_seriesOptions),
          onChanged: _seriesOptions.isNotEmpty
              ? (value) {
                  setState(() => _series = value);
                  _save(
                    FossilSiteCompanion(
                      geologicSeries: db.Value(
                        stratigraphyIndexOf(_seriesOptions, value),
                      ),
                    ),
                  );
                }
              : null,
        ),
        DropdownButtonFormField<String>(
          key: ValueKey('epoch-$_period'),
          isExpanded: true,
          initialValue: _epoch,
          decoration: InputDecoration(
            labelText: 'Geologic Epoch',
            hintText: _epochOptions.isNotEmpty
                ? 'Select a geologic epoch'
                : 'Select a period first',
          ),
          items: _menuItems(_epochOptions),
          onChanged: _epochOptions.isNotEmpty
              ? (value) {
                  setState(() => _epoch = value);
                  _save(
                    FossilSiteCompanion(
                      geologicEpoch: db.Value(
                        stratigraphyIndexOf(_epochOptions, value),
                      ),
                    ),
                  );
                }
              : null,
        ),
        TextFormField(
          controller: _stageCtr,
          onChanged: (value) => _save(
            FossilSiteCompanion(narrowerGeologicStage: db.Value(value)),
          ),
          decoration: const InputDecoration(
            labelText: 'Narrower Geologic Stage',
            hintText: 'Local or non-standardized substage',
          ),
        ),
        TextFormField(
          controller: _biozoneCtr,
          onChanged: (value) =>
              _save(FossilSiteCompanion(biozone: db.Value(value))),
          decoration: const InputDecoration(
            labelText: 'Biozone',
            hintText: 'E.g. "Triceratops biozone"',
          ),
        ),
        TextFormField(
          maxLines: 4,
          controller: _commentsCtr,
          onChanged: (value) =>
              _save(FossilSiteCompanion(stratigraphyRemark: db.Value(value))),
          decoration: const InputDecoration(
            labelText: 'Comments',
            hintText: 'Notes on the stratigraphy or geological age.',
          ),
        ),
        TextFormField(
          maxLines: 4,
          controller: _referencesCtr,
          onChanged: (value) =>
              _save(FossilSiteCompanion(stratigraphicSource: db.Value(value))),
          decoration: const InputDecoration(
            labelText: 'Reference source(s) for stratigraphy',
            hintText: 'Citation(s) or link(s) to relevant paper(s).',
          ),
        ),
      ],
    );
  }

  /// Periods for the selected era, with the shared fallback options.
  List<String> get _periodOptions {
    final periods = geologicPeriodsByEra[_era];
    return periods == null ? const [] : withStratigraphyFallback(periods);
  }

  /// Series for the selected period, with the shared fallback options.
  List<String> get _seriesOptions {
    final series = geologicSeriesByPeriod[_period];
    return series == null ? const [] : withStratigraphyFallback(series);
  }

  /// Epochs for the selected period (period, not series), with fallbacks.
  List<String> get _epochOptions {
    final epochs = geologicEpochsByPeriod[_period];
    return epochs == null ? const [] : withStratigraphyFallback(epochs);
  }

  List<DropdownMenuItem<String>> _menuItems(List<String> options) => options
      .map(
        (e) => DropdownMenuItem(
          value: e,
          child: CommonDropdownText(text: e),
        ),
      )
      .toList();

  void _onEraChanged(String? value) {
    setState(() {
      _era = value;
      // Reset dependent fields when the parent category changes.
      _period = null;
      _series = null;
      _epoch = null;
    });
    _save(
      FossilSiteCompanion(
        geologicEra: db.Value(stratigraphyIndexOf(geologicEraList, value)),
        geologicPeriod: const db.Value(null),
        geologicSeries: const db.Value(null),
        geologicEpoch: const db.Value(null),
      ),
    );
  }

  void _onPeriodChanged(String? value) {
    setState(() {
      _period = value;
      _series = null;
      _epoch = null;
    });
    _save(
      FossilSiteCompanion(
        geologicPeriod: db.Value(stratigraphyIndexOf(_periodOptions, value)),
        geologicSeries: const db.Value(null),
        geologicEpoch: const db.Value(null),
      ),
    );
  }

  void _save(FossilSiteCompanion entries) {
    FossilSiteServices(ref: ref).updateFossilSite(widget.siteId, entries);
  }
}

class StratigraphyInfoContent extends StatelessWidget {
  const StratigraphyInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          content:
              'Information about the stratigraphy and geological age of the'
              ' site.',
        ),
      ],
    );
  }
}
