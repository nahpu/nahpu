import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_dialogs.dart';
import 'package:nahpu/screens/data_table/components/data_table_edit_toolbar.dart';
import 'package:nahpu/screens/data_table/components/data_table_export_dialog.dart';
import 'package:nahpu/screens/data_table/components/data_table_filters.dart';
import 'package:nahpu/screens/data_table/components/data_table_find_replace_bar.dart';
import 'package:nahpu/screens/data_table/components/data_table_grid.dart';
import 'package:nahpu/screens/data_table/components/data_table_link_dialogs.dart';
import 'package:nahpu/screens/data_table/components/data_table_pagination.dart';
import 'package:nahpu/screens/data_table/components/data_table_toolbar.dart';
import 'package:nahpu/screens/events/event_view.dart';
import 'package:nahpu/screens/narrative/narrative_view.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/data_table/data_table_edits.dart';
import 'package:nahpu/services/data_table/data_table_export.dart';
import 'package:nahpu/services/data_table/data_table_find_replace.dart';
import 'package:nahpu/services/database/app_exit.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/data_table/data_table_grid_controller.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/data_table.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/projects.dart';
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
    this.allProjects = false,
    this.initialSearch,
  });

  final DataTableRecordType initialType;

  /// Opens the table limited to these records of [initialType].
  final DataTableKeyScope? initialScope;

  /// Lists records from every project instead of the open one. A record's
  /// form or link picker opens in that record's own project.
  final bool allProjects;

  /// Opens the table on this search and its filters, in place of
  /// [initialType]. Its projects apply with [allProjects].
  final DataTableSearchRequest? initialSearch;

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

  late DataTableRecordType _type =
      widget.initialSearch?.type ?? widget.initialType;
  late DataTableKeyScope? _scope = widget.initialScope;
  late SpecimenRecordType _specimenType =
      widget.initialSearch?.specimenType ?? SpecimenRecordType.allTaxa;
  late String? _searchField = widget.initialSearch?.searchField;
  List<DataTableFilterRule> _rules = const [];
  late Set<DataTableQuickFilter> _quickFilters =
      widget.initialSearch?.quickFilters ?? const {};

  /// With [DataTableScreen.allProjects], the projects the table is limited
  /// to; empty shows every project.
  late Set<String> _projectUuids =
      widget.initialSearch?.projectUuids ?? const {};
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

  /// What the find bar looks for; null while the bar is closed.
  DataTableFindOptions? _find;
  bool _isReplacing = false;

  /// Direction a find step was heading when it turned the page: the next
  /// page's first match (1) or the previous page's last (-1).
  int? _findAfterLoad;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch?.search ?? '';
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
    // The find bar's count follows the focused cell and pending edits.
    _grid.addListener(_onFindStateChanged);
    _edits.addListener(_onFindStateChanged);
    _load();
  }

  @override
  void dispose() {
    _grid.removeListener(_onFindStateChanged);
    _edits.removeListener(_onFindStateChanged);
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
    final matches = data == null
        ? const <DataTableCellPos>[]
        : _matchesIn(data, columns);
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
            AdaptiveMenuButton<DataTableMenuAction>(
              tooltip: 'More actions',
              itemBuilder: () => [
                AdaptiveMenuItem(
                  value: DataTableMenuAction.findReplace,
                  label: 'Find and replace',
                  icon: Icons.find_replace,
                  enabled: _data != null,
                ),
                AdaptiveMenuItem(
                  value: DataTableMenuAction.export,
                  label: 'Export table',
                  icon: Icons.file_download_outlined,
                  enabled: _data != null,
                ),
              ],
              onSelected: _onMenuAction,
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
                  onRefresh: _load,
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
                          _scope != null ||
                          _projectLabel != null) ...[
                        const DataTableToolbarDivider(),
                        DataTableFilterChips(
                          projectLabel: _projectLabel,
                          onProjectsRemoved: () =>
                              _update(() => _projectUuids = const {}),
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
                            _projectUuids = const {};
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_find != null && data != null)
                DataTableFindReplaceBar(
                  columns: columns,
                  isEditMode: _isEditMode,
                  matchCount: matches.length,
                  currentMatch: _currentMatch(matches),
                  isReplacing: _isReplacing,
                  onChanged: _setFind,
                  onPrevious: () => _findStep(-1),
                  onNext: () => _findStep(1),
                  onReplace: _replaceCurrent,
                  onReplaceAll: _replaceAll,
                  onClose: () => setState(() => _find = null),
                ),
              SizedBox(
                height: NahpuStroke.regular,
                child: _isLoading ? const LinearProgressIndicator() : null,
              ),
              const Divider(height: NahpuStroke.thin),
              Expanded(child: _content(data, columns, matches)),
              // Paging waits while the keyboard is up, leaving room for the
              // grid on phones.
              if (MediaQuery.viewInsetsOf(context).bottom == 0) ...[
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(
    DataTablePageData? data,
    List<DataTableColumn> columns,
    List<DataTableCellPos> matches,
  ) {
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
          _scope != null ||
          _projectLabel != null;
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
            : widget.allProjects
            ? 'No $records${taxa == null ? '' : ' for $taxa'} yet.'
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
      highlightedCells: matches.toSet(),
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
    await _inRecordProject(
      row,
      () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => form)),
    );
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
    final saved = await _inRecordProject(
      row,
      () => showDataTableLinkDialog(
        context,
        type: _type,
        row: row,
        column: column,
        link: link,
      ),
    );
    if (!saved || !mounted) return;
    _showMessage('Saved.');
    _invalidateRecordLists();
    _load();
  }

  /// Runs [action] with [row]'s project open, so forms, media folders, and
  /// link pickers resolve against the record's own project, then reopens the
  /// project that was open before. Only an all-projects table switches.
  Future<T> _inRecordProject<T>(
    DataTableRecordRow row,
    Future<T> Function() action,
  ) async {
    final previous = ref.read(projectUuidProvider);
    final target = row.projectUuid;
    if (!widget.allProjects || target == null || target == previous) {
      return action();
    }
    final projects = ProjectServices(ref: ref);
    projects.updateProjectUuid(target);
    try {
      return await action();
    } finally {
      if (mounted) projects.updateProjectUuid(previous);
    }
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
    if (shown.isNotEmpty) return orderDataTableColumns(_type, shown);
    // Nothing chosen yet, or the choice has no field in this export (another
    // taxon group): fall back to the defaults.
    final defaults = defaultDataTableColumnKeys(_type, columns);
    return orderDataTableColumns(_type, [
      for (final column in columns)
        if (defaults.contains(column.key)) column,
    ]);
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
    allProjects: widget.allProjects,
    projectUuids: widget.allProjects ? _projectUuids : const {},
  );

  /// Chip label for the projects the table is limited to, or null when it
  /// shows every project.
  String? get _projectLabel {
    if (!widget.allProjects || _projectUuids.isEmpty) return null;
    final projects = ref.watch(projectListProvider).asData?.value ?? const [];
    final names = {for (final project in projects) project.uuid: project.name};
    return dataTableProjectScopeLabel([
      for (final uuid in _projectUuids) names[uuid] ?? uuid,
    ]);
  }

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
      final findDirection = _findAfterLoad;
      _findAfterLoad = null;
      if (findDirection != null) _continueFind(data, findDirection);
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

  void _onMenuAction(DataTableMenuAction action) => switch (action) {
    DataTableMenuAction.findReplace => setState(
      () => _find ??= const DataTableFindOptions(text: ''),
    ),
    DataTableMenuAction.export => _exportTable(),
  };

  void _onFindStateChanged() {
    if (_find == null || !mounted) return;
    // The grid can move focus while it lays out; wait for the frame.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }
    setState(() {});
  }

  /// The text a cell shows, with its pending edit if it has one.
  String _cellText(DataTableRecordRow row, DataTableColumn column) {
    final pending = _edits.pendingFor(DataTableCellId(row.key, column.key));
    return pending != null
        ? column.field.labelFor(pending.value)
        : row.values[column.key] ?? '';
  }

  String? _pendingValue(DataTableCellId cell) => _edits.pendingFor(cell)?.value;

  List<DataTableCellPos> _matchesIn(
    DataTablePageData data,
    List<DataTableColumn> columns,
  ) {
    final find = _find;
    if (find == null) return const [];
    return findDataTableMatches(data.rows, columns, find, textOf: _cellText);
  }

  int? _currentMatch(List<DataTableCellPos> matches) {
    final focus = _grid.focus;
    final index = matches.indexOf(focus);
    return index < 0 ? null : index + 1;
  }

  /// Applies new find options and moves to the first match when the focused
  /// cell isn't one.
  void _setFind(DataTableFindOptions options) {
    setState(() => _find = options);
    final data = _data;
    if (data == null) return;
    final matches = _matchesIn(data, _shown(data.columns));
    if (matches.isNotEmpty && !matches.contains(_grid.focus)) {
      _grid.moveTo(matches.first.row, matches.first.col);
    }
  }

  /// Moves to the next match after the focused cell ([direction] 1) or the
  /// one before it (-1), turning the page when this one has no more.
  void _findStep(int direction) {
    final data = _data;
    final find = _find;
    if (data == null || find == null || find.isEmpty) return;
    final matches = _matchesIn(data, _shown(data.columns));
    final focus = _grid.focus;
    int compare(DataTableCellPos pos) => pos.row != focus.row
        ? pos.row.compareTo(focus.row)
        : pos.col.compareTo(focus.col);
    final ahead = [
      for (final pos in matches)
        if (compare(pos) * direction > 0) pos,
    ];
    if (ahead.isNotEmpty) {
      final target = direction > 0 ? ahead.first : ahead.last;
      _grid.moveTo(target.row, target.col);
      return;
    }
    _turnFindPage(data, direction);
  }

  void _turnFindPage(DataTablePageData data, int direction) {
    final target = data.page + direction;
    if (target < 0 || target >= data.pageCount) {
      _showMessage(direction > 0 ? 'No more matches.' : 'No earlier matches.');
      return;
    }
    _findAfterLoad = direction;
    _goToPage(target);
  }

  /// After a find step turned the page: focuses its first or last match, or
  /// keeps going when the page has none.
  void _continueFind(DataTablePageData data, int direction) {
    final columns = _shown(data.columns);
    final matches = _matchesIn(data, columns);
    if (matches.isEmpty) {
      _turnFindPage(data, direction);
      return;
    }
    final target = direction > 0 ? matches.first : matches.last;
    _grid.setSize(data.rows.length, columns.length);
    _grid.moveTo(target.row, target.col);
  }

  /// Replaces the match in the focused cell, then moves to the next one.
  void _replaceCurrent() {
    final data = _data;
    final find = _find;
    if (data == null || find == null || !_isEditMode) return;
    final columns = _shown(data.columns);
    final focus = _grid.focus;
    if (focus.row < data.rows.length && focus.col < columns.length) {
      final row = data.rows[focus.row];
      final column = columns[focus.col];
      if (find.includes(column) && find.matches(_cellText(row, column))) {
        final plan = planDataTableReplacements(
          _type,
          [row],
          [column],
          find,
          pendingOf: _pendingValue,
        );
        if (plan.edits.isEmpty) {
          _showMessage(_leftAlone(plan) ?? 'This cell can\'t be replaced.');
        } else {
          _edits.commit(plan.edits);
        }
      }
    }
    _findStep(1);
  }

  /// Replaces every match in the visible columns of every record the search
  /// and filters match. The changes wait for Save like any other edit.
  Future<void> _replaceAll() async {
    final data = _data;
    final find = _find;
    if (data == null || find == null || find.isEmpty || !_isEditMode) return;
    setState(() => _isReplacing = true);
    final List<DataTableRecordRow> rows;
    try {
      rows = await ref.read(dataTableRawRowsLoaderProvider)(
        ref,
        _type,
        _query,
        _specimenType,
        data.columns,
      );
    } catch (e) {
      if (mounted) _showMessage('Couldn\'t read records to replace: $e');
      return;
    } finally {
      if (mounted) setState(() => _isReplacing = false);
    }
    if (!mounted) return;
    final plan = planDataTableReplacements(
      _type,
      rows,
      _shown(data.columns),
      find,
      pendingOf: _pendingValue,
    );
    if (plan.edits.isEmpty) {
      _showMessage(_leftAlone(plan) ?? 'Nothing to replace.');
      return;
    }
    final confirmed = await showAdaptiveConfirmation(
      context: context,
      title: 'Replace all?',
      message:
          'Replace ${_plural(plan.edits.length, 'value')} in '
          '${_plural(plan.recordCount, 'record')}? '
          '${_edits.autoSave ? 'Auto-save writes them right away.' : 'They wait for Save.'}',
      confirmLabel: 'Replace',
    );
    if (!confirmed || !mounted) return;
    final accepted = _edits.commit(plan.edits);
    _showMessage(
      ['Replaced ${_plural(accepted, 'value')}.', ?_leftAlone(plan)].join(' '),
    );
  }

  /// Says which matches a replace had to leave alone, if any.
  String? _leftAlone(DataTableReplacePlan plan) {
    final parts = [
      if (plan.skippedChoices > 0)
        '${_plural(plan.skippedChoices, 'dropdown value')} skipped; '
            'pick those from their list.',
      if (plan.invalid > 0)
        '${_plural(plan.invalid, 'value')} wouldn\'t fit '
            '${plan.invalid == 1 ? 'its field' : 'their fields'}.',
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }

  String _plural(int count, String noun) =>
      count == 1 ? '1 $noun' : '$count ${noun}s';

  /// Exports every record the table matches with its visible columns. Unsaved
  /// edits are settled first, so the file holds what is stored.
  Future<void> _exportTable() async {
    if (!await _resolveUnsaved() || !mounted) return;
    final data = _data;
    if (data == null) return;
    final columns = _shown(data.columns);
    final query = _query;
    final type = _type;
    final specimenType = _specimenType;
    final loader = ref.read(dataTablePageLoaderProvider);
    final service = DataTableExportService(
      loadPage: (query) => loader(ref, type, query, specimenType),
    );
    await showAdaptiveSheetDialog<void>(
      context: context,
      builder: (context, isSheet) => SafeArea(
        top: false,
        child: DataTableExportDialog(
          recordCount: data.totalRows,
          columnCount: columns.length,
          defaultFileStem: 'nahpu_${type.name}',
          showCloseButton: !isSheet,
          onExport:
              ({
                required format,
                required header,
                required mappedOnly,
                required fileStem,
                required directory,
                required onProgress,
              }) => service.write(
                query: query,
                columns: columns,
                format: format,
                header: header,
                mappedOnly: mappedOnly,
                fileStem: fileStem,
                directory: directory,
                onProgress: onProgress,
              ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Actions in the data table's app bar menu.
enum DataTableMenuAction { findReplace, export }
