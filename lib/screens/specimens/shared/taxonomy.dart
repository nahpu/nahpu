import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_details.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';

import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/projects/taxonomy_services.dart';

class TaxonomicForm extends ConsumerWidget {
  const TaxonomicForm({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: 'Taxon Info',
      infoTopic: InfoTopic.specimenTaxonomy,
      mainAxisAlignment: MainAxisAlignment.center,
      child: ref
          .watch(taxonDataProvider(specimenUuid))
          .when(
            data: (taxonData) {
              if (taxonData == null) {
                return const Text('No species selected');
              } else {
                return Column(
                  children: [
                    AdaptiveLayout(
                      useHorizontalLayout: useHorizontalLayout,
                      children: [
                        TaxonText(rank: 'Class', value: taxonData.taxonClass),
                        TaxonText(rank: 'Order', value: taxonData.taxonOrder),
                        TaxonText(rank: 'Family', value: taxonData.taxonFamily),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _showDetails(context, taxonData),
                      child: const Text('View details'),
                    ),
                  ],
                );
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
    );
  }

  void _showDetails(BuildContext context, TaxonomyData taxonData) {
    if (systemPlatform == PlatformType.desktop) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: TaxonInfoTitle(
            displayName: getTaxonDisplayName(taxonData),
            authors: taxonData.authors,
            commonName: taxonData.commonName,
          ),
          content: TaxonDetailsView(taxonData: taxonData),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaxonInfoTitle(
                  displayName: getTaxonDisplayName(taxonData),
                  authors: taxonData.authors,
                  commonName: taxonData.commonName,
                ),
                Flexible(child: TaxonDetailsView(taxonData: taxonData)),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class TaxonText extends StatelessWidget {
  const TaxonText({super.key, required this.rank, required this.value});

  final String rank;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rank,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value ?? '', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class SpeciesAutoComplete extends ConsumerStatefulWidget {
  const SpeciesAutoComplete({
    super.key,
    required this.specimenUuid,
    required this.speciesCtr,
    required this.options,
  });

  final String specimenUuid;
  final TextEditingController speciesCtr;
  final List<TaxonomyData> options;

  @override
  SpeciesAutoCompleteState createState() => SpeciesAutoCompleteState();
}

class SpeciesAutoCompleteState extends ConsumerState<SpeciesAutoComplete> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Type taxon name and select from list',
      child: AutoCompleteField<TaxonomyData>(
        focusNode: _focusNode,
        controller: widget.speciesCtr,
        options: widget.options,
        displayStringFor: getTaxonDisplayName,
        labelText: 'Taxon',
        hintText: 'Type taxon name',
        onSelected: _inputTaxon,
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Stores the selected taxon's id.
  ///
  /// The option carries the record, so the id is taken straight from it. Looking
  /// the taxon back up by genus and epithet would be ambiguous whenever two
  /// records share them -- a species and its nominate subspecies always do.
  void _inputTaxon(TaxonomyData taxon) {
    SpecimenServices(ref: ref).updateSpecimen(
      widget.specimenUuid,
      SpecimenCompanion(speciesID: db.Value(taxon.id)),
    );
    _focusNode.unfocus();
  }
}

/// The taxon field, holding the text as the user types it.
///
/// Owns its controller so a rebuild cannot replace it mid-edit; the text is
/// only re-derived when the stored taxon actually changes.
class SpeciesInputField extends StatefulWidget {
  const SpeciesInputField({
    super.key,
    required this.specimenUuid,
    required this.speciesCtr,
    required this.taxonList,
  });

  final String specimenUuid;
  final int? speciesCtr;
  final List<TaxonomyData> taxonList;

  @override
  State<SpeciesInputField> createState() => _SpeciesInputFieldState();
}

class _SpeciesInputFieldState extends State<SpeciesInputField> {
  late final TextEditingController _controller = TextEditingController(
    text: _storedTaxonName,
  );

  @override
  Widget build(BuildContext context) {
    return CommonPadding(
      child: SpeciesAutoComplete(
        specimenUuid: widget.specimenUuid,
        speciesCtr: _controller,
        options: widget.taxonList,
      ),
    );
  }

  @override
  void didUpdateWidget(SpeciesInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only follow a change to the stored taxon. Rewriting the text on every
    // rebuild would discard what the user is typing.
    if (oldWidget.speciesCtr != widget.speciesCtr) {
      final name = _storedTaxonName;
      _controller.value = TextEditingValue(
        text: name,
        selection: TextSelection.collapsed(offset: name.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The display name of the taxon this specimen references, if it is loaded.
  String get _storedTaxonName {
    final id = widget.speciesCtr;
    if (id == null) return '';
    for (final taxon in widget.taxonList) {
      if (taxon.id == id) return getTaxonDisplayName(taxon);
    }
    return '';
  }
}

/// Taxon field that is disabled
/// Used when the taxon list is empty
class DisabledSpeciesField extends StatelessWidget {
  const DisabledSpeciesField({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonPadding(
      child: TextFormField(
        enabled: false,
        decoration: const InputDecoration(
          labelText: 'Taxon',
          hintText: 'Enter taxon',
        ),
      ),
    );
  }
}

class SpeciesField extends StatelessWidget {
  const SpeciesField({
    super.key,
    required this.speciesCtr,
    required this.focusNode,
    required this.onFieldSubmitted,
    required this.enable,
  });

  final TextEditingController speciesCtr;
  final FocusNode focusNode;
  final void Function(String) onFieldSubmitted;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enable,
      controller: speciesCtr,
      decoration: const InputDecoration(
        labelText: 'Taxon',
        hintText: 'Choose a taxon',
      ),
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) => value!.isEmpty ? 'Please enter a taxon' : null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }
}
