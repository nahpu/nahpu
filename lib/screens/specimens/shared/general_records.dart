import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/specimens/shared/taxa.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/specimen_services.dart';

class GeneralRecordField extends ConsumerStatefulWidget {
  const GeneralRecordField({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.useHorizontalLayout,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final bool useHorizontalLayout;

  @override
  GeneralRecordFieldState createState() => GeneralRecordFieldState();
}

class GeneralRecordFieldState extends ConsumerState<GeneralRecordField> {
  List<PersonnelData> personnelList = [];

  bool _showMore = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final personnelEntry = ref.watch(projectPersonnelProvider);
    personnelEntry.whenData(
      (personnelEntry) => personnelList = personnelEntry,
    );
    return FormCard(
      title: 'General Records',
      isPrimary: true,
      infoContent: const CollRecordInfoContent(),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      child: Column(
        children: [
          PersonnelRecords(
            specimenUuid: widget.specimenUuid,
            specimenCtr: widget.specimenCtr,
            showMore: _showMore,
          ),
          SpeciesFieldCtr(
            specimenUuid: widget.specimenUuid,
            speciesCtr: widget.specimenCtr.speciesCtr,
          ),
          IDConfidence(
            specimenUuid: widget.specimenUuid,
            specimenCtr: widget.specimenCtr,
          ),
          Visibility(
            visible:
                _showMore || widget.specimenCtr.idMethodCtr.text.isNotEmpty,
            child: IDMethod(
                specimenUuid: widget.specimenUuid,
                specimenCtr: widget.specimenCtr),
          ),
          SpecimenConditionField(
            specimenCtr: widget.specimenCtr,
            specimenUuid: widget.specimenUuid,
          ),
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              SpecimenCollectionDateField(
                specimenCtr: widget.specimenCtr,
                specimenUuid: widget.specimenUuid,
              ),  
              SpecimenCollectionTimeField(
                specimenCtr: widget.specimenCtr,
                specimenUuid: widget.specimenUuid,
              ),
            ]
          ),      
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              PrepDateField(
                specimenCtr: widget.specimenCtr,
                specimenUuid: widget.specimenUuid,
              ),
              PrepTimeField(
                specimenCtr: widget.specimenCtr,
                specimenUuid: widget.specimenUuid,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton(
              onPressed: () {
                setState(
                  () {
                    _showMore = !_showMore;
                  },
                );
              },
              child: Text(_showMore ? 'Show less' : 'Show more'),
            ),
          ),
        ],
      ),
    );
  }
}

class SpeciesFieldCtr extends ConsumerWidget {
  const SpeciesFieldCtr({
    super.key,
    required this.specimenUuid,
    required this.speciesCtr,
  });

  final String specimenUuid;
  final int? speciesCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(taxonProvider).when(
          data: (taxa) {
            if (taxa.isEmpty) {
              return const DisabledSpeciesField();
            }
            return SpeciesInputField(
              specimenUuid: specimenUuid,
              speciesCtr: speciesCtr,
              taxonList: taxa,
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => const Text('Error loading taxa'),
        );
  }
}

class IDConfidence extends ConsumerWidget {
  const IDConfidence({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonPadding(
        child: DropdownButtonFormField<int?>(
      initialValue: specimenCtr.idConfidenceCtr,
      onChanged: (int? value) {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(iDConfidence: db.Value(value)),
        );
      },
      decoration: const InputDecoration(
        labelText: 'ID Confidence',
        hintText: 'Choose a confidence level',
      ),
      items: idConfidenceList.reversed
          .map((e) => DropdownMenuItem<int?>(
              value: idConfidenceList.indexOf(e),
              child: CommonDropdownText(text: e)))
          .toList(),
    ));
  }
}

class IDMethod extends ConsumerWidget {
  const IDMethod({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = SpecimenServices(ref: ref);
    return CommonPadding(
        child: TextField(
      controller: specimenCtr.idMethodCtr,
      decoration: const InputDecoration(
        labelText: 'ID Method',
        hintText: 'Enter ID method',
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          service.updateSpecimenSkipInvalidation(
            specimenUuid,
            SpecimenCompanion(iDMethod: db.Value(value)),
          );
        }
      },
      onSubmitted: (_) => service.invalidateSpecimenList(),
    ));
  }
}

class SpecimenCollectionDateField extends ConsumerWidget {
  const SpecimenCollectionDateField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonDateField(
      controller: specimenCtr.collDateCtr,
      labelText: 'Collection date',
      hintText: 'Enter date',
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
      onTap: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(
            collectionDate: db.Value(
              specimenCtr.collDateCtr.text,
            )
          ),
        );
      },
      onClear: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(
            collectionDate: db.Value(null)
          ),
        );
      }
    );
  }
}

class SpecimenCollectionTimeField extends ConsumerWidget {
  const SpecimenCollectionTimeField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonTimeField(
      controller: specimenCtr.collTimeCtr,
      labelText: 'Collection time',
      hintText: 'Enter time',
      initialTime: TimeOfDay.now(),
      onTap: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(
              collectionTime: db.Value(
            specimenCtr.collTimeCtr.text,
          )),
        );
      },
      onClear: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(
              collectionTime: db.Value(null)
          )
        );
      }
    );
  }
}

class SpecimenConditionField extends ConsumerWidget {
  const SpecimenConditionField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return CommonPadding(
      child: DropdownButtonFormField(
        initialValue: specimenCtr.conditionCtr,
        onChanged: (String? value) {
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(condition: db.Value(value)),
          );
        },
        decoration: const InputDecoration(
          labelText: 'Condition',
          hintText: 'Choose a condition',
        ),
        items: conditionList
            .map((String condition) => DropdownMenuItem(
                  value: condition,
                  child: CommonDropdownText(text: condition),
                ))
            .toList(),
      )
    );
  }
}

class PrepDateField extends ConsumerWidget {
  const PrepDateField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonDateField(
      controller: specimenCtr.prepDateCtr,
      labelText: 'Prep. date',
      hintText: 'Enter date',
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
      onTap: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(
            prepDate: db.Value(specimenCtr.prepDateCtr.text),
          ),
        );
      },
      onClear: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(
            prepDate: db.Value(null)
          ),
        );
      }      
    );
  }
}

class PrepTimeField extends ConsumerWidget {
  const PrepTimeField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonTimeField(
      controller: specimenCtr.prepTimeCtr,
      labelText: 'Prep. time',
      hintText: 'Enter time',
      initialTime: TimeOfDay.now(),
      onTap: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(
            prepTime: db.Value(specimenCtr.prepTimeCtr.text),
          ),
        );
      },
      onClear: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(
              prepTime: db.Value(null)
          )
        );
      }
    );
  }
}

class PersonnelRecords extends ConsumerStatefulWidget {
  const PersonnelRecords({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.showMore,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final bool showMore;

  @override
  PersonnelRecordsState createState() => PersonnelRecordsState();
}

class PersonnelRecordsState extends ConsumerState<PersonnelRecords> {
  final Set<String> _selectedPersonnel = {};

  @override
  Widget build(BuildContext context) {
    return CommonPadding(
      child: Column(
        children: [
          widget.specimenCtr.catalogerCtr != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: IdTile(
                    specimenUuid: widget.specimenUuid,
                    specimenCtr: widget.specimenCtr,
                    catalogerUuid: widget.specimenCtr.catalogerCtr!,
                    showMore: widget.showMore,
                  ))
              : const SizedBox.shrink(),
          DropdownButtonFormField<String>(
            initialValue: widget.specimenCtr.catalogerCtr,
            decoration: const InputDecoration(
              labelText: 'Cataloger',
              hintText: 'Choose a person with field number',
            ),
            items: ref.watch(projectPersonnelProvider).when(
                  data: (data) => data
                      .where((element) => element.role == 'Cataloger')
                      .map((e) => DropdownMenuItem(
                            value: e.uuid,
                            child: CommonDropdownText(text: e.name ?? ''),
                          ))
                      .toList(),
                  loading: () => const [],
                  error: (e, s) => const [],
                ),
            onChanged: (String? uuid) async {
              if (uuid != null) {
                int fieldNumber = await _getCurrentCollectorNumber(uuid);
                setState(() {
                  bool hasSelected = _selectedPersonnel.contains(uuid);
                  int currentFieldNumber =
                      hasSelected ? fieldNumber - 1 : fieldNumber;
                  widget.specimenCtr.catalogerCtr = uuid;
                  widget.specimenCtr.preparatorCtr = uuid;
                  widget.specimenCtr.fieldNumberCtr.text =
                      currentFieldNumber.toString();

                  if (!hasSelected) {
                    PersonnelServices(ref: ref).updatePersonnelEntry(
                        uuid,
                        PersonnelCompanion(
                            currentFieldNumber: db.Value(fieldNumber + 1)));
                    _selectedPersonnel.add(uuid);
                  }
                  SpecimenServices(ref: ref).updateSpecimen(
                    widget.specimenUuid,
                    SpecimenCompanion(
                      catalogerID: db.Value(uuid),
                      fieldNumber: db.Value(
                        currentFieldNumber,
                      ),
                      preparatorID: db.Value(uuid),
                    ),
                  );
                });
              }
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: widget.specimenCtr.preparatorCtr,
            decoration: const InputDecoration(
              labelText: 'Preparator',
              hintText: 'Choose a preparator (default is cataloger)',
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
            onChanged: (String? uuid) {
              SpecimenServices(ref: ref).updateSpecimen(
                widget.specimenUuid,
                SpecimenCompanion(preparatorID: db.Value(uuid)),
              );
            },
          )
        ],
      ),
    );
  }

  Future<int> _getCurrentCollectorNumber(String personnelUuid) async {
    int fieldNumber = await SpecimenServices(ref: ref).getSpecimenFieldNumber(
      personnelUuid,
    );

    return fieldNumber;
  }
}

class IdTile extends ConsumerWidget {
  const IdTile({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.catalogerUuid,
    required this.showMore,
  });

  final SpecimenFormCtrModel specimenCtr;
  final bool showMore;
  final String specimenUuid;
  final String catalogerUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonIDForm(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Visibility(
              visible: showMore || specimenCtr.museumIDCtr.text.isNotEmpty,
              child: CommonTextField(
                controller: specimenCtr.museumIDCtr,
                labelText: 'Museum ID',
                hintText: 'Enter museum ID (if applicable)',
                isLastField: true,
                onChanged: (String? value) {
                  if (value != null) {
                    SpecimenServices(ref: ref).updateSpecimen(
                      specimenUuid,
                      SpecimenCompanion(
                        museumID: db.Value(value),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          SpecimenIdTile(
            specimenUuid: specimenUuid,
            specimenCtr: specimenCtr,
            catalogerUuid: catalogerUuid,
          ),
        ],
      ),
    );
  }
}

class SpecimenIdTile extends ConsumerWidget {
  const SpecimenIdTile({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.catalogerUuid,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final String catalogerUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial = ref.watch(personnelInitialProvider(catalogerUuid));
    return ListTile(
      title: initial.when(
        data: (initial) => Text(
          'Field ID: $initial${specimenCtr.fieldNumberCtr.text}',
        ),
        loading: () => const Text('Loading...'),
        error: (error, stack) => Text('Error: $error'),
      ),
      trailing: Visibility(
        visible: specimenCtr.fieldNumberCtr.text.isNotEmpty,
        child: IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).disabledColor,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Edit field number'),
                  content: TextField(
                    controller: specimenCtr.fieldNumberCtr,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Field number',
                      hintText: 'Enter field number',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        int fieldNumber =
                            int.parse(specimenCtr.fieldNumberCtr.text);
                        int nextFieldNumber = fieldNumber + 1;
                        await PersonnelServices(ref: ref).updatePersonnelEntry(
                            catalogerUuid,
                            PersonnelCompanion(
                                currentFieldNumber: db.Value(nextFieldNumber)));
                        await SpecimenServices(ref: ref).updateSpecimen(
                          specimenUuid,
                          SpecimenCompanion(
                            fieldNumber: db.Value(
                              fieldNumber,
                            ),
                          ),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CollRecordInfoContent extends StatelessWidget {
  const CollRecordInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(content: [
      InfoContent(
        header: 'Overview',
        content: 'General record of the specimen. '
            'Field ID is auto-generated based on the'
            ' cataloger\'s current field number.'
            ' Use the edit button to override the field number.',
      ),
      InfoContent(
        header: 'Cataloger and preparator fields',
        content: 'By default, the cataloger is the preparator.'
            ' If the preparator is different, '
            'select the preparator from the dropdown.',
      ),
      InfoContent(
        header: 'Species field',
        content: 'Type the species name to search for it in the taxon registry.'
            ' You can start by typing the epithet to simplify the search.'
            'The species field will be disabled if no'
            ' taxa are registered in the project.'
            ' You can add a taxon in the taxon registry section in the project dashboard.',
      ),
      InfoContent(
        header: 'Condition field',
        content: 'The condition field is a qualitative measure of the freshness'
            ' of the specimen at time of prep.'
            ' Condition can depend on factors including time since death,' 
            ' temperature, sun exposure (especially for salvage specimens), etc.'
            ' If the collection time (i.e., time of death) and prep times are known,'
            ' these can also be added for a more quantitative'
            ' measure of condition at time of prep.'
            
      ),
    ]);
  }
}
