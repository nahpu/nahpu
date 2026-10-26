import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/network_node_details.dart';
import 'package:nahpu/screens/projects/statistics/statistic_filter_panel.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/network_statistics.dart';
import 'package:nahpu/services/types/network_statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// Layout switch, start type, and the linked types or columns of the
/// network, stacked to fit a side pane or a bottom sheet.
class NetworkOptions extends ConsumerWidget {
  const NetworkOptions({super.key, required this.projectUuid});

  final String? projectUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = ref.watch(networkViewProvider(projectUuid));
    final controller = ref.read(networkViewProvider(projectUuid).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<NetworkLayout>(
          key: const ValueKey('statistics-network-layout-control'),
          showSelectedIcon: false,
          segments: [
            for (final layout in NetworkLayout.values)
              ButtonSegment(
                value: layout,
                icon: Icon(layout.icon),
                label: Text(layout.localizedLabel(l10n)),
              ),
          ],
          selected: {view.layout},
          onSelectionChanged: (selection) =>
              controller.setLayout(selection.single),
        ),
        if (view.layout == NetworkLayout.radial) ...[
          // The floating field labels sit above the outline, so the gap is
          // wider than the one between the other options.
          const SizedBox(height: NahpuSpacing.xxl),
          StatisticDropdownField<NetworkNodeType>(
            key: ValueKey('statistics-network-root-${view.rootType.name}'),
            label: l10n.projectStatsNetworkStartFrom,
            values: NetworkNodeType.values,
            selected: view.rootType,
            valueLabel: (type) => type.localizedLabel(l10n),
            onSelected: controller.setRootType,
          ),
        ],
        const SizedBox(height: NahpuSpacing.xxl),
        switch (view.layout) {
          NetworkLayout.radial => _NetworkLinkedPicker(
            rootType: view.rootType,
            linkedTypes: view.linkedTypes,
            onChanged: controller.setLinkedTypes,
          ),
          NetworkLayout.layered => _NetworkColumnPicker(
            columns: view.columns,
            onChanged: controller.setColumns,
          ),
        },
      ],
    );
  }
}

/// Options pane beside the network on wide screens, with the legend under
/// the options. [onCollapse] folds it into a [NetworkOptionsRail].
class NetworkOptionsPane extends ConsumerWidget {
  const NetworkOptionsPane({
    super.key,
    required this.projectUuid,
    required this.onCollapse,
  });

  final String? projectUuid;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final view = ref.watch(networkViewProvider(projectUuid));
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      key: const ValueKey('statistics-network-options-pane'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.xl,
            NahpuSpacing.md,
            NahpuSpacing.md,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.projectStatsNetworkOptions, style: labelStyle),
              ),
              IconButton(
                key: const ValueKey('statistics-network-options-collapse'),
                tooltip: l10n.projectStatsNetworkHideOptions,
                onPressed: onCollapse,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              NahpuSpacing.xl,
              NahpuSpacing.md,
              NahpuSpacing.xl,
              NahpuSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NetworkOptions(projectUuid: projectUuid),
                const SizedBox(height: NahpuSpacing.xxl),
                Text(l10n.projectStatsNetworkLegend, style: labelStyle),
                const SizedBox(height: NahpuSpacing.md),
                NetworkLegend(types: view.shownTypes),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Network options folded to a column of icons: a button to open them, the
/// layout switch, and the legend as colored dots.
class NetworkOptionsRail extends ConsumerWidget {
  const NetworkOptionsRail({
    super.key,
    required this.projectUuid,
    required this.onExpand,
  });

  final String? projectUuid;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = NahpuTheme.networkTypeColors(theme.colorScheme);
    final view = ref.watch(networkViewProvider(projectUuid));
    final controller = ref.read(networkViewProvider(projectUuid).notifier);
    return Padding(
      key: const ValueKey('statistics-network-options-rail'),
      padding: const EdgeInsets.all(NahpuSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const ValueKey('statistics-network-options-expand'),
            tooltip: l10n.projectStatsNetworkShowOptions,
            onPressed: onExpand,
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(height: NahpuSpacing.xs),
          for (final layout in NetworkLayout.values)
            IconButton(
              tooltip: layout.localizedLabel(l10n),
              isSelected: view.layout == layout,
              onPressed: () => controller.setLayout(layout),
              icon: Icon(layout.icon),
            ),
          const SizedBox(height: NahpuSpacing.md),
          Semantics(
            label: l10n.projectStatsNetworkLegend,
            child: Column(
              children: [
                for (final type in view.shownTypes)
                  Tooltip(
                    message: type.localizedLabel(l10n),
                    child: Padding(
                      padding: const EdgeInsets.all(NahpuSpacing.sm),
                      child: Container(
                        width: NahpuControlSize.indicator,
                        height: NahpuControlSize.indicator,
                        decoration: BoxDecoration(
                          color: colors[type.index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on NetworkLayout {
  IconData get icon => switch (this) {
    NetworkLayout.radial => Icons.bubble_chart_outlined,
    NetworkLayout.layered => Icons.view_column_outlined,
  };
}

/// Picks the record types the radial network links to, out of those the
/// start type supports. The last one can't be dropped.
class _NetworkLinkedPicker extends StatelessWidget {
  const _NetworkLinkedPicker({
    required this.rootType,
    required this.linkedTypes,
    required this.onChanged,
  });

  final NetworkNodeType rootType;
  final List<NetworkNodeType> linkedTypes;
  final ValueChanged<List<NetworkNodeType>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final supported = rootType.linkableTypes;
    final chosen = [
      for (final type in supported)
        if (linkedTypes.contains(type)) type,
    ];
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.projectStatsNetworkLinked,
        border: const OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: NahpuSpacing.md,
        runSpacing: NahpuSpacing.xs,
        children: [
          for (final type in supported)
            FilterChip(
              key: ValueKey('statistics-network-linked-${type.name}'),
              label: Text(type.localizedLabel(l10n)),
              selected: chosen.contains(type),
              onSelected: chosen.length == 1 && chosen.contains(type)
                  ? null
                  : (selected) => onChanged(
                      selected
                          ? [...linkedTypes, type]
                          : [
                              for (final linked in linkedTypes)
                                if (linked != type) linked,
                            ],
                    ),
            ),
        ],
      ),
    );
  }
}

/// Picks the layered columns: tap a record type or a field of a chosen
/// type to add it on the right, tap a chosen one to drop it. Holds up to
/// [networkMaxColumns] columns.
class _NetworkColumnPicker extends StatelessWidget {
  const _NetworkColumnPicker({required this.columns, required this.onChanged});

  final List<NetworkColumn> columns;
  final ValueChanged<List<NetworkColumn>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final records = [
      for (final column in columns)
        if (column.field == null) column,
      for (final type in NetworkNodeType.values)
        if (!columns.contains(NetworkColumn(type))) NetworkColumn(type),
    ];
    final fields = [
      for (final column in columns)
        if (column.field == null)
          for (final field in column.type.fields) NetworkColumn.field(field),
    ];
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.projectStatsNetworkColumns,
        helperText: l10n.projectStatsNetworkMaxColumns(networkMaxColumns),
        border: const OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: NahpuSpacing.md,
            runSpacing: NahpuSpacing.xs,
            children: [
              for (final column in records)
                _NetworkColumnChip(
                  column: column,
                  columns: columns,
                  onChanged: onChanged,
                ),
            ],
          ),
          if (fields.isNotEmpty) ...[
            const SizedBox(height: NahpuSpacing.md),
            Text(
              l10n.projectStatsNetworkFields,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: NahpuSpacing.xs),
            Wrap(
              spacing: NahpuSpacing.md,
              runSpacing: NahpuSpacing.xs,
              children: [
                for (final column in fields)
                  _NetworkColumnChip(
                    column: column,
                    columns: columns,
                    onChanged: onChanged,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One layered column choice, numbered by its place when chosen and
/// disabled once [networkMaxColumns] are chosen.
class _NetworkColumnChip extends StatelessWidget {
  const _NetworkColumnChip({
    required this.column,
    required this.columns,
    required this.onChanged,
  });

  final NetworkColumn column;
  final List<NetworkColumn> columns;
  final ValueChanged<List<NetworkColumn>> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = column.localizedLabel(context.l10n);
    final index = columns.indexOf(column);
    final isSelected = index >= 0;
    final isFull = columns.length >= networkMaxColumns;
    return FilterChip(
      key: ValueKey(
        column.field == null
            ? 'statistics-network-column-${column.type.name}'
            : 'statistics-network-field-${column.field!.name}',
      ),
      label: Text(isSelected ? '${index + 1}. $label' : label),
      selected: isSelected,
      onSelected: !isSelected && isFull
          ? null
          : (selected) => onChanged(
              selected
                  ? [...columns, column]
                  : [
                      for (final other in columns)
                        if (other != column) other,
                    ],
            ),
    );
  }
}
