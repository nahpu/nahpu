import 'package:drift/drift.dart' as db;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/projects/components/project_form.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/record_exchange/project_exchange_service.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

enum _CreateProjectStep {
  welcome('Welcome'),
  projectInformation('Project information'),
  mainTaxon('Main taxon'),
  fieldId('Field ID'),
  cataloger('Cataloger'),
  review('Review');

  const _CreateProjectStep(this.label);
  final String label;
}

class CreateProjectForm extends ConsumerStatefulWidget {
  const CreateProjectForm({super.key});

  @override
  ConsumerState<CreateProjectForm> createState() => _CreateProjectFormState();
}

class _CreateProjectFormState extends ConsumerState<CreateProjectForm> {
  final ProjectFormCtrModel _projectCtr = ProjectFormCtrModel.empty();
  final PersonnelFormCtrModel _catalogerCtr = PersonnelFormCtrModel.empty();
  final ScrollController _stepScrollController = ScrollController();
  final String _newProjectUuid = uuid;
  final String _newCatalogerUuid = uuid;

  _CreateProjectStep _step = _CreateProjectStep.welcome;
  ProjectData? _importedProject;
  CatalogFmt? _catalogFmtDraft;
  FieldIdMode? _fieldIdModeDraft;
  bool? _autoIncrementDraft;
  bool _taxonConfigured = false;
  bool _fieldIdConfigured = false;
  String? _selectedCatalogerUuid;
  bool _saving = false;
  bool _projectNameValid = false;
  bool _catalogerValidationAttempted = false;
  int _nameValidationGeneration = 0;
  String? _projectNameError;
  String? _error;

  List<_CreateProjectStep> get _steps {
    if (_importedProject != null) {
      return const [_CreateProjectStep.welcome, _CreateProjectStep.review];
    }
    return [
      _CreateProjectStep.welcome,
      _CreateProjectStep.projectInformation,
      _CreateProjectStep.mainTaxon,
      _CreateProjectStep.fieldId,
      if (_fieldIdConfigured && _fieldIdModeDraft == FieldIdMode.personnel)
        _CreateProjectStep.cataloger,
      _CreateProjectStep.review,
    ];
  }

  String get _projectUuid => _importedProject?.uuid ?? _newProjectUuid;

  @override
  void initState() {
    super.initState();
    _catalogerCtr.roleCtr = 'Cataloger';
    _catalogerCtr.isRegisterField = true;
  }

  @override
  void dispose() {
    _projectCtr.dispose();
    _catalogerCtr.dispose();
    _stepScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FalseWillPop(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create project'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >=
                        NahpuBreakpoints.projectWizardRail) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                            child: SizedBox(width: 248, child: _stepRail()),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _stepBody()),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        SizedBox(height: 64, child: _stepChips()),
                        const Divider(height: NahpuStroke.regular),
                        Expanded(child: _stepBody()),
                      ],
                    );
                  },
                ),
              ),
              _actionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepRail() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('create-project-step-rail'),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withAlpha(80),
        border: Border.all(
          color: colors.outlineVariant,
          width: NahpuStroke.thin,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final step = _steps[index];
          final selected = step == _step;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NahpuRadius.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                selected: selected,
                selectedTileColor: colors.primaryContainer,
                selectedColor: colors.onPrimaryContainer,
                leading: CircleAvatar(
                  radius: NahpuRadius.md,
                  backgroundColor: selected
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                  foregroundColor: selected
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  step.label,
                  style: selected
                      ? const TextStyle(fontWeight: FontWeight.w600)
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stepChips() {
    return ListView.separated(
      controller: _stepScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.lg,
        vertical: NahpuSpacing.md,
      ),
      itemCount: _steps.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final step = _steps[index];
        return ChoiceChip(
          selected: step == _step,
          label: Text('${index + 1}. ${step.label}'),
          onSelected: null,
        );
      },
    );
  }

  Widget _stepBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: NahpuContentWidth.projectWizard,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: switch (_step) {
                _CreateProjectStep.welcome => _welcome(),
                _CreateProjectStep.projectInformation => _projectInformation(),
                _CreateProjectStep.mainTaxon => _mainTaxon(),
                _CreateProjectStep.fieldId => _fieldId(),
                _CreateProjectStep.cataloger => _cataloger(),
                _CreateProjectStep.review => _review(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcome() {
    return FormSection(
      title: 'One project, one identity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create a project once, then share its project-info JSON—or scan '
            'its QR code on mobile—on every device used for data entry. '
            'Reusing the same project keeps one UUID across devices, '
            'supporting reproducible records and reliable data merging.',
          ),
          const SizedBox(height: 12),
          Text(
            'Project-info transfer copies project metadata only. It does not '
            'include records, personnel, taxa, or device settings.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _startNewProject,
            icon: const Icon(Icons.create_outlined),
            label: const Text('Create new project'),
          ),
          const SizedBox(height: 8),
          ImportJsonButton(onPressed: _importJson),
          if (systemPlatform == PlatformType.mobile) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _openScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan project QR'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _projectInformation() {
    return ProjectDetailsSections(
      projectCtr: _projectCtr,
      projectNameError: _projectNameError,
      onChanged: (_) => _validateProjectName(),
    );
  }

  Widget _mainTaxon() {
    return FormSection(
      title: 'Main taxon',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose the main taxon to tailor NAHPU’s specimen forms and '
            'defaults on this device. A project can contain multiple taxon '
            'groups, and you can change the main taxon later in Settings.',
          ),
          const SizedBox(height: 16),
          TaxonGroupFields(
            value: _catalogFmtDraft,
            onChanged: (value) => setState(() => _catalogFmtDraft = value),
          ),
        ],
      ),
    );
  }

  Widget _fieldId() {
    final storedMode = ref.watch(fieldIdModeNotifierProvider);
    final storedAutoIncrement = ref.watch(projectFieldIdAutoIncrementProvider);
    return FormSection(
      title: 'Set up field IDs',
      child: storedMode.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Could not load field ID settings: $error'),
        data: (currentMode) {
          final selectedMode = _fieldIdModeDraft ?? currentMode;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose how specimen field IDs are generated. You can change '
                'this later in Settings › Specimens.',
              ),
              const SizedBox(height: 12),
              SegmentedButton<FieldIdMode>(
                segments: const [
                  ButtonSegment(
                    value: FieldIdMode.personnel,
                    label: Text('Personnel'),
                    icon: Icon(Icons.person_outline),
                  ),
                  ButtonSegment(
                    value: FieldIdMode.project,
                    label: Text('Project'),
                    icon: Icon(Icons.tag_outlined),
                  ),
                ],
                selected: {selectedMode},
                onSelectionChanged: (selection) => setState(() {
                  _fieldIdModeDraft = selection.first;
                  _error = null;
                }),
              ),
              const SizedBox(height: 16),
              if (selectedMode == FieldIdMode.personnel)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline),
                  title: Text('A registered Cataloger is required'),
                  subtitle: Text(
                    'Next, choose an eligible Cataloger or create one with '
                    'initials and a current personal field number.',
                  ),
                )
              else
                _projectFieldIdFields(storedAutoIncrement),
            ],
          );
        },
      ),
    );
  }

  Widget _projectFieldIdFields(AsyncValue<bool> storedAutoIncrement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _projectCtr.catalogNumberPrefixCtr,
          decoration: const InputDecoration(
            labelText: 'Prefix',
            hintText: 'e.g. NAHPU-',
          ),
          onChanged: (_) => setState(() {}),
        ),
        TextField(
          controller: _projectCtr.currentCatalogNumberCtr,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Current catalog number',
            hintText: 'Enter the next number',
            errorText: _projectNumberRequired ? 'Enter a current number' : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        TextField(
          controller: _projectCtr.catalogNumberSuffixCtr,
          decoration: const InputDecoration(
            labelText: 'Suffix',
            hintText: 'e.g. -M',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(
          'Preview: ${_projectCtr.catalogNumberPrefixCtr.text}'
          '${_projectCtr.currentCatalogNumberCtr.text}'
          '${_projectCtr.catalogNumberSuffixCtr.text}',
        ),
        const SizedBox(height: 8),
        storedAutoIncrement.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(error.toString()),
          data: (stored) => Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-increment catalog number'),
              value: _autoIncrementDraft ?? stored,
              onChanged: (value) => setState(() {
                _autoIncrementDraft = value;
                _error = null;
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cataloger() {
    return ref
        .watch(allPersonnelProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => FormSection(
            title: 'Cataloger',
            child: Text('Could not load personnel: $error'),
          ),
          data: (personnel) {
            final eligible = personnel.where(_isEligibleCataloger).toList();
            if (eligible.isNotEmpty) {
              return FormSection(
                title: 'Choose a Cataloger',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Choose the Cataloger whose initials and current field '
                      'number will be used for personnel field IDs.',
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCatalogerUuid,
                      decoration: const InputDecoration(
                        labelText: 'Cataloger*',
                        hintText: 'Choose a Cataloger',
                      ),
                      items: eligible
                          .map(
                            (person) => DropdownMenuItem(
                              value: person.uuid,
                              child: CommonDropdownText(
                                text:
                                    '${person.name ?? 'Unnamed'} '
                                    '(${person.initial ?? ''}'
                                    '${person.currentFieldNumber ?? ''})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCatalogerUuid = value),
                    ),
                  ],
                ),
              );
            }
            return _newCatalogerForm();
          },
        );
  }

  Widget _newCatalogerForm() {
    return FormSection(
      title: 'Create a Cataloger',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'No registered Cataloger is available. Create one now; the role '
            'and personal field-number registration are filled automatically.',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _catalogerCtr.nameCtr,
            decoration: InputDecoration(
              labelText: 'Name*',
              hintText: 'Enter the Cataloger name',
              errorText: _catalogerValidationAttempted
                  ? _catalogerNameError
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextFormField(
            controller: _catalogerCtr.initialCtr,
            maxLength: 5,
            inputFormatters: [LengthLimitingTextInputFormatter(5)],
            decoration: InputDecoration(
              labelText: 'Initials*',
              hintText: 'e.g. HH or H-H',
              errorText: _catalogerValidationAttempted
                  ? _catalogerInitialError
                  : null,
            ),
            onChanged: (value) {
              final upper = value.toUpperCase();
              if (upper != value) {
                _catalogerCtr.initialCtr.value = TextEditingValue(
                  text: upper,
                  selection: TextSelection.collapsed(offset: upper.length),
                );
              }
              setState(() {});
            },
          ),
          TextFormField(
            controller: _catalogerCtr.collectorNumCtr,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Current field number*',
              hintText: 'Enter the next personal field number',
              errorText: _catalogerValidationAttempted
                  ? _catalogerNumberError
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check_circle_outline),
            title: Text('Specimen care role: Cataloger'),
            subtitle: Text('Personal field-number registration enabled'),
          ),
        ],
      ),
    );
  }

  Widget _review() {
    final imported = _importedProject != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          title: imported ? 'Review imported project' : 'Review project',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imported)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'This project-info transfer preserves the source UUID. '
                    'Records, personnel, taxa, and device settings are not '
                    'included.',
                  ),
                ),
              _ReviewRow(label: 'Project UUID', value: _projectUuid),
              _ReviewRow(
                label: 'Project name',
                value: _projectCtr.projectNameCtr.text,
              ),
              _ReviewRow(
                label: 'Description',
                value: _projectCtr.descriptionCtr.text,
              ),
              _ReviewRow(
                label: 'Principal investigator',
                value: _projectCtr.pICtr.text,
              ),
              _ReviewRow(
                label: 'Accession',
                value: _projectCtr.accessionCtr.text,
              ),
              _ReviewRow(
                label: 'Location',
                value: _projectCtr.locationCtr.text,
              ),
              _ReviewRow(
                label: 'Time zone',
                value: _projectCtr.timeZoneCtr.text,
              ),
              _ReviewRow(
                label: 'Start date',
                value: _projectCtr.startDateCtr.text,
              ),
              _ReviewRow(label: 'End date', value: _projectCtr.endDateCtr.text),
              _ReviewRow(
                label: 'Field ID prefix',
                value: _projectCtr.catalogNumberPrefixCtr.text,
              ),
              _ReviewRow(
                label: 'Current catalog number',
                value: _projectCtr.currentCatalogNumberCtr.text,
              ),
              _ReviewRow(
                label: 'Field ID suffix',
                value: _projectCtr.catalogNumberSuffixCtr.text,
              ),
            ],
          ),
        ),
        if (_projectNameError != null) ...[
          const SizedBox(height: 8),
          Text(
            _projectNameError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (!imported) _setupReview(),
        _taxonomyReadiness(),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _setupReview() {
    final cataloger = _selectedCatalogerUuid != null
        ? 'Existing Cataloger selected'
        : _fieldIdConfigured && _fieldIdModeDraft == FieldIdMode.personnel
        ? _catalogerCtr.nameCtr.text
        : 'Not configured';
    return FormSection(
      title: 'Device setup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReviewRow(
            label: 'Main taxon',
            value: _taxonConfigured && _catalogFmtDraft != null
                ? matchCatFmtToTaxonGroup(_catalogFmtDraft!)
                : 'Keep current setting',
          ),
          _ReviewRow(
            label: 'Field ID mode',
            value: _fieldIdConfigured && _fieldIdModeDraft != null
                ? _fieldIdModeDraft!.name
                : 'Keep current setting',
          ),
          if (_fieldIdConfigured && _fieldIdModeDraft == FieldIdMode.project)
            _ReviewRow(
              label: 'Auto-increment',
              value: (_autoIncrementDraft ?? false) ? 'On' : 'Off',
            ),
          if (_fieldIdConfigured && _fieldIdModeDraft == FieldIdMode.personnel)
            _ReviewRow(label: 'Cataloger', value: cataloger),
        ],
      ),
    );
  }

  Widget _taxonomyReadiness() {
    return FormSection(
      title: 'Taxonomy readiness',
      child: ref
          .watch(taxonRegistryProvider)
          .when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Available taxa count is unavailable.'),
            data: (taxa) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Available taxa: ${taxa.length}'),
                if (taxa.isEmpty) ...[
                  const SizedBox(height: 8),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline),
                    title: Text('No taxa are available'),
                    subtitle: Text(
                      'Add or import taxa in the Taxon Registry before creating '
                      'a new specimen record.',
                    ),
                  ),
                ],
              ],
            ),
          ),
    );
  }

  Widget _actionBar() {
    final skippable = {
      _CreateProjectStep.mainTaxon,
      _CreateProjectStep.fieldId,
      _CreateProjectStep.cataloger,
    }.contains(_step);
    return Material(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              if (_step != _CreateProjectStep.welcome)
                OutlinedButton.icon(
                  onPressed: _saving ? null : _back,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                )
              else
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              const Spacer(),
              if (skippable)
                TextButton(
                  onPressed: _saving ? null : _skip,
                  child: const Text('Skip'),
                ),
              if (_step != _CreateProjectStep.welcome) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _canContinue && !_saving ? _continue : null,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _step == _CreateProjectStep.review
                              ? Icons.add
                              : Icons.arrow_forward,
                        ),
                  label: Text(
                    _saving
                        ? 'Creating…'
                        : _step == _CreateProjectStep.review
                        ? 'Create project'
                        : 'Continue',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _projectNumberRequired {
    final selectedMode = _fieldIdModeDraft;
    return selectedMode == FieldIdMode.project &&
        _autoIncrementDraft == true &&
        _projectCtr.currentCatalogNumberCtr.text.isEmpty;
  }

  String? get _catalogerNameError {
    final value = _catalogerCtr.nameCtr.text.trim();
    if (value.isEmpty) return 'Cataloger name is required';
    if (value.length < 3) return 'Name is too short';
    if (!value.isValidName) return 'Invalid characters';
    return null;
  }

  String? get _catalogerInitialError {
    final value = _catalogerCtr.initialCtr.text.trim();
    if (value.isEmpty) return 'Initials are required';
    if (value.length < 2) return 'Initials are too short';
    if (!value.isValidInitial) return 'Invalid characters';
    return null;
  }

  String? get _catalogerNumberError {
    final value = _catalogerCtr.collectorNumCtr.text;
    if (value.isEmpty) return 'Current field number is required';
    if (!value.isValidCollNum) return 'Invalid field number';
    return null;
  }

  bool get _catalogerIsValid =>
      _catalogerNameError == null &&
      _catalogerInitialError == null &&
      _catalogerNumberError == null;

  bool get _canContinue {
    switch (_step) {
      case _CreateProjectStep.welcome:
        return false;
      case _CreateProjectStep.projectInformation:
        return _projectNameValid;
      case _CreateProjectStep.mainTaxon:
        return true;
      case _CreateProjectStep.fieldId:
        return !_projectNumberRequired;
      case _CreateProjectStep.cataloger:
        final personnel = ref
            .read(allPersonnelProvider)
            .when(
              data: (data) => data,
              loading: () => const <PersonnelData>[],
              error: (_, _) => const <PersonnelData>[],
            );
        final eligible = personnel.where(_isEligibleCataloger).toList();
        if (eligible.isNotEmpty) return _selectedCatalogerUuid != null;
        return _catalogerIsValid;
      case _CreateProjectStep.review:
        return _projectNameValid;
    }
  }

  void _startNewProject() {
    _clearProjectDraft();
    setState(() {
      _importedProject = null;
      _step = _CreateProjectStep.projectInformation;
      _error = null;
    });
    _validateProjectName();
  }

  Future<void> _importJson() async {
    final file = await FilePickerServices().selectJsonFile();
    if (file == null) return;
    try {
      _applyImportedProject(await const ProjectExchangeService().read(file));
    } catch (error) {
      _showError(error.toString());
    }
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(onDetect: _onDetect),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    try {
      if (capture.barcodes.isEmpty ||
          capture.barcodes.first.format != BarcodeFormat.qrCode ||
          capture.barcodes.first.rawValue == null) {
        throw const FormatException('Invalid project QR code.');
      }
      final data = ProjectExchangeService.decode(
        capture.barcodes.first.rawValue!,
      );
      Navigator.pop(context);
      _applyImportedProject(data);
    } catch (error) {
      _showError(error.toString());
    }
  }

  void _applyImportedProject(ProjectData project) {
    _projectCtr.updateData(project);
    setState(() {
      _importedProject = project;
      _step = _CreateProjectStep.review;
      _taxonConfigured = false;
      _fieldIdConfigured = false;
      _error = null;
    });
    _validateProjectName();
  }

  Future<void> _validateProjectName() async {
    final generation = ++_nameValidationGeneration;
    final name = _projectCtr.projectNameCtr.text.trim();
    String? error;
    if (name.isEmpty) {
      error = 'Project name is required';
    } else if (name.length < 3) {
      error = 'Project name is too short';
    } else if (name.length > 25) {
      error = 'Project name is too long';
    } else if (!name.isValidProjectName) {
      error = 'Project name is invalid';
    } else {
      final names = await ProjectServices(ref: ref).getAllProjectNames();
      if (names.any(
        (existing) => existing.toLowerCase() == name.toLowerCase(),
      )) {
        error = 'Project name already exists';
      }
    }
    if (!mounted || generation != _nameValidationGeneration) return;
    setState(() {
      _projectNameError = error;
      _projectNameValid = error == null;
    });
  }

  bool _isEligibleCataloger(PersonnelData person) {
    return person.role == 'Cataloger' &&
        person.isRegisterField &&
        (person.initial?.trim().length ?? 0) >= 2 &&
        person.currentFieldNumber != null;
  }

  Future<void> _continue() async {
    setState(() => _error = null);
    switch (_step) {
      case _CreateProjectStep.projectInformation:
        await _validateProjectName();
        if (!_canContinue) return;
        _goTo(_CreateProjectStep.mainTaxon);
      case _CreateProjectStep.mainTaxon:
        _catalogFmtDraft ??= await ref.read(catalogFmtNotifierProvider.future);
        _taxonConfigured = true;
        _goTo(_CreateProjectStep.fieldId);
      case _CreateProjectStep.fieldId:
        _fieldIdModeDraft ??= await ref.read(
          fieldIdModeNotifierProvider.future,
        );
        _autoIncrementDraft ??= await ref.read(
          projectFieldIdAutoIncrementProvider.future,
        );
        if (_projectNumberRequired) {
          setState(() {});
          return;
        }
        _fieldIdConfigured = true;
        _goTo(
          _fieldIdModeDraft == FieldIdMode.personnel
              ? _CreateProjectStep.cataloger
              : _CreateProjectStep.review,
        );
      case _CreateProjectStep.cataloger:
        final personnel = ref
            .read(allPersonnelProvider)
            .when(
              data: (data) => data,
              loading: () => const <PersonnelData>[],
              error: (_, _) => const <PersonnelData>[],
            );
        if (!personnel.any(_isEligibleCataloger)) {
          setState(() => _catalogerValidationAttempted = true);
        }
        if (!_canContinue) return;
        _goTo(_CreateProjectStep.review);
      case _CreateProjectStep.review:
        await _createProject();
      case _CreateProjectStep.welcome:
        return;
    }
  }

  void _skip() {
    switch (_step) {
      case _CreateProjectStep.mainTaxon:
        _taxonConfigured = false;
        _goTo(_CreateProjectStep.fieldId);
      case _CreateProjectStep.fieldId:
        _fieldIdConfigured = false;
        _goTo(_CreateProjectStep.review);
      case _CreateProjectStep.cataloger:
        _fieldIdConfigured = false;
        _selectedCatalogerUuid = null;
        _goTo(_CreateProjectStep.review);
      default:
        return;
    }
  }

  void _back() {
    if (_importedProject != null) {
      _clearProjectDraft();
      setState(() {
        _importedProject = null;
        _step = _CreateProjectStep.welcome;
        _error = null;
      });
      return;
    }
    final steps = _steps;
    final index = steps.indexOf(_step);
    if (index > 0) _goTo(steps[index - 1]);
  }

  void _goTo(_CreateProjectStep step) {
    setState(() => _step = step);
    if (_stepScrollController.hasClients) {
      _stepScrollController.animateTo(
        _stepScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _createProject() async {
    await _validateProjectName();
    if (!_projectNameValid) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final currentTaxon = await ref.read(catalogFmtNotifierProvider.future);
    final currentMode = await ref.read(fieldIdModeNotifierProvider.future);
    final currentAutoIncrement = await ref.read(
      projectFieldIdAutoIncrementProvider.future,
    );
    var settingsChanged = false;
    try {
      final services = ProjectServices(ref: ref);
      if (await services.projectUuidExists(_projectUuid)) {
        throw const FormatException(
          'A project with this UUID already exists on this device.',
        );
      }
      if (_taxonConfigured && _catalogFmtDraft != null) {
        await ref
            .read(catalogFmtNotifierProvider.notifier)
            .set(_catalogFmtDraft!);
        final setting = ref.read(catalogFmtNotifierProvider);
        if (setting.hasError) throw setting.error!;
        settingsChanged = true;
      }
      if (_fieldIdConfigured && _fieldIdModeDraft != null) {
        await ref
            .read(fieldIdModeNotifierProvider.notifier)
            .set(_fieldIdModeDraft!);
        final modeSetting = ref.read(fieldIdModeNotifierProvider);
        if (modeSetting.hasError) throw modeSetting.error!;
        if (_fieldIdModeDraft == FieldIdMode.project) {
          await ref
              .read(projectFieldIdAutoIncrementProvider.notifier)
              .set(_autoIncrementDraft ?? currentAutoIncrement);
          final incrementSetting = ref.read(
            projectFieldIdAutoIncrementProvider,
          );
          if (incrementSetting.hasError) throw incrementSetting.error!;
        }
        settingsChanged = true;
      }

      final now = getSystemDateTime();
      final newCataloger = _newCatalogerCompanion();
      final catalogerUuid =
          _fieldIdConfigured && _fieldIdModeDraft == FieldIdMode.personnel
          ? _selectedCatalogerUuid ?? _newCatalogerUuid
          : null;
      await services.createProjectSetup(
        project: ProjectCompanion(
          uuid: db.Value(_projectUuid),
          name: db.Value(_projectCtr.projectNameCtr.text.trim()),
          description: db.Value(_projectCtr.descriptionCtr.text.trim()),
          principalInvestigator: db.Value(_projectCtr.pICtr.text.trim()),
          accession: db.Value(_projectCtr.accessionCtr.text.trim()),
          catalogNumberPrefix: db.Value(
            _projectCtr.catalogNumberPrefixCtr.text,
          ),
          currentCatalogNumber: db.Value(
            int.tryParse(_projectCtr.currentCatalogNumberCtr.text),
          ),
          catalogNumberSuffix: db.Value(
            _projectCtr.catalogNumberSuffixCtr.text,
          ),
          location: db.Value(_projectCtr.locationCtr.text.trim()),
          timeZone: db.Value(_projectCtr.timeZoneCtr.text),
          startDate: db.Value(_projectCtr.startDateCtr.date),
          endDate: db.Value(_projectCtr.endDateCtr.date),
          created: db.Value(_importedProject?.created ?? now),
          lastAccessed: db.Value(now),
        ),
        newCataloger: newCataloger,
        catalogerUuid: catalogerUuid,
      );
      ref.invalidate(allPersonnelProvider);
      ref.read(projectNavbarIndexProvider.notifier).updateState(0);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(ProjectShell.route());
    } catch (error) {
      if (settingsChanged) {
        await ref.read(catalogFmtNotifierProvider.notifier).set(currentTaxon);
        await ref.read(fieldIdModeNotifierProvider.notifier).set(currentMode);
        await ref
            .read(projectFieldIdAutoIncrementProvider.notifier)
            .set(currentAutoIncrement);
      }
      if (!mounted) return;
      setState(() => _error = 'Could not create project: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  PersonnelCompanion? _newCatalogerCompanion() {
    if (!_fieldIdConfigured ||
        _fieldIdModeDraft != FieldIdMode.personnel ||
        _selectedCatalogerUuid != null) {
      return null;
    }
    return PersonnelCompanion(
      uuid: db.Value(_newCatalogerUuid),
      name: db.Value(_catalogerCtr.nameCtr.text.trim()),
      initial: db.Value(_catalogerCtr.initialCtr.text.trim()),
      role: const db.Value('Cataloger'),
      currentFieldNumber: db.Value(
        int.parse(_catalogerCtr.collectorNumCtr.text),
      ),
      isRegisterField: const db.Value(true),
    );
  }

  void _clearProjectDraft() {
    _projectCtr.projectNameCtr.clear();
    _projectCtr.descriptionCtr.clear();
    _projectCtr.pICtr.clear();
    _projectCtr.accessionCtr.clear();
    _projectCtr.locationCtr.clear();
    _projectCtr.timeZoneCtr.clear();
    _projectCtr.startDateCtr.date = null;
    _projectCtr.endDateCtr.date = null;
    _projectCtr.catalogNumberPrefixCtr.clear();
    _projectCtr.currentCatalogNumberCtr.clear();
    _projectCtr.catalogNumberSuffixCtr.clear();
    _projectCtr.createdCtr = null;
    _projectNameError = null;
    _projectNameValid = false;
    _catalogerValidationAttempted = false;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}

class UuidText extends StatelessWidget {
  const UuidText({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) {
    return Text('Project UUID: $uuid');
  }
}

class QrCaptureButton extends StatelessWidget {
  const QrCaptureButton({super.key, required this.onDetect});

  final ValueChanged<BarcodeCapture> onDetect;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerScreen(onDetect: onDetect),
          ),
        );
      },
      icon: const Icon(Icons.qr_code_scanner),
      label: const Text('Scan project QR'),
    );
  }
}

class ImportJsonButton extends StatelessWidget {
  const ImportJsonButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.file_download_outlined),
      label: const Text('Import project-info JSON'),
    );
  }
}
