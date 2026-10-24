import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// Summary and actions for the node selected in the statistics network.
class NetworkNodeDetails extends StatelessWidget {
  const NetworkNodeDetails({
    super.key,
    required this.node,
    required this.layout,
    required this.isExpanded,
    required this.onToggleLinks,
    required this.onClear,
  });

  final NetworkLayoutNode node;
  final NetworkLayout layout;
  final bool isExpanded;

  /// Shows or hides the record's links; null where links can't be toggled.
  final VoidCallback? onToggleLinks;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = NahpuTheme.networkTypeColors(theme.colorScheme);
    final color = colors[node.key.type.index % colors.length];
    // A radial child counts the specimens it shares with its parent.
    final isShared =
        layout == NetworkLayout.radial &&
        node.parent != null &&
        node.parent!.id.isNotEmpty;
    return Container(
      key: const ValueKey('statistics-network-node-details'),
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NahpuRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: NahpuControlSize.indicator,
                height: NahpuControlSize.indicator,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: NahpuSpacing.md),
              Expanded(
                child: Text(
                  node.key.type.localizedLabel(l10n),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.projectStatsClearSelection,
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Text(
            node.kind == NetworkNodeKind.overflow
                ? l10n.projectStatsNetworkMore(node.hiddenRecords)
                : node.label,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Text(
            isShared
                ? l10n.projectStatsNetworkShared(node.count)
                : l10n.projectStatsNetworkSpecimens(node.count),
            style: theme.textTheme.bodyMedium,
          ),
          if (onToggleLinks != null) ...[
            const SizedBox(height: NahpuSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: onToggleLinks,
              icon: Icon(
                isExpanded ? Icons.unfold_less_rounded : Icons.hub_outlined,
              ),
              label: Text(
                isExpanded
                    ? l10n.projectStatsNetworkHideLinks
                    : l10n.projectStatsNetworkShowLinks,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Color key for the record types on screen.
class NetworkLegend extends StatelessWidget {
  const NetworkLegend({super.key, required this.types});

  final List<NetworkNodeType> types;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = NahpuTheme.networkTypeColors(theme.colorScheme);
    return Semantics(
      label: context.l10n.projectStatsNetworkLegend,
      child: Wrap(
        spacing: NahpuSpacing.lg,
        runSpacing: NahpuSpacing.xs,
        children: [
          for (final type in types)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: NahpuControlSize.indicator,
                  height: NahpuControlSize.indicator,
                  decoration: BoxDecoration(
                    color: colors[type.index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: NahpuSpacing.xs),
                Text(
                  type.localizedLabel(context.l10n),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
