import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/export/dwc_bundle.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/export/export_destination.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/service_labels.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as path;

/// Creates third-party specimen record packages.
class BundleRecordsForm extends ConsumerStatefulWidget {
  const BundleRecordsForm({super.key});

  @override
  ConsumerState<BundleRecordsForm> createState() => BundleRecordsFormState();
}

class BundleRecordsFormState extends ConsumerState<BundleRecordsForm>
    with SingleTickerProviderStateMixin {
  final FileOpCtrModel _fileController = FileOpCtrModel.empty();
  late final TabController _mobileTabs;
  final ExportDestinationService _destination = ExportDestinationService();
  Directory? _selectedDirectory;
  DwcBundleFormat _format = DwcBundleFormat.darwinCoreArchive;
  BundleArchiveFormat _archiveFormat = BundleArchiveFormat.zip;
  String _fileStem = 'darwin_core_specimens';
  Set<String> _availableTaxonGroups = <String>{};
  Set<String> _selectedTaxonGroups = <String>{};
  BundleTaxonSelectionMode _taxonSelectionMode = BundleTaxonSelectionMode.all;
  DwcBundleManifest? _manifest;
  String? _planningError;
  String? _outputPath;
  bool _isPlanning = false;
  bool _isWriting = false;
  bool _isLoadingTaxa = true;
  bool _appendDate = false;
  int _planGeneration = 0;
  bool _isCancelling = false;
  ExportCancellation? _cancellation;
  StreamSubscription<ExportJobProgress>? _progressSubscription;
  ExportJobProgress? _jobProgress;
  ExportOutcome? _outcome;
  String? _runError;
  ExportStepLabel? _failedStepLabel;
  int? _outputBytes;
  Duration? _runDuration;

  @override
  void initState() {
    super.initState();
    _mobileTabs = TabController(length: 2, vsync: this);
    _fileController.fileNameCtr.text = _fileStem;
    _loadTaxonGroups();
  }

  @override
  void dispose() {
    _fileController.dispose();
    _mobileTabs.dispose();
    unawaited(_progressSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ScrollableConstrainedLayout(
      child: _BundleSettingsPane(
        fileController: _fileController,
        format: _format,
        archiveFormat: _archiveFormat,
        availableTaxonGroups: _availableTaxonGroups,
        selectedTaxonGroups: _selectedTaxonGroups,
        taxonSelectionMode: _taxonSelectionMode,
        isLoadingTaxa: _isLoadingTaxa,
        onFormatChanged: _changeFormat,
        onArchiveFormatChanged: _changeArchiveFormat,
        onTaxonGroupsChanged: _changeTaxonGroups,
        onTaxonSelectionModeChanged: _changeTaxonSelectionMode,
        onFileNameChanged: _changeFileName,
        appendDate: _appendDate,
        onAppendDateChanged: (value) {
          setState(() {
            _appendDate = value;
            _outputPath = null;
          });
        },
        locationCard: ExportLocationCard(
          selectedDir: _selectedDirectory,
          output: _outputPath == null ? null : File(_outputPath!),
          outputBytes: _outputBytes,
          duration: _runDuration,
          enabled: !_isWriting,
          onSelectDir: _selectDirectory,
          onClearDir: _clearDestination,
          onShare: _shareBundle,
          onOpenFolder: _openFolder,
          onSaveCopy: _saveCopy,
          onDismiss: _clearDestination,
        ),
      ),
    );
    final jobProgress = _jobProgress;
    final leftPane = _isWriting && jobProgress != null
        ? ScrollableConstrainedLayout(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ExportProgressPanel(
                title: context.l10n.exportBundling,
                progress: jobProgress,
                hint: context.l10n.exportBundlingHint,
                isCancelling: _isCancelling,
                onCancel: _requestCancel,
              ),
            ),
          )
        : settings;
    final contents = Padding(
      padding: const EdgeInsets.all(16),
      // A finished bundle keeps its contents on screen: the location card
      // already reports the file.
      child:
          _outcome != null && _outcome != ExportOutcome.succeeded && !_isWriting
          ? ExportFailurePanel(
              outcome: _outcome!,
              errorMessage: _runError,
              failedStepLabel: _failedStepLabel?.text(context.l10n),
              onRetry: _writeBundle,
            )
          : BundleContentsPane(
              manifest: _manifest,
              isLoading: _isPlanning,
              error: _planningError,
            ),
    );
    final isLargeScreen =
        MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;

    return PopScope(
      // Leaving mid-bundle would leave a partly written package behind, so the
      // user has to cancel deliberately.
      canPop: !_isWriting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: _buildScaffold(leftPane, contents, isLargeScreen),
    );
  }

  Widget _buildScaffold(Widget settings, Widget contents, bool isLargeScreen) {
    final body = isLargeScreen
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: settings),
              Expanded(child: contents),
            ],
          )
        : Column(
            children: [
              TabBar(
                controller: _mobileTabs,
                tabs: [
                  Tab(
                    icon: Icon(Icons.settings_outlined),
                    text: context.l10n.drawerSettings,
                  ),
                  Tab(
                    icon: Icon(Icons.inventory_2_outlined),
                    text: context.l10n.docsContents,
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _mobileTabs,
                  children: [settings, contents],
                ),
              ),
            ],
          );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.labelProjectToolBundleRecords)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            ExportActionBar(
              label: context.l10n.exportCreateBundle,
              repeatLabel: context.l10n.exportBundleAnother,
              icon: Icons.inventory_2_outlined,
              canExport:
                  _fileController.isValid &&
                  (!_format.usesTaxonSelection ||
                      _selectedTaxonGroups.isNotEmpty) &&
                  !_isPlanning,
              isRunning: _isWriting,
              hasOutput: _outputPath != null,
              onExport: _writeBundle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTaxonGroups() async {
    try {
      final groups = await DwcBundleWriter(ref: ref).getRecordedTaxonGroups();
      if (!mounted) return;
      setState(() {
        _availableTaxonGroups = groups.toSet();
        _selectedTaxonGroups = groups.toSet();
        _isLoadingTaxa = false;
      });
      await _planBundle();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingTaxa = false;
        _planningError = error.toString();
      });
    }
  }

  void _changeFormat(DwcBundleFormat format) {
    final fileStem = format == DwcBundleFormat.nahpuDataPackage
        ? 'nahpu_data'
        : 'darwin_core_specimens';
    setState(() {
      _format = format;
      _archiveFormat = format.defaultArchive;
      _fileStem = fileStem;
      _fileController.fileNameCtr.text = fileStem;
      _outputPath = null;
    });
    _planBundle();
  }

  void _changeArchiveFormat(BundleArchiveFormat archiveFormat) {
    setState(() {
      _archiveFormat = archiveFormat;
      _outputPath = null;
    });
    _planBundle();
  }

  void _changeTaxonGroups(Set<String> groups) {
    setState(() {
      _selectedTaxonGroups = groups;
      _outputPath = null;
    });
    _planBundle();
  }

  void _changeTaxonSelectionMode(BundleTaxonSelectionMode mode) {
    setState(() {
      _taxonSelectionMode = mode;
      if (mode == BundleTaxonSelectionMode.all) {
        _selectedTaxonGroups = _availableTaxonGroups.toSet();
      }
      _outputPath = null;
    });
    _planBundle();
  }

  void _changeFileName(String? value) {
    if (value == null) return;
    setState(() {
      _fileStem = value;
      _outputPath = null;
    });
  }

  Future<void> _selectDirectory() async {
    if (!_destination.canChooseDirectory) return;
    final directory = await FilePickerServices().selectDir();
    if (directory == null || !mounted) return;
    setState(() {
      _selectedDirectory = directory;
      _outputPath = null;
    });
  }

  Future<void> _planBundle() async {
    final generation = ++_planGeneration;
    if (_format.usesTaxonSelection && _selectedTaxonGroups.isEmpty) {
      setState(() {
        _manifest = null;
        _planningError = null;
        _isPlanning = false;
      });
      return;
    }
    setState(() {
      _isPlanning = true;
      _planningError = null;
    });
    try {
      final manifest = await DwcBundleWriter(ref: ref).plan(
        format: _format,
        archiveFormat: _archiveFormat,
        selectedTaxonGroups: _selectedTaxonGroups,
      );
      if (mounted && generation == _planGeneration) {
        setState(() => _manifest = manifest);
      }
    } catch (error) {
      if (mounted && generation == _planGeneration) {
        setState(() => _planningError = error.toString());
      }
    } finally {
      if (mounted && generation == _planGeneration) {
        setState(() => _isPlanning = false);
      }
    }
  }

  Future<void> _writeBundle() async {
    final reporter = ExportProgressReporter(
      steps: DwcBundleWriter.bundlePhases,
    );
    final cancellation = ExportCancellation();
    final stopwatch = Stopwatch()..start();
    setState(() {
      _isWriting = true;
      _isCancelling = false;
      _outcome = null;
      _runError = null;
      _failedStepLabel = null;
      _outputBytes = null;
      _runDuration = null;
      _cancellation = cancellation;
      _jobProgress = ExportJobProgress.pending(reporter.steps);
    });
    // On a phone the panel lives in the settings tab, so show it.
    if (_mobileTabs.index != 0) _mobileTabs.animateTo(0);
    _progressSubscription = reporter.stream.listen((progress) {
      if (mounted) setState(() => _jobProgress = progress);
    });
    try {
      final output = await _getOutputPath();
      final manifest = await DwcBundleWriter(ref: ref).write(
        format: _format,
        archiveFormat: _archiveFormat,
        selectedTaxonGroups: _selectedTaxonGroups,
        outputPath: output.path,
        progress: reporter,
        cancel: cancellation,
        expectedFileCount: _manifest?.files.length ?? 0,
      );
      final bytes = await _outputSize(output);
      if (!mounted) return;
      setState(() {
        _outputPath = output.path;
        _manifest = manifest;
        _outcome = ExportOutcome.succeeded;
        _outputBytes = bytes;
        _runDuration = stopwatch.elapsed;
      });
      _showCompleted(output.path);
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
          _isWriting = false;
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
        title: Text(context.l10n.exportCancelBundleTitle),
        content: Text(context.l10n.exportCancelBundleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.exportKeepBundling),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.exportCancelBundle),
          ),
        ],
      ),
    );
    if (leave == true && mounted) _requestCancel();
  }

  /// Reads the size of a finished bundle, which some formats write as a folder.
  Future<int?> _outputSize(File output) async {
    try {
      return await output.length();
    } on FileSystemException {
      return null;
    }
  }

  Future<File> _getOutputPath() async {
    final output = await AppIOServices(
      dir: await _destination.resolve(_selectedDirectory),
      fileStem: _appendDate
          ? appendDateToFileStem(_fileStem, DateTime.now())
          : _fileStem.trim(),
      ext: _format.outputExtension(_archiveFormat),
    ).getSavePath();
    return output;
  }

  Future<void> _shareBundle() async {
    final outputPath = _outputPath;
    if (outputPath == null) return;
    try {
      await FilePickerServices().shareFile(context, File(outputPath));
    } catch (error) {
      if (mounted) _showError(error.toString());
    }
  }

  Future<void> _openFolder() async {
    final outputPath = _outputPath;
    if (outputPath == null) return;
    try {
      await FilePickerServices().openContainingDirectory(File(outputPath));
    } catch (error) {
      if (mounted) _showError(context.l10n.projectOpenFolderFailed('$error'));
    }
  }

  /// Hands the finished file to the system "Save to..." dialog.
  ///
  /// How Android reaches the Files app: its share sheet only lists
  /// apps that accept a file, never a folder to drop one into.
  Future<void> _saveCopy() async {
    final outputPath = _outputPath;
    if (outputPath == null) return;
    try {
      await FilePickerServices().saveCopyToDevice(File(outputPath));
    } catch (error) {
      if (mounted) _showError(context.l10n.projectSaveCopyFailed('$error'));
    }
  }

  /// Closing the result puts the screen back where it was before the bundle,
  /// directory included, so one tap lands on the directory input rather than
  /// on a filled-in path that needs clearing too.
  void _clearDestination() {
    setState(() {
      _selectedDirectory = null;
      _outputPath = null;
      _outcome = null;
      _outputBytes = null;
      _runDuration = null;
    });
  }

  void _showCompleted(String outputPath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          systemPlatform == PlatformType.desktop
              ? context.l10n.exportCreatedFile(path.basename(outputPath))
              : context.l10n.exportBundleComplete,
        ),
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

class _BundleSettingsPane extends StatelessWidget {
  const _BundleSettingsPane({
    required this.fileController,
    required this.format,
    required this.archiveFormat,
    required this.availableTaxonGroups,
    required this.selectedTaxonGroups,
    required this.taxonSelectionMode,
    required this.isLoadingTaxa,
    required this.onFormatChanged,
    required this.onArchiveFormatChanged,
    required this.onTaxonGroupsChanged,
    required this.onTaxonSelectionModeChanged,
    required this.onFileNameChanged,
    required this.appendDate,
    required this.onAppendDateChanged,
    required this.locationCard,
  });

  final FileOpCtrModel fileController;
  final DwcBundleFormat format;
  final BundleArchiveFormat archiveFormat;
  final Set<String> availableTaxonGroups;
  final Set<String> selectedTaxonGroups;
  final BundleTaxonSelectionMode taxonSelectionMode;
  final bool isLoadingTaxa;
  final ValueChanged<DwcBundleFormat> onFormatChanged;
  final ValueChanged<BundleArchiveFormat> onArchiveFormatChanged;
  final ValueChanged<Set<String>> onTaxonGroupsChanged;
  final ValueChanged<BundleTaxonSelectionMode> onTaxonSelectionModeChanged;
  final ValueChanged<String?> onFileNameChanged;
  final bool appendDate;
  final ValueChanged<bool> onAppendDateChanged;

  /// The destination, shown directly under the file settings it belongs to.
  final Widget locationCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FileFormatIcon(
          path: format == DwcBundleFormat.darwinCoreArchive
              ? 'assets/icons/zip.svg'
              : 'assets/icons/json.svg',
        ),
        const SizedBox(height: 8),
        if (format.usesTaxonSelection)
          BundleTaxonSelectionCard(
            availableTaxonGroups: availableTaxonGroups,
            selectedTaxonGroups: selectedTaxonGroups,
            selectionMode: taxonSelectionMode,
            isLoading: isLoadingTaxa,
            onChanged: onTaxonGroupsChanged,
            onModeChanged: onTaxonSelectionModeChanged,
          )
        else
          const _NahpuPackageScopeCard(),
        const SizedBox(height: 8),
        BundleFileSettingsCard(
          exportCtr: fileController,
          format: format,
          archiveFormat: archiveFormat,
          onFormatChanged: onFormatChanged,
          onArchiveFormatChanged: onArchiveFormatChanged,
          onFileNameChanged: onFileNameChanged,
          appendDate: appendDate,
          onAppendDateChanged: onAppendDateChanged,
        ),
        const SizedBox(height: 8),
        locationCard,
      ],
    );
  }
}

enum BundleTaxonSelectionMode { all, selected }

class _NahpuPackageScopeCard extends StatelessWidget {
  const _NahpuPackageScopeCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: NahpuPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.exportCompleteData),
            SizedBox(height: 8),
            Text(context.l10n.exportCompleteDataBody),
            SizedBox(height: 8),
            Text(context.l10n.exportFrictionless),
          ],
        ),
      ),
    );
  }
}

class BundleTaxonSelectionCard extends StatelessWidget {
  const BundleTaxonSelectionCard({
    super.key,
    required this.availableTaxonGroups,
    required this.selectedTaxonGroups,
    required this.selectionMode,
    required this.isLoading,
    required this.onChanged,
    required this.onModeChanged,
  });

  final Set<String> availableTaxonGroups;
  final Set<String> selectedTaxonGroups;
  final BundleTaxonSelectionMode selectionMode;
  final bool isLoading;
  final ValueChanged<Set<String>> onChanged;
  final ValueChanged<BundleTaxonSelectionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: NahpuPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.exportRecordedTaxa,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: SegmentedButton<BundleTaxonSelectionMode>(
                segments: [
                  ButtonSegment(
                    value: BundleTaxonSelectionMode.all,
                    label: Text(context.l10n.labelSpecimenRecordTypeAllTaxa),
                    icon: Icon(Icons.select_all_outlined),
                  ),
                  ButtonSegment(
                    value: BundleTaxonSelectionMode.selected,
                    label: Text(context.l10n.exportSelectedTaxa),
                    icon: Icon(Icons.filter_alt_outlined),
                  ),
                ],
                selected: {selectionMode},
                onSelectionChanged: (selection) =>
                    onModeChanged(selection.single),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (availableTaxonGroups.isEmpty)
              Text(context.l10n.exportNoTaxaRecorded)
            else if (selectionMode == BundleTaxonSelectionMode.all)
              Text(
                context.l10n.exportTaxonGroupsIncluded(
                  availableTaxonGroups.length,
                ),
              )
            else
              ...availableTaxonGroups.map((group) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selectedTaxonGroups.contains(group),
                  title: Text(group),
                  onChanged: (selected) {
                    final next = selectedTaxonGroups.toSet();
                    if (selected == true) {
                      next.add(group);
                    } else {
                      next.remove(group);
                    }
                    onChanged(next);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class BundleContentsPane extends StatelessWidget {
  const BundleContentsPane({
    super.key,
    required this.manifest,
    required this.isLoading,
    required this.error,
  });

  final DwcBundleManifest? manifest;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return FormCard(
        title: context.l10n.exportPackageContents,
        isExpanded: true,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return FormCard(
        title: context.l10n.exportPackageContents,
        isExpanded: true,
        child: Center(child: Text(error!, textAlign: TextAlign.center)),
      );
    }
    if (manifest == null) {
      return FormCard(
        title: context.l10n.exportPackageContents,
        isExpanded: true,
        child: Center(child: Text(context.l10n.exportSelectTaxonPrompt)),
      );
    }
    return FormCard(
      title: context.l10n.exportPackageContents,
      isExpanded: true,
      child: ListView(
        children: [
          Text(context.l10n.exportPackageContentsBody),
          const SizedBox(height: 12),
          ...manifest!.files.map((file) => _BundleFileTile(file: file)),
          if (manifest!.warnings.isNotEmpty) ...[
            const Divider(),
            Text(
              context.l10n.projectTransferWarnings,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...manifest!.warnings.map(
              (warning) => ListTile(
                leading: const Icon(Icons.warning_amber_outlined),
                title: Text(warning),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BundleFileTile extends StatelessWidget {
  const _BundleFileTile({required this.file});

  final DwcBundleFile file;

  @override
  Widget build(BuildContext context) {
    final detail = file.records == 0
        ? file.mediaType
        : context.l10n.exportRecordsAndFields(
            file.records,
            file.columns.length,
          );
    final leading = Icon(_bundleFileIcon(file.path));
    if (file.columns.isEmpty) {
      return Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: leading,
          title: Text(file.path),
          subtitle: Text(detail),
        ),
      );
    }
    return Material(
      type: MaterialType.transparency,
      child: ExpansionTile(
        leading: leading,
        title: Text(file.path),
        subtitle: Text(detail),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: file.columns
                  .map((column) => Chip(label: Text(column)))
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _bundleFileIcon(String filePath) {
  final normalized = filePath.toLowerCase();
  if (normalized.endsWith('.csv')) return Icons.table_chart_outlined;
  if (normalized.endsWith('.json')) return Icons.data_object_outlined;
  if (normalized.endsWith('.toml')) return Icons.settings_outlined;
  if (normalized.endsWith('.sqlite3')) return Icons.storage_outlined;
  if (normalized.endsWith('.xml')) return Icons.code_outlined;
  if (normalized.endsWith('.zip') || normalized.endsWith('.tar.gz')) {
    return Icons.folder_zip_outlined;
  }
  if (normalized.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;

  return switch (matchMediaKindFromPath(filePath)) {
    MediaKind.image => Icons.image_outlined,
    MediaKind.audio => Icons.audio_file_outlined,
    MediaKind.video => Icons.video_file_outlined,
    MediaKind.other => Icons.insert_drive_file_outlined,
  };
}
