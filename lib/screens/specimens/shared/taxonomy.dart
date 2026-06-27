import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';

import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/taxonomy_services.dart';

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
      title: 'Taxonomy',
      infoContent: const TaxonomyInfoContent(),
      mainAxisAlignment: MainAxisAlignment.center,
      child: ref.watch(taxonDataProvider(specimenUuid)).when(
            data: (taxonData) {
              if (taxonData == null) {
                return const Text('No species selected');
              } else {
                return Column(
                  children: [
                    AdaptiveLayout(
                      useHorizontalLayout: useHorizontalLayout,
                      children: [
                        TaxonText(
                          rank: 'Class',
                          value: taxonData.taxonClass,
                        ),
                        TaxonText(
                          rank: 'Order',
                          value: taxonData.taxonOrder,
                        ),
                        TaxonText(
                          rank: 'Family',
                          value: taxonData.taxonFamily,
                        ),
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
          title: const Text('Taxonomy'),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taxonomy',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: TaxonDetailsView(taxonData: taxonData),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class TaxonDetailsView extends StatelessWidget {
  const TaxonDetailsView({
    super.key,
    required this.taxonData,
  });

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              children: [
                TaxonDetailRow(
                    label: 'Kingdom', value: getKingdom(taxonData.taxonClass)),
                TaxonDetailRow(
                    label: 'Phylum', value: getPhylum(taxonData.taxonClass)),
                TaxonDetailRow(label: 'Class', value: taxonData.taxonClass),
                TaxonDetailRow(label: 'Order', value: taxonData.taxonOrder),
                TaxonDetailRow(label: 'Family', value: taxonData.taxonFamily),
                TaxonDetailRow(
                    label: 'Genus', value: taxonData.genus, isItalic: true),
                TaxonDetailRow(
                    label: 'Species',
                    value: taxonData.specificEpithet,
                    isItalic: true),
                TaxonDetailRow(label: 'Authors', value: taxonData.authors),
                TaxonDetailRow(
                    label: 'Common name', value: taxonData.commonName),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (taxonData.redListCategory != null &&
              taxonData.redListCategory!.isNotEmpty)
            TaxonDetailRow(
              label: 'Red List category:',
              isStacked: true,
              customValue:
                  RedListCategoryPill(category: taxonData.redListCategory!),
            ),
          TaxonDetailRow(label: 'CITES status:', value: taxonData.citesStatus),
          TaxonDetailRow(
              label: 'Country status:',
              value: taxonData.countryStatus,
              isStacked: true),
          TaxonDetailRow(label: 'Notes:', value: taxonData.notes),
        ],
      ),
    );
  }
}

class RedListCategoryPill extends StatelessWidget {
  const RedListCategoryPill({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final bgColor = matchRedListCategoryColor(category);
    final textColor =
        bgColor.computeLuminance() > 0.3 ? Colors.black : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TaxonDetailRow extends StatelessWidget {
  const TaxonDetailRow({
    super.key,
    required this.label,
    this.value,
    this.customValue,
    this.isItalic = false,
    this.isStacked = false,
  });

  final String label;
  final String? value;
  final Widget? customValue;
  final bool isItalic;
  final bool isStacked;

  @override
  Widget build(BuildContext context) {
    if ((value == null || value!.isEmpty) && customValue == null) {
      return const SizedBox.shrink();
    }

    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: isItalic ? FontStyle.italic : null,
        );

    if (isStacked) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            customValue ??
                Text(
                  value!,
                  style: textStyle,
                ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: customValue == null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: customValue == null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(': ', style: Theme.of(context).textTheme.titleSmall),
                Expanded(
                  child: customValue ??
                      Text(
                        value!,
                        style: textStyle,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaxonText extends StatelessWidget {
  const TaxonText({
    super.key,
    required this.rank,
    required this.value,
  });

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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value ?? '',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
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
  final List<String> options;

  @override
  SpeciesAutoCompleteState createState() => SpeciesAutoCompleteState();
}

class SpeciesAutoCompleteState extends ConsumerState<SpeciesAutoComplete> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Type species name and select from list',
      child: AutoCompleteField(
        focusNode: _focusNode,
        controller: widget.speciesCtr,
        options: widget.options,
        labelText: 'Species',
        hintText: 'Type species name',
        onSelected: (String selection) {
          setState(() {
            _inputTaxon(selection);
          });
          _focusNode.unfocus();
        },
      ),
    );
  }

  void _inputTaxon(String selection) {
    _copyTaxon(selection);
    var taxon = widget.speciesCtr.text.split(' ');
    TaxonomyServices(ref: ref)
        .getTaxonBySpecies(taxon[0], taxon[1])
        .then((data) {
      SpecimenServices(ref: ref).updateSpecimen(
        widget.specimenUuid,
        SpecimenCompanion(speciesID: db.Value(data?.id)),
      );
    });
  }

  void _copyTaxon(String selection) {
    widget.speciesCtr.value = widget.speciesCtr.value.copyWith(
      text: selection,
      selection: TextSelection.collapsed(offset: selection.length),
    );
  }
}

class SpeciesInputField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CommonPadding(
        child: SpeciesAutoComplete(
      specimenUuid: specimenUuid,
      speciesCtr: _getSpeciesCtr,
      options: _options,
    ));
  }

  TextEditingController get _getSpeciesCtr {
    if (speciesCtr == null) {
      return TextEditingController();
    }
    var data = taxonList.firstWhere((taxon) => taxon.id == speciesCtr);
    TextEditingController ctr =
        TextEditingController(text: '${data.genus} ${data.specificEpithet}');
    ctr.selection =
        TextSelection.fromPosition(TextPosition(offset: ctr.text.length));
    return ctr;
  }

  List<String> get _options => taxonList
      .map((taxon) => '${taxon.genus} ${taxon.specificEpithet}')
      .toList();
}

/// Species field that is disabled
/// Used when the taxon list is empty
class DisabledSpeciesField extends StatelessWidget {
  const DisabledSpeciesField({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonPadding(
      child: TextFormField(
        enabled: false,
        decoration: const InputDecoration(
          labelText: 'Species',
          hintText: 'Enter species',
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
        labelText: 'Species',
        hintText: 'Choose a species',
      ),
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) => value!.isEmpty ? 'Please enter a species' : null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }
}

class TaxonomyInfoContent extends StatelessWidget {
  const TaxonomyInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenType screenType = getScreenType(context);
    return InfoContainer(content: [
      const InfoContent(
        content: 'Taxonomic information is automatically added based on the '
            'species you enter. ',
      ),
      screenType == ScreenType.phone
          ? const InfoContent(
              content: 'From top to bottom: Class, Order, Family',
            )
          : const InfoContent(
              content: 'From left to right: Class, Order, Family',
            )
    ]);
  }
}
