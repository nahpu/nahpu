import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/media/media_export_service.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/styles/design_tokens.dart';

Future<void> showBatchMediaExport(
  BuildContext context, {
  required List<MediaData> media,
}) {
  if (media.isEmpty) return Future.value();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => BatchMediaExportScreen(media: media),
    ),
  );
}

class BatchMediaExportScreen extends ConsumerStatefulWidget {
  BatchMediaExportScreen({super.key, required List<MediaData> media})
    : media = List.unmodifiable(media);

  final List<MediaData> media;

  @override
  ConsumerState<BatchMediaExportScreen> createState() =>
      _BatchMediaExportScreenState();
}

class _BatchMediaExportScreenState
    extends ConsumerState<BatchMediaExportScreen> {
  final _fileNameController = TextEditingController();
  final _maxPixelsController = TextEditingController();
  MediaBatchArchiveFormat _archiveFormat = MediaBatchArchiveFormat.tarGzip;
  MediaExportFormat _imageFormat = MediaExportFormat.original;
  bool _appendDate = false;
  bool _limitImageSize = false;
  int _jpegQuality = 85;
  PreparedMediaBatch? _batch;
  String? _loadError;
  bool _isLoading = true;
  Directory? _directory;
  File? _output;
  MediaBatchExportResult? _result;
  bool _isSaving = false;
  bool _isCancelling = false;
  ExportCancellation? _cancellation;
  StreamSubscription<ExportJobProgress>? _progressSubscription;
  ExportJobProgress? _jobProgress;
  ExportOutcome? _outcome;
  String? _runError;
  String? _failedStepLabel;
  List<MediaBatchWarning> _failureWarnings = const [];
  Duration? _runDuration;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _maxPixelsController.dispose();
    unawaited(_progressSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Export selected media')),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= NahpuBreakpoints.compact;
              final progress = _jobProgress;
              final settingsPane = _isSaving && progress != null
                  ? ExportProgressPanel(
                      title: 'Exporting media',
                      progress: progress,
                      hint:
                          'Large media selections can take several minutes. '
                          'Keep NAHPU open until this finishes.',
                      onCancel: _requestCancel,
                      isCancelling: _isCancelling,
                    )
                  : _BatchMediaExportSettings(
                      fileNameController: _fileNameController,
                      maxPixelsController: _maxPixelsController,
                      archiveFormat: _archiveFormat,
                      imageFormat: _imageFormat,
                      hasImages: (_batch?.count(MediaKind.image) ?? 0) > 0,
                      appendDate: _appendDate,
                      limitImageSize: _limitImageSize,
                      jpegQuality: _jpegQuality,
                      enabled: !_isLoading && !_isSaving,
                      onArchiveFormatChanged: (value) => setState(() {
                        _archiveFormat = value;
                        _resetOutput();
                      }),
                      onImageFormatChanged: (value) => setState(() {
                        _imageFormat = value;
                        _resetOutput();
                      }),
                      onAppendDateChanged: (value) => setState(() {
                        _appendDate = value;
                        _resetOutput();
                      }),
                      onLimitImageSizeChanged: (value) => setState(() {
                        _limitImageSize = value;
                        _resetOutput();
                      }),
                      onJpegQualityChanged: (value) => setState(() {
                        _jpegQuality = value;
                        _resetOutput();
                      }),
                      onFileNameChanged: (_) => setState(_resetOutput),
                      onMaxPixelsChanged: (_) => setState(_resetOutput),
                    );
              final destination = ExportLocationCard(
                selectedDir: _directory,
                output: _output,
                outputBytes: _result?.bytes,
                duration: _runDuration,
                enabled: !_isLoading && !_isSaving,
                onSelectDir: _selectDirectory,
                onClearDir: _clearDestination,
                onShare: _share,
                onOpenFolder: _openFolder,
                onDismiss: _clearDestination,
              );
              final leftPane = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  settingsPane,
                  const SizedBox(height: NahpuSpacing.xl),
                  destination,
                ],
              );
              final failed =
                  _outcome != null &&
                  _outcome != ExportOutcome.succeeded &&
                  !_isSaving;
              final rightPane = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (failed) ...[
                    ExportFailurePanel(
                      outcome: _outcome!,
                      errorMessage: _runError,
                      failedStepLabel: _failedStepLabel,
                      onRetry: _canExport ? _save : null,
                    ),
                    const SizedBox(height: NahpuSpacing.xl),
                  ],
                  _BatchMediaSummary(
                    batch: _batch,
                    result: _result,
                    imageFormat: _imageFormat,
                    isLoading: _isLoading,
                    error: _loadError,
                    failureWarnings: _failureWarnings,
                  ),
                ],
              );
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        NahpuSpacing.xs,
                        NahpuSpacing.sm,
                        NahpuSpacing.xs,
                        NahpuSpacing.xl,
                      ),
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
                    label: 'Export media',
                    repeatLabel: 'Export another',
                    icon: Icons.archive_outlined,
                    canExport: _canExport,
                    isRunning: _isSaving,
                    hasOutput: _output != null,
                    onExport: _save,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool get _canExport {
    final batch = _batch;
    if (_isLoading || _isSaving || _loadError != null || batch == null) {
      return false;
    }
    if (batch.items.isEmpty || _fileNameController.text.trim().isEmpty) {
      return false;
    }
    if (_imageFormat != MediaExportFormat.original && _limitImageSize) {
      final value = int.tryParse(_maxPixelsController.text);
      return value != null && value > 0 && value <= 0xffffffff;
    }
    return true;
  }

  Future<void> _load() async {
    try {
      final batch = await MediaExportService(
        ref: ref,
      ).prepareBatch(widget.media);
      var projectName = 'nahpu';
      final projectUuid = widget.media
          .map((media) => media.projectUuid)
          .whereType<String>()
          .where((uuid) => uuid.isNotEmpty)
          .firstOrNull;
      if (projectUuid != null) {
        try {
          final project = await ref.read(
            projectInfoProvider(projectUuid).future,
          );
          projectName = project?.name ?? projectName;
        } catch (_) {
          // The selected files remain exportable if project metadata is stale.
        }
      }
      if (!mounted) return;
      setState(() {
        _batch = batch;
        _fileNameController.text = '${_safeStem(projectName)}-media';
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    final batch = _batch;
    if (batch == null || !_canExport) return;
    final service = MediaExportService(ref: ref);
    final reporter = ExportProgressReporter(
      steps: MediaExportService.batchExportPhases(batch),
    );
    final cancellation = ExportCancellation();
    final stopwatch = Stopwatch()..start();
    setState(() {
      _isSaving = true;
      _isCancelling = false;
      _outcome = null;
      _runError = null;
      _failedStepLabel = null;
      _failureWarnings = const [];
      _output = null;
      _result = null;
      _runDuration = null;
      _cancellation = cancellation;
      _jobProgress = ExportJobProgress.pending(reporter.steps);
    });
    _progressSubscription = reporter.stream.listen((progress) {
      if (mounted) setState(() => _jobProgress = progress);
    });
    try {
      final result = await service.exportBatch(
        batch: batch,
        options: MediaBatchExportOptions(
          archiveFormat: _archiveFormat,
          imageFormat: _imageFormat,
          maxLongSidePixels:
              _imageFormat != MediaExportFormat.original && _limitImageSize
              ? int.parse(_maxPixelsController.text)
              : null,
          jpegQuality: _jpegQuality,
        ),
        fileStem: _appendDate
            ? appendDateToFileStem(_fileNameController.text, DateTime.now())
            : _fileNameController.text,
        destinationDirectory: _directory,
        progress: reporter,
        cancel: cancellation,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _output = result.file;
        _outcome = ExportOutcome.succeeded;
        _runDuration = stopwatch.elapsed;
      });
    } on ExportCancelledException {
      if (!mounted) return;
      setState(() {
        _outcome = ExportOutcome.cancelled;
        _runDuration = stopwatch.elapsed;
      });
    } on MediaBatchExportAllFilesFailedException catch (error) {
      if (!mounted) return;
      setState(() {
        _outcome = ExportOutcome.failed;
        _runError = error.toString();
        _failedStepLabel = _jobProgress?.activeStep?.label;
        _failureWarnings = error.warnings;
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

  Future<void> _selectDirectory() async {
    final selected = await FilePickerServices().selectDir();
    if (selected == null || !mounted) return;
    setState(() {
      _directory = selected;
      _resetOutput();
    });
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
    if (output != null) await FilePickerServices().shareFile(context, output);
  }

  Future<void> _openFolder() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().openContainingDirectory(output);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open the folder: $error')),
      );
    }
  }

  void _clearDestination() {
    setState(() {
      _directory = null;
      _resetOutput();
    });
  }

  void _resetOutput() {
    _output = null;
    _result = null;
    _outcome = null;
    _runDuration = null;
    _failureWarnings = const [];
  }

  String _safeStem(String value) {
    final cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'nahpu' : cleaned;
  }
}

class _BatchMediaExportSettings extends StatelessWidget {
  const _BatchMediaExportSettings({
    required this.fileNameController,
    required this.maxPixelsController,
    required this.archiveFormat,
    required this.imageFormat,
    required this.hasImages,
    required this.appendDate,
    required this.limitImageSize,
    required this.jpegQuality,
    required this.enabled,
    required this.onArchiveFormatChanged,
    required this.onImageFormatChanged,
    required this.onAppendDateChanged,
    required this.onLimitImageSizeChanged,
    required this.onJpegQualityChanged,
    required this.onFileNameChanged,
    required this.onMaxPixelsChanged,
  });

  final TextEditingController fileNameController;
  final TextEditingController maxPixelsController;
  final MediaBatchArchiveFormat archiveFormat;
  final MediaExportFormat imageFormat;
  final bool hasImages;
  final bool appendDate;
  final bool limitImageSize;
  final int jpegQuality;
  final bool enabled;
  final ValueChanged<MediaBatchArchiveFormat> onArchiveFormatChanged;
  final ValueChanged<MediaExportFormat> onImageFormatChanged;
  final ValueChanged<bool> onAppendDateChanged;
  final ValueChanged<bool> onLimitImageSizeChanged;
  final ValueChanged<int> onJpegQualityChanged;
  final ValueChanged<String> onFileNameChanged;
  final ValueChanged<String> onMaxPixelsChanged;

  @override
  Widget build(BuildContext context) {
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Media archive', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: NahpuSpacing.xl),
          SegmentedButton<MediaBatchArchiveFormat>(
            segments: [
              for (final format in MediaBatchArchiveFormat.values)
                ButtonSegment(
                  value: format,
                  label: Text(format.label),
                  icon: const Icon(Icons.folder_zip_outlined),
                ),
            ],
            selected: {archiveFormat},
            onSelectionChanged: enabled
                ? (values) => onArchiveFormatChanged(values.single)
                : null,
          ),
          if (hasImages) ...[
            const SizedBox(height: NahpuSpacing.xl),
            DropdownButtonFormField<MediaExportFormat>(
              initialValue: imageFormat,
              decoration: const InputDecoration(labelText: 'Image format'),
              items: [
                for (final format in MediaExportFormat.values)
                  DropdownMenuItem(
                    value: format,
                    child: Text(format.label('')),
                  ),
              ],
              onChanged: enabled
                  ? (value) {
                      if (value != null) onImageFormatChanged(value);
                    }
                  : null,
            ),
            if (imageFormat != MediaExportFormat.original) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Limit image dimensions'),
                subtitle: const Text(
                  'Constrain the longer side without upscaling',
                ),
                value: limitImageSize,
                onChanged: enabled ? onLimitImageSizeChanged : null,
              ),
              if (limitImageSize)
                TextField(
                  controller: maxPixelsController,
                  enabled: enabled,
                  decoration: const InputDecoration(
                    labelText: 'Maximum width or height (px)',
                    helperText: 'Applies to whichever side is longer',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: onMaxPixelsChanged,
                ),
              if (imageFormat == MediaExportFormat.jpeg) ...[
                const SizedBox(height: NahpuSpacing.lg),
                Row(
                  children: [
                    const Text('JPEG quality'),
                    const Spacer(),
                    Text('$jpegQuality%'),
                  ],
                ),
                Slider(
                  value: jpegQuality.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: '$jpegQuality',
                  onChanged: enabled
                      ? (value) => onJpegQualityChanged(value.round())
                      : null,
                ),
              ],
            ],
          ],
          const SizedBox(height: NahpuSpacing.xl),
          FileNameField(
            controller: fileNameController,
            extension: archiveFormat.extension,
            appendDate: appendDate,
            enabled: enabled,
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

class _BatchMediaSummary extends StatelessWidget {
  const _BatchMediaSummary({
    required this.batch,
    required this.result,
    required this.imageFormat,
    required this.isLoading,
    required this.error,
    required this.failureWarnings,
  });

  final PreparedMediaBatch? batch;
  final MediaBatchExportResult? result;
  final MediaExportFormat imageFormat;
  final bool isLoading;
  final String? error;
  final List<MediaBatchWarning> failureWarnings;

  @override
  Widget build(BuildContext context) {
    final prepared = batch;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Archive contents',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: NahpuSpacing.lg),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(NahpuSpacing.xxl),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            ErrorText(error: error!)
          else if (prepared != null) ...[
            _SummaryRow(label: 'Selected', value: prepared.requestedCount),
            _SummaryRow(label: 'Available', value: prepared.items.length),
            _SummaryRow(
              label: 'Images',
              value: prepared.count(MediaKind.image),
            ),
            _SummaryRow(label: 'Audio', value: prepared.count(MediaKind.audio)),
            _SummaryRow(label: 'Video', value: prepared.count(MediaKind.video)),
            _SummaryRow(label: 'Other', value: prepared.count(MediaKind.other)),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.sd_storage_outlined),
              title: const Text('Source size'),
              trailing: Text(
                formatByteSize(prepared.sourceBytes),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (result != null) ...[
              const Divider(),
              _SummaryRow(label: 'Exported', value: result!.exportedCount),
              _SummaryRow(label: 'Skipped', value: result!.skippedCount),
            ],
            if (_warnings(prepared).isNotEmpty) ...[
              const Divider(),
              Text(
                '${_warnings(prepared).length} warning(s)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: NahpuSpacing.sm),
              for (final warning in _warnings(prepared))
                Padding(
                  padding: const EdgeInsets.only(bottom: NahpuSpacing.sm),
                  child: Text('• $warning'),
                ),
            ],
          ],
        ],
      ),
    );
  }

  List<MediaBatchWarning> _warnings(PreparedMediaBatch prepared) {
    final warnings = <MediaBatchWarning>[
      if (result != null) ...result!.warnings else ...prepared.warnings,
      ...failureWarnings,
      if (result == null &&
          imageFormat != MediaExportFormat.original &&
          failureWarnings.isEmpty)
        for (final item in prepared.items)
          if (item.kind == MediaKind.image && !item.canConvertImage)
            MediaBatchWarning(
              fileName: item.fileName,
              message:
                  '${item.originalExtension.toUpperCase()} cannot be '
                  'converted and will remain in its original format.',
            ),
    ];
    final unique = <String, MediaBatchWarning>{};
    for (final warning in warnings) {
      unique[warning.toString()] = warning;
    }
    return unique.values.toList(growable: false);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(Icons.check_circle_outline_rounded),
      title: Text(label),
      trailing: Text('$value', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
