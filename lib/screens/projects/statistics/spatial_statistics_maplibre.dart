import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre/maplibre.dart';
import 'package:nahpu/screens/shared/maps/maplibre_gesture_surface.dart';
import 'package:nahpu/screens/shared/maps/maplibre_camera_readiness.dart';
import 'package:nahpu/screens/shared/maps/maplibre_load_watchdog.dart';
import 'package:nahpu/screens/shared/maps/maplibre_viewport_projection.dart';
import 'package:nahpu/screens/shared/maps/map_point_hit_test.dart';
import 'package:nahpu/screens/shared/maps/map_tooltip_card.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/providers/map_renderer.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/statistics/spatial_map_style.dart';
import 'package:nahpu/services/statistics/spatial_marker_clusters.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_legend.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_marker_visuals.dart';

class MapLibreSpatialStatisticsMap extends ConsumerWidget {
  const MapLibreSpatialStatisticsMap({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
    required this.controlsTopOffset,
    required this.legendInitiallyExpanded,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final double controlsTopOffset;
  final bool legendInitiallyExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basemap =
        ref.watch(spatialBasemapStyleProvider).value ??
        SpatialBasemapStyle.automatic;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catalog =
        ref.watch(userMapCatalogProvider).value ?? const UserMapCatalog();
    final style = getUserMapDirectory().then(
      (directory) => SpatialMapStyleService.build(
        style: basemap,
        isDark: isDark,
        colorScheme: colorScheme,
        kind: kind,
        rows: rows,
        total: total,
        catalog: catalog,
        userMapDirectory: directory,
      ),
    );
    return FutureBuilder<String>(
      future: style,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _MapLibreMessage(
            message: 'Unable to prepare the map: ${snapshot.error}',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _MapLibreMap(
          key: ValueKey(snapshot.data.hashCode),
          kind: kind,
          rows: rows,
          total: total,
          style: snapshot.data!,
          baseLayer: basemap,
          controlsTopOffset: controlsTopOffset,
          legendInitiallyExpanded: legendInitiallyExpanded,
        );
      },
    );
  }
}

class _MapLibreMap extends ConsumerStatefulWidget {
  const _MapLibreMap({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
    required this.style,
    required this.baseLayer,
    required this.controlsTopOffset,
    required this.legendInitiallyExpanded,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final String style;
  final SpatialBasemapStyle baseLayer;
  final double controlsTopOffset;
  final bool legendInitiallyExpanded;

  @override
  ConsumerState<_MapLibreMap> createState() => _MapLibreMapState();
}

class _MapLibreMapState extends ConsumerState<_MapLibreMap> {
  static const double _maxZoom = 16;

  MapController? _controller;
  final _readiness = MapLibreCameraReadiness();
  late final _watchdog = MapLibreLoadWatchdog(onTimeout: _handleLoadTimeout);
  _SpatialMapTooltip? _tooltip;

  /// Built once per state. [MapOptions] compares by identity, so a fresh
  /// instance on every build makes the web view backend re-apply the options,
  /// which throws while its controller is still being created.
  late final MapOptions _options = _buildOptions();

  bool get _isReady => mounted && _readiness.isReady;

  @override
  void initState() {
    super.initState();
    _watchdog.start();
  }

  @override
  void didUpdateWidget(covariant _MapLibreMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tooltip = _tooltip;
    if (tooltip != null &&
        !tooltip.coordinateIds.every(
          (id) => widget.rows.any((row) => row.coordinateId == id),
        )) {
      _tooltip = null;
    }
  }

  @override
  void dispose() {
    _watchdog.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maximumCount = widget.rows.fold<int>(
      0,
      (maximum, row) => math.max(maximum, row.count ?? 0),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          MapLibreMap(
            gestureRecognizers: {...mapLibreGestureRecognizers()},
            options: _options,
            onMapCreated: (controller) {
              if (!mounted) return;
              _controller = controller;
              _readiness.markMapCreated();
              _markRendered();
              _initializeCamera();
            },
            onStyleLoaded: (_) {
              _readiness.markStyleLoaded();
              _markRendered();
              _initializeCamera();
            },
            onEvent: _handleEvent,
            children: [
              _SpatialMarkerOverlay(
                kind: widget.kind,
                rows: widget.rows,
                maximumCount: maximumCount,
              ),
              Positioned.fill(
                child: MapLibreGestureSurface(onTapUp: _handleMapTap),
              ),
              if (_tooltip case final tooltip?)
                MapTooltipLayer(
                  point: tooltip.point,
                  title: tooltip.title,
                  details: tooltip.details,
                ),
              if (widget.baseLayer != SpatialBasemapStyle.none)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _MapLibreAttribution(
                    label:
                        widget.baseLayer ==
                            SpatialBasemapStyle.naturalEarthOffline
                        ? 'Natural Earth'
                        : '© OpenStreetMap contributors · OpenFreeMap',
                  ),
                ),
              Positioned(
                left: 8,
                top: widget.controlsTopOffset,
                child: _MapLibreControls(
                  onReset: _resetCamera,
                  onZoomIn: () => _changeZoom(1),
                  onZoomOut: () => _changeZoom(-1),
                ),
              ),
              const Positioned(right: 8, bottom: 8, child: MapScalebar()),
            ],
          ),
          if (_watchdog.isWaiting)
            const Positioned.fill(child: _MapLibreLoading())
          else if (widget.rows.isEmpty)
            const Positioned.fill(
              child: _MapLibreMessage(
                message: 'No valid coordinates are available to map.',
              ),
            ),
          if (widget.rows.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: SpatialStatisticsLegend(
                kind: widget.kind,
                rows: widget.rows,
                total: widget.total,
                maximumCount: maximumCount,
                initiallyExpanded: widget.legendInitiallyExpanded,
                groupsOverlaps: true,
              ),
            ),
        ],
      ),
    );
  }

  /// Stops the watchdog once MapLibre has actually drawn something.
  void _markRendered() {
    if (!_readiness.isReady) return;
    if (_watchdog.markReady() && mounted) setState(() {});
  }

  /// Hands the session over to the offline renderer after a map that never
  /// loaded. The provider latches, so no later map waits this out again.
  void _handleLoadTimeout() {
    if (!mounted) return;
    ref.read(mapRendererProvider.notifier).markMapLibreUnavailable();
  }

  MapOptions _buildOptions() {
    final first = widget.rows.firstOrNull;
    return MapOptions(
      initStyle: widget.style,
      initCenter: Geographic(
        lon: first?.decimalLongitude ?? 0,
        lat: first?.decimalLatitude ?? 18,
      ),
      initZoom: widget.rows.length == 1 ? 12 : 1.5,
      minZoom: 1,
      maxZoom: _maxZoom,
      maxPitch: 60,
      gestures: const MapGestures(
        pan: true,
        zoom: true,
        rotate: false,
        pitch: false,
      ),
    );
  }

  Future<void> _fitRows() async {
    final controller = _controller;
    if (!_isReady || controller == null || widget.rows.length < 2) return;
    await controller.fitBounds(
      bounds: LngLatBounds.fromPoints([
        for (final row in widget.rows)
          Geographic(lon: row.decimalLongitude!, lat: row.decimalLatitude!),
      ]),
      padding: const EdgeInsets.all(40),
      webMaxZoom: 14,
    );
  }

  Future<void> _resetCamera() async {
    _clearTooltip();
    final controller = _controller;
    if (!_isReady || controller == null) {
      _readiness.requestReset();
      return;
    }
    if (widget.rows.length > 1) return _fitRows();
    final row = widget.rows.firstOrNull;
    await controller.animateCamera(
      center: Geographic(
        lon: row?.decimalLongitude ?? 0,
        lat: row?.decimalLatitude ?? 18,
      ),
      zoom: row == null ? 1.5 : 12,
      nativeDuration: const Duration(milliseconds: 250),
    );
  }

  Future<void> _changeZoom(double amount) async {
    _clearTooltip();
    final controller = _controller;
    if (!_isReady || controller == null) return;
    await controller.animateCamera(
      zoom: (controller.getCamera().zoom + amount)
          .clamp(1, _maxZoom)
          .toDouble(),
      nativeDuration: const Duration(milliseconds: 200),
    );
  }

  void _handleEvent(MapEvent event) {
    if (event is! MapEventStartMoveCamera ||
        event.reason != CameraChangeReason.apiGesture) {
      return;
    }
    _clearTooltip();
  }

  void _handleMapTap(MapLibreTapDetails details) {
    final controller = _controller;
    if (!_isReady || controller == null) return;
    final camera = controller.getCamera();
    final maximumCount = _maximumCount;
    Offset project(SpatialStatisticDatum row) => mapLibreViewportScreenLocation(
      camera: camera,
      viewportSize: details.viewportSize,
      point: _geographic(row),
    );
    // Hit-test the same groups the overlay draws, so a tap lands on what the
    // user sees.
    final clusters = clusterSpatialStatistics(
      rows: widget.rows,
      maximumCount: maximumCount,
      screenPosition: (row) {
        final offset = project(row);
        return math.Point(offset.dx, offset.dy);
      },
    );
    final cluster = closestMapPoint<MarkerCluster<SpatialStatisticDatum>>(
      tapPosition: details.localPosition,
      points: clusters,
      screenPosition: (cluster) => Offset(cluster.center.x, cluster.center.y),
      hitRadius: (cluster) => mapMarkerHitRadius(
        cluster.isSingle
            ? spatialMarkerRadius(
                kind: widget.kind,
                count: cluster.count,
                maximumCount: maximumCount,
              )
            : spatialClusterDisplayRadius(
                count: cluster.count,
                maximumCount: maximumCount,
              ),
      ),
    );
    if (cluster == null || !mounted) {
      _clearTooltip();
      return;
    }
    if (cluster.isSingle) {
      final row = cluster.members.single;
      setState(() {
        _tooltip = _SpatialMapTooltip(
          point: _geographic(row),
          title: row.displayName,
          details: [
            '${row.count ?? 0} ${widget.kind.countLabel} '
                '(${spatialStatisticPercent(row, widget.total).toStringAsFixed(1)}%)',
          ],
          coordinateIds: [row.coordinateId],
        );
      });
      return;
    }
    if (_canZoomIn(camera)) {
      _clearTooltip();
      _zoomToCluster(cluster.members);
      return;
    }
    final center = spatialClusterCenter(cluster.members);
    setState(() {
      _tooltip = _SpatialMapTooltip(
        point: Geographic(lon: center.longitude, lat: center.latitude),
        title: spatialClusterTitle(widget.kind, cluster.members, cluster.count),
        details: spatialClusterDetails(cluster.members, canZoomIn: false),
        coordinateIds: [for (final row in cluster.members) row.coordinateId],
      );
    });
  }

  /// Zooms in on a grouped bubble so its coordinates split apart.
  Future<void> _zoomToCluster(List<SpatialStatisticDatum> members) async {
    final controller = _controller;
    if (!_isReady || controller == null) return;
    final zoom = controller.getCamera().zoom;
    final bounds = LngLatBounds.fromPoints([
      for (final row in members) _geographic(row),
    ]);
    final isPoint =
        (bounds.longitudeEast - bounds.longitudeWest).abs() < 1e-6 &&
        (bounds.latitudeNorth - bounds.latitudeSouth).abs() < 1e-6;
    // Fitting shared or near-identical coordinates could zoom out, so those
    // step in two levels around their center instead.
    if (isPoint || members.length < 2) {
      final center = spatialClusterCenter(members);
      await controller.animateCamera(
        center: Geographic(lon: center.longitude, lat: center.latitude),
        zoom: (zoom + 2).clamp(1, _maxZoom).toDouble(),
        nativeDuration: const Duration(milliseconds: 250),
      );
      return;
    }
    await controller.fitBounds(
      bounds: bounds,
      padding: const EdgeInsets.all(64),
      webMaxZoom: _maxZoom,
    );
  }

  bool _canZoomIn(MapCamera camera) => camera.zoom < _maxZoom - 0.5;

  int get _maximumCount => widget.rows.fold<int>(
    0,
    (maximum, row) => math.max(maximum, row.count ?? 0),
  );

  Geographic _geographic(SpatialStatisticDatum row) =>
      Geographic(lon: row.decimalLongitude!, lat: row.decimalLatitude!);

  void _clearTooltip() {
    if (!mounted || _tooltip == null) return;
    setState(() => _tooltip = null);
  }

  Future<void> _initializeCamera() async {
    if (!_readiness.claimInitialCamera()) return;
    if (_readiness.takePendingReset()) {
      await _resetCamera();
      return;
    }
    await _fitRows();
  }
}

/// Spatial circles drawn by Flutter over the MapLibre map, grouping those that
/// overlap at the current camera into numbered bubbles.
///
/// Drawn here rather than as a style layer so grouping can follow the zoom.
/// Points are projected from the camera and this widget's own size, as
/// [MapTooltipLayer] does, because the WebView backend's cached size can lag.
class _SpatialMarkerOverlay extends StatelessWidget {
  const _SpatialMarkerOverlay({
    required this.kind,
    required this.rows,
    required this.maximumCount,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int maximumCount;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.maybeOf(context);
    if (camera == null || rows.isEmpty) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = constraints.biggest;
            final clusters = clusterSpatialStatistics(
              rows: rows,
              maximumCount: maximumCount,
              screenPosition: (row) {
                final offset = mapLibreViewportScreenLocation(
                  camera: camera,
                  viewportSize: viewport,
                  point: Geographic(
                    lon: row.decimalLongitude!,
                    lat: row.decimalLatitude!,
                  ),
                );
                return math.Point(offset.dx, offset.dy);
              },
            );
            // Larger circles first so smaller ones stay on top; bubbles last.
            final singles =
                clusters.where((cluster) => cluster.isSingle).toList()
                  ..sort((a, b) => b.count.compareTo(a.count));
            final groups = clusters.where((cluster) => !cluster.isSingle);
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (final cluster in [...singles, ...groups])
                  _OverlayMarker(
                    kind: kind,
                    cluster: cluster,
                    maximumCount: maximumCount,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One circle or bubble of [_SpatialMarkerOverlay], centered on its point.
class _OverlayMarker extends StatelessWidget {
  const _OverlayMarker({
    required this.kind,
    required this.cluster,
    required this.maximumCount,
  });

  final SpatialStatisticKind kind;
  final MarkerCluster<SpatialStatisticDatum> cluster;
  final int maximumCount;

  @override
  Widget build(BuildContext context) {
    final radius = cluster.isSingle
        ? spatialMarkerRadius(
            kind: kind,
            count: cluster.count,
            maximumCount: maximumCount,
          )
        : spatialClusterDisplayRadius(
            count: cluster.count,
            maximumCount: maximumCount,
          );
    final diameter = radius * 2 + 3;
    return Positioned(
      left: cluster.center.x - diameter / 2,
      top: cluster.center.y - diameter / 2,
      child: cluster.isSingle
          ? SpatialPointCircle(
              diameter: diameter,
              countLabel: kind.hasCounts ? '${cluster.count}' : null,
            )
          : SpatialClusterBubble(
              diameter: diameter,
              countLabel: '${cluster.count}',
              coordinateCount: cluster.members.length,
            ),
    );
  }
}

/// What the map tooltip shows, and which coordinates it describes.
class _SpatialMapTooltip {
  const _SpatialMapTooltip({
    required this.point,
    required this.title,
    required this.details,
    required this.coordinateIds,
  });

  final Geographic point;
  final String title;
  final List<String> details;
  final List<int> coordinateIds;
}

class _MapLibreControls extends StatelessWidget {
  const _MapLibreControls({
    required this.onReset,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onReset;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapLibreControlButton(
          tooltip: 'Zoom in',
          icon: Icons.add,
          onPressed: onZoomIn,
        ),
        _MapLibreControlButton(
          tooltip: 'Zoom out',
          icon: Icons.remove,
          onPressed: onZoomOut,
        ),
        _MapLibreControlButton(
          tooltip: 'Center map on statistics',
          icon: Icons.center_focus_strong_outlined,
          onPressed: onReset,
        ),
      ],
    ),
  );
}

class _MapLibreControlButton extends StatelessWidget {
  const _MapLibreControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
    onPressed: onPressed,
    icon: Icon(icon),
  );
}

class _MapLibreAttribution extends StatelessWidget {
  const _MapLibreAttribution({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    ),
  );
}

class _MapLibreLoading extends StatelessWidget {
  const _MapLibreLoading();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerLow.withValues(alpha: 0.82),
    child: const Center(child: CircularProgressIndicator()),
  );
}

class _MapLibreMessage extends StatelessWidget {
  const _MapLibreMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerLow.withValues(alpha: 0.82),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    ),
  );
}
