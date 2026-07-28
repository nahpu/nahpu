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
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/parasite_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/utility_services.dart';

const parasiteCategories = [
  'Ectoparasite',
  'Endoparasite',
  'Mesoparasite',
  'Parasitoid',
];

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

class NewParasite extends StatelessWidget {
  const NewParasite({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add parasite'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ParasiteRecordForm(
          specimenUuid: specimenUuid,
          parasite: null,
          controller: ParasiteFormCtrModel.empty(),
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
          _ParasiteIdField(controller: widget.controller.parasiteIdCtr),
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
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              hintText: 'Select parasite category',
            ),
            items: parasiteCategories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: CommonDropdownText(text: category),
                  ),
                )
                .toList(),
            onChanged: (value) {
              widget.controller.categoryCtr.text = value ?? '';
            },
          ),
          CommonTextField(
            controller: widget.controller.anatomicalLocationCtr,
            labelText: 'Anatomical location',
            hintText: 'Enter where the parasite was found',
            isLastField: false,
          ),
          const CommonDivider(),
          Text(
            'Collection and identification',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          _IdentifierField(controller: widget.controller),
          CommonTextField(
            controller: widget.controller.detectionMethodCtr,
            labelText: 'Detection method',
            hintText: 'Enter detection method',
            isLastField: false,
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

  String? get _category {
    final value = widget.controller.categoryCtr.text.trim();
    return parasiteCategories.contains(value) ? value : null;
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
      parasiteUuid: const db.Value.absent(),
      count: db.Value(int.tryParse(controller.countCtr.text)),
      preparationMethod: db.Value(_text(controller.preparationMethodCtr)),
      storage: db.Value(_text(controller.storageCtr)),
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
        CommonTextField(
          controller: controller.preparationMethodCtr,
          labelText: 'Preparation method',
          hintText: 'Enter preparation method',
          isLastField: false,
        ),
        CommonTextField(
          controller: controller.storageCtr,
          labelText: 'Storage',
          hintText: 'Enter storage location or medium',
          isLastField: false,
        ),
        CommonTextField(
          controller: controller.treatmentCtr,
          labelText: 'Treatment',
          hintText: 'Enter treatment',
          isLastField: false,
        ),
        CommonTextField(
          controller: controller.lifeStageCtr,
          labelText: 'Life stage',
          hintText: 'Enter life stage',
          isLastField: false,
        ),
        DropdownButtonFormField<int?>(
          initialValue: controller.associationStatus,
          decoration: const InputDecoration(labelText: 'Association status'),
          items: DropDownMenuItems.booleanDropDownItems(),
          onChanged: (value) => controller.associationStatus = value,
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
    );
  }
}

class _ParasiteIdField extends StatefulWidget {
  const _ParasiteIdField({required this.controller});

  final TextEditingController controller;

  @override
  State<_ParasiteIdField> createState() => _ParasiteIdFieldState();
}

class _ParasiteIdFieldState extends State<_ParasiteIdField> {
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
        PopupMenuButton<String>(
          itemBuilder: (_) => [
            if (systemPlatform == PlatformType.mobile)
              PopupMenuItem(
                onTap: _scan,
                child: const ListTile(
                  leading: Icon(Icons.qr_code_scanner_outlined),
                  title: Text('Scan QR/Barcode'),
                ),
              ),
            PopupMenuItem(
              onTap: _generate,
              child: const ListTile(
                leading: Icon(Icons.qr_code_2_outlined),
                title: Text('Generate UUID'),
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
          onDetect: (BarcodeCapture capture) {
            final value = capture.barcodes.firstOrNull?.rawValue;
            if (value != null) widget.controller.text = value;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _generate() {
    if (widget.controller.text.isEmpty) {
      widget.controller.text = uuid;
    }
  }
}

class ParasiteRecordInfoContent extends StatelessWidget {
  const ParasiteRecordInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content:
              'Record parasites found on or within this specimen, '
              'including their taxonomy, location, collection, preservation, '
              'and identification details.',
        ),
      ],
    );
  }
}
