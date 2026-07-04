import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/document/document_settings_pane.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/services/document_layout_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/qr.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:path/path.dart' as path;

// Preview and specimen selection imports
import 'package:nahpu/screens/shared/document/document_preview_pane.dart';
import 'package:nahpu/screens/shared/document/specimen_selection.dart';
import 'package:nahpu/screens/shared/document/column_picker.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/template_settings_services.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/export/export_document.dart';

class DocumentPresetsScreen extends ConsumerStatefulWidget {
  const DocumentPresetsScreen({super.key});

  @override
  ConsumerState<DocumentPresetsScreen> createState() =>
      _DocumentPresetsScreenState();
}

class _DocumentPresetsScreenState extends ConsumerState<DocumentPresetsScreen>
    with TickerProviderStateMixin {
  final DocumentLayoutService _layoutService = const DocumentLayoutService();
  late TabController _tabController;
  late TabController _largeScreenTabController;

  bool _loading = true;
  String? _error;
  rust_config.DocumentLayoutPreset? _layout;
  List<rust_config.DocumentLayoutStatus> _layoutStatuses = const [];
  List<String> _templateNames = const [];
  String _selectedLayoutName = 'Default';

  // Preview States
  bool _showPreview = false;
  bool _previewStale = false;
  int _previewVersion = 0;
  rust_config.DocumentLayoutPreset? _previewLayout;
  List<String> _previewSelectedUuidList = const [];
  List<String> _previewSelectedUuids = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _largeScreenTabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _largeScreenTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    final previewWidget = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preview Specimens (${_previewSelectedUuids.length} selected)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              OutlinedButton.icon(
                onPressed: _selectPreviewSpecimens,
                icon: const Icon(Icons.check_box_outlined),
                label: const Text('Select'),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: DocumentPreviewPane(
            showPreview: _showPreview,
            layout: _previewLayout,
            selectedUuidList: _previewSelectedUuidList,
            previewVersion: _previewVersion,
            isPreviewStale: _previewStale,
            onGeneratePreview: _updatePreview,
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Presets'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SafeArea(
                  child: isLargeScreen
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DocumentPresetListColumn(
                                  selectedPresetName: _selectedLayoutName,
                                  statuses: _layoutStatuses,
                                  onPresetSelected: (name) async {
                                    await _selectLayout(name);
                                    _tabController.animateTo(1);
                                  },
                                  onDeletePreset: _deletePreset,
                                  onCreatePreset: _addPreset,
                                  onScanQR: _importPresetFromQR,
                                  onImport: _importPreset,
                                  onExport: _exportPresetsToFile,
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
                                  child: Column(
                                    children: [
                                      TabBar(
                                        controller: _largeScreenTabController,
                                        tabs: const [
                                          Tab(text: 'Edit Preset'),
                                          Tab(text: 'Preview'),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          controller: _largeScreenTabController,
                                          children: [
                                            DocumentPresetEditColumn(
                                              selectedPresetName:
                                                  _selectedLayoutName,
                                              layout: _layout,
                                              templateNames: _templateNames,
                                              layoutStatuses: _layoutStatuses,
                                              onLayoutChanged: _layoutChanged,
                                              onSaveSetupAs: _savePresetAs,
                                              onCreateTemplate:
                                                  _openTemplateEditor,
                                            ),
                                            previewWidget,
                                          ],
                                        ),
                                      ),
                                    ],
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
                                Tab(text: 'Preview'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  DocumentPresetListColumn(
                                    selectedPresetName: _selectedLayoutName,
                                    statuses: _layoutStatuses,
                                    onPresetSelected: (name) async {
                                      await _selectLayout(name);
                                      _tabController.animateTo(1);
                                    },
                                    onDeletePreset: _deletePreset,
                                    onCreatePreset: _addPreset,
                                    onScanQR: _importPresetFromQR,
                                    onImport: _importPreset,
                                    onExport: _exportPresetsToFile,
                                    tabController: _tabController,
                                  ),
                                  DocumentPresetEditColumn(
                                    selectedPresetName: _selectedLayoutName,
                                    layout: _layout,
                                    templateNames: _templateNames,
                                    layoutStatuses: _layoutStatuses,
                                    onLayoutChanged: _layoutChanged,
                                    onSaveSetupAs: _savePresetAs,
                                    onCreateTemplate: _openTemplateEditor,
                                  ),
                                  previewWidget,
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
    );
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var statuses = await _layoutService.listLayoutStatuses();
      if (statuses.isEmpty) {
        final defaultLayout = await _layoutService.getDefaultLayout('Default');
        await _layoutService.saveLayout(defaultLayout);
        statuses = await _layoutService.listLayoutStatuses();
      }
      final names = statuses.map((status) => status.name).toList();
      final current = await _layoutService.getStoredCurrentLayoutName();
      final String selectedName =
          current != null && names.contains(current) ? current : names.first;
      final selectedStatus =
          statuses.firstWhere((status) => status.name == selectedName);
      final layout = selectedStatus.isCompatible
          ? await _layoutService.getLayout(selectedName)
          : null;
      final templates = await rust_config.listTemplatePresets();

      if (_previewSelectedUuids.isEmpty) {
        final specimens = await ref.read(specimenEntryProvider.future);
        _previewSelectedUuids = specimens.take(20).map((e) => e.uuid).toList();
      }

      if (!mounted) return;
      setState(() {
        _layoutStatuses = statuses;
        _selectedLayoutName = selectedName;
        _layout = layout;
        _templateNames = templates;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _markPreviewStale() {
    if (_showPreview && !_previewStale) {
      setState(() {
        _previewStale = true;
      });
    }
  }

  void _updatePreview() {
    if (_layout == null) return;
    setState(() {
      _showPreview = true;
      _previewStale = false;
      _previewLayout = _layout;
      _previewSelectedUuidList = List.unmodifiable(_previewSelectedUuids);
      _previewVersion++;
    });
  }

  void _selectPreviewSpecimens() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewSpecimenSelectionScreen(
          selectedUuids: _previewSelectedUuids.toSet(),
          onSelectionChanged: (selected) {
            setState(() {
              _previewSelectedUuids = selected.toList();
              _previewStale = true;
            });
          },
        ),
      ),
    );
  }

  Future<void> _layoutChanged(rust_config.DocumentLayoutPreset layout) async {
    setState(() {
      _layout = layout;
    });
    await _layoutService.saveLayout(layout);
    _markPreviewStale();
  }

  Future<void> _selectLayout(String name) async {
    final status = _layoutStatuses.firstWhere((status) => status.name == name);
    final layout =
        status.isCompatible ? await _layoutService.getLayout(name) : null;
    if (status.isCompatible) {
      await _layoutService.setCurrentLayoutName(name);
    }
    setState(() {
      _selectedLayoutName = name;
      _layout = layout;
    });
    _markPreviewStale();
  }

  Future<void> _addPreset() async {
    final name = await _promptPresetName(title: 'New document preset');
    if (name == null) return;

    final templateName =
        _templateNames.isNotEmpty ? _templateNames.first : 'Default';
    final layout = await _layoutService.getDefaultLayout(name);
    final blocks = layout.blocks.isEmpty
        ? [
            rust_config.DocumentLayoutBlock(
              templateName: templateName,
              templateCount: 1,
              rows: 8,
              cols: 4,
              templatePadTopMm: 1.0,
              templatePadLeftMm: 1.0,
              templatePadRightMm: 1.0,
              templatePadBottomMm: 1.0,
              pageBreakAfter: false,
            ),
          ]
        : layout.blocks;
    final nextLayout = layout.copyWith(name: name, blocks: blocks);

    await _layoutService.saveLayout(nextLayout);
    await _layoutService.setCurrentLayoutName(name);
    await _load();
  }

  Future<void> _savePresetAs() async {
    final layout = _layout;
    if (layout == null) return;

    final name = await _promptPresetName(
      title: 'Save document preset',
      initialValue: _selectedLayoutName,
    );
    if (name == null) return;

    final nextLayout = layout.copyWith(name: name);
    await _layoutService.saveLayout(nextLayout);
    await _layoutService.setCurrentLayoutName(name);
    await _load();
  }

  Future<void> _deletePreset(String name) async {
    if (name == 'Default') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete Default preset')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Delete "$name"?'),
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
    if (ok != true) return;

    await _layoutService.deleteLayout(name);
    final remaining = _layoutStatuses.where((s) => s.name != name).toList();
    if (remaining.isNotEmpty) {
      _selectedLayoutName = remaining.first.name;
    } else {
      _selectedLayoutName = 'Default';
    }
    await _load();
  }

  Future<void> _openTemplateEditor() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const TemplateEditorScreen(),
      ),
    );
    await _load();
  }

  Future<void> _exportPresetsToFile() async {
    try {
      final layouts = await rust_config.getAllDocumentLayouts();
      if (layouts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No presets to export')),
          );
        }
        return;
      }
      final Map<String, dynamic> exportedData = {};
      for (final l in layouts) {
        exportedData[l.name] = l.toJson();
      }
      final jsonString = jsonEncode(exportedData);
      final dir = await FilePickerServices().selectDir();
      if (dir != null) {
        final savePath =
            File(path.join(dir.path, 'nahpu_document_presets.json'));
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

  Future<void> _importPreset() async {
    final file = await FilePickerServices().selectAnyFile();
    if (file == null) return;

    try {
      final content = await File(file.path).readAsString();
      final decoded = jsonDecode(content);

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('name') && decoded.containsKey('layoutType')) {
          var imported = DocumentLayoutPresetJson.fromJson(decoded);
          await _saveAndSetCurrentLayout(imported);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Imported layout "${imported.name}"')),
            );
          }
        } else {
          int importedCount = 0;
          final existingNames = (await _layoutService.listLayoutStatuses())
              .map((s) => s.name)
              .toSet();

          for (final entry in decoded.entries) {
            final layoutMap = Map<String, dynamic>.from(entry.value as Map);
            var layout = DocumentLayoutPresetJson.fromJson(layoutMap);

            String finalName = entry.key;
            int i = 1;
            while (existingNames.contains(finalName)) {
              finalName = '${entry.key}_$i';
              i++;
            }
            existingNames.add(finalName);
            layout = layout.copyWith(name: finalName);
            await _layoutService.saveLayout(layout);
            importedCount++;
          }
          await _load();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Imported $importedCount presets')),
            );
          }
        }
      } else {
        throw const FormatException('Invalid format');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid document layout file: $e')),
        );
      }
    }
  }

  Future<void> _saveAndSetCurrentLayout(
      rust_config.DocumentLayoutPreset imported) async {
    var nextLayout = imported;
    final names = (await _layoutService.listLayoutStatuses())
        .map((s) => s.name)
        .toList();
    if (names.contains(imported.name)) {
      final base = imported.name;
      var i = 2;
      while (names.contains('$base $i')) {
        i++;
      }
      nextLayout = imported.copyWith(name: '$base $i');
    }
    await _layoutService.saveLayout(nextLayout);
    await _layoutService.setCurrentLayoutName(nextLayout.name);
    await _load();
  }

  void _importPresetFromQR(String rawValue) async {
    try {
      final decoded = jsonDecode(rawValue) as Map<String, dynamic>;
      if (decoded.containsKey('nahpu_document_preset') &&
          decoded.containsKey('data')) {
        String name = decoded['nahpu_document_preset'] as String;
        final dataJson = Map<String, dynamic>.from(decoded['data'] as Map);
        var layout = DocumentLayoutPresetJson.fromJson(dataJson);

        if (_layoutStatuses.length >= 20) {
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
        final existingNames = _layoutStatuses.map((s) => s.name).toSet();
        while (existingNames.contains(finalName)) {
          finalName = '${name}_$i';
          i++;
        }
        layout = layout.copyWith(name: finalName);

        await _layoutService.saveLayout(layout);
        await _layoutService.setCurrentLayoutName(finalName);
        await _load();

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

  Future<String?> _promptPresetName({
    required String title,
    String? initialValue,
  }) async {
    final existingNames = (await _layoutService.listLayoutStatuses())
        .map((status) => status.name)
        .toList();
    if (!mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (context) => _DocumentPresetNameDialog(
        title: title,
        initialValue: initialValue,
        existingNames: existingNames,
      ),
    );
  }
}

class DocumentPresetListColumn extends StatelessWidget {
  const DocumentPresetListColumn({
    super.key,
    required this.selectedPresetName,
    required this.statuses,
    required this.onPresetSelected,
    required this.onDeletePreset,
    required this.onCreatePreset,
    required this.onScanQR,
    required this.onImport,
    required this.onExport,
    required this.tabController,
  });

  final String? selectedPresetName;
  final List<rust_config.DocumentLayoutStatus> statuses;
  final ValueChanged<String> onPresetSelected;
  final ValueChanged<String> onDeletePreset;
  final VoidCallback onCreatePreset;
  final ValueChanged<String> onScanQR;
  final VoidCallback onImport;
  final VoidCallback onExport;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Select Presets',
      infoContent: const DocumentPresetInfoContent(),
      isWithSidePadding: false,
      isExpanded: true,
      child: Column(
        children: [
          Expanded(
            child: statuses.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No presets found.')),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: statuses.length,
                    itemBuilder: (context, index) {
                      final status = statuses[index];
                      final name = status.name;
                      final isSelected = selectedPresetName == name;
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
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!status.isCompatible) ...[
                                  Icon(
                                    Icons.warning_amber_outlined,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(child: Text(name)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (status.isCompatible)
                                  IconButton(
                                    icon: const Icon(Icons.qr_code),
                                    tooltip: 'Show QR Code',
                                    onPressed: () => _showQRCode(context, name),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                  onPressed: () => onDeletePreset(name),
                                ),
                              ],
                            ),
                            onTap: () {
                              onPresetSelected(name);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const CommonLineDivider(),
          PresetActionButtons(
            onAddNewPreset: onCreatePreset,
            onScanQR: onScanQR,
            onImport: onImport,
            onExport: onExport,
          ),
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context, String name) async {
    final layoutService = const DocumentLayoutService();
    final layout = await layoutService.getLayout(name);
    if (layout == null) return;
    final payload = jsonEncode({
      'nahpu_document_preset': name,
      'data': layout.toJson(),
    });
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: SizedBox(
          width: 300,
          height: 300,
          child: QrImageView(
            data: payload,
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
            child: const Text('Import presets from file'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onExport,
            child: const Text('Export presets'),
          ),
        ],
      ),
    );
  }
}

class DocumentPresetEditColumn extends StatelessWidget {
  const DocumentPresetEditColumn({
    super.key,
    required this.selectedPresetName,
    required this.layout,
    required this.templateNames,
    required this.layoutStatuses,
    required this.onLayoutChanged,
    required this.onSaveSetupAs,
    required this.onCreateTemplate,
  });

  final String? selectedPresetName;
  final rust_config.DocumentLayoutPreset? layout;
  final List<String> templateNames;
  final List<rust_config.DocumentLayoutStatus> layoutStatuses;
  final ValueChanged<rust_config.DocumentLayoutPreset> onLayoutChanged;
  final VoidCallback onSaveSetupAs;
  final VoidCallback onCreateTemplate;

  @override
  Widget build(BuildContext context) {
    if (selectedPresetName == null) {
      return const Center(
        child: Text('Select a preset to edit'),
      );
    }

    final status = layoutStatuses.firstWhere(
      (s) => s.name == selectedPresetName,
      orElse: () => rust_config.DocumentLayoutStatus(
        name: selectedPresetName!,
        isCompatible: false,
      ),
    );

    if (!status.isCompatible) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Incompatible preset',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              status.error ??
                  'This preset is not compatible with the current version.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (layout == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedPresetName!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                OutlinedButton.icon(
                  onPressed: onSaveSetupAs,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Duplicate'),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: DocumentLayoutSection(
                layout: layout!,
                setupNames: const [],
                selectedSetupName: selectedPresetName!,
                templateNames: templateNames,
                onLayoutChanged: onLayoutChanged,
                onSetupSelected: (_) {},
                showPresetActions: false,
                showFileActions: false,
                showProfileDropdown: false,
                onCreateTemplate: onCreateTemplate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentPresetNameDialog extends StatefulWidget {
  const _DocumentPresetNameDialog({
    required this.title,
    required this.existingNames,
    this.initialValue,
  });

  final String title;
  final String? initialValue;
  final List<String> existingNames;

  @override
  State<_DocumentPresetNameDialog> createState() =>
      _DocumentPresetNameDialogState();
}

class _DocumentPresetNameDialogState extends State<_DocumentPresetNameDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Preset name',
          errorText: _errorText,
        ),
        onChanged: _validate,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    _validate(name);
    if (_errorText != null) return;
    Navigator.pop(context, name);
  }

  void _validate(String value) {
    final name = value.trim();
    String? error;
    if (name.isEmpty) {
      error = 'Name cannot be empty';
    } else if (widget.existingNames.contains(name) &&
        name != widget.initialValue) {
      error = 'A preset with this name already exists';
    }
    setState(() {
      _errorText = error;
    });
  }
}

class DocumentPresetInfoContent extends StatelessWidget {
  const DocumentPresetInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Document Presets',
          content:
              'Create and manage custom configurations for exporting documents. '
              'You can configure the page size, margins, and the template blocks to layout.',
        ),
      ],
    );
  }
}

class PreviewSpecimenSelectionScreen extends ConsumerStatefulWidget {
  const PreviewSpecimenSelectionScreen({
    super.key,
    required this.selectedUuids,
    required this.onSelectionChanged,
  });

  final Set<String> selectedUuids;
  final ValueChanged<Set<String>> onSelectionChanged;

  @override
  ConsumerState<PreviewSpecimenSelectionScreen> createState() =>
      _PreviewSpecimenSelectionScreenState();
}

class _PreviewSpecimenSelectionScreenState
    extends ConsumerState<PreviewSpecimenSelectionScreen> {
  List<String> _visibleColumnIds = [];

  @override
  void initState() {
    super.initState();
    _loadColumns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select specimens for preview'),
      ),
      body: SafeArea(
        child: SpecimenSelectionView(
          selectedUuidList: widget.selectedUuids,
          visibleColumnIds: _visibleColumnIds,
          onSelectionChanged: widget.onSelectionChanged,
          onColumnsChanged: _pickColumns,
        ),
      ),
    );
  }

  Future<void> _loadColumns() async {
    final db = ref.read(databaseProvider);
    final settings = DocumentSettingsServices();
    final storedCols = await settings.getPrintSpecimenTableColumnIds();
    var visible = normalizePrintSpecimenTableColumnIds(storedCols, db);
    if (visible.isEmpty) {
      visible = normalizePrintSpecimenTableColumnIds(
        List<String>.from(kDefaultPrintSpecimenTableColumnIds),
        db,
      );
    }
    if (mounted) {
      setState(() {
        _visibleColumnIds = visible;
      });
    }
  }

  Future<void> _pickColumns() async {
    final db = ref.read(databaseProvider);
    final settings = DocumentSettingsServices();
    final order = List<String>.from(_visibleColumnIds);
    List<String>? result;

    if (systemPlatform == PlatformType.mobile) {
      result = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Table columns'),
                automaticallyImplyLeading: false,
              ),
              body: SpecimenTableColumnSelector(
                selectedColumns: _visibleColumnIds,
              ),
            ),
          );
        },
      );
    } else {
      result = await showDialog<List<String>>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Table columns'),
            content: SizedBox(
              width: 420,
              height: 420,
              child: SpecimenTableColumnSelector(
                selectedColumns: _visibleColumnIds,
              ),
            ),
          );
        },
      );
    }

    if (result != null && mounted) {
      var merged =
          const ExportDocumentService().mergeColumnOrder(order, result.toSet());
      merged = normalizePrintSpecimenTableColumnIds(merged, db);
      if (merged.isEmpty) {
        merged = normalizePrintSpecimenTableColumnIds(
          List<String>.from(kDefaultPrintSpecimenTableColumnIds),
          db,
        );
      }
      await settings.setPrintSpecimenTableColumnIds(merged);
      setState(() {
        _visibleColumnIds = merged;
      });
    }
  }
}
