import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre/maplibre.dart' as maplibre;
import 'package:nahpu/screens/shared/maps/coordinate_map_markers.dart';
import 'package:nahpu/screens/shared/maps/maplibre_gesture_surface.dart';
import 'package:nahpu/screens/shared/maps/maplibre_camera_readiness.dart';
import 'package:nahpu/screens/shared/maps/flutter_map_basemap.dart';
import 'package:nahpu/screens/shared/maps/maplibre_viewport_projection.dart';
import 'package:nahpu/screens/shared/maps/map_tooltip_card.dart';
import 'package:nahpu/screens/shared/maps/map_point_hit_test.dart';
import 'package:nahpu/screens/projects/statistics/offline_user_map_layers.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_marker_visuals.dart';
import 'package:nahpu/services/sites/coordinate_map_point.dart';
import 'package:nahpu/services/sites/natural_earth.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/providers/map_renderer.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/statistics/spatial_map_style.dart';
import 'package:nahpu/services/statistics/spatial_marker_clusters.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// A shared, read-only coordinate map. Selecting a marker reports the
/// corresponding coordinate to the owner; it never creates or edits points.
class CoordinateLocationMap extends ConsumerWidget {
  const CoordinateLocationMap({
    super.key,
    required this.points,
    required this.selectedPointId,
    required this.onPointSelected,
    this.selectedPointIds,
    this.focusRequest = 0,
    this.controlsTopOffset = 8,
    this.groupsOverlaps = false,
  });

  final List<CoordinateMapPoint> points;
  final Set<int>? selectedPointIds;
  final int? selectedPointId;
  final int focusRequest;
  final ValueChanged<int> onPointSelected;
  final double controlsTopOffset;

  /// Whether markers that overlap on screen draw as one numbered bubble that
  /// splits apart as the map zooms in.
  final bool groupsOverlaps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappable = points.where((point) => point.isMappable).toList();
    final selectedIds =
        selectedPointIds ?? {for (final point in mappable) point.id};
    final baseLayer =
        ref.watch(spatialBasemapStyleProvider).value ??
        SpatialBasemapStyle.automatic;
    final showsBaseLayer = baseLayer != SpatialBasemapStyle.none;
    if (ref.watch(mapRendererProvider) == MapRenderer.naturalEarth) {
      return FutureBuilder<List<NaturalEarthPolygon>>(
        future: showsBaseLayer
            ? _naturalEarthPolygons
            : Future.value(const <NaturalEarthPolygon>[]),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const _MapMessage();
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _NaturalEarthCoordinateMap(
            points: mappable,
            polygons: snapshot.data!,
            selectedPointIds: selectedIds,
            selectedPointId: selectedPointId,
            focusRequest: focusRequest,
            onPointSelected: onPointSelected,
            controlsTopOffset: controlsTopOffset,
            groupsOverlaps: groupsOverlaps,
            baseLayer: baseLayer,
            isFallback: mapLibreIsExpected,
          );
        },
      );
    }
    final catalog =
        ref.watch(userMapCatalogProvider).value ?? const UserMapCatalog();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = getUserMapDirectory().then(
      (directory) => SpatialMapStyleService.buildCoordinatePoints(
        style: baseLayer,
        isDark: isDark,
        colorScheme: colorScheme,
        catalog: catalog,
        userMapDirectory: directory,
      ),
    );
    return FutureBuilder<String>(
      future: style,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _MapMessage();
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _MapLibreCoordinateMap(
          key: ValueKey(snapshot.data.hashCode),
          points: mappable,
          selectedPointIds: selectedIds,
          selectedPointId: selectedPointId,
          focusRequest: focusRequest,
          onPointSelected: onPointSelected,
          basemap: baseLayer,
          style: snapshot.data!,
          controlsTopOffset: controlsTopOffset,
          groupsOverlaps: groupsOverlaps,
        );
      },
    );
  }
}

final Future<List<NaturalEarthPolygon>> _naturalEarthPolygons =
    loadNaturalEarthPolygons();

class _NaturalEarthCoordinateMap extends StatefulWidget {
  const _NaturalEarthCoordinateMap({
    required this.points,
    required this.polygons,
    required this.selectedPointIds,
    required this.selectedPointId,
    required this.focusRequest,
    required this.onPointSelected,
    required this.controlsTopOffset,
    required this.groupsOverlaps,
    required this.baseLayer,
    required this.isFallback,
  });

  final List<CoordinateMapPoint> points;
  final List<NaturalEarthPolygon> polygons;
  final Set<int> selectedPointIds;
  final int? selectedPointId;
  final int focusRequest;
  final ValueChanged<int> onPointSelected;
  final double controlsTopOffset;
  final bool groupsOverlaps;
  final SpatialBasemapStyle baseLayer;

  /// Whether this map is standing in for a MapLibre map that failed to load,
  /// rather than being the renderer this platform always uses.
  final bool isFallback;

  @override
  State<_NaturalEarthCoordinateMap> createState() =>
      _NaturalEarthCoordinateMapState();
}

class _NaturalEarthCoordinateMapState
    extends State<_NaturalEarthCoordinateMap> {
  final _controller = flutter_map.MapController();
  bool _isReady = false;
  bool _resetPending = false;

  @override
  void didUpdateWidget(covariant _NaturalEarthCoordinateMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPointId != oldWidget.selectedPointId ||
        widget.focusRequest != oldWidget.focusRequest) {
      final point = widget.points
          .where((candidate) => candidate.id == widget.selectedPointId)
          .firstOrNull;
      if (point != null && _isReady) _controller.move(_latLng(point), 12);
    }
  }

  @override
  void dispose() {
    _isReady = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locations = [for (final point in widget.points) _latLng(point)];
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          flutter_map.FlutterMap(
            mapController: _controller,
            options: flutter_map.MapOptions(
              initialCenter: locations.length == 1
                  ? locations.single
                  : const LatLng(18, 0),
              initialZoom: locations.length == 1 ? 12 : 1.5,
              initialCameraFit: locations.length > 1
                  ? flutter_map.CameraFit.coordinates(
                      coordinates: locations,
                      padding: const EdgeInsets.all(40),
                      maxZoom: 14,
                    )
                  : null,
              minZoom: 1,
              maxZoom: 16,
              backgroundColor: colorScheme.surface,
              onMapReady: _onMapReady,
            ),
            children: [
              FlutterMapBasemap(
                style: widget.baseLayer,
                polygons: widget.polygons,
                isFallback: widget.isFallback,
              ),
              const OfflineUserMapLayers(),
              _FlutterMapCoordinateMarkers(
                points: widget.points,
                selectedPointIds: widget.selectedPointIds,
                focusedPointId: widget.selectedPointId,
                groupsOverlaps: widget.groupsOverlaps,
                onPointSelected: widget.onPointSelected,
              ),
              flutter_map.Scalebar(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(12),
                textStyle: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  shadows: mapLabelHalo(colorScheme),
                ),
                lineColor: colorScheme.onSurface,
              ),
            ],
          ),
          Positioned(
            left: 8,
            top: widget.controlsTopOffset,
            child: _MapControls(
              onZoomIn: () => _changeZoom(1),
              onZoomOut: () => _changeZoom(-1),
              onReset: _resetCamera,
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: FlutterMapBasemapAttribution(
              style: widget.baseLayer,
              isFallback: widget.isFallback,
            ),
          ),
          if (widget.points.isEmpty)
            const Positioned.fill(child: _MapMessage()),
        ],
      ),
    );
  }

  void _changeZoom(double amount) {
    if (!_isReady || !mounted) return;
    final camera = _controller.camera;
    _controller.move(
      camera.center,
      (camera.zoom + amount).clamp(1, 16).toDouble(),
    );
  }

  void _resetCamera() {
    if (!_isReady || !mounted) {
      _resetPending = true;
      return;
    }
    final locations = [for (final point in widget.points) _latLng(point)];
    if (locations.length > 1) {
      _controller.fitCamera(
        flutter_map.CameraFit.coordinates(
          coordinates: locations,
          padding: const EdgeInsets.all(40),
          maxZoom: 14,
        ),
      );
      return;
    }
    _controller.move(
      locations.firstOrNull ?? const LatLng(18, 0),
      locations.isEmpty ? 1.5 : 12,
    );
  }

  void _onMapReady() {
    if (!mounted) return;
    _isReady = true;
    if (_resetPending) {
      _resetPending = false;
      _resetCamera();
      return;
    }
    final point = widget.points
        .where((candidate) => candidate.id == widget.selectedPointId)
        .firstOrNull;
    if (point != null) _controller.move(_latLng(point), 12);
  }
}

class _MapLibreCoordinateMap extends ConsumerStatefulWidget {
  const _MapLibreCoordinateMap({
    super.key,
    required this.points,
    required this.selectedPointIds,
    required this.selectedPointId,
    required this.focusRequest,
    required this.onPointSelected,
    required this.basemap,
    required this.style,
    required this.controlsTopOffset,
    required this.groupsOverlaps,
  });

  final List<CoordinateMapPoint> points;
  final Set<int> selectedPointIds;
  final int? selectedPointId;
  final int focusRequest;
  final ValueChanged<int> onPointSelected;
  final SpatialBasemapStyle basemap;
  final String style;
  final double controlsTopOffset;
  final bool groupsOverlaps;

  @override
  ConsumerState<_MapLibreCoordinateMap> createState() =>
      _MapLibreCoordinateMapState();
}

class _MapLibreCoordinateMapState
    extends ConsumerState<_MapLibreCoordinateMap> {
  maplibre.MapController? _controller;
  final _readiness = MapLibreCameraReadiness();
  _CoordinateMapTooltip? _tooltip;

  /// Built once per state so rebuilds do not re-apply the initial options.
  late final maplibre.MapOptions _options = _buildOptions();

  bool get _isReady => mounted && _readiness.isReady;

  @override
  void didUpdateWidget(covariant _MapLibreCoordinateMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = {for (final point in widget.points) point.id};
    if (_tooltip != null && !_tooltip!.pointIds.every(ids.contains)) {
      _tooltip = null;
    }
    if (_isReady &&
        (widget.selectedPointId != oldWidget.selectedPointId ||
            widget.focusRequest != oldWidget.focusRequest)) {
      unawaited(_focusSelected());
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          maplibre.MapLibreMap(
            gestureRecognizers: {...mapLibreGestureRecognizers()},
            options: _options,
            onMapCreated: (controller) {
              if (!mounted) return;
              _controller = controller;
              _readiness.markMapCreated();
              _initializeMap();
            },
            onStyleLoaded: (_) {
              _readiness.markStyleLoaded();
              _initializeMap();
            },
            onEvent: _handleEvent,
            children: [
              _MapLibreCoordinateMarkers(
                points: widget.points,
                selectedPointIds: widget.selectedPointIds,
                focusedPointId: widget.selectedPointId,
                groupsOverlaps: widget.groupsOverlaps,
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
              if (widget.basemap != SpatialBasemapStyle.none)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _BaseLayerAttribution(
                    label:
                        widget.basemap ==
                            SpatialBasemapStyle.naturalEarthOffline
                        ? 'Natural Earth'
                        : '© OpenStreetMap contributors · OpenFreeMap',
                  ),
                ),
              Positioned(
                left: 8,
                top: widget.controlsTopOffset,
                child: _MapControls(
                  onZoomIn: () => _changeZoom(1),
                  onZoomOut: () => _changeZoom(-1),
                  onReset: _resetCamera,
                ),
              ),
              const Positioned(
                right: 8,
                bottom: 8,
                child: maplibre.MapScalebar(),
              ),
            ],
          ),
          if (widget.points.isEmpty)
            const Positioned.fill(child: _MapMessage()),
        ],
      ),
    );
  }

  maplibre.MapOptions _buildOptions() {
    final first = widget.points.firstOrNull;
    return maplibre.MapOptions(
      initStyle: widget.style,
      initCenter: maplibre.Geographic(
        lon: first?.longitude ?? 0,
        lat: first?.latitude ?? 18,
      ),
      initZoom: widget.points.length == 1 ? 12 : 1.5,
      minZoom: 1,
      maxZoom: 16,
      gestures: const maplibre.MapGestures(
        pan: true,
        zoom: true,
        rotate: false,
        pitch: false,
      ),
    );
  }

  Future<void> _fitPoints() async {
    final controller = _controller;
    if (!_isReady || controller == null || widget.points.length < 2) return;
    await controller.fitBounds(
      bounds: maplibre.LngLatBounds.fromPoints([
        for (final point in widget.points)
          maplibre.Geographic(lon: point.longitude!, lat: point.latitude!),
      ]),
      padding: const EdgeInsets.all(40),
      webMaxZoom: 14,
    );
  }

  Future<void> _focusSelected() async {
    final controller = _controller;
    final point = widget.points
        .where((candidate) => candidate.id == widget.selectedPointId)
        .firstOrNull;
    if (!_isReady || controller == null || point == null) return;
    await controller.animateCamera(
      center: maplibre.Geographic(lon: point.longitude!, lat: point.latitude!),
      zoom: 12,
      nativeDuration: const Duration(milliseconds: 250),
    );
  }

  Future<void> _changeZoom(double amount) async {
    _clearTooltip();
    final controller = _controller;
    if (!_isReady || controller == null) return;
    await controller.animateCamera(
      zoom: (controller.getCamera().zoom + amount).clamp(1, 16).toDouble(),
      nativeDuration: const Duration(milliseconds: 200),
    );
  }

  Future<void> _resetCamera() async {
    _clearTooltip();
    if (!_isReady) {
      _readiness.requestReset();
      return;
    }
    if (widget.points.length > 1) return _fitPoints();
    final controller = _controller;
    if (controller == null) return;
    final point = widget.points.firstOrNull;
    await controller.animateCamera(
      center: maplibre.Geographic(
        lon: point?.longitude ?? 0,
        lat: point?.latitude ?? 18,
      ),
      zoom: point == null ? 1.5 : 12,
      nativeDuration: const Duration(milliseconds: 250),
    );
  }

  void _handleEvent(maplibre.MapEvent event) {
    if (event is! maplibre.MapEventStartMoveCamera ||
        event.reason != maplibre.CameraChangeReason.apiGesture) {
      return;
    }
    _clearTooltip();
  }

  void _handleMapTap(MapLibreTapDetails details) {
    final controller = _controller;
    if (!_isReady || controller == null) return;
    final camera = controller.getCamera();
    // Hit-test the same groups the overlay draws, so a tap lands on what the
    // user sees.
    final clusters = clusterCoordinatePoints(
      points: widget.points,
      focusedPointId: widget.selectedPointId,
      groupsOverlaps: widget.groupsOverlaps,
      screenPosition: (point) {
        final offset = mapLibreViewportScreenLocation(
          camera: camera,
          viewportSize: details.viewportSize,
          point: _geographic(point),
        );
        return math.Point(offset.dx, offset.dy);
      },
    );
    final cluster = closestMapPoint<MarkerCluster<CoordinateMapPoint>>(
      tapPosition: details.localPosition,
      points: clusters,
      screenPosition: (cluster) => Offset(cluster.center.x, cluster.center.y),
      hitRadius: (cluster) => mapMarkerHitRadius(
        coordinateClusterDiameter(
              cluster,
              selectedPointIds: widget.selectedPointIds,
              focusedPointId: widget.selectedPointId,
            ) /
            2,
      ),
    );
    if (cluster == null || !mounted) {
      _clearTooltip();
      return;
    }
    if (cluster.isSingle) {
      final point = cluster.members.single;
      widget.onPointSelected(point.id);
      setState(() {
        _tooltip = _CoordinateMapTooltip(
          point: _geographic(point),
          title: point.name,
          pointIds: [point.id],
        );
      });
      return;
    }
    if (camera.zoom < _maxZoom - 0.5) {
      _clearTooltip();
      unawaited(_zoomToCluster(cluster.members));
      return;
    }
    final center = coordinateClusterCenter(cluster.members);
    setState(() {
      _tooltip = _CoordinateMapTooltip(
        point: maplibre.Geographic(lon: center.longitude, lat: center.latitude),
        title: coordinateClusterTitle(context, cluster),
        details: coordinateClusterDetails(
          context.l10n,
          cluster,
          canZoomIn: false,
        ),
        pointIds: [for (final point in cluster.members) point.id],
      );
    });
  }

  /// Zooms in on a grouped bubble so its coordinates split apart.
  Future<void> _zoomToCluster(List<CoordinateMapPoint> members) async {
    final controller = _controller;
    if (!_isReady || controller == null) return;
    final zoom = controller.getCamera().zoom;
    final bounds = maplibre.LngLatBounds.fromPoints([
      for (final point in members) _geographic(point),
    ]);
    final isPoint =
        (bounds.longitudeEast - bounds.longitudeWest).abs() < 1e-6 &&
        (bounds.latitudeNorth - bounds.latitudeSouth).abs() < 1e-6;
    // Fitting shared or near-identical coordinates could zoom out, so those
    // step in two levels around their center instead.
    if (isPoint) {
      final center = coordinateClusterCenter(members);
      await controller.animateCamera(
        center: maplibre.Geographic(
          lon: center.longitude,
          lat: center.latitude,
        ),
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

  void _clearTooltip() {
    if (!mounted || _tooltip == null) return;
    setState(() => _tooltip = null);
  }

  Future<void> _initializeMap() async {
    if (!_readiness.claimInitialCamera()) return;
    if (_readiness.takePendingReset()) {
      await _resetCamera();
      return;
    }
    if (widget.points.length > 1) {
      await _fitPointsAfterLayout();
    }
    if (_isReady && widget.selectedPointId != null) {
      await _focusSelected();
    }
  }

  Future<void> _fitPointsAfterLayout() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !_isReady) return;
    await _fitPoints();
  }
}

LatLng _latLng(CoordinateMapPoint point) =>
    LatLng(point.latitude!, point.longitude!);

maplibre.Geographic _geographic(CoordinateMapPoint point) =>
    maplibre.Geographic(lon: point.longitude!, lat: point.latitude!);

const double _maxZoom = 16;

/// What the MapLibre tooltip shows, and which coordinates it describes.
class _CoordinateMapTooltip {
  const _CoordinateMapTooltip({
    required this.point,
    required this.title,
    required this.pointIds,
    this.details = const [],
  });

  final maplibre.Geographic point;
  final String title;
  final List<String> details;
  final List<int> pointIds;
}

/// Coordinate markers inside a `flutter_map` map, drawn with the same visuals
/// as [_MapLibreCoordinateMarkers].
class _FlutterMapCoordinateMarkers extends StatelessWidget {
  const _FlutterMapCoordinateMarkers({
    required this.points,
    required this.selectedPointIds,
    required this.focusedPointId,
    required this.groupsOverlaps,
    required this.onPointSelected,
  });

  final List<CoordinateMapPoint> points;
  final Set<int> selectedPointIds;
  final int? focusedPointId;
  final bool groupsOverlaps;
  final ValueChanged<int> onPointSelected;

  @override
  Widget build(BuildContext context) {
    final camera = flutter_map.MapCamera.of(context);
    final clusters = clusterCoordinatePoints(
      points: points,
      focusedPointId: focusedPointId,
      groupsOverlaps: groupsOverlaps,
      screenPosition: (point) {
        final offset = camera.latLngToScreenOffset(_latLng(point));
        return math.Point(offset.dx, offset.dy);
      },
    );
    final canZoomIn = camera.zoom < (camera.maxZoom ?? _maxZoom) - 0.5;
    return flutter_map.MarkerLayer(
      markers: [
        for (final cluster in coordinateMarkerPaintOrder(
          clusters,
          selectedPointIds: selectedPointIds,
          focusedPointId: focusedPointId,
        ))
          _marker(camera, cluster, canZoomIn: canZoomIn),
      ],
    );
  }

  flutter_map.Marker _marker(
    flutter_map.MapCamera camera,
    MarkerCluster<CoordinateMapPoint> cluster, {
    required bool canZoomIn,
  }) {
    // Small dots still get a finger-sized target.
    final size = math.max(
      coordinateClusterDiameter(
        cluster,
        selectedPointIds: selectedPointIds,
        focusedPointId: focusedPointId,
      ),
      _minimumTapTarget,
    );
    return flutter_map.Marker(
      point: cluster.isSingle
          ? _latLng(cluster.members.single)
          : camera.screenOffsetToLatLng(
              Offset(cluster.center.x, cluster.center.y),
            ),
      width: size,
      height: size,
      child: _FlutterMapCoordinateMarker(
        cluster: cluster,
        selectedPointIds: selectedPointIds,
        focusedPointId: focusedPointId,
        canZoomIn: canZoomIn,
        onPointSelected: onPointSelected,
      ),
    );
  }

  static const _minimumTapTarget = 28.0;
}

/// One dot or grouped bubble of [_FlutterMapCoordinateMarkers], with its tap
/// and tooltip handling.
class _FlutterMapCoordinateMarker extends StatelessWidget {
  const _FlutterMapCoordinateMarker({
    required this.cluster,
    required this.selectedPointIds,
    required this.focusedPointId,
    required this.canZoomIn,
    required this.onPointSelected,
  });

  final MarkerCluster<CoordinateMapPoint> cluster;
  final Set<int> selectedPointIds;
  final int? focusedPointId;
  final bool canZoomIn;
  final ValueChanged<int> onPointSelected;

  @override
  Widget build(BuildContext context) {
    final label = cluster.isSingle
        ? cluster.members.single.name
        : [
            coordinateClusterTitle(context, cluster),
            ...coordinateClusterDetails(
              context.l10n,
              cluster,
              canZoomIn: canZoomIn,
            ),
          ].join('\n');
    final isTappable = cluster.isSingle || canZoomIn;
    return Semantics(
      button: isTappable,
      label: label,
      child: Tooltip(
        message: label,
        triggerMode: TooltipTriggerMode.tap,
        waitDuration: Duration.zero,
        showDuration: const Duration(seconds: 4),
        child: MouseRegion(
          cursor: isTappable
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isTappable ? () => _onTap(context) : null,
            child: Center(
              child: CoordinateMarkerVisual(
                cluster: cluster,
                selectedPointIds: selectedPointIds,
                focusedPointId: focusedPointId,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (cluster.isSingle) {
      onPointSelected(cluster.members.single.id);
      return;
    }
    final controller = flutter_map.MapController.of(context);
    final camera = flutter_map.MapCamera.of(context);
    final maxZoom = camera.maxZoom ?? _maxZoom;
    // Coordinates that share a point would fit at any zoom, so step in at
    // least one level each tap.
    controller.fitCamera(
      flutter_map.CameraFit.coordinates(
        coordinates: [for (final point in cluster.members) _latLng(point)],
        padding: const EdgeInsets.all(64),
        maxZoom: maxZoom,
        minZoom: math.min(camera.zoom + 1, maxZoom),
      ),
    );
  }
}

/// Coordinate markers drawn by Flutter over the MapLibre map, so they match
/// the `flutter_map` markers and can group as the zoom changes.
///
/// Points are projected from the camera and this widget's own size, as
/// [MapTooltipLayer] does, because the controller's cached size can lag.
/// Taps are handled by the map's gesture surface.
class _MapLibreCoordinateMarkers extends StatelessWidget {
  const _MapLibreCoordinateMarkers({
    required this.points,
    required this.selectedPointIds,
    required this.focusedPointId,
    required this.groupsOverlaps,
  });

  final List<CoordinateMapPoint> points;
  final Set<int> selectedPointIds;
  final int? focusedPointId;
  final bool groupsOverlaps;

  @override
  Widget build(BuildContext context) {
    final camera = maplibre.MapCamera.maybeOf(context);
    if (camera == null || points.isEmpty) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = constraints.biggest;
            final clusters = clusterCoordinatePoints(
              points: points,
              focusedPointId: focusedPointId,
              groupsOverlaps: groupsOverlaps,
              screenPosition: (point) {
                final offset = mapLibreViewportScreenLocation(
                  camera: camera,
                  viewportSize: viewport,
                  point: _geographic(point),
                );
                return math.Point(offset.dx, offset.dy);
              },
            );
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (final cluster in coordinateMarkerPaintOrder(
                  clusters,
                  selectedPointIds: selectedPointIds,
                  focusedPointId: focusedPointId,
                ))
                  _centered(cluster),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _centered(MarkerCluster<CoordinateMapPoint> cluster) {
    final diameter = coordinateClusterDiameter(
      cluster,
      selectedPointIds: selectedPointIds,
      focusedPointId: focusedPointId,
    );
    return Positioned(
      left: cluster.center.x - diameter / 2,
      top: cluster.center.y - diameter / 2,
      child: CoordinateMarkerVisual(
        cluster: cluster,
        selectedPointIds: selectedPointIds,
        focusedPointId: focusedPointId,
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Zoom in',
          visualDensity: VisualDensity.compact,
          onPressed: onZoomIn,
          icon: const Icon(Icons.add),
        ),
        IconButton(
          tooltip: 'Zoom out',
          visualDensity: VisualDensity.compact,
          onPressed: onZoomOut,
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          tooltip: context.l10n.mapCenterOnCoordinates,
          visualDensity: VisualDensity.compact,
          onPressed: onReset,
          icon: const Icon(Icons.center_focus_strong_outlined),
        ),
      ],
    ),
  );
}

class _BaseLayerAttribution extends StatelessWidget {
  const _BaseLayerAttribution({required this.label});

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

class _MapMessage extends StatelessWidget {
  const _MapMessage();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerLow.withValues(alpha: 0.82),
    child: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No valid coordinates are available to map.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
