import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Shared look for the statistics option fields, so dropdown menus and
/// search pickers line up at one height with the same rounded outline.
abstract final class StatisticFieldStyle {
  static const borderRadius = BorderRadius.all(Radius.circular(NahpuRadius.md));
  static const double height = NahpuControlSize.touchTarget;
  static const decorationTheme = InputDecorationTheme(
    isDense: true,
    constraints: BoxConstraints.tightFor(height: height),
    contentPadding: EdgeInsets.symmetric(
      horizontal: NahpuSpacing.lg,
      vertical: NahpuSpacing.lg,
    ),
    // Trailing buttons are sized to fit inside the field, so the dropdown
    // arrow and the picker's search button keep every field at [height].
    suffixIconConstraints: BoxConstraints.tightFor(
      width: NahpuControlSize.control,
      height: NahpuControlSize.control,
    ),
    border: OutlineInputBorder(borderRadius: borderRadius),
  );
  static const menuStyle = MenuStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: borderRadius),
    ),
  );
}

class SearchableStatisticFilterPicker extends StatelessWidget {
  const SearchableStatisticFilterPicker({
    super.key,
    required this.options,
    required this.selected,
    this.label,
    required this.title,
    required this.placeholder,
    required this.onChanged,
    required this.onRetry,
  });

  final AsyncValue<List<StatisticFilterOption>> options;
  final StatisticFilterOption? selected;

  /// Field label. When set, the picker draws as a labelled outlined field
  /// that lines up with dropdown menus; otherwise as an outlined button.
  final String? label;
  final String title;
  final String placeholder;
  final ValueChanged<StatisticFilterOption?> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return options.when(
      data: (items) => label == null
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: items.isEmpty
                        ? null
                        : () => _pick(context, items),
                    icon: const Icon(Icons.search_rounded),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selected?.label ?? placeholder,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                if (selected != null)
                  IconButton(
                    tooltip: context.l10n.projectStatsClearSelection,
                    onPressed: () => onChanged(null),
                    icon: const Icon(Icons.clear_rounded),
                  ),
              ],
            )
          : _StatisticPickerField(
              label: label!,
              text: selected?.label ?? placeholder,
              onTap: items.isEmpty ? null : () => _pick(context, items),
              suffixIcon: selected == null
                  ? IconButton(
                      tooltip: title,
                      onPressed: items.isEmpty
                          ? null
                          : () => _pick(context, items),
                      icon: const Icon(Icons.search_rounded),
                    )
                  : IconButton(
                      tooltip: context.l10n.projectStatsClearSelection,
                      onPressed: () => onChanged(null),
                      icon: const Icon(Icons.clear_rounded),
                    ),
            ),
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => Row(
        children: [
          Expanded(
            child: Text(context.l10n.projectStatsChoicesLoadError('$error')),
          ),
          IconButton(
            tooltip: context.l10n.commonRetry,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    List<StatisticFilterOption> items,
  ) async {
    final result = await showModalBottomSheet<StatisticFilterOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          SearchableStatisticFilterSheet(title: title, options: items),
    );
    if (result != null) onChanged(result);
  }
}

/// Read-only text field that opens a picker on tap.
///
/// It is a [TextField] rather than an [InputDecorator] so it measures exactly
/// like the [DropdownMenu] fields beside it.
class _StatisticPickerField extends StatefulWidget {
  const _StatisticPickerField({
    required this.label,
    required this.text,
    required this.onTap,
    required this.suffixIcon,
  });

  final String label;
  final String text;
  final VoidCallback? onTap;
  final Widget suffixIcon;

  @override
  State<_StatisticPickerField> createState() => _StatisticPickerFieldState();
}

class _StatisticPickerFieldState extends State<_StatisticPickerField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

  @override
  void didUpdateWidget(covariant _StatisticPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _controller.text = widget.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      canRequestFocus: false,
      mouseCursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onTap: widget.onTap,
      decoration: InputDecoration(
        labelText: widget.label,
        enabled: widget.onTap != null,
        suffixIcon: widget.suffixIcon,
      ).applyDefaults(StatisticFieldStyle.decorationTheme),
    );
  }
}

class SearchableStatisticFilterSheet extends StatefulWidget {
  const SearchableStatisticFilterSheet({
    super.key,
    required this.title,
    required this.options,
  });

  final String title;
  final List<StatisticFilterOption> options;

  @override
  State<SearchableStatisticFilterSheet> createState() =>
      _SearchableStatisticFilterSheetState();
}

class _SearchableStatisticFilterSheetState
    extends State<SearchableStatisticFilterSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final filtered = widget.options
        .where((option) => option.label.toLowerCase().contains(query))
        .toList(growable: false);
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SearchBar(
                controller: _searchController,
                hintText: context.l10n.projectBatchSearch,
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      tooltip: context.l10n.documentSelectionClearSearch,
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
                ],
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(context.l10n.projectStatsNoMatchingChoices),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          return ListTile(
                            title: Text(option.label),
                            onTap: () => Navigator.pop(context, option),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
