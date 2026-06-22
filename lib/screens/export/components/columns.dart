import 'package:flutter/material.dart';

class ColumnSelectionList extends StatefulWidget {
  const ColumnSelectionList({
    super.key,
    required this.availableColumns,
    required this.selectedColumns,
    required this.onSelectionChanged,
  });

  final List<String> availableColumns;
  final List<String> selectedColumns;
  final void Function(List<String>) onSelectionChanged;

  @override
  State<ColumnSelectionList> createState() => _ColumnSelectionListState();
}

class _ColumnSelectionListState extends State<ColumnSelectionList> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedColumns);
  }

  @override
  void didUpdateWidget(covariant ColumnSelectionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColumns != widget.selectedColumns) {
      _selected = List.from(widget.selectedColumns);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupColumnsByTable();
    final groupKeys = groups.keys.toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Fields',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _selectAll,
                    child: const Text('Select All'),
                  ),
                  TextButton(
                    onPressed: _deselectAll,
                    child: const Text('Clear All'),
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: groupKeys.length,
            itemBuilder: (context, index) {
              String table = groupKeys[index];
              List<String> columns = groups[table]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(16.0),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  child: ExpansionTile(
                    shape: const Border(),
                    title: Text(
                      table.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true,
                    children: columns.map((col) {
                      bool isLocked = _isIdField(col);
                      return CheckboxListTile(
                        title: Text(col.split('::').last),
                        value: _selected.contains(col),
                        onChanged:
                            isLocked ? null : (val) => _toggleColumn(col, val),
                        controlAffinity: ListTileControlAffinity.leading,
                        subtitle: isLocked ? const Text('Required') : null,
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isIdField(String column) {
    // The first column is always the primary key/identifier for the record type
    return column == widget.availableColumns.first;
  }

  void _toggleColumn(String column, bool? value) {
    if (_isIdField(column)) return; // Prevent deselecting ID fields
    setState(() {
      if (value == true && !_selected.contains(column)) {
        _selected.add(column);
      } else if (value == false && _selected.contains(column)) {
        _selected.remove(column);
      }
      widget.onSelectionChanged(_selected);
    });
  }

  void _selectAll() {
    setState(() {
      _selected = List.from(widget.availableColumns);
      widget.onSelectionChanged(_selected);
    });
  }

  void _deselectAll() {
    setState(() {
      // Keep only ID fields
      _selected =
          widget.availableColumns.where((col) => _isIdField(col)).toList();
      widget.onSelectionChanged(_selected);
    });
  }

  Map<String, List<String>> _groupColumnsByTable() {
    Map<String, List<String>> groups = {};
    for (String col in widget.availableColumns) {
      List<String> parts = col.split('::');
      String table = parts.length > 1 ? parts[0] : 'general';
      if (!groups.containsKey(table)) {
        groups[table] = [];
      }
      groups[table]!.add(col);
    }
    return groups;
  }
}
