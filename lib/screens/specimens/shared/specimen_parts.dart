import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/shared/qr.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/specimens/shared/associated_data.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/utility_services.dart';

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
  final int _length = 2;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _length, vsync: this);
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
      infoContent: const SpecimenPartInfoContent(),
      isWithSidePadding: false,
      child: CommonTabBars(
        tabController: _tabController,
        length: _length,
        height: 502,
        tabs: [
          Tab(
            icon: Icon(matchCatFmtToPartIcon(widget.catalogFmt)),
          ),
          Tab(
            icon: Icon(MdiIcons.databaseOutline),
          )
        ],
        children: [
          SpecimenPartFields(
            specimenUuid: widget.specimenUuid,
            catalogFmt: widget.catalogFmt,
          ),
          AssociatedDataViewer(specimenUuid: widget.specimenUuid),
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
          infoContent: SpecimenPartInfoContent(),
        ),
        SizedBox(
          height: 450,
          child: PartList(
            specimenUuid: specimenUuid,
            catalogFmt: catalogFmt,
          ),
        )
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specimenPartList =
        ref.watch(partBySpecimenProvider(widget.specimenUuid));
    return specimenPartList.when(
      data: (data) {
        return data.isEmpty
            ? EmptyPart(specimenUuid: widget.specimenUuid)
            : Column(
                children: [
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
                            leading: PartIcon(
                              partType: part.type ?? 'unknown',
                              catalogFmt: widget.catalogFmt,
                            ),
                            title: PartTitle(
                              partType: part.type,
                              partCount: part.count.toString(),
                              barcodeID: part.barcodeID ?? '',
                              preparator: part.personnelId,
                            ),
                            subtitle: PartSubTitle(part: part),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditPart(
                                      specimenUuid: widget.specimenUuid,
                                      specimenPartId: part.id,
                                      partCtr: PartFormCtrModel.fromData(part),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AddPartButton(specimenUuid: widget.specimenUuid),
                ],
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
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
  const PartIcon({
    super.key,
    required this.partType,
    required this.catalogFmt,
  });

  final String partType;
  final CatalogFmt catalogFmt;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TileSvgIcon(
      iconPath: _iconPath,
    );
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
                      text: '$_partText'
                          '$listTileSeparator'
                          '${snapshot.data}',
                    );
                  } else {
                    return TitlePartText(
                      text: _partText,
                    );
                  }
                })
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
    PersonnelData person =
        await PersonnelServices(ref: ref).getPersonnelByUuid(preparator!);
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
  const BarcodeText({
    super.key,
    required this.barcodeID,
  });

  final String? barcodeID;

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: [
        WidgetSpan(
            child: TileIcon(icon: MdiIcons.barcode),
            alignment: PlaceholderAlignment.middle),
        const TextSpan(text: ' '),
        TextSpan(
          text: barcodeIDText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ]),
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
      '${_getText(part.dateTaken)}'
      '${_getText(part.timeTaken)}'
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
  const NewPart({
    super.key,
    required this.specimenUuid,
  });

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

  @override
  void dispose() {
    widget.partCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PartIdForm(
            specimenUuid: widget.specimenUuid,
            partCtr: widget.partCtr,
          ),
          SpecimenTypeField(
            partCtr: widget.partCtr,
          ),
          SpecimenCountField(partCtr: widget.partCtr),
          SpecimenTreatmentFields(
            partCtr: widget.partCtr,
            isVisible: _showMore,
          ),
          AdditionalPartFields(visible: _showMore, partCtr: widget.partCtr),
          ShowMoreButton(
            showMore: _showMore,
            onPressed: () {
              setState(() {
                _showMore = !_showMore;
              });
            },
          ),
          const SizedBox(height: 16),
          FormButtonWithDelete(
            isEditing: widget.isEditing,
            onDeleted: () {
              if (widget.specimenPartId != null) {
                SpecimenServices(ref: ref)
                    .deleteSpecimenPart(widget.specimenPartId!);
                Navigator.pop(context);
              }
            },
            onSubmitted: () {
              widget.isEditing ? _updatePart() : _createPart();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createPart() async {
    SpecimenPartCompanion form = _getForm();

    await SpecimenPartServices(ref: ref).createSpecimenPart(form);
  }

  Future<void> _updatePart() async {
    SpecimenPartCompanion form = _getForm();

    await SpecimenPartServices(ref: ref)
        .updateSpecimenPart(widget.specimenPartId!, form);
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
      dateTaken: db.Value(widget.partCtr.dateTakenCtr.text),
      timeTaken: db.Value(widget.partCtr.timeTakenCtr.text),
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
    return ref.watch(treatmentOptionsProvider).when(
          data: (data) {
            return Column(
              children: [
                SpecimenTreatmentField(
                  partCtr: partCtr,
                  treatmentList: data,
                ),
                AdditionalTreatmentField(
                  partCtr: partCtr,
                  treatmentList: data,
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
  const SpecimenCountField({
    super.key,
    required this.partCtr,
  });

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
  const SpecimenTypeField({
    super.key,
    required this.partCtr,
  });

  final PartFormCtrModel partCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(specimenTypesProvider).when(
          data: (data) {
            return DropdownButtonFormField(
              initialValue: _getValue(),
              decoration: const InputDecoration(
                labelText: 'Preparation type',
                hintText: 'Enter preparation type',
              ),
              items: data.map((String value) {
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

class AdditionalPartFields extends ConsumerWidget {
  const AdditionalPartFields({
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
        CommonTimeField(
          labelText: 'Time taken',
          hintText: 'Enter time',
          controller: partCtr.timeTakenCtr,
          initialTime: TimeOfDay.now(),
          onTap: () {},
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Recommended for fresh tissues',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Visibility(
          visible: visible || partCtr.preparatorCtr != null,
          child: DropdownButtonFormField<String>(
            initialValue: partCtr.preparatorCtr,
            decoration: const InputDecoration(
              labelText: 'Preparator',
              hintText: 'If different from voucher preparator',
            ),
            items: ref.watch(projectPersonnelProvider).when(
                  data: (data) => data
                      .where((element) =>
                          element.role == 'Cataloger' ||
                          element.role == 'Preparator only')
                      .map((e) => DropdownMenuItem(
                            value: e.uuid,
                            child: CommonDropdownText(text: e.name ?? ''),
                          ))
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
            isLastField: false,
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
          child: Column(children: [
            Text(
              'Additional Part ID',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TissueIDform(
              specimenUuid: specimenUuid,
              tissueIdCtr: partCtr.tissueIdCtr,
            ),
            UniqueIDField(
              barcodeIdCtr: partCtr.barcodeIdCtr,
            ),
          ]),
        ));
  }
}

class UniqueIDField extends StatefulWidget {
  const UniqueIDField({
    super.key,
    required this.barcodeIdCtr,
  });

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
        PopupMenuButton<String>(itemBuilder: (context) {
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
                        onDetect: (barcode) {
                          _onDetect(barcode);
                        },
                      ),
                    ),
                  );
                },
              ),
            if (systemPlatform == PlatformType.mobile) const PopupMenuDivider(),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(
                  Icons.qr_code_2_outlined,
                ),
                title: Text('Generate UUID'),
              ),
              onTap: () {
                _generateUuid();
              },
            ),
          ];
        }),
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
      _showError('QR/barcode ID already exists. '
          'Clear the field to generate a new UUID');
      return;
    }
    setState(() {
      widget.barcodeIdCtr.text = uuid;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
                  setState(
                    () {
                      _hasId = true;
                    },
                  );
                },
        ),
      ],
    );
  }

  Future<void> _repeatTissueNum() async {
    String? tissueID =
        await TissueIdServices(ref: ref).repeatNumber(widget.specimenUuid);
    if (tissueID == null || tissueID.isEmpty) {
      if (context.mounted) {
        _showError('Failed to repeat tissue number');
      }
    } else {
      widget.tissueIdCtr.text = tissueID;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
    return PopupMenuButton<int>(itemBuilder: (BuildContext context) {
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
              }
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
                  ).then(
                    (value) => _showTissueSettings(),
                  ),
                }),
      ];
    });
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
                String tissueID = await TissueIdServices(ref: ref).setTissueID(
                  prefixCtr.text,
                  numberCtr.text,
                );
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

class SpecimenPartInfoContent extends StatelessWidget {
  const SpecimenPartInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(content: [
      InfoContent(
        header: 'Overview',
        content: 'List of specimen parts collected from the specimen, '
            'such as skin, skull, liver, etc.'
            ' You can edit the type and treatments list in the settings,',
      ),
    ]);
  }
}
