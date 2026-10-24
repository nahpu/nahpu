import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_legend.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_markers.dart';
import 'package:nahpu/screens/shared/maps/full_screen_map_page.dart';
import 'package:nahpu/screens/shared/maps/flutter_map_basemap.dart';
import 'package:nahpu/services/sites/natural_earth.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_maplibre.dart';
import 'package:nahpu/screens/projects/statistics/offline_user_map_layers.dart';
import 'package:nahpu/screens/settings/application/map_settings.dart';
import 'package:nahpu/services/providers/map_renderer.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/localization/l10n.dart';

final Future<List<NaturalEarthPolygon>> _naturalEarthPolygons =
    loadNaturalEarthPolygons();

class SpatialStatisticsMap extends StatefulWidget {
  const SpatialStatisticsMap({
    super.key,
    required this.kind,
    required this.rows,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;

  @override
  State<SpatialStatisticsMap> createState() => _SpatialStatisticsMapState();
}

class _SpatialStatisticsMapState extends State<SpatialStatisticsMap> {
  bool _fullScreenMapOpen = false;

  @override
  Widget build(BuildContext context) {
    final mappable = mappableSpatialStatistics(widget.rows);
    final omittedCount = widget.rows.length - mappable.length;
    final total = spatialStatisticTotal(widget.rows);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (omittedCount > 0) ...[
          Text(
            context.l10n.projectStatsUnmappedRecords(omittedCount),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
        ],
        // Every screen size shows the map inline. The map's gesture surface
        // yields vertical drags to the page, so small screens still scroll past
        // it; the full-screen action opens the map for closer exploration.
        Expanded(
          child: _fullScreenMapOpen
              ? ColoredBox(color: Theme.of(context).colorScheme.surface)
              : _SpatialMapViewport(
                  kind: widget.kind,
                  rows: mappable,
                  total: total,
                  onViewFullScreen: () =>
                      _showFullScreenMap(context, rows: mappable, total: total),
                ),
        ),
      ],
    );
  }

  Future<void> _showFullScreenMap(
    BuildContext context, {
    required List<SpatialStatisticDatum> rows,
    required int total,
  }) {
    setState(() => _fullScreenMapOpen = true);
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMapPage(
          title: context.l10n.projectStatsSpatialMap,
          child: _SpatialMapViewport(
            kind: widget.kind,
            rows: rows,
            total: total,
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _fullScreenMapOpen = false);
    });
  }
}

class _SpatialMapViewport extends ConsumerWidget {
  const _SpatialMapViewport({
    required this.kind,
    required this.rows,
    required this.total,
    this.onViewFullScreen,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final VoidCallback? onViewFullScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseLayer =
        ref.watch(spatialBasemapStyleProvider).value ??
        SpatialBasemapStyle.automatic;
    final showsBaseLayer = baseLayer != SpatialBasemapStyle.none;
    final actions = [
      _SpatialMapAction(
        tooltip: context.l10n.projectStatsMapLayers,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapLayerSettings()),
        ),
        icon: Icons.layers_outlined,
      ),
      if (onViewFullScreen != null)
        _SpatialMapAction(
          tooltip: context.l10n.projectStatsViewFullScreen,
          onPressed: onViewFullScreen!,
          icon: Icons.fullscreen,
        ),
    ];
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ref.watch(mapRendererProvider) == MapRenderer.naturalEarth
              ? FutureBuilder<List<NaturalEarthPolygon>>(
                  future: showsBaseLayer
                      ? _naturalEarthPolygons
                      : Future.value(const []),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _MapMessage(
                        icon: Icons.public_off_outlined,
                        message: context.l10n.projectStatsNaturalEarthError,
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _NaturalEarthMap(
                      key: ValueKey(
                        '${kind.name}-${rows.map((row) => row.coordinateId).join(',')}',
                      ),
                      kind: kind,
                      rows: rows,
                      total: total,
                      polygons: snapshot.data!,
                      baseLayer: baseLayer,
                      legendInitiallyExpanded: !isNarrow,
                      isFallback: mapLibreIsExpected,
                    );
                  },
                )
              : MapLibreSpatialStatisticsMap(
                  kind: kind,
                  rows: rows,
                  total: total,
                  controlsTopOffset: _SpatialMapActionStack.controlsTopOffset(
                    actions.length,
                  ),
                  legendInitiallyExpanded: !isNarrow,
                ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _SpatialMapActionStack(actions: actions),
        ),
      ],
    );
  }
}

class _SpatialMapActionStack extends StatelessWidget {
  const _SpatialMapActionStack({required this.actions});

  static const buttonExtent = 48.0;
  static const spacing = 8.0;

  final List<Widget> actions;

  static double controlsTopOffset(int actionCount) =>
      8 + actionCount * buttonExtent + actionCount * spacing;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var index = 0; index < actions.length; index++) ...[
        actions[index],
        if (index < actions.length - 1) const SizedBox(height: spacing),
      ],
    ],
  );
}

class _SpatialMapAction extends StatelessWidget {
  const _SpatialMapAction({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: _SpatialMapActionStack.buttonExtent,
    child: Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(8),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    ),
  );
}

class _NaturalEarthMap extends StatelessWidget {
  const _NaturalEarthMap({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
    required this.polygons,
    required this.baseLayer,
    required this.legendInitiallyExpanded,
    required this.isFallback,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final List<NaturalEarthPolygon> polygons;
  final SpatialBasemapStyle baseLayer;
  final bool legendInitiallyExpanded;

  /// Whether this map is standing in for a MapLibre map that failed to load,
  /// rather than being the renderer this platform always uses.
  final bool isFallback;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final points = [
      for (final row in rows)
        LatLng(row.decimalLatitude!, row.decimalLongitude!),
    ];
    final maximumCount = rows.fold<int>(
      0,
      (maximum, row) => math.max(maximum, row.count ?? 0),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: points.length == 1
                  ? points.single
                  : const LatLng(18, 0),
              initialZoom: points.length == 1 ? 12 : 1.5,
              initialCameraFit: points.length > 1
                  ? CameraFit.coordinates(
                      coordinates: points,
                      padding: const EdgeInsets.all(40),
                      maxZoom: 14,
                    )
                  : null,
              minZoom: 1,
              maxZoom: 16,
              backgroundColor: colorScheme.surface,
            ),
            children: [
              FlutterMapBasemap(
                style: baseLayer,
                polygons: polygons,
                isFallback: isFallback,
              ),
              const OfflineUserMapLayers(),
              if (rows.isNotEmpty)
                SpatialStatisticsMarkerLayer(
                  kind: kind,
                  rows: rows,
                  total: total,
                  maximumCount: maximumCount,
                ),
            ],
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: FlutterMapBasemapAttribution(
              style: baseLayer,
              isFallback: isFallback,
            ),
          ),
          if (rows.isEmpty)
            Positioned.fill(
              child: _MapMessage(
                icon: Icons.location_off_outlined,
                message: context.l10n.projectStatsNoValidCoordinates,
              ),
            ),
          if (rows.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: SpatialStatisticsLegend(
                kind: kind,
                rows: rows,
                total: total,
                maximumCount: maximumCount,
                initiallyExpanded: legendInitiallyExpanded,
                groupsOverlaps: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerLow.withValues(alpha: 0.82),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
