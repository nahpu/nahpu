import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_columns_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_file_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_mode_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_result_step.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_review_step.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_column_matcher.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_reader.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/providers/batch_import.dart';

/// Full-screen wizard that updates or creates project records from a CSV,
/// TSV, or Excel file.
class BatchImportPage extends ConsumerStatefulWidget {
  const BatchImportPage({super.key});

  @override
  ConsumerState<BatchImportPage> createState() => _BatchImportPageState();
}

class _BatchImportPageState extends ConsumerState<BatchImportPage> {
  static const _steps = ['Mode', 'File', 'Columns', 'Review', 'Result'];
  static const _fileStep = 1;
  static const _columnsStep = 2;
  static const _reviewStep = 3;
  static const _resultStep = 4;

  int _step = 0;
  int _maxVisitedStep = 0;
  BatchImportMode _mode = BatchImportMode.create;
  DataTableRecordType _type = DataTableRecordType.specimenRecords;
  XFile? _file;
  BatchImportTable? _table;
  bool _isBusy = false;
  String? _error;
  BatchImportHeaderMode _headerMode = BatchImportHeaderMode.auto;
  List<BatchColumnMatch> _matches = const [];
  BatchImportKey? _key;
  BatchImportReview? _review;
  bool _includeMissingLinks = true;
  (int, int)? _progress;
  BatchImportResult? _result;

  @override
  Widget build(BuildContext context) {
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
                  if (_result == null) setState(() => _step = index);
                },
                child: switch (_step) {
                  0 => BatchModeStep(
                    mode: _mode,
                    type: _type,
                    onModeChanged: (mode) => _changeSetup(mode: mode),
                    onTypeChanged: (type) => _changeSetup(type: type),
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
                  _reviewStep => BatchReviewStep(
                    review: _review!,
                    includeMissingLinks: _includeMissingLinks,
                    progress: _progress,
                    error: _error,
                    onIncludeMissingLinksChanged: (value) =>
                        setState(() => _includeMissingLinks = value),
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

  bool get _canContinue {
    if (_isBusy) return false;
    return switch (_step) {
      0 => true,
      _fileStep => _table != null,
      _columnsStep =>
        _matches.any((match) => match.fieldKey != null) &&
            (_mode == BatchImportMode.create || _key != null),
      _reviewStep =>
        _review!
            .importable(includeMissingLinks: _includeMissingLinks)
            .isNotEmpty,
      _ => false,
    };
  }

  Future<void> _continue() async {
    switch (_step) {
      case 0:
        _goTo(_fileStep);
      case _fileStep:
        if (_matches.isEmpty) await _match();
        if (mounted) _goTo(_columnsStep);
      case _columnsStep:
        await _runReview();
      case _reviewStep:
        await _apply();
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
    _result = null;
    _maxVisitedStep = step;
  }

  void _changeSetup({BatchImportMode? mode, DataTableRecordType? type}) {
    setState(() {
      _mode = mode ?? _mode;
      _type = type ?? _type;
      _invalidateFrom(_table == null ? 0 : _fileStep);
    });
  }

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
      terms = await ref.read(batchDwcTermsProvider(_type).future);
    } catch (_) {
      // Names still match without the Darwin Core mapping.
      terms = const {};
    }
    final saved = ref
        .read(batchMappingStoreProvider)
        .load(_type, _mode, table.headers);
    final matches = BatchColumnMatcher(
      targets: batchImportTargets(_type),
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
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
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
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _apply() async {
    setState(() {
      _isBusy = true;
      _error = null;
      _progress = (0, 0);
    });
    try {
      final result = await ref.read(batchImportApplierProvider)(
        ref,
        _review!,
        includeMissingLinks: _includeMissingLinks,
        onProgress: (done, total) {
          if (mounted) setState(() => _progress = (done, total));
        },
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _step = _resultStep;
        _maxVisitedStep = _resultStep;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _openTable() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => DataTableScreen(initialType: _type),
      ),
    );
  }
}
