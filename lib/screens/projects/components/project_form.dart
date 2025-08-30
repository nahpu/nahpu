import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/projects/dashboard.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/validation.dart';

class ProjectForm extends ConsumerStatefulWidget {
  const ProjectForm({
    super.key,
    required this.projectCtr,
    required this.projectUuid,
    this.isEditing = false,
  });

  final ProjectFormCtrModel projectCtr;
  final String projectUuid;
  final bool isEditing;

  @override
  ProjectFormState createState() => ProjectFormState();
}

class ProjectFormState extends ConsumerState<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  String? initialProjectName;
  bool _showMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getInitialProjectName();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final validator = ref.watch(projectFormValidatorProvider);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                ProjectFormField(
                    controller: widget.projectCtr.projectNameCtr,
                    maxLength: 25,
                    labelText: 'Project name*',
                    hintText: 'Enter the name of the project (required)',
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(25),
                    ],
                    onChanged: (value) async {
                      if (widget.isEditing) {
                        ref
                            .watch(projectFormValidatorProvider.notifier)
                            .validateOnEditing(initialProjectName,
                                widget.projectCtr.projectNameCtr.text);
                      } else {
                        await ref
                            .watch(projectFormValidatorProvider.notifier)
                            .validateProjectName(value);
                        await ref
                            .watch(projectFormValidatorProvider.notifier)
                            .checkProjectNameExists(value);
                      }
                    },
                    errorText: validator.when(
                      data: (data) {
                        if (data.projectName.errMsg != null) {
                          return data.projectName.errMsg;
                        }

                        if (data.existingProject.errMsg != null) {
                          return data.existingProject.errMsg;
                        }

                        if (data.projectName.errMsg != null &&
                            data.existingProject.errMsg != null) {
                          return '${data.projectName.errMsg} '
                              '${data.existingProject.errMsg}}';
                        }
                        return null;
                      },
                      loading: () => null,
                      error: (err, stack) => null,
                    )),
                ProjectFormField(
                  controller: widget.projectCtr.descriptionCtr,
                  labelText: 'Project description',
                  hintText: 'Enter a description of the project (optional)',
                  maxLines: 2,
                  maxLength: 120,
                  onChanged: (_) {
                    _validateEditing();
                  },
                ),
                Visibility(
                  visible: _showMore || widget.projectCtr.pICtr.text.isNotEmpty,
                  child: ProjectFormField(
                    controller: widget.projectCtr.pICtr,
                    labelText: 'Principal Investigator',
                    hintText: 'Enter PI name of the project (optional)',
                    onChanged: (_) {
                      _validateEditing();
                    },
                  ),
                ),
                !widget.isEditing
                    ? const TaxonGroupFields()
                    : const SizedBox.shrink(),
                Visibility(
                  visible: _showMore ||
                      widget.projectCtr.locationCtr.text.isNotEmpty,
                  child: ProjectFormField(
                    controller: widget.projectCtr.locationCtr,
                    labelText: 'Location',
                    hintText: 'Enter location of the project (optional)',
                    onChanged: (_) {
                      _validateEditing();
                    },
                  ),
                ),
                Visibility(
                  visible: _showMore ||
                      widget.projectCtr.startDateCtr.text.isNotEmpty,
                  child: TextField(
                    controller: widget.projectCtr.startDateCtr,
                    decoration: const InputDecoration(
                      labelText: 'Start date',
                      hintText: 'Enter the project start date',
                    ),
                    onTap: () async {
                      DateTime? selectedDate = await _showDate(
                        context,
                      );
                      if (selectedDate != null) {
                        widget.projectCtr.startDateCtr.text =
                            DateFormat.yMMMd().format(selectedDate);
                      }
                      _validateEditing();
                    },
                  ),
                ),
                Visibility(
                  visible:
                      _showMore || widget.projectCtr.endDateCtr.text.isNotEmpty,
                  child: TextField(
                    controller: widget.projectCtr.endDateCtr,
                    decoration: const InputDecoration(
                      labelText: 'End date',
                      hintText: 'Enter the project end date',
                    ),
                    onTap: () async {
                      DateTime? selectedDate = await _showDate(
                        context,
                      );
                      if (selectedDate != null) {
                        widget.projectCtr.endDateCtr.text =
                            DateFormat.yMMMd().format(selectedDate);
                      }
                      _validateEditing();
                    },
                  ),
                ),
                if (!_allControllersFilled())
                  ShowMoreButton(
                    onPressed: () {
                      setState(() {
                        _showMore = !_showMore;
                      });
                    },
                    showMore: _showMore,
                  ),
                const SizedBox(height: 16),
                Wrap(spacing: 10, children: [
                  SecondaryButton(
                    text: 'Cancel',
                    onPressed: () {
                      ref.invalidate(projectFormValidatorProvider);
                      Navigator.pop(context);
                    },
                  ),
                  FormElevButton(
                    onPressed: () {
                      widget.isEditing ? _updateProject() : _createProject();
                      _goToDashboard();
                    },
                    label: widget.isEditing ? 'Update' : 'Create',
                    icon: widget.isEditing ? Icons.check : Icons.add,
                    enabled: _isValid(),
                  )
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValid() {
    final validator = ref.read(projectFormValidatorProvider);
    return validator.when(
      data: (data) => data.isValid,
      loading: () => false,
      error: (err, stack) => false,
    );
  }

  Future<void> _validateEditing() async {
    if (widget.isEditing) {
      ref.watch(projectFormValidatorProvider.notifier).validateOnEditing(
          initialProjectName, widget.projectCtr.projectNameCtr.text);
    }
  }

  bool _allControllersFilled() {
    return widget.projectCtr.projectNameCtr.text.isNotEmpty &&
        widget.projectCtr.descriptionCtr.text.isNotEmpty &&
        widget.projectCtr.pICtr.text.isNotEmpty &&
        widget.projectCtr.locationCtr.text.isNotEmpty &&
        widget.projectCtr.startDateCtr.text.isNotEmpty &&
        widget.projectCtr.endDateCtr.text.isNotEmpty;
  }

  Future<void> _getInitialProjectName() async {
    final name =
        await ProjectServices(ref: ref).getProjectName(widget.projectUuid);
    setState(() {
      initialProjectName = name;
    });
  }

  Future<DateTime?> _showDate(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030)); // Prevent user from selecting future dates
  }

  void _createProject() {
    final projectData = ProjectCompanion(
      uuid: db.Value(widget.projectUuid),
      name: db.Value(widget.projectCtr.projectNameCtr.text),
      description: db.Value(widget.projectCtr.descriptionCtr.text),
      principalInvestigator: db.Value(widget.projectCtr.pICtr.text),
      location: db.Value(widget.projectCtr.locationCtr.text),
      startDate: db.Value(widget.projectCtr.startDateCtr.text),
      endDate: db.Value(widget.projectCtr.endDateCtr.text),
      created: db.Value(getSystemDateTime()),
      lastAccessed: db.Value(getSystemDateTime()),
    );

    ProjectServices(ref: ref).createProject(projectData);
  }

  void _updateProject() {
    final projectData = ProjectCompanion(
      name: db.Value(widget.projectCtr.projectNameCtr.text),
      description: db.Value(widget.projectCtr.descriptionCtr.text),
      principalInvestigator: db.Value(widget.projectCtr.pICtr.text),
      location: db.Value(widget.projectCtr.locationCtr.text),
      startDate: db.Value(widget.projectCtr.startDateCtr.text),
      endDate: db.Value(widget.projectCtr.endDateCtr.text),
      created: db.Value(getSystemDateTime()),
      lastAccessed: db.Value(getSystemDateTime()),
    );

    ProjectServices(ref: ref).updateProject(widget.projectUuid, projectData);
  }

  Future<void> _goToDashboard() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
    );
  }
}

class ProjectFormField extends StatelessWidget {
  const ProjectFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.maxLength,
    this.maxLines,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.onSaved,
    this.onChanged,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  final String? Function(String?)? onSaved;
  final Function(String?)? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
          labelText: labelText, hintText: hintText, errorText: errorText),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }
}

class TaxonGroupFields extends ConsumerWidget {
  const TaxonGroupFields({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(catalogFmtNotifierProvider).when(
          data: (fmt) => _buildDropdownMenu(fmt, ref),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        );
  }

  Widget _buildDropdownMenu(CatalogFmt catalogFmt, WidgetRef ref) {
    return DropdownButtonFormField(
      decoration: const InputDecoration(
        labelText: 'Main Taxon Group',
        hintText: 'Choose a taxon group',
      ),
      items: taxonGroupList
          .map((taxonGroup) => DropdownMenuItem(
                value: taxonGroup,
                child: CommonDropdownText(text: taxonGroup),
              ))
          .toList(),
      initialValue: matchCatFmtToTaxonGroup(catalogFmt),
      onChanged: (String? newValue) {
        catalogFmt = matchTaxonGroupToCatFmt(newValue!);
        ref.read(catalogFmtNotifierProvider.notifier).set(catalogFmt);
      },
    );
  }
}
