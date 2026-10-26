import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// The tissue box being filled: its name, fill count, next cell, and grid.
/// Filled cells name their tube; tapping one shows [inspector] below the
/// grid, above the box pager.
class TissueBoxCard extends StatelessWidget {
  const TissueBoxCard({
    super.key,
    required this.boxName,
    required this.layout,
    required this.occupied,
    required this.next,
    required this.onCellSelected,
    required this.onNextBox,
    required this.shortLabelFor,
    required this.labelFor,
    this.onPreviousBox,
    this.inspected,
    this.onInspect,
    this.inspector,
    this.replacing,
  });

  final String boxName;
  final TissueBoxLayout layout;
  final Map<TissueCell, List<TissueItemRecord>> occupied;
  final TissueCell? next;
  final ValueChanged<TissueCell> onCellSelected;
  final VoidCallback onNextBox;
  final String Function(TissueItemRecord record) shortLabelFor;
  final String Function(TissueItemRecord record) labelFor;

  /// The filled cell whose tubes [inspector] shows.
  final TissueCell? inspected;
  final ValueChanged<TissueCell>? onInspect;

  /// The tubes the next cell replaces, when it is a filled cell chosen to
  /// replace them.
  final String? replacing;

  /// Shown below the grid while a filled cell is inspected.
  final Widget? inspector;

  /// Null disables the previous box button, as on box 1.
  final VoidCallback? onPreviousBox;

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
                        context.l10n.projectTissueFilledCount(
                          occupied.length,
                          capacity,
                        ),
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
                      context.l10n.projectTissueNextCell,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // The replace note sits beside the label, so the
                    // header keeps its height and the grid stays put.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (replacing case final labels?) ...[
                          Text(
                            context.l10n.projectTissueReplacing(labels),
                            key: const ValueKey('tissue-next-replacing'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: NahpuTheme.warningText(theme.colorScheme),
                            ),
                          ),
                          const SizedBox(width: NahpuSpacing.md),
                        ],
                        Text(
                          next == null
                              ? context.l10n.projectTissueFull
                              : layout.cellLabel(next!),
                          key: const ValueKey('tissue-next-cell'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
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
              inspected: inspected,
              shortLabelFor: shortLabelFor,
              labelFor: labelFor,
              onCellSelected: onCellSelected,
              onInspect: onInspect,
            ),
            // Below the grid, so opening it never shifts the cells.
            if (inspector != null) ...[
              const SizedBox(height: NahpuSpacing.lg),
              inspector!,
            ],
            const SizedBox(height: NahpuSpacing.lg),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: NahpuSpacing.lg,
              runSpacing: NahpuSpacing.md,
              children: [
                const TissueBoxLegend(),
                TissueBoxPager(
                  boxName: boxName,
                  onPrevious: onPreviousBox,
                  onNext: onNextBox,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Steps between boxes, with the current box named between the buttons.
class TissueBoxPager extends StatelessWidget {
  const TissueBoxPager({
    super.key,
    required this.boxName,
    required this.onPrevious,
    required this.onNext,
  });

  final String boxName;

  /// Null disables the previous button.
  final VoidCallback? onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const ValueKey('tissue-previous-box'),
          tooltip: context.l10n.projectTissuePreviousBox,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Flexible(
          child: Text(
            boxName,
            key: const ValueKey('tissue-pager-box'),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        IconButton(
          key: const ValueKey('tissue-next-box'),
          tooltip: context.l10n.projectTissueNextBox,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
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
    required this.shortLabelFor,
    required this.labelFor,
    required this.onCellSelected,
    this.inspected,
    this.onInspect,
  });

  final TissueBoxLayout layout;
  final Map<TissueCell, List<TissueItemRecord>> occupied;
  final TissueCell? next;
  final TissueCell? inspected;
  final String Function(TissueItemRecord record) shortLabelFor;
  final String Function(TissueItemRecord record) labelFor;
  final ValueChanged<TissueCell> onCellSelected;
  final ValueChanged<TissueCell>? onInspect;

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
                    Expanded(child: _cell(TissueCell(row, column))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  TissueBoxCell _cell(TissueCell cell) {
    final items = occupied[cell] ?? const <TissueItemRecord>[];
    return TissueBoxCell(
      key: ValueKey('tissue-cell-${layout.cellLabel(cell)}'),
      label: layout.cellLabel(cell),
      shortLabel: items.isEmpty ? null : shortLabelFor(items.first),
      fullLabel: items.map(labelFor).join(', '),
      count: items.length,
      isNext: next == cell,
      isSelected: inspected == cell,
      onTap: items.isEmpty
          ? () => onCellSelected(cell)
          : onInspect == null
          ? null
          : () => onInspect!(cell),
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
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// One tube position. Filled cells show the end of their tube's ID, with a
/// count when tubes share the cell; the next cell shows its label. Tapping
/// an empty cell makes it the next cell; tapping a filled one inspects it.
class TissueBoxCell extends StatelessWidget {
  const TissueBoxCell({
    super.key,
    required this.label,
    required this.isNext,
    required this.onTap,
    this.shortLabel,
    this.fullLabel = '',
    this.count = 0,
    this.isSelected = false,
  });

  final String label;

  /// Null for an empty cell.
  final String? shortLabel;

  /// Every tube in the cell, for the tooltip and screen readers.
  final String fullLabel;
  final int count;
  final bool isNext;
  final bool isSelected;
  final VoidCallback? onTap;

  bool get isFilled => count > 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall;
    final isShared = count > 1;
    final description = isFilled ? '$label · $fullLabel' : label;
    final BorderSide side;
    if (isSelected) {
      side = BorderSide(
        color: colorScheme.onSurface,
        width: NahpuStroke.regular,
      );
    } else if (isNext) {
      side = BorderSide(color: colorScheme.primary, width: NahpuStroke.regular);
    } else if (isShared) {
      side = BorderSide(
        color: NahpuTheme.warningText(colorScheme),
        width: NahpuStroke.regular,
      );
    } else {
      side = BorderSide(
        color: isFilled
            ? colorScheme.primary.withValues(alpha: 0.4)
            : colorScheme.outlineVariant,
        width: NahpuStroke.thin,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(NahpuSpacing.xxs),
      child: Tooltip(
        message: description,
        child: Semantics(
          button: onTap != null,
          selected: isNext || isSelected,
          label: description,
          excludeSemantics: true,
          child: Material(
            color: isFilled
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NahpuRadius.xs),
              side: side,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(NahpuSpacing.xxs),
                  child: FittedBox(
                    child: isFilled
                        ? Text(
                            isShared
                                ? '$shortLabel +${count - 1}'
                                : shortLabel!,
                            style: textStyle?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          )
                        : isNext
                        ? Text(
                            label,
                            // The primary border marks the cell; the label
                            // stays in on-surface to read on the cell fill.
                            style: textStyle?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
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
          label: context.l10n.projectTissueFilled,
          color: colorScheme.primaryContainer,
          borderColor: colorScheme.primary.withValues(alpha: 0.4),
        ),
        TissueBoxLegendItem(
          label: context.l10n.projectTissueNext,
          color: colorScheme.surfaceContainerHighest,
          borderColor: colorScheme.primary,
          borderWidth: NahpuStroke.regular,
        ),
        Text(
          context.l10n.projectTissueTapCellHint,
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
