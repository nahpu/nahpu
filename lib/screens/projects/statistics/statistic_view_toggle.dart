import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// One choice of a [StatisticViewToggle].
class StatisticViewSegment<T> {
  const StatisticViewSegment({
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final IconData icon;
  final String label;
}

/// Segmented switch between ways of showing statistics, such as chart and
/// table, shared by Summary, Explore, and Analytics so they look alike.
///
/// Segments show their icon and label from medium widths up; on phones they
/// show only the icon, with the label as a tooltip.
class StatisticViewToggle<T> extends StatelessWidget {
  const StatisticViewToggle({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
  });

  final List<StatisticViewSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final iconOnly =
        MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    return SegmentedButton<T>(
      showSelectedIcon: false,
      segments: [
        for (final segment in segments)
          ButtonSegment(
            value: segment.value,
            icon: Icon(segment.icon),
            label: iconOnly ? null : Text(segment.label),
            tooltip: iconOnly ? segment.label : null,
          ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.single),
    );
  }
}
