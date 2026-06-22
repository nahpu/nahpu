import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/export_preset_edit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nahpu/screens/shared/qr.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:path/path.dart' as path;

class ExportPresetsScreen extends ConsumerStatefulWidget {
  const ExportPresetsScreen({super.key});

  @override
  ExportPresetsScreenState createState() => ExportPresetsScreenState();
}

class ExportPresetsScreenState extends ConsumerState<ExportPresetsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedPresetName;
  Map<String, String>? _selectedPresetMap;
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

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Presets'),
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
                      onPresetSelected: (name, map) {
                        setState(() {
                          _selectedPresetName = name;
                          _selectedPresetMap = map;
                        });
                      },
                      tabController: _tabController,
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
                        onPresetSelected: (name, map) {
                          setState(() {
                            _selectedPresetName = name;
                            _selectedPresetMap = map;
                          });
                        },
                        tabController: _tabController,
                      ),
                      PresetEditColumn(
                        selectedPresetName: _selectedPresetName,
                        selectedPresetMap: _selectedPresetMap,
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
  });

  final String? selectedPresetName;
  final void Function(String?, Map<String, String>?) onPresetSelected;
  final TabController tabController;

  @override
  ConsumerState<PresetListColumn> createState() => _PresetListColumnState();
}

class _PresetListColumnState extends ConsumerState<PresetListColumn> {
  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Select Presets',
      infoContent: const ExportPresetInfoContent(),
      isWithSidePadding: false,
      isExpanded: true,
      child: Column(
        children: [
          Expanded(
            child: ref.watch(exportPresetNotifierProvider).when(
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
                              vertical: 4, horizontal: 8),
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
                              subtitle:
                                  Text('${preset.length} fields selected'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.qr_code),
                                    tooltip: 'Show QR Code',
                                    onPressed: () => _showQRCode(name, preset),
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
          const CommonLineDivider(),
          PresetActionButtons(
            onAddNewPreset: _addNewPreset,
            onScanQR: _importPresetFromQR,
            onImport: _importPresetsFile,
            onExport: _exportPresetsFile,
          ),
        ],
      ),
    );
  }

  void _addNewPreset() async {
    final currentPresets = await ref.read(exportPresetNotifierProvider.future);
    if (currentPresets.length >= 20) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum of 20 presets reached.')),
        );
      }
      return;
    }

    if (mounted) {
      final newName = await showDialog<String>(
        context: context,
        builder: (context) => const NewPresetDialog(),
      );
      if (newName != null) {
        widget.onPresetSelected(newName, {});
        widget.tabController.animateTo(1);
      }
    }
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

  void _showQRCode(String name, Map<String, String> preset) {
    final payload = jsonEncode({'nahpu_export_preset': name, 'data': preset});
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: SizedBox(
          width: 300,
          height: 300,
          child: QrImageView(
            data: payload,
            version: QrVersions.auto,
            backgroundColor: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _importPresetFromQR(String rawValue) async {
    try {
      final decoded = jsonDecode(rawValue) as Map<String, dynamic>;
      if (decoded.containsKey('nahpu_export_preset') &&
          decoded.containsKey('data')) {
        String name = decoded['nahpu_export_preset'] as String;
        final data = Map<String, String>.from(decoded['data'] as Map);

        final currentPresets =
            await ref.read(exportPresetNotifierProvider.future);
        if (currentPresets.length >= 20) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Maximum of 20 presets reached. Cannot import.')),
            );
          }
          return;
        }

        String finalName = name;
        int i = 1;
        while (currentPresets.containsKey(finalName)) {
          finalName = '${name}_$i';
          i++;
        }

        await ref
            .read(exportPresetNotifierProvider.notifier)
            .savePreset(finalName, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported preset "$finalName"')),
          );
        }
      } else {
        throw const FormatException('Invalid QR code format for preset.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or unrecognized QR code.')),
        );
      }
    }
  }

  void _importPresetsFile() async {
    final file = await FilePickerServices().selectAnyFile();
    if (file != null) {
      try {
        final content = await File(file.path).readAsString();
        final decoded = jsonDecode(content) as Map<String, dynamic>;

        final notifier = ref.read(exportPresetNotifierProvider.notifier);

        int importedCount = 0;
        for (final entry in decoded.entries) {
          final currentPresetsLatest =
              await ref.read(exportPresetNotifierProvider.future);
          if (currentPresetsLatest.length >= 20) break;

          final data = Map<String, String>.from(entry.value as Map);

          String finalName = entry.key;
          int i = 1;
          while (currentPresetsLatest.containsKey(finalName)) {
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to import presets: $e')),
          );
        }
      }
    }
  }

  void _exportPresetsFile() async {
    try {
      final currentPresets =
          await ref.read(exportPresetNotifierProvider.future);
      if (currentPresets.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No presets to export')),
          );
        }
        return;
      }
      final jsonString = jsonEncode(currentPresets);
      final dir = await FilePickerServices().selectDir();
      if (dir != null) {
        final savePath = File(path.join(dir.path, 'nahpu_export_presets.json'));
        await savePath.writeAsString(jsonString);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported presets to ${savePath.path}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export presets: $e')),
        );
      }
    }
  }
}

class PresetActionButtons extends StatelessWidget {
  const PresetActionButtons({
    super.key,
    required this.onExport,
    required this.onImport,
    required this.onScanQR,
    required this.onAddNewPreset,
  });

  final void Function() onExport;
  final void Function() onImport;
  final void Function(String) onScanQR;
  final void Function() onAddNewPreset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SecondaryButton(
                text: 'Scan QR',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScannerScreen(
                        onDetect: (barcode) {
                          final String? rawValue =
                              barcode.barcodes.first.rawValue;
                          if (rawValue != null) {
                            onScanQR(rawValue);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              PrimaryButton(
                label: 'Create',
                icon: Icons.add,
                onPressed: onAddNewPreset,
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onImport,
            child: Text('Import presets from file'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onExport,
            child: Text('Export presets'),
          ),
        ],
      ),
    );
  }
}

class PresetEditColumn extends ConsumerWidget {
  const PresetEditColumn({
    super.key,
    required this.selectedPresetName,
    required this.selectedPresetMap,
  });

  final String? selectedPresetName;
  final Map<String, String>? selectedPresetMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedPresetName == null || selectedPresetMap == null) {
      return const Center(
        child: Text('Select a preset to edit'),
      );
    }
    return ref.watch(exportPresetNotifierProvider).when(
          data: (presets) {
            if (!presets.containsKey(selectedPresetName!)) {
              return const Center(child: Text('Preset not found'));
            }
            return ExportPresetEditForm(
              presetName: selectedPresetName!,
              initialPreset: presets[selectedPresetName!]!,
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
              final currentPresets =
                  await ref.read(exportPresetNotifierProvider.future);
              if (currentPresets.containsKey(name)) {
                setState(() {
                  _errorText = 'A preset with this name already exists';
                });
                return;
              }
              await ref
                  .read(exportPresetNotifierProvider.notifier)
                  .savePreset(name, {});
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

class ExportPresetInfoContent extends StatelessWidget {
  const ExportPresetInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Export Presets',
          content:
              'Create and manage custom configurations for exporting records. '
              'You can select specific fields to include in your exports.',
        ),
      ],
    );
  }
}
