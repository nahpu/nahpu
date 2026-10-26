import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// Summary and actions for the node selected in the statistics network.
class NetworkNodeDetails extends StatelessWidget {
  const NetworkNodeDetails({
    super.key,
    required this.node,
    required this.layout,
    this.facts,
    required this.isExpanded,
    required this.onToggleLinks,
    required this.onClear,
  });

  final NetworkLayoutNode node;
  final NetworkLayout layout;

  /// Facts about the selected site or specimen, or null for other nodes and
  /// while they load.
  final NetworkRecordDetails? facts;
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
    // The caller frames and scrolls the details: a floating card on wide
    // screens, a bottom sheet on narrow ones.
    return Column(
      key: const ValueKey('statistics-network-node-details'),
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
                node.key.column.localizedLabel(l10n),
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
        if (facts case final facts?) ...[
          const SizedBox(height: NahpuSpacing.md),
          NetworkRecordFacts(facts: facts),
        ],
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
    );
  }
}

/// Label and value rows describing one site or specimen. Fields with no
/// value are left out.
class NetworkRecordFacts extends StatelessWidget {
  const NetworkRecordFacts({super.key, required this.facts});

  final NetworkRecordDetails facts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      key: const ValueKey('statistics-network-record-facts'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in _rows(context.l10n))
          Padding(
            padding: const EdgeInsets.only(bottom: NahpuSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }

  List<(String, String)> _rows(AppLocalizations l10n) {
    final rows = switch (facts) {
      NetworkSiteDetails(:final latitude, :final longitude) && final site => [
        (l10n.siteCopyFieldSiteType, site.siteType),
        (l10n.projectStatsColumnLocality, site.locality),
        (l10n.siteCopyFieldHabitatType, site.habitatType),
        (l10n.siteCopyFieldHabitatCondition, site.habitatCondition),
        (l10n.projectStatsColumnLatitude, latitude?.toStringAsFixed(5)),
        (l10n.projectStatsColumnLongitude, longitude?.toStringAsFixed(5)),
        (l10n.projectStatsColumnElevation, site.elevation?.round().toString()),
        (l10n.projectStatsNetworkEvents, '${site.eventCount}'),
      ],
      NetworkSpecimenDetails() && final specimen => [
        (l10n.specimenMuseumId, specimen.museumId),
        (l10n.projectTaxonSpecies, specimen.species),
        (l10n.projectStatsSex, getSpecimenSexLabel(specimen.sexCode)),
        (l10n.projectStatsLifeStage, specimen.lifeStage),
        (l10n.formsSearchCondition, specimen.condition),
        (l10n.projectStatsDate, specimen.eventDate),
        (l10n.projectStatsSite, specimen.siteId),
        (l10n.projectStatsNetworkParts, specimen.parts),
        (l10n.projectStatsNetworkParasites, specimen.parasites),
      ],
    };
    return [
      for (final (label, value) in rows)
        if (value != null) (label, value),
    ];
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
