import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/shared/taxonomy.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/screens/shared/common/common.dart';

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
    personnelEntry.whenData((personnelEntry) => personnelList = personnelEntry);
    return FormCard(
      title: 'Collection & Identification',
      isPrimary: true,
      infoTopic: InfoTopic.specimenGeneralRecord,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      child: Column(
        children: [
          PersonnelRecords(
            specimenUuid: widget.specimenUuid,
            specimenCtr: widget.specimenCtr,
            showMore: _showMore,
            onCatalogerChanged: () => setState(() {}),
          ),
          SpeciesFieldCtr(
            specimenUuid: widget.specimenUuid,
            speciesCtr: widget.specimenCtr.speciesCtr,
          ),
          DeterminerField(
            specimenUuid: widget.specimenUuid,
            specimenCtr: widget.specimenCtr,
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
              specimenCtr: widget.specimenCtr,
            ),
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
            ],
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
                setState(() {
                  _showMore = !_showMore;
                });
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
    return ref
        .watch(taxonProvider)
        .when(
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
            .map(
              (e) => DropdownMenuItem<int?>(
                value: idConfidenceList.indexOf(e),
                child: CommonDropdownText(text: e),
              ),
            )
            .toList(),
      ),
    );
  }
}

class DeterminerField extends ConsumerWidget {
  const DeterminerField({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonPadding(
      child: DropdownButtonFormField<String>(
        key: ValueKey(specimenCtr.determinerCtr),
        initialValue: specimenCtr.determinerCtr,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Determiner',
          hintText: 'Choose a determiner (default is cataloger)',
          hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
        ),
        items: ref
            .watch(projectPersonnelProvider)
            .when(
              data: (data) => data
                  .where(
                    (element) =>
                        element.role == 'Cataloger' ||
                        element.role == 'Determiner only',
                  )
                  .map(
                    (person) => DropdownMenuItem(
                      value: person.uuid,
                      child: CommonDropdownText(text: person.name ?? ''),
                    ),
                  )
                  .toList(),
              loading: () => const [],
              error: (_, _) => const [],
            ),
        onChanged: (String? uuid) {
          specimenCtr.determinerCtr = uuid;
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(determinerID: db.Value(uuid)),
          );
        },
      ),
    );
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
      ),
    );
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
            collectionDate: db.Value(specimenCtr.collDateCtr.date),
          ),
        );
      },
      onClear: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(collectionDate: db.Value(null)),
        );
      },
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
            collectionTime: db.Value(specimenCtr.collTimeCtr.time),
          ),
        );
      },
      onClear: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(collectionTime: db.Value(null)),
        );
      },
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
    return ref
        .watch(effectiveUserDefinedFieldProvider(conditionPrefKey))
        .when(
          data: (data) {
            final options = includeCurrentVocabularyValue(
              data,
              specimenCtr.conditionCtr,
            );
            return CommonPadding(
              child: DropdownButtonFormField<String>(
                initialValue: specimenCtr.conditionCtr,
                onChanged: (String? value) {
                  specimenCtr.conditionCtr = value;
                  SpecimenServices(ref: ref).updateSpecimen(
                    specimenUuid,
                    SpecimenCompanion(condition: db.Value(value)),
                  );
                },
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  hintText: 'Choose a condition',
                ),
                items: options
                    .map(
                      (condition) => DropdownMenuItem(
                        value: condition,
                        child: CommonDropdownText(text: condition),
                      ),
                    )
                    .toList(),
              ),
            );
          },
          loading: () => const CommonProgressIndicator(),
          error: (error, _) => Text('Error: $error'),
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
          SpecimenCompanion(prepDate: db.Value(specimenCtr.prepDateCtr.date)),
        );
      },
      onClear: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(prepDate: db.Value(null)),
        );
      },
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
          SpecimenCompanion(prepTime: db.Value(specimenCtr.prepTimeCtr.time)),
        );
      },
      onClear: () {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(prepTime: db.Value(null)),
        );
      },
    );
  }
}

class PersonnelRecords extends ConsumerStatefulWidget {
  const PersonnelRecords({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.showMore,
    required this.onCatalogerChanged,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final bool showMore;
  final VoidCallback onCatalogerChanged;

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
          IdTile(
            specimenUuid: widget.specimenUuid,
            specimenCtr: widget.specimenCtr,
            catalogerUuid: widget.specimenCtr.catalogerCtr ?? '',
            showMore: widget.showMore,
          ),
          DropdownButtonFormField<String>(
            initialValue: widget.specimenCtr.catalogerCtr,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Cataloger',
              hintText: 'Choose a cataloger',
              hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
            ),
            items: ref
                .watch(projectPersonnelProvider)
                .when(
                  data: (data) => data
                      .where((element) => element.role == 'Cataloger')
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
            onChanged: (String? personnelUuid) async {
              _setPersonalFieldNumber(personnelUuid);
            },
          ),
          DropdownButtonFormField<String>(
            key: ValueKey(widget.specimenCtr.preparatorCtr),
            initialValue: widget.specimenCtr.preparatorCtr,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Preparator',
              hintText: 'Choose a preparator (default is cataloger)',
              hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
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
            onChanged: (String? uuid) {
              SpecimenServices(ref: ref).updateSpecimen(
                widget.specimenUuid,
                SpecimenCompanion(preparatorID: db.Value(uuid)),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setPersonalFieldNumber(String? personnelUuid) async {
    if (personnelUuid != null) {
      final personnelData = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(personnelUuid);
      final specimenServices = SpecimenServices(ref: ref);
      final specimen = await specimenServices.getSpecimen(widget.specimenUuid);
      final defaultMode = await ref.read(fieldIdModeNotifierProvider.future);
      final identifierMode = specimen.projectFieldNumber != null
          ? FieldIdMode.project
          : specimen.fieldNumber != null
          ? FieldIdMode.personnel
          : defaultMode;
      final personalFieldNumber = await specimenServices.getSpecimenFieldNumber(
        personnelUuid,
      );
      if (!mounted) return;

      bool hasSelected = _selectedPersonnel.contains(personnelUuid);
      int? currentFieldNumber =
          identifierMode == FieldIdMode.personnel &&
              personnelData.isRegisterField
          ? (hasSelected ? personalFieldNumber - 1 : personalFieldNumber)
          : null;
      setState(() {
        widget.specimenCtr.catalogerCtr = personnelUuid;
        widget.specimenCtr.determinerCtr = personnelUuid;
        widget.specimenCtr.preparatorCtr = personnelUuid;
        widget.specimenCtr.persFieldNumberCtr.text =
            currentFieldNumber?.toString() ?? '';
        if (!hasSelected) _selectedPersonnel.add(personnelUuid);
      });
      widget.onCatalogerChanged();

      if (!hasSelected &&
          identifierMode == FieldIdMode.personnel &&
          personnelData.isRegisterField) {
        await PersonnelServices(ref: ref).updatePersonnelEntry(
          personnelUuid,
          PersonnelCompanion(
            currentFieldNumber: db.Value(personalFieldNumber + 1),
          ),
        );
      }
      final companion = identifierMode == FieldIdMode.personnel
          ? SpecimenCompanion(
              catalogerID: db.Value(personnelUuid),
              determinerID: db.Value(personnelUuid),
              fieldNumber: db.Value(currentFieldNumber),
              projectFieldNumber: const db.Value(null),
              preparatorID: db.Value(personnelUuid),
            )
          : SpecimenCompanion(
              catalogerID: db.Value(personnelUuid),
              determinerID: db.Value(personnelUuid),
              preparatorID: db.Value(personnelUuid),
            );
      await specimenServices.updateSpecimen(widget.specimenUuid, companion);
    }
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
    final fieldIdModeProvider = ref.watch(fieldIdModeNotifierProvider);

    return fieldIdModeProvider.when(
      data: (fieldIdMode) {
        final showIdArea =
            (fieldIdMode == FieldIdMode.project) ||
            (fieldIdMode == FieldIdMode.personnel && catalogerUuid != '') ||
            showMore ||
            specimenCtr.museumIDCtr.text.isNotEmpty;

        return Visibility(
          visible: showIdArea,
          child: CommonIDForm(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Visibility(
                    visible:
                        showMore || specimenCtr.museumIDCtr.text.isNotEmpty,
                    child: CommonTextField(
                      controller: specimenCtr.museumIDCtr,
                      labelText: 'Museum ID',
                      hintText: 'Enter museum ID (if applicable)',
                      isLastField: true,
                      onChanged: (String? value) {
                        if (value != null) {
                          SpecimenServices(
                            ref: ref,
                          ).updateSpecimenSkipInvalidation(
                            specimenUuid,
                            SpecimenCompanion(museumID: db.Value(value)),
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
                  fieldIdMode: fieldIdMode,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Text('Loading...'),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

class SpecimenIdTile extends ConsumerWidget {
  const SpecimenIdTile({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.catalogerUuid,
    required this.fieldIdMode,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final String catalogerUuid;
  final FieldIdMode fieldIdMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storedMode = specimenCtr.projFieldNumberCtr.text.isNotEmpty
        ? FieldIdMode.project
        : specimenCtr.persFieldNumberCtr.text.isNotEmpty
        ? FieldIdMode.personnel
        : fieldIdMode;
    return _SpecimenFieldIdTile(
      specimenCtr: specimenCtr,
      specimenUuid: specimenUuid,
      catalogerUuid: catalogerUuid,
      mode: storedMode,
    );
  }
}

class _SpecimenFieldIdTile extends ConsumerWidget {
  const _SpecimenFieldIdTile({
    required this.specimenUuid,
    required this.specimenCtr,
    required this.catalogerUuid,
    required this.mode,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final String catalogerUuid;
  final FieldIdMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = mode == FieldIdMode.project
        ? ref
              .watch(currProjInfoProvider)
              .when(
                data: (project) =>
                    'Field ID: ${formatProjectFieldId(project, int.tryParse(specimenCtr.projFieldNumberCtr.text))}',
                loading: () => 'Field ID: Loading...',
                error: (error, stack) => 'Field ID: unavailable',
              )
        : _personnelTitle(ref);
    return ListTile(
      title: Text(title),
      trailing: IconButton(
        icon: Icon(Icons.edit_outlined, color: Theme.of(context).disabledColor),
        onPressed: () => _showSpecimenFieldIdEditor(
          context: context,
          specimenUuid: specimenUuid,
          specimenCtr: specimenCtr,
        ),
      ),
    );
  }

  String _personnelTitle(WidgetRef ref) {
    if (catalogerUuid.isEmpty) return 'Field ID: select a cataloger';
    return ref
        .watch(personnelNameProvider(catalogerUuid))
        .when(
          data: (personnel) {
            if (!personnel.isRegisterField) {
              return 'Field ID: cataloger is not set up for field numbers';
            }
            return 'Field ID: ${personnel.initial ?? ''}'
                '${specimenCtr.persFieldNumberCtr.text}';
          },
          loading: () => 'Field ID: Loading...',
          error: (error, stack) => 'Field ID: unavailable',
        );
  }
}

Future<void> _showSpecimenFieldIdEditor({
  required BuildContext context,
  required String specimenUuid,
  required SpecimenFormCtrModel specimenCtr,
}) async {
  final content = _SpecimenFieldIdEditor(
    specimenUuid: specimenUuid,
    specimenCtr: specimenCtr,
  );
  if (MediaQuery.sizeOf(context).width < 600) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: content,
        ),
      ),
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(padding: const EdgeInsets.all(24), child: content),
      ),
    ),
  );
}

class _SpecimenFieldIdEditor extends ConsumerStatefulWidget {
  const _SpecimenFieldIdEditor({
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  ConsumerState<_SpecimenFieldIdEditor> createState() =>
      _SpecimenFieldIdEditorState();
}

class _SpecimenFieldIdEditorState
    extends ConsumerState<_SpecimenFieldIdEditor> {
  final _numberController = TextEditingController();
  FieldIdMode? _mode;
  FieldIdMode? _originalMode;
  PersonnelData? _cataloger;
  ProjectData? _project;
  bool _acknowledged = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CommonProgressIndicator(),
      );
    }
    final mode = _mode!;
    final typeChanged = _originalMode != null && mode != _originalMode;
    final personnelUnavailable =
        mode == FieldIdMode.personnel &&
        (_cataloger == null || !_cataloger!.isRegisterField);
    final number = int.tryParse(_numberController.text);
    final canSave =
        !_saving &&
        !personnelUnavailable &&
        number != null &&
        (!typeChanged || _acknowledged);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Edit field ID', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SegmentedButton<FieldIdMode>(
          segments: const [
            ButtonSegment(
              value: FieldIdMode.personnel,
              icon: Icon(Icons.person_outline),
              label: Text('Personnel'),
            ),
            ButtonSegment(
              value: FieldIdMode.project,
              icon: Icon(Icons.folder_outlined),
              label: Text('Project'),
            ),
          ],
          selected: {mode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            setState(() {
              _mode = selection.single;
              _acknowledged = false;
              _numberController.text = _suggestedNumber(selection.single);
            });
          },
        ),
        const SizedBox(height: 16),
        if (personnelUnavailable)
          const Text(
            'Select a Cataloger with personal field-number registration '
            'enabled before assigning a personnel field ID.',
          )
        else ...[
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: mode == FieldIdMode.personnel
                  ? 'Personnel field number'
                  : 'Project catalog number',
              hintText: 'Enter a number',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text('Preview: ${_preview(mode, number)}'),
        ],
        if (typeChanged)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _acknowledged,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'I understand that changing identifier type removes the '
              'specimen’s previous field ID and that it may already appear '
              'in exports or on specimen labels.',
            ),
            onChanged: (value) =>
                setState(() => _acknowledged = value ?? false),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: canSave ? _save : null,
              child: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _load() async {
    final specimen = await SpecimenServices(
      ref: ref,
    ).getSpecimen(widget.specimenUuid);
    final defaultMode = await ref.read(fieldIdModeNotifierProvider.future);
    final project = await ProjectFieldIdServices(ref: ref).getProject();
    PersonnelData? cataloger;
    if (specimen.catalogerID != null) {
      cataloger = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(specimen.catalogerID!);
    }
    final storedMode = specimen.projectFieldNumber != null
        ? FieldIdMode.project
        : specimen.fieldNumber != null
        ? FieldIdMode.personnel
        : null;
    final mode = storedMode ?? defaultMode;
    if (!mounted) return;
    _project = project;
    _cataloger = cataloger;
    _originalMode = storedMode;
    _mode = mode;
    _numberController.text = mode == FieldIdMode.project
        ? (specimen.projectFieldNumber ?? project.currentCatalogNumber)
                  ?.toString() ??
              ''
        : (specimen.fieldNumber ?? cataloger?.currentFieldNumber)?.toString() ??
              '';
    setState(() => _loading = false);
  }

  String _suggestedNumber(FieldIdMode mode) {
    if (mode == FieldIdMode.project) {
      return _project?.currentCatalogNumber?.toString() ?? '';
    }
    return _cataloger?.currentFieldNumber?.toString() ?? '';
  }

  String _preview(FieldIdMode mode, int? number) {
    if (number == null) return '';
    if (mode == FieldIdMode.project) {
      return formatProjectFieldId(_project!, number);
    }
    return '${_cataloger?.initial ?? ''}$number';
  }

  Future<void> _save() async {
    final number = int.parse(_numberController.text);
    setState(() => _saving = true);
    final services = SpecimenServices(ref: ref);
    if (_mode == FieldIdMode.project) {
      await services.setProjectFieldIdentifier(
        specimenUuid: widget.specimenUuid,
        projectFieldNumber: number,
      );
      widget.specimenCtr.projFieldNumberCtr.text = number.toString();
      widget.specimenCtr.persFieldNumberCtr.clear();
      ref.invalidate(currProjInfoProvider);
    } else {
      await services.setPersonnelFieldIdentifier(
        specimenUuid: widget.specimenUuid,
        catalogerUuid: _cataloger!.uuid,
        fieldNumber: number,
      );
      widget.specimenCtr.persFieldNumberCtr.text = number.toString();
      widget.specimenCtr.projFieldNumberCtr.clear();
      ref.invalidate(personnelNameProvider(_cataloger!.uuid));
    }
    if (mounted) Navigator.pop(context);
  }
}
