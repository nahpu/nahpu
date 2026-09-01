import 'dart:convert';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/document/document_settings_pane.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/services/templates/document_layout_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/screens/shared/actions/preset_actions.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:path/path.dart' as path;

// Preview and specimen selection imports
import 'package:nahpu/screens/shared/document/document_preview_pane.dart';
import 'package:nahpu/screens/shared/document/specimen_selection.dart';
import 'package:nahpu/screens/shared/document/specimen_part_selection.dart';
import 'package:nahpu/screens/shared/document/record_selection.dart';
import 'package:nahpu/screens/shared/document/column_picker.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/templates/template_settings_services.dart';
import 'package:nahpu/services/templates/template_table_preview_settings_service.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/screens/settings/presets/font_manager.dart';
import 'package:nahpu/screens/settings/presets/template_preset_manager.dart';
import 'package:nahpu/services/settings/config_services.dart';
import 'package:nahpu/services/templates/bundled_template_preset_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The three things the Document Presets screen manages.
enum DocumentPresetView { layouts, templates, fonts }

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
  DocumentPresetView _view = DocumentPresetView.layouts;

  // Preview States
  bool _showPreview = false;
  bool _previewStale = false;
  int _previewVersion = 0;
  rust_config.DocumentLayoutPreset? _previewLayout;
  List<String> _previewSelectedUuidList = const [];
  List<String> _previewSelectedUuids = const [];
  RecordType _recordType = RecordType.specimenRecord;

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
                _recordType == RecordType.site
                    ? 'Preview Sites (${_previewSelectedUuids.length} selected)'
                    : _recordType == RecordType.collEvent
                    ? 'Preview Events (${_previewSelectedUuids.length} selected)'
                    : _recordType == RecordType.narrative
                    ? 'Preview Narratives (${_previewSelectedUuids.length} selected)'
                    : _recordType == RecordType.none
                    ? 'Current Project (None)'
                    : _recordType == RecordType.specimenParts
                    ? 'Preview Specimen Parts (${_previewSelectedUuids.length} selected)'
                    : 'Preview Specimens (${_previewSelectedUuids.length} selected)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (_recordType != RecordType.none)
                OutlinedButton.icon(
                  onPressed: _selectPreviewRecords,
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
        actions: [
          if (_view == DocumentPresetView.layouts)
            PresetAppBarActions(
              onCreate: _addPreset,
              onScanQr: _scanPresetQr,
              onImport: _importPreset,
              onExportAll: _exportPresetsToFile,
              onExportSelected: _exportSelectedPreset,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Center(
                child: SegmentedButton<DocumentPresetView>(
                  segments: const [
                    ButtonSegment(
                      value: DocumentPresetView.layouts,
                      icon: Icon(Icons.view_quilt_outlined),
                      label: Text('Print layouts'),
                    ),
                    ButtonSegment(
                      value: DocumentPresetView.templates,
                      icon: Icon(Icons.dashboard_customize_outlined),
                      label: Text('Templates'),
                    ),
                    ButtonSegment(
                      value: DocumentPresetView.fonts,
                      icon: Icon(Icons.text_fields_outlined),
                      label: Text('Fonts'),
                    ),
                  ],
                  selected: {_view},
                  onSelectionChanged: (selection) {
                    setState(() => _view = selection.single);
                  },
                ),
              ),
            ),
            Expanded(
              child: _view == DocumentPresetView.fonts
                  ? const FontManager()
                  : _view == DocumentPresetView.templates
                  ? TemplatePresetManager(
                      onOpenTemplateEditor: _openTemplateEditor,
                      onRestoreBundledTemplates: _restoreBundledTemplates,
                    )
                  : _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : SafeArea(
                      child: isLargeScreen
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                      onExportPreset: (name) =>
                                          _exportLayouts(onlyName: name),
                                      tabController: _tabController,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Material(
                                        clipBehavior: Clip.hardEdge,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: BorderSide(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outlineVariant,
                                          ),
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.4),
                                        child: Column(
                                          children: [
                                            TabBar(
                                              controller:
                                                  _largeScreenTabController,
                                              tabs: const [
                                                Tab(text: 'Edit Preset'),
                                                Tab(text: 'Preview'),
                                              ],
                                            ),
                                            Expanded(
                                              child: TabBarView(
                                                controller:
                                                    _largeScreenTabController,
                                                children: [
                                                  DocumentPresetEditColumn(
                                                    selectedPresetName:
                                                        _selectedLayoutName,
                                                    layout: _layout,
                                                    templateNames:
                                                        _templateNames,
                                                    layoutStatuses:
                                                        _layoutStatuses,
                                                    onLayoutChanged:
                                                        _layoutChanged,
                                                    onSaveSetupAs:
                                                        _savePresetAs,
                                                    onCreateTemplate: () =>
                                                        _openTemplateEditor(),
                                                    onEditTemplate:
                                                        _openTemplateEditor,
                                                    onRenamePreset:
                                                        _renamePreset,
                                                  ),
                                                  previewWidget,
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
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
                                        onExportPreset: (name) =>
                                            _exportLayouts(onlyName: name),
                                        tabController: _tabController,
                                      ),
                                      DocumentPresetEditColumn(
                                        selectedPresetName: _selectedLayoutName,
                                        layout: _layout,
                                        templateNames: _templateNames,
                                        layoutStatuses: _layoutStatuses,
                                        onLayoutChanged: _layoutChanged,
                                        onSaveSetupAs: _savePresetAs,
                                        onCreateTemplate: () =>
                                            _openTemplateEditor(),
                                        onEditTemplate: _openTemplateEditor,
                                        onRenamePreset: _renamePreset,
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
      ),
    );
  }

  Future<void> _load({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = null;
      });
    }

    try {
      var statuses = await _layoutService.listLayoutStatuses();
      if (statuses.isEmpty) {
        final defaultLayout = await _layoutService.getDefaultLayout('Default');
        await _layoutService.saveLayout(defaultLayout);
        statuses = await _layoutService.listLayoutStatuses();
      }
      final names = statuses.map((status) => status.name).toList();
      final current = await _layoutService.getStoredCurrentLayoutName();
      final String selectedName = current != null && names.contains(current)
          ? current
          : names.first;
      final selectedStatus = statuses.firstWhere(
        (status) => status.name == selectedName,
      );
      final layout = selectedStatus.isCompatible
          ? await _layoutService.getLayout(selectedName)
          : null;
      final templates = await rust_config.listTemplatePresets();

      RecordType recordType = RecordType.specimenRecord;
      if (layout != null && layout.blocks.isNotEmpty) {
        final templateName = layout.blocks.first.templateName;
        final tmpl = await const TemplateService().getTemplate(templateName);
        if (tmpl != null) {
          recordType = tmpl.recordType;
        }
      }

      if (_previewSelectedUuids.isEmpty) {
        if (recordType == RecordType.site) {
          final sites = ref.read(siteEntryProvider).value ?? [];
          _previewSelectedUuids = sites
              .take(20)
              .map((e) => e.id.toString())
              .toList();
        } else if (recordType == RecordType.collEvent) {
          final events = ref.read(collEventEntryProvider).value ?? [];
          _previewSelectedUuids = events
              .take(20)
              .map((e) => e.id.toString())
              .toList();
        } else if (recordType == RecordType.narrative) {
          final narratives = ref.read(narrativeEntryProvider).value ?? [];
          _previewSelectedUuids = narratives
              .take(20)
              .map((e) => e.id.toString())
              .toList();
        } else if (recordType == RecordType.none) {
          _previewSelectedUuids = [];
        } else if (recordType == RecordType.specimenParts) {
          final parts = ref.read(specimenPartEntryProvider).value ?? [];
          _previewSelectedUuids = parts
              .take(20)
              .map((part) => part.recordId)
              .whereType<String>()
              .toList();
        } else {
          final specimens = ref.read(specimenEntryProvider).value ?? [];
          _previewSelectedUuids = specimens
              .take(20)
              .map((e) => e.uuid)
              .toList();
        }
      }

      if (!mounted) return;
      setState(() {
        _layoutStatuses = statuses;
        _selectedLayoutName = selectedName;
        _layout = layout;
        _templateNames = templates;
        _recordType = recordType;
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

  void _selectPreviewRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewRecordSelectionScreen(
          selectedUuids: _previewSelectedUuids.toSet(),
          recordType: _recordType,
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
    final oldRecordType = _recordType;
    setState(() {
      _layout = layout;
    });
    await _layoutService.saveLayout(layout);
    await _load(showLoading: false);
    if (_recordType != oldRecordType) {
      setState(() {
        _previewSelectedUuids = const [];
      });
    }
    _markPreviewStale();
  }

  Future<void> _selectLayout(String name) async {
    final status = _layoutStatuses.firstWhere((status) => status.name == name);
    final layout = status.isCompatible
        ? await _layoutService.getLayout(name)
        : null;
    if (status.isCompatible) {
      await _layoutService.setCurrentLayoutName(name);
    }
    setState(() {
      _selectedLayoutName = name;
      _layout = layout;
      _previewSelectedUuids = const [];
    });
    await _load();
    _markPreviewStale();
  }

  Future<void> _addPreset() async {
    final name = await _promptPresetName(title: 'New document preset');
    if (name == null) return;

    final templateName = _templateNames.isNotEmpty
        ? _templateNames.first
        : 'Default';
    final layout = await _layoutService.getDefaultLayout(name);
    final blocks = layout.blocks.isEmpty
        ? [
            rust_config.DocumentLayoutBlock(
              templateName: templateName,
              templateCount: 1,
              rows: 1,
              cols: 1,
              templatePadTopMm: 0,
              templatePadLeftMm: 0,
              templatePadRightMm: 0,
              templatePadBottomMm: 0,
              pageBreakAfter: false,
              sortField: null,
              sortDirection: rust_config.DocumentSortDirection.ascending,
            ),
          ]
        : layout.blocks;
    final nextLayout = layout.copyWith(name: name, blocks: blocks);

    await _layoutService.saveLayout(nextLayout);
    await _layoutService.setCurrentLayoutName(name);
    await _load();
  }

  Future<void> _renamePreset(String currentName, String newName) async {
    if (currentName == 'Default') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot rename the Default preset')),
      );
      return;
    }
    try {
      await _layoutService.renameLayout(currentName, newName);
      _selectedLayoutName = newName;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Renamed to $newName')));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rename failed: $error')));
    }
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

  Future<void> _openTemplateEditor([String? templateName]) async {
    if (templateName != null && templateName.isNotEmpty) {
      await DocumentSettingsServices().setCurrentTemplateName(templateName);
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const TemplateEditorScreen(),
      ),
    );
    await _load();
  }

  Future<void> _restoreBundledTemplates() async {
    await const BundledTemplatePresetService().restoreAll();
    final prefs = await SharedPreferences.getInstance();
    await ConfigDbService().loadDefaultDocumentPresetsOnce(prefs);
    await _load(showLoading: false);
  }

  Future<void> _exportPresetsToFile() => _exportLayouts();

  Future<void> _exportSelectedPreset() =>
      _exportLayouts(onlyName: _selectedLayoutName);

  /// Writes layouts to a JSON file.
  ///
  /// One layout and all layouts share the same name-keyed envelope, so either
  /// file imports through the same path.
  Future<void> _exportLayouts({String? onlyName}) async {
    try {
      final all = await rust_config.getAllDocumentLayouts();
      final layouts = onlyName == null
          ? all
          : all.where((layout) => layout.name == onlyName).toList();
      if (layouts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No presets to export')));
        }
        return;
      }
      final Map<String, dynamic> exportedData = {
        for (final layout in layouts) layout.name: layout.toJson(),
      };
      final dir = await FilePickerServices().selectDir();
      if (dir == null) return;
      final fileName = onlyName == null
          ? 'nahpu_document_presets.json'
          : 'preset_${_sanitizeFileStem(onlyName)}.json';
      final savePath = File(path.join(dir.path, fileName));
      await savePath.writeAsString(jsonEncode(exportedData));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${layouts.length} preset'
            '${layouts.length == 1 ? '' : 's'} to ${savePath.path}',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export presets: $e')));
      }
    }
  }

  String _sanitizeFileStem(String name) {
    final safe = name.trim().replaceAll(RegExp(r'[^\w.\-]'), '_');
    return safe.isEmpty ? 'preset' : safe;
  }

  /// Imports one layout or a name-keyed map of layouts.
  ///
  /// Layouts reference templates by name and carry no font of their own, so
  /// there is nothing to resolve here — the fonts are resolved when the
  /// templates themselves are imported.
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
    rust_config.DocumentLayoutPreset imported,
  ) async {
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

  void _scanPresetQr() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          onDetect: (barcode) {
            final rawValue = barcode.barcodes.first.rawValue;
            if (rawValue != null) {
              _importPresetFromQR(rawValue);
            }
          },
        ),
      ),
    );
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
                content: Text('Maximum of 20 presets reached. Cannot import.'),
              ),
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
    required this.tabController,
    this.onExportPreset,
  });

  final String? selectedPresetName;
  final List<rust_config.DocumentLayoutStatus> statuses;
  final ValueChanged<String>? onExportPreset;
  final ValueChanged<String> onPresetSelected;
  final ValueChanged<String> onDeletePreset;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Select Presets',
      infoTopic: InfoTopic.documentPresets,
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
                                if (status.isCompatible) ...[
                                  IconButton(
                                    icon: const Icon(Icons.qr_code),
                                    tooltip: 'Show QR',
                                    onPressed: () => _showQRCode(context, name),
                                  ),
                                  if (onExportPreset != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.file_upload_outlined,
                                      ),
                                      tooltip: 'Export this preset',
                                      onPressed: () => onExportPreset!(name),
                                    ),
                                ],
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
          child: QrImageView(data: payload, backgroundColor: Colors.white),
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
    required this.onEditTemplate,
    required this.onRenamePreset,
  });

  final String? selectedPresetName;
  final rust_config.DocumentLayoutPreset? layout;
  final List<String> templateNames;
  final List<rust_config.DocumentLayoutStatus> layoutStatuses;
  final ValueChanged<rust_config.DocumentLayoutPreset> onLayoutChanged;
  final VoidCallback onSaveSetupAs;
  final VoidCallback onCreateTemplate;
  final ValueChanged<String> onEditTemplate;
  final Future<void> Function(String, String) onRenamePreset;

  @override
  Widget build(BuildContext context) {
    if (selectedPresetName == null) {
      return const Center(child: Text('Select a preset to edit'));
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
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: _PresetNameField(
              key: ValueKey(selectedPresetName),
              presetName: selectedPresetName!,
              takenNames: layoutStatuses
                  .map((status) => status.name)
                  .where((name) => name != selectedPresetName)
                  .toSet(),
              onRename: onRenamePreset,
              onDuplicate: onSaveSetupAs,
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
                showFileActions: false,
                showProfileDropdown: false,
                showBlockOverrideToggle: false,
                showBlockOrderingImmediately: true,
                onCreateTemplate: onCreateTemplate,
                onEditTemplate: onEditTemplate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Editable name for the selected print layout preset.
///
/// The name is committed by the Rename button rather than as the user types,
/// so a rename never fires against a half-typed name.
class _PresetNameField extends StatefulWidget {
  const _PresetNameField({
    super.key,
    required this.presetName,
    required this.takenNames,
    required this.onRename,
    required this.onDuplicate,
  });

  final String presetName;
  final Set<String> takenNames;
  final Future<void> Function(String, String) onRename;
  final VoidCallback onDuplicate;

  @override
  State<_PresetNameField> createState() => _PresetNameFieldState();
}

class _PresetNameFieldState extends State<_PresetNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.presetName,
  );
  bool _renaming = false;

  @override
  void didUpdateWidget(covariant _PresetNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presetName != widget.presetName && !_isDirty) {
      _controller.text = widget.presetName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDirty => _controller.text.trim() != widget.presetName;

  String? get _error {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return 'Name cannot be empty';
    if (widget.takenNames.contains(trimmed)) {
      return 'A preset with this name already exists';
    }
    return null;
  }

  Future<void> _rename() async {
    final target = _controller.text.trim();
    setState(() => _renaming = true);
    await widget.onRename(widget.presetName, target);
    if (mounted) setState(() => _renaming = false);
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    final canRename = _isDirty && error == null && !_renaming;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Preset name',
              errorText: _isDirty ? error : null,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (canRename) _rename();
            },
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.tonal(
          onPressed: canRename ? _rename : null,
          child: const Text('Rename'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: widget.onDuplicate,
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Duplicate'),
        ),
      ],
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
        FilledButton(onPressed: _submit, child: const Text('Save')),
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

class PreviewRecordSelectionScreen extends ConsumerStatefulWidget {
  const PreviewRecordSelectionScreen({
    super.key,
    required this.selectedUuids,
    required this.onSelectionChanged,
    required this.recordType,
  });

  final Set<String> selectedUuids;
  final ValueChanged<Set<String>> onSelectionChanged;
  final RecordType recordType;

  @override
  ConsumerState<PreviewRecordSelectionScreen> createState() =>
      _PreviewRecordSelectionScreenState();
}

class _PreviewRecordSelectionScreenState
    extends ConsumerState<PreviewRecordSelectionScreen> {
  List<String> _visibleColumnIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.recordType == RecordType.specimenRecord) {
      _loadColumns();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recordType == RecordType.none) {
      return const Scaffold(
        body: Center(child: Text('No preview records for this type')),
      );
    }
    if (widget.recordType == RecordType.specimenParts) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select specimen parts for preview')),
        body: SafeArea(
          child: SpecimenPartSelectionView(
            selectedIds: widget.selectedUuids,
            onSelectionChanged: widget.onSelectionChanged,
          ),
        ),
      );
    }
    if (widget.recordType == RecordType.site) {
      return SiteSelectionScreen(
        selectedIds: widget.selectedUuids
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e != 0)
            .toSet(),
        onSelectionChanged: (selected) {
          widget.onSelectionChanged(selected.map((e) => e.toString()).toSet());
        },
      );
    } else if (widget.recordType == RecordType.collEvent) {
      return EventSelectionScreen(
        selectedIds: widget.selectedUuids
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e != 0)
            .toSet(),
        onSelectionChanged: (selected) {
          widget.onSelectionChanged(selected.map((e) => e.toString()).toSet());
        },
      );
    } else if (widget.recordType == RecordType.narrative) {
      return NarrativeSelectionScreen(
        selectedIds: widget.selectedUuids
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e != 0)
            .toSet(),
        onSelectionChanged: (selected) {
          widget.onSelectionChanged(selected.map((e) => e.toString()).toSet());
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select specimens for preview')),
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
    final visible = await const TemplateTablePreviewSettingsService()
        .getColumns(db);
    if (mounted) {
      setState(() {
        _visibleColumnIds = visible;
      });
    }
  }

  Future<void> _pickColumns() async {
    final db = ref.read(databaseProvider);
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
      final merged = await const TemplateTablePreviewSettingsService()
          .saveColumns(db: db, previousOrder: order, selectedColumns: result);
      if (!mounted) return;
      setState(() {
        _visibleColumnIds = merged;
      });
    }
  }
}
