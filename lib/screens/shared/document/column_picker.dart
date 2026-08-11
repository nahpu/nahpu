import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';

class SpecimenTableColumnSelector extends ConsumerStatefulWidget {
  const SpecimenTableColumnSelector({super.key, required this.selectedColumns});

  final List<String> selectedColumns;

  @override
  ConsumerState<SpecimenTableColumnSelector> createState() =>
      _SpecimenTableColumnSelectorState();
}

class _SpecimenTableColumnSelectorState
    extends ConsumerState<SpecimenTableColumnSelector> {
  late Set<String> _selected;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedColumns.toSet();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final groups = _getAllGroups(db);
    final keys = groups.keys.toList()..sort();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView(
              controller: _scrollController,
              shrinkWrap: true,
              children: [
                for (final table in keys)
                  _ExpansionGroup(
                    tableName: table,
                    fields: groups[table]!,
                    selected: _selected,
                    onSelectionChanged: (id, value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(id);
                        } else {
                          _selected.remove(id);
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selected.clear();
                    _selected.addAll(kDefaultPrintSpecimenTableColumnIds);
                  });
                },
                child: const Text('Defaults'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context, _selected.toList()),
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, List<String>> _getAllGroups(Database db) {
    Map<String, List<String>> groups = {};
    for (var table in db.allTables) {
      final tableName = table.actualTableName;
      final cols = table.$columns.map((c) => '$tableName::${c.name}').toList();
      cols.sort(
        (a, b) => specimenColumnDisplayTitle(
          a,
        ).toLowerCase().compareTo(specimenColumnDisplayTitle(b).toLowerCase()),
      );
      groups[tableName] = cols;
    }
    return groups;
  }
}

class _ExpansionGroup extends StatelessWidget {
  const _ExpansionGroup({
    required this.tableName,
    required this.fields,
    required this.selected,
    required this.onSelectionChanged,
  });

  final String tableName;
  final List<String> fields;
  final Set<String> selected;
  final void Function(String, bool?) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final int selectedCount = fields.where((f) => selected.contains(f)).length;
    final subtitleText = 'Selected $selectedCount of ${fields.length} columns';

    return ExpansionTile(
      title: Text(
        databaseTableDisplayTitle(tableName),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitleText),
      children: [
        for (final id in fields)
          CheckboxListTile(
            dense: true,
            value: selected.contains(id),
            onChanged: (v) => onSelectionChanged(id, v),
            title: Text(specimenColumnDisplayTitle(id)),
          ),
      ],
    );
  }
}
