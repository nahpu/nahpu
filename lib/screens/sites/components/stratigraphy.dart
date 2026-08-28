import 'package:flutter/material.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/fossils.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';

/// Stratigraphy and geological age of a fossil site.
///
/// UI only for now: the fields hold local state and are not yet persisted to
/// the database. The layout mirrors [Sedimentology] so the two paleontology
/// sections read as a pair.
class Stratigraphy extends StatefulWidget {
  const Stratigraphy({
    super.key,
    required this.id,
    required this.useHorizontalLayout,
    required this.siteFormCtr,
  });

  final int id;
  final bool useHorizontalLayout;
  final SiteFormCtrModel siteFormCtr;

  @override
  StratigraphyState createState() => StratigraphyState();
}

class StratigraphyState extends State<Stratigraphy> {
  // Local, UI-only state. Not yet persisted to the database.
  final TextEditingController _formationCtr = TextEditingController();
  final TextEditingController _stageCtr = TextEditingController();
  final TextEditingController _biozoneCtr = TextEditingController();
  final TextEditingController _commentsCtr = TextEditingController();
  final TextEditingController _referencesCtr = TextEditingController();
  String? _era;
  String? _period;
  String? _series;
  String? _epoch;

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
    // Natural-height card: the site form stacks Sedimentology and Stratigraphy
    // in one scrolling pane, so the scroll lives there rather than here.
    return FormCard(
      title: 'Stratigraphy',
      infoContent: const StratigraphyInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      child: Padding(padding: const EdgeInsets.all(6), child: _buildFields()),
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        TextFormField(
          controller: _formationCtr,
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
              ? (value) => setState(() => _series = value)
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
              ? (value) => setState(() => _epoch = value)
              : null,
        ),
        TextFormField(
          controller: _stageCtr,
          decoration: const InputDecoration(
            labelText: 'Narrower Geologic Stage',
            hintText: 'Local or non-standardized substage',
          ),
        ),
        TextFormField(
          controller: _biozoneCtr,
          decoration: const InputDecoration(
            labelText: 'Biozone',
            hintText: 'E.g. "Triceratops biozone"',
          ),
        ),
        TextFormField(
          maxLines: 4,
          controller: _commentsCtr,
          decoration: const InputDecoration(
            labelText: 'Comments',
            hintText: 'Notes on the stratigraphy or geological age.',
          ),
        ),
        TextFormField(
          maxLines: 4,
          controller: _referencesCtr,
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
        (e) => DropdownMenuItem(value: e, child: CommonDropdownText(text: e)),
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
  }

  void _onPeriodChanged(String? value) {
    setState(() {
      _period = value;
      _series = null;
      _epoch = null;
    });
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
