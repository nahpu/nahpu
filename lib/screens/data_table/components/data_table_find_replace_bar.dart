import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_find_replace.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Finds text in the visible columns and replaces it.
///
/// Matches on the page are stepped through in place; Replace all reaches
/// every record the search and filters match. Replacing needs edit mode.
class DataTableFindReplaceBar extends StatefulWidget {
  const DataTableFindReplaceBar({
    super.key,
    required this.columns,
    required this.isEditMode,
    required this.matchCount,
    required this.currentMatch,
    required this.isReplacing,
    required this.onChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onReplace,
    required this.onReplaceAll,
    required this.onClose,
  });

  /// Visible columns the search can be limited to.
  final List<DataTableColumn> columns;
  final bool isEditMode;

  /// Matches on the current page.
  final int matchCount;

  /// One-based position of the focused match, or null when the focused cell
  /// isn't one.
  final int? currentMatch;

  /// Whether Replace all is reading records.
  final bool isReplacing;
  final ValueChanged<DataTableFindOptions> onChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReplace;
  final VoidCallback onReplaceAll;
  final VoidCallback onClose;

  @override
  State<DataTableFindReplaceBar> createState() =>
      _DataTableFindReplaceBarState();
}

class _DataTableFindReplaceBarState extends State<DataTableFindReplaceBar> {
  final _find = TextEditingController();
  final _replace = TextEditingController();
  String? _columnKey;
  bool _matchCase = false;
  bool _wholeCell = false;

  @override
  void didUpdateWidget(DataTableFindReplaceBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A column hidden since it was picked no longer limits the search.
    if (_columnKey != null &&
        !widget.columns.any((column) => column.key == _columnKey)) {
      _columnKey = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notify();
      });
    }
  }

  @override
  void dispose() {
    _find.dispose();
    _replace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _find.text.isNotEmpty;
    final canReplace = widget.isEditMode && hasText && !widget.isReplacing;
    // Counts matches on the current page.
    final count = !hasText
        ? null
        : widget.matchCount == 0
        ? 'No matches'
        : widget.currentMatch == null
        ? '${widget.matchCount} found'
        : '${widget.currentMatch} of ${widget.matchCount}';
    // One scrolling row keeps the bar short on phones, where the keyboard
    // takes much of the screen.
    final options = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          DataTableFindColumnMenu(
            columnKey: _columnKey,
            columns: widget.columns,
            onChanged: (key) => _set(() => _columnKey = key),
          ),
          const SizedBox(width: NahpuSpacing.md),
          FilterChip(
            label: const Text('Match case'),
            selected: _matchCase,
            onSelected: (value) => _set(() => _matchCase = value),
          ),
          const SizedBox(width: NahpuSpacing.md),
          FilterChip(
            label: const Text('Whole cell'),
            selected: _wholeCell,
            onSelected: (value) => _set(() => _wholeCell = value),
          ),
        ],
      ),
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NahpuSpacing.md,
          0,
          NahpuSpacing.md,
          NahpuSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DataTableFindField(
                    controller: _find,
                    hint: 'Find',
                    icon: Icons.search,
                    count: count,
                    autofocus: true,
                    onChanged: (_) => _set(() {}),
                    onSubmitted: (_) => widget.onNext(),
                  ),
                ),
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
                IconButton(
                  tooltip: 'Close find and replace',
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.md),
            Row(
              children: [
                Expanded(
                  child: DataTableFindField(
                    controller: _replace,
                    hint: widget.isEditMode
                        ? 'Replace with'
                        : 'Turn on edit mode to replace',
                    icon: Icons.find_replace,
                    enabled: widget.isEditMode,
                    onChanged: (_) => _notify(),
                    onSubmitted: (_) {
                      if (canReplace) widget.onReplace();
                    },
                  ),
                ),
                const SizedBox(width: NahpuSpacing.md),
                TextButton(
                  onPressed: canReplace ? widget.onReplace : null,
                  child: const Text('Replace'),
                ),
                TextButton(
                  onPressed: canReplace ? widget.onReplaceAll : null,
                  child: widget.isReplacing
                      ? const SizedBox.square(
                          dimension: NahpuControlSize.iconSmall,
                          child: CircularProgressIndicator(
                            strokeWidth: NahpuStroke.regular,
                          ),
                        )
                      : const Text('Replace all'),
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.xs),
            options,
          ],
        ),
      ),
    );
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

/// Dense text field for the find bar.
class DataTableFindField extends StatelessWidget {
  const DataTableFindField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onChanged,
    required this.onSubmitted,
    this.count,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  /// Matches on the current page, shown at the field's end.
  final String? count;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NahpuControlSize.control,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        enabled: enabled,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          prefixIcon: Icon(icon, size: NahpuControlSize.iconMedium),
          suffixText: count,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: NahpuSpacing.lg,
          ),
        ),
      ),
    );
  }
}

/// Chooses the column the find bar searches.
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
