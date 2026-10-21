import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Tinted panel that holds the Explore selectors above the result card.
///
/// The top line pairs the [section] switch with an optional [selector]; the
/// [fields] wrap below it in equal columns.
class StatisticFilterPanel extends StatelessWidget {
  const StatisticFilterPanel({
    super.key,
    required this.section,
    this.selector,
    this.fields = const [],
  });

  final Widget section;
  final Widget? selector;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('statistics-filter-panel'),
      // Matches the default Card margin so the panel lines up with the
      // result card below it.
      margin: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xs),
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NahpuRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: NahpuSpacing.lg,
            runSpacing: NahpuSpacing.md,
            children: [section, ?selector],
          ),
          if (fields.isNotEmpty) ...[
            // The floating field labels sit above the outline, so the gap is
            // wider than the panel padding to read as the same space.
            const SizedBox(height: NahpuSpacing.xl),
            _StatisticFieldRow(children: fields),
          ],
        ],
      ),
    );
  }
}

/// Labelled outlined dropdown for one statistics option.
class StatisticDropdownField<T> extends StatelessWidget {
  const StatisticDropdownField({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.valueLabel,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T value) valueLabel;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      initialSelection: selected,
      label: Text(label),
      expandedInsets: EdgeInsets.zero,
      requestFocusOnTap: false,
      inputDecorationTheme: StatisticFieldStyle.decorationTheme,
      menuStyle: StatisticFieldStyle.menuStyle,
      dropdownMenuEntries: [
        for (final value in values)
          DropdownMenuEntry(value: value, label: valueLabel(value)),
      ],
      onSelected: (value) {
        if (value != null) onSelected(value);
      },
    );
  }
}

/// Lays the option fields out in equal columns that wrap on narrow screens.
class _StatisticFieldRow extends StatelessWidget {
  const _StatisticFieldRow({required this.children});

  static const _minFieldWidth = 200.0;
  static const _maxColumns = 4;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = NahpuSpacing.lg;
        final columns =
            ((constraints.maxWidth + spacing) / (_minFieldWidth + spacing))
                .floor()
                .clamp(1, _maxColumns);
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: NahpuSpacing.xl,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}
