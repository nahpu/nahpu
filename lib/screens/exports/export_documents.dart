import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/document_layout_service.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/exports/components/specimen_selection.dart';
import 'package:nahpu/services/export/export_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nahpu/screens/exports/components/document_preview_pane.dart';
import 'package:nahpu/screens/exports/components/document_settings_pane.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';

class ExportDocumentsView extends ConsumerStatefulWidget {
  const ExportDocumentsView({super.key});

  @override
  ConsumerState<ExportDocumentsView> createState() =>
      _ExportDocumentsViewState();
}

class _ExportDocumentsViewState extends ConsumerState<ExportDocumentsView>
    with TickerProviderStateMixin {
  final DocumentLayoutService _layoutService = const DocumentLayoutService();
  bool _loading = true;
  String? _error;
  bool _showPreview = false;
  bool _previewStale = false;
  int _previewVersion = 0;
  rust_config.DocumentLayoutPreset? _previewLayout;
  List<String> _previewSelectedUuidList = const [];

  rust_config.DocumentLayoutPreset? _layout;
  List<String> _templateNames = const [];
  List<String> _setupNames = const [];
  String _selectedSetupName = 'Default';

  late TabController _mobileTabController;

  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  Directory? _selectedDir;
  bool _isRunning = false;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    _mobileTabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _mobileTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(projectUuidProvider);
    final selectedUuids = ref.watch(documentSpecimenSelectionProvider);
    ref.listen<Set<String>>(documentSpecimenSelectionProvider,
        (previous, next) {
      if (previous != null && next != previous) {
        _markPreviewStale();
      }
    });
    final totalCount = ref.watch(specimenEntryProvider).value?.length ?? 0;
    bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    final settingsPane = _layout == null
        ? const Center(child: CircularProgressIndicator())
        : DocumentSettingsPane(
            layout: _layout!,
            setupNames: _setupNames,
            selectedSetupName: _selectedSetupName,
            templateNames: _templateNames,
            exportCtr: exportCtr,
            selectedDir: _selectedDir,
            hasSaved: _hasSaved,
            isRunning: _isRunning,
            onLayoutChanged: _layoutChanged,
            onSetupSelected: _selectSetup,
            onSaveSetupAs: _saveSetupAs,
            onDeleteSetup: _deleteSetup,
            onExportSetup: _exportSetup,
            onImportSetup: _importSetup,
            onFileNameChanged: (v) {
              setState(() {
                _hasSaved = false;
              });
            },
            onSelectDir: () async {
              Directory? path = await FilePickerServices().selectDir();
              setState(() {
                _selectedDir = path;
              });
            },
            onClearDir: () {
              setState(() {
                _selectedDir = null;
                _hasSaved = false;
              });
            },
            onExportPressed: !exportCtr.isValid ? null : _exportDocuments,
            selectedCount: selectedUuids.length,
            totalCount: totalCount,
            onSelectSpecimens: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpecimenSelectionScreen(),
                ),
              );
            },
            onCreateTemplate: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const TemplateEditorScreen(),
                ),
              );
              _load();
            },
          );

    final previewPane = DocumentPreviewPane(
      showPreview: _showPreview,
      layout: _previewLayout,
      selectedUuidList: _previewSelectedUuidList,
      previewVersion: _previewVersion,
      isPreviewStale: _previewStale,
      onGeneratePreview: _updatePreview,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export documents'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : isLargeScreen
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: settingsPane),
                          const SizedBox(width: 16),
                          Expanded(
                            child: previewPane,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        TabBar(
                          controller: _mobileTabController,
                          tabs: const [
                            Tab(icon: Icon(Icons.settings_outlined)),
                            Tab(icon: Icon(Icons.preview_outlined)),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _mobileTabController,
                            children: [
                              settingsPane,
                              previewPane,
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  void _markPreviewStale() {
    if (_showPreview && !_previewStale) {
      setState(() {
        _setPreviewStale();
      });
    }
  }

  void _setPreviewStale() {
    if (_showPreview) {
      _previewStale = true;
    }
  }

  void _updatePreview() {
    if (_layout == null) return;
    setState(() {
      _showPreview = true;
      _previewStale = false;
      _previewLayout = _layout;
      _previewSelectedUuidList =
          List.unmodifiable(ref.read(documentSpecimenSelectionProvider));
      _previewVersion++;
    });
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final layout = await _layoutService.getCurrentLayout();
      final setupNames = await _layoutService.listLayoutNames();
      final templateNames = await rust_config.listTemplatePresets();

      if (mounted) {
        setState(() {
          _layout = layout;
          _setupNames = setupNames;
          _selectedSetupName = layout.name;
          _templateNames = templateNames;
          _showPreview = false;
          _previewStale = false;
          _previewLayout = null;
          _previewSelectedUuidList = const [];
          _loading = false;
        });
      }

      if (Platform.isAndroid || Platform.isIOS) {
        final appDocDir = await getApplicationDocumentsDirectory();
        if (mounted) {
          setState(() {
            _selectedDir = appDocDir;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _layoutChanged(
      rust_config.DocumentLayoutPreset newLayout) async {
    setState(() {
      _layout = newLayout;
      _setPreviewStale();
    });
    await _layoutService.saveLayout(newLayout);
  }

  Future<void> _selectSetup(String name) async {
    final setup = await _layoutService.getLayout(name);
    if (setup == null) return;
    await _layoutService.setCurrentLayoutName(name);
    setState(() {
      _layout = setup;
      _selectedSetupName = name;
      _setPreviewStale();
    });
  }

  Future<void> _saveSetupAs() async {
    if (_layout == null) return;
    final ctrl = TextEditingController(text: _selectedSetupName);
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save document layout'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Layout name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (name == null || name.trim().isEmpty || !mounted) return;
      final newName = name.trim();
      final newLayout = _layout!.copyWith(name: newName);
      await _layoutService.saveLayout(newLayout);
      await _layoutService.setCurrentLayoutName(newName);
      final names = await _layoutService.listLayoutNames();
      setState(() {
        _setupNames = names;
        _selectedSetupName = newName;
        _layout = newLayout;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved layout "$newName"')),
      );
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _deleteSetup() async {
    if (_selectedSetupName == 'Default') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete Default layout')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document layout'),
        content: Text('Delete "$_selectedSetupName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _layoutService.deleteLayout(_selectedSetupName);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted layout "$_selectedSetupName"')),
    );
  }

  Future<void> _exportSetup() async {
    if (_layout == null) return;
    final safe = _selectedSetupName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final location = await getSaveLocation(
      suggestedName: 'document_layout_$safe.json',
    );
    if (location == null) return;
    final savePath = location.path;
    final out =
        savePath.toLowerCase().endsWith('.json') ? savePath : '$savePath.json';

    final jsonMap = documentLayoutPresetToJson(_layout!);
    final contents = const JsonEncoder.withIndent('  ').convert(jsonMap);
    await File(out).writeAsString(contents);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved ${path.basename(out)}')),
    );
  }

  Future<void> _importSetup() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final filePath = picked?.files.single.path;
    if (filePath == null) return;

    try {
      final content = await File(filePath).readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;
      var imported = documentLayoutPresetFromJson(map);

      final names = await _layoutService.listLayoutNames();
      if (names.contains(imported.name)) {
        final base = imported.name;
        var i = 2;
        while (names.contains('$base $i')) {
          i++;
        }
        imported = imported.copyWith(name: '$base $i');
      }

      await _layoutService.saveLayout(imported);
      await _layoutService.setCurrentLayoutName(imported.name);
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported layout "${imported.name}"')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid document layout file: $e')),
      );
    }
  }

  Future<void> _exportDocuments() async {
    if (!exportCtr.isValid || _selectedDir == null || _layout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set valid file name and directory')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _hasSaved = false;
    });

    try {
      await ExportDocumentService(ref: ref).exportDocuments(
        selectedSpecimens: ref.read(documentSpecimenSelectionProvider),
        selectedDir: _selectedDir!,
        fileStem: exportCtr.fileNameCtr.text,
        layout: _layout!,
      );

      if (mounted) {
        setState(() {
          _hasSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved documents successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }
}
