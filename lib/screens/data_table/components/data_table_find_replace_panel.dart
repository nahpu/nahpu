import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_find_replace.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// What the find panel shows about the table behind it.
class DataTableFindStatus {
  const DataTableFindStatus({
    required this.matchCount,
    required this.currentMatch,
    required this.isEditMode,
    required this.isReplacing,
  });

  /// Matches on the current page.
  final int matchCount;

  /// One-based position of the focused match, or null when the focused cell
  /// isn't one.
  final int? currentMatch;
  final bool isEditMode;

  /// Whether Replace all is reading records.
  final bool isReplacing;
}

/// Finds text in the visible columns and replaces it, shown in a dialog on
/// wide screens and a bottom sheet on compact ones.
///
/// Matches stay highlighted in the table while the panel is open; Replace
/// all reaches every record the search and filters match. Replacing needs
/// edit mode.
class DataTableFindReplacePanel extends StatefulWidget {
  const DataTableFindReplacePanel({
    super.key,
    required this.initial,
    required this.columns,
    required this.listenable,
    required this.status,
    required this.onChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onReplace,
    required this.onReplaceAll,
    required this.onEnableEditMode,
    this.showCloseButton = true,
  });

  /// Options the panel opens with, such as the last search.
  final DataTableFindOptions initial;

  /// Visible columns the search can be limited to.
  final List<DataTableColumn> columns;

  /// Notifies when [status] may have changed.
  final Listenable listenable;
  final ValueGetter<DataTableFindStatus> status;
  final ValueChanged<DataTableFindOptions> onChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReplace;
  final VoidCallback onReplaceAll;

  /// Turns on the table's edit mode, which replacing needs.
  final VoidCallback onEnableEditMode;

  /// False in a bottom sheet, which closes with a drag or a tap outside.
  final bool showCloseButton;

  @override
  State<DataTableFindReplacePanel> createState() =>
      _DataTableFindReplacePanelState();
}

class _DataTableFindReplacePanelState extends State<DataTableFindReplacePanel> {
  late final _find = TextEditingController(text: widget.initial.text);
  late final _replace = TextEditingController(text: widget.initial.replacement);
  late String? _columnKey =
      widget.columns.any((column) => column.key == widget.initial.columnKey)
      ? widget.initial.columnKey
      : null;
  late bool _matchCase = widget.initial.matchCase;
  late bool _wholeCell = widget.initial.wholeCell;

  @override
  void dispose() {
    _find.dispose();
    _replace.dispose();
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
      child: ListenableBuilder(
        listenable: widget.listenable,
        builder: (context, _) {
          final status = widget.status();
          final hasText = _find.text.isNotEmpty;
          final canReplace =
              status.isEditMode && hasText && !status.isReplacing;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Find and replace',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  if (widget.showCloseButton)
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
              const SizedBox(height: NahpuSpacing.lg),
              TextField(
                controller: _find,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Find',
                  prefixIcon: const Icon(Icons.search),
                  suffixText: hasText ? _countLabel(status) : null,
                ),
                onChanged: (_) => _set(() {}),
                onSubmitted: (_) => widget.onNext(),
              ),
              const SizedBox(height: NahpuSpacing.lg),
              TextField(
                controller: _replace,
                enabled: status.isEditMode,
                decoration: InputDecoration(
                  labelText: 'Replace with',
                  helperText: status.isEditMode
                      ? null
                      : 'Replacing needs edit mode.',
                  prefixIcon: const Icon(Icons.find_replace),
                ),
                onChanged: (_) => _notify(),
                onSubmitted: (_) {
                  if (canReplace) widget.onReplace();
                },
              ),
              const SizedBox(height: NahpuSpacing.lg),
              Wrap(
                spacing: NahpuSpacing.md,
                runSpacing: NahpuSpacing.md,
                children: [
                  DataTableFindColumnMenu(
                    columnKey: _columnKey,
                    columns: widget.columns,
                    onChanged: (key) => _set(() => _columnKey = key),
                  ),
                  FilterChip(
                    label: const Text('Match case'),
                    selected: _matchCase,
                    onSelected: (value) => _set(() => _matchCase = value),
                  ),
                  FilterChip(
                    label: const Text('Whole cell'),
                    selected: _wholeCell,
                    onSelected: (value) => _set(() => _wholeCell = value),
                  ),
                ],
              ),
              const SizedBox(height: NahpuSpacing.xl),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous match',
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: hasText ? widget.onPrevious : null,
                  ),
                  IconButton(
                    tooltip: 'Next match',
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: hasText ? widget.onNext : null,
                  ),
                  const Spacer(),
                  if (!status.isEditMode)
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Turn on edit mode'),
                      onPressed: widget.onEnableEditMode,
                    )
                  else ...[
                    TextButton(
                      onPressed: canReplace ? widget.onReplace : null,
                      child: const Text('Replace'),
                    ),
                    const SizedBox(width: NahpuSpacing.xs),
                    FilledButton(
                      onPressed: canReplace ? widget.onReplaceAll : null,
                      child: status.isReplacing
                          ? const SizedBox.square(
                              dimension: NahpuControlSize.iconSmall,
                              child: CircularProgressIndicator(
                                strokeWidth: NahpuStroke.regular,
                              ),
                            )
                          : const Text('Replace all'),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Counts matches on the current page.
  String _countLabel(DataTableFindStatus status) {
    if (status.matchCount == 0) return 'No matches';
    final current = status.currentMatch;
    return current == null
        ? '${status.matchCount} found'
        : '$current of ${status.matchCount}';
  }

  void _set(VoidCallback change) {
    setState(change);
    _notify();
  }

  void _notify() => widget.onChanged(
    DataTableFindOptions(
      text: _find.text,
      replacement: _replace.text,
      columnKey: _columnKey,
      matchCase: _matchCase,
      wholeCell: _wholeCell,
    ),
  );
}

/// Chooses the column the find panel searches.
class DataTableFindColumnMenu extends StatelessWidget {
  const DataTableFindColumnMenu({
    super.key,
    required this.columnKey,
    required this.columns,
    required this.onChanged,
  });

  /// Null searches every visible column.
  final String? columnKey;
  final List<DataTableColumn> columns;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    String? label;
    for (final column in columns) {
      if (column.key == columnKey) label = column.label;
    }
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(
            columnKey == null ? Icons.check : null,
            size: NahpuControlSize.iconMedium,
          ),
          onPressed: () => onChanged(null),
          child: const Text('All visible columns'),
        ),
        const Divider(height: NahpuStroke.thin),
        for (final column in columns)
          MenuItemButton(
            leadingIcon: Icon(
              column.key == columnKey ? Icons.check : null,
              size: NahpuControlSize.iconMedium,
            ),
            onPressed: () => onChanged(column.key),
            child: Text(column.label),
          ),
      ],
      builder: (context, controller, _) => ActionChip(
        avatar: const Icon(
          Icons.view_column_outlined,
          size: NahpuControlSize.iconSmall,
        ),
        label: Text(label ?? 'All visible columns'),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
