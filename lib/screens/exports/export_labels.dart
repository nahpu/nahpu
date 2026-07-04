import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/template_page_setup_service.dart';
import 'package:nahpu/services/template_settings_services.dart';
import 'package:nahpu/services/template_service.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/exports/components/specimen_selection.dart';
import 'package:nahpu/services/export/export_label.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/screens/exports/components/label_preview_pane.dart';
import 'package:nahpu/screens/exports/components/label_settings_pane.dart';

class ExportLabelsView extends ConsumerStatefulWidget {
  const ExportLabelsView({super.key});

  @override
  ConsumerState<ExportLabelsView> createState() => _ExportLabelsViewState();
}

class _ExportLabelsViewState extends ConsumerState<ExportLabelsView>
    with TickerProviderStateMixin {
  final LabelSettingsServices _settings = LabelSettingsServices();
  final LabelPageSetupService _pageSetupService = const LabelPageSetupService();
  bool _loading = true;
  String? _error;
  bool _showPreview = false;
  bool _previewStale = false;
  int _previewVersion = 0;
  Template? _template;
  List<String> _templateNames = const [];
  String? _selectedTemplateName;
  List<String> _setupNames = const [];
  String _selectedSetupName = 'Default';
  String _pageSizeKey = 'Letter';
  String _pageOrientation = 'portrait';
  double _customPageWidthMm = 215.9;
  double _customPageHeightMm = 279.4;
  int _rowsPerPage = 8;
  int _colsPerPage = 4;
  double _pagePadTopMm = 8;
  double _pagePadLeftMm = 8;
  double _pagePadRightMm = 8;
  double _pagePadBottomMm = 8;
  double _labelPadTopMm = 1;
  double _labelPadLeftMm = 1;
  double _labelPadRightMm = 1;
  double _labelPadBottomMm = 1;

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

  void _markPreviewStale() {
    if (_showPreview && !_previewStale) {
      _previewStale = true;
    }
  }

  void _updatePreview() {
    setState(() {
      _showPreview = true;
      _previewStale = false;
      _previewVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(projectUuidProvider);
    final selectedUuids = ref.watch(labelSpecimenSelectionProvider);
    ref.listen<Set<String>>(labelSpecimenSelectionProvider, (previous, next) {
      if (previous != null && next != previous) {
        _markPreviewStale();
      }
    });
    bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    final settingsPane = LabelSettingsPane(
      templateNames: _templateNames,
      selectedTemplateName: _selectedTemplateName,
      setupNames: _setupNames,
      selectedSetupName: _selectedSetupName,
      pageSizeKey: _pageSizeKey,
      pageOrientation: _pageOrientation,
      customPageWidthMm: _customPageWidthMm,
      customPageHeightMm: _customPageHeightMm,
      rowsPerPage: _rowsPerPage,
      colsPerPage: _colsPerPage,
      pagePadTopMm: _pagePadTopMm,
      pagePadLeftMm: _pagePadLeftMm,
      pagePadRightMm: _pagePadRightMm,
      pagePadBottomMm: _pagePadBottomMm,
      labelPadTopMm: _labelPadTopMm,
      labelPadLeftMm: _labelPadLeftMm,
      labelPadRightMm: _labelPadRightMm,
      labelPadBottomMm: _labelPadBottomMm,
      exportCtr: exportCtr,
      selectedDir: _selectedDir,
      hasSaved: _hasSaved,
      isRunning: _isRunning,
      onTemplateSelected: _selectTemplate,
      onSetupSelected: _selectSetup,
      onSaveSetupAs: _saveSetupAs,
      onDeleteSetup: _deleteSetup,
      onExportSetup: _exportSetup,
      onImportSetup: _importSetup,
      onPageSizeKeyChanged: (v) async {
        setState(() {
          _pageSizeKey = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onCustomPageWidthChanged: (v) async {
        setState(() {
          _customPageWidthMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onCustomPageHeightChanged: (v) async {
        setState(() {
          _customPageHeightMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onOrientationChanged: (v) async {
        setState(() {
          _pageOrientation = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onPagePadTopChanged: (v) async {
        setState(() {
          _pagePadTopMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onPagePadLeftChanged: (v) async {
        setState(() {
          _pagePadLeftMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onPagePadRightChanged: (v) async {
        setState(() {
          _pagePadRightMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onPagePadBottomChanged: (v) async {
        setState(() {
          _pagePadBottomMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onRowsPerPageChanged: (v) async {
        setState(() {
          _rowsPerPage = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onColsPerPageChanged: (v) async {
        setState(() {
          _colsPerPage = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onLabelPadTopChanged: (v) async {
        setState(() {
          _labelPadTopMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onLabelPadLeftChanged: (v) async {
        setState(() {
          _labelPadLeftMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onLabelPadRightChanged: (v) async {
        setState(() {
          _labelPadRightMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
      onLabelPadBottomChanged: (v) async {
        setState(() {
          _labelPadBottomMm = v;
          _markPreviewStale();
        });
        await _persistCurrentSetup();
      },
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
      onExportPressed: !exportCtr.isValid ? null : _exportLabels,
      selectedCount: selectedUuids.length,
      onSelectSpecimens: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SpecimenSelectionScreen(),
          ),
        );
      },
    );

    final previewPane = LabelPreviewPane(
      showPreview: _showPreview,
      isPreviewStale: _previewStale,
      previewVersion: _previewVersion,
      template: _template,
      selectedUuidList: selectedUuids.toList(),
      rowsPerPage: _rowsPerPage,
      colsPerPage: _colsPerPage,
      pagePadTopMm: _pagePadTopMm,
      pagePadLeftMm: _pagePadLeftMm,
      pagePadRightMm: _pagePadRightMm,
      pagePadBottomMm: _pagePadBottomMm,
      labelPadTopMm: _labelPadTopMm,
      labelPadLeftMm: _labelPadLeftMm,
      labelPadRightMm: _labelPadRightMm,
      labelPadBottomMm: _labelPadBottomMm,
      customPageWidthMm: _customPageWidthMm,
      customPageHeightMm: _customPageHeightMm,
      onGeneratePreview: _updatePreview,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print labels'),
        actions: [
          IconButton(
            tooltip: 'Template editor',
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const TemplateEditorScreen(),
                ),
              );
            },
          ),
        ],
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final db = ref.read(databaseProvider);
    final setupNames = await _pageSetupService.listSetupNames();
    final currentSetupName = await _pageSetupService.getCurrentSetupName();
    final currentSetup = await _pageSetupService.getCurrentSetup();

    final templateService = const TemplateService();
    final templateNames = await templateService.listTemplateNames();
    final currentTemplateName = await _settings.getCurrentTemplateName();
    final selectedTemplateName = templateNames.contains(currentTemplateName)
        ? currentTemplateName
        : null;
    final pickedTemplate = selectedTemplateName == null
        ? null
        : await templateService.getTemplate(selectedTemplateName);

    final projectUuid = ref.read(projectUuidProvider);
    final specimenUuids =
        await SpecimenQuery(db).getAllSpecimenUuids(projectUuid);

    ref
        .read(labelSpecimenSelectionProvider.notifier)
        .updateSelection(specimenUuids.toSet());

    if (mounted) {
      setState(() {
        _template = pickedTemplate;
        _showPreview = false;
        _previewStale = false;
        _templateNames = templateNames;
        _selectedTemplateName = selectedTemplateName;
        _setupNames = setupNames;
        _selectedSetupName = currentSetupName;
        _pageSizeKey = currentSetup.pageSizeKey;
        _pageOrientation = currentSetup.pageOrientation;
        _customPageWidthMm = currentSetup.customPageWidthMm;
        _customPageHeightMm = currentSetup.customPageHeightMm;
        _rowsPerPage = currentSetup.rowsPerPage;
        _colsPerPage = currentSetup.colsPerPage;
        _pagePadTopMm = currentSetup.pagePadTopMm;
        _pagePadLeftMm = currentSetup.pagePadLeftMm;
        _pagePadRightMm = currentSetup.pagePadRightMm;
        _pagePadBottomMm = currentSetup.pagePadBottomMm;
        _labelPadTopMm = currentSetup.labelPadTopMm;
        _labelPadLeftMm = currentSetup.labelPadLeftMm;
        _labelPadRightMm = currentSetup.labelPadRightMm;
        _labelPadBottomMm = currentSetup.labelPadBottomMm;
      });
    }
    try {
      if (!mounted) return;
      setState(() {
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

  Future<void> _selectTemplate(String? name) async {
    if (name == null || name.isEmpty) return;
    final template = await const TemplateService().getTemplate(name);
    if (template == null) return;
    await _settings.setCurrentTemplateName(name);
    if (!mounted) return;
    setState(() {
      _selectedTemplateName = name;
      _template = template;
      _markPreviewStale();
    });
  }

  LabelPageSetup _currentSetup([String? name]) {
    return LabelPageSetup(
      name: name ?? _selectedSetupName,
      pageSizeKey: _pageSizeKey,
      pageOrientation: _pageOrientation,
      customPageWidthMm: _customPageWidthMm,
      customPageHeightMm: _customPageHeightMm,
      rowsPerPage: _rowsPerPage,
      colsPerPage: _colsPerPage,
      pagePadTopMm: _pagePadTopMm,
      pagePadLeftMm: _pagePadLeftMm,
      pagePadRightMm: _pagePadRightMm,
      pagePadBottomMm: _pagePadBottomMm,
      labelPadTopMm: _labelPadTopMm,
      labelPadLeftMm: _labelPadLeftMm,
      labelPadRightMm: _labelPadRightMm,
      labelPadBottomMm: _labelPadBottomMm,
    );
  }

  Future<void> _selectSetup(String name) async {
    final setup = await _pageSetupService.getSetup(name);
    if (setup == null) return;
    await _pageSetupService.setCurrentSetupName(name);
    _applySetup(setup);
  }

  void _applySetup(LabelPageSetup setup) {
    setState(() {
      _selectedSetupName = setup.name;
      _pageSizeKey = setup.pageSizeKey;
      _pageOrientation = setup.pageOrientation;
      _customPageWidthMm = setup.customPageWidthMm;
      _customPageHeightMm = setup.customPageHeightMm;
      _rowsPerPage = setup.rowsPerPage;
      _colsPerPage = setup.colsPerPage;
      _pagePadTopMm = setup.pagePadTopMm;
      _pagePadLeftMm = setup.pagePadLeftMm;
      _pagePadRightMm = setup.pagePadRightMm;
      _pagePadBottomMm = setup.pagePadBottomMm;
      _labelPadTopMm = setup.labelPadTopMm;
      _labelPadLeftMm = setup.labelPadLeftMm;
      _labelPadRightMm = setup.labelPadRightMm;
      _labelPadBottomMm = setup.labelPadBottomMm;
      _markPreviewStale();
    });
  }

  Future<void> _persistCurrentSetup() async {
    await _pageSetupService.saveSetup(_currentSetup());
    final names = await _pageSetupService.listSetupNames();
    if (!mounted) return;
    setState(() => _setupNames = names);
  }

  Future<void> _saveSetupAs() async {
    final ctrl = TextEditingController(text: _selectedSetupName);
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save page setup'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Setup name',
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
      final setup = _currentSetup(name.trim());
      await _pageSetupService.saveSetup(setup);
      await _pageSetupService.setCurrentSetupName(setup.name);
      final names = await _pageSetupService.listSetupNames();
      if (!mounted) return;
      setState(() {
        _setupNames = names;
        _selectedSetupName = setup.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved setup "${setup.name}"')),
      );
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _deleteSetup() async {
    if (_selectedSetupName == 'Default') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete Default setup')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete page setup'),
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
    await _pageSetupService.deleteSetup(_selectedSetupName);
    final names = await _pageSetupService.listSetupNames();
    final currentName = await _pageSetupService.getCurrentSetupName();
    final setup = await _pageSetupService.getCurrentSetup();
    if (!mounted) return;
    setState(() {
      _setupNames = names;
      _selectedSetupName = currentName;
    });
    _applySetup(setup);
  }

  Future<void> _exportSetup() async {
    final safe = _selectedSetupName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final location = await getSaveLocation(
      suggestedName: 'label_page_setup_$safe.json',
    );
    if (location == null) return;
    final savePath = location.path;
    final out =
        savePath.toLowerCase().endsWith('.json') ? savePath : '$savePath.json';
    await _pageSetupService.exportToPath(_currentSetup(), out);
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
    final imported = await _pageSetupService.importFromPath(filePath);
    if (imported == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid page setup file')),
      );
      return;
    }
    var setup = imported;
    final names = await _pageSetupService.listSetupNames();
    if (names.contains(setup.name)) {
      final base = setup.name;
      var i = 2;
      while (names.contains('$base $i')) {
        i++;
      }
      setup = setup.copyWith(name: '$base $i');
    }
    await _pageSetupService.saveSetup(setup);
    await _pageSetupService.setCurrentSetupName(setup.name);
    final refreshed = await _pageSetupService.listSetupNames();
    if (!mounted) return;
    setState(() {
      _setupNames = refreshed;
      _selectedSetupName = setup.name;
    });
    _applySetup(setup);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported setup "${setup.name}"')),
    );
  }

  Future<void> _exportLabels() async {
    if (!exportCtr.isValid || _selectedDir == null) {
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
      final templateService = const TemplateService();
      final currentTemplateName = await _settings.getCurrentTemplateName();
      final pickedTemplate = currentTemplateName == null
          ? null
          : await templateService.getTemplate(currentTemplateName);

      await ExportLabelService(ref: ref).exportLabels(
        selectedSpecimens: ref.read(labelSpecimenSelectionProvider),
        selectedDir: _selectedDir!,
        fileStem: exportCtr.fileNameCtr.text,
        template: pickedTemplate,
        pageSizeKey: _pageSizeKey,
        pageOrientation: _pageOrientation,
        customPageWidthMm: _customPageWidthMm,
        customPageHeightMm: _customPageHeightMm,
        rowsPerPage: _rowsPerPage,
        colsPerPage: _colsPerPage,
        pagePadTopMm: _pagePadTopMm,
        pagePadLeftMm: _pagePadLeftMm,
        pagePadRightMm: _pagePadRightMm,
        pagePadBottomMm: _pagePadBottomMm,
        labelPadTopMm: _labelPadTopMm,
        labelPadLeftMm: _labelPadLeftMm,
        labelPadRightMm: _labelPadRightMm,
        labelPadBottomMm: _labelPadBottomMm,
      );

      if (mounted) {
        setState(() {
          _hasSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved labels successfully.')),
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
