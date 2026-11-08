import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_toolbar.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

enum DataTableUnsavedChoice { save, discard, cancel }

/// Asks what to do with unsaved edits before leaving them behind.
class DataTableUnsavedDialog extends StatelessWidget {
  const DataTableUnsavedDialog({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.dataTableSaveChangesTitle),
      content: Text(context.l10n.dataTableUnsavedChanges(count)),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(DataTableUnsavedChoice.cancel),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(DataTableUnsavedChoice.discard),
          child: Text(context.l10n.templateDiscard),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(DataTableUnsavedChoice.save),
          child: Text(context.l10n.commonSave),
        ),
      ],
    );
  }
}

/// Picks visible columns, grouped by export table. Shown with
/// `showAdaptiveSheetDialog`: a bottom sheet on phones, a dialog elsewhere.
class DataTableColumnPicker extends StatefulWidget {
  const DataTableColumnPicker({
    super.key,
    required this.columns,
    required this.selected,
    required this.defaults,
    this.showCloseButton = true,
  });

  final List<DataTableColumn> columns;
  final Set<String> selected;
  final Set<String> defaults;

  /// A bottom sheet is dismissed with its drag handle instead.
  final bool showCloseButton;

  @override
  State<DataTableColumnPicker> createState() => _DataTableColumnPickerState();
}

class _DataTableColumnPickerState extends State<DataTableColumnPicker> {
  late final Set<String> _selected = {...widget.selected};
  final _filterController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needle = _filter.trim().toLowerCase();
    final groups = <String, List<DataTableColumn>>{};
    for (final column in widget.columns) {
      if (needle.isNotEmpty &&
          !column.label.toLowerCase().contains(needle) &&
          !column.group.toLowerCase().contains(needle)) {
        continue;
      }
      groups.putIfAbsent(column.group, () => []).add(column);
    }
    return AdaptiveSheetDialogBody(
      title: context.l10n.projectBatchStepColumns,
      description: context.l10n.dataTableFieldsShown(
        _selected.length,
        widget.columns.length,
      ),
      showCloseButton: widget.showCloseButton,
      actions: [
        TextButton(
          onPressed: () => setState(
            () => _selected
              ..clear()
              ..addAll(widget.defaults),
          ),
          child: Text(context.l10n.setupPresetDefaults),
        ),
        TextButton(
          onPressed: () => setState(
            () => _selected.addAll(widget.columns.map((column) => column.key)),
          ),
          child: Text(context.l10n.dataTableShowAll),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: Text(context.l10n.commonDone),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DataTableSearchField(
            controller: _filterController,
            hint: context.l10n.dataTableFindField,
            onChanged: (value) => setState(() => _filter = value),
          ),
          for (final group in groups.entries)
            DataTableColumnGroupSection(
              name: group.key,
              columns: group.value,
              selected: _selected,
              onToggle: _toggle,
              onToggleGroup: _toggleGroup,
            ),
        ],
      ),
    );
  }

  void _toggle(String key, bool checked) => setState(() {
    if (checked) {
      _selected.add(key);
    } else if (_selected.length > 1) {
      // Keep one column so the table never empties.
      _selected.remove(key);
    }
  });

  void _toggleGroup(List<DataTableColumn> columns, bool checked) =>
      setState(() {
        final keys = columns.map((column) => column.key);
        if (checked) {
          _selected.addAll(keys);
          return;
        }
        final rest = _selected.difference(keys.toSet());
        // Keep one column so the table never empties.
        if (rest.isEmpty) {
          _selected
            ..clear()
            ..add(columns.first.key);
        } else {
          _selected
            ..clear()
            ..addAll(rest);
        }
      });
}

/// One export table's fields in the column picker: a header that toggles
/// the whole group, then the fields flowed into as many columns as fit.
class DataTableColumnGroupSection extends StatelessWidget {
  const DataTableColumnGroupSection({
    super.key,
    required this.name,
    required this.columns,
    required this.selected,
    required this.onToggle,
    required this.onToggleGroup,
  });

  final String name;
  final List<DataTableColumn> columns;
  final Set<String> selected;
  final void Function(String key, bool checked) onToggle;
  final void Function(List<DataTableColumn> columns, bool checked)
  onToggleGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = columns.where((c) => selected.contains(c.key)).length;
    final groupValue = shown == 0
        ? false
        : shown == columns.length
        ? true
        : null;
    return Padding(
      padding: const EdgeInsets.only(top: NahpuSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: NahpuStroke.thin,
            thickness: NahpuStroke.thin,
            color: theme.colorScheme.outlineVariant,
          ),
          Row(
            children: [
              Tooltip(
                message: context.l10n.commonSelectAll,
                child: Checkbox(
                  tristate: true,
                  value: groupValue,
                  // A partial group fills in, as in most pickers.
                  onChanged: (_) => onToggleGroup(columns, groupValue != true),
                ),
              ),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$shown / ${columns.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final count =
                  (constraints.maxWidth / NahpuDataTable.pickerTileWidth)
                      .floor()
                      .clamp(1, NahpuDataTable.pickerMaxColumns);
              final tileWidth =
                  (constraints.maxWidth - (count - 1) * NahpuSpacing.md) /
                  count;
              return Wrap(
                spacing: NahpuSpacing.md,
                children: [
                  for (final column in columns)
                    SizedBox(
                      width: tileWidth,
                      child: DataTableColumnPickerTile(
                        column: column,
                        isSelected: selected.contains(column.key),
                        onChanged: (checked) => onToggle(column.key, checked),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A field's checkbox in the column picker.
class DataTableColumnPickerTile extends StatelessWidget {
  const DataTableColumnPickerTile({
    super.key,
    required this.column,
    required this.isSelected,
    required this.onChanged,
  });

  final DataTableColumn column;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: isSelected,
      title: Tooltip(
        message: column.label == column.key
            ? column.key
            : '${column.label}\n${column.key}',
        waitDuration: const Duration(milliseconds: 500),
        child: Text(column.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      secondary: column.field.isComputed
          ? Tooltip(
              message: context.l10n.dataTableComputedNotSearchable,
              child: const Icon(
                Icons.functions,
                size: NahpuControlSize.iconSmall,
              ),
            )
          : null,
      onChanged: (checked) => onChanged(checked == true),
    );
  }
}
