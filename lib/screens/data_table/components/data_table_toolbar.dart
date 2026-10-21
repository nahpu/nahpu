import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// One row with record type, taxon group, search, filters, and columns.
/// Narrow screens split it in two.
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
          ? 'Search ${type.label.toLowerCase()}'
          : 'Search ${searchField!.label}',
      onChanged: onSearchChanged,
      scope: DataTableSearchScopeMenu(
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
          ),
          if (showLabels) const SizedBox(width: NahpuSpacing.xs),
          DataTableToolButton(
            icon: Icons.view_column_outlined,
            label: 'Columns',
            showLabel: showLabels,
            onPressed: onPickColumns,
          ),
        ];
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

  final IconData icon;
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
          Icon(icon, size: NahpuControlSize.iconSmall),
          const SizedBox(width: NahpuSpacing.md),
          Text(label),
          const SizedBox(width: NahpuSpacing.xs),
          const Icon(Icons.arrow_drop_down, size: NahpuControlSize.iconMedium),
        ],
      ),
    );
  }
}

/// Chooses the kind of record the table shows.
class RecordTypeMenu extends StatelessWidget {
  const RecordTypeMenu({
    super.key,
    required this.type,
    required this.onChanged,
  });

  final DataTableRecordType type;
  final ValueChanged<DataTableRecordType> onChanged;

  @override
  Widget build(BuildContext context) {
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
        icon: Icons.table_chart_outlined,
        label: type.label,
        controller: controller,
      ),
    );
  }
}

/// Preset filters for the record type, checked in place, and the field
/// rules editor. The badge counts every active filter.
class DataTableFilterMenu extends StatelessWidget {
  const DataTableFilterMenu({
    super.key,
    required this.type,
    required this.selected,
    required this.ruleCount,
    required this.showLabel,
    required this.onToggled,
    required this.onEditRules,
  });

  final DataTableRecordType type;
  final Set<DataTableQuickFilter> selected;
  final int ruleCount;
  final bool showLabel;
  final ValueChanged<DataTableQuickFilter> onToggled;

  /// Null until the first page loads.
  final VoidCallback? onEditRules;

  @override
  Widget build(BuildContext context) {
    final count = selected.length + ruleCount;
    return MenuAnchor(
      menuChildren: [
        for (final filter in type.quickFilters)
          CheckboxMenuButton(
            value: selected.contains(filter),
            closeOnActivate: false,
            onChanged: (_) => onToggled(filter),
            child: Text(filter.label),
          ),
        if (type.quickFilters.isNotEmpty)
          const Divider(height: NahpuStroke.thin),
        MenuItemButton(
          leadingIcon: const Icon(
            Icons.tune,
            size: NahpuControlSize.iconMedium,
          ),
          onPressed: onEditRules,
          child: Text(ruleCount == 0 ? 'Add field rules' : 'Edit field rules'),
        ),
      ],
      builder: (context, controller, _) => DataTableToolButton(
        icon: Icons.filter_list,
        label: 'Filters',
        showLabel: showLabel,
        badgeCount: count,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
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
    IconData icon(SpecimenRecordType type, {bool filled = false}) {
      final catalogFmt = dataTableCatalogFmt(type);
      if (catalogFmt == null) {
        return filled ? Icons.category : Icons.category_outlined;
      }
      return matchCatFmtToIcon(catalogFmt, isFilledIcon: filled);
    }

    return MenuAnchor(
      menuChildren: [
        for (final value in SpecimenRecordType.values)
          MenuItemButton(
            leadingIcon: Icon(
              icon(value, filled: value == specimenType),
              size: NahpuControlSize.iconMedium,
            ),
            trailingIcon: value == specimenType
                ? const Icon(Icons.check, size: NahpuControlSize.iconMedium)
                : null,
            onPressed: () => onChanged(value),
            child: Text(value.dataTableLabel),
          ),
      ],
      builder: (context, controller, _) => DataTableMenuButton(
        icon: icon(specimenType),
        label: specimenType.dataTableLabel,
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
          prefixIcon:
              scope ??
              const Icon(Icons.search, size: NahpuControlSize.iconMedium),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear search',
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

/// Chooses which field the search covers.
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
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(
            field == null ? Icons.check : null,
            size: NahpuControlSize.iconMedium,
          ),
          onPressed: () => onChanged(null),
          child: const Text('All visible fields'),
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
        tooltip: field == null
            ? 'Searching all visible fields'
            : 'Searching ${field!.label}',
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
