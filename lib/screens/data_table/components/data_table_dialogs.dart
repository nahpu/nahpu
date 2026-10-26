import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_toolbar.dart';
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

/// Picks visible columns, grouped by export table.
class ColumnPickerDialog extends StatefulWidget {
  const ColumnPickerDialog({
    super.key,
    required this.columns,
    required this.selected,
    required this.defaults,
  });

  final List<DataTableColumn> columns;
  final Set<String> selected;
  final Set<String> defaults;

  @override
  State<ColumnPickerDialog> createState() => _ColumnPickerDialogState();
}

class _ColumnPickerDialogState extends State<ColumnPickerDialog> {
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
    final theme = Theme.of(context);
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
    return AlertDialog(
      title: Text(context.l10n.projectBatchStepColumns),
      content: SizedBox(
        width: NahpuContentWidth.dialog,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DataTableSearchField(
              controller: _filterController,
              hint: context.l10n.dataTableFindField,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: NahpuSpacing.md),
            Text(
              context.l10n.dataTableFieldsShown(
                _selected.length,
                widget.columns.length,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: NahpuSpacing.xs),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final group in groups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: NahpuSpacing.md,
                        bottom: NahpuSpacing.xs,
                      ),
                      child: Text(
                        group.key,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    for (final column in group.value)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _selected.contains(column.key),
                        title: Text(column.label),
                        secondary: column.field.isComputed
                            ? Tooltip(
                                message:
                                    context.l10n.dataTableComputedNotSearchable,
                                child: Icon(
                                  Icons.functions,
                                  size: NahpuControlSize.iconSmall,
                                ),
                              )
                            : null,
                        onChanged: (checked) => setState(() {
                          if (checked == true) {
                            _selected.add(column.key);
                          } else if (_selected.length > 1) {
                            // Keep one column so the table never empties.
                            _selected.remove(column.key);
                          }
                        }),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
    );
  }
}
