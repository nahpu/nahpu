import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/network_canvas.dart';
import 'package:nahpu/screens/projects/statistics/network_node_details.dart';
import 'package:nahpu/screens/projects/statistics/statistic_filter_panel.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/network_statistics.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Explore card for the statistics network: the filter panel, then the
/// network in a fixed-height card with a button to open it full screen.
class NetworkStatisticsPanel extends StatelessWidget {
  const NetworkStatisticsPanel({
    super.key,
    required this.projectUuid,
    required this.projectName,
    required this.height,
    required this.sectionSwitch,
  });

  /// Project the network covers, or null for every project.
  final String? projectUuid;
  final String projectName;

  /// Fixed card height, shared with the other Explore cards.
  final double height;

  /// Counts/Spatial/Network switch shown at the top of the filter panel.
  final Widget sectionSwitch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NetworkFilterPanel(projectUuid: projectUuid, section: sectionSwitch),
        const SizedBox(height: NahpuSpacing.xl),
        Card(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            key: const ValueKey('statistics-network-content'),
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(NahpuSpacing.xl),
              child: NetworkWorkspace(
                projectUuid: projectUuid,
                onFullScreen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NetworkStatisticsFullScreen(
                      projectUuid: projectUuid,
                      projectName: projectName,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-screen statistics network. Shares its view state with the Explore
/// card, so expanded records and the selection carry over both ways.
class NetworkStatisticsFullScreen extends StatelessWidget {
  const NetworkStatisticsFullScreen({
    super.key,
    required this.projectUuid,
    required this.projectName,
  });

  final String? projectUuid;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${context.l10n.projectStatsNetwork} · $projectName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NahpuSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NetworkFilterPanel(projectUuid: projectUuid),
              const SizedBox(height: NahpuSpacing.lg),
              Expanded(child: NetworkWorkspace(projectUuid: projectUuid)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Layout switch and record-type pickers for the network.
class NetworkFilterPanel extends ConsumerWidget {
  const NetworkFilterPanel({
    super.key,
    required this.projectUuid,
    this.section,
  });

  final String? projectUuid;

  /// Explore section switch; the layout switch takes its place when null.
  final Widget? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = ref.watch(networkViewProvider(projectUuid));
    final controller = ref.read(networkViewProvider(projectUuid).notifier);
    final layoutSwitch = SegmentedButton<NetworkLayout>(
      key: const ValueKey('statistics-network-layout-control'),
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: NetworkLayout.radial,
          icon: const Icon(Icons.bubble_chart_outlined),
          label: Text(NetworkLayout.radial.localizedLabel(l10n)),
        ),
        ButtonSegment(
          value: NetworkLayout.layered,
          icon: const Icon(Icons.view_column_outlined),
          label: Text(NetworkLayout.layered.localizedLabel(l10n)),
        ),
      ],
      selected: {view.layout},
      onSelectionChanged: (selection) => controller.setLayout(selection.single),
    );
    return StatisticFilterPanel(
      section: section ?? layoutSwitch,
      selector: section == null ? null : layoutSwitch,
      fields: [
        if (view.layout == NetworkLayout.radial)
          StatisticDropdownField<NetworkNodeType>(
            key: ValueKey('statistics-network-root-${view.rootType.name}'),
            label: l10n.projectStatsNetworkStartFrom,
            values: NetworkNodeType.values,
            selected: view.rootType,
            valueLabel: (type) => type.localizedLabel(l10n),
            onSelected: controller.setRootType,
          ),
      ],
      footer: switch (view.layout) {
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
    );
  }
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

/// Network canvas with its toolbar, legend, and selected-node details.
class NetworkWorkspace extends ConsumerStatefulWidget {
  const NetworkWorkspace({
    super.key,
    required this.projectUuid,
    this.onFullScreen,
  });

  final String? projectUuid;

  /// Opens the full-screen view; null when already full screen.
  final VoidCallback? onFullScreen;

  @override
  ConsumerState<NetworkWorkspace> createState() => _NetworkWorkspaceState();
}

class _NetworkWorkspaceState extends ConsumerState<NetworkWorkspace> {
  /// Keeps the canvas, with its zoom and pan, when the details panel opens
  /// or closes and the canvas moves to a new place in the tree.
  final _canvasKey = GlobalKey();

  /// Last network drawn, kept on screen while a new page loads.
  NetworkLayoutResult? _last;
  int _fitCount = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final view = ref.watch(networkViewProvider(widget.projectUuid));
    final result = ref.watch(networkLayoutProvider(widget.projectUuid));
    if (result.value case final layout?) _last = layout;
    final layout = _last;
    final selected = view.selected == null
        ? null
        : layout?.nodeFor(view.selected!);

    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.projectStatsNetworkTitle,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                l10n.projectStatsNetworkHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (result.isLoading)
          const Padding(
            padding: EdgeInsets.all(NahpuSpacing.md),
            child: SizedBox.square(
              dimension: NahpuControlSize.iconSmall,
              child: CircularProgressIndicator(
                strokeWidth: NahpuStroke.regular,
              ),
            ),
          ),
        IconButton(
          tooltip: l10n.projectStatsNetworkFit,
          onPressed: () => setState(() => _fitCount++),
          icon: const Icon(Icons.fit_screen_outlined),
        ),
        IconButton(
          tooltip: l10n.projectStatsNetworkReset,
          onPressed: () {
            ref.read(networkViewProvider(widget.projectUuid).notifier).reset();
            setState(() => _fitCount++);
          },
          icon: const Icon(Icons.restart_alt_rounded),
        ),
        if (widget.onFullScreen != null)
          IconButton(
            key: const ValueKey('statistics-network-full-screen'),
            tooltip: l10n.projectStatsNetworkFullScreen,
            onPressed: widget.onFullScreen,
            icon: const Icon(Icons.fullscreen_rounded),
          ),
      ],
    );

    final Widget body;
    if (layout == null) {
      body = result.hasError
          ? _NetworkError(
              message: l10n.projectStatsNetworkLoadError('${result.error}'),
              onRetry: () =>
                  ref.invalidate(networkLayoutProvider(widget.projectUuid)),
            )
          : const Center(child: CircularProgressIndicator());
    } else if (layout.nodes.length <= 1 && _isEmpty(layout)) {
      body = Center(child: Text(l10n.projectStatsNetworkEmpty));
    } else {
      body = NetworkCanvas(
        key: _canvasKey,
        layout: layout,
        selected: view.selected,
        fitSignal: (
          view.layout,
          view.rootType,
          Object.hashAll(view.columns),
          _fitCount,
        ),
        labels: NetworkCanvasLabels(
          columnLabel: (column) => column.localizedLabel(l10n),
          overflowLabel: l10n.projectStatsNetworkMore,
        ),
        onNodeTap: (node) => _onNodeTap(view, node),
      );
    }

    final facts = selected == null || !selected.key.isRecord
        ? null
        : ref.watch(networkRecordDetailsProvider(selected.key)).value;
    final details = selected == null
        ? null
        : NetworkNodeDetails(
            node: selected,
            layout: view.layout,
            facts: facts,
            isExpanded: view.isExpanded(selected.key),
            onToggleLinks:
                view.layout == NetworkLayout.radial &&
                    selected.kind == NetworkNodeKind.record
                ? () => ref
                      .read(networkViewProvider(widget.projectUuid).notifier)
                      .toggleExpanded(selected.key)
                : null,
            onClear: () => ref
                .read(networkViewProvider(widget.projectUuid).notifier)
                .select(null),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: NahpuSpacing.md),
        NetworkLegend(
          types: view.layout == NetworkLayout.radial
              ? view.radialTypes
              : {for (final column in view.columns) column.type}.toList(),
        ),
        const SizedBox(height: NahpuSpacing.md),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvas = DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(NahpuRadius.md),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(NahpuRadius.md),
                  child: body,
                ),
              );
              if (details == null) return canvas;
              if (constraints.maxWidth >= NahpuBreakpoints.compact) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: canvas),
                    const SizedBox(width: NahpuSpacing.lg),
                    SizedBox(
                      width: NahpuContentWidth.statisticsDetails,
                      child: details,
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: canvas),
                  const SizedBox(height: NahpuSpacing.lg),
                  Flexible(child: details),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static bool _isEmpty(NetworkLayoutResult layout) =>
      layout.nodes.every((node) => node.count == 0);

  void _onNodeTap(NetworkViewState view, NetworkLayoutNode? node) {
    final controller = ref.read(
      networkViewProvider(widget.projectUuid).notifier,
    );
    if (node == null || node.kind == NetworkNodeKind.hub) {
      controller.select(null);
      return;
    }
    if (node.kind == NetworkNodeKind.overflow) {
      controller.showMore(node.key, parent: node.parent);
      return;
    }
    if (view.layout == NetworkLayout.radial) {
      controller.toggleExpanded(node.key);
      return;
    }
    controller.select(view.selected == node.key ? null : node.key);
  }
}

class _NetworkError extends StatelessWidget {
  const _NetworkError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: NahpuSpacing.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}
