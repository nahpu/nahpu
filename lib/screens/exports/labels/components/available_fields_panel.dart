import 'package:nahpu/services/providers/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvailableFieldsPanel extends ConsumerWidget {
  const AvailableFieldsPanel({
    super.key,
    required this.isExpanded,
    required this.onAddField,
    required this.fieldDisplayOption,
    required this.onFieldDisplayOptionChanged,
  });

  final bool isExpanded;
  final void Function(String) onAddField;
  final String fieldDisplayOption;
  final ValueChanged<String> onFieldDisplayOptionChanged;

  Map<String, List<String>> _getAllGroups(WidgetRef ref) {
    final db = ref.read(databaseProvider);
    Map<String, List<String>> groups = {};
    for (var table in db.allTables) {
      final tableName = table.actualTableName;
      groups[tableName] =
          table.$columns.map((c) => '$tableName::${c.name}').toList();
    }
    return groups;
  }

  /// One list row per label; `.sex` columns become two rows (`[id]`, `[id]-img`).
  List<String> _fieldPanelRowLabels(List<String> fieldIds) {
    final out = <String>[];
    for (final id in fieldIds) {
      if (id.toLowerCase().endsWith('.sex')) {
        out.add('[$id]');
        out.add('[$id]-img');
      } else {
        out.add('[$id]');
      }
    }
    return out;
  }

  String _getDisplayLabel(String label) {
    final stripped = label.replaceAll('[', '').replaceAll(']', '');
    if (fieldDisplayOption == 'short') {
      final parts = stripped.split('::');
      return parts.length > 1 ? parts.last : stripped;
    }
    return stripped;
  }

  Widget _buildExpansionGroup(
    BuildContext context,
    String title,
    List<String> fields,
  ) {
    final rowLabels = _fieldPanelRowLabels(fields);
    final fieldStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.25,
      color: Theme.of(context).colorScheme.onSurface,
    );
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      dense: true,
      childrenPadding: EdgeInsets.zero,
      children: rowLabels.map((label) {
        return ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          horizontalTitleGap: 8,
          contentPadding: const EdgeInsets.fromLTRB(16, 2, 5, 2),
          onTap: () => onAddField(label),
          title: Text(
            _getDisplayLabel(label),
            style: fieldStyle,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelW = 280.0;
    const divW = 1.0;

    final groups = _getAllGroups(ref);
    final groupKeys = groups.keys.toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: isExpanded ? divW + panelW : 0,
      child: UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: divW + panelW,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VerticalDivider(width: 1),
              SizedBox(
                width: panelW,
                child: TextFieldTapRegion(
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available fields',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              DropdownButton<String>(
                                value: fieldDisplayOption,
                                isDense: true,
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'full',
                                    child: Text(
                                      'Table::Field',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'short',
                                    child: Text(
                                      'Field Only',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    onFieldDisplayOptionChanged(v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            children: [
                              ...groupKeys.map((table) {
                                return _buildExpansionGroup(
                                  context,
                                  table.toUpperCase(),
                                  groups[table]!,
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
