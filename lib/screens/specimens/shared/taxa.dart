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
                return AdaptiveLayout(
                  useHorizontalLayout: useHorizontalLayout,
                  children: [
                    Text(
                      taxonData.taxonClass ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      taxonData.taxonOrder ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      taxonData.taxonFamily ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
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
}

class SpeciesAutoComplete extends ConsumerStatefulWidget {
  const SpeciesAutoComplete({
    super.key,
    required this.specimenUuid,
    required this.speciesCtr,
    required this.options,
    this.errorText,
  });

  final String specimenUuid;
  final TextEditingController speciesCtr;
  final List<String> options;
  final String? errorText;

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
        errorText: widget.errorText,
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
      errorText:
        speciesCtr == null ? 'This field is recommended.' : null,
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
