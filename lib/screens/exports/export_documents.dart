import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/document_layout_service.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/document/specimen_selection.dart';
import 'package:nahpu/services/export/export_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nahpu/screens/shared/document/document_preview_pane.dart';
import 'package:nahpu/screens/shared/document/document_settings_pane.dart';
import 'package:nahpu/screens/settings/document_presets.dart';

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
  File? _savePath;
  bool _isRunning = false;

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
            isRunning: _isRunning,
            onLayoutChanged: _layoutChanged,
            onSetupSelected: _selectSetup,
            onFileNameChanged: (v) {
              setState(() {
                _savePath = null;
              });
            },
            onSelectDir: () async {
              Directory? path = await FilePickerServices().selectDir();
              setState(() {
                _selectedDir = path;
                _savePath = null;
              });
            },
            onClearDir: () {
              setState(() {
                _selectedDir = null;
                _savePath = null;
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
            onManagePresets: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const DocumentPresetsScreen(),
                ),
              );
              await _load();
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


  Future<void> _exportDocuments() async {
    if (!exportCtr.isValid || _selectedDir == null || _layout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set valid file name and directory')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _savePath = null;
    });

    try {
      final savePath = await ExportDocumentService(ref: ref).exportDocuments(
        selectedSpecimens: ref.read(documentSpecimenSelectionProvider),
        selectedDir: _selectedDir!,
        fileStem: exportCtr.fileNameCtr.text,
        layout: _layout!,
      );

      if (mounted) {
        setState(() {
          _savePath = savePath;
        });
        _showSavedPath();
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

  void _showSavedPath() {
    final savePath = _savePath;
    if (!context.mounted || savePath == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          systemPlatform == PlatformType.desktop
              ? 'Document saved to ${savePath.path}'
              : 'Document saved!',
        ),
      ),
    );
  }
}
