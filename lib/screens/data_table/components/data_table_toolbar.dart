import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Record type, taxon group, search, filters, and columns.
class DataTableToolbar extends StatelessWidget {
  const DataTableToolbar({
    super.key,
    required this.type,
    required this.specimenType,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchField,
    required this.searchableColumns,
    required this.ruleCount,
    required this.onTypeChanged,
    required this.onSpecimenTypeChanged,
    required this.onSearchChanged,
    required this.onSearchFieldChanged,
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
  final int ruleCount;
  final ValueChanged<DataTableRecordType> onTypeChanged;
  final ValueChanged<SpecimenRecordType> onSpecimenTypeChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DataTableColumn?> onSearchFieldChanged;
  final VoidCallback? onEditRules;

  /// Null until the first page loads.
  final VoidCallback? onPickColumns;

  @override
  Widget build(BuildContext context) {
    final typeSelector = RecordTypeSelector(
      type: type,
      onChanged: onTypeChanged,
    );
    final searchRow = Row(
      children: [
        if (type == DataTableRecordType.specimenRecords) ...[
          SpecimenTypeMenu(
            specimenType: specimenType,
            onChanged: onSpecimenTypeChanged,
          ),
          const SizedBox(width: NahpuSpacing.md),
        ],
        Expanded(
          child: DataTableSearchField(
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
          ),
        ),
        const SizedBox(width: NahpuSpacing.md),
        Badge(
          isLabelVisible: ruleCount > 0,
          label: Text('$ruleCount'),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.filter_list),
            label: const Text('Filters'),
            style: _pillButtonStyle,
            onPressed: onEditRules,
          ),
        ),
        const SizedBox(width: NahpuSpacing.md),
        OutlinedButton.icon(
          icon: const Icon(Icons.view_column_outlined),
          label: const Text('Columns'),
          style: _pillButtonStyle,
          onPressed: onPickColumns,
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= NahpuBreakpoints.laptop) {
          return Row(
            children: [
              typeSelector,
              const SizedBox(width: NahpuSpacing.lg),
              Expanded(child: searchRow),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: typeSelector,
            ),
            const SizedBox(height: NahpuSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  maxWidth: constraints.maxWidth < NahpuContentWidth.form
                      ? NahpuContentWidth.form
                      : constraints.maxWidth,
                ),
                child: searchRow,
              ),
            ),
          ],
        );
      },
    );
  }
}

final _pillButtonStyle = OutlinedButton.styleFrom(
  minimumSize: const Size(0, NahpuControlSize.control),
  shape: const StadiumBorder(),
);

/// Pill-shaped switch between record types.
class RecordTypeSelector extends StatelessWidget {
  const RecordTypeSelector({
    super.key,
    required this.type,
    required this.onChanged,
  });

  final DataTableRecordType type;
  final ValueChanged<DataTableRecordType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: NahpuControlSize.control,
      padding: const EdgeInsets.all(NahpuSpacing.xs),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in DataTableRecordType.values)
            RecordTypePill(
              label: value.label,
              isSelected: value == type,
              onPressed: () => onChanged(value),
            ),
        ],
      ),
    );
  }
}

class RecordTypePill extends StatelessWidget {
  const RecordTypePill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.lg),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Limits specimen records to one taxon group, as the export does. Icons
/// follow the catalog formats, with the project's own format for all taxa.
class SpecimenTypeMenu extends ConsumerWidget {
  const SpecimenTypeMenu({
    super.key,
    required this.specimenType,
    required this.onChanged,
  });

  final SpecimenRecordType specimenType;
  final ValueChanged<SpecimenRecordType> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectFmt =
        ref.watch(catalogFmtNotifierProvider).value ?? CatalogFmt.mammalogy;
    IconData icon(SpecimenRecordType type, {bool filled = false}) =>
        matchCatFmtToIcon(
          dataTableCatalogFmt(type) ?? projectFmt,
          isFilledIcon: filled,
        );
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
      builder: (context, controller, _) => OutlinedButton.icon(
        icon: Icon(icon(specimenType)),
        label: Text(specimenType.dataTableLabel),
        style: _pillButtonStyle,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
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
