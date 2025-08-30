import 'package:nahpu/services/personnel_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/projects/dashboard.dart';
import 'package:nahpu/screens/projects/personnel/avatars.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/validation.dart';
import 'package:flutter/services.dart';

const List<String> personnelRoleList = [
  'Cataloger',
  'Preparator only',
  'None',
];

class PersonnelFormPage extends ConsumerStatefulWidget {
  const PersonnelFormPage({
    super.key,
    required this.ctr,
    required this.personnelUuid,
    required this.isEditing,
  });

  final PersonnelFormCtrModel ctr;
  final String personnelUuid;
  final bool isEditing;

  @override
  PersonnelFormPageState createState() => PersonnelFormPageState();
}

class PersonnelFormPageState extends ConsumerState<PersonnelFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isShowMore = false;
  late String? initialRole;

  @override
  void initState() {
    _getRole();
    super.initState();
  }

  @override
  void dispose() {
    widget.ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PersonnelAvatar(
            ctr: widget.ctr,
          ),
          const SizedBox(height: 8),
          PersonnelNameField(
              ctr: widget.ctr,
              onChanged: (value) {
                if (widget.isEditing) {
                  _validateEditing();
                } else {
                  ref
                      .watch(personnelFormValidatorProvider.notifier)
                      .validateName(value);
                }
              }),
          TextFormField(
            controller: widget.ctr.affiliationCtr,
            decoration: const InputDecoration(
              labelText: 'Affiliation',
              hintText: 'Enter Affiliation',
            ),
            onChanged: (value) {
              if (widget.isEditing) {
                _validateEditing();
              }
            },
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.emailCtr.text.isNotEmpty,
            child: TextFormField(
              controller: widget.ctr.emailCtr,
              decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email',
                  errorText: ref.watch(personnelFormValidatorProvider).when(
                        data: (data) => data.email.errMsg,
                        loading: () => null,
                        error: (e, s) => null,
                      )),
              onChanged: (value) {
                if (widget.isEditing) {
                  _validateEditing();
                } else {
                  widget.ctr.emailCtr.value = TextEditingValue(
                      text: value.toLowerCase(),
                      selection: widget.ctr.emailCtr.selection);
                  ref
                      .watch(personnelFormValidatorProvider.notifier)
                      .validateEmail(
                        value,
                      );
                }
              },
            ),
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.phoneCtr.text.isNotEmpty,
            child: TextFormField(
              controller: widget.ctr.phoneCtr,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter phone',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                if (widget.isEditing) {
                  _validateEditing();
                }
              },
            ),
          ),
          DropdownButtonFormField(
            initialValue: widget.ctr.roleCtr,
            decoration: const InputDecoration(
              labelText: 'Specimen care role',
              hintText: 'Enter role',
            ),
            items: personnelRoleList
                .map(
                  (role) => DropdownMenuItem(
                    value: role,
                    child: CommonDropdownText(text: role),
                  ),
                )
                .toList(),
            onChanged: _isDisabled()
                ? null
                : (String? newValue) {
                    setState(() {
                      widget.ctr.roleCtr = newValue;
                    });
                  },
          ),
          Visibility(
            visible: widget.ctr.roleCtr == 'Cataloger',
            child: Column(
              children: [
                PersonnelInitialField(
                  ctr: widget.ctr,
                  onChanged: (value) {
                    widget.ctr.initialCtr.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: widget.ctr.initialCtr.selection,
                    );
                    if (widget.isEditing) {
                      _validateEditing();
                    } else {
                      ref
                          .watch(personnelFormValidatorProvider.notifier)
                          .validateInitial(value);
                    }
                  },
                ),
                CatalogerNumberField(
                  ctr: widget.ctr,
                  onChanged: (value) {
                    if (widget.isEditing) {
                      _validateEditing();
                    } else {
                      ref
                          .watch(personnelFormValidatorProvider.notifier)
                          .validateCollNum(value);
                    }
                  },
                ),
                Text(
                    'Initial and cataloger number will be used to generate Field ID.',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.noteCtr.text.isNotEmpty,
            child: TextField(
              controller: widget.ctr.noteCtr,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Write notes',
              ),
              maxLines: 3,
              onChanged: (value) {
                if (widget.isEditing) {
                  _validateEditing();
                }
              },
            ),
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  _isShowMore = !_isShowMore;
                });
              },
              child: Text(_isShowMore ? 'Show less' : 'Show more')),
          const SizedBox(
            height: 16,
          ),
          Wrap(
            spacing: 16,
            children: [
              SecondaryButton(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FormElevButton(
                label: widget.isEditing ? 'Update' : 'Add',
                icon: widget.isEditing ? Icons.check : Icons.add,
                enabled: _validateForm(),
                onPressed: () async {
                  widget.isEditing ? _updatePersonnel() : _addPersonnel();
                  ref.invalidate(projectPersonnelProvider);
                  ref.invalidate(personnelFormValidatorProvider);
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Dashboard(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isDisabled() {
    return widget.isEditing && initialRole == 'Cataloger';
  }

  void _getRole() {
    if (widget.isEditing) {
      initialRole = widget.ctr.roleCtr;
    }
    if (widget.ctr.roleCtr != null && widget.ctr.roleCtr!.isNotEmpty) {
      if (!personnelRoleList.contains(widget.ctr.roleCtr)) {
        widget.ctr.roleCtr = 'None';
        _updatePersonnel();
      }
    }
  }

  void _validateEditing() {
    ref.watch(personnelFormValidatorProvider.notifier).validateAll(widget.ctr);
  }

  bool _validateForm() {
    return widget.ctr.roleCtr == 'Cataloger'
        ? ref.read(personnelFormValidatorProvider).when(
              data: (data) => data.isValidCataloger,
              loading: () => false,
              error: (error, stackTrace) => false,
            )
        : ref.read(personnelFormValidatorProvider).when(
              data: (data) => data.isValidOther,
              loading: () => false,
              error: (error, stackTrace) => false,
            );
  }

  void _updatePersonnel() {
    PersonnelServices(ref: ref).updatePersonnelEntry(
      widget.personnelUuid,
      PersonnelCompanion(
        name: db.Value(widget.ctr.nameCtr.text),
        initial: db.Value(widget.ctr.initialCtr.text),
        affiliation: db.Value(widget.ctr.affiliationCtr.text),
        email: db.Value(widget.ctr.emailCtr.text),
        phone: db.Value(widget.ctr.phoneCtr.text),
        role: db.Value(widget.ctr.roleCtr),
        currentFieldNumber: db.Value(
          _getCollectorNumber(),
        ),
        photoPath: db.Value(widget.ctr.photoPathCtr.text),
        notes: db.Value(widget.ctr.noteCtr.text),
      ),
    );
  }

  Future<void> _addPersonnel() async {
    PersonnelServices personnelServices = PersonnelServices(ref: ref);
    String projectUuid = ref.read(projectUuidProvider);
    await personnelServices.createPersonnel(
      PersonnelCompanion(
        uuid: db.Value(widget.personnelUuid),
        name: db.Value(widget.ctr.nameCtr.text),
        initial: db.Value(widget.ctr.initialCtr.text),
        affiliation: db.Value(widget.ctr.affiliationCtr.text),
        email: db.Value(widget.ctr.emailCtr.text),
        phone: db.Value(widget.ctr.phoneCtr.text),
        role: db.Value(widget.ctr.roleCtr),
        currentFieldNumber: db.Value(
          _getCollectorNumber(),
        ),
        photoPath: db.Value(widget.ctr.photoPathCtr.text),
        notes: db.Value(widget.ctr.noteCtr.text),
      ),
    );
    await personnelServices.addPersonnelToProject(PersonnelListCompanion(
      personnelUuid: db.Value(widget.personnelUuid),
      projectUuid: db.Value(projectUuid),
    ));
  }

  int _getCollectorNumber() {
    if (widget.ctr.collectorNumCtr.text == '') {
      return 0;
    } else {
      return int.parse(widget.ctr.collectorNumCtr.text);
    }
  }
}

class PersonnelNameField extends ConsumerWidget {
  const PersonnelNameField({
    super.key,
    required this.ctr,
    required this.onChanged,
  });

  final PersonnelFormCtrModel ctr;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: ctr.nameCtr,
      decoration: InputDecoration(
        labelText: 'Name*',
        hintText: 'Enter a name (required)',
        errorText: ref.watch(personnelFormValidatorProvider).when(
              data: (data) => data.name.errMsg,
              loading: () => null,
              error: (e, s) => null,
            ),
      ),
      onChanged: onChanged,
    );
  }
}

class PersonnelInitialField extends ConsumerWidget {
  const PersonnelInitialField({
    super.key,
    required this.ctr,
    required this.onChanged,
  });

  final PersonnelFormCtrModel ctr;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: ctr.initialCtr,
      maxLength: 8,
      decoration: InputDecoration(
          labelText: 'Initials*',
          hintText: 'e.g., HH or H-H',
          errorText: ref.watch(personnelFormValidatorProvider).when(
                data: (data) => data.initial.errMsg,
                loading: () => null,
                error: (e, s) => null,
              )),
      inputFormatters: [
        LengthLimitingTextInputFormatter(5),
      ],
      onChanged: onChanged,
    );
  }
}

class CatalogerNumberField extends ConsumerWidget {
  const CatalogerNumberField({
    super.key,
    required this.ctr,
    required this.onChanged,
  });

  final PersonnelFormCtrModel ctr;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      enabled: ctr.roleCtr == 'Cataloger',
      controller: ctr.collectorNumCtr,
      decoration: InputDecoration(
          labelText: 'Cataloger Number*',
          hintText: '1234',
          errorText: ref.watch(personnelFormValidatorProvider).when(
                data: (data) => data.collNum.errMsg,
                loading: () => null,
                error: (e, s) => null,
              )),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9]+'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
