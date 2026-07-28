import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/project_transfer/project_transfer_service.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:path/path.dart' as path;

class ImportProjectScreen extends ConsumerStatefulWidget {
  const ImportProjectScreen({
    super.key,
    this.mode = ProjectTransferImportMode.merge,
    this.initialArchive,
  });

  const ImportProjectScreen.newProject({super.key})
    : mode = ProjectTransferImportMode.newProject,
      initialArchive = null;

  final ProjectTransferImportMode mode;
  final XFile? initialArchive;

  @override
  ConsumerState<ImportProjectScreen> createState() =>
      _ImportProjectScreenState();
}

class _ImportProjectScreenState extends ConsumerState<ImportProjectScreen> {
  static const _mergeSteps = [
    'File and safety',
    'Project info',
    'Personnel',
    'Taxonomy',
    'Sites',
    'Events',
    'Specimens',
    'Narratives',
    'Review and merge',
    'Result',
  ];
  static const _mergeSectionByStep = {
    2: ProjectTransferSection.personnel,
    3: ProjectTransferSection.taxonomy,
    4: ProjectTransferSection.sites,
    5: ProjectTransferSection.events,
    6: ProjectTransferSection.specimens,
    7: ProjectTransferSection.narratives,
  };
  static const _newProjectSteps = [
    'File and safety',
    'Personnel',
    'Taxonomy',
    'Specimens',
    'Review and import',
    'Result',
  ];
  static const _newProjectSectionByStep = {
    1: ProjectTransferSection.personnel,
    2: ProjectTransferSection.taxonomy,
    3: ProjectTransferSection.specimens,
  };

  final _forceConfirmationController = TextEditingController();
  final _destinationNameController = TextEditingController();
  final _stepChipScrollController = ScrollController();
  final _stepChipKeys = List<GlobalKey>.generate(10, (_) => GlobalKey());
  final Map<String, ProjectTransferConflictAction> _actions = {};
  final Map<String, bool> _importedProjectFields = {};
  ProjectTransferArchiveFile? _archiveFile;
  ProjectTransferImportPlan? _plan;
  ProjectTransferImportResult? _result;
  int _step = 0;
  int _maxVisitedStep = 0;
  bool _backupAcknowledged = false;
  bool _forceMerge = false;
  bool _isReading = false;
  bool _isImporting = false;
  bool _isValidatingName = false;
  String? _error;
  String? _destinationNameError;
  ProjectTransferProjectMatch? _nameConflict;
  ProjectTransferProjectMatch? _existingProject;
  XFile? _selectedInput;
  int _nameValidationGeneration = 0;

  bool get _isNewProject => widget.mode == ProjectTransferImportMode.newProject;
  List<String> get _steps => _isNewProject ? _newProjectSteps : _mergeSteps;
  Map<int, ProjectTransferSection> get _sectionByStep =>
      _isNewProject ? _newProjectSectionByStep : _mergeSectionByStep;
  int get _reviewStep => _steps.length - 2;
  int get _resultStep => _steps.length - 1;

  @override
  void initState() {
    super.initState();
    final initialArchive = widget.initialArchive;
    if (initialArchive != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadArchive(initialArchive);
      });
    }
  }

  @override
  void dispose() {
    _forceConfirmationController.dispose();
    _destinationNameController.dispose();
    _stepChipScrollController.dispose();
    final archive = _archiveFile;
    if (archive != null) unawaited(archive.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 880;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewProject ? 'Import project' : 'Merge project'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 248, child: _buildStepRail()),
                        const VerticalDivider(width: 1),
                        Expanded(child: _buildStepBody()),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(height: 64, child: _buildStepChips()),
                        const Divider(height: 1),
                        Expanded(child: _buildStepBody()),
                      ],
                    ),
            ),
            _WizardActionBar(
              step: _step,
              lastStep: _steps.length - 1,
              isRunning: _isImporting,
              canContinue: _canContinue,
              finalActionLabel: _isNewProject
                  ? 'Import project'
                  : 'Merge project',
              finalActionIcon: _isNewProject
                  ? Icons.download_rounded
                  : Icons.merge_rounded,
              onBack: _back,
              onContinue: _continue,
              onClose: _close,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRail() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final selected = index == _step;
        final enabled = index <= _maxVisitedStep;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            selected: selected,
            enabled: enabled,
            leading: _StepNumber(
              number: index + 1,
              selected: selected,
              complete: index < _step,
            ),
            title: Text(_steps[index]),
            onTap: enabled ? () => setState(() => _step = index) : null,
          ),
        );
      },
    );
  }

  Widget _buildStepChips() {
    return ListView.separated(
      controller: _stepChipScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: _steps.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final enabled = index <= _maxVisitedStep;
        return ChoiceChip(
          key: _stepChipKeys[index],
          selected: index == _step,
          label: Text('${index + 1}. ${_steps[index]}'),
          onSelected: enabled
              ? (_) {
                  setState(() => _step = index);
                  _scrollActiveStepChip();
                }
              : null,
        );
      },
    );
  }

  void _scrollActiveStepChip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final chipContext = _stepChipKeys[_step].currentContext;
      if (chipContext == null) return;
      Scrollable.ensureVisible(
        chipContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _buildStepBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(key: ValueKey(_step), child: _stepContent()),
          ),
        ),
      ),
    );
  }

  Widget _stepContent() {
    if (_step == 0) return _fileAndSafety();
    final plan = _plan;
    if (plan == null) {
      return const _MessageCard(
        icon: Icons.upload_file_outlined,
        title: 'Choose a project transfer first',
        message: 'Return to File and safety to select an archive.',
      );
    }
    if (!_isNewProject && _step == 1) return _projectInfo(plan);
    if (_step == _reviewStep) return _review(plan);
    if (_step == _resultStep) return _resultView();
    final section = _sectionByStep[_step];
    if (section != null) return _conflictSection(plan, section);
    return const SizedBox.shrink();
  }

  Widget _fileAndSafety() {
    final plan = _plan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RoundedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a NAHPU project transfer',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Project transfers can be JSON.GZ, ZIP, or TAR.GZ. JSON.GZ '
                'contains records only; ZIP and TAR.GZ include media.',
              ),
              const SizedBox(height: 20),
              Center(
                child: FilledButton.tonalIcon(
                  onPressed: _isReading ? null : _chooseArchive,
                  icon: _isReading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_rounded),
                  label: Text(
                    _selectedInput == null
                        ? 'Choose archive'
                        : 'Choose another archive',
                  ),
                ),
              ),
              if (plan != null) ...[
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(plan.payload.projectName),
                  subtitle: Text(
                    '${path.basename(_archiveFile!.extractedDirectory.path)}\n'
                    'Project UUID: ${plan.payload.sourceProjectUuid}',
                  ),
                  isThreeLine: true,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                ErrorText(error: _error!),
              ],
            ],
          ),
        ),
        if (_isNewProject && plan != null) ...[
          const SizedBox(height: 16),
          _newProjectIdentityCard(plan),
        ],
        if (_isNewProject && _existingProject != null) ...[
          const SizedBox(height: 16),
          _existingProjectCard(_existingProject!),
        ],
        const SizedBox(height: 16),
        _RoundedCard(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isNewProject
                          ? 'Back up before importing'
                          : 'Back up before merging',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'A database backup gives you a recovery point if imported '
                'changes are not what you expected.',
              ),
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _openBackup,
                  icon: const Icon(Icons.storage_rounded),
                  label: const Text('Back up now'),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _backupAcknowledged,
                title: Text(
                  _isNewProject
                      ? 'I understand that I should keep a backup before '
                            'importing.'
                      : 'I understand that I should keep a backup before '
                            'merging.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) =>
                    setState(() => _backupAcknowledged = value ?? false),
              ),
            ],
          ),
        ),
        if (plan?.hasUuidMismatch == true) ...[
          const SizedBox(height: 16),
          _forceMergeCard(plan!),
        ],
      ],
    );
  }

  Widget _newProjectIdentityCard(ProjectTransferImportPlan plan) {
    return _RoundedCard(
      color: _nameConflict == null
          ? null
          : Theme.of(context).colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New project identity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Archive UUID: ${plan.payload.sourceProjectUuid}'),
          const SizedBox(height: 12),
          TextField(
            controller: _destinationNameController,
            onChanged: _validateDestinationName,
            maxLength: 25,
            decoration: InputDecoration(
              labelText: 'Destination project name',
              border: const OutlineInputBorder(),
              errorText: _destinationNameError,
              helperText: _nameConflict == null
                  ? 'The archive itself is not changed.'
                  : null,
            ),
          ),
          if (_nameConflict != null) ...[
            const SizedBox(height: 8),
            Text(
              'A project named “${_nameConflict!.name}” already exists. '
              'Choose another name. If these are copies of the same project, '
              'cancel and use Merge project instead.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _existingProjectCard(ProjectTransferProjectMatch project) {
    return _RoundedCard(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This project already exists',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${project.name}\n${project.uuid}\n\n'
            'Matching UUIDs identify the same project. Import is blocked; '
            'merge this archive into the existing project instead.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _openMatchingProjectMerge,
            icon: const Icon(Icons.merge_rounded),
            label: const Text('Open Merge project'),
          ),
        ],
      ),
    );
  }

  Widget _forceMergeCard(ProjectTransferImportPlan plan) {
    final confirmed =
        _forceConfirmationController.text.trim() == plan.activeProjectName;
    return _RoundedCard(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project UUID does not match',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Archive: ${plan.payload.sourceProjectUuid}\n'
            'Active project: ${plan.activeProjectUuid}',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _forceMerge,
            title: const Text('Force merge into the active project'),
            subtitle: const Text(
              'Imported project-scoped records will use the active project '
              'UUID. Conflicts still require the choices shown later.',
            ),
            onChanged: (value) => setState(() => _forceMerge = value),
          ),
          if (_forceMerge) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _forceConfirmationController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Type “${plan.activeProjectName}” to confirm',
                border: const OutlineInputBorder(),
                suffixIcon: confirmed
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _projectInfo(ProjectTransferImportPlan plan) {
    const fields = {
      'name': 'Project name',
      'description': 'Description',
      'principalInvestigator': 'Principal investigator',
      'location': 'Location',
      'timeZone': 'Time zone',
      'startDate': 'Start date',
      'endDate': 'End date',
      'accession': 'Accession',
      'catalogNumberPrefix': 'Catalog number prefix',
      'catalogNumberSuffix': 'Catalog number suffix',
    };
    final current = ref.watch(currProjInfoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeading(
          title: 'Project info',
          message:
              'Current values are kept by default. Select individual imported '
              'values when you want to replace them.',
        ),
        const SizedBox(height: 12),
        Center(
          child: Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => setState(() {
                  for (final key in fields.keys) {
                    _importedProjectFields[key] = false;
                  }
                }),
                child: const Text('Keep all current'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  for (final key in fields.keys) {
                    _importedProjectFields[key] = true;
                  }
                }),
                child: const Text('Use all imported'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        current.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorText(error: error.toString()),
          data: (project) {
            final currentValues = project.toJson();
            return Column(
              children: [
                for (final field in fields.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProjectFieldChoice(
                      label: field.value,
                      currentValue: currentValues[field.key]?.toString(),
                      importedValue: plan.payload.project[field.key]
                          ?.toString(),
                      useImported: _importedProjectFields[field.key] ?? false,
                      onChanged: (value) => setState(
                        () => _importedProjectFields[field.key] = value,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _conflictSection(
    ProjectTransferImportPlan plan,
    ProjectTransferSection section,
  ) {
    final conflicts = plan.conflictsFor(section);
    final fresh = plan.newBySection[section] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeading(
          title: section.label,
          message:
              'Review matches before continuing. “Keep current” maps imported '
              'dependencies to the existing record without replacing it.',
        ),
        if (conflicts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Center(
            child: PopupMenuButton<ProjectTransferConflictAction>(
              tooltip: 'Apply one choice to all conflicts',
              onSelected: (action) => setState(() {
                for (final conflict in conflicts) {
                  if (conflict.allowedActions.contains(action)) {
                    _actions[conflict.id] = action;
                  }
                }
              }),
              itemBuilder: (context) => ProjectTransferConflictAction.values
                  .map(
                    (action) => PopupMenuItem(
                      value: action,
                      child: Text('${action.label} for all'),
                    ),
                  )
                  .toList(),
              child: const Chip(
                avatar: Icon(Icons.tune_rounded, size: 18),
                label: Text('Bulk action'),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(label: 'New', count: fresh, color: Colors.green),
            _StatusChip(
              label: 'Matched',
              count: conflicts.length,
              color: Colors.blue,
            ),
            _StatusChip(
              label: 'Conflict',
              count: conflicts.length,
              color: Colors.orange,
            ),
            _StatusChip(
              label: 'Skipped',
              count: conflicts.where((conflict) {
                return _actions[conflict.id] ==
                    ProjectTransferConflictAction.skip;
              }).length,
              color: Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (conflicts.isEmpty)
          const _MessageCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'No conflicts',
            message: 'All records in this section can be imported as new.',
          )
        else
          for (final conflict in conflicts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ConflictCard(
                conflict: conflict,
                action:
                    _actions[conflict.id] ??
                    ProjectTransferConflictAction.keepCurrent,
                onChanged: (action) =>
                    setState(() => _actions[conflict.id] = action),
              ),
            ),
      ],
    );
  }

  Widget _review(ProjectTransferImportPlan plan) {
    final skipped = _actions.values
        .where((action) => action == ProjectTransferConflictAction.skip)
        .length;
    final replacements = _actions.values
        .where((action) => action == ProjectTransferConflictAction.useImported)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeading(
          title: _isNewProject ? 'Review and import' : 'Review and merge',
          message:
              'Nothing has been written yet. The database changes will be '
              'committed together; a failure rolls them all back.',
        ),
        const SizedBox(height: 16),
        _RoundedCard(
          child: Column(
            children: [
              _ReviewRow(
                label: 'Source project',
                value: plan.payload.projectName,
              ),
              _ReviewRow(
                label: 'Destination',
                value: _isNewProject
                    ? _destinationNameController.text.trim()
                    : plan.activeProjectName,
              ),
              _ReviewRow(
                label: 'UUID handling',
                value: _isNewProject
                    ? 'New project UUID: ${plan.destinationProjectUuid}'
                    : plan.hasUuidMismatch
                    ? 'Force merge into active UUID'
                    : 'Matching project UUID',
              ),
              _ReviewRow(label: 'Conflicts', value: '${plan.conflicts.length}'),
              _ReviewRow(label: 'Use imported', value: '$replacements'),
              _ReviewRow(label: 'Skip', value: '$skipped'),
              _ReviewRow(
                label: 'Media files',
                value: '${plan.payload.mediaFiles.length}',
              ),
              if (_isNewProject)
                for (final entry in plan.payload.summary.entries)
                  if (entry.key != 'Media')
                    _ReviewRow(label: entry.key, value: '${entry.value}'),
            ],
          ),
        ),
        if (plan.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _RoundedCard(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Archive warnings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final warning in plan.warnings) Text('• $warning'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _resultView() {
    final result = _result;
    if (result == null) {
      return _MessageCard(
        icon: Icons.error_outline_rounded,
        title: _isNewProject ? 'Import did not finish' : 'Merge did not finish',
        message:
            _error ??
            (_isNewProject
                ? 'Return to Review and import and try again.'
                : 'Return to Review and merge and try again.'),
      );
    }
    return _RoundedCard(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            _isNewProject ? 'Project imported' : 'Project data merged',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ResultCount(
                label: _isNewProject ? 'Imported' : 'Merged',
                value: result.imported,
              ),
              _ResultCount(label: 'Updated', value: result.updated),
              _ResultCount(label: 'Skipped', value: result.skipped),
              _ResultCount(label: 'Media copied', value: result.mediaCopied),
            ],
          ),
        ],
      ),
    );
  }

  bool get _canContinue {
    if (_isReading || _isImporting) return false;
    if (_isNewProject &&
        (_isValidatingName ||
            _destinationNameError != null ||
            _nameConflict != null)) {
      return false;
    }
    if (_step == 0) {
      final plan = _plan;
      if (plan == null || !_backupAcknowledged) return false;
      if (_isNewProject) return true;
      if (!plan.hasUuidMismatch) return true;
      return _forceMerge &&
          _forceConfirmationController.text.trim() == plan.activeProjectName;
    }
    return _plan != null;
  }

  Future<void> _chooseArchive() async {
    final input = await FilePickerServices().selectAnyFile();
    if (input == null || !mounted) return;
    await _loadArchive(input);
  }

  Future<void> _loadArchive(XFile input) async {
    setState(() {
      _isReading = true;
      _error = null;
      _existingProject = null;
      _selectedInput = input;
    });
    ProjectTransferArchiveFile? opened;
    try {
      opened = await ProjectTransferService(ref: ref).archive.read(input);
      final plan = await ProjectTransferService(
        ref: ref,
      ).planImport(opened.payload, mode: widget.mode);
      final previous = _archiveFile;
      if (previous != null) await previous.dispose();
      if (!mounted) {
        await opened.dispose();
        return;
      }
      setState(() {
        _archiveFile = opened;
        _plan = plan;
        _destinationNameController.text = plan.destinationProjectName;
        _nameConflict = plan.nameConflict;
        _destinationNameError = _projectNameError(plan.destinationProjectName);
        _isValidatingName = false;
        _result = null;
        _actions
          ..clear()
          ..addEntries(
            plan.conflicts.map(
              (conflict) => MapEntry(
                conflict.id,
                conflict.allowedActions.contains(
                      ProjectTransferConflictAction.keepCurrent,
                    )
                    ? ProjectTransferConflictAction.keepCurrent
                    : conflict.allowedActions.first,
              ),
            ),
          );
        _importedProjectFields.clear();
        _forceMerge = false;
        _forceConfirmationController.clear();
        _maxVisitedStep = 0;
      });
      _scrollActiveStepChip();
    } catch (error) {
      if (opened != null) await opened.dispose();
      if (!mounted) return;
      setState(() {
        _plan = null;
        if (error is ProjectTransferProjectExistsException) {
          _existingProject = error.project;
          _error = null;
        } else {
          _error = error.toString();
        }
      });
    } finally {
      if (mounted) setState(() => _isReading = false);
    }
  }

  Future<void> _openBackup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExportDbForm()),
    );
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _scrollActiveStepChip();
    }
  }

  Future<void> _continue() async {
    if (!_canContinue) return;
    if (_step == _reviewStep) {
      await _runImport();
      return;
    }
    if (_step < _steps.length - 1) {
      setState(() {
        _step++;
        _maxVisitedStep = _maxVisitedStep < _step ? _step : _maxVisitedStep;
      });
      _scrollActiveStepChip();
    }
  }

  Future<void> _runImport() async {
    final plan = _plan;
    final archive = _archiveFile;
    if (plan == null || archive == null) return;
    setState(() {
      _isImporting = true;
      _error = null;
    });
    try {
      final result = await ProjectTransferService(ref: ref).importProject(
        plan,
        forceMerge: _forceMerge,
        conflictActions: _actions,
        importedProjectFields: _importedProjectFields,
        extractedDirectory: archive.extractedDirectory,
        destinationProjectName: _isNewProject
            ? _destinationNameController.text.trim()
            : null,
      );
      if (!mounted) return;
      if (_isNewProject) {
        ref
            .read(projectUuidProvider.notifier)
            .updateProjectUuid(plan.destinationProjectUuid);
        ref.read(projectNavbarIndexProvider.notifier).updateState(0);
      }
      setState(() {
        _result = result;
        _step = _resultStep;
        _maxVisitedStep = _resultStep;
      });
      _scrollActiveStepChip();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ErrorText(error: error.toString()),
          duration: const Duration(seconds: 12),
        ),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  String? _projectNameError(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 3) return 'Project name is too short';
    if (trimmed.length > 25) return 'Project name is too long';
    if (!trimmed.isValidProjectName) return 'Project name is invalid';
    return null;
  }

  Future<void> _validateDestinationName(String value) async {
    final generation = ++_nameValidationGeneration;
    final formatError = _projectNameError(value);
    if (formatError != null) {
      setState(() {
        _destinationNameError = formatError;
        _nameConflict = null;
        _isValidatingName = false;
      });
      return;
    }
    setState(() => _isValidatingName = true);
    final match = await ProjectTransferService(
      ref: ref,
    ).findProjectNameMatch(value);
    if (!mounted || generation != _nameValidationGeneration) return;
    setState(() {
      _nameConflict = match;
      _destinationNameError = match == null
          ? null
          : 'Project name already exists';
      _isValidatingName = false;
    });
  }

  void _openMatchingProjectMerge() {
    final project = _existingProject;
    final input = _selectedInput;
    if (project == null || input == null) return;
    ref.read(projectUuidProvider.notifier).updateProjectUuid(project.uuid);
    ref.read(projectNavbarIndexProvider.notifier).updateState(0);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ImportProjectScreen(initialArchive: input),
      ),
    );
  }

  void _close() {
    if (!_isNewProject || _result == null) {
      Navigator.pop(context);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(ProjectShell.route());
  }
}

class _WizardActionBar extends StatelessWidget {
  const _WizardActionBar({
    required this.step,
    required this.lastStep,
    required this.isRunning,
    required this.canContinue,
    required this.finalActionLabel,
    required this.finalActionIcon,
    required this.onBack,
    required this.onContinue,
    required this.onClose,
  });

  final int step;
  final int lastStep;
  final bool isRunning;
  final bool canContinue;
  final String finalActionLabel;
  final IconData finalActionIcon;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              if (step > 0 && step < lastStep)
                OutlinedButton.icon(
                  onPressed: isRunning ? null : onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
              const Spacer(),
              if (step == lastStep)
                FilledButton(onPressed: onClose, child: const Text('Done'))
              else
                FilledButton.icon(
                  onPressed: canContinue ? onContinue : null,
                  icon: isRunning
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          step == lastStep - 1
                              ? finalActionIcon
                              : Icons.arrow_forward_rounded,
                        ),
                  label: Text(
                    step == lastStep - 1 ? finalActionLabel : 'Continue',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.conflict,
    required this.action,
    required this.onChanged,
  });

  final ProjectTransferConflict conflict;
  final ProjectTransferConflictAction action;
  final ValueChanged<ProjectTransferConflictAction> onChanged;

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  conflict.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Chip(label: Text('Conflict')),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final current = _ComparisonPane(
                label: 'Current',
                value: conflict.currentSummary,
              );
              final imported = _ComparisonPane(
                label: 'Imported',
                value: conflict.importedSummary,
              );
              return constraints.maxWidth >= 600
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: current),
                        const SizedBox(width: 12),
                        Expanded(child: imported),
                      ],
                    )
                  : Column(
                      children: [current, const SizedBox(height: 8), imported],
                    );
            },
          ),
          if (conflict.warning != null) ...[
            const SizedBox(height: 10),
            Text(
              conflict.warning!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 14),
          DropdownButtonFormField<ProjectTransferConflictAction>(
            initialValue: action,
            decoration: const InputDecoration(
              labelText: 'Conflict action',
              border: OutlineInputBorder(),
            ),
            items: conflict.allowedActions
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectFieldChoice extends StatelessWidget {
  const _ProjectFieldChoice({
    required this.label,
    required this.currentValue,
    required this.importedValue,
    required this.useImported,
    required this.onChanged,
  });

  final String label;
  final String? currentValue;
  final String? importedValue;
  final bool useImported;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          RadioGroup<bool>(
            groupValue: useImported,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            child: Column(
              children: [
                RadioListTile<bool>(
                  value: false,
                  title: const Text('Keep current'),
                  subtitle: Text(_displayValue(currentValue)),
                ),
                RadioListTile<bool>(
                  value: true,
                  title: const Text('Use imported'),
                  subtitle: Text(_displayValue(importedValue)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String? value) =>
      value == null || value.isEmpty ? 'Not set' : value;
}

class _RoundedCard extends StatelessWidget {
  const _RoundedCard({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(message),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Column(
        children: [
          Icon(icon, size: 44),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ComparisonPane extends StatelessWidget {
  const _ComparisonPane({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value.isEmpty ? 'No details' : value),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
      label: Text(label),
    );
  }
}

class _StepNumber extends StatelessWidget {
  const _StepNumber({
    required this.number,
    required this.selected,
    required this.complete,
  });

  final int number;
  final bool selected;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: selected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: complete
          ? const Icon(Icons.check_rounded, size: 16)
          : Text(
              '$number',
              style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
                fontSize: 12,
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 132, child: Text(label)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              ': $value',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: Theme.of(context).textTheme.headlineMedium),
        Text(label),
      ],
    );
  }
}
