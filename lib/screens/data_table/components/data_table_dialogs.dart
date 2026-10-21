import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_toolbar.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

enum DataTableUnsavedChoice { save, discard, cancel }

/// Asks what to do with unsaved edits before leaving them behind.
class DataTableUnsavedDialog extends StatelessWidget {
  const DataTableUnsavedDialog({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save your changes?'),
      content: Text(
        count == 1
            ? 'You have 1 unsaved change in this table.'
            : 'You have $count unsaved changes in this table.',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(DataTableUnsavedChoice.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(DataTableUnsavedChoice.discard),
          child: const Text('Discard'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(DataTableUnsavedChoice.save),
          child: const Text('Save'),
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
      title: const Text('Columns'),
      content: SizedBox(
        width: NahpuContentWidth.dialog,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DataTableSearchField(
              controller: _filterController,
              hint: 'Find a field',
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: NahpuSpacing.md),
            Text(
              '${_selected.length} of ${widget.columns.length} fields shown',
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
                            ? const Tooltip(
                                message:
                                    'Calculated during export: not searchable '
                                    'or sortable',
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
          child: const Text('Defaults'),
        ),
        TextButton(
          onPressed: () => setState(
            () => _selected.addAll(widget.columns.map((column) => column.key)),
          ),
          child: const Text('Show all'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
