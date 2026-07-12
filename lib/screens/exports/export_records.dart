import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';

/// Runs record exports from a saved preset. Record shape is intentionally not
/// editable here: the preset is the reproducible definition of an export.
class ExportForm extends ConsumerStatefulWidget {
  const ExportForm({super.key});

  @override
  ConsumerState<ExportForm> createState() => ExportFormState();
}

class ExportFormState extends ConsumerState<ExportForm> {
  final FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  String _fileStem = 'export';
  Directory? _selectedDir;
  String? _selectedPresetName;
  ExportPresetModel? _selectedPreset;
  bool _hasSaved = false;
  bool _isRunning = false;
  late File _savePath;

  @override
  void dispose() {
    exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presets = ref.watch(exportPresetNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Export records')),
      body: FileOperationPage(
        children: [
          FileFormatIcon(path: _matchFileIconPath()),
          const SizedBox(height: 8),
          presets.when(
            data: (presets) => _PresetPicker(
              presets: presets,
              selectedPresetName: _selectedPresetName,
              onPresetChanged: (name) {
                setState(() {
                  _selectedPresetName = name;
                  _selectedPreset = name == null ? null : presets[name];
                  _hasSaved = false;
                });
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Unable to load export presets: $error'),
          ),
          if (_selectedPreset != null) ...[
            const SizedBox(height: 16),
            PresetFieldViewer(preset: _selectedPreset!),
          ],
          const SizedBox(height: 16),
          FileSettingsCard(
            exportCtr: exportCtr,
            selectedDir: _selectedDir,
            onExportFmtChanged: (value) {
              if (value == null) return;
              setState(() {
                exportCtr.exportFmtCtr = value;
                _hasSaved = false;
              });
            },
            onFileNameChanged: (value) {
              if (value == null) return;
              setState(() {
                _fileStem = value;
                _hasSaved = false;
              });
            },
            onSelectDir: () async {
              final path = await FilePickerServices().selectDir();
              if (path != null) setState(() => _selectedDir = path);
            },
            onClearDir: () => setState(() {
              _selectedDir = null;
              _hasSaved = false;
            }),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            children: [
              SaveSecondaryButton(hasSaved: _hasSaved),
              if (!_hasSaved)
                ProgressButton(
                  label: 'Save',
                  icon: Icons.save_alt_outlined,
                  isRunning: _isRunning,
                  onPressed: _isValid() ? _exportFile : null,
                )
              else
                ShareButton(onPressed: () => _shareFile(context)),
            ],
          ),
        ],
      ),
    );
  }

  bool _isValid() => exportCtr.isValid && _selectedPreset != null;

  String _matchFileIconPath() => switch (exportCtr.exportFmtCtr) {
        ExportFmt.csv => 'assets/icons/csv.svg',
        ExportFmt.tsv => 'assets/icons/tsv.svg',
        ExportFmt.excel => 'assets/icons/csv.svg',
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
      _savePath = await AppIOServices(
        dir: _selectedDir,
        fileStem: _fileStem,
        ext: ext,
      ).getSavePath();
      await PresetRecordExporter(ref: ref, preset: _selectedPreset!).write(
        _savePath,
        format,
      );
      if (mounted) setState(() => _hasSaved = true);
      _showSavedPath();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  void _showSavedPath() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          systemPlatform == PlatformType.desktop
              ? 'File saved as $_savePath'
              : 'File saved!',
        ),
      ),
    );
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      await FilePickerServices().shareFile(context, _savePath);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }
}

class _PresetPicker extends StatelessWidget {
  const _PresetPicker({
    required this.presets,
    required this.selectedPresetName,
    required this.onPresetChanged,
  });

  final Map<String, ExportPresetModel> presets;
  final String? selectedPresetName;
  final ValueChanged<String?> onPresetChanged;

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
              'Create an export preset in Settings before exporting records.'),
        ),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: selectedPresetName,
      decoration: const InputDecoration(
        labelText: 'Export preset',
        helperText:
            'Record type, headers, and field mappings are set by the preset.',
      ),
      items: presets.keys
          .map((name) => DropdownMenuItem(value: name, child: Text(name)))
          .toList(growable: false),
      onChanged: onPresetChanged,
    );
  }
}

class PresetFieldViewer extends StatelessWidget {
  const PresetFieldViewer({super.key, required this.preset});

  final ExportPresetModel preset;

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text('Preset summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Record type: ${recordTypeToString(preset.recordType)}'),
            if (preset.recordType == RecordType.specimenRecord)
              Text('Taxon group: ${preset.specimenRecordType.name}'),
            Text('Header format: ${preset.headerFormat.name}'),
            const SizedBox(height: 12),
            ...preset.mappings.map(
              (mapping) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(mapping.headerOverride ?? mapping.expression),
                subtitle: Text(mapping.isNested
                    ? '${mapping.nestedMode.name}: ${mapping.nestedNamespace}::${mapping.nestedFields.join(', ')}'
                    : '${mapping.textType} · ${mapping.formatOption}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
