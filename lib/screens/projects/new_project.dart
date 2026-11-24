import 'package:drift/drift.dart' as db;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nahpu/screens/projects/components/project_form.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
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
  welcome,
  projectInformation,
  mainTaxon,
  fieldId,
  cataloger,
  review;

  String label(AppLocalizations l10n) => switch (this) {
    welcome => l10n.projectWizardWelcome,
    projectInformation => l10n.homeProjectInformation,
    mainTaxon => l10n.projectWizardMainTaxon,
    fieldId => l10n.recordsSpecimenFieldId,
    cataloger => l10n.projectPersonnelRoleCataloger,
    review => l10n.projectWizardReview,
  };
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
  bool _createNewCataloger = false;
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
          title: Text(context.l10n.drawerCreateProject),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // The welcome step comes before the user picks a path, so
                    // the step list would only preview steps they may skip.
                    if (_step == _CreateProjectStep.welcome) {
                      return _stepBody();
                    }
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
              if (_step != _CreateProjectStep.welcome) _actionBar(),
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
      decoration: NahpuPanel.decorationOf(context),
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
                  step.label(context.l10n),
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
          label: Text('${index + 1}. ${step.label(context.l10n)}'),
          onSelected: null,
        );
      },
    );
  }

  Widget _stepBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = EdgeInsets.fromLTRB(8, 12, 8, 24);
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _step == _CreateProjectStep.welcome
                  ? constraints.maxHeight - padding.vertical
                  : 0,
            ),
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
                      _CreateProjectStep.welcome => _WelcomeStep(
                        onCreateNew: _startNewProject,
                        onImportJson: _importJson,
                        onCancel: () => Navigator.pop(context),
                        onScanQr: supportsCameraScanning ? _openScanner : null,
                      ),
                      _CreateProjectStep.projectInformation =>
                        _projectInformation(),
                      _CreateProjectStep.mainTaxon => _mainTaxon(),
                      _CreateProjectStep.fieldId => _fieldId(),
                      _CreateProjectStep.cataloger => _cataloger(),
                      _CreateProjectStep.review => _review(),
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
      title: context.l10n.projectWizardMainTaxon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.projectWizardMainTaxonBody),
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
      title: context.l10n.projectWizardFieldIdsTitle,
      child: storedMode.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Text(context.l10n.projectWizardFieldIdsLoadError('$error')),
        data: (currentMode) {
          final selectedMode = _fieldIdModeDraft ?? currentMode;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.projectWizardFieldIdsBody),
              const SizedBox(height: 12),
              SegmentedButton<FieldIdMode>(
                segments: [
                  ButtonSegment(
                    value: FieldIdMode.personnel,
                    label: Text(context.l10n.settingsNavPersonnel),
                    icon: const Icon(Icons.person_outline),
                  ),
                  ButtonSegment(
                    value: FieldIdMode.project,
                    label: Text(context.l10n.labelTableProject),
                    icon: const Icon(Icons.tag_outlined),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline),
                  title: Text(context.l10n.projectWizardCatalogerRequired),
                  subtitle: Text(
                    context.l10n.projectWizardCatalogerRequiredBody,
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
          decoration: InputDecoration(
            labelText: context.l10n.recordsSpecimenPrefix,
            hintText: context.l10n.projectWizardPrefixHint('NAHPU-'),
          ),
          onChanged: (_) => setState(() {}),
        ),
        TextField(
          controller: _projectCtr.currentCatalogNumberCtr,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: context.l10n.projectCurrentCatalogNumber,
            hintText: context.l10n.projectWizardNextNumberHint,
            errorText: _projectNumberRequired
                ? context.l10n.projectWizardCurrentNumberRequired
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        TextField(
          controller: _projectCtr.catalogNumberSuffixCtr,
          decoration: InputDecoration(
            labelText: context.l10n.recordsSpecimenSuffix,
            hintText: context.l10n.projectWizardPrefixHint('-M'),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.recordsSpecimenFieldIdPreview(
            '${_projectCtr.catalogNumberPrefixCtr.text}'
            '${_projectCtr.currentCatalogNumberCtr.text}'
            '${_projectCtr.catalogNumberSuffixCtr.text}',
          ),
        ),
        const SizedBox(height: 8),
        storedAutoIncrement.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(error.toString()),
          data: (stored) => Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.projectWizardAutoIncrementCatalog),
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
            title: context.l10n.projectPersonnelRoleCataloger,
            child: Text(context.l10n.projectWizardPersonnelLoadError('$error')),
          ),
          data: (personnel) {
            final eligible = personnel.where(_isEligibleCataloger).toList();
            if (eligible.isEmpty) {
              return FormSection(
                title: context.l10n.projectWizardCreateCataloger,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(context.l10n.projectWizardNoCatalogerBody),
                    const SizedBox(height: 12),
                    _newCatalogerFields(),
                  ],
                ),
              );
            }
            return FormSection(
              title: _createNewCataloger
                  ? context.l10n.projectWizardCreateCataloger
                  : context.l10n.projectWizardChooseCataloger,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CatalogerSourceChoice(
                    createNew: _createNewCataloger,
                    onChanged: _setCreateNewCataloger,
                  ),
                  const SizedBox(height: 16),
                  if (_createNewCataloger) ...[
                    Text(context.l10n.projectWizardCreateAnotherCatalogerBody),
                    const SizedBox(height: 12),
                    _newCatalogerFields(),
                  ] else ...[
                    Text(context.l10n.projectWizardChooseCatalogerBody),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCatalogerUuid,
                      decoration: InputDecoration(
                        labelText: context.l10n.projectWizardCatalogerLabel,
                        hintText: context.l10n.projectWizardChooseCataloger,
                      ),
                      items: eligible
                          .map(
                            (person) => DropdownMenuItem(
                              value: person.uuid,
                              child: CommonDropdownText(
                                text:
                                    '${person.name ?? context.l10n.projectPersonnelUnnamed} '
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
                ],
              ),
            );
          },
        );
  }

  Widget _newCatalogerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _catalogerCtr.nameCtr,
          decoration: InputDecoration(
            labelText: context.l10n.projectPersonnelNameLabel,
            hintText: context.l10n.projectWizardCatalogerNameHint,
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
            labelText: context.l10n.projectPersonnelInitialsLabel,
            hintText: context.l10n.projectPersonnelInitialsHint,
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
            labelText: context.l10n.projectWizardCurrentFieldNumberLabel,
            hintText: context.l10n.projectWizardCurrentFieldNumberHint,
            errorText: _catalogerValidationAttempted
                ? _catalogerNumberError
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.check_circle_outline),
          title: Text(context.l10n.projectWizardCatalogerRoleSet),
          subtitle: Text(context.l10n.projectWizardFieldNumberEnabled),
        ),
      ],
    );
  }

  void _setCreateNewCataloger(bool createNew) {
    setState(() {
      _createNewCataloger = createNew;
      _selectedCatalogerUuid = null;
      _catalogerValidationAttempted = false;
      _error = null;
    });
  }

  Widget _review() {
    final l10n = context.l10n;
    final imported = _importedProject != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          title: imported
              ? l10n.projectWizardReviewImported
              : l10n.projectWizardReviewProject,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imported)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(l10n.projectWizardImportNote),
                ),
              _ReviewRow(
                label: l10n.recordsCustomFieldProjectUuid,
                value: _projectUuid,
              ),
              _ReviewRow(
                label: l10n.projectName,
                value: _projectCtr.projectNameCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectDescription,
                value: _projectCtr.descriptionCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectPrincipalInvestigator,
                value: _projectCtr.pICtr.text,
              ),
              _ReviewRow(
                label: l10n.projectAccession,
                value: _projectCtr.accessionCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectLocation,
                value: _projectCtr.locationCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectTimeZone,
                value: _projectCtr.timeZoneCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectStartDate,
                value: _projectCtr.startDateCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectEndDate,
                value: _projectCtr.endDateCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectFieldIdPrefix,
                value: _projectCtr.catalogNumberPrefixCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectCurrentCatalogNumber,
                value: _projectCtr.currentCatalogNumberCtr.text,
              ),
              _ReviewRow(
                label: l10n.projectFieldIdSuffix,
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
    final l10n = context.l10n;
    final cataloger = _selectedCatalogerUuid != null
        ? l10n.projectWizardExistingCataloger
        : _fieldIdConfigured && _fieldIdModeDraft == FieldIdMode.personnel
        ? _catalogerCtr.nameCtr.text
        : l10n.projectWizardNotConfigured;
    return FormSection(
      title: l10n.projectWizardDeviceSetup,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReviewRow(
            label: l10n.projectWizardMainTaxon,
            value: _taxonConfigured && _catalogFmtDraft != null
                ? _catalogFmtDraft!.localizedLabel(l10n)
                : l10n.projectWizardKeepCurrent,
          ),
          _ReviewRow(
            label: l10n.projectWizardFieldIdMode,
            value: _fieldIdConfigured && _fieldIdModeDraft != null
                ? _fieldIdModeDraft == FieldIdMode.personnel
                      ? l10n.settingsNavPersonnel
                      : l10n.labelTableProject
                : l10n.projectWizardKeepCurrent,
          ),
          if (_fieldIdConfigured && _fieldIdModeDraft == FieldIdMode.project)
            _ReviewRow(
              label: l10n.projectWizardAutoIncrement,
              value: (_autoIncrementDraft ?? false)
                  ? l10n.projectOn
                  : l10n.projectOff,
            ),
          if (_fieldIdConfigured && _fieldIdModeDraft == FieldIdMode.personnel)
            _ReviewRow(
              label: l10n.projectPersonnelRoleCataloger,
              value: cataloger,
            ),
        ],
      ),
    );
  }

  Widget _taxonomyReadiness() {
    return FormSection(
      title: context.l10n.projectWizardTaxonomyReadiness,
      child: ref
          .watch(taxonRegistryProvider)
          .when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) =>
                Text(context.l10n.projectWizardTaxaCountUnavailable),
            data: (taxa) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.l10n.projectWizardAvailableTaxa(taxa.length)),
                if (taxa.isEmpty) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: Text(context.l10n.projectWizardNoTaxa),
                    subtitle: Text(context.l10n.projectWizardNoTaxaBody),
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
              OutlinedButton.icon(
                onPressed: _saving ? null : _back,
                icon: const Icon(Icons.arrow_back),
                label: Text(context.l10n.sharedBack),
              ),
              const Spacer(),
              if (skippable)
                TextButton(
                  onPressed: _saving ? null : _skip,
                  child: Text(context.l10n.projectWizardSkip),
                ),
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
                      ? context.l10n.projectWizardCreating
                      : _step == _CreateProjectStep.review
                      ? context.l10n.drawerCreateProject
                      : context.l10n.sharedContinue,
                ),
              ),
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
    if (value.isEmpty) return context.l10n.projectWizardCatalogerNameRequired;
    if (value.length < 3) return context.l10n.projectWizardNameTooShort;
    if (!value.isValidName) return context.l10n.projectWizardInvalidCharacters;
    return null;
  }

  String? get _catalogerInitialError {
    final value = _catalogerCtr.initialCtr.text.trim();
    if (value.isEmpty) return context.l10n.projectWizardInitialsRequired;
    if (value.length < 2) return context.l10n.projectWizardInitialsTooShort;
    if (!value.isValidInitial) {
      return context.l10n.projectWizardInvalidCharacters;
    }
    return null;
  }

  String? get _catalogerNumberError {
    final value = _catalogerCtr.collectorNumCtr.text;
    if (value.isEmpty) return context.l10n.projectWizardFieldNumberRequired;
    if (!value.isValidCollNum) {
      return context.l10n.projectWizardInvalidFieldNumber;
    }
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
        if (eligible.isNotEmpty && !_createNewCataloger) {
          return _selectedCatalogerUuid != null;
        }
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
        throw FormatException(context.l10n.projectInvalidQr);
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
    final l10n = context.l10n;
    if (name.isEmpty) {
      error = l10n.projectNameRequired;
    } else if (name.length < 3) {
      error = l10n.projectNameTooShort;
    } else if (name.length > 25) {
      error = l10n.projectNameTooLong;
    } else if (!name.isValidProjectName) {
      error = l10n.projectNameInvalid;
    } else {
      final names = await ProjectServices(ref: ref).getAllProjectNames();
      if (names.any(
        (existing) => existing.toLowerCase() == name.toLowerCase(),
      )) {
        error = l10n.projectNameExists;
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
        if (_createNewCataloger || !personnel.any(_isEligibleCataloger)) {
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
    final l10n = context.l10n;
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
        throw FormatException(l10n.projectUuidExists);
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
      setState(() => _error = l10n.projectCreateFailed('$error'));
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

/// First wizard step: create a project on the first device, or bring an
/// existing one to this device so it keeps the same project identity.
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.onCreateNew,
    required this.onImportJson,
    required this.onCancel,
    this.onScanQr,
  });

  final VoidCallback onCreateNew;
  final VoidCallback onImportJson;

  /// Sits right under the panel: the bottom action bar is hidden on this
  /// step, so a far corner button would be easy to miss.
  final VoidCallback onCancel;

  /// Null when this device cannot scan with a camera.
  final VoidCallback? onScanQr;

  @override
  Widget build(BuildContext context) {
    final newProject = _WelcomeNewProject(
      key: const ValueKey('create-project-welcome-new'),
      onCreateNew: onCreateNew,
    );
    final existingProject = _WelcomeExistingProject(
      key: const ValueKey('create-project-welcome-existing'),
      onImportJson: onImportJson,
      onScanQr: onScanQr,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Two independent panels with a gap, so neither tinted fill nor a
        // divider ever paints over the other panel's rounded border.
        LayoutBuilder(
          key: const ValueKey('create-project-welcome'),
          builder: (context, constraints) {
            if (constraints.maxWidth < NahpuBreakpoints.compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  newProject,
                  const SizedBox(height: NahpuSpacing.lg),
                  existingProject,
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: newProject),
                  const SizedBox(width: NahpuSpacing.lg),
                  Expanded(child: existingProject),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: NahpuSpacing.lg),
        Center(
          child: TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            label: Text(context.l10n.commonCancel),
          ),
        ),
      ],
    );
  }
}

class _WelcomeNewProject extends StatelessWidget {
  const _WelcomeNewProject({super.key, required this.onCreateNew});

  final VoidCallback onCreateNew;

  static const _previewSteps = [
    _CreateProjectStep.projectInformation,
    _CreateProjectStep.mainTaxon,
    _CreateProjectStep.fieldId,
    _CreateProjectStep.review,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DecoratedBox(
      decoration: NahpuPanel.decorationOf(context, color: colors.surface),
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.projectWizardNewProject,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: NahpuSpacing.xs),
            Text(
              context.l10n.projectWizardFirstDeviceOnly,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: NahpuSpacing.xl),
            for (final (index, step) in _previewSteps.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: NahpuControlSize.iconSmall / 2 + NahpuSpacing.xs,
                      backgroundColor: colors.surfaceContainerHighest,
                      foregroundColor: colors.onSurfaceVariant,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(width: NahpuSpacing.lg),
                    Expanded(child: Text(step.label(context.l10n))),
                  ],
                ),
              ),
            const SizedBox(height: NahpuSpacing.md),
            FilledButton.icon(
              onPressed: onCreateNew,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.projectWizardCreateNew),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeExistingProject extends StatelessWidget {
  const _WelcomeExistingProject({
    super.key,
    required this.onImportJson,
    this.onScanQr,
  });

  final VoidCallback onImportJson;
  final VoidCallback? onScanQr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scan = onScanQr;
    return DecoratedBox(
      decoration: NahpuPanel.decorationOf(
        context,
        color: colors.surfaceContainerLow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.projectWizardExistingProject,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: NahpuSpacing.xs),
            Text(
              context.l10n.projectWizardImportToDevice,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: NahpuSpacing.xl),
            if (scan != null) ...[
              _WelcomeOption(
                icon: Icons.qr_code_scanner,
                label: context.l10n.projectWizardScanQr,
                onTap: scan,
              ),
              const SizedBox(height: NahpuSpacing.md),
            ],
            _WelcomeOption(
              icon: Icons.file_download_outlined,
              label: context.l10n.projectWizardImportJson,
              onTap: onImportJson,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeOption extends StatelessWidget {
  const _WelcomeOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant, width: NahpuStroke.thin),
        borderRadius: BorderRadius.circular(NahpuRadius.sm),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _CatalogerSourceChoice extends StatelessWidget {
  const _CatalogerSourceChoice({
    required this.createNew,
    required this.onChanged,
  });

  final bool createNew;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          label: Text(context.l10n.projectWizardChooseExisting),
          icon: const Icon(Icons.person_search_outlined),
        ),
        ButtonSegment(
          value: true,
          label: Text(context.l10n.projectWizardCreateNewCataloger),
          icon: const Icon(Icons.person_add_alt_outlined),
        ),
      ],
      selected: {createNew},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
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
    return Text(context.l10n.projectUuidValue(uuid));
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
      label: Text(context.l10n.projectScanQr),
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
      label: Text(context.l10n.projectImportInfoJson),
    );
  }
}
