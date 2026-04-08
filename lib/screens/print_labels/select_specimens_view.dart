import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/print_labels/label_pdf_service.dart';
import 'package:nahpu/screens/print_labels/label_template_editor_screen.dart';
import 'package:nahpu/screens/print_labels/pdf_preview_screen.dart';
import 'package:nahpu/services/database/database.dart' show SpecimenData;
import 'package:nahpu/services/label_page_setup_service.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/label_template_service.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:pdf/pdf.dart';
import 'package:path/path.dart' as path;

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

PdfPageFormat _pageFormatFromKey(
  String key, {
  required double customWidthMm,
  required double customHeightMm,
}) {
  switch (key) {
    case 'A0':
      return PdfPageFormat(841 * PdfPageFormat.mm, 1188 * PdfPageFormat.mm);
    case 'A1':
      return PdfPageFormat(594 * PdfPageFormat.mm, 841 * PdfPageFormat.mm);
    case 'A2':
      return PdfPageFormat(420 * PdfPageFormat.mm, 594 * PdfPageFormat.mm);
    case 'A3':
      return PdfPageFormat.a3;
    case 'Letter':
      return PdfPageFormat.letter;
    case 'A5':
      return PdfPageFormat.a5;
    case 'A6':
      return PdfPageFormat.a6;
    case 'A7':
      return PdfPageFormat(74 * PdfPageFormat.mm, 105 * PdfPageFormat.mm);
    case 'A8':
      return PdfPageFormat(52 * PdfPageFormat.mm, 74 * PdfPageFormat.mm);
    case 'Legal':
      return PdfPageFormat.legal;
    case 'Custom':
      return PdfPageFormat(
        customWidthMm.clamp(40.0, 1200.0) * PdfPageFormat.mm,
        customHeightMm.clamp(40.0, 1200.0) * PdfPageFormat.mm,
      );
    case 'A4':
    default:
      return PdfPageFormat.a4;
  }
}

PdfPageFormat _applyPageOrientation(PdfPageFormat format, String orientation) {
  if (orientation == 'landscape') {
    return PdfPageFormat(
      format.height,
      format.width,
      marginLeft: format.marginLeft,
      marginTop: format.marginTop,
      marginRight: format.marginRight,
      marginBottom: format.marginBottom,
    );
  }
  return format;
}

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

class _SelectSpecimensViewState extends ConsumerState<SelectSpecimensView> {
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
  bool _showPageSetup = false;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _selectSetup(String name) async {
    final setup = await _pageSetupService.getSetup(name);
    if (setup == null) return;
    await _pageSetupService.setCurrentSetupName(name);
    _applySetup(setup);
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

  Future<void> _deleteCurrentSetup() async {
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

  Future<void> _exportCurrentSetup() async {
    final safe = _selectedSetupName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export page setup',
      fileName: 'label_page_setup_$safe.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (savePath == null) return;
    final out =
        savePath.toLowerCase().endsWith('.json') ? savePath : '$savePath.json';
    await _pageSetupService.exportToPath(_currentSetup(), out);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved ${path.basename(out)}')),
    );
  }

  Future<void> _importSetup() async {
    final picked = await FilePicker.platform.pickFiles(
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

  Widget _numberField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onSubmitted,
  }) {
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

  Widget _buildPrintLayoutSection() {
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
                    key: ValueKey('setup-$_selectedSetupName'),
                    initialValue: _selectedSetupName,
                    decoration: const InputDecoration(
                      labelText: 'Page setup',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _setupNames
                        .map(
                          (n) => DropdownMenuItem<String>(
                            value: n,
                            child: Text(n),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      await _selectSetup(v);
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _saveSetupAs,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
                OutlinedButton.icon(
                  onPressed: _deleteCurrentSetup,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
                OutlinedButton.icon(
                  onPressed: _importSetup,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Import'),
                ),
                OutlinedButton.icon(
                  onPressed: _exportCurrentSetup,
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
                    key: ValueKey('page-size-$_pageSizeKey'),
                    initialValue: _pageSizeKey,
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
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() => _pageSizeKey = v);
                      await _persistCurrentSetup();
                    },
                  ),
                ),
                if (_pageSizeKey == 'Custom') ...[
                  _numberField(
                    label: 'Width mm',
                    initialValue: _customPageWidthMm.toStringAsFixed(1),
                    onSubmitted: (value) async {
                      final next = _parseMmOrCurrent(value, _customPageWidthMm);
                      setState(() => _customPageWidthMm = next);
                      await _persistCurrentSetup();
                    },
                  ),
                  _numberField(
                    label: 'Height mm',
                    initialValue: _customPageHeightMm.toStringAsFixed(1),
                    onSubmitted: (value) async {
                      final next =
                          _parseMmOrCurrent(value, _customPageHeightMm);
                      setState(() => _customPageHeightMm = next);
                      await _persistCurrentSetup();
                    },
                  ),
                ],
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('orientation-$_pageOrientation'),
                    initialValue: _pageOrientation,
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
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() => _pageOrientation = v);
                      await _persistCurrentSetup();
                    },
                  ),
                ),
                _numberField(
                  label: 'Page top',
                  initialValue: _pagePadTopMm.toStringAsFixed(1),
                  onSubmitted: (value) async {
                    final next = _parseMmOrCurrent(value, _pagePadTopMm);
                    setState(() => _pagePadTopMm = next);
                    await _persistCurrentSetup();
                  },
                ),
                _numberField(
                  label: 'Page left',
                  initialValue: _pagePadLeftMm.toStringAsFixed(1),
                  onSubmitted: (value) async {
                    final next = _parseMmOrCurrent(value, _pagePadLeftMm);
                    setState(() => _pagePadLeftMm = next);
                    await _persistCurrentSetup();
                  },
                ),
                _numberField(
                  label: 'Page right',
                  initialValue: _pagePadRightMm.toStringAsFixed(1),
                  onSubmitted: (value) async {
                    final next = _parseMmOrCurrent(value, _pagePadRightMm);
                    setState(() => _pagePadRightMm = next);
                    await _persistCurrentSetup();
                  },
                ),
                _numberField(
                  label: 'Page bottom',
                  initialValue: _pagePadBottomMm.toStringAsFixed(1),
                  onSubmitted: (value) async {
                    final next = _parseMmOrCurrent(value, _pagePadBottomMm);
                    setState(() => _pagePadBottomMm = next);
                    await _persistCurrentSetup();
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
                _numberField(
                  label: 'Rows / page',
                  initialValue: '$_rowsPerPage',
                  onSubmitted: (value) async {
                    final next = _parseIntOrCurrent(value, _rowsPerPage);
                    setState(() => _rowsPerPage = next);
                    await _persistCurrentSetup();
                  },
                ),
                _numberField(
                  label: 'Cols / page',
                  initialValue: '$_colsPerPage',
                  onSubmitted: (value) async {
                    final next = _parseIntOrCurrent(value, _colsPerPage);
                    setState(() => _colsPerPage = next);
                    await _persistCurrentSetup();
                  },
                ),
                _numberField(
                  label: 'Label top',
                  initialValue: _labelPadTopMm.toStringAsFixed(1),
                  onSubmitted: (value) async {
                    final next = _parseMmOrCurrent(value, _labelPadTopMm);
                    setState(() => _labelPadTopMm = next);
                    await _persistCurrentSetup();
                  },
                ),
                _numberField(
                  label: 'Label left',
                  initialValue: _labelPadLeftMm.toStringAsFixed(1),
                  onSubmitted: (value) async {
                    final next = _parseMmOrCurrent(value, _labelPadLeftMm);
                    setState(() => _labelPadLeftMm = next);
                    await _persistCurrentSetup();
                  },
                ),
                _numberField(
                  label: 'Label right',
                  initialValue: _labelPadRightMm.toStringAsFixed(1),
                  onSubmitted: (value) async {
                    final next = _parseMmOrCurrent(value, _labelPadRightMm);
                    setState(() => _labelPadRightMm = next);
                    await _persistCurrentSetup();
                  },
                ),
                _numberField(
                  label: 'Label bottom',
                  initialValue: _labelPadBottomMm.toStringAsFixed(1),
                  onSubmitted: (value) async {
                    final next = _parseMmOrCurrent(value, _labelPadBottomMm);
                    setState(() => _labelPadBottomMm = next);
                    await _persistCurrentSetup();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _print() async {
    final picked =
        _all.where((s) => _selected.contains(s.uuid)).toList(growable: false);
    if (picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one specimen')),
      );
      return;
    }
    final nav = Navigator.of(context);
    final templateService = const LabelTemplateService();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      if (!mounted) return;
      nav.pop();
      final templateNames = await templateService.listTemplateNames();
      final currentTemplateName = await _settings.getCurrentTemplateName();
      await nav.push<void>(
        MaterialPageRoute<void>(
          builder: (context) => PdfPreviewScreen(
            pdfBuilder: (_, templateName) async {
              final pickedTemplate = templateName == null
                  ? null
                  : await templateService.getTemplate(templateName);
              return LabelPdfService(ref: ref).generateLabelsPdf(
                picked,
                template: pickedTemplate,
                sheetFormat: _applyPageOrientation(
                  _pageFormatFromKey(
                    _pageSizeKey,
                    customWidthMm: _customPageWidthMm,
                    customHeightMm: _customPageHeightMm,
                  ),
                  _pageOrientation,
                ),
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
            },
            title: 'Labels (${picked.length})',
            canChangePageFormat: false,
            canCustomizePageSize: false,
            templateNames: templateNames,
            initialTemplateName: currentTemplateName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) nav.pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(projectUuidProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print labels'),
        actions: [
          IconButton(
            tooltip: _showPageSetup ? 'Hide page setup' : 'Show page setup',
            icon: Icon(
              _showPageSetup ? Icons.tune_outlined : Icons.tune,
            ),
            onPressed: () {
              setState(() => _showPageSetup = !_showPageSetup);
            },
          ),
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
      floatingActionButton: _loading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _selected.isEmpty ? null : _print,
              backgroundColor: _selected.isEmpty
                  ? colorScheme.surfaceContainerHighest
                  : null,
              foregroundColor: _selected.isEmpty
                  ? colorScheme.onSurface.withValues(alpha: 0.38)
                  : null,
              icon: const Icon(Icons.print),
              label: const Text('Print'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    if (_showPageSetup) _buildPrintLayoutSection(),
                    Expanded(
                      child: LayoutBuilder(
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
                    ),
                  ],
                ),
    );
  }
}
