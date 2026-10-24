import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/projects/orcid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/personnel/avatars.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/validation.dart';
import 'package:flutter/services.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

const List<String> personnelRoleList = [
  'Cataloger',
  'Determiner only',
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
  late bool _isShowMore;
  late String? initialRole;

  @override
  void initState() {
    _isShowMore = widget.isEditing;
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
    final form = ref.watch(personnelFormValidatorProvider).value;
    final canSubmit = _orcidError == null && _isFormValid(form);
    return Form(
      key: _formKey,
      child: ScrollableConstrainedLayout(
        footer: FormButton(
          isEditing: widget.isEditing,
          onSubmitted: canSubmit
              ? () async {
                  if (widget.isEditing) {
                    await _updatePersonnel();
                  } else {
                    await _addPersonnel();
                  }
                  PersonnelServices(ref: ref).invalidatePersonnel();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormSection(
              title: context.l10n.projectPersonnelProfile,
              child: Column(
                children: [
                  PersonnelAvatar(ctr: widget.ctr),
                  const SizedBox(height: 8),
                  PersonnelNameField(
                    ctr: widget.ctr,
                    onChanged: (value) {
                      if (widget.isEditing) {
                        _validateEditing();
                      } else {
                        ref
                            .read(personnelFormValidatorProvider.notifier)
                            .validateName(value);
                      }
                    },
                  ),
                  TextFormField(
                    controller: widget.ctr.affiliationCtr,
                    decoration: InputDecoration(
                      labelText: context.l10n.projectPersonnelAffiliation,
                      hintText: context.l10n.projectPersonnelAffiliationHint,
                    ),
                    onChanged: (_) {
                      if (widget.isEditing) _validateEditing();
                    },
                  ),
                  TextFormField(
                    controller: widget.ctr.orcidCtr,
                    decoration: InputDecoration(
                      labelText: context.l10n.projectPersonnelOrcid,
                      hintText: '0000-0000-0000-0000',
                      errorText: _orcidError,
                    ),
                    onChanged: (_) {
                      setState(() {});
                      if (widget.isEditing) _validateEditing();
                    },
                  ),
                ],
              ),
            ),
            FormSection(
              title: context.l10n.projectPersonnelSpecimenCare,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: widget.ctr.roleCtr,
                    decoration: InputDecoration(
                      labelText: context.l10n.projectPersonnelSpecimenCareRole,
                      hintText: context.l10n.projectPersonnelRoleHint,
                    ),
                    items: personnelRoleList
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: CommonDropdownText(
                              text: personnelRoleLabel(context.l10n, role),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _isDisabled()
                        ? null
                        : (newValue) {
                            setState(() => widget.ctr.roleCtr = newValue);
                            ref
                                .read(personnelFormValidatorProvider.notifier)
                                .validateAll(widget.ctr);
                          },
                  ),
                  if (widget.ctr.roleCtr == 'Cataloger') ...[
                    Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context
                              .l10n
                              .projectPersonnelRegisterPersonalFieldNumber,
                        ),
                        subtitle: Text(
                          context.l10n.projectPersonnelRegisterFieldNumberNote,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        value: widget.ctr.isRegisterField,
                        onChanged: (value) {
                          setState(() => widget.ctr.isRegisterField = value);
                          ref
                              .read(personnelFormValidatorProvider.notifier)
                              .validateAll(widget.ctr);
                        },
                      ),
                    ),
                    if (widget.ctr.isRegisterField) ...[
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
                                .read(personnelFormValidatorProvider.notifier)
                                .validateInitial(
                                  widget.ctr.initialCtr.text,
                                  widget.ctr.isRegisterField,
                                );
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
                                .read(personnelFormValidatorProvider.notifier)
                                .validateCollNum(
                                  value,
                                  widget.ctr.isRegisterField,
                                );
                          }
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (_isShowMore)
              FormSection(
                title: context.l10n.projectPersonnelContact,
                child: Column(
                  children: [
                    TextFormField(
                      controller: widget.ctr.emailCtr,
                      decoration: InputDecoration(
                        labelText: context.l10n.projectPersonnelEmail,
                        hintText: context.l10n.projectPersonnelEmailHint,
                        errorText: ref
                            .watch(personnelFormValidatorProvider)
                            .when(
                              data: (data) => data.email.errMsg,
                              loading: () => null,
                              error: (e, s) => null,
                            ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        if (widget.isEditing) {
                          _validateEditing();
                        } else {
                          widget.ctr.emailCtr.value = TextEditingValue(
                            text: value.toLowerCase(),
                            selection: widget.ctr.emailCtr.selection,
                          );
                          ref
                              .read(personnelFormValidatorProvider.notifier)
                              .validateEmail(value);
                        }
                      },
                    ),
                    TextFormField(
                      controller: widget.ctr.phoneCtr,
                      decoration: InputDecoration(
                        labelText: context.l10n.projectPersonnelPhone,
                        hintText: context.l10n.projectPersonnelPhoneHint,
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) {
                        if (widget.isEditing) _validateEditing();
                      },
                    ),
                  ],
                ),
              ),
            if (_isShowMore)
              FormSection(
                title: context.l10n.projectPersonnelNotes,
                child: TextField(
                  controller: widget.ctr.noteCtr,
                  decoration: InputDecoration(
                    labelText: context.l10n.projectPersonnelNotes,
                    hintText: context.l10n.projectPersonnelNotesHint,
                  ),
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (_) => _validateEditing(),
                ),
              ),
            ShowMoreButton(
              onPressed: () => setState(() => _isShowMore = !_isShowMore),
              showMore: _isShowMore,
            ),
          ],
        ),
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
    ref.read(personnelFormValidatorProvider.notifier).validateAll(widget.ctr);
  }

  bool _isFormValid(PersonnelForm? form) {
    if (form == null) return false;
    return widget.ctr.roleCtr == 'Cataloger'
        ? form.isValidCataloger
        : form.isValidOther;
  }

  String? get _orcidError {
    final value = widget.ctr.orcidCtr.text;
    if (value.isEmpty || isValidOrcid(value)) return null;
    return context.l10n.projectPersonnelOrcidInvalid;
  }

  Future<void> _updatePersonnel() async {
    await PersonnelServices(ref: ref).updatePersonnelEntry(
      widget.personnelUuid,
      PersonnelCompanion(
        name: db.Value(widget.ctr.nameCtr.text),
        initial: db.Value(widget.ctr.initialCtr.text),
        affiliation: db.Value(widget.ctr.affiliationCtr.text),
        email: db.Value(widget.ctr.emailCtr.text),
        phone: db.Value(widget.ctr.phoneCtr.text),
        orcid: db.Value(
          widget.ctr.orcidCtr.text.isEmpty ? null : widget.ctr.orcidCtr.text,
        ),
        role: db.Value(widget.ctr.roleCtr),
        isRegisterField: db.Value(widget.ctr.isRegisterField),
        currentFieldNumber: db.Value(_getCollectorNumber()),
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
        orcid: db.Value(
          widget.ctr.orcidCtr.text.isEmpty ? null : widget.ctr.orcidCtr.text,
        ),
        role: db.Value(widget.ctr.roleCtr),
        isRegisterField: db.Value(widget.ctr.isRegisterField),
        currentFieldNumber: db.Value(_getCollectorNumber()),
        photoPath: db.Value(widget.ctr.photoPathCtr.text),
        notes: db.Value(widget.ctr.noteCtr.text),
      ),
    );
    await personnelServices.addPersonnelToProject(
      PersonnelListCompanion(
        personnelUuid: db.Value(widget.personnelUuid),
        projectUuid: db.Value(projectUuid),
      ),
    );
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
        labelText: context.l10n.projectPersonnelNameLabel,
        hintText: context.l10n.projectPersonnelNameHint,
        errorText: ref
            .watch(personnelFormValidatorProvider)
            .when(
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
        labelText: context.l10n.projectPersonnelInitialsLabel,
        hintText: context.l10n.projectPersonnelInitialsHint,
        errorText: ref
            .watch(personnelFormValidatorProvider)
            .when(
              data: (data) => data.initial.errMsg,
              loading: () => null,
              error: (e, s) => null,
            ),
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(5)],
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
        labelText: context.l10n.projectPersonnelCatalogerNumberLabel,
        hintText: '1234',
        errorText: ref
            .watch(personnelFormValidatorProvider)
            .when(
              data: (data) => data.collNum.errMsg,
              loading: () => null,
              error: (e, s) => null,
            ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]+'))],
      onChanged: onChanged,
    );
  }
}
