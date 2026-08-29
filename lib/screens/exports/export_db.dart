import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ExportDbForm extends ConsumerStatefulWidget {
  const ExportDbForm({super.key});

  @override
  ExportDbFormState createState() => ExportDbFormState();
}

class ExportDbFormState extends ConsumerState<ExportDbForm> {
  DbArchiveFormat _format = DbArchiveFormat.tarGzip;
  final _fileNameController = TextEditingController(text: 'backup');
  String _fileStem = 'backup';
  Directory? _selectedDir;
  bool _appendDate = false;
  DbBackupSummary? _summary;
  File? _savePath;
  String? _summaryError;
  bool _hasSaved = false;
  bool _isLoading = true;
  bool _isRunning = false;
  bool _isCancelling = false;
  ExportProgressReporter? _reporter;
  ExportCancellation? _cancellation;
  StreamSubscription<ExportJobProgress>? _progressSubscription;
  ExportJobProgress? _jobProgress;
  ExportOutcome? _outcome;
  String? _runError;
  String? _failedStepLabel;
  int? _outputBytes;
  Duration? _runDuration;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    unawaited(_progressSubscription?.cancel());
    unawaited(_reporter?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Leaving mid-backup would orphan the staging directory and the partly
      // written archive, so the user has to cancel deliberately.
      canPop: !_isRunning,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup database')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= NahpuBreakpoints.compact;
            final settings = _BackupSettingsCard(
              controller: _fileNameController,
              format: _format,
              appendDate: _appendDate,
              enabled: !_isLoading && !_isRunning,
              onFormatChanged: (value) {
                setState(() {
                  _format = value;
                  _hasSaved = false;
                });
              },
              onFileNameChanged: (value) {
                setState(() {
                  _fileStem = value;
                  _hasSaved = false;
                });
              },
              onAppendDateChanged: (value) {
                setState(() {
                  _appendDate = value;
                  _hasSaved = false;
                });
              },
            );
            final jobProgress = _jobProgress;
            final destination = ExportLocationCard(
              selectedDir: _selectedDir,
              output: _hasSaved ? _savePath : null,
              outputBytes: _outputBytes,
              duration: _runDuration,
              enabled: !_isLoading && !_isRunning,
              onSelectDir: _getDir,
              onClearDir: _clearDestination,
              onShare: () => _shareFile(context),
              onOpenFolder: _openFolder,
              onDismiss: _clearDestination,
            );
            final settingsPane = _isRunning && jobProgress != null
                ? ExportProgressPanel(
                    title: 'Backing up database',
                    progress: jobProgress,
                    hint:
                        'Large media libraries can take several minutes. '
                        'Keep NAHPU open until this finishes.',
                    isCancelling: _isCancelling,
                    onCancel: _requestCancel,
                  )
                : settings;
            // The destination belongs with the file settings it configures.
            final leftPane = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                settingsPane,
                const SizedBox(height: NahpuSpacing.xl),
                destination,
              ],
            );
            // A finished backup keeps the contents summary on screen: the
            // location card already reports the file.
            final failed =
                _outcome != null &&
                _outcome != ExportOutcome.succeeded &&
                !_isRunning;
            final rightPane = failed
                ? ExportFailurePanel(
                    outcome: _outcome!,
                    errorMessage: _runError,
                    failedStepLabel: _failedStepLabel,
                    onRetry: _writeDb,
                  )
                : _BackupSummary(summary: _summary, error: _summaryError);
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: leftPane),
                                  const SizedBox(width: NahpuSpacing.xxl),
                                  Expanded(child: rightPane),
                                ],
                              )
                            : Column(
                                children: [
                                  leftPane,
                                  const SizedBox(height: NahpuSpacing.xl),
                                  rightPane,
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                ExportActionBar(
                  label: 'Save backup',
                  repeatLabel: 'Save another',
                  icon: Icons.save_alt_outlined,
                  canExport:
                      !_isLoading &&
                      _summary != null &&
                      _summaryError == null &&
                      _fileNameController.text.trim().isNotEmpty,
                  isRunning: _isRunning,
                  hasOutput: _hasSaved,
                  onExport: _writeDb,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await DbExport(ref: ref, filePath: File('')).getSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _summaryError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _writeDb() async {
    final summary = _summary;
    if (summary == null) return;
    final reporter = ExportProgressReporter(
      steps: DbExport.backupPhases(summary),
    );
    final cancellation = ExportCancellation();
    final stopwatch = Stopwatch()..start();
    setState(() {
      _isRunning = true;
      _isCancelling = false;
      _outcome = null;
      _runError = null;
      _failedStepLabel = null;
      _outputBytes = null;
      _runDuration = null;
      _reporter = reporter;
      _cancellation = cancellation;
      _jobProgress = ExportJobProgress.pending(reporter.steps);
    });
    _progressSubscription = reporter.stream.listen((progress) {
      if (mounted) setState(() => _jobProgress = progress);
    });
    try {
      final savePath = await AppIOServices(
        dir: _selectedDir,
        fileStem: _appendDate
            ? appendDateToFileStem(_fileStem, DateTime.now())
            : _fileStem.trim(),
        ext: _format.extension,
      ).getSavePath();
      final output = await DbExport(
        ref: ref,
        filePath: savePath,
      ).write(_format, progress: reporter, cancel: cancellation);
      final bytes = await output.length();
      if (!mounted) return;
      setState(() {
        _hasSaved = true;
        _savePath = output;
        _outcome = ExportOutcome.succeeded;
        _outputBytes = bytes;
        _runDuration = stopwatch.elapsed;
      });
    } on ExportCancelledException {
      if (!mounted) return;
      setState(() {
        _outcome = ExportOutcome.cancelled;
        _runDuration = stopwatch.elapsed;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _outcome = ExportOutcome.failed;
        _runError = error.toString();
        _failedStepLabel = _jobProgress?.activeStep?.label;
        _runDuration = stopwatch.elapsed;
      });
      _showError(error.toString());
    } finally {
      await _progressSubscription?.cancel();
      _progressSubscription = null;
      await reporter.dispose();
      if (mounted) {
        setState(() {
          _isRunning = false;
          _isCancelling = false;
          _reporter = null;
          _cancellation = null;
        });
      }
    }
  }

  void _requestCancel() {
    _cancellation?.cancel();
    setState(() => _isCancelling = true);
  }

  Future<void> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel the backup?'),
        content: const Text(
          'The backup is still running. Leaving now cancels it and no file '
          'will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep backing up'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel backup'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) _requestCancel();
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorText(error: error),
        duration: const Duration(seconds: 10),
      ),
    );
  }

  Future<void> _shareFile(BuildContext context) async {
    final savePath = _savePath;
    if (savePath == null) return;
    try {
      await FilePickerServices().shareFile(context, savePath);
    } catch (error) {
      if (mounted) _showError(error.toString());
    }
  }

  Future<void> _openFolder() async {
    final savePath = _savePath;
    if (savePath == null) return;
    try {
      await FilePickerServices().openContainingDirectory(savePath);
    } catch (error) {
      if (mounted) _showError('Unable to open the folder: $error');
    }
  }

  /// Closing the result puts the screen back where it was before the backup,
  /// directory included, so one tap lands on the directory input rather than
  /// on a filled-in path that needs clearing too.
  void _clearDestination() {
    setState(() {
      _selectedDir = null;
      _hasSaved = false;
      _savePath = null;
      _outcome = null;
      _outputBytes = null;
      _runDuration = null;
    });
  }

  Future<void> _getDir() async {
    final selected = await FilePickerServices().selectDir();
    if (selected == null || !mounted) return;
    setState(() {
      _selectedDir = selected;
      _hasSaved = false;
    });
  }
}

class _BackupSettingsCard extends StatelessWidget {
  const _BackupSettingsCard({
    required this.controller,
    required this.format,
    required this.appendDate,
    required this.enabled,
    required this.onFormatChanged,
    required this.onFileNameChanged,
    required this.onAppendDateChanged,
  });

  final TextEditingController controller;
  final DbArchiveFormat format;
  final bool appendDate;
  final bool enabled;
  final ValueChanged<DbArchiveFormat> onFormatChanged;
  final ValueChanged<String> onFileNameChanged;
  final ValueChanged<bool> onAppendDateChanged;

  @override
  Widget build(BuildContext context) {
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backup archive', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'This creates a full NAHPU backup, including all projects, '
            'records, media, and app settings. For a project-only backup, '
            'use Project export.',
          ),
          const SizedBox(height: 20),
          SegmentedButton<DbArchiveFormat>(
            segments: const [
              ButtonSegment(
                value: DbArchiveFormat.tarGzip,
                label: Text('TAR.GZ'),
                icon: Icon(Icons.folder_zip_outlined),
              ),
              ButtonSegment(
                value: DbArchiveFormat.zip,
                label: Text('ZIP'),
                icon: Icon(Icons.folder_zip_outlined),
              ),
            ],
            selected: {format},
            onSelectionChanged: enabled
                ? (values) => onFormatChanged(values.single)
                : null,
          ),
          const SizedBox(height: 20),
          FileNameField(
            controller: controller,
            enabled: enabled,
            extension: format.extension,
            appendDate: appendDate,
            onChanged: onFileNameChanged,
          ),
          AppendDateSwitch(
            value: appendDate,
            enabled: enabled,
            onChanged: onAppendDateChanged,
          ),
        ],
      ),
    );
  }
}

class _BackupSummary extends StatelessWidget {
  const _BackupSummary({required this.summary, required this.error});

  final DbBackupSummary? summary;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entire database contents',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (error != null)
            ErrorText(error: error!)
          else if (summary == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            for (final entry in summary!.entries.entries)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(entry.key),
                trailing: Text('${entry.value}'),
              ),
            const CommonDivider(),
            // Knowing the size before pressing Save is what tells the user
            // whether this is a ten second job or a ten minute one.
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Backup size before compression',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: Text(
                formatByteSize(summary!.totalBytes),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
