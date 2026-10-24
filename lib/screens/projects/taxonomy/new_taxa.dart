import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

class NewTaxon extends StatelessWidget {
  const NewTaxon({super.key});

  @override
  Widget build(BuildContext context) {
    final TaxonRegistryCtrModel ctr = TaxonRegistryCtrModel.empty();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.projectTaxonNew),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: TaxonRegistryForm(taxonId: null, ctr: ctr, isEditing: false),
        ),
      ),
    );
  }
}

class EditTaxon extends StatelessWidget {
  const EditTaxon({super.key, required this.taxonId, required this.ctr});

  final int taxonId;
  final TaxonRegistryCtrModel ctr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.projectTaxonEdit),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: TaxonRegistryForm(taxonId: taxonId, ctr: ctr, isEditing: true),
        ),
      ),
    );
  }
}

class TaxonRegistryForm extends ConsumerStatefulWidget {
  const TaxonRegistryForm({
    super.key,
    required this.taxonId,
    required this.ctr,
    required this.isEditing,
    this.showActions = true,
    this.disposeController = true,
  });

  final int? taxonId;
  final TaxonRegistryCtrModel ctr;
  final bool isEditing;
  final bool showActions;
  final bool disposeController;

  @override
  TaxonRegistryFormState createState() => TaxonRegistryFormState();
}

class TaxonRegistryFormState extends ConsumerState<TaxonRegistryForm> {
  bool _isShowMore = false;

  @override
  void dispose() {
    if (widget.disposeController) widget.ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ScrollableConstrainedLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormSection(
            title: l10n.projectTaxonClassification,
            child: Column(
              children: [
                DropdownButtonFormField<TaxonRank>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.projectTaxonRankLabel,
                    hintText: l10n.projectTaxonRankHint,
                  ),
                  initialValue: _rank,
                  items: TaxonRank.values
                      .map(
                        (rank) => DropdownMenuItem(
                          value: rank,
                          child: CommonDropdownText(
                            text: rank.localizedLabel(l10n),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (rank) {
                    setState(() {
                      widget.ctr.taxonRankCtr = rank?.databaseValue;
                    });
                  },
                ),
                _RankTextField(
                  controller: widget.ctr.kingdomCtr,
                  label: l10n.projectTaxonKingdom,
                ),
                _RankTextField(
                  controller: widget.ctr.phylumCtr,
                  label: l10n.projectTaxonPhylum,
                ),
                if (_shows(TaxonRank.taxonClass))
                  _RankTextField(
                    controller: widget.ctr.taxonClassCtr,
                    label: l10n.projectTaxonClass,
                  ),
                if (_shows(TaxonRank.order))
                  _RankTextField(
                    controller: widget.ctr.taxonOrderCtr,
                    label: l10n.projectTaxonOrder,
                  ),
                if (_shows(TaxonRank.family))
                  _RankTextField(
                    controller: widget.ctr.taxonFamilyCtr,
                    label: l10n.projectTaxonFamily,
                  ),
                if (_shows(TaxonRank.genus))
                  _RankTextField(
                    controller: widget.ctr.genusCtr,
                    label: l10n.projectTaxonGenus,
                  ),
                if (_shows(TaxonRank.species))
                  _RankTextField(
                    controller: widget.ctr.specificEpithetCtr,
                    label: l10n.projectTaxonSpecificEpithet,
                    lowercase: true,
                  ),
                if (_shows(TaxonRank.subspecies))
                  _RankTextField(
                    controller: widget.ctr.subspecificEpithetCtr,
                    label: l10n.projectTaxonSubspecificEpithet,
                    lowercase: true,
                  ),
              ],
            ),
          ),
          FormSection(
            title: l10n.projectTaxonAdditionalDetails,
            child: Column(
              children: [
                CommonTextField(
                  controller: widget.ctr.authorCtr,
                  labelText: l10n.projectTaxonAuthors,
                  hintText: l10n.projectTaxonAuthorsHint,
                  isLastField: false,
                ),
                CommonTextField(
                  controller: widget.ctr.commonNameCtr,
                  labelText: l10n.projectTaxonCommonName,
                  hintText: l10n.projectTaxonCommonNameHint,
                  isLastField: false,
                  onChanged: (String? value) {
                    if (value != null) {
                      widget.ctr.commonNameCtr.value = TextEditingValue(
                        text: value.toSentenceCase(),
                        selection: widget.ctr.commonNameCtr.selection,
                      );
                    }
                  },
                ),
                Visibility(
                  visible:
                      _isShowMore ||
                      widget.ctr.redListCategoryCtr.text.isNotEmpty,
                  child: CommonTextField(
                    controller: widget.ctr.redListCategoryCtr,
                    labelText: l10n.projectTaxonRedListLabel,
                    hintText: l10n.projectTaxonRedListHint,
                    isLastField: false,
                    onChanged: (String? value) {
                      if (value != null) {
                        widget.ctr.redListCategoryCtr.value = TextEditingValue(
                          text: value.toSentenceCase(),
                          selection: widget.ctr.redListCategoryCtr.selection,
                        );
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: _isShowMore || widget.ctr.citesCtr.text.isNotEmpty,
                  child: CommonTextField(
                    controller: widget.ctr.citesCtr,
                    labelText: l10n.projectTaxonCitesStatus,
                    hintText: l10n.projectTaxonCitesHint,
                    isLastField: false,
                    onChanged: (String? value) {
                      if (value != null) {
                        widget.ctr.citesCtr.value = TextEditingValue(
                          text: value.toSentenceCase(),
                          selection: widget.ctr.citesCtr.selection,
                        );
                      }
                    },
                  ),
                ),
                Visibility(
                  visible:
                      _isShowMore ||
                      widget.ctr.countryStatusCtr.text.isNotEmpty,
                  child: CommonTextField(
                    controller: widget.ctr.countryStatusCtr,
                    labelText: l10n.projectTaxonCountryStatusLabel,
                    hintText: l10n.projectTaxonCountryStatusHint,
                    isLastField: false,
                  ),
                ),
                Visibility(
                  visible:
                      _isShowMore || widget.ctr.sortingOrderCtr.text.isNotEmpty,
                  child: CommonNumField(
                    controller: widget.ctr.sortingOrderCtr,
                    labelText: l10n.projectTaxonSortingOrder,
                    hintText: l10n.projectTaxonSortingOrderHint,
                    isLastField: false,
                  ),
                ),
                Visibility(
                  visible: _isShowMore || widget.ctr.noteCtr.text.isNotEmpty,
                  child: CommonTextField(
                    controller: widget.ctr.noteCtr,
                    labelText: l10n.projectPersonnelNotes,
                    hintText: l10n.projectTaxonNotesHint,
                    maxLines: 3,
                    isLastField: false,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isShowMore = !_isShowMore;
                    });
                  },
                  child: Text(
                    _isShowMore ? l10n.sharedShowLess : l10n.sharedShowMore,
                  ),
                ),
              ],
            ),
          ),
          if (widget.showActions) ...[
            const SizedBox(height: 16),
            FormButton(isEditing: widget.isEditing, onSubmitted: _submit),
          ],
        ],
      ),
    );
  }

  Future<void> submit() => _submit();

  TaxonRank? get _rank => taxonRankFromString(widget.ctr.taxonRankCtr);

  bool _shows(TaxonRank rank) => _rank != null && _rank!.index >= rank.index;

  Future<void> _submit() async {
    if (!_isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.projectTaxonRankRequired)),
      );
      return;
    }
    final taxonId = widget.isEditing
        ? await _updateTaxon()
        : await _createTaxon();
    ref.invalidate(taxonRegistryProvider);
    ref.invalidate(taxonProvider);
    if (!mounted) return;
    Navigator.of(context).pop(taxonId);
  }

  bool _isValid() {
    final controller = switch (_rank) {
      TaxonRank.taxonClass => widget.ctr.taxonClassCtr,
      TaxonRank.order => widget.ctr.taxonOrderCtr,
      TaxonRank.family => widget.ctr.taxonFamilyCtr,
      TaxonRank.genus => widget.ctr.genusCtr,
      TaxonRank.species => widget.ctr.specificEpithetCtr,
      TaxonRank.subspecies => widget.ctr.subspecificEpithetCtr,
      null => null,
    };
    return controller?.text.trim().isNotEmpty == true;
  }

  Future<int> _createTaxon() async {
    final taxon = _getForm();
    return TaxonomyServices(ref: ref).createTaxon(taxon);
  }

  Future<int> _updateTaxon() async {
    final taxon = _getForm();
    await TaxonomyServices(ref: ref).updateTaxonEntry(widget.taxonId!, taxon);
    return widget.taxonId!;
  }

  TaxonomyCompanion _getForm() {
    return TaxonomyCompanion(
      taxonRank: db.Value(_rank?.databaseValue),
      kingdom: db.Value(_optional(widget.ctr.kingdomCtr)),
      phylum: db.Value(_optional(widget.ctr.phylumCtr)),
      taxonClass: db.Value(
        _valueThrough(TaxonRank.taxonClass, widget.ctr.taxonClassCtr),
      ),
      taxonOrder: db.Value(
        _valueThrough(TaxonRank.order, widget.ctr.taxonOrderCtr),
      ),
      taxonFamily: db.Value(
        _valueThrough(TaxonRank.family, widget.ctr.taxonFamilyCtr),
      ),
      genus: db.Value(_valueThrough(TaxonRank.genus, widget.ctr.genusCtr)),
      specificEpithet: db.Value(
        _valueThrough(TaxonRank.species, widget.ctr.specificEpithetCtr),
      ),
      subspecificEpithet: db.Value(
        _valueThrough(TaxonRank.subspecies, widget.ctr.subspecificEpithetCtr),
      ),
      authors: db.Value(widget.ctr.authorCtr.text),
      commonName: db.Value(widget.ctr.commonNameCtr.text),
      redListCategory: db.Value(widget.ctr.redListCategoryCtr.text),
      citesStatus: db.Value(widget.ctr.citesCtr.text),
      countryStatus: db.Value(widget.ctr.countryStatusCtr.text),
      sortingOrder: db.Value(int.tryParse(widget.ctr.sortingOrderCtr.text)),
      notes: db.Value(widget.ctr.noteCtr.text),
    );
  }

  String? _valueThrough(TaxonRank rank, TextEditingController controller) {
    return _shows(rank) ? _optional(controller) : null;
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }
}

class _RankTextField extends StatelessWidget {
  const _RankTextField({
    required this.controller,
    required this.label,
    this.lowercase = false,
  });

  final TextEditingController controller;
  final String label;
  final bool lowercase;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: context.l10n.projectTaxonEnterValue(label.toLowerCase()),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z .'-]+")),
      ],
      onChanged: (value) {
        final text = lowercase ? value.toLowerCase() : value.toSentenceCase();
        if (text == controller.text) return;
        controller.value = controller.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      },
    );
  }
}
