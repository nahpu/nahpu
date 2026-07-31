import 'package:drift/drift.dart' as db;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/validation.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:timezone/timezone.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ProjectForm extends ConsumerStatefulWidget {
  const ProjectForm({
    super.key,
    required this.projectCtr,
    required this.projectUuid,
    this.isEditing = false,
    this.returnToHome = false,
  });

  final ProjectFormCtrModel projectCtr;
  final String projectUuid;
  final bool isEditing;
  final bool returnToHome;

  @override
  ConsumerState<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends ConsumerState<ProjectForm> {
  String? _initialProjectName;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _initialProjectName = widget.isEditing
        ? widget.projectCtr.projectNameCtr.text
        : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  @override
  Widget build(BuildContext context) {
    final validator = ref.watch(projectFormValidatorProvider);
    final nameError = validator.when(
      data: (data) => data.projectName.errMsg ?? data.existingProject.errMsg,
      loading: () => null,
      error: (_, _) => null,
    );
    return Form(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: NahpuContentWidth.projectForm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProjectDetailsSections(
                  projectCtr: widget.projectCtr,
                  projectNameError: nameError,
                  onChanged: (_) => _validate(),
                ),
                if (_saveError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _saveError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    SecondaryButton(
                      text: 'Cancel',
                      onPressed: _saving ? () {} : _cancel,
                    ),
                    FormElevButton(
                      onPressed: _save,
                      label: _saving
                          ? 'Saving…'
                          : widget.isEditing
                          ? 'Update'
                          : 'Create',
                      icon: widget.isEditing ? Icons.check : Icons.add,
                      enabled: !_saving && _isValid(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _validate() async {
    if (widget.isEditing) {
      await ref
          .read(projectFormValidatorProvider.notifier)
          .validateOnEditing(
            _initialProjectName,
            widget.projectCtr.projectNameCtr.text,
          );
    } else {
      await ref
          .read(projectFormValidatorProvider.notifier)
          .validateOnCreate(widget.projectCtr.projectNameCtr.text);
    }
  }

  bool _isValid() {
    return ref
        .read(projectFormValidatorProvider)
        .when(
          data: (data) => data.isValid,
          loading: () => false,
          error: (_, _) => false,
        );
  }

  Future<void> _save() async {
    await _validate();
    if (!_isValid() || !mounted) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final companion = ProjectCompanion(
        uuid: widget.isEditing
            ? const db.Value.absent()
            : db.Value(widget.projectUuid),
        name: db.Value(widget.projectCtr.projectNameCtr.text.trim()),
        description: db.Value(widget.projectCtr.descriptionCtr.text.trim()),
        principalInvestigator: db.Value(widget.projectCtr.pICtr.text.trim()),
        accession: db.Value(widget.projectCtr.accessionCtr.text.trim()),
        location: db.Value(widget.projectCtr.locationCtr.text.trim()),
        timeZone: db.Value(widget.projectCtr.timeZoneCtr.text),
        startDate: db.Value(widget.projectCtr.startDateCtr.date),
        endDate: db.Value(widget.projectCtr.endDateCtr.date),
        catalogNumberPrefix: widget.isEditing
            ? const db.Value.absent()
            : db.Value(widget.projectCtr.catalogNumberPrefixCtr.text),
        currentCatalogNumber: widget.isEditing
            ? const db.Value.absent()
            : db.Value(
                int.tryParse(widget.projectCtr.currentCatalogNumberCtr.text),
              ),
        catalogNumberSuffix: widget.isEditing
            ? const db.Value.absent()
            : db.Value(widget.projectCtr.catalogNumberSuffixCtr.text),
        created: db.Value(
          widget.isEditing ? widget.projectCtr.createdCtr : getSystemDateTime(),
        ),
        lastAccessed: db.Value(getSystemDateTime()),
      );
      final services = ProjectServices(ref: ref);
      if (widget.isEditing) {
        await services.updateProject(widget.projectUuid, companion);
      } else {
        await services.createProject(companion);
      }
      if (!mounted) return;
      _goToDashboard();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saveError = 'Could not save project: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancel() {
    ref.invalidate(projectFormValidatorProvider);
    Navigator.pop(context);
  }

  void _goToDashboard() {
    ref.read(projectNavbarIndexProvider.notifier).updateState(0);
    if (widget.isEditing) {
      if (widget.returnToHome) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ProjectShell.popToShell(context);
      }
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(ProjectShell.route());
  }
}

class ProjectDetailsSections extends StatelessWidget {
  const ProjectDetailsSections({
    super.key,
    required this.projectCtr,
    required this.onChanged,
    this.projectNameError,
  });

  final ProjectFormCtrModel projectCtr;
  final ValueChanged<String?> onChanged;
  final String? projectNameError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormSection(
          title: 'Project details',
          child: Column(
            children: [
              ProjectFormField(
                controller: projectCtr.projectNameCtr,
                maxLength: 25,
                labelText: 'Project name*',
                hintText: 'Enter the project name (required)',
                inputFormatters: [LengthLimitingTextInputFormatter(25)],
                errorText: projectNameError,
                onChanged: onChanged,
              ),
              ProjectFormField(
                controller: projectCtr.descriptionCtr,
                labelText: 'Project description',
                hintText: 'Enter a short project description',
                maxLines: 3,
                maxLength: 160,
                onChanged: onChanged,
              ),
              ProjectFormField(
                controller: projectCtr.pICtr,
                labelText: 'Principal investigator',
                hintText: 'Enter the principal investigator',
                onChanged: onChanged,
              ),
              ProjectFormField(
                controller: projectCtr.accessionCtr,
                labelText: 'Accession',
                hintText: 'Enter an institutional accession',
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        FormSection(
          title: 'Place and time',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProjectFormField(
                controller: projectCtr.locationCtr,
                labelText: 'Location',
                hintText: 'Enter the general project location',
                onChanged: onChanged,
              ),
              TimeZoneField(projectCtr: projectCtr, onChanged: onChanged),
              const SizedBox(height: 8),
              Text(
                'NAHPU stores collection dates and times as entered in local '
                'field time; it does not convert them. The project time zone '
                'records that context so exchanged data can be interpreted '
                'consistently by third-party collection management systems.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        FormSection(
          title: 'Project dates',
          child: Column(
            children: [
              ProjectDateField(
                controller: projectCtr.startDateCtr,
                label: 'Start date',
                onChanged: onChanged,
              ),
              ProjectDateField(
                controller: projectCtr.endDateCtr,
                label: 'End date',
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProjectDateField extends StatelessWidget {
  const ProjectDateField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final DateEditingController controller;
  final String label;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Choose a date',
        suffixIcon: controller.text.isEmpty
            ? const Icon(Icons.calendar_today_outlined)
            : IconButton(
                tooltip: 'Clear $label',
                onPressed: () {
                  controller.date = null;
                  onChanged(null);
                },
                icon: const Icon(Icons.clear),
              ),
      ),
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: controller.dateTime ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          controller.dateTime = selectedDate;
          onChanged(controller.text);
        }
      },
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
    this.onChanged,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String?>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );
  }
}

class TimeZoneField extends StatelessWidget {
  const TimeZoneField({
    super.key,
    required this.projectCtr,
    required this.onChanged,
  });

  final ProjectFormCtrModel projectCtr;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: projectCtr.timeZoneCtr.text,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Time zone',
        hintText: 'Choose a time zone',
      ),
      items: _timeZoneDropdown(),
      onChanged: (value) {
        projectCtr.timeZoneCtr.text = value ?? '';
        onChanged(value);
      },
    );
  }

  List<DropdownMenuItem<String>> _timeZoneDropdown() {
    final locations = timeZoneDatabase.locations.values.toList()
      ..sort((a, b) {
        final offsetCompare = a.currentTimeZone.offset.compareTo(
          b.currentTimeZone.offset,
        );
        return offsetCompare != 0 ? offsetCompare : a.name.compareTo(b.name);
      });
    return [
      const DropdownMenuItem(
        value: '',
        child: HintDropdownText(text: 'Choose a time zone'),
      ),
      ...locations.map(
        (location) => DropdownMenuItem(
          value: location.name,
          child: CommonDropdownText(text: location.toText()),
        ),
      ),
    ];
  }
}

extension LocationDropdownText on Location {
  String toText() {
    if (name == 'UTC') return '(UTC) Coordinated Universal Time';
    final offset = currentTimeZone.offset.inMilliseconds / 3.6e6;
    final sign = offset >= 0 ? '+' : '-';
    final hours = offset.toInt().abs().toString().padLeft(2, '0');
    final minutes = ((offset.abs() % 1.0) * 60).round().toString().padLeft(
      2,
      '0',
    );
    return '(UTC$sign$hours:$minutes) $name';
  }
}

class TaxonGroupFields extends ConsumerWidget {
  const TaxonGroupFields({super.key, this.value, this.onChanged});

  final CatalogFmt? value;
  final ValueChanged<CatalogFmt>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(catalogFmtNotifierProvider)
        .when(
          data: (stored) {
            final selected = value ?? stored;
            return DropdownButtonFormField<CatalogFmt>(
              decoration: const InputDecoration(
                labelText: 'Main taxon group',
                hintText: 'Choose a taxon group',
              ),
              items: CatalogFmt.values
                  .map(
                    (format) => DropdownMenuItem(
                      value: format,
                      child: CommonDropdownText(
                        text: matchCatFmtToTaxonGroup(format),
                      ),
                    ),
                  )
                  .toList(),
              initialValue: selected,
              onChanged: (format) {
                if (format == null) return;
                if (onChanged != null) {
                  onChanged!(format);
                } else {
                  ref.read(catalogFmtNotifierProvider.notifier).set(format);
                }
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Could not load taxon setting: $error'),
        );
  }
}
