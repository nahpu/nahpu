import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/screens/shared/common/catalog_fmt_icon.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// One row with record type, taxon group, search, filters, and columns.
/// Mid-width screens split it in two. Phones keep a single row: the record
/// type sits at the start of the search field, and the taxon group and
/// search field are picked in the filter sheet.
class DataTableToolbar extends StatelessWidget {
  const DataTableToolbar({
    super.key,
    required this.type,
    required this.specimenType,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchField,
    required this.searchableColumns,
    required this.quickFilters,
    required this.ruleCount,
    required this.onTypeChanged,
    required this.onSpecimenTypeChanged,
    required this.onSearchChanged,
    required this.onSearchFieldChanged,
    required this.onQuickFilterToggled,
    required this.onEditRules,
    required this.onPickColumns,
  });

  final DataTableRecordType type;
  final SpecimenRecordType specimenType;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  /// Field the search is limited to; null searches the visible columns.
  final DataTableColumn? searchField;
  final List<DataTableColumn> searchableColumns;
  final Set<DataTableQuickFilter> quickFilters;
  final int ruleCount;
  final ValueChanged<DataTableRecordType> onTypeChanged;
  final ValueChanged<SpecimenRecordType> onSpecimenTypeChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DataTableColumn?> onSearchFieldChanged;
  final ValueChanged<DataTableQuickFilter> onQuickFilterToggled;
  final VoidCallback? onEditRules;

  /// Null until the first page loads.
  final VoidCallback? onPickColumns;

  @override
  Widget build(BuildContext context) {
    final isCompact =
        MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    final menus = [
      RecordTypeMenu(type: type, onChanged: onTypeChanged),
      if (type == DataTableRecordType.specimenRecords) ...[
        const SizedBox(width: NahpuSpacing.md),
        SpecimenTypeMenu(
          specimenType: specimenType,
          onChanged: onSpecimenTypeChanged,
        ),
      ],
    ];
    final search = DataTableSearchField(
      controller: searchController,
      focusNode: searchFocusNode,
      hint: searchField == null
          ? context.l10n.dataTableSearchIn(
              type.localizedLabel(context.l10n).toLowerCase(),
            )
          : context.l10n.dataTableSearchIn(searchField!.label),
      onChanged: onSearchChanged,
      scope: isCompact
          ? RecordTypeMenu(
              type: type,
              isCompact: true,
              onChanged: onTypeChanged,
            )
          : DataTableSearchScopeMenu(
              field: searchField,
              columns: searchableColumns,
              onChanged: onSearchFieldChanged,
            ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // Large screens have room to name the filter and column buttons.
        final showLabels = constraints.maxWidth >= NahpuBreakpoints.laptop;
        final tools = [
          DataTableFilterMenu(
            type: type,
            selected: quickFilters,
            ruleCount: ruleCount,
            showLabel: showLabels,
            onToggled: onQuickFilterToggled,
            onEditRules: onEditRules,
            // The sheet takes over the pickers the phone row leaves out.
            specimenType: isCompact ? specimenType : null,
            onSpecimenTypeChanged: onSpecimenTypeChanged,
            searchField: searchField,
            onPickSearchField: isCompact && searchableColumns.isNotEmpty
                ? () => _pickSearchField(context)
                : null,
          ),
          if (showLabels) const SizedBox(width: NahpuSpacing.xs),
          DataTableToolButton(
            icon: Icons.view_column_outlined,
            label: context.l10n.projectBatchStepColumns,
            showLabel: showLabels,
            onPressed: onPickColumns,
          ),
        ];
        if (isCompact) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: NahpuSpacing.xs),
              ...tools,
            ],
          );
        }
        if (constraints.maxWidth >= NahpuBreakpoints.desktop) {
          return Row(
            children: [
              ...menus,
              const SizedBox(width: NahpuSpacing.md),
              Expanded(child: search),
              SizedBox(width: showLabels ? NahpuSpacing.md : NahpuSpacing.xs),
              ...tools,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: menus),
            ),
            const SizedBox(height: NahpuSpacing.md),
            Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: NahpuSpacing.xs),
                ...tools,
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickSearchField(BuildContext context) async {
    final choice = await showDataTableSearchScopeSheet(
      context,
      field: searchField,
      columns: searchableColumns,
    );
    if (choice != null) onSearchFieldChanged(choice.column);
  }
}

class DataTableToolbarDivider extends StatelessWidget {
  const DataTableToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: NahpuControlSize.iconMedium,
      child: VerticalDivider(width: NahpuSpacing.xl),
    );
  }
}

/// Pill button that opens a menu, with a dropdown arrow after its label.
class DataTableMenuButton extends StatelessWidget {
  const DataTableMenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
  });

  /// Leading icon, sized by the button.
  final Widget icon;
  final String label;
  final MenuController controller;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, NahpuControlSize.control),
        padding: const EdgeInsetsDirectional.only(
          start: NahpuSpacing.lg,
          end: NahpuSpacing.md,
        ),
        shape: const StadiumBorder(),
      ),
      onPressed: () =>
          controller.isOpen ? controller.close() : controller.open(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme.merge(
            data: const IconThemeData(size: NahpuControlSize.iconSmall),
            child: icon,
          ),
          const SizedBox(width: NahpuSpacing.md),
          Text(label),
          const SizedBox(width: NahpuSpacing.xs),
          const Icon(Icons.arrow_drop_down, size: NahpuControlSize.iconMedium),
        ],
      ),
    );
  }
}

/// Chooses the kind of record the table shows. [isCompact] shrinks it to
/// an icon at the start of the phone search field, picking from a bottom
/// sheet.
class RecordTypeMenu extends StatelessWidget {
  const RecordTypeMenu({
    super.key,
    required this.type,
    required this.onChanged,
    this.isCompact = false,
  });

  final DataTableRecordType type;
  final ValueChanged<DataTableRecordType> onChanged;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Tooltip(
        message: type.label,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => _showSheet(context),
          child: const SizedBox(
            height: NahpuControlSize.control,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: NahpuSpacing.lg),
                Icon(
                  Icons.table_chart_outlined,
                  size: NahpuControlSize.iconMedium,
                ),
                Icon(Icons.arrow_drop_down, size: NahpuControlSize.iconMedium),
                VerticalDivider(
                  width: NahpuSpacing.md,
                  indent: NahpuSpacing.md,
                  endIndent: NahpuSpacing.md,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return MenuAnchor(
      menuChildren: [
        for (final value in DataTableRecordType.values)
          MenuItemButton(
            leadingIcon: Icon(
              value == type ? Icons.check : null,
              size: NahpuControlSize.iconMedium,
            ),
            onPressed: () => onChanged(value),
            child: Text(value.label),
          ),
      ],
      builder: (context, controller, _) => DataTableMenuButton(
        icon: const Icon(Icons.table_chart_outlined),
        label: type.label,
        controller: controller,
      ),
    );
  }

  Future<void> _showSheet(BuildContext context) async {
    final choice = await showModalBottomSheet<DataTableRecordType>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DataTableChoiceSheet(
        title: context.l10n.homeSearchRecordType,
        children: [
          for (final value in DataTableRecordType.values)
            DataTableSearchScopeTile(
              label: value.label,
              isSelected: value == type,
              onTap: () => Navigator.of(context).pop(value),
            ),
        ],
      ),
    );
    if (choice != null && choice != type) onChanged(choice);
  }
}

/// A titled bottom sheet of choices that scrolls when they run long.
class DataTableChoiceSheet extends StatelessWidget {
  const DataTableChoiceSheet({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NahpuSpacing.xl,
                0,
                NahpuSpacing.xl,
                NahpuSpacing.md,
              ),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Preset filters for the record type, checked in place, and the field
/// rules editor. The badge counts every active filter. Compact screens list
/// them in a bottom sheet instead of a menu, along with the taxon group and
/// search field when [specimenType] and [onPickSearchField] are given.
class DataTableFilterMenu extends StatelessWidget {
  const DataTableFilterMenu({
    super.key,
    required this.type,
    required this.selected,
    required this.ruleCount,
    required this.showLabel,
    required this.onToggled,
    required this.onEditRules,
    this.specimenType,
    this.onSpecimenTypeChanged,
    this.searchField,
    this.onPickSearchField,
  });

  final DataTableRecordType type;
  final Set<DataTableQuickFilter> selected;
  final int ruleCount;
  final bool showLabel;
  final ValueChanged<DataTableQuickFilter> onToggled;

  /// Null until the first page loads.
  final VoidCallback? onEditRules;

  /// The taxon group to offer in the sheet; null leaves it out.
  final SpecimenRecordType? specimenType;
  final ValueChanged<SpecimenRecordType>? onSpecimenTypeChanged;

  /// Field the search is limited to, shown in the sheet with
  /// [onPickSearchField]; a null callback leaves it out.
  final DataTableColumn? searchField;
  final VoidCallback? onPickSearchField;

  @override
  Widget build(BuildContext context) {
    final count = selected.length + ruleCount;
    if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
      // The taxon group and search field narrow the table too, so they
      // count while the sheet holds them.
      final hasTaxa =
          type == DataTableRecordType.specimenRecords &&
          specimenType != null &&
          specimenType != SpecimenRecordType.allTaxa;
      final hasField = onPickSearchField != null && searchField != null;
      return DataTableToolButton(
        icon: Icons.filter_list,
        label: context.l10n.dataTableFilters,
        showLabel: showLabel,
        badgeCount: count + (hasTaxa ? 1 : 0) + (hasField ? 1 : 0),
        onPressed: () => _showSheet(context),
      );
    }
    return MenuAnchor(
      menuChildren: [
        for (final filter in type.quickFilters)
          CheckboxMenuButton(
            value: selected.contains(filter),
            closeOnActivate: false,
            onChanged: (_) => onToggled(filter),
            child: Text(filter.localizedLabel(context.l10n)),
          ),
        if (type.quickFilters.isNotEmpty)
          const Divider(height: NahpuStroke.thin),
        MenuItemButton(
          leadingIcon: const Icon(
            Icons.tune,
            size: NahpuControlSize.iconMedium,
          ),
          onPressed: onEditRules,
          child: Text(
            ruleCount == 0
                ? context.l10n.dataTableAddFieldRules
                : context.l10n.dataTableEditFieldRules,
          ),
        ),
      ],
      builder: (context, controller, _) => DataTableToolButton(
        icon: Icons.filter_list,
        label: context.l10n.dataTableFilters,
        showLabel: showLabel,
        badgeCount: count,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  Future<void> _showSheet(BuildContext context) async {
    final action = await showModalBottomSheet<DataTableFilterSheetAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DataTableFilterSheet(
        type: type,
        selected: selected,
        ruleCount: ruleCount,
        canEditRules: onEditRules != null,
        onToggled: onToggled,
        specimenType: type == DataTableRecordType.specimenRecords
            ? specimenType
            : null,
        onSpecimenTypeChanged: onSpecimenTypeChanged,
        searchField: searchField,
        canPickSearchField: onPickSearchField != null,
      ),
    );
    // Follow-up pickers open once the sheet is out of the way.
    switch (action) {
      case DataTableFilterSheetAction.editRules:
        onEditRules?.call();
      case DataTableFilterSheetAction.pickSearchField:
        onPickSearchField?.call();
      case null:
        break;
    }
  }
}

/// What [DataTableFilterSheet] closes to open next.
enum DataTableFilterSheetAction { editRules, pickSearchField }

/// The filter menu as a bottom sheet. The taxon group and presets apply as
/// they are picked; the field rules and search field open their own
/// pickers through [DataTableFilterSheetAction].
class DataTableFilterSheet extends StatefulWidget {
  const DataTableFilterSheet({
    super.key,
    required this.type,
    required this.selected,
    required this.ruleCount,
    required this.canEditRules,
    required this.onToggled,
    this.specimenType,
    this.onSpecimenTypeChanged,
    this.searchField,
    this.canPickSearchField = false,
  });

  final DataTableRecordType type;
  final Set<DataTableQuickFilter> selected;
  final int ruleCount;
  final bool canEditRules;
  final ValueChanged<DataTableQuickFilter> onToggled;

  /// Shows the taxon group choices when set.
  final SpecimenRecordType? specimenType;
  final ValueChanged<SpecimenRecordType>? onSpecimenTypeChanged;
  final DataTableColumn? searchField;
  final bool canPickSearchField;

  @override
  State<DataTableFilterSheet> createState() => _DataTableFilterSheetState();
}

class _DataTableFilterSheetState extends State<DataTableFilterSheet> {
  // The sheet's route doesn't rebuild with the table, so it tracks the
  // picks itself.
  late final Set<DataTableQuickFilter> _selected = {...widget.selected};
  late SpecimenRecordType? _specimenType = widget.specimenType;

  @override
  Widget build(BuildContext context) {
    final specimenType = _specimenType;
    final searchField = widget.searchField;
    return DataTableChoiceSheet(
      title: context.l10n.dataTableFilters,
      children: [
        if (specimenType != null) ...[
          DataTableSheetSection(label: context.l10n.homeSearchTaxa),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xl),
            child: Wrap(
              spacing: NahpuSpacing.md,
              runSpacing: NahpuSpacing.md,
              children: [
                for (final value in SpecimenRecordType.values)
                  ChoiceChip(
                    avatar: _SpecimenTypeIcon(
                      type: value,
                      isFilled: value == specimenType,
                      size: NahpuControlSize.iconSmall,
                    ),
                    showCheckmark: false,
                    label: Text(value.localizedLabel(context.l10n)),
                    selected: value == specimenType,
                    onSelected: (_) {
                      if (value == specimenType) return;
                      setState(() => _specimenType = value);
                      widget.onSpecimenTypeChanged?.call(value);
                    },
                  ),
              ],
            ),
          ),
        ],
        if (widget.canPickSearchField) ...[
          DataTableSheetSection(label: context.l10n.homeSearchIn),
          ListTile(
            leading: Icon(
              searchField == null ? Icons.search : Icons.manage_search,
            ),
            title: Text(
              searchField == null
                  ? context.l10n.dataTableAllVisibleFields
                  : searchField.label,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).pop(DataTableFilterSheetAction.pickSearchField),
          ),
        ],
        if (widget.type.quickFilters.isNotEmpty) ...[
          if (specimenType != null || widget.canPickSearchField)
            DataTableSheetSection(label: context.l10n.homeSearchQuickFilters),
          for (final filter in widget.type.quickFilters)
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: _selected.contains(filter),
              title: Text(filter.localizedLabel(context.l10n)),
              onChanged: (_) {
                setState(() {
                  if (!_selected.remove(filter)) _selected.add(filter);
                });
                widget.onToggled(filter);
              },
            ),
        ],
        const Divider(height: NahpuSpacing.lg),
        ListTile(
          leading: const Icon(Icons.tune),
          title: Text(
            widget.ruleCount == 0
                ? context.l10n.dataTableAddFieldRules
                : context.l10n.dataTableEditFieldRules,
          ),
          trailing: const Icon(Icons.chevron_right),
          enabled: widget.canEditRules,
          onTap: () =>
              Navigator.of(context).pop(DataTableFilterSheetAction.editRules),
        ),
      ],
    );
  }
}

/// A small heading over a group of choices in a bottom sheet.
class DataTableSheetSection extends StatelessWidget {
  const DataTableSheetSection({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NahpuSpacing.xl,
        NahpuSpacing.lg,
        NahpuSpacing.xl,
        NahpuSpacing.md,
      ),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Toolbar action shown as an icon with its label, or as the icon alone
/// with the label as a tooltip. A nonzero [badgeCount] marks it active.
class DataTableToolButton extends StatelessWidget {
  const DataTableToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.showLabel,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool showLabel;
  final VoidCallback? onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final isActive = badgeCount > 0;
    final badgedIcon = Badge(
      isLabelVisible: isActive,
      label: Text('$badgeCount'),
      child: Icon(icon),
    );
    if (!showLabel) {
      return IconButton(
        tooltip: label,
        isSelected: isActive,
        icon: badgedIcon,
        onPressed: onPressed,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return TextButton.icon(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, NahpuControlSize.control),
        foregroundColor: isActive
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
        shape: const StadiumBorder(),
      ),
      icon: badgedIcon,
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

/// Limits specimen records to one taxon group, as the export does. Icons
/// follow the catalog formats, with a generic icon for all taxa.
class SpecimenTypeMenu extends StatelessWidget {
  const SpecimenTypeMenu({
    super.key,
    required this.specimenType,
    required this.onChanged,
  });

  final SpecimenRecordType specimenType;
  final ValueChanged<SpecimenRecordType> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        for (final value in SpecimenRecordType.values)
          MenuItemButton(
            leadingIcon: _SpecimenTypeIcon(
              type: value,
              isFilled: value == specimenType,
              size: NahpuControlSize.iconMedium,
            ),
            trailingIcon: value == specimenType
                ? const Icon(Icons.check, size: NahpuControlSize.iconMedium)
                : null,
            onPressed: () => onChanged(value),
            child: Text(value.localizedLabel(context.l10n)),
          ),
      ],
      builder: (context, controller, _) => DataTableMenuButton(
        icon: _SpecimenTypeIcon(type: specimenType),
        label: specimenType.localizedLabel(context.l10n),
        controller: controller,
      ),
    );
  }
}

/// Pill-shaped search field with an optional scope button at its start.
class DataTableSearchField extends StatelessWidget {
  const DataTableSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.focusNode,
    this.scope,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final Widget? scope;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const pill = BorderRadius.all(Radius.circular(NahpuControlSize.control));
    const iconConstraints = BoxConstraints.tightFor(
      width: NahpuControlSize.control,
      height: NahpuControlSize.control,
    );
    // A wider scope, such as the phone's record type button, keeps its
    // own width.
    const scopeConstraints = BoxConstraints(
      minWidth: NahpuControlSize.control,
      minHeight: NahpuControlSize.control,
      maxHeight: NahpuControlSize.control,
    );
    return SizedBox(
      height: NahpuControlSize.control,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: colorScheme.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: NahpuSpacing.xl,
          ),
          // Phones use standard density, where icon buttons ask for a full
          // touch target; hold them to the field's height so they aren't
          // squeezed out of place.
          prefixIconConstraints: scopeConstraints,
          suffixIconConstraints: iconConstraints,
          prefixIcon:
              scope ??
              const Icon(Icons.search, size: NahpuControlSize.iconMedium),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: context.l10n.documentSelectionClearSearch,
                    icon: const Icon(
                      Icons.close,
                      size: NahpuControlSize.iconMedium,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
          border: const OutlineInputBorder(
            borderRadius: pill,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: pill,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: pill,
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: NahpuStroke.regular,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chooses which field the search covers. Phones pick it from the filter
/// sheet instead, through [showDataTableSearchScopeSheet].
class DataTableSearchScopeMenu extends StatelessWidget {
  const DataTableSearchScopeMenu({
    super.key,
    required this.field,
    required this.columns,
    required this.onChanged,
  });

  final DataTableColumn? field;
  final List<DataTableColumn> columns;
  final ValueChanged<DataTableColumn?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tooltip = field == null
        ? context.l10n.dataTableSearchingAllFields
        : context.l10n.dataTableSearchingField(field!.label);
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(
            field == null ? Icons.check : null,
            size: NahpuControlSize.iconMedium,
          ),
          onPressed: () => onChanged(null),
          child: Text(context.l10n.dataTableAllVisibleFields),
        ),
        const Divider(height: NahpuStroke.thin),
        for (final column in columns)
          MenuItemButton(
            leadingIcon: Icon(
              field?.key == column.key ? Icons.check : null,
              size: NahpuControlSize.iconMedium,
            ),
            onPressed: () => onChanged(column),
            child: Text(column.label),
          ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: tooltip,
        // Matches the field's height under every platform density.
        visualDensity: VisualDensity.compact,
        icon: Icon(
          field == null ? Icons.search : Icons.manage_search,
          size: NahpuControlSize.iconMedium,
        ),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// Picks the field the search covers from a bottom sheet. Returns null when
/// dismissed.
Future<DataTableSearchScopeChoice?> showDataTableSearchScopeSheet(
  BuildContext context, {
  required DataTableColumn? field,
  required List<DataTableColumn> columns,
}) {
  return showModalBottomSheet<DataTableSearchScopeChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) =>
        DataTableSearchScopeSheet(field: field, columns: columns),
  );
}

/// A field picked in [DataTableSearchScopeSheet]; a null [column] searches
/// every visible field.
class DataTableSearchScopeChoice {
  const DataTableSearchScopeChoice(this.column);

  final DataTableColumn? column;
}

/// Lists the fields the search can cover, with a filter for long lists.
class DataTableSearchScopeSheet extends StatefulWidget {
  const DataTableSearchScopeSheet({
    super.key,
    required this.field,
    required this.columns,
  });

  final DataTableColumn? field;
  final List<DataTableColumn> columns;

  @override
  State<DataTableSearchScopeSheet> createState() =>
      _DataTableSearchScopeSheetState();
}

class _DataTableSearchScopeSheetState extends State<DataTableSearchScopeSheet> {
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
    final columns = [
      for (final column in widget.columns)
        if (needle.isEmpty || column.label.toLowerCase().contains(needle))
          column,
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NahpuSpacing.xl,
                0,
                NahpuSpacing.xl,
                NahpuSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Names the field in use, as the button's tooltip does.
                  Text(
                    widget.field == null
                        ? context.l10n.dataTableSearchingAllFields
                        : context.l10n.dataTableSearchingField(
                            widget.field!.label,
                          ),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: NahpuSpacing.md),
                  DataTableSearchField(
                    controller: _filterController,
                    hint: context.l10n.dataTableFindField,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (needle.isEmpty) ...[
                    DataTableSearchScopeTile(
                      label: context.l10n.dataTableAllVisibleFields,
                      isSelected: widget.field == null,
                      onTap: () => Navigator.of(
                        context,
                      ).pop(const DataTableSearchScopeChoice(null)),
                    ),
                    const Divider(height: NahpuStroke.thin),
                  ],
                  for (final column in columns)
                    DataTableSearchScopeTile(
                      label: column.label,
                      isSelected: widget.field?.key == column.key,
                      onTap: () => Navigator.of(
                        context,
                      ).pop(DataTableSearchScopeChoice(column)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One choice in [DataTableSearchScopeSheet], checked when it is in use.
class DataTableSearchScopeTile extends StatelessWidget {
  const DataTableSearchScopeTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: NahpuControlSize.iconMedium,
        child: isSelected
            ? const Icon(Icons.check, size: NahpuControlSize.iconMedium)
            : null,
      ),
      title: Text(label),
      selected: isSelected,
      onTap: onTap,
    );
  }
}

/// The catalog-format glyph for [type], or a generic icon for all taxa.
class _SpecimenTypeIcon extends StatelessWidget {
  const _SpecimenTypeIcon({
    required this.type,
    this.isFilled = false,
    this.size,
  });

  final SpecimenRecordType type;
  final bool isFilled;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final catalogFmt = dataTableCatalogFmt(type);
    if (catalogFmt == null) {
      return Icon(
        isFilled ? Icons.category : Icons.category_outlined,
        size: size,
      );
    }
    return CatalogFmtIcon(
      catalogFmt: catalogFmt,
      isFilled: isFilled,
      size: size,
    );
  }
}
