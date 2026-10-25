import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/map_renderer.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Attribution for the bundled basemap, plus why it is standing in for the
/// detailed one and how to go back.
///
/// Shown where MapLibre is the normal renderer, and on desktop when an online
/// OpenFreeMap style could not be loaded.
class OfflineBasemapNotice extends ConsumerWidget {
  const OfflineBasemapNotice({super.key, this.onRetry});

  /// What the retry button does. Defaults to trying MapLibre again; desktop
  /// passes a reload of the OpenFreeMap style it draws with `flutter_map`.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(NahpuRadius.xs),
      child: Padding(
        padding: const EdgeInsets.only(left: NahpuSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: NahpuControlSize.iconSmall,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: NahpuSpacing.sm),
            Text(
              context.l10n.mapNaturalEarthOffline,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            IconButton(
              tooltip: context.l10n.mapRetryDetailed,
              visualDensity: VisualDensity.compact,
              iconSize: NahpuControlSize.iconSmall,
              onPressed:
                  onRetry ??
                  () => ref.read(mapRendererProvider.notifier).retryMapLibre(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plain attribution for the bundled basemap when it is the expected one.
class NaturalEarthAttribution extends StatelessWidget {
  const NaturalEarthAttribution({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(NahpuRadius.xs),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.sm,
        vertical: NahpuSpacing.xs,
      ),
      child: Text(
        'Natural Earth',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ),
  );
}
