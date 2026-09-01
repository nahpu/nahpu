import 'dart:convert';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/presets/export_preset_edit.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/services/types/export.dart';

class ExportPresetsScreen extends ConsumerStatefulWidget {
  const ExportPresetsScreen({super.key});

  @override
  ExportPresetsScreenState createState() => ExportPresetsScreenState();
}

class ExportPresetsScreenState extends ConsumerState<ExportPresetsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedPresetName;
  ExportPresetModel? _selectedPresetMap;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectPreset(String? name, ExportPresetModel? preset) {
    setState(() {
      _selectedPresetName = name;
      _selectedPresetMap = preset;
    });
  }

  Future<void> _addNewPreset() async {
    final currentPresets = await ref.read(exportPresetNotifierProvider.future);
    if (currentPresets.length >= 20) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum of 20 presets reached.')),
        );
      }
      return;
    }

    if (!mounted) return;
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => const NewPresetDialog(),
    );
    if (newName != null) {
      _selectPreset(newName, ExportPresetModel.empty());
      _tabController.animateTo(1);
    }
  }

  void _scanPresetQr() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          onDetect: (barcode) {
            final rawValue = barcode.barcodes.first.rawValue;
            if (rawValue != null) {
              _importPresetFromQr(rawValue);
            }
          },
        ),
      ),
    );
  }

  Future<void> _importPresetFromQr(String rawValue) async {
    try {
      final decoded = jsonDecode(rawValue) as Map<String, dynamic>;
      if (!decoded.containsKey('nahpu_export_preset') ||
          !decoded.containsKey('data')) {
        throw const FormatException('Invalid QR code format for preset.');
      }

      final name = decoded['nahpu_export_preset'] as String;
      final data = ExportPresetModel.fromJson(
        Map<String, dynamic>.from(decoded['data'] as Map),
      );
      final currentPresets = await ref.read(
        exportPresetNotifierProvider.future,
      );
      if (currentPresets.length >= 20) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum of 20 presets reached. Cannot import.'),
            ),
          );
        }
        return;
      }

      var finalName = name;
      var i = 1;
      while (currentPresets.containsKey(finalName)) {
        finalName = '${name}_$i';
        i++;
      }

      await ref
          .read(exportPresetNotifierProvider.notifier)
          .savePreset(finalName, data);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Imported preset "$finalName"')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or unrecognized QR code.')),
        );
      }
    }
  }

  Future<void> _importPresetsFile() async {
    final file = await FilePickerServices().selectAnyFile();
    if (file == null) return;

    try {
      final content = await File(file.path).readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final notifier = ref.read(exportPresetNotifierProvider.notifier);

      var importedCount = 0;
      for (final entry in decoded.entries) {
        final currentPresets = await ref.read(
          exportPresetNotifierProvider.future,
        );
        if (currentPresets.length >= 20) break;

        final data = ExportPresetModel.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
        var finalName = entry.key;
        var i = 1;
        while (currentPresets.containsKey(finalName)) {
          finalName = '${entry.key}_$i';
          i++;
        }
        await notifier.savePreset(finalName, data);
        importedCount++;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported $importedCount presets')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import presets: $error')),
        );
      }
    }
  }

  Future<void> _exportPresetsFile() => _exportPresets();

  /// Writes presets to a JSON file.
  ///
  /// One preset and all presets share the same name-keyed envelope, so either
  /// file imports through the same path.
  Future<void> _exportPresets({String? onlyName}) async {
    try {
      final currentPresets = await ref.read(
        exportPresetNotifierProvider.future,
      );
      final selected = onlyName == null
          ? currentPresets
          : {
              for (final entry in currentPresets.entries)
                if (entry.key == onlyName) entry.key: entry.value,
            };
      if (selected.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No presets to export')));
        }
        return;
      }
      final dir = await FilePickerServices().selectDir();
      if (dir == null) return;

      final fileName = onlyName == null
          ? 'nahpu_export_presets.json'
          : 'preset_${_sanitizeFileStem(onlyName)}.json';
      final savePath = File(path.join(dir.path, fileName));
      await savePath.writeAsString(jsonEncode(selected));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${selected.length} preset'
            '${selected.length == 1 ? '' : 's'} to ${savePath.path}',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export presets: $error')),
        );
      }
    }
  }

  String _sanitizeFileStem(String name) {
    final safe = name.trim().replaceAll(RegExp(r'[^\w.\-]'), '_');
    return safe.isEmpty ? 'preset' : safe;
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabular Export Presets'),
        actions: [
          PresetAppBarActions(
            onCreate: _addNewPreset,
            onScanQr: _scanPresetQr,
            onImport: _importPresetsFile,
            onExportAll: _exportPresetsFile,
            onExportSelected: _selectedPresetName == null
                ? null
                : () => _exportPresets(onlyName: _selectedPresetName),
          ),
        ],
      ),
      body: isLargeScreen
          ? Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PresetListColumn(
                      selectedPresetName: _selectedPresetName,
                      onPresetSelected: _selectPreset,
                      tabController: _tabController,
                      onExportPreset: (name) => _exportPresets(onlyName: name),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Material(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      child: PresetEditColumn(
                        selectedPresetName: _selectedPresetName,
                        selectedPresetMap: _selectedPresetMap,
                        onPresetRenamed: (oldName, newName) {
                          setState(() {
                            _selectedPresetName = newName;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Presets'),
                    Tab(text: 'Edit Preset'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PresetListColumn(
                        selectedPresetName: _selectedPresetName,
                        onPresetSelected: _selectPreset,
                        tabController: _tabController,
                        onExportPreset: (name) =>
                            _exportPresets(onlyName: name),
                      ),
                      PresetEditColumn(
                        selectedPresetName: _selectedPresetName,
                        selectedPresetMap: _selectedPresetMap,
                        onPresetRenamed: (oldName, newName) {
                          setState(() {
                            _selectedPresetName = newName;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class PresetListColumn extends ConsumerStatefulWidget {
  const PresetListColumn({
    super.key,
    required this.selectedPresetName,
    required this.onPresetSelected,
    required this.tabController,
    this.onExportPreset,
  });

  final String? selectedPresetName;
  final void Function(String?, ExportPresetModel?) onPresetSelected;
  final TabController tabController;
  final ValueChanged<String>? onExportPreset;

  @override
  ConsumerState<PresetListColumn> createState() => _PresetListColumnState();
}

class _PresetListColumnState extends ConsumerState<PresetListColumn> {
  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Select Presets',
      infoTopic: InfoTopic.tabularExportPresets,
      isWithSidePadding: false,
      isExpanded: true,
      child: Column(
        children: [
          Expanded(
            child: ref
                .watch(exportPresetNotifierProvider)
                .when(
                  data: (presets) {
                    if (presets.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No presets found.')),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: presets.length,
                      itemBuilder: (context, index) {
                        final name = presets.keys.elementAt(index);
                        final preset = presets[name]!;
                        final isSelected = widget.selectedPresetName == name;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.8),
                            child: ListTile(
                              leading: isSelected
                                  ? const Icon(Icons.radio_button_checked)
                                  : const Icon(Icons.radio_button_unchecked),
                              title: Text(name),
                              subtitle: Text(
                                '${preset.mappings.length} mappings · ${recordTypeToString(preset.recordType)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onExportPreset != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.file_upload_outlined,
                                      ),
                                      tooltip: 'Export this preset',
                                      onPressed: () =>
                                          widget.onExportPreset!(name),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete',
                                    onPressed: () => _deletePreset(name),
                                  ),
                                ],
                              ),
                              onTap: () {
                                widget.onPresetSelected(name, preset);
                                widget.tabController.animateTo(1);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const CommonProgressIndicator(),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
          ),
        ],
      ),
    );
  }

  void _deletePreset(String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete the preset "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(exportPresetNotifierProvider.notifier).deletePreset(name);
      if (widget.selectedPresetName == name) {
        widget.onPresetSelected(null, null);
      }
    }
  }
}

class PresetEditColumn extends ConsumerWidget {
  const PresetEditColumn({
    super.key,
    required this.selectedPresetName,
    required this.selectedPresetMap,
    required this.onPresetRenamed,
  });

  final String? selectedPresetName;
  final ExportPresetModel? selectedPresetMap;
  final void Function(String, String) onPresetRenamed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedPresetName == null || selectedPresetMap == null) {
      return const Center(child: Text('Select a preset to edit'));
    }
    return ref
        .watch(exportPresetNotifierProvider)
        .when(
          data: (presets) {
            if (!presets.containsKey(selectedPresetName!)) {
              return const Center(child: Text('Preset not found'));
            }
            return ExportPresetEditForm(
              presetName: selectedPresetName!,
              initialPreset: presets[selectedPresetName!]!,
              onPresetRenamed: onPresetRenamed,
            );
          },
          loading: () => const CommonProgressIndicator(),
          error: (e, s) => const Center(child: Text('Error loading preset')),
        );
  }
}

class NewPresetDialog extends ConsumerStatefulWidget {
  const NewPresetDialog({super.key});

  @override
  NewPresetDialogState createState() => NewPresetDialogState();
}

class NewPresetDialogState extends ConsumerState<NewPresetDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Preset'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Preset Name',
          errorText: _errorText,
        ),
        onChanged: _validate,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          label: 'Create',
          icon: Icons.add,
          onPressed: () async {
            _validate(_nameController.text);
            if (_errorText == null && _nameController.text.isNotEmpty) {
              final name = _nameController.text;
              final currentPresets = await ref.read(
                exportPresetNotifierProvider.future,
              );
              if (currentPresets.containsKey(name)) {
                setState(() {
                  _errorText = 'A preset with this name already exists';
                });
                return;
              }
              await ref
                  .read(exportPresetNotifierProvider.notifier)
                  .savePreset(name, ExportPresetModel.empty());
              if (context.mounted) {
                Navigator.pop(context, name);
              }
            }
          },
        ),
      ],
    );
  }

  void _validate(String value) {
    if (value.isEmpty) {
      setState(() {
        _errorText = 'Name cannot be empty';
      });
      return;
    }
    final RegExp validName = RegExp(r'^[a-zA-Z0-9_\-]+$');
    if (!validName.hasMatch(value)) {
      setState(() {
        _errorText = 'Only alphanumeric, underscores, and dashes allowed';
      });
      return;
    }
    setState(() {
      _errorText = null;
    });
  }
}
