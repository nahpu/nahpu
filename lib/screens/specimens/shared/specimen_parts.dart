import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/screens/specimens/shared/parasite_forms.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/forms/numbered_id_fields.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/specimens/shared/associated_data.dart';
import 'package:nahpu/screens/specimens/shared/individual_selector.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/localization/l10n.dart';

class PartDataForm extends ConsumerStatefulWidget {
  const PartDataForm({
    super.key,
    required this.specimenUuid,
    required this.catalogFmt,
  });

  final String specimenUuid;
  final CatalogFmt catalogFmt;

  @override
  PartDataFormState createState() => PartDataFormState();
}

class PartDataFormState extends ConsumerState<PartDataForm>
    with TickerProviderStateMixin {
  late TabController _tabController;

  int get _length => supportsParasites(widget.catalogFmt) ? 3 : 2;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant PartDataForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (supportsParasites(oldWidget.catalogFmt) !=
        supportsParasites(widget.catalogFmt)) {
      _tabController.dispose();
      _tabController = TabController(length: _length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormCard(
      isWithTitle: false,
      infoTopic: InfoTopic.specimenParts,
      isWithSidePadding: false,
      child: CommonTabBars(
        tabController: _tabController,
        length: _length,
        height: 502,
        tabs: [
          Tab(
            icon: Icon(
              matchCatFmtToIcon(widget.catalogFmt, isFilledIcon: true),
            ),
          ),
          if (supportsParasites(widget.catalogFmt))
            const Tab(icon: Icon(Icons.bug_report_outlined)),
          Tab(icon: Icon(Icons.storage_rounded)),
        ],
        children: [
          SpecimenPartFields(
            specimenUuid: widget.specimenUuid,
            catalogFmt: widget.catalogFmt,
          ),
          if (supportsParasites(widget.catalogFmt))
            ParasiteForms(specimenUuid: widget.specimenUuid),
          AssociatedDataViewer(
            target: AssociatedDataTarget.specimen(widget.specimenUuid),
          ),
        ],
      ),
    );
  }
}

class SpecimenPartFields extends StatelessWidget {
  const SpecimenPartFields({
    super.key,
    required this.specimenUuid,
    required this.catalogFmt,
  });

  final String specimenUuid;
  final CatalogFmt catalogFmt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleForm(
          text: context.l10n.partSpecimenParts,
          infoTopic: InfoTopic.specimenParts,
        ),
        SizedBox(
          height: 450,
          child: PartList(specimenUuid: specimenUuid, catalogFmt: catalogFmt),
        ),
      ],
    );
  }
}

class PartList extends ConsumerStatefulWidget {
  const PartList({
    super.key,
    required this.specimenUuid,
    required this.catalogFmt,
  });

  final String specimenUuid;
  final CatalogFmt catalogFmt;

  @override
  PartListState createState() => PartListState();
}

class PartListState extends ConsumerState<PartList> {
  final ScrollController _scrollController = ScrollController();
  bool _isSelecting = false;
  final List<int> _selectedparts = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specimenPartList = ref.watch(
      partBySpecimenProvider(widget.specimenUuid),
    );
    // Resolved once for the whole list. Looking each preparator up from the row
    // fired a personnel query per row on every rebuild, including while
    // scrolling.
    final preparatorNames = ref
        .watch(projectPersonnelProvider)
        .maybeWhen(
          data: (personnel) => {
            for (final person in personnel) person.uuid: person.name ?? '',
          },
          orElse: () => const <String, String>{},
        );
    return specimenPartList.when(
      data: (data) {
        return data.isEmpty
            ? EmptyPart(specimenUuid: widget.specimenUuid)
            : Column(
                children: [
                  SelectItemsInterface(
                    isSelecting: _isSelecting,
                    onClearPressed: _selectedparts.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _selectedparts.clear();
                            });
                          },
                    onSelectAllPressed: () {
                      setState(() {
                        _selectedparts.clear();
                        _selectedparts.addAll(
                          data
                              .where((e) => e.id != null)
                              .map((e) => e.id!)
                              .toList(),
                        );
                      });
                    },
                    onSelectPressed: () {
                      setState(() {
                        _isSelecting = !_isSelecting;
                        _selectedparts.clear();
                      });
                    },
                  ),
                  Flexible(
                    child: CommonScrollbar(
                      scrollController: _scrollController,
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final part = data[index];
                          return ListTile(
                            key: ValueKey(part.id),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                !_isSelecting
                                    ? PartIcon(
                                        partType: part.type ?? 'unknown',
                                        catalogFmt: widget.catalogFmt,
                                      )
                                    : ListCheckBox(
                                        isDisabled: false,
                                        value: _selectedparts.contains(part.id),
                                        onChanged: (bool? value) {
                                          if (part.id != null) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedparts.add(part.id!);
                                              } else {
                                                _selectedparts.remove(part.id);
                                              }
                                            });
                                          }
                                        },
                                      ),
                              ],
                            ),
                            title: PartTitle(
                              partType: part.type,
                              partCount: part.count,
                              barcodeID: part.barcodeID ?? '',
                              preparator: part.personnelId == null
                                  ? null
                                  : preparatorNames[part.personnelId],
                            ),
                            subtitle: PartSubTitle(part: part),
                            trailing: !_isSelecting
                                ? IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditPart(
                                            specimenUuid: widget.specimenUuid,
                                            specimenPartId: part.id,
                                            partCtr: PartFormCtrModel.fromData(
                                              part,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  !_isSelecting
                      ? AddPartButton(specimenUuid: widget.specimenUuid)
                      : DeleteItemsButton(
                          selectedItems: _selectedparts,
                          customIconButtonText: context.l10n
                              .deleteSpecimenPartsCount(_selectedparts.length),
                          customDialogHeader: context.l10n
                              .deleteSpecimenPartsTitle(_selectedparts.length),
                          customDialogText: context.l10n
                              .deleteSpecimenPartsBody(_selectedparts.length),
                          onPressedFunction: () async {
                            await _deleteParts();
                            setState(() {
                              _selectedparts.clear();
                            });
                          },
                        ),
                ],
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text(context.l10n.formsErrorDetail('$err')),
    );
  }

  Future<void> _deleteParts() async {
    try {
      await SpecimenServices(
        ref: ref,
      ).deleteSpecimenPartsFromList(_selectedparts);
      setState(() {
        _isSelecting = false;
      });
      if (context.mounted) {
        _pop();
      }
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 10)),
    );
  }
}

class AddPartButton extends StatelessWidget {
  const AddPartButton({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewPart(specimenUuid: specimenUuid),
          ),
        );
      },
      label: context.l10n.partAdd,
      icon: Icons.add,
    );
  }
}

class EmptyPart extends StatelessWidget {
  const EmptyPart({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.l10n.partNoneAdded),
        const SizedBox(height: 8),
        AddPartButton(specimenUuid: specimenUuid),
      ],
    );
  }
}

class PartIcon extends ConsumerWidget {
  const PartIcon({super.key, required this.partType, required this.catalogFmt});

  final String partType;
  final CatalogFmt catalogFmt;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TileSvgIcon(iconPath: _iconPath);
  }

  String get _iconPath {
    return SpecimenPartIcon(part: partType, catalogFmt: catalogFmt).match();
  }
}

class PartTitle extends StatelessWidget {
  const PartTitle({
    super.key,
    required this.partType,
    required this.partCount,
    required this.barcodeID,
    required this.preparator,
  });

  final String? partType;
  final String? partCount;
  final String barcodeID;

  /// The preparator's name, already resolved by the list.
  final String? preparator;

  @override
  Widget build(BuildContext context) {
    final name = preparator;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: TitlePartText(
            text: name == null || name.isEmpty
                ? _partText(context.l10n)
                : '${_partText(context.l10n)}$listTileSeparator$name',
          ),
        ),
        if (barcodeID.isNotEmpty)
          Flexible(child: BarcodeText(barcodeID: barcodeID)),
      ],
    );
  }

  String _partText(AppLocalizations l10n) {
    final count = partCount;
    return '${partType ?? l10n.partUnknown}'
        '$listTileSeparator'
        '${count == null || count.isEmpty ? l10n.partNoCount : count}';
  }
}

class TitlePartText extends StatelessWidget {
  const TitlePartText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class BarcodeText extends StatelessWidget {
  const BarcodeText({super.key, required this.barcodeID});

  final String? barcodeID;

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          WidgetSpan(
            child: TileIcon(icon: Icons.abc),
            alignment: PlaceholderAlignment.middle,
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: barcodeIDText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String get barcodeIDText {
    if (barcodeID == null) {
      return '';
    } else if (barcodeID!.isEmpty) {
      return '';
    } else {
      return '$barcodeID';
    }
  }
}

class PartSubTitle extends ConsumerWidget {
  const PartSubTitle({super.key, required this.part});

  final SpecimenPartData part;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partId = part.id;
    final individuals = partId == null
        ? const <SpecimenIndividualData>[]
        : ref.watch(individualsByPartProvider(partId)).asData?.value ??
              const <SpecimenIndividualData>[];
    return Text(
      '${_individualText(context.l10n, individuals)}'
      '${_getTextFirst(part.tissueID)}'
      '${_treatment(context.l10n)}'
      '${_getText(part.additionalTreatment)}'
      '${_getText(dateStdToDateDisplay(part.dateTaken))}'
      '${_getText(timeStdToTimeDisplay(part.timeTaken))}'
      '${_getPMI(context.l10n)}'
      '${_remark(context.l10n)}',
      style: Theme.of(context).textTheme.bodyMedium,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _individualText(
    AppLocalizations l10n,
    List<SpecimenIndividualData> individuals,
  ) {
    if (individuals.isEmpty) return '';
    return '${l10n.parasiteIndividuals(individuals.map(individualShortId).join(', '))}'
        '$listTileSeparator';
  }

  String _getTextFirst(String? text) {
    if (text == null) {
      return '';
    } else if (text.isEmpty) {
      return '';
    } else {
      return '$text$listTileSeparator';
    }
  }

  String _treatment(AppLocalizations l10n) {
    if (part.treatment == null) {
      return l10n.partNoTreatment;
    } else if (part.treatment!.isEmpty) {
      return l10n.partNoTreatment;
    } else {
      return '${part.treatment}';
    }
  }

  String _getPMI(AppLocalizations l10n) {
    if (part.pmi == null) {
      return '';
    } else if (part.pmi!.isEmpty) {
      return '';
    } else {
      return '$listTileSeparator${l10n.partPmi(part.pmi!)}';
    }
  }

  String _getText(String? text) {
    if (text == null) {
      return '';
    } else if (text.isEmpty) {
      return '';
    } else {
      return '$listTileSeparator$text';
    }
  }

  String _remark(AppLocalizations l10n) {
    if (part.remark == null) {
      return '';
    } else if (part.remark!.isEmpty) {
      return '';
    } else {
      return '$listTileSeparator${l10n.partHasRemark}';
    }
  }
}

class NewPart extends StatelessWidget {
  const NewPart({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    final PartFormCtrModel partCtr = PartFormCtrModel.empty();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.partAddParts),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: PartForm(
          specimenUuid: specimenUuid,
          specimenPartId: null,
          partCtr: partCtr,
        ),
      ),
    );
  }
}

class EditPart extends StatelessWidget {
  const EditPart({
    super.key,
    required this.specimenUuid,
    required this.specimenPartId,
    required this.partCtr,
  });

  final String specimenUuid;
  final int? specimenPartId;
  final PartFormCtrModel partCtr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.partEditParts),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: PartForm(
          specimenUuid: specimenUuid,
          specimenPartId: specimenPartId,
          partCtr: partCtr,
          isEditing: true,
        ),
      ),
    );
  }
}

class PartForm extends ConsumerStatefulWidget {
  const PartForm({
    super.key,
    required this.specimenUuid,
    required this.specimenPartId,
    required this.partCtr,
    this.isEditing = false,
  });

  final String specimenUuid;
  final int? specimenPartId;
  final PartFormCtrModel partCtr;
  final bool isEditing;

  @override
  PartFormState createState() => PartFormState();
}

class PartFormState extends ConsumerState<PartForm> {
  bool _showMore = false;
  final CustomFieldDraftController _customFields = CustomFieldDraftController();

  @override
  void initState() {
    super.initState();
    final partId = widget.specimenPartId;
    if (widget.isEditing && partId != null) _loadIndividuals(partId);
  }

  @override
  void dispose() {
    _customFields.dispose();
    widget.partCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      footer: FormButton(isEditing: widget.isEditing, onSubmitted: _submit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PartIdForm(
            specimenUuid: widget.specimenUuid,
            partCtr: widget.partCtr,
          ),
          FormSection(
            title: context.l10n.partPreparation,
            child: Column(
              children: [
                SpecimenTypeField(partCtr: widget.partCtr),
                SpecimenCountField(partCtr: widget.partCtr),
                SpecimenTreatmentFields(
                  partCtr: widget.partCtr,
                  isVisible: _showMore,
                ),
              ],
            ),
          ),
          FormSection(
            title: context.l10n.partSampling,
            child: PartSamplingFields(
              visible: _showMore,
              partCtr: widget.partCtr,
            ),
          ),
          Visibility(
            visible: _showMore || _hasCurationData,
            child: FormSection(
              title: context.l10n.parasiteCuration,
              child: PartCurationFields(
                visible: _showMore,
                partCtr: widget.partCtr,
              ),
            ),
          ),
          if (widget.isEditing)
            CustomFieldForm(
              owner: CustomFieldOwner.specimenPart(widget.specimenPartId!),
              showAll: _showMore,
            )
          else
            CustomFieldDraftForm(
              placement: FieldUISection.specimenPart,
              specimenUuid: widget.specimenUuid,
              controller: _customFields,
              showAll: _showMore,
            ),
          ShowMoreButton(
            showMore: _showMore,
            onPressed: () {
              setState(() {
                _showMore = !_showMore;
              });
            },
          ),
        ],
      ),
    );
  }

  bool get _hasCurationData =>
      widget.partCtr.storageCtr.text.trim().isNotEmpty ||
      widget.partCtr.storageLocationCtr.text.trim().isNotEmpty ||
      widget.partCtr.museumPermanentCtr.text.trim().isNotEmpty ||
      widget.partCtr.museumLoanCtr.text.trim().isNotEmpty ||
      widget.partCtr.remarkCtr.text.trim().isNotEmpty;

  Future<void> _loadIndividuals(int partId) async {
    final ids = await SpecimenPartServices(
      ref: ref,
    ).getIndividualIdsForPart(partId);
    if (!mounted) return;
    setState(() => widget.partCtr.individualIds = ids.toSet());
  }

  Future<void> _submit() async {
    final services = SpecimenPartServices(ref: ref);
    final individualIds = widget.partCtr.individualIds;
    try {
      final database = ref.read(databaseProvider);
      if (widget.isEditing) {
        final partId = widget.specimenPartId!;
        await database.transaction(() async {
          await services.updateSpecimenPart(partId, _getForm());
          await services.setPartIndividuals(partId, individualIds);
        });
        services.invalidatePartIndividuals(partId);
      } else {
        final id = await database.transaction(() async {
          final id = await services.createSpecimenPart(_getForm());
          await services.setPartIndividuals(id, individualIds);
          await ref
              .read(customFieldServiceProvider)
              .setValues(
                CustomFieldOwner.specimenPart(id),
                _customFields.values,
              );
          return id;
        });
        services.invalidatePartIndividuals(id);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.partSaveError('$error'))),
      );
    }
  }

  SpecimenPartCompanion _getForm() {
    return SpecimenPartCompanion(
      specimenUuid: db.Value(widget.specimenUuid),
      tissueID: db.Value(widget.partCtr.tissueIdCtr.text),
      barcodeID: db.Value(widget.partCtr.barcodeIdCtr.text),
      personnelId: db.Value(widget.partCtr.preparatorCtr),
      type: db.Value(widget.partCtr.typeCtr.text),
      count: db.Value(widget.partCtr.countCtr.text),
      treatment: db.Value(widget.partCtr.treatmentCtr.text),
      additionalTreatment: db.Value(widget.partCtr.additionalTreatmentCtr.text),
      storage: db.Value(widget.partCtr.storageCtr.text),
      storageLocation: db.Value(widget.partCtr.storageLocationCtr.text),
      dateTaken: db.Value(widget.partCtr.dateTakenCtr.date),
      timeTaken: db.Value(widget.partCtr.timeTakenCtr.time),
      pmi: db.Value(widget.partCtr.pmiCtr.text),
      museumPermanent: db.Value(widget.partCtr.museumPermanentCtr.text),
      museumLoan: db.Value(widget.partCtr.museumLoanCtr.text),
      remark: db.Value(widget.partCtr.remarkCtr.text),
    );
  }
}

class SpecimenTreatmentFields extends ConsumerWidget {
  const SpecimenTreatmentFields({
    super.key,
    required this.partCtr,
    required this.isVisible,
  });

  final PartFormCtrModel partCtr;
  final bool isVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(effectiveUserDefinedFieldProvider(treatmentPrefKey))
        .when(
          data: (data) {
            final treatments = includeCurrentVocabularyValue(
              data,
              partCtr.treatmentCtr.text.trim().isEmpty
                  ? null
                  : partCtr.treatmentCtr.text.trim(),
            );
            return Column(
              children: [
                SpecimenTreatmentField(
                  partCtr: partCtr,
                  treatmentList: treatments,
                ),
                AdditionalTreatmentField(
                  partCtr: partCtr,
                  treatmentList: treatments,
                  isVisible: isVisible,
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text(context.l10n.formsErrorDetail('$e')),
        );
  }
}

class SpecimenCountField extends StatelessWidget {
  const SpecimenCountField({super.key, required this.partCtr});

  final PartFormCtrModel partCtr;

  @override
  Widget build(BuildContext context) {
    return CommonNumField(
      controller: partCtr.countCtr,
      labelText: context.l10n.partCounts,
      hintText: context.l10n.partCountsHint,
      isLastField: false,
    );
  }
}

class SpecimenTypeField extends ConsumerWidget {
  const SpecimenTypeField({super.key, required this.partCtr});

  final PartFormCtrModel partCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(effectiveUserDefinedFieldProvider(specimenTypePrefKey))
        .when(
          data: (data) {
            final options = includeCurrentVocabularyValue(data, _getValue());
            return DropdownButtonFormField(
              isExpanded: true,
              initialValue: _getValue(),
              decoration: InputDecoration(
                labelText: context.l10n.partPreparationType,
                hintText: context.l10n.partPreparationTypeHint,
              ),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: CommonDropdownText(text: value),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  partCtr.typeCtr.text = value;
                  if (partCtr.countCtr.text.isEmpty) {
                    partCtr.countCtr.text = '1';
                  }
                }
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text(context.l10n.formsErrorDetail('$e')),
        );
  }

  String? _getValue() {
    if (partCtr.typeCtr.text.trim().isNotEmpty) {
      return partCtr.typeCtr.text.trim();
    } else {
      return null;
    }
  }
}

class SpecimenTreatmentField extends StatelessWidget {
  const SpecimenTreatmentField({
    super.key,
    required this.partCtr,
    required this.treatmentList,
  });

  final PartFormCtrModel partCtr;
  final List<String> treatmentList;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      isExpanded: true,
      initialValue: _getValue(),
      decoration: InputDecoration(
        labelText: context.l10n.parasiteTreatment,
        hintText: context.l10n.partTreatmentHint,
      ),
      items: treatmentList.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: CommonDropdownText(text: value),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) {
          partCtr.treatmentCtr.text = value;
        }
      },
    );
  }

  String? _getValue() {
    if (partCtr.treatmentCtr.text.trim().isNotEmpty) {
      return partCtr.treatmentCtr.text.trim();
    } else {
      return null;
    }
  }
}

class AdditionalTreatmentField extends StatelessWidget {
  const AdditionalTreatmentField({
    super.key,
    required this.partCtr,
    required this.isVisible,
    required this.treatmentList,
  });

  final PartFormCtrModel partCtr;
  final bool isVisible;
  final List<String> treatmentList;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: DropdownButtonFormField(
        isExpanded: true,
        initialValue: _getValue(),
        decoration: InputDecoration(
          labelText: context.l10n.partAdditionalTreatment,
          hintText: context.l10n.partAdditionalTreatmentHint,
        ),
        items: treatmentList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: CommonDropdownText(text: value),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            partCtr.additionalTreatmentCtr.text = value;
          }
        },
      ),
    );
  }

  String? _getValue() {
    if (partCtr.additionalTreatmentCtr.text.trim().isNotEmpty) {
      return partCtr.additionalTreatmentCtr.text.trim();
    } else {
      return null;
    }
  }
}

class PartSamplingFields extends ConsumerWidget {
  const PartSamplingFields({
    super.key,
    required this.visible,
    required this.partCtr,
  });

  final bool visible;
  final PartFormCtrModel partCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Visibility(
          visible: visible || partCtr.preparatorCtr != null,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: partCtr.preparatorCtr,
            decoration: InputDecoration(
              labelText: context.l10n.formsSearchPreparator,
              hintText: context.l10n.partPreparatorHint,
            ),
            items: ref
                .watch(projectPersonnelProvider)
                .when(
                  data: (data) => data
                      .where(
                        (element) =>
                            element.role == 'Cataloger' ||
                            element.role == 'Preparator only',
                      )
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.uuid,
                          child: CommonDropdownText(text: e.name ?? ''),
                        ),
                      )
                      .toList(),
                  loading: () => const [],
                  error: (e, s) => const [],
                ),
            onChanged: (value) {
              if (value != null) {
                partCtr.preparatorCtr = value;
              }
            },
          ),
        ),
        Visibility(
          visible: visible || partCtr.dateTakenCtr.text.isNotEmpty,
          child: CommonDateField(
            labelText: context.l10n.partDateTaken,
            hintText: context.l10n.narrativeDateHint,
            controller: partCtr.dateTakenCtr,
            initialDate: DateTime.now(),
            lastDate: DateTime.now(),
            onTap: () {},
            onClear: () {},
          ),
        ),
        CommonTimeField(
          labelText: context.l10n.partTimeTaken,
          hintText: context.l10n.narrativeTimeHint,
          controller: partCtr.timeTakenCtr,
          initialTime: TimeOfDay.now(),
          onTap: () {},
          onClear: () {},
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.l10n.partRecommendedFresh,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Visibility(
          visible: visible || partCtr.pmiCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.pmiCtr,
            labelText: 'PMI',
            hintText: 'e.g., 1:30, 1:40',
            isLastField: false,
          ),
        ),
      ],
    );
  }
}

class PartCurationFields extends StatelessWidget {
  const PartCurationFields({
    super.key,
    required this.visible,
    required this.partCtr,
  });

  final bool visible;
  final PartFormCtrModel partCtr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: visible || partCtr.storageCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.storageCtr,
            labelText: context.l10n.partStorageType,
            hintText: context.l10n.partStorageTypeHint,
            isLastField: false,
          ),
        ),
        Visibility(
          visible: visible || partCtr.storageLocationCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.storageLocationCtr,
            labelText: context.l10n.parasiteStorageLocation,
            hintText: context.l10n.partStorageLocationHint,
            isLastField: false,
          ),
        ),
        Visibility(
          visible: visible || partCtr.museumPermanentCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.museumPermanentCtr,
            labelText: context.l10n.parasiteMuseumPermanent,
            hintText: context.l10n.partMuseumHint,
            isLastField: false,
          ),
        ),
        Visibility(
          visible: visible || partCtr.museumLoanCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.museumLoanCtr,
            labelText: context.l10n.parasiteMuseumLoan,
            hintText: context.l10n.partMuseumHint,
            isLastField: false,
          ),
        ),
        Visibility(
          visible: visible || partCtr.remarkCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.remarkCtr,
            maxLines: 3,
            labelText: context.l10n.specimenRemarks,
            hintText: context.l10n.partRemarksHint,
            isLastField: true,
          ),
        ),
      ],
    );
  }
}

class PartIdForm extends ConsumerWidget {
  const PartIdForm({
    super.key,
    required this.specimenUuid,
    required this.partCtr,
  });

  final String specimenUuid;
  final PartFormCtrModel partCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 4, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              context.l10n.parasiteIds,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TissueIDform(
              specimenUuid: specimenUuid,
              tissueIdCtr: partCtr.tissueIdCtr,
            ),
            UniqueIDField(barcodeIdCtr: partCtr.barcodeIdCtr),
            SpecimenIndividualSelector(
              specimenUuid: specimenUuid,
              selectedIds: partCtr.individualIds,
            ),
          ],
        ),
      ),
    );
  }
}

enum _UniqueIdAction { scan, generateUuid }

class UniqueIDField extends StatefulWidget {
  const UniqueIDField({super.key, required this.barcodeIdCtr});

  final TextEditingController barcodeIdCtr;

  @override
  State<UniqueIDField> createState() => _UniqueIDFieldState();
}

class _UniqueIDFieldState extends State<UniqueIDField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CommonTextField(
            controller: widget.barcodeIdCtr,
            labelText: context.l10n.partBarcodeId,
            hintText: context.l10n.partBarcodeIdHint,
            isLastField: false,
          ),
        ),
        AdaptiveMenuButton<_UniqueIdAction>(
          tooltip: context.l10n.partBarcodeIdOptions,
          onSelected: _onSelected,
          itemBuilder: () => [
            if (systemPlatform == PlatformType.mobile)
              AdaptiveMenuItem(
                value: _UniqueIdAction.scan,
                icon: Icons.qr_code_scanner_outlined,
                label: context.l10n.parasiteScanCode,
              ),
            AdaptiveMenuItem(
              value: _UniqueIdAction.generateUuid,
              icon: Icons.qr_code_2_outlined,
              label: context.l10n.partGenerateUuid,
              hasDividerBefore: true,
            ),
          ],
        ),
      ],
    );
  }

  void _onSelected(_UniqueIdAction action) {
    switch (action) {
      case _UniqueIdAction.scan:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerScreen(
              supportedModes: const {ScannerMode.qr, ScannerMode.barcode},
              onDetect: (barcode) {
                _onDetect(barcode);
              },
            ),
          ),
        );
      case _UniqueIdAction.generateUuid:
        _generateUuid();
    }
  }

  void _onDetect(BarcodeCapture barcode) {
    final barcodeId = barcode.barcodes.first;
    final String? qrData = barcodeId.rawValue;
    if (qrData == null) {
      _showError(context.l10n.partInvalidBarcode);
      return;
    }
    setState(() {
      widget.barcodeIdCtr.text = qrData;
    });
    Navigator.pop(context);
  }

  void _generateUuid() {
    if (widget.barcodeIdCtr.text.isNotEmpty) {
      _showError(context.l10n.partBarcodeIdExists);
      return;
    }
    setState(() {
      widget.barcodeIdCtr.text = uuid;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class TissueIDform extends ConsumerStatefulWidget {
  const TissueIDform({
    super.key,
    required this.specimenUuid,
    required this.tissueIdCtr,
  });

  final String specimenUuid;
  final TextEditingController tissueIdCtr;

  @override
  TissueIDformState createState() => TissueIDformState();
}

class TissueIDformState extends ConsumerState<TissueIDform> {
  bool _hasId = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: widget.tissueIdCtr,
            decoration: InputDecoration(
              labelText: context.l10n.recordsSpecimenTissueId,
              hintText: context.l10n.partTissueIdHint,
              suffix: _hasId || widget.tissueIdCtr.text.isNotEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: Theme.of(context).disabledColor,
                      ),
                      onPressed: () {
                        _repeatTissueNum();
                      },
                    ),
            ),
            onChanged: (value) {
              setState(() {
                _hasId = value.isNotEmpty;
              });
            },
            textInputAction: TextInputAction.done,
          ),
        ),
        TissueIDMenu(
          tissueIDct: widget.tissueIdCtr,
          onNewNumber: widget.tissueIdCtr.text.isNotEmpty
              ? null
              : () {
                  setState(() {
                    _hasId = true;
                  });
                },
        ),
      ],
    );
  }

  Future<void> _repeatTissueNum() async {
    String? tissueID = await TissueIdServices(
      ref: ref,
    ).repeatNumber(widget.specimenUuid);
    if (tissueID == null || tissueID.isEmpty) {
      if (mounted) {
        _showError(context.l10n.partRepeatTissueFailed);
      }
    } else {
      widget.tissueIdCtr.text = tissueID;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class TissueIDMenu extends ConsumerStatefulWidget {
  const TissueIDMenu({
    super.key,
    required this.tissueIDct,
    required this.onNewNumber,
  });

  final TextEditingController tissueIDct;
  final VoidCallback? onNewNumber;

  @override
  TissueIDMenuState createState() => TissueIDMenuState();
}

enum _TissueIdAction { newNumber, settings }

class TissueIDMenuState extends ConsumerState<TissueIDMenu> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveMenuButton<_TissueIdAction>(
      tooltip: context.l10n.partTissueIdOptions,
      onSelected: _onSelected,
      itemBuilder: () => [
        AdaptiveMenuItem(
          value: _TissueIdAction.newNumber,
          icon: Icons.add,
          label: context.l10n.parasiteNewNumber,
          enabled: _hasNoId(),
        ),
        AdaptiveMenuItem(
          value: _TissueIdAction.settings,
          icon: Icons.settings_outlined,
          label: context.l10n.parasiteSettings,
          hasDividerBefore: true,
        ),
      ],
    );
  }

  void _onSelected(_TissueIdAction action) {
    switch (action) {
      case _TissueIdAction.newNumber:
        if (widget.onNewNumber != null) {
          widget.onNewNumber!();
          setState(() {
            _getNewNumber();
          });
        }
      case _TissueIdAction.settings:
        _showTissueSettings();
    }
  }

  Future<void> _showTissueSettings() async {
    await showAdaptiveSheetDialog<void>(
      context: context,
      builder: (context, isSheet) => AdaptiveSheetDialogBody(
        title: context.l10n.partTissueIdSettings,
        showCloseButton: !isSheet,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonDone),
          ),
        ],
        child: NumberedIdFields(
          store: TissueIdServices(ref: ref),
          useHorizontalLayout: false,
          previewLabel: context.l10n.recordsSpecimenNextTissueId,
        ),
      ),
    );
    if (mounted && _hasNoId()) _getNewNumber();
  }

  void _getNewNumber() {
    TissueIdServices(ref: ref).getNewNumber().then((value) {
      widget.tissueIDct.text = value;
    });
  }

  bool _hasNoId() {
    return widget.tissueIDct.text.isEmpty;
  }
}
