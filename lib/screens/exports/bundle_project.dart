import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/export/dwc_bundle.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:path/path.dart' as path;

/// Creates a specimen-only Darwin Core Archive or Darwin Core Data Package.
class BundleProjectForm extends ConsumerStatefulWidget {
  const BundleProjectForm({super.key});

  @override
  ConsumerState<BundleProjectForm> createState() => BundleProjectFormState();
}

class BundleProjectFormState extends ConsumerState<BundleProjectForm>
    with SingleTickerProviderStateMixin {
  final FileOpCtrModel _fileController = FileOpCtrModel.empty();
  late final TabController _mobileTabs;
  Directory? _selectedDirectory;
  DwcBundleFormat _format = DwcBundleFormat.darwinCoreArchive;
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
  int _planGeneration = 0;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ScrollableConstrainedLayout(
      child: _BundleSettingsPane(
        fileController: _fileController,
        selectedDirectory: _selectedDirectory,
        format: _format,
        availableTaxonGroups: _availableTaxonGroups,
        selectedTaxonGroups: _selectedTaxonGroups,
        taxonSelectionMode: _taxonSelectionMode,
        isLoadingTaxa: _isLoadingTaxa,
        isWriting: _isWriting,
        canWrite: _fileController.isValid &&
            _selectedTaxonGroups.isNotEmpty &&
            !_isPlanning,
        onFormatChanged: _changeFormat,
        onTaxonGroupsChanged: _changeTaxonGroups,
        onTaxonSelectionModeChanged: _changeTaxonSelectionMode,
        onFileNameChanged: _changeFileName,
        onSelectDirectory: _selectDirectory,
        onClearDirectory: _clearDirectory,
        onBundle: _writeBundle,
        onShare:
            _format == DwcBundleFormat.darwinCoreArchive && _outputPath != null
                ? _shareBundle
                : null,
      ),
    );
    final contents = Padding(
      padding: const EdgeInsets.all(16),
      child: BundleContentsPane(
        manifest: _manifest,
        isLoading: _isPlanning,
        error: _planningError,
      ),
    );
    final isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Bundle project')),
      body: isLargeScreen
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [Expanded(child: settings), Expanded(child: contents)],
            )
          : Column(
              children: [
                TabBar(
                  controller: _mobileTabs,
                  tabs: const [
                    Tab(icon: Icon(Icons.settings_outlined), text: 'Settings'),
                    Tab(
                        icon: Icon(Icons.inventory_2_outlined),
                        text: 'Contents'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _mobileTabs,
                    children: [settings, contents],
                  ),
                ),
              ],
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
    setState(() {
      _format = format;
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
    final directory = await FilePickerServices().selectDir();
    if (directory == null || !mounted) return;
    setState(() {
      _selectedDirectory = directory;
      _outputPath = null;
    });
  }

  void _clearDirectory() {
    setState(() {
      _selectedDirectory = null;
      _outputPath = null;
    });
  }

  Future<void> _planBundle() async {
    final generation = ++_planGeneration;
    if (_selectedTaxonGroups.isEmpty) {
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
    setState(() => _isWriting = true);
    try {
      final output = await _getOutputPath();
      final manifest = await DwcBundleWriter(ref: ref).write(
        format: _format,
        selectedTaxonGroups: _selectedTaxonGroups,
        outputPath: output.path,
      );
      if (!mounted) return;
      setState(() {
        _outputPath = output.path;
        _manifest = manifest;
      });
      _showCompleted(output.path);
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isWriting = false);
    }
  }

  Future<File> _getOutputPath() async {
    final output = await AppIOServices(
      dir: _selectedDirectory,
      fileStem: _fileStem,
      ext: _format.outputExtension,
    ).getSavePath();
    if (_format != DwcBundleFormat.darwinCoreDataPackage) return output;

    var candidate = output;
    var suffix = 1;
    while (Directory(candidate.path).existsSync()) {
      candidate = File(path.join(
        path.dirname(output.path),
        '$_fileStem($suffix).${_format.outputExtension}',
      ));
      suffix++;
    }
    return candidate;
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

  void _showCompleted(String outputPath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(systemPlatform == PlatformType.desktop
            ? 'Created ${path.basename(outputPath)}'
            : 'Bundle complete!'),
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
    required this.selectedDirectory,
    required this.format,
    required this.availableTaxonGroups,
    required this.selectedTaxonGroups,
    required this.taxonSelectionMode,
    required this.isLoadingTaxa,
    required this.isWriting,
    required this.canWrite,
    required this.onFormatChanged,
    required this.onTaxonGroupsChanged,
    required this.onTaxonSelectionModeChanged,
    required this.onFileNameChanged,
    required this.onSelectDirectory,
    required this.onClearDirectory,
    required this.onBundle,
    required this.onShare,
  });

  final FileOpCtrModel fileController;
  final Directory? selectedDirectory;
  final DwcBundleFormat format;
  final Set<String> availableTaxonGroups;
  final Set<String> selectedTaxonGroups;
  final BundleTaxonSelectionMode taxonSelectionMode;
  final bool isLoadingTaxa;
  final bool isWriting;
  final bool canWrite;
  final ValueChanged<DwcBundleFormat> onFormatChanged;
  final ValueChanged<Set<String>> onTaxonGroupsChanged;
  final ValueChanged<BundleTaxonSelectionMode> onTaxonSelectionModeChanged;
  final ValueChanged<String?> onFileNameChanged;
  final Future<void> Function() onSelectDirectory;
  final VoidCallback onClearDirectory;
  final Future<void> Function() onBundle;
  final Future<void> Function()? onShare;

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
        BundleTaxonSelectionCard(
          availableTaxonGroups: availableTaxonGroups,
          selectedTaxonGroups: selectedTaxonGroups,
          selectionMode: taxonSelectionMode,
          isLoading: isLoadingTaxa,
          onChanged: onTaxonGroupsChanged,
          onModeChanged: onTaxonSelectionModeChanged,
        ),
        const SizedBox(height: 8),
        BundleFileSettingsCard(
          exportCtr: fileController,
          selectedDir: selectedDirectory,
          format: format,
          onFormatChanged: onFormatChanged,
          onFileNameChanged: onFileNameChanged,
          onSelectDir: onSelectDirectory,
          onClearDir: onClearDirectory,
        ),
        const SizedBox(height: 24),
        ExportShareButton(
          hasExported: onShare != null,
          isRunning: isWriting,
          onExport: canWrite ? onBundle : null,
          onShare: () => onShare?.call(),
        ),
      ],
    );
  }
}

enum BundleTaxonSelectionMode { all, selected }

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
      child: Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recorded Taxa',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Center(
                child: SegmentedButton<BundleTaxonSelectionMode>(
                  segments: const [
                    ButtonSegment(
                      value: BundleTaxonSelectionMode.all,
                      label: Text('All taxa'),
                      icon: Icon(Icons.select_all_outlined),
                    ),
                    ButtonSegment(
                      value: BundleTaxonSelectionMode.selected,
                      label: Text('Selected taxa'),
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
                const Text('No specimen taxa have been recorded yet.')
              else if (selectionMode == BundleTaxonSelectionMode.all)
                Text(
                  '${availableTaxonGroups.length} recorded taxon groups will be included.',
                )
              else
                ...availableTaxonGroups.map((group) {
                  final isRequiredBat = group == 'Bats' &&
                      selectedTaxonGroups.contains('Mammals');
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isRequiredBat || selectedTaxonGroups.contains(group),
                    title: Text(
                      group == 'Mammals' ? 'Mammals (includes bats)' : group,
                    ),
                    subtitle: group == 'Mammals'
                        ? const Text('Bats are always included with mammals.')
                        : isRequiredBat
                            ? const Text('Included with Mammals')
                            : null,
                    onChanged: isRequiredBat
                        ? null
                        : (selected) {
                            final next = selectedTaxonGroups.toSet();
                            if (selected == true) {
                              next.add(group);
                            } else {
                              next.remove(group);
                            }
                            if (group == 'Mammals' && selected == true) {
                              next.add('Bats');
                            }
                            onChanged(next);
                          },
                  );
                }),
            ],
          ),
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
      return const FormCard(
        title: 'Package contents',
        isExpanded: true,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return FormCard(
        title: 'Package contents',
        isExpanded: true,
        child: Center(child: Text(error!, textAlign: TextAlign.center)),
      );
    }
    if (manifest == null) {
      return const FormCard(
        title: 'Package contents',
        isExpanded: true,
        child: Center(
          child: Text(
              'Select at least one recorded taxon to list the package contents.'),
        ),
      );
    }
    return FormCard(
      title: 'Package contents',
      isExpanded: true,
      child: ListView(
        children: [
          const Text(
            'The list reflects exactly what will be bundled. Empty optional fields and tables are omitted.',
          ),
          const SizedBox(height: 12),
          ...manifest!.files.map((file) => _BundleFileTile(file: file)),
          if (manifest!.warnings.isNotEmpty) ...[
            const Divider(),
            Text('Warnings', style: Theme.of(context).textTheme.titleSmall),
            ...manifest!.warnings.map((warning) => ListTile(
                  leading: const Icon(Icons.warning_amber_outlined),
                  title: Text(warning),
                )),
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
        : '${file.records} records · ${file.columns.length} fields';
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
  if (normalized.endsWith('.xml')) return Icons.code_outlined;
  if (normalized.endsWith('.zip')) return Icons.folder_zip_outlined;
  if (normalized.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;

  return switch (matchMediaKindFromPath(filePath)) {
    MediaKind.image => Icons.image_outlined,
    MediaKind.audio => Icons.audio_file_outlined,
    MediaKind.video => Icons.video_file_outlined,
    MediaKind.other => Icons.insert_drive_file_outlined,
  };
}
