import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_columns_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_file_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_groups_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_linked_review_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_mode_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_result_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_review_step.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_column_matcher.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_reader.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/import/batch/batch_linked_models.dart';
import 'package:nahpu/services/import/batch/batch_linked_service.dart';
import 'package:nahpu/services/providers/batch_import.dart';

/// Full-screen wizard that updates or creates project records from a CSV,
/// TSV, or Excel file. A linked import also groups each row's site and
/// event, which the user checks in an extra step.
class BatchImportPage extends ConsumerStatefulWidget {
  const BatchImportPage({super.key});

  @override
  ConsumerState<BatchImportPage> createState() => _BatchImportPageState();
}

class _BatchImportPageState extends ConsumerState<BatchImportPage> {
  static const _fileStep = 1;
  static const _columnsStep = 2;

  int _step = 0;
  int _maxVisitedStep = 0;
  BatchImportMode _mode = BatchImportMode.create;
  DataTableRecordType _type = DataTableRecordType.specimenRecords;
  bool _linked = false;
  XFile? _file;
  BatchImportTable? _table;
  bool _isBusy = false;
  String? _error;
  BatchImportHeaderMode _headerMode = BatchImportHeaderMode.auto;
  List<BatchColumnMatch> _matches = const [];
  BatchImportKey? _key;
  BatchImportReview? _review;
  BatchLinkedPlan? _linkedPlan;
  bool _includeMissingLinks = true;
  (int, int)? _progress;
  BatchImportResult? _result;
  BatchLinkedResult? _linkedResult;

  @override
  Widget build(BuildContext context) {
    final step = _step;
    return Scaffold(
      appBar: AppBar(title: const Text('Batch import')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NahpuWizardScaffold(
                steps: _steps,
                currentStep: _step,
                maxVisitedStep: _maxVisitedStep,
                onStepSelected: (index) {
                  // Written records can't be reviewed and written again.
                  if (!_isDone) setState(() => _step = index);
                },
                child: switch (step) {
                  0 => BatchModeStep(
                    mode: _mode,
                    type: _type,
                    linked: _linked,
                    onModeChanged: (mode) => _changeSetup(mode: mode),
                    onTypeChanged: (type) => _changeSetup(type: type),
                    onLinkedSelected: () => _changeSetup(linked: true),
                  ),
                  _fileStep => BatchFileStep(
                    file: _file,
                    table: _table,
                    isReading: _isBusy,
                    error: _error,
                    onPick: _pickFile,
                    onClear: _clearFile,
                    onSheetChanged: (sheet) => _readFile(_file!, sheet: sheet),
                  ),
                  _columnsStep => BatchColumnsStep(
                    table: _table!,
                    type: _type,
                    targets: _targets,
                    mode: _mode,
                    headerMode: _headerMode,
                    matches: _matches,
                    selectedKey: _key,
                    onHeaderModeChanged: _changeHeaderMode,
                    onFieldChanged: _changeField,
                    onKeyChanged: (key) => setState(() {
                      _key = key;
                      _invalidateFrom(_columnsStep);
                    }),
                  ),
                  _ when step == _groupsStep => BatchGroupsStep(
                    plan: _linkedPlan!,
                    onChanged: _changePlan,
                    linkOptions: (link) =>
                        ref.read(batchLinkOptionsLoaderProvider)(ref, link),
                  ),
                  _ when step == _reviewStep && _linked =>
                    BatchLinkedReviewStep(
                      plan: _linkedPlan!,
                      includeMissingLinks: _includeMissingLinks,
                      progress: _progress,
                      error: _error,
                      onIncludeMissingLinksChanged: (value) =>
                          setState(() => _includeMissingLinks = value),
                      onChanged: _changePlan,
                    ),
                  _ when step == _reviewStep => BatchReviewStep(
                    review: _review!,
                    includeMissingLinks: _includeMissingLinks,
                    progress: _progress,
                    error: _error,
                    onIncludeMissingLinksChanged: (value) =>
                        setState(() => _includeMissingLinks = value),
                  ),
                  _ when _linked => BatchLinkedResultStep(
                    result: _linkedResult!,
                    onOpenTable: _openTable,
                  ),
                  _ => BatchResultStep(
                    result: _result!,
                    onOpenTable: _openTable,
                  ),
                },
              ),
            ),
            NahpuWizardActionBar(
              step: _step,
              lastStep: _resultStep,
              isRunning: _isBusy,
              canContinue: _canContinue,
              finalActionLabel: _mode == BatchImportMode.update
                  ? 'Update records'
                  : 'Import records',
              finalActionIcon: _mode == BatchImportMode.update
                  ? Icons.edit_note_rounded
                  : Icons.download_rounded,
              onBack: () => setState(() => _step--),
              onContinue: _continue,
              onClose: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  List<String> get _steps => [
    'Mode',
    'File',
    'Columns',
    if (_linked) 'Groups',
    'Review',
    'Result',
  ];

  /// -1 when the import has no groups step.
  int get _groupsStep => _linked ? 3 : -1;
  int get _reviewStep => _steps.length - 2;
  int get _resultStep => _steps.length - 1;
  bool get _isDone => _result != null || _linkedResult != null;

  List<BatchImportTarget> get _targets =>
      _linked ? batchLinkedTargets() : batchImportTargets(_type);

  bool get _canContinue {
    if (_isBusy) return false;
    final step = _step;
    if (step == 0) return true;
    if (step == _fileStep) return _table != null;
    if (step == _columnsStep) {
      return _matches.any((match) => match.fieldKey != null) &&
          (_mode == BatchImportMode.create || _key != null);
    }
    if (step == _groupsStep) {
      final plan = _linkedPlan!;
      return plan.sites.isNotEmpty ||
          plan.events.isNotEmpty ||
          plan.specimens.isNotEmpty;
    }
    if (step == _reviewStep) {
      if (_linked) {
        final counts = _linkedPlan!.counts(
          includeMissingLinks: _includeMissingLinks,
        );
        return counts.newSites +
                counts.linkedSites +
                counts.newEvents +
                counts.linkedEvents +
                counts.specimens >
            0;
      }
      return _review!
          .importable(includeMissingLinks: _includeMissingLinks)
          .isNotEmpty;
    }
    return false;
  }

  Future<void> _continue() async {
    final step = _step;
    if (step == 0) {
      _goTo(_fileStep);
    } else if (step == _fileStep) {
      if (_matches.isEmpty) await _match();
      if (mounted) _goTo(_columnsStep);
    } else if (step == _columnsStep) {
      await (_linked ? _runGrouping() : _runReview());
    } else if (step == _groupsStep) {
      _goTo(_reviewStep);
    } else if (step == _reviewStep) {
      await (_linked ? _applyLinked() : _apply());
    }
  }

  void _goTo(int step) {
    setState(() {
      _step = step;
      if (step > _maxVisitedStep) _maxVisitedStep = step;
    });
  }

  /// Drops the work of steps after [step], which no longer fits what
  /// changed.
  void _invalidateFrom(int step) {
    if (step < _columnsStep) {
      _matches = const [];
      _key = null;
    }
    _review = null;
    _linkedPlan = null;
    _result = null;
    _linkedResult = null;
    _maxVisitedStep = step;
  }

  void _changeSetup({
    BatchImportMode? mode,
    DataTableRecordType? type,
    bool? linked,
  }) {
    setState(() {
      _mode = mode ?? _mode;
      _type = type ?? _type;
      // Linked imports only create; choosing a type leaves them.
      _linked =
          _mode == BatchImportMode.create &&
          (linked ?? (type == null && _linked));
      _invalidateFrom(_table == null ? 0 : _fileStep);
    });
  }

  void _changePlan(BatchLinkedPlan plan) => setState(() => _linkedPlan = plan);

  Future<void> _pickFile() async {
    final file = await ref.read(batchImportFilePickerProvider)();
    if (file == null || !mounted) return;
    if (!BatchImportReader.supportsPath(file.path)) {
      setState(() => _error = 'Choose a CSV, TSV, or Excel file.');
      return;
    }
    await _readFile(file);
  }

  Future<void> _readFile(XFile file, {String? sheet}) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final table = await ref.read(batchImportFileReaderProvider)(
        file.path,
        sheetName: sheet,
      );
      if (!mounted) return;
      setState(() {
        _file = file;
        _table = table;
        _invalidateFrom(_fileStep);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e is FormatException ? e.message : '$e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _clearFile() {
    setState(() {
      _file = null;
      _table = null;
      _error = null;
      _invalidateFrom(_fileStep);
    });
  }

  Future<void> _match() async {
    final table = _table!;
    Map<String, String> terms;
    try {
      terms = await ref.read(
        batchDwcTermsProvider(_linked ? null : _type).future,
      );
    } catch (_) {
      // Names still match without the Darwin Core mapping.
      terms = const {};
    }
    final saved = ref
        .read(batchMappingStoreProvider)
        .load(_type, _mode, table.headers, linked: _linked);
    final matches = BatchColumnMatcher(
      targets: _targets,
      dwcTerms: terms,
    ).match(table.headers, mode: _headerMode, saved: saved);
    if (!mounted) return;
    setState(() {
      _matches = matches;
      _key = _defaultKey(matches);
    });
  }

  BatchImportKey? _defaultKey(List<BatchColumnMatch> matches) {
    if (_mode == BatchImportMode.create) return null;
    final available = BatchImportKey.available(_type, [
      for (final match in matches) match.fieldKey,
    ]);
    if (available.contains(_key)) return _key;
    return available.firstOrNull;
  }

  Future<void> _changeHeaderMode(BatchImportHeaderMode mode) async {
    setState(() {
      _headerMode = mode;
      _invalidateFrom(_columnsStep);
    });
    await _match();
  }

  void _changeField(int column, String? fieldKey) {
    setState(() {
      _matches = [
        for (final match in _matches)
          match.column == column ? match.withField(fieldKey) : match,
      ];
      _key = _defaultKey(_matches);
      _invalidateFrom(_columnsStep);
    });
  }

  Future<void> _runReview() async {
    await _busy(() async {
      await ref.read(batchMappingStoreProvider).save(_type, _mode, _matches);
      final review = await ref.read(batchImportReviewerProvider)(
        ref,
        table: _table!,
        type: _type,
        mode: _mode,
        matches: _matches,
        key: _key,
      );
      if (!mounted) return;
      setState(() {
        _review = review;
        _progress = null;
      });
      _goTo(_reviewStep);
    });
  }

  Future<void> _runGrouping() async {
    await _busy(() async {
      await ref
          .read(batchMappingStoreProvider)
          .save(_type, _mode, _matches, linked: true);
      final plan = await ref.read(batchLinkedGroupLoaderProvider)(
        ref,
        _table!,
        _matches,
      );
      if (!mounted) return;
      setState(() {
        _linkedPlan = plan;
        _progress = null;
      });
      _goTo(_groupsStep);
    });
  }

  Future<void> _apply() async {
    setState(() => _progress = (0, 0));
    await _busy(() async {
      final result = await ref.read(batchImportApplierProvider)(
        ref,
        _review!,
        includeMissingLinks: _includeMissingLinks,
        onProgress: _onProgress,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _step = _resultStep;
        _maxVisitedStep = _resultStep;
      });
    });
  }

  Future<void> _applyLinked() async {
    setState(() => _progress = (0, 0));
    await _busy(() async {
      final result = await ref.read(batchLinkedApplierProvider)(
        ref,
        _linkedPlan!,
        includeMissingLinks: _includeMissingLinks,
        onProgress: _onProgress,
      );
      if (!mounted) return;
      setState(() {
        _linkedResult = result;
        _step = _resultStep;
        _maxVisitedStep = _resultStep;
      });
    });
  }

  void _onProgress(int done, int total) {
    if (mounted) setState(() => _progress = (done, total));
  }

  /// Runs [work] with the wizard marked busy, showing any error.
  Future<void> _busy(Future<void> Function() work) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await work();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _openTable() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => DataTableScreen(
          initialType: _linked ? DataTableRecordType.specimenRecords : _type,
        ),
      ),
    );
  }
}
