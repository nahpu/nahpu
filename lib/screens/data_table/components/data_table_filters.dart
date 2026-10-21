import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_query.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// The record scope, active preset filters, and field rules as removable chips, shown
/// after the edit controls only while any are on.
class DataTableFilterChips extends StatelessWidget {
  const DataTableFilterChips({
    super.key,
    required this.selected,
    required this.rules,
    required this.columns,
    required this.onToggled,
    required this.onRuleRemoved,
    required this.onCleared,
    this.scope,
    this.onScopeRemoved,
  });

  /// Records picked elsewhere, such as from a statistics chart.
  final DataTableKeyScope? scope;
  final VoidCallback? onScopeRemoved;
  final Set<DataTableQuickFilter> selected;
  final List<DataTableFilterRule> rules;
  final List<DataTableColumn> columns;
  final ValueChanged<DataTableQuickFilter> onToggled;
  final ValueChanged<int> onRuleRemoved;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final labels = {for (final column in columns) column.key: column.label};
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (scope case final scope?)
          DataTableActiveFilterChip(
            label: '${scope.label} (${scope.keys.length})',
            onDeleted: onScopeRemoved ?? () {},
          ),
        // Keep the menu's order rather than the order they were picked.
        for (final filter in DataTableQuickFilter.values)
          if (selected.contains(filter))
            DataTableActiveFilterChip(
              label: filter.label,
              onDeleted: () => onToggled(filter),
            ),
        for (var i = 0; i < rules.length; i++)
          DataTableActiveFilterChip(
            label: describeDataTableRule(
              rules[i],
              labels[rules[i].fieldKey] ?? rules[i].fieldKey,
            ),
            onDeleted: () => onRuleRemoved(i),
          ),
        TextButton(
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          onPressed: onCleared,
          child: const Text('Clear filters'),
        ),
      ],
    );
  }
}

class DataTableActiveFilterChip extends StatelessWidget {
  const DataTableActiveFilterChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: NahpuSpacing.md),
      child: InputChip(
        label: Text(label),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
        onDeleted: onDeleted,
      ),
    );
  }
}

/// A short reading of [rule], such as "weight between 10 and 20".
String describeDataTableRule(DataTableFilterRule rule, String fieldLabel) {
  final value = switch (rule.op) {
    DataTableFilterOp.isEmpty || DataTableFilterOp.isNotEmpty => '',
    DataTableFilterOp.between => ' ${rule.value} and ${rule.value2}',
    _ => ' "${rule.value}"',
  };
  return '$fieldLabel ${rule.op.label}$value';
}

/// Shows the rule editor as a sheet on small screens and a dialog
/// elsewhere. Returns the new rules, or null when cancelled.
Future<List<DataTableFilterRule>?> showDataTableFilterRules(
  BuildContext context, {
  required List<DataTableColumn> columns,
  required List<DataTableFilterRule> rules,
}) {
  final form = DataTableFilterRulesForm(columns: columns, rules: rules);
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    return showModalBottomSheet<List<DataTableFilterRule>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: NahpuSpacing.xl,
            right: NahpuSpacing.xl,
            bottom: MediaQuery.viewInsetsOf(context).bottom + NahpuSpacing.xl,
          ),
          child: form,
        ),
      ),
    );
  }
  return showDialog<List<DataTableFilterRule>>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: NahpuContentWidth.form),
        child: Padding(
          padding: const EdgeInsets.all(NahpuSpacing.xxl),
          child: form,
        ),
      ),
    ),
  );
}

/// Field rules, combined with AND. Only fields stored in the database can
/// be filtered; calculated ones are listed but disabled.
class DataTableFilterRulesForm extends StatefulWidget {
  const DataTableFilterRulesForm({
    super.key,
    required this.columns,
    required this.rules,
  });

  final List<DataTableColumn> columns;
  final List<DataTableFilterRule> rules;

  @override
  State<DataTableFilterRulesForm> createState() =>
      _DataTableFilterRulesFormState();
}

class _DataTableFilterRulesFormState extends State<DataTableFilterRulesForm> {
  late final List<DataTableRuleDraft> _drafts = [
    for (final rule in widget.rules)
      DataTableRuleDraft.fromRule(rule, widget.columns),
  ];
  String? _error;

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filterable = widget.columns
        .where((column) => column.field.isFilterable)
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Filter rules', style: theme.textTheme.titleLarge),
        const SizedBox(height: NahpuSpacing.xs),
        Text(
          'Show records that match every rule.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var i = 0; i < _drafts.length; i++)
                  DataTableRuleRow(
                    key: ObjectKey(_drafts[i]),
                    draft: _drafts[i],
                    columns: widget.columns,
                    onChanged: () => setState(() => _error = null),
                    onRemoved: () => setState(() {
                      _drafts.removeAt(i).dispose();
                    }),
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add rule'),
            onPressed: filterable.isEmpty
                ? null
                : () => setState(
                    () => _drafts.add(DataTableRuleDraft(filterable.first)),
                  ),
          ),
        ),
        if (_error != null)
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        const SizedBox(height: NahpuSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(const <DataTableFilterRule>[]),
              child: const Text('Clear all'),
            ),
            const SizedBox(width: NahpuSpacing.md),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: NahpuSpacing.md),
            FilledButton(onPressed: _apply, child: const Text('Apply')),
          ],
        ),
      ],
    );
  }

  void _apply() {
    final rules = <DataTableFilterRule>[];
    for (final draft in _drafts) {
      final rule = draft.toRule();
      final problem = validateDataTableRule(
        dataTableField(rule.fieldKey),
        rule,
      );
      if (problem != null) {
        setState(() => _error = problem);
        return;
      }
      rules.add(rule);
    }
    Navigator.of(context).pop(rules);
  }
}

/// Why [rule] can't run, or null when it can.
String? validateDataTableRule(DataTableField field, DataTableFilterRule rule) {
  if (!rule.op.takesValue) return null;
  final values = [
    rule.value,
    if (rule.op == DataTableFilterOp.between) rule.value2,
  ];
  for (final value in values) {
    final text = value.trim();
    if (text.isEmpty) return 'Enter a value for every rule.';
    final ok = switch (field.valueType) {
      DataTableValueType.integer ||
      DataTableValueType.real => double.tryParse(text) != null,
      DataTableValueType.date => isDataTableDate(text),
      DataTableValueType.time => isDataTableTime(text),
      DataTableValueType.text => true,
      DataTableValueType.coded => field.codeForInput(text) != null,
    };
    if (!ok) {
      return switch (field.valueType) {
        DataTableValueType.date => 'Enter dates as YYYY-MM-DD.',
        DataTableValueType.time => 'Enter times as HH:MM.',
        DataTableValueType.coded => 'Choose one of the listed values.',
        _ => 'Enter a number.',
      };
    }
  }
  return null;
}

/// A rule while it is being edited.
class DataTableRuleDraft {
  DataTableRuleDraft(this.column, {DataTableFilterOp? op})
    : op = op ?? DataTableFilterOp.forType(column.field.valueType).first;

  factory DataTableRuleDraft.fromRule(
    DataTableFilterRule rule,
    List<DataTableColumn> columns,
  ) {
    final column = columns.firstWhere(
      (column) => column.key == rule.fieldKey,
      orElse: () => dataTableColumnsFromHeader([rule.fieldKey]).single,
    );
    return DataTableRuleDraft(column, op: rule.op)
      ..value.text = rule.value
      ..value2.text = rule.value2;
  }

  DataTableColumn column;
  DataTableFilterOp op;
  final value = TextEditingController();
  final value2 = TextEditingController();

  DataTableFilterRule toRule() => DataTableFilterRule(
    fieldKey: column.key,
    op: op,
    value: value.text,
    value2: value2.text,
  );

  void dispose() {
    value.dispose();
    value2.dispose();
  }
}

class DataTableRuleRow extends StatelessWidget {
  const DataTableRuleRow({
    super.key,
    required this.draft,
    required this.columns,
    required this.onChanged,
    required this.onRemoved,
  });

  final DataTableRuleDraft draft;
  final List<DataTableColumn> columns;
  final VoidCallback onChanged;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    final ops = DataTableFilterOp.forType(draft.column.field.valueType);
    final hint = switch (draft.column.field.valueType) {
      DataTableValueType.date => 'YYYY-MM-DD',
      DataTableValueType.time => 'HH:MM',
      _ => 'Value',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
      child: Wrap(
        spacing: NahpuSpacing.md,
        runSpacing: NahpuSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownMenu<String>(
            width: NahpuDataTable.wideColumnWidth,
            initialSelection: draft.column.key,
            enableFilter: true,
            requestFocusOnTap: true,
            label: const Text('Field'),
            dropdownMenuEntries: [
              for (final column in columns)
                DropdownMenuEntry(
                  value: column.key,
                  label: column.label,
                  enabled: column.field.isFilterable,
                  trailingIcon: column.field.isFilterable
                      ? null
                      : const Tooltip(
                          message: 'Calculated during export; not filterable',
                          child: Icon(
                            Icons.block,
                            size: NahpuControlSize.iconSmall,
                          ),
                        ),
                ),
            ],
            onSelected: (key) {
              if (key == null) return;
              draft.column = columns.firstWhere((c) => c.key == key);
              final allowed = DataTableFilterOp.forType(
                draft.column.field.valueType,
              );
              if (!allowed.contains(draft.op)) draft.op = allowed.first;
              onChanged();
            },
          ),
          DropdownButton<DataTableFilterOp>(
            value: draft.op,
            items: [
              for (final op in ops)
                DropdownMenuItem(value: op, child: Text(op.label)),
            ],
            onChanged: (op) {
              if (op == null) return;
              draft.op = op;
              onChanged();
            },
          ),
          if (draft.op.takesValue &&
              draft.column.field.valueType == DataTableValueType.coded)
            DropdownButton<String>(
              value:
                  draft.column.field.codes.any(
                    (choice) => choice.$2 == draft.value.text,
                  )
                  ? draft.value.text
                  : null,
              hint: const Text('Value'),
              items: [
                for (final (_, label) in draft.column.field.codes)
                  DropdownMenuItem(value: label, child: Text(label)),
              ],
              onChanged: (label) {
                draft.value.text = label ?? '';
                onChanged();
              },
            )
          else if (draft.op.takesValue)
            SizedBox(
              width: NahpuDataTable.columnWidth,
              child: TextField(
                controller: draft.value,
                decoration: InputDecoration(isDense: true, hintText: hint),
                onChanged: (_) => onChanged(),
              ),
            ),
          if (draft.op == DataTableFilterOp.between)
            SizedBox(
              width: NahpuDataTable.columnWidth,
              child: TextField(
                controller: draft.value2,
                decoration: InputDecoration(isDense: true, hintText: hint),
                onChanged: (_) => onChanged(),
              ),
            ),
          IconButton(
            tooltip: 'Remove rule',
            icon: const Icon(Icons.close),
            onPressed: onRemoved,
          ),
        ],
      ),
    );
  }
}
