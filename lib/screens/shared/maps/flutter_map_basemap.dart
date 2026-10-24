import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/maps/offline_basemap_notice.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/sites/natural_earth.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;

/// The base layer of a `flutter_map` map, placed first in its children.
///
/// Where `flutter_map` is the only renderer (desktop), online styles are drawn
/// from OpenFreeMap vector tiles. While a style loads, when it fails, and
/// where this map stands in for a failed MapLibre map, it draws the bundled
/// Natural Earth countries instead.
class FlutterMapBasemap extends ConsumerWidget {
  const FlutterMapBasemap({
    super.key,
    required this.style,
    required this.polygons,
    required this.isFallback,
  });

  final SpatialBasemapStyle style;
  final List<NaturalEarthPolygon> polygons;

  /// Whether this map is standing in for a MapLibre map that failed to load.
  /// The failure is usually a missing network, so no online style is tried.
  final bool isFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (style == SpatialBasemapStyle.none) return const SizedBox.shrink();
    final vectorStyle = _onlineStyle(context, style, isFallback: isFallback);
    final loaded = vectorStyle == null
        ? null
        : ref.watch(vectorBasemapStyleProvider(vectorStyle)).value;
    if (loaded == null) return _NaturalEarthLayer(polygons: polygons);
    return vmt.VectorTileLayer(
      theme: loaded.theme,
      sprites: loaded.sprites,
      tileProviders: loaded.providers,
    );
  }
}

/// Attribution for whichever layer [FlutterMapBasemap] drew.
class FlutterMapBasemapAttribution extends ConsumerWidget {
  const FlutterMapBasemapAttribution({
    super.key,
    required this.style,
    required this.isFallback,
  });

  final SpatialBasemapStyle style;
  final bool isFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (style == SpatialBasemapStyle.none) return const SizedBox.shrink();
    if (isFallback) return const OfflineBasemapNotice();
    final vectorStyle = _onlineStyle(context, style, isFallback: isFallback);
    if (vectorStyle == null) return const NaturalEarthAttribution();
    final loaded = ref.watch(vectorBasemapStyleProvider(vectorStyle));
    if (loaded.hasValue) return const _OpenFreeMapAttribution();
    if (loaded.hasError) {
      return OfflineBasemapNotice(
        onRetry: () => ref.invalidate(vectorBasemapStyleProvider(vectorStyle)),
      );
    }
    return const NaturalEarthAttribution();
  }
}

/// The online style to load, resolved for the app brightness, or null when the
/// bundled Natural Earth map is the one to draw.
SpatialBasemapStyle? _onlineStyle(
  BuildContext context,
  SpatialBasemapStyle style, {
  required bool isFallback,
}) {
  if (isFallback) return null;
  final resolved = style.resolve(
    isDark: Theme.of(context).brightness == Brightness.dark,
  );
  return resolved.styleUrl == null ? null : resolved;
}

class _NaturalEarthLayer extends StatelessWidget {
  const _NaturalEarthLayer({required this.polygons});

  final List<NaturalEarthPolygon> polygons;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PolygonLayer(
      polygons: [
        for (final polygon in polygons)
          Polygon(
            points: polygon.points,
            holePointsList: polygon.holes,
            color: colorScheme.surfaceContainerHighest,
            borderColor: colorScheme.outlineVariant,
            borderStrokeWidth: 0.6,
          ),
      ],
    );
  }
}

class _OpenFreeMapAttribution extends StatelessWidget {
  const _OpenFreeMapAttribution();

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
        'OpenFreeMap © OpenMapTiles · © OpenStreetMap contributors',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ),
  );
}
