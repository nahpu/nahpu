import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as db;
import 'package:timezone/timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  CatalogFmt? _catalogFmt;

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
                    ? TaxonGroupFields(
                        onCatalogFmtChanged: (CatalogFmt? value) {
                        _catalogFmt = value;
                      })
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
                        widget.projectCtr.timeZoneCtr.text.isNotEmpty,
                    child: TimeZoneField(
                      projectCtr: widget.projectCtr,
                      onChanged: (_) {
                        _validateEditing();
                      },
                    )),
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
                          context, widget.projectCtr.startDateCtr.dateTime);
                      if (selectedDate != null) {
                        widget.projectCtr.startDateCtr.dateTime = selectedDate;
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
                          context, widget.projectCtr.endDateCtr.dateTime);
                      if (selectedDate != null) {
                        widget.projectCtr.endDateCtr.dateTime = selectedDate;
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
        widget.projectCtr.timeZoneCtr.text.isNotEmpty &&
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

  Future<DateTime?> _showDate(BuildContext context, DateTime? initialDate) {
    return showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
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
      timeZone: db.Value(widget.projectCtr.timeZoneCtr.text),
      startDate: db.Value(widget.projectCtr.startDateCtr.date),
      endDate: db.Value(widget.projectCtr.endDateCtr.date),
      created: db.Value(getSystemDateTime()),
      lastAccessed: db.Value(getSystemDateTime()),
    );

    ProjectServices(ref: ref).createProject(projectData);

    if (_catalogFmt != null) {
      ref.read(catalogFmtNotifierProvider.notifier).set(_catalogFmt!);
    }
  }

  void _updateProject() {
    final projectData = ProjectCompanion(
      name: db.Value(widget.projectCtr.projectNameCtr.text),
      description: db.Value(widget.projectCtr.descriptionCtr.text),
      principalInvestigator: db.Value(widget.projectCtr.pICtr.text),
      location: db.Value(widget.projectCtr.locationCtr.text),
      timeZone: db.Value(widget.projectCtr.timeZoneCtr.text),
      startDate: db.Value(widget.projectCtr.startDateCtr.date),
      endDate: db.Value(widget.projectCtr.endDateCtr.date),
      created: db.Value(widget.projectCtr.createdCtr),
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

extension LocationDropdownText on Location {
  String toText() {
    if (name == 'UTC') return '(UTC) Coordinated Universal Time';

    final utcOffset = (currentTimeZone.offset / 3.6e6);
    final plusMinus = utcOffset >= 0 ? '+' : '-';
    final utcOffsetHours = utcOffset.toInt();
    final utcOffsetMinutes = ((utcOffset % 1.0) * 60).toInt();

    final paddedHour = utcOffsetHours.abs().toString().padLeft(2, '0');
    final paddedMinutes = utcOffsetMinutes.toString().padLeft(2, '0');

    return '(UTC$plusMinus$paddedHour:$paddedMinutes) $name';
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

class TimeZoneField extends ConsumerWidget {
  const TimeZoneField({
    super.key,
    required this.projectCtr,
    required this.onChanged,
  });

  final ProjectFormCtrModel projectCtr;
  final Null Function(String?)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonFormField<String>(
      initialValue: projectCtr.timeZoneCtr.text,
      decoration: const InputDecoration(
          labelText: 'Timezone', hintText: 'Choose a timezone'),
      items: _timeZoneDropdown(),
      onChanged: (String? value) {
        if (value != null) {
          projectCtr.timeZoneCtr.text = value;
        }
        onChanged!(value);
      },
    );
  }

  List<DropdownMenuItem<String>> _timeZoneDropdown() {
    final locations = timeZoneDatabase.locations.values.toList();
    if (kDebugMode) {
      print(locations.map((e) => e.name).toList().where((e) => e == '').length);
    }

    // Sort locations by UTC offset, then name
    locations.sort((a, b) {
      int offsetCompare =
          a.currentTimeZone.offset.compareTo(b.currentTimeZone.offset);
      if (offsetCompare != 0) {
        return offsetCompare;
      }
      return a.name.compareTo(b.name);
    });

    final locationItems = locations
        .map((e) => DropdownMenuItem<String>(
            value: e.name,
            child: CommonDropdownText(text: LocationDropdownText(e).toText())))
        .toList();

    final chooseOneItem = DropdownMenuItem(
        value: '', child: HintDropdownText(text: 'Choose a timezone'));

    locationItems.insert(0, chooseOneItem);

    return locationItems;
  }
}

class TaxonGroupFields extends ConsumerStatefulWidget {
  const TaxonGroupFields({super.key, required this.onCatalogFmtChanged});

  final void Function(CatalogFmt? cFmt) onCatalogFmtChanged;

  @override
  TaxonGroupFieldsState createState() => TaxonGroupFieldsState();
}

class TaxonGroupFieldsState extends ConsumerState<TaxonGroupFields> {
  ProjectType? _projectType;

  @override
  Widget build(BuildContext context) {
    return ref.watch(catalogFmtNotifierProvider).when(
          data: (fmt) {
            // Set project type on initial load based on current catalog fmt
            _projectType ??= fmt == CatalogFmt.fossils
                ? ProjectType.fossils
                : ProjectType.extantTaxa;
            return _buildDropdownMenu(fmt);
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        );
  }

  Widget _buildDropdownMenu(CatalogFmt catalogFmt) {
    return Column(children: [
      DropdownButtonFormField<ProjectType>(
          decoration: const InputDecoration(
            labelText: 'Project type',
          ),
          items: [
            DropdownMenuItem(
                value: ProjectType.extantTaxa,
                child: CommonDropdownText(text: 'Extant taxa')),
            DropdownMenuItem(
              value: ProjectType.fossils,
              child: CommonDropdownText(text: 'Fossils'),
            )
          ],
          initialValue: catalogFmt == CatalogFmt.fossils
              ? ProjectType.fossils
              : ProjectType.extantTaxa,
          onChanged: (ProjectType? newValue) {
            setState(() {
              _projectType = newValue;
              widget.onCatalogFmtChanged(
                  getDefaultCatalogFmt(_projectType!, catalogFmt));
            });
          }),
      _projectType == ProjectType.extantTaxa
          ? DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: 'Main taxon group',
                hintText: 'Choose a taxon group',
              ),
              items: extantTaxaGroupList
                  .map((taxonGroup) => DropdownMenuItem(
                        value: taxonGroup,
                        child: CommonDropdownText(text: taxonGroup),
                      ))
                  .toList(),
              initialValue: matchCatFmtToTaxonGroup(
                  getDefaultCatalogFmt(_projectType!, catalogFmt)),
              onChanged: (String? newValue) {
                catalogFmt = matchTaxonGroupToCatFmt(newValue!);
                widget.onCatalogFmtChanged(catalogFmt);
              },
            )
          : const SizedBox.shrink()
    ]);
  }

  CatalogFmt getDefaultCatalogFmt(
      ProjectType projectType, CatalogFmt currCatalogFmt) {
    if (projectType == ProjectType.fossils) {
      return CatalogFmt.fossils;
    } else {
      if (currCatalogFmt == CatalogFmt.fossils) {
        return CatalogFmt.mammals;
      } else {
        return currCatalogFmt;
      }
    }
  }
}
