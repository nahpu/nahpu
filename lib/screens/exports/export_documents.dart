import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/templates/document_layout_service.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/export/export_document.dart';
import 'package:nahpu/services/export/export_destination.dart';
import 'package:nahpu/screens/shared/document/document_preview_pane.dart';
import 'package:nahpu/screens/shared/document/document_settings_pane.dart';
import 'package:nahpu/screens/settings/presets/document_presets.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/services/templates/template_settings_services.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';
import 'package:nahpu/screens/shared/dialogs/load_defaults_dialog.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';

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
  String? _selectedSetupName;
  RecordType _recordType = RecordType.specimenRecord;

  late TabController _mobileTabController;

  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  final ExportDestinationService _destination = ExportDestinationService();
  Directory? _selectedDir;
  File? _savePath;
  bool _isRunning = false;
  bool _appendDate = false;

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

    final isLargeScreen =
        MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;

    final settingsPane = _layout == null
        ? const Center(child: CircularProgressIndicator())
        : DocumentSettingsPane(
            layout: _layout!,
            setupNames: _setupNames,
            selectedSetupName: _selectedSetupName ?? _layout!.name,
            templateNames: _templateNames,
            exportCtr: exportCtr,
            isRunning: _isRunning,
            appendDate: _appendDate,
            onLayoutChanged: _layoutChanged,
            onSetupSelected: _selectSetup,
            onFileNameChanged: (v) {
              setState(() {
                _savePath = null;
              });
            },
            onAppendDateChanged: (value) {
              setState(() {
                _appendDate = value;
                _savePath = null;
              });
            },
            locationCard: ExportLocationCard(
              selectedDir: _selectedDir,
              output: _savePath,
              enabled: !_isRunning,
              onSelectDir: _selectDirectory,
              onClearDir: _clearDestination,
              onShare: _shareExport,
              onOpenFolder: _openFolder,
              onSaveCopy: _saveCopy,
              onDismiss: _clearDestination,
            ),
            onManagePresets: _managePresets,
            onEditTemplate: _openTemplateEditor,
            recordType: _recordType,
            showSpecimenSelection: true,
          );

    final previewPane = DocumentPreviewPane(
      showPreview: _showPreview,
      layout: _previewLayout,
      selectedUuidList: _previewSelectedUuidList,
      previewVersion: _previewVersion,
      isPreviewStale: _previewStale,
      onGeneratePreview: _updatePreview,
      isBlockSelection: true,
    );

    final body = isLargeScreen
        ? Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: settingsPane),
                const SizedBox(width: 16),
                Expanded(child: previewPane),
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
                  children: [settingsPane, previewPane],
                ),
              ),
            ],
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Export documents')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _layout == null
          ? SafeArea(
              child: PresetEmptyState(
                message:
                    'No print layouts yet. Load the default layouts, or create '
                    'one in Document Presets.',
                onLoadDefaults: _loadDefaults,
                secondaryLabel: 'Manage presets',
                secondaryIcon: Icons.tune_outlined,
                onSecondary: _managePresets,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(child: body),
                  ExportActionBar(
                    label: 'Export documents',
                    repeatLabel: 'Export another',
                    icon: Icons.picture_as_pdf_outlined,
                    canExport: exportCtr.isValid,
                    isRunning: _isRunning,
                    hasOutput: _savePath != null,
                    onExport: _exportDocuments,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _managePresets() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const DocumentPresetsScreen(),
      ),
    );
    await _load();
  }

  /// Lets the user pick bundled generic layouts; their templates come along.
  Future<void> _loadDefaults() async {
    final result = await showLoadDefaultsDialog(
      context: context,
      kinds: const {BundledPresetKind.document},
    );
    if (result == null) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
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
    if (!_destination.canChooseDirectory) return;
    final path = await FilePickerServices().selectDir();
    if (path == null || !mounted) return;
    setState(() {
      _selectedDir = path;
      _savePath = null;
    });
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
      _previewSelectedUuidList = const [];
      _previewVersion++;
    });
  }

  Future<RecordType> _getRecordTypeForLayout(
    rust_config.DocumentLayoutPreset? layout,
  ) async {
    if (layout == null || layout.blocks.isEmpty) {
      return RecordType.specimenRecord;
    }
    final firstTemplateName = layout.blocks.first.templateName;
    final tmpl = await const TemplateService().getTemplate(firstTemplateName);
    return tmpl?.recordType ?? RecordType.specimenRecord;
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
      final recordType = await _getRecordTypeForLayout(layout);

      if (mounted) {
        setState(() {
          _layout = layout;
          _setupNames = setupNames;
          _selectedSetupName = layout?.name;
          _templateNames = templateNames;
          _recordType = recordType;
          _showPreview = false;
          _previewStale = false;
          _previewLayout = null;
          _previewSelectedUuidList = const [];
          _savePath = null;
          _loading = false;
        });
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
    rust_config.DocumentLayoutPreset newLayout,
  ) async {
    final recordType = await _getRecordTypeForLayout(newLayout);
    setState(() {
      _layout = newLayout;
      _recordType = recordType;
      _savePath = null;
      _setPreviewStale();
    });
    await _layoutService.saveLayout(newLayout);
  }

  Future<void> _selectSetup(String name) async {
    final setup = await _layoutService.getLayout(name);
    if (setup == null) return;
    await _layoutService.setCurrentLayoutName(name);
    final recordType = await _getRecordTypeForLayout(setup);
    setState(() {
      _layout = setup;
      _selectedSetupName = name;
      _recordType = recordType;
      _savePath = null;
      _setPreviewStale();
    });
  }

  Future<void> _openTemplateEditor(String templateName) async {
    if (templateName.isNotEmpty) {
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

  Future<void> _exportDocuments() async {
    // No directory is a valid state: the export then lands in NAHPU app
    // storage, which is the only option on iOS and the fallback elsewhere.
    // Requiring one here left the enabled button silently doing nothing once
    // the destination had been cleared.
    if (!exportCtr.isValid || _layout == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a file name first.')));
      return;
    }

    setState(() {
      _isRunning = true;
      _savePath = null;
    });

    try {
      final savePath = await ExportDocumentService(ref: ref).exportDocuments(
        selectedDir: await _destination.resolve(_selectedDir),
        fileStem: _appendDate
            ? appendDateToFileStem(exportCtr.fileNameCtr.text, DateTime.now())
            : exportCtr.fileNameCtr.text,
        layout: _layout!,
      );

      if (mounted) {
        setState(() {
          _savePath = savePath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
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

  /// Hands the finished file to the system "Save to..." dialog.
  ///
  /// How Android reaches the Files app: its share sheet only lists
  /// apps that accept a file, never a folder to drop one into.
  Future<void> _saveCopy() async {
    final savePath = _savePath;
    if (savePath == null) return;
    try {
      await FilePickerServices().saveCopyToDevice(savePath);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save a copy: $error')),
        );
      }
    }
  }

  Future<void> _shareExport() async {
    final savePath = _savePath;
    if (savePath == null) return;
    try {
      await FilePickerServices().shareFile(context, savePath);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to share export: $error')),
        );
      }
    }
  }
}
