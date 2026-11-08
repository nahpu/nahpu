import 'package:drift/drift.dart' as db;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/projects/taxonomy/new_taxa.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/screens/specimens/shared/individual_selector.dart';
import 'package:nahpu/screens/specimens/shared/specimen_parts.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/services/specimens/symbiont_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/symbionts.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/styles/design_tokens.dart';

class SymbiontForms extends StatelessWidget {
  const SymbiontForms({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleForm(
          text: context.l10n.symbiontRecords,
          infoTopic: InfoTopic.specimenSymbionts,
        ),
        SizedBox(height: 450, child: SymbiontList(specimenUuid: specimenUuid)),
      ],
    );
  }
}

class SymbiontList extends ConsumerStatefulWidget {
  const SymbiontList({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  ConsumerState<SymbiontList> createState() => _SymbiontListState();
}

class _SymbiontListState extends ConsumerState<SymbiontList> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _selected = {};
  bool _isSelecting = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbionts = ref.watch(
      symbiontBySpecimenProvider(widget.specimenUuid),
    );
    final taxa = ref.watch(taxonRegistryProvider);
    return symbionts.when(
      data: (records) => taxa.when(
        data: (taxonRecords) {
          final taxonById = {for (final taxon in taxonRecords) taxon.id: taxon};
          if (records.isEmpty) {
            return _EmptySymbionts(specimenUuid: widget.specimenUuid);
          }
          return Column(
            children: [
              SelectItemsInterface(
                isSelecting: _isSelecting,
                onClearPressed: _selected.isEmpty
                    ? null
                    : () => setState(_selected.clear),
                onSelectAllPressed: () {
                  setState(() {
                    _selected
                      ..clear()
                      ..addAll(
                        records.map((record) => record.id).whereType<int>(),
                      );
                  });
                },
                onSelectPressed: () {
                  setState(() {
                    _isSelecting = !_isSelecting;
                    _selected.clear();
                  });
                },
              ),
              Expanded(
                child: CommonScrollbar(
                  scrollController: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final symbiont = records[index];
                      final taxon = taxonById[symbiont.speciesID];
                      return ListTile(
                        key: ValueKey(symbiont.id),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isSelecting
                                ? ListCheckBox(
                                    isDisabled: false,
                                    value: _selected.contains(symbiont.id),
                                    onChanged: (selected) {
                                      setState(() {
                                        final id = symbiont.id;
                                        if (id == null) return;
                                        selected == true
                                            ? _selected.add(id)
                                            : _selected.remove(id);
                                      });
                                    },
                                  )
                                : SymbiontIcon(
                                    interactionType: symbiont.interactionType,
                                  ),
                          ],
                        ),
                        title: _SymbiontTitle(
                          name: taxon == null
                              ? context.l10n.symbiontUnidentified
                              : getTaxonDisplayName(taxon),
                          count: symbiont.count,
                          symbiontID: symbiont.symbiontID ?? '',
                        ),
                        subtitle: _SymbiontSubtitle(symbiont: symbiont),
                        trailing: _isSelecting
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditSymbiont(symbiont: symbiont),
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _isSelecting
                  ? DeleteItemsButton(
                      selectedItems: _selected.toList(),
                      customIconButtonText: context.l10n.deleteSymbiontsCount(
                        _selected.length,
                      ),
                      customDialogHeader: context.l10n.deleteSymbiontsTitle(
                        _selected.length,
                      ),
                      customDialogText: context.l10n.deleteSymbiontsBody(
                        _selected.length,
                      ),
                      onPressedFunction: _deleteSelected,
                    )
                  : _AddSymbiontButton(specimenUuid: widget.specimenUuid),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text(context.l10n.formsErrorDetail('$error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(context.l10n.formsErrorDetail('$error')),
    );
  }

  Future<void> _deleteSelected() async {
    await SymbiontServices(
      ref: ref,
    ).deleteSymbionts(widget.specimenUuid, _selected.toList());
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _isSelecting = false;
    });
  }
}

class _SymbiontSubtitle extends ConsumerWidget {
  const _SymbiontSubtitle({required this.symbiont});

  final SymbiontData symbiont;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbiontId = symbiont.id;
    final individuals = symbiontId == null
        ? const <SpecimenIndividualData>[]
        : ref.watch(individualsBySymbiontProvider(symbiontId)).asData?.value ??
              const <SpecimenIndividualData>[];
    return Text(
      [
        if (individuals.isNotEmpty)
          context.l10n.symbiontIndividuals(
            individuals.map(individualShortId).join(', '),
          ),
        ?_nonEmpty(symbiont.interactionType),
        if (interactionHasCategory(symbiont.interactionType))
          ?_nonEmpty(symbiont.category),
        ?_nonEmpty(symbiont.anatomicalLocation),
        ?_nonEmpty(symbiont.lifeStage),
        ?_nonEmpty(symbiont.preparationMethod),
      ].join(listTileSeparator),
      style: Theme.of(context).textTheme.bodyMedium,
      overflow: TextOverflow.ellipsis,
    );
  }

  String? _nonEmpty(String? text) => text?.isNotEmpty == true ? text : null;
}

class _SymbiontTitle extends StatelessWidget {
  const _SymbiontTitle({
    required this.name,
    required this.count,
    required this.symbiontID,
  });

  final String name;
  final int? count;
  final String symbiontID;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: TitlePartText(
            text: count == null
                ? name
                : '$name$listTileSeparator'
                      '${context.l10n.symbiontCount('$count')}',
          ),
        ),
        if (symbiontID.isNotEmpty)
          Flexible(child: BarcodeText(barcodeID: symbiontID)),
      ],
    );
  }
}

/// Leading list icon drawn from the symbiont's interaction with its host.
class SymbiontIcon extends StatelessWidget {
  const SymbiontIcon({super.key, required this.interactionType});

  final String? interactionType;

  @override
  Widget build(BuildContext context) {
    return TileSvgIcon(iconPath: matchSymbiontInteractionIcon(interactionType));
  }
}

class _EmptySymbionts extends StatelessWidget {
  const _EmptySymbionts({required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.l10n.symbiontNoneAdded),
        const SizedBox(height: 8),
        _AddSymbiontButton(specimenUuid: specimenUuid),
      ],
    );
  }
}

class _AddSymbiontButton extends StatelessWidget {
  const _AddSymbiontButton({required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NewSymbiont(specimenUuid: specimenUuid),
        ),
      ),
      label: context.l10n.symbiontAdd,
      icon: Icons.add,
    );
  }
}

class NewSymbiont extends ConsumerStatefulWidget {
  const NewSymbiont({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  ConsumerState<NewSymbiont> createState() => _NewSymbiontState();
}

class _NewSymbiontState extends ConsumerState<NewSymbiont> {
  SymbiontFormCtrModel? _controller;

  @override
  void initState() {
    super.initState();
    _loadController();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.symbiontAdd),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: controller == null
            ? const CommonProgressIndicator()
            : SymbiontRecordForm(
                specimenUuid: widget.specimenUuid,
                symbiont: null,
                controller: controller,
              ),
      ),
    );
  }

  Future<void> _loadController() async {
    ({String? collectorId, String? dateCollected}) defaults = (
      collectorId: null,
      dateCollected: null,
    );
    try {
      defaults = await SymbiontServices(
        ref: ref,
      ).getHostDefaults(widget.specimenUuid);
    } catch (_) {
      // Start blank when the host cannot be read.
    }
    if (!mounted) return;
    setState(() {
      _controller = SymbiontFormCtrModel.empty(
        collectorId: defaults.collectorId,
        dateCollected: defaults.dateCollected,
      );
    });
  }
}

class EditSymbiont extends StatelessWidget {
  const EditSymbiont({super.key, required this.symbiont});

  final SymbiontData symbiont;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.symbiontEdit),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SymbiontRecordForm(
          specimenUuid: symbiont.specimenUuid!,
          symbiont: symbiont,
          controller: SymbiontFormCtrModel.fromData(symbiont),
        ),
      ),
    );
  }
}

class SymbiontRecordForm extends ConsumerStatefulWidget {
  const SymbiontRecordForm({
    super.key,
    required this.specimenUuid,
    required this.symbiont,
    required this.controller,
  });

  final String specimenUuid;
  final SymbiontData? symbiont;
  final SymbiontFormCtrModel controller;

  @override
  ConsumerState<SymbiontRecordForm> createState() => _SymbiontRecordFormState();
}

class _SymbiontRecordFormState extends ConsumerState<SymbiontRecordForm> {
  bool _showMore = false;
  final CustomFieldDraftController _customFields = CustomFieldDraftController();

  bool get _isEditing => widget.symbiont != null;

  @override
  void initState() {
    super.initState();
    final symbiontId = widget.symbiont?.id;
    if (symbiontId != null) _loadIndividuals(symbiontId);
    _clearHiddenCategory();
    widget.controller.interactionTypeCtr.addListener(_clearHiddenCategory);
  }

  @override
  void dispose() {
    widget.controller.interactionTypeCtr.removeListener(_clearHiddenCategory);
    _customFields.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      footer: FormButton(isEditing: _isEditing, onSubmitted: _submit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SymbiontIds(
            specimenUuid: widget.specimenUuid,
            symbiontUuid: widget.controller.symbiontUuid,
            symbiontIdController: widget.controller.symbiontIdCtr,
            individualIds: widget.controller.individualIds,
          ),
          FormSection(
            title: context.l10n.symbiontDetails,
            child: Column(
              children: [
                _TaxonField(
                  selectedId: widget.controller.speciesId,
                  onChanged: (value) {
                    setState(() => widget.controller.speciesId = value);
                  },
                ),
                _SymbiontVocabularyField(
                  controller: widget.controller.interactionTypeCtr,
                  prefKey: symbiontInteractionTypePrefKey,
                  labelText: context.l10n.symbiontInteractionType,
                ),
                _InteractionHint(
                  interactionType: widget.controller.interactionTypeCtr,
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.controller.interactionTypeCtr,
                  builder: (context, value, _) => Visibility(
                    visible: interactionHasCategory(value.text),
                    child: _SymbiontVocabularyField(
                      controller: widget.controller.categoryCtr,
                      prefKey: symbiontCategoryPrefKey,
                      labelText: context.l10n.symbiontCategory,
                    ),
                  ),
                ),
                _SymbiontVocabularyField(
                  controller: widget.controller.anatomicalLocationCtr,
                  prefKey: symbiontAnatomicalLocationPrefKey,
                  labelText: context.l10n.symbiontAnatomicalLocation,
                  filterSource: widget.controller.categoryCtr,
                  filter: filterAnatomicalLocations,
                ),
                CommonNumField(
                  controller: widget.controller.countCtr,
                  labelText: context.l10n.symbiontCountLabel,
                  hintText: context.l10n.symbiontCountHint,
                  isLastField: false,
                ),
                _SymbiontLifeStageField(controller: widget.controller),
                _SymbiontAssociationStatusField(controller: widget.controller),
              ],
            ),
          ),
          FormSection(
            title: context.l10n.symbiontCollectionIdentification,
            child: Column(
              children: [
                _SymbiontPersonnelField(
                  initialValue: widget.controller.collectorId,
                  labelText: context.l10n.symbiontCollector,
                  hintText: context.l10n.symbiontCollectorHint,
                  onChanged: (value) => widget.controller.collectorId = value,
                ),
                _SymbiontVocabularyField(
                  controller: widget.controller.detectionMethodCtr,
                  prefKey: symbiontDetectionMethodPrefKey,
                  labelText: context.l10n.symbiontDetectionMethod,
                ),
                CommonDateField(
                  controller: widget.controller.dateCollectedCtr,
                  labelText: context.l10n.symbiontDateCollected,
                  hintText: context.l10n.symbiontDateCollectedHint,
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  onTap: () {},
                  onClear: () {},
                ),
                CommonTimeField(
                  controller: widget.controller.timeCollectedCtr,
                  labelText: context.l10n.symbiontTimeCollected,
                  hintText: context.l10n.symbiontTimeCollectedHint,
                  initialTime: TimeOfDay.now(),
                  onTap: () {},
                  onClear: () {},
                ),
                _SymbiontPersonnelField(
                  initialValue: widget.controller.determinerId,
                  labelText: context.l10n.symbiontDeterminer,
                  hintText: context.l10n.symbiontDeterminerHint,
                  onChanged: (value) => widget.controller.determinerId = value,
                ),
                CommonDateField(
                  controller: widget.controller.dateDeterminedCtr,
                  labelText: context.l10n.symbiontDateDetermined,
                  hintText: context.l10n.symbiontDateDeterminedHint,
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  onTap: () {},
                  onClear: () {},
                ),
                _SymbiontVocabularyField(
                  controller: widget.controller.determinationMethodCtr,
                  prefKey: idMethodPrefKey,
                  labelText: context.l10n.symbiontDeterminationMethod,
                ),
              ],
            ),
          ),
          Visibility(
            visible: _showMore,
            child: _AdvancedSymbiontFields(controller: widget.controller),
          ),
          if (_isEditing)
            CustomFieldForm(
              owner: CustomFieldOwner.symbiont(widget.symbiont!.id!),
              showAll: _showMore,
            )
          else
            CustomFieldDraftForm(
              placement: FieldUISection.symbiont,
              specimenUuid: widget.specimenUuid,
              controller: _customFields,
              showAll: _showMore,
            ),
          ShowMoreButton(
            showMore: _showMore,
            onPressed: () => setState(() => _showMore = !_showMore),
          ),
        ],
      ),
    );
  }

  /// Drops a category the interaction no longer allows, so it neither
  /// filters anatomical locations nor gets saved.
  void _clearHiddenCategory() {
    final controller = widget.controller;
    final category = controller.categoryCtr.text;
    if (category.isEmpty) return;
    if (categoryForInteraction(controller.interactionTypeCtr.text, category) ==
        null) {
      controller.categoryCtr.clear();
    }
  }

  Future<void> _loadIndividuals(int symbiontId) async {
    final ids = await SymbiontServices(
      ref: ref,
    ).getIndividualIdsForSymbiont(symbiontId);
    if (!mounted) return;
    setState(() {
      widget.controller.individualIds
        ..clear()
        ..addAll(ids);
    });
  }

  Future<void> _submit() async {
    final form = _form();
    final services = SymbiontServices(ref: ref);
    final individualIds = widget.controller.individualIds;
    try {
      final database = ref.read(databaseProvider);
      if (_isEditing) {
        final symbiontId = widget.symbiont!.id!;
        await database.transaction(() async {
          await services.updateSymbiont(symbiontId, widget.specimenUuid, form);
          await services.setSymbiontIndividuals(symbiontId, individualIds);
        });
        services.invalidateSymbiontIndividuals(symbiontId);
      } else {
        final id = await database.transaction(() async {
          final id = await services.createSymbiont(widget.specimenUuid, form);
          await services.setSymbiontIndividuals(id, individualIds);
          await ref
              .read(customFieldServiceProvider)
              .setValues(CustomFieldOwner.symbiont(id), _customFields.values);
          return id;
        });
        services.invalidateSymbiontIndividuals(id);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.symbiontSaveError('$error'))),
      );
    }
  }

  SymbiontCompanion _form() {
    final controller = widget.controller;
    return SymbiontCompanion(
      specimenUuid: db.Value(widget.specimenUuid),
      speciesID: db.Value(controller.speciesId),
      determinerID: db.Value(controller.determinerId),
      collectorID: db.Value(controller.collectorId),
      dateDetermined: db.Value(controller.dateDeterminedCtr.date),
      determinationMethod: db.Value(_text(controller.determinationMethodCtr)),
      symbiontID: db.Value(_text(controller.symbiontIdCtr)),
      symbiontUuid: db.Value(controller.symbiontUuid),
      count: db.Value(int.tryParse(controller.countCtr.text)),
      preparationMethod: db.Value(_text(controller.preparationMethodCtr)),
      storage: db.Value(_text(controller.storageCtr)),
      storageLocation: db.Value(_text(controller.storageLocationCtr)),
      treatment: db.Value(_text(controller.treatmentCtr)),
      anatomicalLocation: db.Value(_text(controller.anatomicalLocationCtr)),
      lifeStage: db.Value(_text(controller.lifeStageCtr)),
      category: db.Value(
        categoryForInteraction(
          controller.interactionTypeCtr.text,
          _text(controller.categoryCtr),
        ),
      ),
      interactionType: db.Value(_text(controller.interactionTypeCtr)),
      associationStatus: db.Value(controller.associationStatus),
      detectionMethod: db.Value(_text(controller.detectionMethodCtr)),
      dateCollected: db.Value(controller.dateCollectedCtr.date),
      timeCollected: db.Value(controller.timeCollectedCtr.time),
      datePreserved: db.Value(controller.datePreservedCtr.date),
      timePreserved: db.Value(controller.timePreservedCtr.time),
      museumPermanent: db.Value(_text(controller.museumPermanentCtr)),
      museumLoan: db.Value(_text(controller.museumLoanCtr)),
      remark: db.Value(_text(controller.remarkCtr)),
    );
  }

  String? _text(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }
}

class _TaxonField extends ConsumerWidget {
  const _TaxonField({required this.selectedId, required this.onChanged});

  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ref
              .watch(taxonRegistryProvider)
              .when(
                data: (taxa) => DropdownButtonFormField<int?>(
                  initialValue: taxa.any((taxon) => taxon.id == selectedId)
                      ? selectedId
                      : null,
                  decoration: InputDecoration(
                    labelText: context.l10n.symbiontTaxon,
                    hintText: context.l10n.symbiontTaxonHint,
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: CommonDropdownText(
                        text: context.l10n.symbiontNotIdentified,
                      ),
                    ),
                    ...taxa.map(
                      (taxon) => DropdownMenuItem(
                        value: taxon.id,
                        child: CommonDropdownText(
                          text: getTaxonDisplayName(taxon),
                        ),
                      ),
                    ),
                  ],
                  onChanged: onChanged,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, _) =>
                    Text(context.l10n.symbiontTaxaLoadError('$error')),
              ),
        ),
        IconButton(
          tooltip: context.l10n.symbiontAddTaxon,
          icon: const Icon(Icons.add),
          onPressed: () async {
            final id = await Navigator.of(
              context,
            ).push<int>(MaterialPageRoute(builder: (_) => const NewTaxon()));
            if (id != null) onChanged(id);
          },
        ),
      ],
    );
  }
}

class _SymbiontPersonnelField extends ConsumerWidget {
  const _SymbiontPersonnelField({
    required this.initialValue,
    required this.labelText,
    required this.hintText,
    required this.onChanged,
  });

  final String? initialValue;
  final String labelText;
  final String hintText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(projectPersonnelProvider).asData?.value;
    // Select the stored person only once they appear in the project list.
    // The controller keeps the stored value either way.
    final knownIds = people?.map((person) => person.uuid).toSet() ?? {};
    return DropdownButtonFormField<String?>(
      key: ValueKey('$labelText-${people?.length}'),
      isExpanded: true,
      initialValue: knownIds.contains(initialValue) ? initialValue : null,
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: CommonDropdownText(text: context.l10n.symbiontNotAssigned),
        ),
        ...?people?.map(
          (person) => DropdownMenuItem(
            value: person.uuid,
            child: CommonDropdownText(text: person.name ?? ''),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _AdvancedSymbiontFields extends StatelessWidget {
  const _AdvancedSymbiontFields({required this.controller});

  final SymbiontFormCtrModel controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormSection(
          title: context.l10n.symbiontPreparationPreservation,
          child: Column(
            children: [
              _SymbiontVocabularyField(
                controller: controller.preparationMethodCtr,
                prefKey: symbiontPreparationMethodPrefKey,
                labelText: context.l10n.symbiontPreparationMethod,
              ),
              _SymbiontVocabularyField(
                controller: controller.treatmentCtr,
                prefKey: symbiontTreatmentPrefKey,
                labelText: context.l10n.symbiontTreatment,
              ),
              CommonDateField(
                controller: controller.datePreservedCtr,
                labelText: context.l10n.symbiontDatePreserved,
                hintText: context.l10n.symbiontDatePreservedHint,
                initialDate: DateTime.now(),
                lastDate: DateTime.now(),
                onTap: () {},
                onClear: () {},
              ),
              CommonTimeField(
                controller: controller.timePreservedCtr,
                labelText: context.l10n.symbiontTimePreserved,
                hintText: context.l10n.symbiontTimePreservedHint,
                initialTime: TimeOfDay.now(),
                onTap: () {},
                onClear: () {},
              ),
            ],
          ),
        ),
        FormSection(
          title: context.l10n.symbiontCuration,
          child: Column(
            children: [
              _SymbiontVocabularyField(
                controller: controller.storageCtr,
                prefKey: symbiontStoragePrefKey,
                labelText: context.l10n.symbiontStorage,
              ),
              CommonTextField(
                controller: controller.storageLocationCtr,
                labelText: context.l10n.symbiontStorageLocation,
                hintText: context.l10n.symbiontStorageLocationHint,
                isLastField: false,
              ),
              CommonTextField(
                controller: controller.museumPermanentCtr,
                labelText: context.l10n.symbiontMuseumPermanent,
                hintText: context.l10n.symbiontMuseumHint,
                isLastField: false,
              ),
              CommonTextField(
                controller: controller.museumLoanCtr,
                labelText: context.l10n.symbiontMuseumLoan,
                hintText: context.l10n.symbiontMuseumHint,
                isLastField: false,
              ),
              CommonTextField(
                controller: controller.remarkCtr,
                labelText: context.l10n.symbiontRemarks,
                hintText: context.l10n.symbiontRemarksHint,
                maxLines: 3,
                isLastField: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SymbiontLifeStageField extends StatelessWidget {
  const _SymbiontLifeStageField({required this.controller});

  final SymbiontFormCtrModel controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _currentLifeStage,
      decoration: InputDecoration(
        labelText: context.l10n.symbiontLifeStage,
        hintText: context.l10n.symbiontLifeStageHint,
      ),
      items:
          includeCurrentVocabularyValue(symbiontLifeStages, _currentLifeStage)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: CommonDropdownText(text: value),
                ),
              )
              .toList(),
      onChanged: (value) => controller.lifeStageCtr.text = value ?? '',
    );
  }

  String? get _currentLifeStage {
    final value = controller.lifeStageCtr.text.trim();
    return value.isEmpty ? null : value;
  }
}

class _SymbiontAssociationStatusField extends StatelessWidget {
  const _SymbiontAssociationStatusField({required this.controller});

  final SymbiontFormCtrModel controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      isExpanded: true,
      initialValue: controller.associationStatus,
      decoration: InputDecoration(
        labelText: context.l10n.symbiontAssociationStatus,
        hintText: context.l10n.symbiontAssociationStatusHint,
      ),
      items: [
        DropDownMenuItems.chooseOneListItem,
        ...symbiontAssociationStatuses.entries.map(
          (entry) => DropdownMenuItem<int?>(
            value: entry.key,
            child: CommonDropdownText(text: entry.value),
          ),
        ),
      ],
      onChanged: (value) => controller.associationStatus = value,
    );
  }
}

/// One-line definition of the selected interaction type. Empty for custom
/// values.
class _InteractionHint extends StatelessWidget {
  const _InteractionHint({required this.interactionType});

  final ValueListenable<TextEditingValue> interactionType;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: interactionType,
      builder: (context, value, _) {
        final hint = _hint(context.l10n, value.text);
        if (hint == null) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }

  String? _hint(AppLocalizations l10n, String interactionType) {
    return switch (resolveSymbiontInteraction(interactionType)) {
      'parasitic' => l10n.symbiontInteractionParasiticHint,
      'parasitoid' => l10n.symbiontInteractionParasitoidHint,
      'mutualistic' => l10n.symbiontInteractionMutualisticHint,
      'commensal' => l10n.symbiontInteractionCommensalHint,
      'phoretic' => l10n.symbiontInteractionPhoreticHint,
      'unknown' => l10n.symbiontInteractionUnknownHint,
      _ => null,
    };
  }
}

class _SymbiontVocabularyField extends ConsumerWidget {
  const _SymbiontVocabularyField({
    required this.controller,
    required this.prefKey,
    required this.labelText,
    this.filterSource,
    this.filter,
  });

  final TextEditingController controller;
  final String prefKey;
  final String labelText;

  /// Rebuilds the options whenever this source changes, passing its text to
  /// [filter].
  final ValueListenable<TextEditingValue>? filterSource;
  final List<String> Function(List<String> options, String? source)? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(effectiveUserDefinedFieldProvider(prefKey))
        .when(
          data: (configured) {
            final source = filterSource;
            final applyFilter = filter;
            if (source == null || applyFilter == null) {
              return _VocabularyDropdown(
                controller: controller,
                labelText: labelText,
                available: configured,
              );
            }
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: source,
              builder: (context, value, _) => _VocabularyDropdown(
                controller: controller,
                labelText: labelText,
                available: applyFilter(configured, value.text),
              ),
            );
          },
          loading: () => const CommonProgressIndicator(),
          error: (error, _) =>
              Text(context.l10n.symbiontFieldLoadError(labelText, '$error')),
        );
  }
}

class _VocabularyDropdown extends StatelessWidget {
  const _VocabularyDropdown({
    required this.controller,
    required this.labelText,
    required this.available,
  });

  final TextEditingController controller;
  final String labelText;
  final List<String> available;

  @override
  Widget build(BuildContext context) {
    final current = controller.text.trim();
    final options = includeCurrentVocabularyValue(
      available,
      current.isEmpty ? null : current,
    );
    return DropdownButtonFormField<String>(
      key: ValueKey(options.join('\u0000')),
      isExpanded: true,
      initialValue: current.isEmpty ? null : current,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: options.isEmpty
            ? context.l10n.symbiontSetOptionsInSettings
            : context.l10n.symbiontSelectField(labelText.toLowerCase()),
      ),
      items: options
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: CommonDropdownText(text: value),
            ),
          )
          .toList(),
      onChanged: options.isEmpty
          ? null
          : (value) => controller.text = value ?? '',
    );
  }
}

class _SymbiontIds extends StatelessWidget {
  const _SymbiontIds({
    required this.specimenUuid,
    required this.symbiontUuid,
    required this.symbiontIdController,
    required this.individualIds,
  });

  final String specimenUuid;
  final String symbiontUuid;
  final TextEditingController symbiontIdController;
  final Set<int> individualIds;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 4, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.symbiontIds,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SelectableText(context.l10n.symbiontUuid(symbiontUuid)),
            _SymbiontIdField(controller: symbiontIdController),
            SpecimenIndividualSelector(
              specimenUuid: specimenUuid,
              selectedIds: individualIds,
            ),
          ],
        ),
      ),
    );
  }
}

class _SymbiontIdField extends ConsumerStatefulWidget {
  const _SymbiontIdField({required this.controller});

  final TextEditingController controller;

  @override
  ConsumerState<_SymbiontIdField> createState() => _SymbiontIdFieldState();
}

class _SymbiontIdFieldState extends ConsumerState<_SymbiontIdField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CommonTextField(
            controller: widget.controller,
            labelText: context.l10n.symbiontId,
            hintText: context.l10n.symbiontIdHint,
            isLastField: false,
          ),
        ),
        AdaptiveMenuButton<_SymbiontIdAction>(
          tooltip: context.l10n.symbiontIdOptions,
          onSelected: _handleAction,
          itemBuilder: () => [
            if (supportsCameraScanning)
              AdaptiveMenuItem(
                value: _SymbiontIdAction.scan,
                icon: Icons.qr_code_scanner_outlined,
                label: context.l10n.symbiontScanCode,
              ),
            AdaptiveMenuItem(
              value: _SymbiontIdAction.newNumber,
              icon: Icons.add,
              label: context.l10n.symbiontNewNumber,
              enabled: widget.controller.text.isEmpty,
            ),
            AdaptiveMenuItem(
              value: _SymbiontIdAction.settings,
              icon: Icons.settings_outlined,
              label: context.l10n.symbiontSettings,
              hasDividerBefore: true,
            ),
          ],
        ),
      ],
    );
  }

  void _scan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScannerScreen(
          supportedModes: const {ScannerMode.qr, ScannerMode.barcode},
          onDetect: (BarcodeCapture capture) {
            final value = capture.barcodes.firstOrNull?.rawValue;
            if (value != null) widget.controller.text = value;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _handleAction(_SymbiontIdAction action) async {
    switch (action) {
      case _SymbiontIdAction.scan:
        _scan();
      case _SymbiontIdAction.newNumber:
        widget.controller.text = await const SymbiontIdServices()
            .getNewNumber();
        if (mounted) setState(() {});
      case _SymbiontIdAction.settings:
        await _showSettings();
    }
  }

  Future<void> _showSettings() async {
    const services = SymbiontIdServices();
    final prefixController = TextEditingController(
      text: await services.getPrefix(),
    );
    final numberController = TextEditingController(
      text: await services.getNumberString(),
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.symbiontIdSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonTextField(
              controller: prefixController,
              labelText: context.l10n.symbiontPrefix,
              hintText: context.l10n.symbiontPrefixHint,
              isLastField: false,
            ),
            CommonNumField(
              controller: numberController,
              labelText: context.l10n.symbiontNumber,
              hintText: context.l10n.symbiontNumberHint,
              isLastField: true,
            ),
          ],
        ),
        actions: [
          SecondaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            text: context.l10n.commonCancel,
          ),
          PrimaryButton(
            onPressed: () async {
              await services.setPrefix(prefixController.text);
              await services.setNumber(numberController.text);
              if (widget.controller.text.isEmpty) {
                widget.controller.text = await services.getNewNumber();
              }
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (mounted) setState(() {});
            },
            label: context.l10n.commonSave,
            icon: Icons.save_alt_outlined,
          ),
        ],
      ),
    );
    prefixController.dispose();
    numberController.dispose();
  }
}

enum _SymbiontIdAction { scan, newNumber, settings }
