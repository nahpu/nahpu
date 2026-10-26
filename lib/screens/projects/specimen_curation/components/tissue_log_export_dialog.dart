import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_export.dart';
import 'package:nahpu/services/export/export_destination.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_log_export.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Writes the log with the chosen settings and returns the file.
typedef TissueLogExportWriter =
    Future<File> Function({
      required ExportFmt format,
      required String fileStem,
      required Directory? directory,
      required List<String> columns,
      required TissueLogHeader header,
    });

/// Exports the session log to a tabular file: the curation columns, then
/// any part, specimen, and linked record columns the user adds.
class TissueLogExportDialog extends StatefulWidget {
  const TissueLogExportDialog({
    super.key,
    required this.checkedCount,
    required this.skippedCount,
    required this.defaultFileStem,
    required this.fieldGroups,
    required this.onExport,
    this.columns = const [],
    this.header = TissueLogHeader.fieldName,
    this.customFieldName = _noCustomName,
    this.onColumnsChanged,
    this.showCloseButton = true,
  });

  final int checkedCount;
  final int skippedCount;
  final String defaultFileStem;

  /// The columns that can be added, by table.
  final Map<String, List<String>> fieldGroups;
  final TissueLogExportWriter onExport;

  /// The added columns and header style to start with.
  final List<String> columns;
  final TissueLogHeader header;

  /// The name of a custom field key, or null for a table field.
  final String? Function(String key) customFieldName;

  /// Called when the added columns or header style change, so they can be
  /// kept for the next export.
  final void Function(List<String> columns, TissueLogHeader header)?
  onColumnsChanged;
  final bool showCloseButton;

  static String? _noCustomName(String key) => null;

  @override
  State<TissueLogExportDialog> createState() => _TissueLogExportDialogState();
}

class _TissueLogExportDialogState extends State<TissueLogExportDialog> {
  final _exportCtr = FileOpCtrModel.empty();
  final _destination = ExportDestinationService();
  late List<String> _columns = [...widget.columns];
  late TissueLogHeader _header = widget.header;
  bool _appendDate = false;
  Directory? _selectedDir;
  File? _output;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _exportCtr.fileNameCtr.text = widget.defaultFileStem;
  }

  @override
  void dispose() {
    _exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        NahpuSpacing.xl,
        NahpuSpacing.md,
        NahpuSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + NahpuSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.projectTissueExportLogTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (widget.showCloseButton)
                IconButton(
                  tooltip: context.l10n.commonClose,
                  icon: const Icon(Icons.close),
                  onPressed: _isRunning
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Text(
            context.l10n.projectTissueExportSummary(
              widget.checkedCount,
              widget.skippedCount,
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: NahpuSpacing.lg),
          GenericFileSettingsCard<ExportFmt>(
            exportCtr: _exportCtr,
            selectedDir: _selectedDir,
            format: _exportCtr.exportFmtCtr,
            formats: dataTableExportFormats,
            formatLabel: dataTableExportFormatLabel,
            extensionForFormat: dataTableExportExtension,
            onFormatChanged: (value) => _reset(() {
              _exportCtr.exportFmtCtr = value;
            }),
            onFileNameChanged: (_) => _reset(() {}),
            appendDate: _appendDate,
            onAppendDateChanged: (value) => _reset(() => _appendDate = value),
            onSelectDir: _selectDirectory,
            onClearDir: () => _reset(() => _selectedDir = null),
            enabled: !_isRunning,
          ),
          const SizedBox(height: NahpuSpacing.lg),
          TissueLogColumnsPanel(
            columns: _columns,
            header: _header,
            customFieldName: widget.customFieldName,
            enabled: !_isRunning,
            onAdd: _pickColumns,
            onRemove: (key) => _setColumns([..._columns]..remove(key)),
            onReorder: _reorder,
            onHeaderChanged: (header) => _setColumns(_columns, header: header),
          ),
          const SizedBox(height: NahpuSpacing.xl),
          ExportShareButton(
            hasExported: _output != null,
            isRunning: _isRunning,
            onExport: _exportCtr.isValid ? _export : null,
            onShare: _share,
            output: _output,
            onRevealFile: _openFolder,
            onSaveCopy: _saveCopy,
          ),
        ],
      ),
    );
  }

  /// Applies a settings change; the last file no longer matches them.
  void _reset(VoidCallback change) => setState(() {
    change();
    _output = null;
  });

  void _setColumns(List<String> columns, {TissueLogHeader? header}) {
    _reset(() {
      _columns = columns;
      _header = header ?? _header;
    });
    widget.onColumnsChanged?.call(_columns, _header);
  }

  void _reorder(int oldIndex, int newIndex) {
    final columns = [..._columns];
    final key = columns.removeAt(oldIndex);
    columns.insert(newIndex, key);
    _setColumns(columns);
  }

  Future<void> _pickColumns() async {
    final picked = await showAdaptiveSheetDialog<List<String>>(
      context: context,
      builder: (context, isSheet) => TissueLogColumnPicker(
        groups: widget.fieldGroups,
        selected: _columns,
        customFieldName: widget.customFieldName,
        isSheet: isSheet,
      ),
    );
    if (picked != null && mounted) _setColumns(picked);
  }

  Future<void> _selectDirectory() async {
    if (!_destination.canChooseDirectory) return;
    final directory = await FilePickerServices().selectDir();
    if (directory != null && mounted) {
      _reset(() => _selectedDir = directory);
    }
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isRunning = true);
    try {
      final output = await widget.onExport(
        format: _exportCtr.exportFmtCtr,
        fileStem: _appendDate
            ? appendDateToFileStem(_exportCtr.fileNameCtr.text, DateTime.now())
            : _exportCtr.fileNameCtr.text,
        directory: await _destination.resolve(_selectedDir),
        columns: _columns,
        header: _header,
      );
      if (!mounted) return;
      setState(() => _output = output);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _selectedDir != null
                ? context.l10n.sharedExportedTo(output.path)
                : context.l10n.sharedExportComplete,
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.sharedExportFailedError('$error'))),
      );
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().shareFile(context, output);
    } on Object catch (error) {
      _reportActionFailure(error);
    }
  }

  Future<void> _openFolder() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().openContainingDirectory(output);
    } on Object catch (error) {
      _reportActionFailure(error);
    }
  }

  Future<void> _saveCopy() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().saveCopyToDevice(output);
    } on Object catch (error) {
      _reportActionFailure(error);
    }
  }

  void _reportActionFailure(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

/// The export's columns: the fixed curation columns, then the added ones,
/// which can be reordered and removed, and how added headers are named.
class TissueLogColumnsPanel extends StatelessWidget {
  const TissueLogColumnsPanel({
    super.key,
    required this.columns,
    required this.header,
    required this.customFieldName,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
    required this.onHeaderChanged,
    this.enabled = true,
  });

  final List<String> columns;
  final TissueLogHeader header;
  final String? Function(String key) customFieldName;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  /// Gets the new index with the moved column already removed.
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<TissueLogHeader> onHeaderChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.projectTissueLogColumns,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Text(context.l10n.projectTissueLogColumnsBody, style: secondary),
          const SizedBox(height: NahpuSpacing.lg),
          Wrap(
            key: const ValueKey('tissue-log-curation-columns'),
            spacing: NahpuSpacing.sm,
            runSpacing: NahpuSpacing.sm,
            children: [
              for (final column in TissueLogColumn.values)
                Chip(
                  label: Text(column.localizedLabel(context.l10n)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.projectTissueLogAddedColumns,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                key: const ValueKey('tissue-log-add-columns'),
                onPressed: enabled ? onAdd : null,
                icon: const Icon(Icons.add),
                label: Text(context.l10n.projectTissueLogAddColumns),
              ),
            ],
          ),
          if (columns.isEmpty)
            Text(context.l10n.projectTissueLogNoAddedColumns, style: secondary)
          else ...[
            ReorderableListView(
              key: const ValueKey('tissue-log-added-columns'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: enabled ? onReorder : (_, _) {},
              children: [
                for (final (index, key) in columns.indexed)
                  TissueLogColumnTile(
                    key: ValueKey('tissue-log-column-$key'),
                    index: index,
                    columnKey: key,
                    label: customFieldName(key) ?? key.split('::').last,
                    enabled: enabled,
                    onRemove: () => onRemove(key),
                  ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.lg),
            Text(
              context.l10n.projectTissueLogHeaderStyle,
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: NahpuSpacing.sm),
            SegmentedButton<TissueLogHeader>(
              segments: [
                for (final value in TissueLogHeader.values)
                  ButtonSegment(
                    value: value,
                    label: Text(value.localizedLabel(context.l10n)),
                  ),
              ],
              selected: {header},
              showSelectedIcon: false,
              onSelectionChanged: enabled
                  ? (selection) => onHeaderChanged(selection.single)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// An added column: its field name and table, a drag handle, and a remove
/// button.
class TissueLogColumnTile extends StatelessWidget {
  const TissueLogColumnTile({
    super.key,
    required this.index,
    required this.columnKey,
    required this.label,
    required this.onRemove,
    this.enabled = true,
  });

  final int index;
  final String columnKey;
  final String label;
  final VoidCallback onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final table = columnKey.split('::').first;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: ReorderableDragStartListener(
        index: index,
        enabled: enabled,
        child: const Icon(Icons.drag_indicator),
      ),
      title: Text(label, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        databaseTableLocalizedTitle(context.l10n, table),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        tooltip: context.l10n.projectTissueLogRemoveColumn(label),
        onPressed: enabled ? onRemove : null,
        icon: const Icon(Icons.close),
      ),
    );
  }
}

/// Picks the columns a log export adds, from the specimen part export's
/// fields grouped by table. Pops with the chosen keys: kept columns in their
/// order, then new ones in catalog order.
class TissueLogColumnPicker extends StatefulWidget {
  const TissueLogColumnPicker({
    super.key,
    required this.groups,
    required this.selected,
    required this.customFieldName,
    this.isSheet = false,
  });

  final Map<String, List<String>> groups;
  final List<String> selected;
  final String? Function(String key) customFieldName;

  /// Sheets get a fixed height so the list can scroll.
  final bool isSheet;

  @override
  State<TissueLogColumnPicker> createState() => _TissueLogColumnPickerState();
}

class _TissueLogColumnPickerState extends State<TissueLogColumnPicker> {
  final _searchCtr = TextEditingController();
  late final Set<String> _selected = {...widget.selected};

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _filteredGroups(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.xl,
            NahpuSpacing.lg,
            NahpuSpacing.md,
            NahpuSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.projectTissueLogChooseColumns,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              if (!widget.isSheet)
                IconButton(
                  tooltip: context.l10n.commonClose,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.xl,
            NahpuSpacing.xs,
            NahpuSpacing.xl,
            NahpuSpacing.lg,
          ),
          child: TextField(
            key: const ValueKey('tissue-log-column-search'),
            controller: _searchCtr,
            decoration: InputDecoration(
              labelText: context.l10n.exportFieldsSearchFields,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const Divider(height: NahpuStroke.thin),
        Expanded(
          child: groups.isEmpty
              ? Center(child: Text(context.l10n.exportFieldsNoMatchingFields))
              : ListView(
                  children: [
                    for (final MapEntry(key: table, value: fields)
                        in groups.entries) ...[
                      Container(
                        color: theme.colorScheme.surfaceContainerLow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: NahpuSpacing.xl,
                          vertical: NahpuSpacing.md,
                        ),
                        child: Text(
                          databaseTableLocalizedTitle(context.l10n, table),
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      for (final key in fields)
                        CheckboxListTile(
                          key: ValueKey('tissue-log-pick-$key'),
                          dense: true,
                          value: _selected.contains(key),
                          title: Text(_label(key)),
                          onChanged: (checked) => setState(() {
                            checked == true
                                ? _selected.add(key)
                                : _selected.remove(key);
                          }),
                        ),
                    ],
                  ],
                ),
        ),
        const Divider(height: NahpuStroke.thin),
        Padding(
          padding: const EdgeInsets.all(NahpuSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.projectTissueLogSelectedCount(_selected.length),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.commonCancel),
              ),
              const SizedBox(width: NahpuSpacing.sm),
              FilledButton(
                key: const ValueKey('tissue-log-pick-done'),
                onPressed: () => Navigator.pop(context, _result()),
                child: Text(context.l10n.commonDone),
              ),
            ],
          ),
        ),
      ],
    );
    if (!widget.isSheet) return content;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: content,
    );
  }

  String _label(String key) =>
      widget.customFieldName(key) ?? key.split('::').last;

  /// Kept columns stay in their order; new ones follow in catalog order.
  List<String> _result() => [
    for (final key in widget.selected)
      if (_selected.contains(key)) key,
    for (final fields in widget.groups.values)
      for (final key in fields)
        if (_selected.contains(key) && !widget.selected.contains(key)) key,
  ];

  /// Groups whose table or fields match the search. A matching table keeps
  /// all its fields.
  Map<String, List<String>> _filteredGroups(BuildContext context) {
    final query = _searchCtr.text.trim().toLowerCase();
    if (query.isEmpty) return widget.groups;
    return {
      for (final MapEntry(key: table, value: fields) in widget.groups.entries)
        if (_matches(context, table, fields, query) case final matches
            when matches.isNotEmpty)
          table: matches,
    };
  }

  List<String> _matches(
    BuildContext context,
    String table,
    List<String> fields,
    String query,
  ) {
    final title = databaseTableLocalizedTitle(context.l10n, table);
    if (title.toLowerCase().contains(query) ||
        table.toLowerCase().contains(query)) {
      return fields;
    }
    return [
      for (final key in fields)
        if (_label(key).toLowerCase().contains(query)) key,
    ];
  }
}
