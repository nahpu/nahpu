import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_check/tissue_box.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// The tissue box being filled: its name, fill count, next cell, and grid.
class TissueBoxCard extends StatelessWidget {
  const TissueBoxCard({
    super.key,
    required this.boxName,
    required this.layout,
    required this.occupied,
    required this.next,
    required this.onCellSelected,
    required this.onNextBox,
  });

  final String boxName;
  final TissueBoxLayout layout;
  final Map<TissueCell, String?> occupied;
  final TissueCell? next;
  final ValueChanged<TissueCell> onCellSelected;
  final VoidCallback onNextBox;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final capacity = layout.size.capacity;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: NahpuSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(boxName, style: theme.textTheme.titleMedium),
                      Text(
                        '${occupied.length} / $capacity filled',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Next cell',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      next == null ? 'Full' : layout.cellLabel(next!),
                      key: const ValueKey('tissue-next-cell'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(NahpuRadius.xs),
              child: LinearProgressIndicator(
                value: occupied.length / capacity,
                minHeight: NahpuSpacing.xs,
              ),
            ),
            const SizedBox(height: NahpuSpacing.lg),
            TissueBoxGrid(
              layout: layout,
              occupied: occupied,
              next: next,
              onCellSelected: onCellSelected,
            ),
            const SizedBox(height: NahpuSpacing.lg),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: NahpuSpacing.lg,
              runSpacing: NahpuSpacing.md,
              children: [
                const TissueBoxLegend(),
                TextButton.icon(
                  onPressed: onNextBox,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next box'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A square grid of tube cells with row and column labels.
class TissueBoxGrid extends StatelessWidget {
  const TissueBoxGrid({
    super.key,
    required this.layout,
    required this.occupied,
    required this.next,
    required this.onCellSelected,
  });

  final TissueBoxLayout layout;
  final Map<TissueCell, String?> occupied;
  final TissueCell? next;
  final ValueChanged<TissueCell> onCellSelected;

  @override
  Widget build(BuildContext context) {
    final side = layout.side;
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                for (var column = 0; column < side; column++)
                  Expanded(
                    child: TissueBoxHeader(label: layout.columnLabel(column)),
                  ),
              ],
            ),
          ),
          for (var row = 0; row < side; row++)
            Expanded(
              child: Row(
                children: [
                  Expanded(child: TissueBoxHeader(label: layout.rowLabel(row))),
                  for (var column = 0; column < side; column++)
                    Expanded(
                      child: TissueBoxCell(
                        label: layout.cellLabel(TissueCell(row, column)),
                        isFilled: occupied.containsKey(TissueCell(row, column)),
                        tissueLabel: occupied[TissueCell(row, column)],
                        isNext: next == TissueCell(row, column),
                        onTap: () => onCellSelected(TissueCell(row, column)),
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

class TissueBoxHeader extends StatelessWidget {
  const TissueBoxHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: FittedBox(
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// One tube position. Filled cells show the end of the tissue ID; the next
/// cell shows its label. Tapping an empty cell makes it the next cell.
class TissueBoxCell extends StatelessWidget {
  const TissueBoxCell({
    super.key,
    required this.label,
    required this.isFilled,
    required this.isNext,
    required this.onTap,
    this.tissueLabel,
  });

  final String label;
  final bool isFilled;
  final bool isNext;
  final String? tissueLabel;
  final VoidCallback onTap;

  static const int _shortLength = 4;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall;
    final tissue = tissueLabel;
    final tooltip = tissue == null ? label : '$label · $tissue';
    return Padding(
      padding: const EdgeInsets.all(NahpuSpacing.xxs),
      child: Tooltip(
        message: isFilled && tissue == null ? '$label · filled' : tooltip,
        child: Semantics(
          button: !isFilled,
          selected: isNext,
          label: tooltip,
          child: Material(
            color: isFilled
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NahpuRadius.xs),
              side: isNext
                  ? BorderSide(
                      color: colorScheme.primary,
                      width: NahpuStroke.regular,
                    )
                  : BorderSide(
                      color: isFilled
                          ? colorScheme.primary.withValues(alpha: 0.4)
                          : colorScheme.outlineVariant,
                      width: NahpuStroke.thin,
                    ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isFilled ? null : onTap,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(NahpuSpacing.xxs),
                  child: FittedBox(
                    child: isFilled
                        ? (tissue == null
                              ? Icon(
                                  Icons.check,
                                  size: NahpuControlSize.iconSmall,
                                  color: colorScheme.onPrimaryContainer,
                                )
                              : Text(
                                  _shortLabel(tissue),
                                  style: textStyle?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ))
                        : isNext
                        ? Text(
                            label,
                            style: textStyle?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _shortLabel(String text) => text.length <= _shortLength
      ? text
      : text.substring(text.length - _shortLength);
}

class TissueBoxLegend extends StatelessWidget {
  const TissueBoxLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: NahpuSpacing.lg,
      runSpacing: NahpuSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TissueBoxLegendItem(
          label: 'Filled',
          color: colorScheme.primaryContainer,
          borderColor: colorScheme.primary.withValues(alpha: 0.4),
        ),
        TissueBoxLegendItem(
          label: 'Next',
          color: colorScheme.surfaceContainerHighest,
          borderColor: colorScheme.primary,
          borderWidth: NahpuStroke.regular,
        ),
        Text(
          'Tap an empty cell to jump',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class TissueBoxLegendItem extends StatelessWidget {
  const TissueBoxLegendItem({
    super.key,
    required this.label,
    required this.color,
    required this.borderColor,
    this.borderWidth = NahpuStroke.thin,
  });

  final String label;
  final Color color;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: NahpuControlSize.indicator,
          height: NahpuControlSize.indicator,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(NahpuRadius.xs / 2),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
        ),
        const SizedBox(width: NahpuSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
