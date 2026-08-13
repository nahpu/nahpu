import 'dart:io';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_legend.dart';
import 'package:nahpu/screens/shared/maps/full_screen_map_page.dart';
import 'package:nahpu/services/sites/natural_earth.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_maplibre.dart';
import 'package:nahpu/screens/projects/statistics/linux_user_map_layers.dart';
import 'package:nahpu/screens/settings/map_settings.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/map_layers.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (omittedCount > 0) ...[
            Text(
              '$omittedCount ${omittedCount == 1 ? 'record is' : 'records are'} '
              'listed in the table but cannot be mapped because latitude or '
              'longitude is missing or invalid.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
          ],
          if (constraints.maxWidth < 600)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: FilledButton.icon(
                key: const ValueKey('spatial-statistics-view-map'),
                onPressed: () =>
                    _showFullScreenMap(context, rows: mappable, total: total),
                icon: const Icon(Icons.map_outlined),
                label: const Text('View map'),
              ),
            )
          else
            SizedBox(
              height: 480,
              child: _fullScreenMapOpen
                  ? ColoredBox(color: Theme.of(context).colorScheme.surface)
                  : _SpatialMapViewport(
                      kind: widget.kind,
                      rows: mappable,
                      total: total,
                      onViewFullScreen: () => _showFullScreenMap(
                        context,
                        rows: mappable,
                        total: total,
                      ),
                    ),
            ),
        ],
      ),
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
          title: 'Spatial statistics map',
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
        tooltip: 'Map layers',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapLayerSettings()),
        ),
        icon: Icons.layers_outlined,
      ),
      if (onViewFullScreen != null)
        _SpatialMapAction(
          tooltip: 'View map full screen',
          onPressed: onViewFullScreen!,
          icon: Icons.fullscreen,
        ),
    ];
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Platform.isLinux
              ? FutureBuilder<List<NaturalEarthPolygon>>(
                  future: showsBaseLayer
                      ? _naturalEarthPolygons
                      : Future.value(const []),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const _MapMessage(
                        icon: Icons.public_off_outlined,
                        message:
                            'Unable to load the offline Natural Earth map.',
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
                      showsBaseLayer: showsBaseLayer,
                      legendInitiallyExpanded: !isNarrow,
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
    required this.showsBaseLayer,
    required this.legendInitiallyExpanded,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final List<NaturalEarthPolygon> polygons;
  final bool showsBaseLayer;
  final bool legendInitiallyExpanded;

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
    final markers = [...rows]
      ..sort((a, b) => (b.count ?? 0).compareTo(a.count ?? 0));

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
              if (showsBaseLayer)
                PolygonLayer(
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
                ),
              const LinuxUserMapLayers(),
              if (rows.isNotEmpty)
                MarkerLayer(
                  markers: [
                    for (final row in markers)
                      _marker(
                        context,
                        row,
                        maximumCount: maximumCount,
                        total: total,
                        colorScheme: colorScheme,
                      ),
                  ],
                ),
            ],
          ),
          if (showsBaseLayer)
            Positioned(
              left: 8,
              bottom: 8,
              child: _MapAttribution(colorScheme: colorScheme),
            ),
          if (rows.isEmpty)
            const Positioned.fill(
              child: _MapMessage(
                icon: Icons.location_off_outlined,
                message: 'No valid coordinates are available to map.',
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
              ),
            ),
        ],
      ),
    );
  }

  Marker _marker(
    BuildContext context,
    SpatialStatisticDatum row, {
    required int maximumCount,
    required int total,
    required ColorScheme colorScheme,
  }) {
    final radius = spatialMarkerRadius(
      kind: kind,
      count: row.count ?? 0,
      maximumCount: maximumCount,
    );
    final diameter = radius * 2 + 3;
    final countText = kind.hasCounts
        ? ', ${row.count} ${kind.countLabel} '
              '(${spatialStatisticPercent(row, total).toStringAsFixed(1)}%)'
        : '';
    return Marker(
      point: LatLng(row.decimalLatitude!, row.decimalLongitude!),
      width: diameter,
      height: diameter,
      child: Semantics(
        button: true,
        label: '${row.displayName}$countText',
        child: Tooltip(
          message: '${row.displayName}$countText',
          triggerMode: TooltipTriggerMode.tap,
          waitDuration: Duration.zero,
          showDuration: const Duration(seconds: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.32),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.86),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) => Material(
    color: colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(4),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text('Natural Earth', style: TextStyle(fontSize: 12)),
    ),
  );
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
