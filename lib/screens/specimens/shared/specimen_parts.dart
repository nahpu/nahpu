import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/screens/specimens/shared/parasite_forms.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/specimens/shared/associated_data.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/custom_field.dart';

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
        const TitleForm(
          text: 'Specimen Parts',
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
                              partCount: part.count.toString(),
                              barcodeID: part.barcodeID ?? '',
                              preparator: part.personnelId,
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
                          itemName:
                              'specimen ${_selectedparts.length == 1 ? 'part' : 'parts'}',
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
      error: (err, stack) => Text('Error: $err'),
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
      label: 'Add specimen part',
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
        const Text('No parts added'),
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

class PartTitle extends ConsumerWidget {
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
  final String? preparator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        preparator != null
            ? FutureBuilder(
                future: _getPreparatorName(ref),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TitlePartText(
                      text:
                          '$_partText'
                          '$listTileSeparator'
                          '${snapshot.data}',
                    );
                  } else {
                    return TitlePartText(text: _partText);
                  }
                },
              )
            : TitlePartText(text: _partText),
        barcodeID.isNotEmpty
            ? BarcodeText(barcodeID: barcodeID)
            : const SizedBox.shrink(),
      ],
    );
  }

  String get _partText {
    return '${partType ?? 'Unknown part'}'
        '$listTileSeparator'
        '${partCount ?? 'No count'}';
  }

  Future<String> _getPreparatorName(WidgetRef ref) async {
    PersonnelData person = await PersonnelServices(
      ref: ref,
    ).getPersonnelByUuid(preparator!);
    return person.name ?? '';
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

class PartSubTitle extends StatelessWidget {
  const PartSubTitle({super.key, required this.part});

  final SpecimenPartData part;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_getTextFirst(part.tissueID)}'
      '$treatment'
      '${_getText(part.additionalTreatment)}'
      '${_getText(dateStdToDateDisplay(part.dateTaken))}'
      '${_getText(timeStdToTimeDisplay(part.timeTaken))}'
      '${_getPMI()}'
      '$remark',
      style: Theme.of(context).textTheme.bodyMedium,
      overflow: TextOverflow.ellipsis,
    );
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

  String get treatment {
    if (part.treatment == null) {
      return 'None';
    } else if (part.treatment!.isEmpty) {
      return 'None';
    } else {
      return '${part.treatment}';
    }
  }

  String _getPMI() {
    if (part.pmi == null) {
      return '';
    } else if (part.pmi!.isEmpty) {
      return '';
    } else {
      return '${listTileSeparator}PMI ${part.pmi}';
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

  String get remark {
    if (part.remark == null) {
      return '';
    } else if (part.remark!.isEmpty) {
      return '';
    } else {
      return '${listTileSeparator}has remark';
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
        title: const Text('Add specimen parts'),
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
        title: const Text('Edit specimen parts'),
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
            title: 'Preparation',
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
            title: 'Sampling',
            child: PartSamplingFields(
              visible: _showMore,
              partCtr: widget.partCtr,
            ),
          ),
          Visibility(
            visible: _showMore || _hasCurationData,
            child: FormSection(
              title: 'Curation',
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

  Future<void> _submit() async {
    try {
      if (widget.isEditing) {
        await SpecimenPartServices(
          ref: ref,
        ).updateSpecimenPart(widget.specimenPartId!, _getForm());
      } else {
        final database = ref.read(databaseProvider);
        await database.transaction(() async {
          final id = await SpecimenPartServices(
            ref: ref,
          ).createSpecimenPart(_getForm());
          await ref
              .read(customFieldServiceProvider)
              .setValues(
                CustomFieldOwner.specimenPart(id),
                _customFields.values,
              );
        });
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save specimen part: $error')),
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
          error: (e, s) => Text('Error: $e'),
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
      labelText: 'Counts',
      hintText: 'Enter part counts',
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
              decoration: const InputDecoration(
                labelText: 'Preparation type',
                hintText: 'Enter preparation type',
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
          error: (e, s) => Text('Error: $e'),
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
      decoration: const InputDecoration(
        labelText: 'Treatment',
        hintText: 'Enter treatment',
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
        decoration: const InputDecoration(
          labelText: 'Additional treatment',
          hintText: 'Enter additional treatment',
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
            decoration: const InputDecoration(
              labelText: 'Preparator',
              hintText: 'If different from voucher preparator',
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
            labelText: 'Date taken',
            hintText: 'Enter date',
            controller: partCtr.dateTakenCtr,
            initialDate: DateTime.now(),
            lastDate: DateTime.now(),
            onTap: () {},
            onClear: () {},
          ),
        ),
        CommonTimeField(
          labelText: 'Time taken',
          hintText: 'Enter time',
          controller: partCtr.timeTakenCtr,
          initialTime: TimeOfDay.now(),
          onTap: () {},
          onClear: () {},
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Recommended for fresh tissues',
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
            labelText: 'Storage type',
            hintText: 'Enter storage type',
            isLastField: false,
          ),
        ),
        Visibility(
          visible: visible || partCtr.storageLocationCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.storageLocationCtr,
            labelText: 'Storage location',
            hintText:
                'It can be cell or jar ID, following your museum convention',
            isLastField: false,
          ),
        ),
        Visibility(
          visible: visible || partCtr.museumPermanentCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.museumPermanentCtr,
            labelText: 'Museum permanent',
            hintText: 'Enter a museum name or abbreviation',
            isLastField: false,
          ),
        ),
        Visibility(
          visible: visible || partCtr.museumLoanCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.museumLoanCtr,
            labelText: 'Museum loan',
            hintText: 'Enter a museum name or abbreviation',
            isLastField: false,
          ),
        ),
        Visibility(
          visible: visible || partCtr.remarkCtr.text.isNotEmpty,
          child: CommonTextField(
            controller: partCtr.remarkCtr,
            maxLines: 3,
            labelText: 'Remarks',
            hintText: 'Enter a remark specific to this part',
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
            Text('IDs', style: Theme.of(context).textTheme.titleLarge),
            SelectableText('Specimen UUID: $specimenUuid'),
            TissueIDform(
              specimenUuid: specimenUuid,
              tissueIdCtr: partCtr.tissueIdCtr,
            ),
            UniqueIDField(barcodeIdCtr: partCtr.barcodeIdCtr),
          ],
        ),
      ),
    );
  }
}

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
            labelText: 'QR/barcode ID',
            hintText: 'Enter barcode ID (if applicable)',
            isLastField: false,
          ),
        ),
        PopupMenuButton<String>(
          itemBuilder: (context) {
            return [
              if (systemPlatform == PlatformType.mobile)
                PopupMenuItem(
                  child: const ListTile(
                    leading: Icon(Icons.qr_code_scanner_outlined),
                    title: Text('Scan QR/Barcode'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScannerScreen(
                          supportedModes: const {
                            ScannerMode.qr,
                            ScannerMode.barcode,
                          },
                          onDetect: (barcode) {
                            _onDetect(barcode);
                          },
                        ),
                      ),
                    );
                  },
                ),
              if (systemPlatform == PlatformType.mobile)
                const PopupMenuDivider(),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.qr_code_2_outlined),
                  title: Text('Generate UUID'),
                ),
                onTap: () {
                  _generateUuid();
                },
              ),
            ];
          },
        ),
      ],
    );
  }

  void _onDetect(BarcodeCapture barcode) {
    final barcodeId = barcode.barcodes.first;
    final String? qrData = barcodeId.rawValue;
    if (qrData == null) {
      _showError('Invalid QR/barcode');
      return;
    }
    setState(() {
      widget.barcodeIdCtr.text = qrData;
    });
    Navigator.pop(context);
  }

  void _generateUuid() {
    if (widget.barcodeIdCtr.text.isNotEmpty) {
      _showError(
        'QR/barcode ID already exists. '
        'Clear the field to generate a new UUID',
      );
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
              labelText: 'Tissue ID',
              hintText: 'Enter tissue ID',
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
      if (context.mounted) {
        _showError('Failed to repeat tissue number');
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

class TissueIDMenuState extends ConsumerState<TissueIDMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 1,
            enabled: _hasNoId(),
            child: const ListTile(
              leading: Icon(Icons.add),
              title: Text('New number'),
            ),
            onTap: () => {
              if (widget.onNewNumber != null)
                {
                  widget.onNewNumber!(),
                  setState(() {
                    _getNewNumber();
                  }),
                },
            },
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 2,
            child: const ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Settings'),
            ),
            onTap: () => {
              Future.delayed(
                const Duration(milliseconds: 0),
              ).then((value) => _showTissueSettings()),
            },
          ),
        ];
      },
    );
  }

  void _showTissueSettings() {
    TextEditingController prefixCtr = TextEditingController();
    TextEditingController numberCtr = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tissue ID settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonTextField(
                  controller: prefixCtr,
                  labelText: 'Prefix',
                  hintText: 'Enter tissue ID prefix',
                  isLastField: false,
                ),
                CommonNumField(
                  controller: numberCtr,
                  labelText: 'Number',
                  hintText: 'Enter tissue ID number',
                  isLastField: false,
                ),
              ],
            ),
          ),
          actions: [
            SecondaryButton(
              onPressed: () => Navigator.of(context).pop(),
              text: 'Cancel',
            ),
            PrimaryButton(
              onPressed: () async {
                String tissueID = await TissueIdServices(
                  ref: ref,
                ).setTissueID(prefixCtr.text, numberCtr.text);
                widget.tissueIDct.text = tissueID;
                if (mounted) {
                  _pop();
                }
              },
              label: 'Save',
              icon: Icons.save_alt_outlined,
            ),
          ],
        );
      },
    );
  }

  void _pop() {
    Navigator.pop(context);
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
