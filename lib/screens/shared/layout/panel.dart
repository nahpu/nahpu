import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// The standard NAHPU panel: one fill, one radius, one padding.
///
/// Export and transfer screens had grown four card looks side by side — plain
/// cards, tinted cards, and bordered containers — so panels that sit next to
/// each other read as unrelated. The file settings card is the one users see
/// on every export, so its fill is the one everything else matches.
class NahpuPanel extends StatelessWidget {
  const NahpuPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NahpuSpacing.xl),
    this.color,
  });

  final Widget child;

  /// Override only for panels nested inside another one, which need less.
  final EdgeInsetsGeometry padding;

  /// Override only to mark a panel as an error or a highlight.
  final Color? color;

  /// The panel look for surfaces that cannot be a [NahpuPanel] themselves,
  /// such as the wizard step rails, whose padding belongs to their scroll view.
  static BoxDecoration decorationOf(BuildContext context, {Color? color}) {
    final colors = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: color ?? colors.surfaceContainerHighest.withValues(alpha: 0.4),
      border: Border.all(color: colors.outlineVariant, width: NahpuStroke.thin),
      borderRadius: BorderRadius.circular(NahpuRadius.lg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: NahpuElevation.none,
      color: color ?? colors.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant, width: NahpuStroke.thin),
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
