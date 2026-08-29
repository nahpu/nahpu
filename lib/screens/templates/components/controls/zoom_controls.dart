import 'package:material_ui/material_ui.dart';

class ZoomControls extends StatelessWidget {
  const ZoomControls({
    super.key,
    required this.zoom,
    required this.onZoomChanged,
  });

  final double zoom;
  final ValueChanged<double> onZoomChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.remove, size: 20),
              tooltip: 'Zoom out',
              onPressed: zoom > 0.5
                  ? () => onZoomChanged((zoom - 0.25).clamp(0.5, 4.0))
                  : null,
            ),
            Text(
              '${(zoom * 100).round()}%',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.add, size: 20),
              tooltip: 'Zoom in',
              onPressed: zoom < 4.0
                  ? () => onZoomChanged((zoom + 0.25).clamp(0.5, 4.0))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
