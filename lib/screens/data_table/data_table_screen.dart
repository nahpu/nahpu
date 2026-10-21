import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_dialogs.dart';
import 'package:nahpu/screens/data_table/components/data_table_edit_toolbar.dart';
import 'package:nahpu/screens/data_table/components/data_table_filters.dart';
import 'package:nahpu/screens/data_table/components/data_table_grid.dart';
import 'package:nahpu/screens/data_table/components/data_table_link_dialogs.dart';
import 'package:nahpu/screens/data_table/components/data_table_pagination.dart';
import 'package:nahpu/screens/data_table/components/data_table_toolbar.dart';
import 'package:nahpu/screens/events/event_view.dart';
import 'package:nahpu/screens/narrative/narrative_view.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/data_table/data_table_edits.dart';
import 'package:nahpu/services/database/app_exit.dart';
import 'package:nahpu/services/data_table/data_table_grid_controller.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/data_table.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Spreadsheet view of project records, one page at a time.
///
/// Columns are the fields of the matching tabular export. In edit mode,
/// plain fields can be changed; edits wait for Save, or save as they are
/// committed when auto-save is on.
class DataTableScreen extends ConsumerStatefulWidget {
  const DataTableScreen({
    super.key,
    this.initialType = DataTableRecordType.specimenRecords,
    this.initialScope,
  });

  final DataTableRecordType initialType;

  /// Opens the table limited to these records of [initialType].
  final DataTableKeyScope? initialScope;

  @override
  DataTableScreenState createState() => DataTableScreenState();
}

class DataTableScreenState extends ConsumerState<DataTableScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode(debugLabel: 'data table search');
  final _grid = DataTableGridController();
  late final DataTableEditController _edits;
  late final AppLifecycleListener _lifecycle;
  late final VoidCallback _removeExitGuard;
  final Map<DataTableRecordType, Set<String>> _visibleColumns = {};
  Timer? _searchDebounce;
  int _request = 0;

  late DataTableRecordType _type = widget.initialType;
  late DataTableKeyScope? _scope = widget.initialScope;
  SpecimenRecordType _specimenType = SpecimenRecordType.allTaxa;
  String? _searchField;
  List<DataTableFilterRule> _rules = const [];
  Set<DataTableQuickFilter> _quickFilters = const {};
  DataTableSort? _sort;
  int _page = 0;
  int _rowsPerPage = dataTableRowsPerPageOptions[1];
  bool _isEditMode = false;

  DataTablePageData? _data;
  bool _isLoading = false;
  Object? _error;

  /// Row to focus once the next page arrives: 0 after paging forward, -1
  /// for the last row after paging back.
  int? _focusRowAfterLoad;

  @override
  void initState() {
    super.initState();
    _edits = DataTableEditController(
      saver: _saveEdits,
      initialAutoSave: ref.read(dataTableAutoSaveProvider),
    );
    // Queued auto-saves go out before the app is backgrounded or closed.
    _lifecycle = AppLifecycleListener(onInactive: _edits.flush);
    // Quitting the app asks about unsaved edits, as leaving the screen does,
    // before the database closes.
    _removeExitGuard = ref
        .read(appExitCoordinatorProvider)
        .addGuard(_resolveUnsaved);
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _lifecycle.dispose();
    _removeExitGuard();
    _edits.dispose();
    _grid.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final columns = data == null
        ? const <DataTableColumn>[]
        : _shown(data.columns);
    return ListenableBuilder(
      listenable: _edits,
      builder: (context, child) => PopScope(
        canPop: !_edits.hasPending,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final canLeave = await _resolveUnsaved();
          if (canLeave && context.mounted) Navigator.of(context).pop();
        },
        child: child!,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Data table'),
          actions: [
            IconButton(
              tooltip: 'Reload records',
              icon: const Icon(Icons.refresh),
              onPressed: _load,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(NahpuSpacing.md),
                child: DataTableToolbar(
                  type: _type,
                  specimenType: _specimenType,
                  searchController: _searchController,
                  searchFocusNode: _searchFocus,
                  searchField: _columnFor(_searchField),
                  searchableColumns: [
                    for (final column
                        in data?.columns ?? const <DataTableColumn>[])
                      if (column.field.isFilterable) column,
                  ],
                  quickFilters: _quickFilters,
                  ruleCount: _rules.length,
                  onTypeChanged: _setType,
                  onSpecimenTypeChanged: _setSpecimenType,
                  onSearchChanged: _onSearchChanged,
                  onSearchFieldChanged: (column) =>
                      _update(() => _searchField = column?.key),
                  onQuickFilterToggled: _toggleQuickFilter,
                  onEditRules: data == null ? null : _editRules,
                  onPickColumns: data == null ? null : _pickColumns,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NahpuSpacing.md,
                  0,
                  NahpuSpacing.md,
                  NahpuSpacing.md,
                ),
                // Edit controls first, then any active filters.
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DataTableEditToolbar(
                        isEditMode: _isEditMode,
                        edits: _edits,
                        onModeChanged: _setEditMode,
                        onAutoSaveChanged: _setAutoSave,
                        onSave: _save,
                        onDiscard: _edits.discard,
                      ),
                      if (_quickFilters.isNotEmpty ||
                          _rules.isNotEmpty ||
                          _scope != null) ...[
                        const DataTableToolbarDivider(),
                        DataTableFilterChips(
                          scope: _scope,
                          onScopeRemoved: () => _update(() => _scope = null),
                          selected: _quickFilters,
                          rules: _rules,
                          columns: data?.columns ?? const [],
                          onToggled: _toggleQuickFilter,
                          onRuleRemoved: (index) => _update(
                            () => _rules = [..._rules]..removeAt(index),
                          ),
                          onCleared: () => _update(() {
                            _rules = const [];
                            _quickFilters = const {};
                            _scope = null;
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: NahpuStroke.regular,
                child: _isLoading ? const LinearProgressIndicator() : null,
              ),
              const Divider(height: NahpuStroke.thin),
              Expanded(child: _content(data, columns)),
              const Divider(height: NahpuStroke.thin),
              DataTablePaginationBar(
                page: data,
                rowsPerPage: _rowsPerPage,
                onPageChanged: _goToPage,
                onRowsPerPageChanged: (value) => _update(() {
                  _rowsPerPage = value;
                  _page = 0;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(DataTablePageData? data, List<DataTableColumn> columns) {
    if (_error != null) {
      return DataTableMessage(
        icon: Icons.error_outline,
        message: _errorMessage(_error!),
        actionLabel: 'Retry',
        onAction: _load,
      );
    }
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data.rows.isEmpty) {
      final isFiltered =
          _searchController.text.trim().isNotEmpty ||
          _rules.isNotEmpty ||
          _quickFilters.isNotEmpty ||
          _scope != null;
      final taxa =
          _type == DataTableRecordType.specimenRecords &&
              _specimenType != SpecimenRecordType.allTaxa
          ? _specimenType.dataTableLabel.toLowerCase()
          : null;
      final records = _type.label.toLowerCase();
      return DataTableMessage(
        icon: isFiltered ? Icons.search_off : Icons.table_rows_outlined,
        message: isFiltered
            ? 'No $records match your search and filters.'
            : taxa != null
            ? 'This project has no $records for $taxa.'
            : 'This project has no $records yet.',
      );
    }
    return DataTableGrid(
      type: _type,
      page: data,
      columns: columns,
      sort: _sort,
      isEditMode: _isEditMode,
      grid: _grid,
      edits: _edits,
      onSort: _setSort,
      onRequestPage: _turnPage,
      onSave: _save,
      onFocusSearch: _searchFocus.requestFocus,
      onMessage: _showMessage,
      onToggleEditMode: () => _setEditMode(!_isEditMode),
      onOpenLinked: _openLinked,
      onOpenRecord: _openRecord,
    );
  }

  /// Opens the record's form over the table. The table keeps its place and
  /// reloads when the form closes, to show any changes made there.
  Future<void> _openRecord(DataTableRecordRow row) async {
    if (!await _resolveUnsaved() || !mounted) return;
    final key = row.key;
    final Widget? form = switch (_type) {
      DataTableRecordType.specimenRecords ||
      DataTableRecordType.specimenParts => switch (row.specimenUuid) {
        final String uuid => SpecimenFormView(specimenUuid: uuid),
        null => null,
      },
      DataTableRecordType.sites => SiteFormView(siteId: key as int),
      DataTableRecordType.events => CollEventFormView(eventId: key as int),
      DataTableRecordType.narrative => NarrativeFormView(
        narrativeId: key as int,
      ),
    };
    if (form == null) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => form));
    if (!mounted) return;
    _invalidateRecordLists();
    _load();
  }

  Future<void> _openLinked(
    DataTableRecordRow row,
    DataTableColumn column,
  ) async {
    final link = column.linkIn(_type);
    if (link == null) return;
    final saved = await showDataTableLinkDialog(
      context,
      type: _type,
      row: row,
      column: column,
      link: link,
    );
    if (!saved || !mounted) return;
    _showMessage('Saved.');
    _invalidateRecordLists();
    _load();
  }

  /// Other screens list the records this table changed; refresh them.
  void _invalidateRecordLists() {
    ref
      ..invalidate(specimenEntryProvider)
      ..invalidate(specimenPartEntryProvider)
      ..invalidate(siteEntryProvider)
      ..invalidate(collEventEntryProvider)
      ..invalidate(narrativeEntryProvider);
  }

  String _errorMessage(Object error) => switch (error) {
    FormatException(:final message) => message,
    _ => 'Couldn\'t load ${_type.label.toLowerCase()}.',
  };

  DataTableColumn? _columnFor(String? key) {
    if (key == null) return null;
    for (final column in _data?.columns ?? const <DataTableColumn>[]) {
      if (column.key == key) return column;
    }
    return null;
  }

  List<DataTableColumn> _shown(List<DataTableColumn> columns) {
    final chosen = _visibleColumns[_type];
    final shown = chosen == null
        ? const <DataTableColumn>[]
        : columns.where((column) => chosen.contains(column.key)).toList();
    if (shown.isNotEmpty) return shown;
    // Nothing chosen yet, or the choice has no field in this export (another
    // taxon group): fall back to the defaults.
    final defaults = defaultDataTableColumnKeys(_type, columns);
    return columns.where((column) => defaults.contains(column.key)).toList();
  }

  List<String> get _visibleKeys {
    final data = _data;
    if (data != null) return _shown(data.columns).map((c) => c.key).toList();
    return _visibleColumns[_type]?.toList() ?? _type.defaultColumnKeys;
  }

  DataTableQuery get _query => DataTableQuery(
    search: _searchController.text,
    searchField: _searchField,
    searchKeys: _visibleKeys,
    rules: _rules,
    quickFilters: _quickFilters,
    sort: _sort,
    page: _page,
    rowsPerPage: _rowsPerPage,
    scope: _scope,
  );

  /// Fetches the current page. Earlier data stays on screen while it
  /// loads, so saving or paging doesn't flash the table.
  Future<void> _load() async {
    final request = ++_request;
    setState(() => _isLoading = true);
    try {
      final data = await ref.read(dataTablePageLoaderProvider)(
        ref,
        _type,
        _query,
        _specimenType,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _data = data;
        _page = data.page;
        _error = null;
        _isLoading = false;
      });
      _edits.resetStored();
      final focusRow = _focusRowAfterLoad;
      _focusRowAfterLoad = null;
      if (focusRow != null && data.rows.isNotEmpty) {
        _grid.setSize(data.rows.length, _shown(data.columns).length);
        _grid.moveTo(
          focusRow < 0 ? data.rows.length - 1 : focusRow,
          _grid.focus.col,
        );
      }
    } catch (e) {
      if (!mounted || request != _request) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  /// Applies a change to what is shown and reloads from the first page.
  void _update(VoidCallback change, {bool keepPage = false}) {
    setState(() {
      change();
      if (!keepPage) _page = 0;
    });
    _load();
  }

  Future<DataTableSaveResult> _saveEdits(List<DataTableEdit> edits) async {
    final result = await ref.read(dataTableEditSaverProvider)(
      ref,
      _type,
      edits,
    );
    if (result.saved.isNotEmpty && mounted) unawaited(_load());
    return result;
  }

  Future<void> _save() async {
    await _edits.save();
    if (mounted && _edits.failedCount > 0) {
      _showMessage('Some changes couldn\'t be saved. Check the marked cells.');
    }
  }

  /// Lets the user save or discard pending edits before they are left
  /// behind. Returns whether it is fine to go on.
  Future<bool> _resolveUnsaved() async {
    await _edits.flush();
    if (!_edits.hasPending || !mounted) return true;
    final choice = await showDialog<DataTableUnsavedChoice>(
      context: context,
      builder: (context) => DataTableUnsavedDialog(count: _edits.pendingCount),
    );
    switch (choice) {
      case DataTableUnsavedChoice.save:
        await _save();
        return !_edits.hasPending;
      case DataTableUnsavedChoice.discard:
        _edits.discard();
        return true;
      case DataTableUnsavedChoice.cancel:
      case null:
        return false;
    }
  }

  Future<void> _setType(DataTableRecordType type) async {
    if (type == _type || !await _resolveUnsaved()) return;
    _searchController.clear();
    _grid.moveTo(0, 0);
    _update(() {
      _type = type;
      _sort = null;
      _searchField = null;
      _rules = const [];
      _quickFilters = const {};
      // Scoped keys belong to the type they were picked for.
      _scope = null;
      _data = null;
    });
  }

  Future<void> _setSpecimenType(SpecimenRecordType type) async {
    if (type == _specimenType || !await _resolveUnsaved()) return;
    _update(() => _specimenType = type);
  }

  Future<void> _setEditMode(bool isEditMode) async {
    if (!isEditMode && !await _resolveUnsaved()) return;
    _grid.endEdit();
    setState(() => _isEditMode = isEditMode);
  }

  Future<void> _setAutoSave(bool value) async {
    await ref.read(dataTableAutoSaveProvider.notifier).set(value);
    await _edits.setAutoSave(value);
    if (mounted && value && _edits.failedCount > 0) {
      _showMessage('Some changes couldn\'t be saved. Check the marked cells.');
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _update(() {}),
    );
  }

  void _toggleQuickFilter(DataTableQuickFilter filter) => _update(() {
    _quickFilters = _quickFilters.contains(filter)
        ? ({..._quickFilters}..remove(filter))
        : {..._quickFilters, filter};
  });

  void _setSort(String columnKey) => _update(() {
    final current = _sort;
    _sort = DataTableSort(
      columnKey: columnKey,
      ascending: current?.columnKey != columnKey || !current!.ascending,
    );
  });

  void _goToPage(int page) => _update(() => _page = page, keepPage: true);

  /// Called from the grid at its top or bottom row.
  void _turnPage(int direction) {
    final data = _data;
    if (data == null) return;
    final target = data.page + direction;
    if (target < 0 || target >= data.pageCount) return;
    _focusRowAfterLoad = direction > 0 ? 0 : -1;
    _goToPage(target);
  }

  Future<void> _editRules() async {
    final data = _data;
    if (data == null) return;
    final rules = await showDataTableFilterRules(
      context,
      columns: data.columns,
      rules: _rules,
    );
    if (rules != null && mounted) _update(() => _rules = rules);
  }

  Future<void> _pickColumns() async {
    final data = _data;
    if (data == null) return;
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (context) => ColumnPickerDialog(
        columns: data.columns,
        selected: _shown(data.columns).map((column) => column.key).toSet(),
        defaults: defaultDataTableColumnKeys(_type, data.columns),
      ),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    _update(() {
      _visibleColumns[_type] = selected;
      if (_sort != null && !selected.contains(_sort!.columnKey)) _sort = null;
      if (_searchField != null && !selected.contains(_searchField)) {
        _searchField = null;
      }
    }, keepPage: true);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
