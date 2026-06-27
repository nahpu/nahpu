import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/screens/print_labels/label_template_editor_screen.dart';
import 'package:nahpu/services/database/database.dart' show SpecimenData;
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/label_page_setup_service.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/label_template_service.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/specimen_services.dart';

const Map<String, String> _printPageSizeLabels = {
  'A0': 'A0 (841 x 1188 mm)',
  'A1': 'A1 (594 x 841 mm)',
  'A2': 'A2 (420 x 594 mm)',
  'A3': 'A3 (297 x 420 mm)',
  'A4': 'A4 (210 x 297 mm)',
  'A5': 'A5 (148 x 210 mm)',
  'A6': 'A6 (105 x 148 mm)',
  'A7': 'A7 (74 x 105 mm)',
  'A8': 'A8 (52 x 74 mm)',
  'Letter': 'US Letter (8.5 x 11 in)',
  'Legal': 'US Legal',
  'Custom': 'Custom',
};

const Map<String, String> _pageOrientationLabels = {
  'portrait': 'Portrait',
  'landscape': 'Landscape',
};

List<String> _mergeColumnOrder(
  List<String> previousOrder,
  Set<String> selected,
) {
  final out = <String>[];
  final sel = {...selected};
  for (final id in previousOrder) {
    if (sel.remove(id)) out.add(id);
  }
  final rest = sel.toList()
    ..sort((a, b) => specimenColumnDisplayTitle(a)
        .toLowerCase()
        .compareTo(specimenColumnDisplayTitle(b).toLowerCase()));
  out.addAll(rest);
  return out;
}

String _cellText(Map<String, String> row, String columnId) {
  if (row.containsKey(columnId)) return row[columnId]!;
  final lower = columnId.toLowerCase();
  for (final e in row.entries) {
    if (e.key.toLowerCase() == lower) return e.value;
  }
  return '';
}

class SelectSpecimensView extends ConsumerStatefulWidget {
  const SelectSpecimensView({super.key});

  @override
  ConsumerState<SelectSpecimensView> createState() =>
      _SelectSpecimensViewState();
}

class _SelectSpecimensViewState extends ConsumerState<SelectSpecimensView>
    with SingleTickerProviderStateMixin {
  List<SpecimenData> _all = [];
  Map<String, Map<String, String>> _rowValues = {};
  final Set<String> _selected = {};
  List<String> _visibleColumnIds = [];
  final LabelSettingsServices _settings = LabelSettingsServices();
  final LabelPageSetupService _pageSetupService = const LabelPageSetupService();
  bool _loading = true;
  String? _error;
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

  late TabController _tabController;

  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  Directory? _selectedDir;
  bool _isRunning = false;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final storedCols = await _settings.getPrintSpecimenTableColumnIds();
    final db = ref.read(databaseProvider);
    var visible = normalizePrintSpecimenTableColumnIds(storedCols, db);
    if (visible.isEmpty) {
      visible = normalizePrintSpecimenTableColumnIds(
        List<String>.from(kDefaultPrintSpecimenTableColumnIds),
        db,
      );
    }
    if (mounted) {
      setState(() => _visibleColumnIds = visible);
    }
    final setupNames = await _pageSetupService.listSetupNames();
    final currentSetupName = await _pageSetupService.getCurrentSetupName();
    final currentSetup = await _pageSetupService.getCurrentSetup();
    if (mounted) {
      setState(() {
        _setupNames = setupNames;
        _selectedSetupName = currentSetupName;
        _pageSizeKey =
            _printPageSizeLabels.containsKey(currentSetup.pageSizeKey)
                ? currentSetup.pageSizeKey
                : 'Letter';
        _pageOrientation =
            _pageOrientationLabels.containsKey(currentSetup.pageOrientation)
                ? currentSetup.pageOrientation
                : 'portrait';
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
      final list = await SpecimenServices(ref: ref).getSpecimenList();
      final rowVals = <String, Map<String, String>>{};
      for (final s in list) {
        rowVals[s.uuid] = await fieldValuesForSpecimen(db, s);
      }
      if (!mounted) return;
      setState(() {
        _all = list;
        _rowValues = rowVals;
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

  bool? get _headerCheckboxValue {
    if (_all.isEmpty) return false;
    final n = _all.where((s) => _selected.contains(s.uuid)).length;
    if (n == 0) return false;
    if (n == _all.length) return true;
    return null;
  }

  void _onHeaderCheckbox(bool? v) {
    setState(() {
      if (v == true) {
        _selected.addAll(_all.map((e) => e.uuid));
      } else {
        _selected.removeWhere((id) => _all.any((s) => s.uuid == id));
      }
    });
  }

  Future<void> _pickColumns() async {
    final db = ref.read(databaseProvider);
    final catalog = labelTemplateAvailableFieldIds(db)
      ..sort((a, b) => specimenColumnDisplayTitle(a)
          .toLowerCase()
          .compareTo(specimenColumnDisplayTitle(b).toLowerCase()));
    final sel = _visibleColumnIds.toSet();
    final order = List<String>.from(_visibleColumnIds);
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return AlertDialog(
              title: const Text('Table columns'),
              content: SizedBox(
                width: 420,
                height: 420,
                child: ListView(
                  children: [
                    for (final id in catalog)
                      CheckboxListTile(
                        dense: true,
                        value: sel.contains(id),
                        onChanged: (v) {
                          setModal(() {
                            if (v == true) {
                              sel.add(id);
                            } else {
                              sel.remove(id);
                            }
                          });
                        },
                        title: Text(specimenColumnDisplayTitle(id)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setModal(() {
                      sel
                        ..clear()
                        ..addAll(kDefaultPrintSpecimenTableColumnIds);
                    });
                  },
                  child: const Text('Defaults'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    var merged = _mergeColumnOrder(order, sel);
                    merged = normalizePrintSpecimenTableColumnIds(merged, db);
                    if (merged.isEmpty) {
                      merged = normalizePrintSpecimenTableColumnIds(
                        List<String>.from(kDefaultPrintSpecimenTableColumnIds),
                        db,
                      );
                    }
                    Navigator.pop(ctx, merged);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null && mounted) {
      await _settings.setPrintSpecimenTableColumnIds(result);
      setState(() => _visibleColumnIds = result);
    }
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
      _pageSizeKey = _printPageSizeLabels.containsKey(setup.pageSizeKey)
          ? setup.pageSizeKey
          : 'Letter';
      _pageOrientation =
          _pageOrientationLabels.containsKey(setup.pageOrientation)
              ? setup.pageOrientation
              : 'portrait';
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
    });
  }

  Future<void> _persistCurrentSetup() async {
    await _pageSetupService.saveSetup(_currentSetup());
    final names = await _pageSetupService.listSetupNames();
    if (!mounted) return;
    setState(() => _setupNames = names);
  }

  Future<void> _exportLabels() async {
    final picked =
        _all.where((s) => _selected.contains(s.uuid)).toList(growable: false);
    if (picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one specimen')),
      );
      return;
    }
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
      final templateService = const LabelTemplateService();
      final currentTemplateName = await _settings.getCurrentTemplateName();
      final pickedTemplate = currentTemplateName == null
          ? null
          : await templateService.getTemplate(currentTemplateName);

      await LabelWriter(ref: ref).writeLabels(
        picked: picked,
        selectedDir: _selectedDir!,
        fileStem: exportCtr.fileNameCtr.text,
        template: pickedTemplate,
        pageSizeKey: _pageSizeKey,
        pageOrientation: _pageOrientation,
        customPageWidthMm: _customPageWidthMm,
        customPageHeightMm: _customPageHeightMm,
        layout: LabelPrintLayoutOptions(
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
        ),
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

  @override
  Widget build(BuildContext context) {
    ref.watch(projectUuidProvider);
    bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    final settingsPane = _buildSettingsPane();
    final previewPane = const DocumentExportPreviewLike();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print labels'),
        actions: [
          IconButton(
            tooltip: 'Table columns',
            icon: const Icon(Icons.view_column_outlined),
            onPressed: _loading ? null : _pickColumns,
          ),
          IconButton(
            tooltip: 'Template editor',
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const LabelTemplateEditorScreen(),
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
                          Expanded(child: previewPane),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Settings'),
                            Tab(text: 'Preview'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
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

  Widget _buildSettingsPane() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FileOperationPage(
            children: [
              const FileFormatIcon(path: 'assets/icons/pdf.svg'),
              PrintLayoutSection(
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
                onSetupSelected: (name) => _selectSetup(name),
                onSaveSetupAs: () async {
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
                            onPressed: () =>
                                Navigator.pop(ctx, ctrl.text.trim()),
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
                },
                onDeleteSetup: () async {
                  if (_selectedSetupName == 'Default') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cannot delete Default setup')),
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
                  final currentName =
                      await _pageSetupService.getCurrentSetupName();
                  final setup = await _pageSetupService.getCurrentSetup();
                  if (!mounted) return;
                  setState(() {
                    _setupNames = names;
                    _selectedSetupName = currentName;
                  });
                  _applySetup(setup);
                },
                onExportSetup: () async {
                  final safe =
                      _selectedSetupName.replaceAll(RegExp(r'[^\w.\-]'), '_');
                  final location = await getSaveLocation(
                    suggestedName: 'label_page_setup_$safe.json',
                  );
                  if (location == null) return;
                  final savePath = location.path;
                  final out = savePath.toLowerCase().endsWith('.json')
                      ? savePath
                      : '$savePath.json';
                  await _pageSetupService.exportToPath(_currentSetup(), out);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved ${path.basename(out)}')),
                  );
                },
                onImportSetup: () async {
                  final picked = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );
                  final filePath = picked?.files.single.path;
                  if (filePath == null) return;
                  final imported =
                      await _pageSetupService.importFromPath(filePath);
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
                },
                onPageSizeKeyChanged: (v) async {
                  setState(() => _pageSizeKey = v);
                  await _persistCurrentSetup();
                },
                onCustomPageWidthChanged: (v) async {
                  setState(() => _customPageWidthMm = v);
                  await _persistCurrentSetup();
                },
                onCustomPageHeightChanged: (v) async {
                  setState(() => _customPageHeightMm = v);
                  await _persistCurrentSetup();
                },
                onOrientationChanged: (v) async {
                  setState(() => _pageOrientation = v);
                  await _persistCurrentSetup();
                },
                onPagePadTopChanged: (v) async {
                  setState(() => _pagePadTopMm = v);
                  await _persistCurrentSetup();
                },
                onPagePadLeftChanged: (v) async {
                  setState(() => _pagePadLeftMm = v);
                  await _persistCurrentSetup();
                },
                onPagePadRightChanged: (v) async {
                  setState(() => _pagePadRightMm = v);
                  await _persistCurrentSetup();
                },
                onPagePadBottomChanged: (v) async {
                  setState(() => _pagePadBottomMm = v);
                  await _persistCurrentSetup();
                },
                onRowsPerPageChanged: (v) async {
                  setState(() => _rowsPerPage = v);
                  await _persistCurrentSetup();
                },
                onColsPerPageChanged: (v) async {
                  setState(() => _colsPerPage = v);
                  await _persistCurrentSetup();
                },
                onLabelPadTopChanged: (v) async {
                  setState(() => _labelPadTopMm = v);
                  await _persistCurrentSetup();
                },
                onLabelPadLeftChanged: (v) async {
                  setState(() => _labelPadLeftMm = v);
                  await _persistCurrentSetup();
                },
                onLabelPadRightChanged: (v) async {
                  setState(() => _labelPadRightMm = v);
                  await _persistCurrentSetup();
                },
                onLabelPadBottomChanged: (v) async {
                  setState(() => _labelPadBottomMm = v);
                  await _persistCurrentSetup();
                },
              ),
              FileNameField(
                controller: exportCtr,
                onChanged: (v) {
                  setState(() {
                    _hasSaved = false;
                  });
                },
              ),
              SelectDirField(
                dirPath: _selectedDir,
                onPressed: () async {
                  Directory? path = await FilePickerServices().selectDir();
                  setState(() {
                    _selectedDir = path;
                  });
                },
                onCanceled: () {
                  setState(() {
                    _selectedDir = null;
                    _hasSaved = false;
                  });
                },
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 20,
                children: [
                  SaveSecondaryButton(hasSaved: _hasSaved),
                  !_hasSaved
                      ? ProgressButton(
                          label: 'Export PDF',
                          isRunning: _isRunning,
                          icon: Icons.save_alt_outlined,
                          onPressed: !exportCtr.isValid ? null : _exportLabels,
                        )
                      : Builder(
                          builder: (BuildContext context) {
                            return ShareButton(onPressed: () async {
                              // Share functionality
                            });
                          },
                        ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Select Specimens',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        dataRowMinHeight: 40,
                        columns: [
                          DataColumn(
                            label: Checkbox(
                              tristate: true,
                              value: _headerCheckboxValue,
                              onChanged: _onHeaderCheckbox,
                            ),
                          ),
                          for (final col in _visibleColumnIds)
                            DataColumn(
                              label: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 72,
                                  maxWidth: 160,
                                ),
                                child: Text(
                                  specimenColumnDisplayTitle(col),
                                  softWrap: true,
                                ),
                              ),
                            ),
                        ],
                        rows: [
                          for (final s in _all)
                            DataRow(
                              selected: _selected.contains(s.uuid),
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: _selected.contains(s.uuid),
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          _selected.add(s.uuid);
                                        } else {
                                          _selected.remove(s.uuid);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                for (final col in _visibleColumnIds)
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                      child: Text(
                                        _cellText(
                                          _rowValues[s.uuid] ?? {},
                                          col,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onSubmitted,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: TextFormField(
        key: ValueKey('$label-$initialValue'),
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onFieldSubmitted: onSubmitted,
      ),
    );
  }
}

class PrintLayoutSection extends StatelessWidget {
  const PrintLayoutSection({
    super.key,
    required this.setupNames,
    required this.selectedSetupName,
    required this.pageSizeKey,
    required this.pageOrientation,
    required this.customPageWidthMm,
    required this.customPageHeightMm,
    required this.rowsPerPage,
    required this.colsPerPage,
    required this.pagePadTopMm,
    required this.pagePadLeftMm,
    required this.pagePadRightMm,
    required this.pagePadBottomMm,
    required this.labelPadTopMm,
    required this.labelPadLeftMm,
    required this.labelPadRightMm,
    required this.labelPadBottomMm,
    required this.onSetupSelected,
    required this.onSaveSetupAs,
    required this.onDeleteSetup,
    required this.onExportSetup,
    required this.onImportSetup,
    required this.onPageSizeKeyChanged,
    required this.onCustomPageWidthChanged,
    required this.onCustomPageHeightChanged,
    required this.onOrientationChanged,
    required this.onPagePadTopChanged,
    required this.onPagePadLeftChanged,
    required this.onPagePadRightChanged,
    required this.onPagePadBottomChanged,
    required this.onRowsPerPageChanged,
    required this.onColsPerPageChanged,
    required this.onLabelPadTopChanged,
    required this.onLabelPadLeftChanged,
    required this.onLabelPadRightChanged,
    required this.onLabelPadBottomChanged,
  });

  final List<String> setupNames;
  final String selectedSetupName;
  final String pageSizeKey;
  final String pageOrientation;
  final double customPageWidthMm;
  final double customPageHeightMm;
  final int rowsPerPage;
  final int colsPerPage;
  final double pagePadTopMm;
  final double pagePadLeftMm;
  final double pagePadRightMm;
  final double pagePadBottomMm;
  final double labelPadTopMm;
  final double labelPadLeftMm;
  final double labelPadRightMm;
  final double labelPadBottomMm;

  final ValueChanged<String> onSetupSelected;
  final VoidCallback onSaveSetupAs;
  final VoidCallback onDeleteSetup;
  final VoidCallback onExportSetup;
  final VoidCallback onImportSetup;
  final ValueChanged<String> onPageSizeKeyChanged;
  final ValueChanged<double> onCustomPageWidthChanged;
  final ValueChanged<double> onCustomPageHeightChanged;
  final ValueChanged<String> onOrientationChanged;
  final ValueChanged<double> onPagePadTopChanged;
  final ValueChanged<double> onPagePadLeftChanged;
  final ValueChanged<double> onPagePadRightChanged;
  final ValueChanged<double> onPagePadBottomChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<int> onColsPerPageChanged;
  final ValueChanged<double> onLabelPadTopChanged;
  final ValueChanged<double> onLabelPadLeftChanged;
  final ValueChanged<double> onLabelPadRightChanged;
  final ValueChanged<double> onLabelPadBottomChanged;

  double _parseMmOrCurrent(String value, double current) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return current;
    return parsed.clamp(0.0, 200.0);
  }

  int _parseIntOrCurrent(String value, int current) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return current;
    return parsed.clamp(1, 200);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Print layout',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 360,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('setup-$selectedSetupName'),
                    initialValue: selectedSetupName,
                    decoration: const InputDecoration(
                      labelText: 'Page setup',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: setupNames
                        .map(
                          (n) => DropdownMenuItem<String>(
                            value: n,
                            child: Text(n),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onSetupSelected(v);
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSaveSetupAs,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
                OutlinedButton.icon(
                  onPressed: onDeleteSetup,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
                OutlinedButton.icon(
                  onPressed: onImportSetup,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Import'),
                ),
                OutlinedButton.icon(
                  onPressed: onExportSetup,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Export'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('page-size-$pageSizeKey'),
                    initialValue: pageSizeKey,
                    decoration: const InputDecoration(
                      labelText: 'Page size',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _printPageSizeLabels.entries
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onPageSizeKeyChanged(v);
                    },
                  ),
                ),
                if (pageSizeKey == 'Custom') ...[
                  NumberField(
                    label: 'Width mm',
                    initialValue: customPageWidthMm.toStringAsFixed(1),
                    onSubmitted: (value) {
                      onCustomPageWidthChanged(
                          _parseMmOrCurrent(value, customPageWidthMm));
                    },
                  ),
                  NumberField(
                    label: 'Height mm',
                    initialValue: customPageHeightMm.toStringAsFixed(1),
                    onSubmitted: (value) {
                      onCustomPageHeightChanged(
                          _parseMmOrCurrent(value, customPageHeightMm));
                    },
                  ),
                ],
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('orientation-$pageOrientation'),
                    initialValue: pageOrientation,
                    decoration: const InputDecoration(
                      labelText: 'Orientation',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _pageOrientationLabels.entries
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onOrientationChanged(v);
                    },
                  ),
                ),
                NumberField(
                  label: 'Page top',
                  initialValue: pagePadTopMm.toStringAsFixed(1),
                  onSubmitted: (value) {
                    onPagePadTopChanged(_parseMmOrCurrent(value, pagePadTopMm));
                  },
                ),
                NumberField(
                  label: 'Page left',
                  initialValue: pagePadLeftMm.toStringAsFixed(1),
                  onSubmitted: (value) {
                    onPagePadLeftChanged(
                        _parseMmOrCurrent(value, pagePadLeftMm));
                  },
                ),
                NumberField(
                  label: 'Page right',
                  initialValue: pagePadRightMm.toStringAsFixed(1),
                  onSubmitted: (value) {
                    onPagePadRightChanged(
                        _parseMmOrCurrent(value, pagePadRightMm));
                  },
                ),
                NumberField(
                  label: 'Page bottom',
                  initialValue: pagePadBottomMm.toStringAsFixed(1),
                  onSubmitted: (value) {
                    onPagePadBottomChanged(
                        _parseMmOrCurrent(value, pagePadBottomMm));
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                NumberField(
                  label: 'Rows / page',
                  initialValue: '$rowsPerPage',
                  onSubmitted: (value) {
                    onRowsPerPageChanged(
                        _parseIntOrCurrent(value, rowsPerPage));
                  },
                ),
                NumberField(
                  label: 'Cols / page',
                  initialValue: '$colsPerPage',
                  onSubmitted: (value) {
                    onColsPerPageChanged(
                        _parseIntOrCurrent(value, colsPerPage));
                  },
                ),
                NumberField(
                  label: 'Label top',
                  initialValue: labelPadTopMm.toStringAsFixed(1),
                  onSubmitted: (value) {
                    onLabelPadTopChanged(
                        _parseMmOrCurrent(value, labelPadTopMm));
                  },
                ),
                NumberField(
                  label: 'Label left',
                  initialValue: labelPadLeftMm.toStringAsFixed(1),
                  onSubmitted: (value) {
                    onLabelPadLeftChanged(
                        _parseMmOrCurrent(value, labelPadLeftMm));
                  },
                ),
                NumberField(
                  label: 'Label right',
                  initialValue: labelPadRightMm.toStringAsFixed(1),
                  onSubmitted: (value) {
                    onLabelPadRightChanged(
                        _parseMmOrCurrent(value, labelPadRightMm));
                  },
                ),
                NumberField(
                  label: 'Label bottom',
                  initialValue: labelPadBottomMm.toStringAsFixed(1),
                  onSubmitted: (value) {
                    onLabelPadBottomChanged(
                        _parseMmOrCurrent(value, labelPadBottomMm));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentExportPreviewLike extends StatelessWidget {
  const DocumentExportPreviewLike({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(16.0),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'PDF preview is not available. Please export the document to view it.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
