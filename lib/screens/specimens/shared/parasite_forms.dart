import 'package:drift/drift.dart' as db;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/projects/taxonomy/new_taxa.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/parasite_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/common/utility_services.dart';

class ParasiteForms extends StatelessWidget {
  const ParasiteForms({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleForm(
          text: 'Parasite records',
          infoContent: ParasiteRecordInfoContent(),
        ),
        SizedBox(height: 450, child: ParasiteList(specimenUuid: specimenUuid)),
      ],
    );
  }
}

class ParasiteList extends ConsumerStatefulWidget {
  const ParasiteList({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  ConsumerState<ParasiteList> createState() => _ParasiteListState();
}

class _ParasiteListState extends ConsumerState<ParasiteList> {
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
    final parasites = ref.watch(
      parasiteBySpecimenProvider(widget.specimenUuid),
    );
    final taxa = ref.watch(taxonRegistryProvider);
    return parasites.when(
      data: (records) => taxa.when(
        data: (taxonRecords) {
          final taxonById = {for (final taxon in taxonRecords) taxon.id: taxon};
          if (records.isEmpty) {
            return _EmptyParasites(specimenUuid: widget.specimenUuid);
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
                      final parasite = records[index];
                      final taxon = taxonById[parasite.speciesID];
                      return ListTile(
                        leading: _isSelecting
                            ? ListCheckBox(
                                isDisabled: false,
                                value: _selected.contains(parasite.id),
                                onChanged: (selected) {
                                  setState(() {
                                    final id = parasite.id;
                                    if (id == null) return;
                                    selected == true
                                        ? _selected.add(id)
                                        : _selected.remove(id);
                                  });
                                },
                              )
                            : const Icon(Icons.bug_report_outlined),
                        title: Text(
                          taxon == null
                              ? parasite.category ?? 'Unidentified parasite'
                              : getTaxonDisplayName(taxon),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          [
                            if (parasite.parasiteID?.isNotEmpty == true)
                              parasite.parasiteID!,
                            if (parasite.category?.isNotEmpty == true)
                              parasite.category!,
                            if (parasite.anatomicalLocation?.isNotEmpty == true)
                              parasite.anatomicalLocation!,
                            if (parasite.count != null)
                              'Count: ${parasite.count}',
                          ].join(listTileSeparator),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _isSelecting
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditParasite(parasite: parasite),
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
                      itemName: _selected.length == 1
                          ? 'parasite'
                          : 'parasites',
                      onPressedFunction: _deleteSelected,
                    )
                  : _AddParasiteButton(specimenUuid: widget.specimenUuid),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Error: $error'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Future<void> _deleteSelected() async {
    await ParasiteServices(
      ref: ref,
    ).deleteParasites(widget.specimenUuid, _selected.toList());
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _isSelecting = false;
    });
  }
}

class _EmptyParasites extends StatelessWidget {
  const _EmptyParasites({required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No parasites added'),
        const SizedBox(height: 8),
        _AddParasiteButton(specimenUuid: specimenUuid),
      ],
    );
  }
}

class _AddParasiteButton extends StatelessWidget {
  const _AddParasiteButton({required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NewParasite(specimenUuid: specimenUuid),
        ),
      ),
      label: 'Add parasite',
      icon: Icons.add,
    );
  }
}

class NewParasite extends StatefulWidget {
  const NewParasite({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  State<NewParasite> createState() => _NewParasiteState();
}

class _NewParasiteState extends State<NewParasite> {
  late final ParasiteFormCtrModel _controller;

  @override
  void initState() {
    super.initState();
    _controller = ParasiteFormCtrModel.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add parasite'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ParasiteRecordForm(
          specimenUuid: widget.specimenUuid,
          parasite: null,
          controller: _controller,
        ),
      ),
    );
  }
}

class EditParasite extends StatelessWidget {
  const EditParasite({super.key, required this.parasite});

  final ParasiteData parasite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit parasite'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ParasiteRecordForm(
          specimenUuid: parasite.specimenUuid!,
          parasite: parasite,
          controller: ParasiteFormCtrModel.fromData(parasite),
        ),
      ),
    );
  }
}

class ParasiteRecordForm extends ConsumerStatefulWidget {
  const ParasiteRecordForm({
    super.key,
    required this.specimenUuid,
    required this.parasite,
    required this.controller,
  });

  final String specimenUuid;
  final ParasiteData? parasite;
  final ParasiteFormCtrModel controller;

  @override
  ConsumerState<ParasiteRecordForm> createState() => _ParasiteRecordFormState();
}

class _ParasiteRecordFormState extends ConsumerState<ParasiteRecordForm> {
  bool _showMore = false;

  bool get _isEditing => widget.parasite != null;

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ParasiteIds(
            parasiteUuid: widget.controller.parasiteUuid,
            parasiteIdController: widget.controller.parasiteIdCtr,
          ),
          FormSection(
            title: 'Parasite details',
            child: Column(
              children: [
                _TaxonField(
                  selectedId: widget.controller.speciesId,
                  onChanged: (value) {
                    setState(() => widget.controller.speciesId = value);
                  },
                ),
                CommonNumField(
                  controller: widget.controller.countCtr,
                  labelText: 'Count',
                  hintText: 'Enter parasite count',
                  isLastField: false,
                ),
                _ParasiteVocabularyField(
                  controller: widget.controller.categoryCtr,
                  prefKey: parasiteCategoryPrefKey,
                  labelText: 'Category',
                ),
                _ParasiteVocabularyField(
                  controller: widget.controller.anatomicalLocationCtr,
                  prefKey: parasiteAnatomicalLocationPrefKey,
                  labelText: 'Anatomical location',
                ),
                Visibility(
                  visible: _showMore,
                  child: _AdvancedParasiteDetailsFields(
                    controller: widget.controller,
                  ),
                ),
              ],
            ),
          ),
          FormSection(
            title: 'Collection & identification',
            child: Column(
              children: [
                _IdentifierField(controller: widget.controller),
                _ParasiteVocabularyField(
                  controller: widget.controller.detectionMethodCtr,
                  prefKey: parasiteDetectionMethodPrefKey,
                  labelText: 'Detection method',
                ),
                CommonDateField(
                  controller: widget.controller.dateCollectedCtr,
                  labelText: 'Date collected',
                  hintText: 'Enter collection date',
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  onTap: () {},
                  onClear: () {},
                ),
                CommonTimeField(
                  controller: widget.controller.timeCollectedCtr,
                  labelText: 'Time collected',
                  hintText: 'Enter collection time',
                  initialTime: TimeOfDay.now(),
                  onTap: () {},
                  onClear: () {},
                ),
              ],
            ),
          ),
          Visibility(
            visible: _showMore,
            child: _AdvancedParasiteFields(controller: widget.controller),
          ),
          ShowMoreButton(
            showMore: _showMore,
            onPressed: () => setState(() => _showMore = !_showMore),
          ),
          const SizedBox(height: 16),
          FormButton(isEditing: _isEditing, onSubmitted: _submit),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final form = _form();
    try {
      if (_isEditing) {
        await ParasiteServices(
          ref: ref,
        ).updateParasite(widget.parasite!.id!, widget.specimenUuid, form);
      } else {
        await ParasiteServices(
          ref: ref,
        ).createParasite(widget.specimenUuid, form);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save parasite: $error')),
      );
    }
  }

  ParasiteCompanion _form() {
    final controller = widget.controller;
    return ParasiteCompanion(
      specimenUuid: db.Value(widget.specimenUuid),
      speciesID: db.Value(controller.speciesId),
      identifierID: db.Value(controller.identifierId),
      parasiteID: db.Value(_text(controller.parasiteIdCtr)),
      parasiteUuid: db.Value(controller.parasiteUuid),
      count: db.Value(int.tryParse(controller.countCtr.text)),
      preparationMethod: db.Value(_text(controller.preparationMethodCtr)),
      storage: db.Value(_text(controller.storageCtr)),
      storageLocation: db.Value(_text(controller.storageLocationCtr)),
      treatment: db.Value(_text(controller.treatmentCtr)),
      anatomicalLocation: db.Value(_text(controller.anatomicalLocationCtr)),
      lifeStage: db.Value(_text(controller.lifeStageCtr)),
      category: db.Value(_text(controller.categoryCtr)),
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
                  decoration: const InputDecoration(
                    labelText: 'Parasite taxon',
                    hintText: 'Select a registered taxon',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: CommonDropdownText(text: 'Not identified'),
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
                error: (error, _) => Text('Unable to load taxa: $error'),
              ),
        ),
        IconButton(
          tooltip: 'Add taxon',
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

class _IdentifierField extends ConsumerWidget {
  const _IdentifierField({required this.controller});

  final ParasiteFormCtrModel controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonFormField<String?>(
      isExpanded: true,
      initialValue: controller.identifierId,
      decoration: const InputDecoration(
        labelText: 'Identifier',
        hintText: 'Select who identified the parasite',
      ),
      items: ref
          .watch(projectPersonnelProvider)
          .when(
            data: (people) => [
              const DropdownMenuItem<String?>(
                value: null,
                child: CommonDropdownText(text: 'Not assigned'),
              ),
              ...people.map(
                (person) => DropdownMenuItem(
                  value: person.uuid,
                  child: CommonDropdownText(text: person.name ?? ''),
                ),
              ),
            ],
            loading: () => const [],
            error: (_, _) => const [],
          ),
      onChanged: (value) => controller.identifierId = value,
    );
  }
}

class _AdvancedParasiteFields extends StatelessWidget {
  const _AdvancedParasiteFields({required this.controller});

  final ParasiteFormCtrModel controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormSection(
          title: 'Preparation & preservation',
          child: Column(
            children: [
              _ParasiteVocabularyField(
                controller: controller.preparationMethodCtr,
                prefKey: parasitePreparationMethodPrefKey,
                labelText: 'Preparation method',
              ),
              _ParasiteVocabularyField(
                controller: controller.treatmentCtr,
                prefKey: parasiteTreatmentPrefKey,
                labelText: 'Treatment',
              ),
              CommonDateField(
                controller: controller.datePreservedCtr,
                labelText: 'Date preserved',
                hintText: 'Enter preservation date',
                initialDate: DateTime.now(),
                lastDate: DateTime.now(),
                onTap: () {},
                onClear: () {},
              ),
              CommonTimeField(
                controller: controller.timePreservedCtr,
                labelText: 'Time preserved',
                hintText: 'Enter preservation time',
                initialTime: TimeOfDay.now(),
                onTap: () {},
                onClear: () {},
              ),
            ],
          ),
        ),
        FormSection(
          title: 'Curation',
          child: Column(
            children: [
              _ParasiteVocabularyField(
                controller: controller.storageCtr,
                prefKey: parasiteStoragePrefKey,
                labelText: 'Storage',
              ),
              CommonTextField(
                controller: controller.storageLocationCtr,
                labelText: 'Storage location',
                hintText: 'Enter freezer, cabinet, shelf, or container',
                isLastField: false,
              ),
              CommonTextField(
                controller: controller.museumPermanentCtr,
                labelText: 'Museum permanent',
                hintText: 'Enter museum name or abbreviation',
                isLastField: false,
              ),
              CommonTextField(
                controller: controller.museumLoanCtr,
                labelText: 'Museum loan',
                hintText: 'Enter museum name or abbreviation',
                isLastField: false,
              ),
              CommonTextField(
                controller: controller.remarkCtr,
                labelText: 'Remarks',
                hintText: 'Enter parasite remarks',
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

class _AdvancedParasiteDetailsFields extends StatelessWidget {
  const _AdvancedParasiteDetailsFields({required this.controller});

  final ParasiteFormCtrModel controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _currentLifeStage,
          decoration: const InputDecoration(
            labelText: 'Life stage',
            hintText: 'Select parasite life stage',
          ),
          items:
              includeCurrentVocabularyValue(
                    parasiteLifeStages,
                    _currentLifeStage,
                  )
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: CommonDropdownText(text: value),
                    ),
                  )
                  .toList(),
          onChanged: (value) => controller.lifeStageCtr.text = value ?? '',
        ),
        DropdownButtonFormField<int?>(
          isExpanded: true,
          initialValue: controller.associationStatus,
          decoration: const InputDecoration(
            labelText: 'Association status',
            hintText: 'Select association status',
          ),
          items: [
            DropDownMenuItems.chooseOneListItem,
            ...parasiteAssociationStatuses.entries.map(
              (entry) => DropdownMenuItem<int?>(
                value: entry.key,
                child: CommonDropdownText(text: entry.value),
              ),
            ),
          ],
          onChanged: (value) => controller.associationStatus = value,
        ),
      ],
    );
  }

  String? get _currentLifeStage {
    final value = controller.lifeStageCtr.text.trim();
    return value.isEmpty ? null : value;
  }
}

class _ParasiteVocabularyField extends ConsumerWidget {
  const _ParasiteVocabularyField({
    required this.controller,
    required this.prefKey,
    required this.labelText,
  });

  final TextEditingController controller;
  final String prefKey;
  final String labelText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(effectiveUserDefinedFieldProvider(prefKey))
        .when(
          data: (configured) {
            final current = controller.text.trim();
            final options = includeCurrentVocabularyValue(
              configured,
              current.isEmpty ? null : current,
            );
            return DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: current.isEmpty ? null : current,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: options.isEmpty
                    ? 'Set options in Specimen settings'
                    : 'Select ${labelText.toLowerCase()}',
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
          },
          loading: () => const CommonProgressIndicator(),
          error: (error, _) => Text('Unable to load $labelText: $error'),
        );
  }
}

class _ParasiteIds extends StatelessWidget {
  const _ParasiteIds({
    required this.parasiteUuid,
    required this.parasiteIdController,
  });

  final String parasiteUuid;
  final TextEditingController parasiteIdController;

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
            Text('IDs', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SelectableText('UUID: $parasiteUuid'),
            _ParasiteIdField(controller: parasiteIdController),
          ],
        ),
      ),
    );
  }
}

class _ParasiteIdField extends ConsumerStatefulWidget {
  const _ParasiteIdField({required this.controller});

  final TextEditingController controller;

  @override
  ConsumerState<_ParasiteIdField> createState() => _ParasiteIdFieldState();
}

class _ParasiteIdFieldState extends ConsumerState<_ParasiteIdField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CommonTextField(
            controller: widget.controller,
            labelText: 'Parasite ID',
            hintText: 'Enter a user-defined parasite ID',
            isLastField: false,
          ),
        ),
        PopupMenuButton<_ParasiteIdAction>(
          onSelected: _handleAction,
          itemBuilder: (_) => [
            if (systemPlatform == PlatformType.mobile)
              const PopupMenuItem(
                value: _ParasiteIdAction.scan,
                child: ListTile(
                  leading: Icon(Icons.qr_code_scanner_outlined),
                  title: Text('Scan QR/Barcode'),
                ),
              ),
            PopupMenuItem(
              value: _ParasiteIdAction.newNumber,
              enabled: widget.controller.text.isEmpty,
              child: const ListTile(
                leading: Icon(Icons.add),
                title: Text('New number'),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _ParasiteIdAction.settings,
              child: ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings'),
              ),
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

  Future<void> _handleAction(_ParasiteIdAction action) async {
    switch (action) {
      case _ParasiteIdAction.scan:
        _scan();
      case _ParasiteIdAction.newNumber:
        widget.controller.text = await const ParasiteIdServices()
            .getNewNumber();
        if (mounted) setState(() {});
      case _ParasiteIdAction.settings:
        await _showSettings();
    }
  }

  Future<void> _showSettings() async {
    const services = ParasiteIdServices();
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
        title: const Text('Parasite ID settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonTextField(
              controller: prefixController,
              labelText: 'Prefix',
              hintText: 'Enter parasite ID prefix',
              isLastField: false,
            ),
            CommonNumField(
              controller: numberController,
              labelText: 'Number',
              hintText: 'Enter the next parasite ID number',
              isLastField: true,
            ),
          ],
        ),
        actions: [
          SecondaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            text: 'Cancel',
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
            label: 'Save',
            icon: Icons.save_alt_outlined,
          ),
        ],
      ),
    );
    prefixController.dispose();
    numberController.dispose();
  }
}

enum _ParasiteIdAction { scan, newNumber, settings }

class ParasiteRecordInfoContent extends StatelessWidget {
  const ParasiteRecordInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content:
              'Record parasites collected from the specimen, '
              'including their taxonomy, location, collection, preservation, '
              'and identification details.',
        ),
      ],
    );
  }
}
