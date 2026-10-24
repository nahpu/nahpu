import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// A band of headline numbers shown above a statistics chart or table.
///
/// The spatial and count views of Explore both use it, so their summaries
/// read the same.
class StatisticMetricStrip extends StatelessWidget {
  const StatisticMetricStrip({super.key, required this.tiles});

  final List<StatisticMetricTile> tiles;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(NahpuSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NahpuRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = NahpuSpacing.md;
          final columns = constraints.maxWidth >= NahpuBreakpoints.compact
              ? tiles.length
              : 2;
          final width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final tile in tiles) SizedBox(width: width, child: tile),
            ],
          );
        },
      ),
    );
  }
}

class StatisticMetricTile extends StatelessWidget {
  const StatisticMetricTile({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NahpuSpacing.lg,
            vertical: NahpuSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(NahpuRadius.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The `N = total` label shown under a statistics plot title.
///
/// It sits below the title in a smaller, muted style so it reads as a note on
/// the plot rather than a heading.
class StatisticTotalLabel extends StatelessWidget {
  const StatisticTotalLabel({super.key, required this.total});

  /// Sum of the plotted counts, or null while it loads. The line still
  /// renders then, so the layout does not shift once the count arrives.
  final int? total;

  @override
  Widget build(BuildContext context) {
    final value = total?.toString() ?? '—';
    return Semantics(
      label: 'Total count: $value',
      child: ExcludeSemantics(
        child: Text(
          'N = $value',
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
