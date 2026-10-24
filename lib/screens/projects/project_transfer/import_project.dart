import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/projects/project_transfer_service.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

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
  static const _mergeSectionByStep = {
    2: ProjectTransferSection.personnel,
    3: ProjectTransferSection.taxonomy,
    4: ProjectTransferSection.sites,
    5: ProjectTransferSection.events,
    6: ProjectTransferSection.specimens,
    7: ProjectTransferSection.narratives,
  };
  static const _newProjectSectionByStep = {
    1: ProjectTransferSection.personnel,
    2: ProjectTransferSection.taxonomy,
    3: ProjectTransferSection.specimens,
  };

  final _forceConfirmationController = TextEditingController();
  final _destinationNameController = TextEditingController();
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
  ExportCancellation? _readCancellation;
  StreamSubscription<ExportJobProgress>? _readSubscription;
  ExportJobProgress? _readProgress;
  bool _isCancellingRead = false;

  bool get _isNewProject => widget.mode == ProjectTransferImportMode.newProject;
  List<String> get _steps {
    final l10n = context.l10n;
    final sections = _sectionByStep.values.map(
      (section) => section.localizedLabel(l10n),
    );
    return [
      l10n.projectTransferFileAndSafety,
      if (!_isNewProject) l10n.projectTransferProjectInfo,
      ...sections,
      _isNewProject
          ? l10n.projectTransferReviewImport
          : l10n.projectTransferReviewMerge,
      l10n.projectTransferResult,
    ];
  }

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
    final archive = _archiveFile;
    if (archive != null) unawaited(archive.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewProject
              ? context.l10n.drawerImportProject
              : context.l10n.labelProjectToolMergeProject,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NahpuWizardScaffold(
                steps: _steps,
                currentStep: _step,
                maxVisitedStep: _maxVisitedStep,
                onStepSelected: (index) => setState(() => _step = index),
                child: _stepContent(),
              ),
            ),
            NahpuWizardActionBar(
              step: _step,
              lastStep: _steps.length - 1,
              isRunning: _isImporting,
              canContinue: _canContinue,
              finalActionLabel: _isNewProject
                  ? context.l10n.drawerImportProject
                  : context.l10n.labelProjectToolMergeProject,
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

  Widget _stepContent() {
    if (_step == 0) return _fileAndSafety();
    final plan = _plan;
    if (plan == null) {
      return _MessageCard(
        icon: Icons.upload_file_outlined,
        title: context.l10n.projectTransferChooseFirst,
        message: context.l10n.projectTransferChooseFirstBody,
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
    final l10n = context.l10n;
    final plan = _plan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.projectTransferChooseTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(l10n.projectTransferChooseBody),
              const SizedBox(height: 20),
              if (_isReading && _readProgress != null)
                // Reading a media-heavy transfer decompresses gigabytes; a
                // spinner in the button cannot say how far along that is.
                ExportProgressPanel(
                  title: l10n.projectTransferReadingArchive,
                  progress: _readProgress!,
                  hint: l10n.projectTransferReadingArchiveHint,
                  isCancelling: _isCancellingRead,
                  onCancel: _requestReadCancel,
                )
              else
                Center(
                  child: FilledButton.tonalIcon(
                    onPressed: _isReading ? null : _chooseArchive,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(
                      _selectedInput == null
                          ? l10n.projectTransferChooseArchive
                          : l10n.projectTransferChooseAnotherArchive,
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
                    '${l10n.projectUuidValue(plan.payload.sourceProjectUuid)}',
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
        NahpuPanel(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isNewProject
                          ? l10n.projectTransferBackupBeforeImport
                          : l10n.projectTransferBackupBeforeMerge,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(l10n.projectTransferBackupBody),
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _openBackup,
                  icon: const Icon(Icons.storage_rounded),
                  label: Text(l10n.projectTransferBackupNow),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _backupAcknowledged,
                title: Text(
                  _isNewProject
                      ? l10n.projectTransferBackupAckImport
                      : l10n.projectTransferBackupAckMerge,
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
    return NahpuPanel(
      color: _nameConflict == null
          ? null
          : Theme.of(context).colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.projectTransferNewIdentity,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.projectTransferArchiveUuid(
              plan.payload.sourceProjectUuid,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destinationNameController,
            onChanged: _validateDestinationName,
            maxLength: 25,
            decoration: InputDecoration(
              labelText: context.l10n.projectTransferDestinationName,
              border: const OutlineInputBorder(),
              errorText: _destinationNameError,
              helperText: _nameConflict == null
                  ? context.l10n.projectTransferDestinationNameHelper
                  : null,
            ),
          ),
          if (_nameConflict != null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.projectTransferNameConflict(_nameConflict!.name),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _existingProjectCard(ProjectTransferProjectMatch project) {
    return NahpuPanel(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.projectTransferAlreadyExists,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${project.name}\n${project.uuid}\n\n'
            '${context.l10n.projectTransferAlreadyExistsBody}',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _openMatchingProjectMerge,
            icon: const Icon(Icons.merge_rounded),
            label: Text(context.l10n.projectTransferOpenMerge),
          ),
        ],
      ),
    );
  }

  Widget _forceMergeCard(ProjectTransferImportPlan plan) {
    final confirmed =
        _forceConfirmationController.text.trim() == plan.activeProjectName;
    return NahpuPanel(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.projectTransferUuidMismatch,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.projectTransferUuidMismatchBody(
              plan.payload.sourceProjectUuid,
              plan.activeProjectUuid,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _forceMerge,
            title: Text(context.l10n.projectTransferForceMerge),
            subtitle: Text(context.l10n.projectTransferForceMergeBody),
            onChanged: (value) => setState(() => _forceMerge = value),
          ),
          if (_forceMerge) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _forceConfirmationController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.projectTransferTypeToConfirm(
                  plan.activeProjectName,
                ),
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
    final l10n = context.l10n;
    final fields = {
      'name': l10n.projectName,
      'description': l10n.projectDescription,
      'principalInvestigator': l10n.projectPrincipalInvestigator,
      'location': l10n.projectLocation,
      'timeZone': l10n.projectTimeZone,
      'startDate': l10n.projectStartDate,
      'endDate': l10n.projectEndDate,
      'accession': l10n.projectAccession,
      'catalogNumberPrefix': l10n.projectCatalogNumberPrefix,
      'currentCatalogNumber': l10n.projectCurrentCatalogNumber,
      'catalogNumberSuffix': l10n.projectCatalogNumberSuffix,
    };
    final current = ref.watch(currProjInfoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: l10n.projectTransferProjectInfo,
          message: l10n.projectTransferProjectInfoBody,
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
                child: Text(l10n.projectTransferKeepAllCurrent),
              ),
              TextButton(
                onPressed: () => setState(() {
                  for (final key in fields.keys) {
                    _importedProjectFields[key] = true;
                  }
                }),
                child: Text(l10n.projectTransferUseAllImported),
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

  /// Conflicts the user still has to look at in [section].
  ///
  /// Child conflicts drop out once their parent record is kept or skipped,
  /// because nothing will be written for them.
  List<ProjectTransferConflict> _visibleConflicts(
    ProjectTransferImportPlan plan,
    ProjectTransferSection section,
  ) =>
      plan
          .conflictsFor(section)
          .where((conflict) => isConflictActive(conflict, _actions))
          .toList()
        // Blocking conflicts hold up the wizard, so they come first.
        ..sort((a, b) {
          if (a.requiresChoice == b.requiresChoice) return 0;
          return a.requiresChoice ? -1 : 1;
        });

  List<ProjectTransferConflict> _unresolvedIn(
    ProjectTransferImportPlan plan,
    ProjectTransferSection section,
  ) => _visibleConflicts(plan, section)
      .where(
        (conflict) => conflict.requiresChoice && _actions[conflict.id] == null,
      )
      .toList(growable: false);

  Widget _conflictSection(
    ProjectTransferImportPlan plan,
    ProjectTransferSection section,
  ) {
    final conflicts = _visibleConflicts(plan, section);
    final bulkTargets = conflicts
        .where((conflict) => !conflict.requiresChoice)
        .toList(growable: false);
    final needsAttention = _unresolvedIn(plan, section).length;
    final colorScheme = Theme.of(context).colorScheme;
    final matched = plan.matchedBySection[section] ?? 0;
    final fresh = plan.newBySection[section] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: section.localizedLabel(context.l10n),
          message: context.l10n.projectTransferReviewMatches,
        ),
        if (bulkTargets.isNotEmpty) ...[
          const SizedBox(height: 12),
          Center(
            child: PopupMenuButton<ProjectTransferConflictAction>(
              // Duplicate identifiers are left out: a blanket choice would
              // dispose of them without the user reading the warning.
              tooltip: context.l10n.projectTransferBulkTooltip,
              onSelected: (action) => setState(() {
                for (final conflict in bulkTargets) {
                  if (conflict.allowedActions.contains(action)) {
                    _actions[conflict.id] = action;
                  }
                }
              }),
              itemBuilder: (context) => ProjectTransferConflictAction.values
                  .map(
                    (action) => PopupMenuItem(
                      value: action,
                      child: Text(
                        context.l10n.projectTransferActionForAll(
                          action.localizedLabel(context.l10n),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              child: Chip(
                avatar: const Icon(Icons.tune_rounded, size: 18),
                label: Text(context.l10n.projectTransferBulkAction),
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
            _StatusChip(
              label: context.l10n.projectTransferStatusNew,
              count: fresh,
              color: colorScheme.tertiary,
              onColor: colorScheme.onTertiary,
            ),
            _StatusChip(
              label: context.l10n.projectTransferStatusMatched,
              count: matched,
              color: colorScheme.primary,
              onColor: colorScheme.onPrimary,
            ),
            _StatusChip(
              label: context.l10n.projectTransferNeedsAttention,
              count: needsAttention,
              color: colorScheme.error,
              onColor: colorScheme.onError,
            ),
            _StatusChip(
              label: context.l10n.projectTransferSkipped,
              count: conflicts.where((conflict) {
                return _actions[conflict.id] ==
                    ProjectTransferConflictAction.skip;
              }).length,
              color: colorScheme.outline,
              onColor: colorScheme.surface,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (conflicts.isEmpty)
          _MessageCard(
            icon: Icons.check_circle_outline_rounded,
            title: context.l10n.projectTransferNoConflicts,
            message: context.l10n.projectTransferNoConflictsBody,
          )
        else
          for (final conflict in conflicts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ConflictCard(
                conflict: conflict,
                action:
                    _actions[conflict.id] ??
                    (conflict.requiresChoice
                        ? null
                        : ProjectTransferConflictAction.keepCurrent),
                onChanged: (action) =>
                    setState(() => _actions[conflict.id] = action),
              ),
            ),
      ],
    );
  }

  Widget _review(ProjectTransferImportPlan plan) {
    final l10n = context.l10n;
    final blockedSections = _blockedSections(plan);
    final skipped = _actions.values
        .where((action) => action == ProjectTransferConflictAction.skip)
        .length;
    final replacements = _actions.values
        .where((action) => action == ProjectTransferConflictAction.useImported)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: _isNewProject
              ? l10n.projectTransferReviewImport
              : l10n.projectTransferReviewMerge,
          message: l10n.projectTransferReviewBody,
        ),
        const SizedBox(height: 16),
        NahpuPanel(
          child: Column(
            children: [
              _ReviewRow(
                label: l10n.projectTransferSourceProject,
                value: plan.payload.projectName,
              ),
              _ReviewRow(
                label: l10n.projectTransferDestination,
                value: _isNewProject
                    ? _destinationNameController.text.trim()
                    : plan.activeProjectName,
              ),
              _ReviewRow(
                label: l10n.projectTransferUuidHandling,
                value: _isNewProject
                    ? l10n.projectTransferNewUuid(plan.destinationProjectUuid)
                    : plan.hasUuidMismatch
                    ? l10n.projectTransferForceMergeUuid
                    : l10n.projectTransferMatchingUuid,
              ),
              _ReviewRow(
                label: l10n.projectTransferConflicts,
                value: '${plan.conflicts.length}',
              ),
              _ReviewRow(
                label: l10n.projectTransferNeedsAttention,
                value: '${unresolvedConflicts(plan, _actions).length}',
              ),
              _ReviewRow(
                label: l10n.projectTransferUseImported,
                value: '$replacements',
              ),
              _ReviewRow(label: l10n.projectWizardSkip, value: '$skipped'),
              _ReviewRow(
                label: l10n.projectTransferMediaFiles,
                value: '${plan.payload.mediaFiles.length}',
              ),
              if (_isNewProject)
                for (final entry in plan.payload.summary.entries)
                  if (entry.key != 'Media')
                    _ReviewRow(
                      label: projectTransferSummaryLabel(l10n, entry.key),
                      value: '${entry.value}',
                    ),
            ],
          ),
        ),
        if (blockedSections.isNotEmpty) ...[
          const SizedBox(height: 16),
          _MessageCard(
            icon: Icons.report_problem_outlined,
            title: l10n.projectTransferResolveConflicts,
            message:
                '${l10n.projectTransferDuplicateIdentifiers(blockedSections.map((section) => section.localizedLabel(l10n)).join(', '))} '
                '$duplicateIdentifierAdvice',
          ),
        ],
        if (plan.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          NahpuPanel(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.projectTransferArchiveWarnings,
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
    final l10n = context.l10n;
    final result = _result;
    if (result == null) {
      return _MessageCard(
        icon: Icons.error_outline_rounded,
        title: _isNewProject
            ? l10n.projectTransferImportUnfinished
            : l10n.projectTransferMergeUnfinished,
        message:
            _error ??
            (_isNewProject
                ? l10n.projectTransferImportRetry
                : l10n.projectTransferMergeRetry),
      );
    }
    return NahpuPanel(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            _isNewProject
                ? l10n.projectTransferImported
                : l10n.projectTransferMerged,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ResultCount(
                label: _isNewProject
                    ? l10n.projectTransferCountImported
                    : l10n.projectTransferCountMerged,
                value: result.imported,
              ),
              _ResultCount(
                label: l10n.projectTransferCountUpdated,
                value: result.updated,
              ),
              _ResultCount(
                label: l10n.projectTransferSkipped,
                value: result.skipped,
              ),
              if (result.skippedByConflict > 0)
                _ResultCount(
                  label: l10n.projectTransferSkippedOnConflict,
                  value: result.skippedByConflict,
                ),
              _ResultCount(
                label: l10n.projectTransferMediaCopied,
                value: result.mediaCopied,
              ),
            ],
          ),
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.projectTransferWarnings,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final warning in result.warnings) Text('• $warning'),
                ],
              ),
            ),
          ],
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
    final plan = _plan;
    if (plan == null) return false;
    final section = _sectionByStep[_step];
    if (section != null && _unresolvedIn(plan, section).isNotEmpty) {
      return false;
    }
    // Sections can gate each other, so the last stop checks all of them.
    if (_step == _reviewStep &&
        unresolvedConflicts(plan, _actions).isNotEmpty) {
      return false;
    }
    return true;
  }

  /// Sections still holding an unresolved duplicate identifier.
  List<ProjectTransferSection> _blockedSections(
    ProjectTransferImportPlan plan,
  ) => _sectionByStep.values
      .where((section) => _unresolvedIn(plan, section).isNotEmpty)
      .toList(growable: false);

  Future<void> _chooseArchive() async {
    final input = await FilePickerServices().selectAnyFile();
    if (input == null || !mounted) return;
    await _loadArchive(input);
  }

  Future<void> _loadArchive(XFile input) async {
    final reporter = ExportProgressReporter(
      steps: ProjectTransferArchiveService.importPhases,
    );
    final cancellation = ExportCancellation();
    setState(() {
      _isReading = true;
      _isCancellingRead = false;
      _error = null;
      _existingProject = null;
      _selectedInput = input;
      _readCancellation = cancellation;
      _readProgress = ExportJobProgress.pending(reporter.steps);
    });
    _readSubscription = reporter.stream.listen((progress) {
      if (mounted) setState(() => _readProgress = progress);
    });
    ProjectTransferArchiveFile? opened;
    try {
      opened = await ProjectTransferService(
        ref: ref,
      ).archive.read(input, progress: reporter, cancel: cancellation);
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
    } on ExportCancelledException {
      if (opened != null) await opened.dispose();
      if (!mounted) return;
      setState(() {
        _plan = null;
        _selectedInput = null;
        _error = null;
      });
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
      await _readSubscription?.cancel();
      _readSubscription = null;
      await reporter.dispose();
      if (mounted) {
        setState(() {
          _isReading = false;
          _isCancellingRead = false;
          _readCancellation = null;
          _readProgress = null;
        });
      }
    }
  }

  void _requestReadCancel() {
    _readCancellation?.cancel();
    setState(() => _isCancellingRead = true);
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
    if (trimmed.length < 3) return context.l10n.projectNameTooShort;
    if (trimmed.length > 25) return context.l10n.projectNameTooLong;
    if (!trimmed.isValidProjectName) return context.l10n.projectNameInvalid;
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
          : context.l10n.projectNameExists;
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

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.conflict,
    required this.action,
    required this.onChanged,
  });

  final ProjectTransferConflict conflict;

  /// Null while a blocking conflict is still waiting for the user to choose.
  final ProjectTransferConflictAction? action;
  final ValueChanged<ProjectTransferConflictAction> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final needsChoice = conflict.requiresChoice && action == null;
    return NahpuPanel(
      borderColor: needsChoice ? colorScheme.error : null,
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
              Chip(
                label: Text(
                  needsChoice
                      ? context.l10n.projectTransferNeedsAttention
                      : context.l10n.projectTransferConflict,
                ),
                backgroundColor: needsChoice
                    ? colorScheme.errorContainer
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final current = _ComparisonPane(
                label: context.l10n.projectTransferCurrent,
                value: conflict.currentSummary,
              );
              final imported = _ComparisonPane(
                label: context.l10n.projectTransferCountImported,
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
            const SizedBox(height: 8),
            Text(
              conflict.warning!,
              // Only a blocking conflict earns the error colour; advisory
              // notes on ordinary matches would otherwise read as failures.
              style: TextStyle(
                color: conflict.requiresChoice
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 14),
          DropdownButtonFormField<ProjectTransferConflictAction>(
            // The form field only reads initialValue once, so bulk actions
            // need a new field to show up.
            key: ValueKey('${conflict.id}:$action'),
            initialValue: action,
            decoration: InputDecoration(
              labelText: context.l10n.projectTransferConflictAction,
              hintText: needsChoice
                  ? context.l10n.projectTransferChooseAction
                  : null,
              errorText: needsChoice
                  ? context.l10n.projectTransferChooseActionToContinue
                  : null,
              border: const OutlineInputBorder(),
            ),
            items: conflict.allowedActions
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.localizedLabel(context.l10n)),
                  ),
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
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioGroup<bool>(
            groupValue: useImported,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            child: Column(
              children: [
                RadioListTile<bool>(
                  value: false,
                  title: Text(context.l10n.projectTransferKeepCurrent),
                  subtitle: Text(_displayValue(context, currentValue)),
                ),
                RadioListTile<bool>(
                  value: true,
                  title: Text(context.l10n.projectTransferUseImported),
                  subtitle: Text(_displayValue(context, importedValue)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(BuildContext context, String? value) =>
      value == null || value.isEmpty
      ? context.l10n.projectTransferNotSet
      : value;
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
    return NahpuPanel(
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
    return NahpuPanel(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value.isEmpty ? context.l10n.projectTransferNoDetails : value),
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
    required this.onColor,
  });

  final String label;
  final int count;
  final Color color;

  /// Contrasting colour for the count drawn on top of [color].
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$count',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: onColor),
        ),
      ),
      label: Text(label),
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
