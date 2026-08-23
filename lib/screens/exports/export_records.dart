import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/settings/export_presets.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Runs record exports from a saved preset. Record shape is intentionally not
/// editable here: the preset is the reproducible definition of an export.
class ExportForm extends ConsumerStatefulWidget {
  const ExportForm({super.key});

  @override
  ConsumerState<ExportForm> createState() => ExportFormState();
}

class ExportFormState extends ConsumerState<ExportForm>
    with SingleTickerProviderStateMixin {
  final FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  String _fileStem = 'export';
  Directory? _selectedDir;
  String? _selectedPresetName;
  ExportPresetModel? _selectedPreset;
  bool _isRunning = false;
  bool _appendDate = false;
  File? _savePath;
  late TabController _mobileTabController;

  @override
  void initState() {
    super.initState();
    _mobileTabController = TabController(length: 2, vsync: this);
    _initPresets();
  }

  Future<void> _initPresets() async {
    final presets = await ref.read(exportPresetNotifierProvider.future);
    if (presets.isNotEmpty && mounted) {
      setState(() {
        _selectedPresetName = presets.keys.first;
        _selectedPreset = presets.values.first;
      });
    }
  }

  @override
  void dispose() {
    exportCtr.dispose();
    _mobileTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(exportPresetNotifierProvider);
    final isLargeScreen =
        MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;

    return Scaffold(
      appBar: AppBar(title: const Text('Export records')),
      body: presetsAsync.when(
        data: (presets) {
          // Synchronize selection with updated map of presets
          if (_selectedPresetName != null &&
              !presets.containsKey(_selectedPresetName)) {
            _selectedPresetName = null;
            _selectedPreset = null;
          } else if (_selectedPresetName != null) {
            _selectedPreset = presets[_selectedPresetName];
          }

          final settingsPane = ScrollableConstrainedLayout(
            child: Column(
              children: [
                FileFormatIcon(path: _matchFileIconPath()),
                const SizedBox(height: 8),
                _PresetPicker(
                  presets: presets,
                  selectedPresetName: _selectedPresetName,
                  onPresetChanged: (name) {
                    setState(() {
                      _selectedPresetName = name;
                      _selectedPreset = name == null ? null : presets[name];
                      _savePath = null;
                    });
                  },
                  onManagePresets: _managePresets,
                ),
                const SizedBox(height: 8),
                FileSettingsCard(
                  exportCtr: exportCtr,
                  onExportFmtChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      exportCtr.exportFmtCtr = value;
                      _savePath = null;
                    });
                  },
                  onFileNameChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _fileStem = value;
                      _savePath = null;
                    });
                  },
                  appendDate: _appendDate,
                  onAppendDateChanged: (value) {
                    setState(() {
                      _appendDate = value;
                      _savePath = null;
                    });
                  },
                ),
                const SizedBox(height: 8),
                ExportLocationCard(
                  selectedDir: _selectedDir,
                  output: _savePath,
                  enabled: !_isRunning,
                  onSelectDir: _selectDirectory,
                  onClearDir: _clearDestination,
                  onShare: () => _shareFile(context),
                  onOpenFolder: _openFolder,
                  onDismiss: _clearDestination,
                ),
              ],
            ),
          );

          final previewPane = Padding(
            padding: const EdgeInsets.all(16.0),
            child: PresetPreviewPane(
              selectedPresetName: _selectedPresetName,
              selectedPreset: _selectedPreset,
              onSeeTable: () {
                if (_selectedPreset != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExportPresetTablePreviewScreen(
                        preset: _selectedPreset!,
                      ),
                    ),
                  );
                }
              },
            ),
          );

          final body = isLargeScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: settingsPane),
                    Expanded(child: previewPane),
                  ],
                )
              : Column(
                  children: [
                    TabBar(
                      controller: _mobileTabController,
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.settings_outlined),
                          text: 'Settings',
                        ),
                        Tab(
                          icon: Icon(Icons.preview_outlined),
                          text: 'Preview',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _mobileTabController,
                        children: [settingsPane, previewPane],
                      ),
                    ),
                  ],
                );
          return SafeArea(
            child: Column(
              children: [
                Expanded(child: body),
                ExportActionBar(
                  label: 'Export records',
                  repeatLabel: 'Export another',
                  icon: Icons.file_upload_outlined,
                  canExport: _isValid(),
                  isRunning: _isRunning,
                  hasOutput: _savePath != null,
                  onExport: _exportFile,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load export presets: $error')),
      ),
    );
  }

  bool _isValid() =>
      exportCtr.isValid &&
      _selectedPreset != null &&
      !(_selectedPreset!.headerFormat == ExportHeaderFormat.darwinCore &&
          exportCtr.exportFmtCtr == ExportFmt.json);

  String _matchFileIconPath() => switch (exportCtr.exportFmtCtr) {
    ExportFmt.csv => 'assets/icons/csv.svg',
    ExportFmt.tsv => 'assets/icons/tsv.svg',
    ExportFmt.excel => 'assets/icons/xlsx.svg',
    ExportFmt.json => 'assets/icons/json.svg',
  };

  Future<void> _exportFile() async {
    setState(() => _isRunning = true);
    try {
      final format = exportCtr.exportFmtCtr;
      final ext = switch (format) {
        ExportFmt.excel => 'xlsx',
        ExportFmt.json => 'json',
        _ => format.name,
      };
      final savePath = await AppIOServices(
        dir: _selectedDir,
        fileStem: _appendDate
            ? appendDateToFileStem(_fileStem, DateTime.now())
            : _fileStem.trim(),
        ext: ext,
      ).getSavePath();
      await PresetRecordExporter(
        ref: ref,
        preset: _selectedPreset!,
      ).write(savePath, format);
      if (mounted) setState(() => _savePath = savePath);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  /// Closing the result also drops the directory, so one tap lands back on the
  /// directory input rather than on a filled-in path that needs clearing too.
  void _clearDestination() {
    setState(() {
      _selectedDir = null;
      _savePath = null;
    });
  }

  Future<void> _selectDirectory() async {
    final path = await FilePickerServices().selectDir();
    if (path == null || !mounted) return;
    setState(() {
      _selectedDir = path;
      _savePath = null;
    });
  }

  Future<void> _openFolder() async {
    final savePath = _savePath;
    if (savePath == null) return;
    try {
      await FilePickerServices().openContainingDirectory(savePath);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open the folder: $error')),
        );
      }
    }
  }

  Future<void> _shareFile(BuildContext context) async {
    final savePath = _savePath;
    if (savePath == null) return;
    try {
      await FilePickerServices().shareFile(context, savePath);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  void _managePresets() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExportPresetsScreen()),
    );
    setState(() {});
  }
}

class _PresetPicker extends StatelessWidget {
  const _PresetPicker({
    required this.presets,
    required this.selectedPresetName,
    required this.onPresetChanged,
    required this.onManagePresets,
  });

  final Map<String, ExportPresetModel> presets;
  final String? selectedPresetName;
  final ValueChanged<String?> onPresetChanged;
  final VoidCallback onManagePresets;

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) {
      return FormCard(
        title: 'Export preset',
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48),
              const SizedBox(height: 12),
              const Text(
                'No export presets found. Manage presets in settings to create one.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Manage Presets',
                icon: Icons.settings_outlined,
                onPressed: onManagePresets,
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedPresetName,
              decoration: const InputDecoration(
                labelText: 'Export preset',
                helperText:
                    'Record type, headers, and field mappings are set by the preset.',
              ),
              items: presets.keys
                  .map(
                    (name) => DropdownMenuItem(value: name, child: Text(name)),
                  )
                  .toList(growable: false),
              onChanged: onPresetChanged,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onManagePresets,
                icon: const Icon(Icons.settings_outlined, size: 16),
                label: const Text('Manage presets'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PresetPreviewPane extends StatelessWidget {
  const PresetPreviewPane({
    super.key,
    required this.selectedPresetName,
    required this.selectedPreset,
    required this.onSeeTable,
  });

  final String? selectedPresetName;
  final ExportPresetModel? selectedPreset;
  final VoidCallback onSeeTable;

  @override
  Widget build(BuildContext context) {
    if (selectedPresetName == null || selectedPreset == null) {
      return const FormCard(
        title: 'Preset details',
        isExpanded: true,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select an export preset to see details and preview.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final preset = selectedPreset!;
    final isValid = preset.mappings.isNotEmpty;

    return FormCard(
      title: 'Preset: $selectedPresetName',
      isExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Record: ${recordTypeToString(preset.recordType)}',
                        ),
                        avatar: const Icon(
                          Icons.description_outlined,
                          size: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      if (preset.recordType == RecordType.specimenRecord)
                        Chip(
                          label: Text(
                            'Taxon: ${preset.specimenRecordType.name}',
                          ),
                          avatar: const Icon(Icons.pets_outlined, size: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      Chip(
                        label: Text('Header: ${preset.headerFormat.name}'),
                        avatar: const Icon(Icons.title_outlined, size: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selected Columns (${preset.mappings.length}):',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  PresetColumnChips(preset: preset),
                  if (isValid) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: PrimaryButton(
                        label: 'Preview Table',
                        icon: Icons.table_chart_outlined,
                        onPressed: onSeeTable,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PresetColumnChips extends StatelessWidget {
  const PresetColumnChips({super.key, required this.preset});

  final ExportPresetModel preset;

  @override
  Widget build(BuildContext context) {
    if (preset.mappings.isEmpty) {
      return const Text('No fields mapped in this preset.');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: preset.mappings.map((mapping) {
        final label = _getMappingLabel(mapping, preset.headerFormat);
        return Chip(
          label: Text(label),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withAlpha(24),
            width: 2,
          ),
        );
      }).toList(),
    );
  }

  String _getMappingLabel(
    ExportFieldMapping mapping,
    ExportHeaderFormat format,
  ) {
    final override = mapping.headerOverride?.trim();
    if (override != null && override.isNotEmpty) return override;
    if (mapping.isNested) {
      return '${mapping.nestedNamespace} (${mapping.nestedFields.length} fields)';
    }
    final expr = mapping.expression.trim();
    final match = RegExp(r'\[([^\]?\s]+)').firstMatch(expr);
    final key = match?.group(1) ?? expr;
    if (format == ExportHeaderFormat.fieldName) {
      return key.split('::').last;
    }
    return key;
  }
}

class ExportPresetTablePreviewScreen extends ConsumerStatefulWidget {
  const ExportPresetTablePreviewScreen({super.key, required this.preset});

  final ExportPresetModel preset;

  @override
  ConsumerState<ExportPresetTablePreviewScreen> createState() =>
      _ExportPresetTablePreviewScreenState();
}

class _ExportPresetTablePreviewScreenState
    extends ConsumerState<ExportPresetTablePreviewScreen> {
  final ScrollController _hScrollController = ScrollController();
  final ScrollController _vScrollController = ScrollController();
  List<String> _headers = [];
  List<List<String>> _rows = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _hScrollController.dispose();
    _vScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await PresetRecordExporter(
        ref: ref,
        preset: widget.preset,
      ).getPreviewData();
      if (mounted) {
        setState(() {
          _headers = data.headers;
          _rows = data.rows;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize) < _rows.length
        ? (startIndex + _pageSize)
        : _rows.length;
    final currentPageData = _isLoading || _rows.isEmpty
        ? <List<String>>[]
        : _rows.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(title: const Text('Table preview')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _rows.isEmpty
            ? const Center(child: Text('No records found for this preset.'))
            : Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Scrollbar(
                          controller: _vScrollController,
                          child: SingleChildScrollView(
                            controller: _vScrollController,
                            scrollDirection: Axis.vertical,
                            child: Scrollbar(
                              controller: _hScrollController,
                              child: SingleChildScrollView(
                                controller: _hScrollController,
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16.0),
                                    ),
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                        Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                      ),
                                      columnSpacing: 16,
                                      horizontalMargin: 12,
                                      dataRowMinHeight: 40,
                                      columns: [
                                        for (final col in _headers)
                                          DataColumn(
                                            label: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                minWidth: 72,
                                                maxWidth: 160,
                                              ),
                                              child: Text(col, softWrap: true),
                                            ),
                                          ),
                                      ],
                                      rows: [
                                        for (final row in currentPageData)
                                          DataRow(
                                            cells: [
                                              for (
                                                var index = 0;
                                                index < _headers.length;
                                                index++
                                              )
                                                DataCell(
                                                  ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxWidth: 200,
                                                        ),
                                                    child: Text(
                                                      index < row.length
                                                          ? row[index]
                                                          : '',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Showing ${startIndex + 1}-$endIndex of ${_rows.length} records',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 0
                              ? () {
                                  setState(() => _currentPage--);
                                }
                              : null,
                        ),
                        Text(
                          'Page ${_currentPage + 1} of ${(_rows.isNotEmpty ? (_rows.length / _pageSize).ceil() : 1)}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              (_currentPage + 1) * _pageSize < _rows.length
                              ? () {
                                  setState(() => _currentPage++);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
