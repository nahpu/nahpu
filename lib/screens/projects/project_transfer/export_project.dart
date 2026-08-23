import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/projects/project_transfer_service.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ExportProjectScreen extends ConsumerStatefulWidget {
  const ExportProjectScreen({super.key});

  @override
  ConsumerState<ExportProjectScreen> createState() =>
      _ExportProjectScreenState();
}

class _ExportProjectScreenState extends ConsumerState<ExportProjectScreen> {
  final _fileNameController = TextEditingController();
  ProjectTransferArchiveFormat _format = ProjectTransferArchiveFormat.tarGzip;
  bool _lightExport = false;
  ProjectTransferPayload? _payload;
  Directory? _directory;
  File? _output;
  bool _appendDate = false;
  String? _error;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCancelling = false;
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
    _load();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    unawaited(_progressSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Leaving mid-export would orphan the staging directory and the partly
      // written archive, so the user has to cancel deliberately.
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export project')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final settings = _SettingsCard(
              controller: _fileNameController,
              format: _format,
              lightExport: _lightExport,
              directory: _directory,
              appendDate: _appendDate,
              enabled: !_isLoading && !_isSaving,
              onFormatChanged: (value) {
                setState(() {
                  _format = value;
                  _output = null;
                });
              },
              onAppendDateChanged: (value) {
                setState(() {
                  _appendDate = value;
                  _output = null;
                });
              },
              onFileNameChanged: (_) => setState(() => _output = null),
              onLightExportChanged: (value) {
                setState(() {
                  _lightExport = value;
                  _output = null;
                });
              },
              onSelectDirectory: _selectDirectory,
              onClearDirectory: () => setState(() {
                _directory = null;
                _output = null;
              }),
            );
            final jobProgress = _jobProgress;
            final leftPane = _isSaving && jobProgress != null
                ? ExportProgressPanel(
                    title: 'Exporting project',
                    progress: jobProgress,
                    hint:
                        'Projects with many photos can take several minutes. '
                        'Keep NAHPU open until this finishes.',
                    isCancelling: _isCancelling,
                    onCancel: _requestCancel,
                  )
                : settings;
            final rightPane = _outcome != null && !_isSaving
                ? ExportResultPanel(
                    outcome: _outcome!,
                    successTitle: 'Project exported',
                    output: _output,
                    outputBytes: _outputBytes,
                    duration: _runDuration,
                    errorMessage: _runError,
                    failedStepLabel: _failedStepLabel,
                    onShare: _share,
                    onRetry: _save,
                  )
                : _SummaryCard(
                    payload: _payload,
                    isLoading: _isLoading,
                    error: _error,
                    includeMedia: !_lightExport,
                  );
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
                _ExportActionBar(
                  isSaving: _isSaving,
                  canExport: _payload != null && _error == null,
                  hasOutput: _output != null,
                  onExport: _save,
                  onShare: _share,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _load() async {
    try {
      final payload = await ProjectTransferService(ref: ref).buildExport();
      if (!mounted) return;
      setState(() {
        _payload = payload;
        _fileNameController.text =
            '${_safeStem(payload.projectName)}-nahpu-transfer';
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDirectory() async {
    final selected = await FilePickerServices().selectDir();
    if (selected == null || !mounted) return;
    setState(() {
      _directory = selected;
      _output = null;
    });
  }

  Future<void> _save() async {
    final payload = _payload;
    if (payload == null) return;
    final format = _lightExport
        ? ProjectTransferArchiveFormat.jsonGzip
        : _format;
    final reporter = ExportProgressReporter(
      steps: ProjectTransferArchiveService.exportPhases(payload, format),
    );
    final cancellation = ExportCancellation();
    final stopwatch = Stopwatch()..start();
    setState(() {
      _isSaving = true;
      _isCancelling = false;
      _outcome = null;
      _runError = null;
      _failedStepLabel = null;
      _outputBytes = null;
      _runDuration = null;
      _cancellation = cancellation;
      _jobProgress = ExportJobProgress.pending(reporter.steps);
    });
    _progressSubscription = reporter.stream.listen((progress) {
      if (mounted) setState(() => _jobProgress = progress);
    });
    try {
      final output = await ProjectTransferService(ref: ref).archive.save(
        payload,
        fileStem: _appendDate
            ? appendDateToFileStem(_fileNameController.text, DateTime.now())
            : _fileNameController.text,
        format: format,
        destinationDirectory: _directory,
        progress: reporter,
        cancel: cancellation,
      );
      final bytes = await output.length();
      if (!mounted) return;
      setState(() {
        _output = output;
        _outcome = ExportOutcome.succeeded;
        _outputBytes = bytes;
        _runDuration = stopwatch.elapsed;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project transfer saved as ${output.path}')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ErrorText(error: error.toString()),
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      await _progressSubscription?.cancel();
      _progressSubscription = null;
      await reporter.dispose();
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isCancelling = false;
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
        title: const Text('Cancel the export?'),
        content: const Text(
          'The export is still running. Leaving now cancels it and no file '
          'will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep exporting'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel export'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) _requestCancel();
  }

  Future<void> _share() async {
    final output = _output;
    if (output == null) return;
    await FilePickerServices().shareFile(context, output);
  }

  String _safeStem(String value) {
    final cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'project' : cleaned;
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.controller,
    required this.format,
    required this.lightExport,
    required this.directory,
    required this.appendDate,
    required this.enabled,
    required this.onFormatChanged,
    required this.onAppendDateChanged,
    required this.onFileNameChanged,
    required this.onLightExportChanged,
    required this.onSelectDirectory,
    required this.onClearDirectory,
  });

  final TextEditingController controller;
  final ProjectTransferArchiveFormat format;
  final bool lightExport;
  final Directory? directory;
  final bool appendDate;
  final bool enabled;
  final ValueChanged<ProjectTransferArchiveFormat> onFormatChanged;
  final ValueChanged<bool> onAppendDateChanged;
  final ValueChanged<String> onFileNameChanged;
  final ValueChanged<bool> onLightExportChanged;
  final VoidCallback onSelectDirectory;
  final VoidCallback onClearDirectory;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup and transfer archive',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this archive to create a project backup, '
              'transfer, or merge this project data to another device.',
            ),
            const SizedBox(height: 20),
            if (!lightExport)
              SegmentedButton<ProjectTransferArchiveFormat>(
                segments: const [
                  ButtonSegment(
                    value: ProjectTransferArchiveFormat.tarGzip,
                    label: Text('TAR.GZ'),
                    icon: Icon(Icons.folder_zip_outlined),
                  ),
                  ButtonSegment(
                    value: ProjectTransferArchiveFormat.zip,
                    label: Text('ZIP'),
                    icon: Icon(Icons.folder_zip_outlined),
                  ),
                ],
                selected: {format},
                onSelectionChanged: enabled
                    ? (values) => onFormatChanged(values.single)
                    : null,
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Light export'),
              subtitle: lightExport
                  ? const Text(
                      'Export the project without media files for limited-internet uploads. '
                      'Use TAR.GZ or ZIP for a full project backup.',
                    )
                  : null,
              value: lightExport,
              onChanged: enabled ? onLightExportChanged : null,
            ),
            const SizedBox(height: 20),
            FileNameField(
              controller: controller,
              extension: lightExport
                  ? ProjectTransferArchiveFormat.jsonGzip.extension
                  : format.extension,
              appendDate: appendDate,
              enabled: enabled,
              onChanged: onFileNameChanged,
            ),
            AppendDateSwitch(
              value: appendDate,
              enabled: enabled,
              onChanged: onAppendDateChanged,
            ),
            const SizedBox(height: 16),
            if (systemPlatform == PlatformType.desktop)
              FileSettingsDirectoryPicker(
                selectedDir: directory,
                onSelectDir: enabled ? onSelectDirectory : () {},
                onClearDir: enabled ? onClearDirectory : () {},
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.payload,
    required this.isLoading,
    required this.error,
    required this.includeMedia,
  });

  final ProjectTransferPayload? payload;
  final bool isLoading;
  final String? error;
  final bool includeMedia;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Archive contents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              ErrorText(error: error!)
            else ...[
              for (final entry in payload!.summary.entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline_rounded),
                  title: Text(entry.key),
                  trailing: Text(
                    entry.key == 'Media' && !includeMedia
                        ? 'Excluded'
                        : '${entry.value}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              if (includeMedia && payload!.mediaBytes > 0) ...[
                const Divider(),
                // Seeing the size up front is what tells the user whether this
                // is a ten second export or a ten minute one.
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.sd_storage_outlined),
                  title: Text(
                    'Media size',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  trailing: Text(
                    formatByteSize(payload!.mediaBytes),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
              if (includeMedia && payload!.warnings.isNotEmpty) ...[
                const Divider(),
                Text(
                  '${payload!.warnings.length} warning(s)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final warning in payload!.warnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $warning'),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ExportActionBar extends StatelessWidget {
  const _ExportActionBar({
    required this.isSaving,
    required this.canExport,
    required this.hasOutput,
    required this.onExport,
    required this.onShare,
  });

  final bool isSaving;
  final bool canExport;
  final bool hasOutput;
  final VoidCallback onExport;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasOutput)
                OutlinedButton.icon(
                  onPressed: onShare,
                  icon: Icon(Icons.adaptive.share_rounded),
                  label: const Text('Share'),
                ),
              if (hasOutput) const SizedBox(width: 12),
              // The running state is shown by the progress panel now, so this
              // button only has to stay out of the way while an export runs.
              FilledButton.icon(
                onPressed: canExport && !isSaving ? onExport : null,
                icon: const Icon(Icons.archive_outlined),
                label: Text(hasOutput ? 'Export another' : 'Export project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
