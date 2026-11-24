import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show setEquals;
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

/// Labelled field that opens a searchable checklist below it, for filtering
/// statistics by several options at once.
///
/// An empty selection means every option, shown as [placeholder].
class MultiStatisticFilterPicker extends StatelessWidget {
  const MultiStatisticFilterPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.label,
    required this.placeholder,
    required this.onChanged,
    required this.onRetry,
  });

  final AsyncValue<List<StatisticFilterOption>> options;

  /// IDs of the chosen options.
  final Set<int> selected;
  final String label;
  final String placeholder;
  final ValueChanged<Set<int>> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return options.when(
      data: (items) => _MultiFilterDropdown(
        items: items,
        selected: selected,
        label: label,
        placeholder: placeholder,
        onChanged: onChanged,
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
}

class _MultiFilterDropdown extends StatefulWidget {
  const _MultiFilterDropdown({
    required this.items,
    required this.selected,
    required this.label,
    required this.placeholder,
    required this.onChanged,
  });

  final List<StatisticFilterOption> items;
  final Set<int> selected;
  final String label;
  final String placeholder;
  final ValueChanged<Set<int>> onChanged;

  @override
  State<_MultiFilterDropdown> createState() => _MultiFilterDropdownState();
}

class _MultiFilterDropdownState extends State<_MultiFilterDropdown> {
  final _controller = MenuController();

  static const _minMenuWidth = 280.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = widget.selected;
    final enabled = widget.items.isNotEmpty;
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        controller: _controller,
        style: StatisticFieldStyle.menuStyle,
        alignmentOffset: const Offset(0, NahpuSpacing.xs),
        consumeOutsideTap: true,
        menuChildren: [
          _MultiFilterMenu(
            width: constraints.maxWidth < _minMenuWidth
                ? _minMenuWidth
                : constraints.maxWidth,
            items: widget.items,
            selected: selected,
            onChanged: widget.onChanged,
          ),
        ],
        builder: (context, controller, child) => _StatisticPickerField(
          label: widget.label,
          text: _fieldText(l10n),
          onTap: enabled ? _toggle : null,
          suffixIcon: selected.isEmpty
              ? IconButton(
                  tooltip: widget.label,
                  onPressed: enabled ? _toggle : null,
                  icon: Icon(
                    controller.isOpen
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                  ),
                )
              : IconButton(
                  tooltip: l10n.projectStatsClearSelection,
                  onPressed: () => widget.onChanged(const {}),
                  icon: const Icon(Icons.clear_rounded),
                ),
        ),
      ),
    );
  }

  String _fieldText(AppLocalizations l10n) {
    final selected = widget.selected;
    if (selected.isEmpty) return widget.placeholder;
    if (selected.length == 1) {
      for (final item in widget.items) {
        if (item.id == selected.first) return item.label;
      }
    }
    return l10n.projectStatsSelectedCount(selected.length);
  }

  void _toggle() {
    // Phones get a bottom sheet: a dropdown leaves little room for the
    // checklist once the keyboard is up.
    if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
      _openSheet();
      return;
    }
    if (_controller.isOpen) {
      _controller.close();
    } else {
      _controller.open();
    }
  }

  Future<void> _openSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _MultiFilterSheet(
        title: widget.label,
        items: widget.items,
        selected: widget.selected,
        onChanged: widget.onChanged,
      ),
    );
  }
}

/// Search box, bulk actions, and checklist inside the multi-select menu.
class _MultiFilterMenu extends StatefulWidget {
  const _MultiFilterMenu({
    this.width,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.inSheet = false,
  });

  /// Menu width, or null to fill the sheet.
  final double? width;

  /// Whether the checklist sits in a phone sheet: it then fills the sheet's
  /// height, and the search box waits for a tap so the keyboard stays shut.
  final bool inSheet;
  final List<StatisticFilterOption> items;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  State<_MultiFilterMenu> createState() => _MultiFilterMenuState();
}

class _MultiFilterMenuState extends State<_MultiFilterMenu> {
  final _searchController = TextEditingController();
  final _listController = ScrollController();
  late Set<int> _selected = {...widget.selected};
  String _query = '';

  /// Order and family the checklist is narrowed to, if any.
  String? _order;
  String? _family;

  static const _maxListHeight = 320.0;

  @override
  void didUpdateWidget(covariant _MultiFilterMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(oldWidget.selected, widget.selected)) {
      _selected = {...widget.selected};
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _query.toLowerCase();
    final filtered = [
      for (final item in widget.items)
        if (item.label.toLowerCase().contains(query) &&
            _TaxonName.matches(item.taxonOrder, _order) &&
            _TaxonName.matches(item.taxonFamily, _family))
          item,
    ];
    final hasTaxa = widget.items.any(
      (item) => item.taxonOrder != null || item.taxonFamily != null,
    );
    final allShown =
        filtered.isNotEmpty &&
        filtered.every((item) => _selected.contains(item.id));
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisSize: widget.inSheet ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NahpuSpacing.md,
              NahpuSpacing.xs,
              NahpuSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('statistics-multi-filter-search'),
                    controller: _searchController,
                    autofocus: !widget.inSheet,
                    decoration: InputDecoration(
                      hintText: l10n.projectBatchSearch,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.documentSelectionClearSearch,
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ).applyDefaults(StatisticFieldStyle.decorationTheme),
                    onChanged: (value) => setState(() => _query = value.trim()),
                  ),
                ),
                if (hasTaxa)
                  _TaxonFilterButton(
                    items: widget.items,
                    order: _order,
                    family: _family,
                    onOrder: _setOrder,
                    onFamily: (value) => setState(() => _family = value),
                    onClear: () => setState(() {
                      _order = null;
                      _family = null;
                    }),
                  ),
              ],
            ),
          ),
          if (_order != null || _family != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NahpuSpacing.md,
                NahpuSpacing.sm,
                NahpuSpacing.md,
                0,
              ),
              child: Wrap(
                spacing: NahpuSpacing.sm,
                runSpacing: NahpuSpacing.sm,
                children: [
                  if (_order case final order?)
                    InputChip(
                      key: const ValueKey('statistics-multi-filter-chip-order'),
                      label: Text(
                        l10n.projectStatsTaxonFilterValue(
                          l10n.projectTaxonOrder,
                          order,
                        ),
                      ),
                      onDeleted: () => _setOrder(null),
                    ),
                  if (_family case final family?)
                    InputChip(
                      key: const ValueKey(
                        'statistics-multi-filter-chip-family',
                      ),
                      label: Text(
                        l10n.projectStatsTaxonFilterValue(
                          l10n.projectTaxonFamily,
                          family,
                        ),
                      ),
                      onDeleted: () => setState(() => _family = null),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xs),
            child: Row(
              children: [
                TextButton(
                  onPressed: filtered.isEmpty || allShown
                      ? null
                      : () => _update({
                          ..._selected,
                          for (final item in filtered) item.id,
                        }),
                  child: Text(l10n.commonSelectAll),
                ),
                TextButton(
                  onPressed: _selected.isEmpty ? null : () => _update({}),
                  child: Text(l10n.commonClear),
                ),
              ],
            ),
          ),
          const Divider(height: NahpuStroke.thin),
          _ListHeight(
            fill: widget.inSheet,
            maxHeight: _maxListHeight,
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(NahpuSpacing.xl),
                    child: Text(
                      l10n.projectStatsNoMatchingChoices,
                      textAlign: TextAlign.center,
                    ),
                  )
                // A plain column: the menu measures its children's
                // intrinsic width, which a lazy list cannot report.
                : Scrollbar(
                    controller: _listController,
                    child: SingleChildScrollView(
                      // Its own controller: the menu already scrolls with the
                      // primary one.
                      controller: _listController,
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final item in filtered)
                            CheckboxListTile(
                              key: ValueKey(
                                'statistics-multi-filter-${item.id}',
                              ),
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                item.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              value: _selected.contains(item.id),
                              onChanged: (checked) => _update({
                                for (final id in _selected)
                                  if (id != item.id) id,
                                if (checked ?? false) item.id,
                              }),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Narrows to [order], dropping a family filter outside it.
  void _setOrder(String? order) {
    setState(() {
      _order = order;
      final family = _family;
      if (order == null || family == null) return;
      final familyInOrder = widget.items.any(
        (item) =>
            _TaxonName.matches(item.taxonOrder, order) &&
            _TaxonName.matches(item.taxonFamily, family),
      );
      if (!familyInOrder) _family = null;
    });
  }

  void _update(Set<int> next) {
    setState(() => _selected = next);
    widget.onChanged({...next});
  }
}

/// Order and family names compared without case or surrounding spaces.
abstract final class _TaxonName {
  static String key(String name) => name.trim().toLowerCase();

  /// Whether [value] passes a [filter]; a null filter passes everything.
  static bool matches(String? value, String? filter) =>
      filter == null || (value != null && key(value) == key(filter));

  /// Distinct non-empty names among [values] with how many times each
  /// occurs, sorted by name. A capitalized spelling wins over others;
  /// otherwise the first one met is kept.
  static bool _capitalized(String name) {
    final first = name.substring(0, 1);
    return first != first.toLowerCase();
  }

  static List<({String name, int count})> tally(Iterable<String?> values) {
    final names = <String, String>{};
    final counts = <String, int>{};
    for (final value in values) {
      if (value == null || value.trim().isEmpty) continue;
      final k = key(value);
      final name = value.trim();
      final kept = names[k];
      // Prefer a capitalized spelling, the usual form of these names.
      if (kept == null || (!_capitalized(kept) && _capitalized(name))) {
        names[k] = name;
      }
      counts[k] = (counts[k] ?? 0) + 1;
    }
    final tallies = [
      for (final MapEntry(:key, :value) in names.entries)
        (name: value, count: counts[key]!),
    ];
    tallies.sort((a, b) => key(a.name).compareTo(key(b.name)));
    return tallies;
  }
}

/// Filter button beside the species search, narrowing the checklist to an
/// order or family so a whole group can be ticked at once.
class _TaxonFilterButton extends StatefulWidget {
  const _TaxonFilterButton({
    required this.items,
    required this.order,
    required this.family,
    required this.onOrder,
    required this.onFamily,
    required this.onClear,
  });

  final List<StatisticFilterOption> items;
  final String? order;
  final String? family;
  final ValueChanged<String?> onOrder;
  final ValueChanged<String?> onFamily;
  final VoidCallback onClear;

  @override
  State<_TaxonFilterButton> createState() => _TaxonFilterButtonState();
}

class _TaxonFilterButtonState extends State<_TaxonFilterButton> {
  final _controller = MenuController();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = [widget.order, widget.family].nonNulls.length;
    final orders = _TaxonName.tally(
      widget.items.map((item) => item.taxonOrder),
    );
    final families = _TaxonName.tally([
      for (final item in widget.items)
        if (_TaxonName.matches(item.taxonOrder, widget.order)) item.taxonFamily,
    ]);
    return MenuAnchor(
      controller: _controller,
      style: StatisticFieldStyle.menuStyle,
      menuChildren: [
        _TaxonSubmenu(
          key: const ValueKey('statistics-multi-filter-order'),
          rank: 'order',
          label: l10n.projectTaxonOrder,
          names: orders,
          selected: widget.order,
          onSelected: (value) => _pick(widget.onOrder, value),
        ),
        _TaxonSubmenu(
          key: const ValueKey('statistics-multi-filter-family'),
          rank: 'family',
          label: l10n.projectTaxonFamily,
          names: families,
          selected: widget.family,
          onSelected: (value) => _pick(widget.onFamily, value),
        ),
        const Divider(height: NahpuStroke.thin),
        MenuItemButton(
          key: const ValueKey('statistics-multi-filter-taxon-clear'),
          // Kept open by hand: activating would also close the checklist
          // menu this one sits in.
          closeOnActivate: false,
          leadingIcon: const Icon(Icons.filter_list_off_rounded),
          onPressed: active == 0
              ? null
              : () {
                  _controller.close();
                  widget.onClear();
                },
          child: Text(l10n.commonClear),
        ),
      ],
      builder: (context, controller, child) => IconButton(
        key: const ValueKey('statistics-multi-filter-taxon'),
        tooltip: l10n.projectStatsFilterByTaxon,
        isSelected: active > 0,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: Badge(
          isLabelVisible: active > 0,
          label: Text('$active'),
          child: const Icon(Icons.filter_list_rounded),
        ),
      ),
    );
  }

  void _pick(ValueChanged<String?> onChanged, String? value) {
    _controller.close();
    onChanged(value);
  }
}

/// Order or family names to narrow the checklist to, each with its number of
/// species. Picking the current name again clears it.
class _TaxonSubmenu extends StatelessWidget {
  const _TaxonSubmenu({
    super.key,
    required this.rank,
    required this.label,
    required this.names,
    required this.selected,
    required this.onSelected,
  });

  final String rank;
  final String label;
  final List<({String name, int count})> names;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SubmenuButton(
      menuStyle: StatisticFieldStyle.menuStyle,
      menuChildren: [
        for (final (:name, :count) in names)
          MenuItemButton(
            key: ValueKey('statistics-multi-filter-$rank-$name'),
            closeOnActivate: false,
            leadingIcon: Icon(
              Icons.check_rounded,
              color: _TaxonName.matches(name, selected) && selected != null
                  ? null
                  : Colors.transparent,
            ),
            trailingIcon: Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            onPressed: () => onSelected(
              selected != null && _TaxonName.matches(name, selected)
                  ? null
                  : name,
            ),
            child: Text(name),
          ),
      ],
      child: Text(
        selected == null
            ? label
            : context.l10n.projectStatsTaxonFilterValue(label, selected!),
      ),
    );
  }
}

/// The checklist's height: the rest of a sheet, or at most [maxHeight] in a
/// dropdown menu.
class _ListHeight extends StatelessWidget {
  const _ListHeight({
    required this.fill,
    required this.maxHeight,
    required this.child,
  });

  final bool fill;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (fill) return Expanded(child: child);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: child,
    );
  }
}

/// Phone version of the multi-select menu: the same checklist in a bottom
/// sheet, with a Done button.
class _MultiFilterSheet extends StatelessWidget {
  const _MultiFilterSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<StatisticFilterOption> items;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Padding(
        // Lifts the checklist above the keyboard while searching.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom + NahpuSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  FilledButton(
                    key: const ValueKey('statistics-multi-filter-done'),
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.commonDone),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NahpuSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NahpuSpacing.xs,
                ),
                child: _MultiFilterMenu(
                  items: items,
                  selected: selected,
                  onChanged: onChanged,
                  inSheet: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
