import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Padding inside a property panel docked under the editor toolbar, kept tight
/// so the panel costs as little canvas height as possible.
const EdgeInsets kTemplateToolbarPanelPadding = EdgeInsets.symmetric(
  horizontal: NahpuSpacing.xs,
  vertical: NahpuSpacing.xxs,
);

/// Frame for element and border properties.
///
/// Docked under the editor toolbar ([inToolbar]), it sits flat on the same
/// surface as the toolbar so the two read as one bar. Otherwise it is a raised
/// sheet.
class TemplatePropertyPanelShell extends StatelessWidget {
  const TemplatePropertyPanelShell({
    super.key,
    required this.child,
    required this.inToolbar,
    this.onDismiss,
  });

  final Widget child;
  final bool inToolbar;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wrappedChild = Row(
      children: [
        Expanded(child: child),
        if (onDismiss != null) ...[
          SizedBox(
            height: NahpuControlSize.iconLarge,
            child: VerticalDivider(
              width: NahpuSpacing.md,
              thickness: NahpuStroke.thin,
              color: scheme.outlineVariant,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: NahpuControlSize.iconMedium),
            tooltip: 'Dismiss toolbar',
            onPressed: onDismiss,
          ),
        ],
      ],
    );

    if (inToolbar) {
      return Material(color: scheme.surface, child: wrappedChild);
    }

    return Material(
      elevation: NahpuElevation.low,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(top: false, child: wrappedChild),
    );
  }
}

class TemplateOptionSlider extends StatelessWidget {
  const TemplateOptionSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final safeMin = min <= max ? min : max;
    final safeMax = max >= min ? max : min;
    final safeValue = value.clamp(safeMin, safeMax).toDouble();
    final safeDivisions = divisions > 0 ? divisions : null;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.12),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: TextStyle(color: scheme.onPrimary),
        valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
      child: Slider(
        value: safeValue,
        min: safeMin,
        max: safeMax,
        divisions: safeDivisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }
}
