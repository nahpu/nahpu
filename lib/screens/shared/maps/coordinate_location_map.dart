import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre/maplibre.dart' as maplibre;
import 'package:nahpu/screens/shared/maps/maplibre_gesture_surface.dart';
import 'package:nahpu/services/maps/coordinate_map_point.dart';
import 'package:nahpu/services/maps/natural_earth.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/statistics/spatial_map_style.dart';
import 'package:nahpu/services/types/map_layers.dart';

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
  });

  final List<CoordinateMapPoint> points;
  final Set<int>? selectedPointIds;
  final int? selectedPointId;
  final int focusRequest;
  final ValueChanged<int> onPointSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappable = points.where((point) => point.isMappable).toList();
    final selectedIds =
        selectedPointIds ?? {for (final point in mappable) point.id};
    if (Platform.isLinux) {
      return FutureBuilder<List<NaturalEarthPolygon>>(
        future: _naturalEarthPolygons,
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
          );
        },
      );
    }
    final basemap =
        ref.watch(spatialBasemapStyleProvider).value ??
        SpatialBasemapStyle.automatic;
    return _MapLibreCoordinateMap(
      points: mappable,
      selectedPointIds: selectedIds,
      selectedPointId: selectedPointId,
      focusRequest: focusRequest,
      onPointSelected: onPointSelected,
      basemap: basemap,
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
  });

  final List<CoordinateMapPoint> points;
  final List<NaturalEarthPolygon> polygons;
  final Set<int> selectedPointIds;
  final int? selectedPointId;
  final int focusRequest;
  final ValueChanged<int> onPointSelected;

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
              backgroundColor: colorScheme.surfaceContainerLowest,
              onMapReady: _onMapReady,
            ),
            children: [
              flutter_map.PolygonLayer(
                polygons: [
                  for (final polygon in widget.polygons)
                    flutter_map.Polygon(
                      points: polygon.points,
                      holePointsList: polygon.holes,
                      color: colorScheme.surfaceContainerHighest,
                      borderColor: colorScheme.outlineVariant,
                      borderStrokeWidth: 0.6,
                    ),
                ],
              ),
              flutter_map.MarkerLayer(
                markers: [
                  for (final point in widget.points)
                    flutter_map.Marker(
                      point: _latLng(point),
                      width: 34,
                      height: 34,
                      child: _MapMarker(
                        selected: widget.selectedPointIds.contains(point.id),
                        focused: point.id == widget.selectedPointId,
                        label: point.name,
                        onTap: () => widget.onPointSelected(point.id),
                      ),
                    ),
                ],
              ),
              flutter_map.Scalebar(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(12),
                textStyle: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                ),
                lineColor: colorScheme.onSurface,
              ),
            ],
          ),
          Positioned(
            left: 8,
            top: 8,
            child: _MapControls(
              onZoomIn: () => _changeZoom(1),
              onZoomOut: () => _changeZoom(-1),
              onReset: _resetCamera,
            ),
          ),
          const Positioned(
            left: 8,
            bottom: 8,
            child: _NaturalEarthAttribution(),
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

class _MapLibreCoordinateMap extends StatefulWidget {
  const _MapLibreCoordinateMap({
    required this.points,
    required this.selectedPointIds,
    required this.selectedPointId,
    required this.focusRequest,
    required this.onPointSelected,
    required this.basemap,
  });

  final List<CoordinateMapPoint> points;
  final Set<int> selectedPointIds;
  final int? selectedPointId;
  final int focusRequest;
  final ValueChanged<int> onPointSelected;
  final SpatialBasemapStyle basemap;

  @override
  State<_MapLibreCoordinateMap> createState() => _MapLibreCoordinateMapState();
}

class _MapLibreCoordinateMapState extends State<_MapLibreCoordinateMap> {
  maplibre.MapController? _controller;
  bool _mapCreated = false;
  bool _styleReady = false;
  bool _resetPending = false;

  bool get _isReady => mounted && _mapCreated && _styleReady;

  @override
  void didUpdateWidget(covariant _MapLibreCoordinateMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isReady) {
      unawaited(
        _updateCoordinates(
          focus:
              widget.selectedPointId != oldWidget.selectedPointId ||
              widget.focusRequest != oldWidget.focusRequest,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapCreated = false;
    _styleReady = false;
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = SpatialMapStyleService.buildCoordinatePoints(
      style: widget.basemap,
      isDark: isDark,
      colorScheme: colorScheme,
    );
    return FutureBuilder<String>(
      future: style,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _MapMessage();
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final first = widget.points.firstOrNull;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              maplibre.MapLibreMap(
                gestureRecognizers: {...mapLibreGestureRecognizers()},
                options: maplibre.MapOptions(
                  initStyle: snapshot.data!,
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
                ),
                onMapCreated: (controller) {
                  if (!mounted) return;
                  _controller = controller;
                  _mapCreated = true;
                },
                onStyleLoaded: (_) => _onStyleLoaded(),
                onEvent: _handleEvent,
                children: [
                  const Positioned.fill(child: MapLibreGestureSurface()),
                  const Positioned(
                    left: 8,
                    bottom: 8,
                    child: _OnlineAttribution(),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
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
      },
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

  Future<void> _updateCoordinates({required bool focus}) async {
    final style = _controller?.style;
    if (!_isReady || style == null) return;
    await style.updateGeoJsonSource(
      id: SpatialMapStyleService.coordinateSourceId,
      data: SpatialMapStyleService.coordinateFeatureCollection(
        points: widget.points,
        selectedPointIds: widget.selectedPointIds,
        focusedPointId: widget.selectedPointId,
      ),
    );
    if (focus && _isReady) await _focusSelected();
  }

  Future<void> _changeZoom(double amount) async {
    final controller = _controller;
    if (!_isReady || controller == null) return;
    await controller.animateCamera(
      zoom: (controller.getCamera().zoom + amount).clamp(1, 16).toDouble(),
      nativeDuration: const Duration(milliseconds: 200),
    );
  }

  Future<void> _resetCamera() async {
    if (!_isReady) {
      _resetPending = true;
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
    if (!_isReady || event is! maplibre.MapEventClick) return;
    final feature = _controller
        ?.featuresAtPoint(
          event.screenPoint,
          layerIds: const [SpatialMapStyleService.coordinateLayerId],
        )
        .firstOrNull;
    final coordinateId = feature?.properties['coordinateId'];
    if (coordinateId is num) widget.onPointSelected(coordinateId.toInt());
  }

  Future<void> _onStyleLoaded() async {
    if (!mounted || !_mapCreated) return;
    _styleReady = true;
    await _updateCoordinates(focus: false);
    if (_resetPending) {
      _resetPending = false;
      await _resetCamera();
      return;
    }
    if (widget.points.length > 1) {
      await _fitPoints();
    }
    if (_isReady && widget.selectedPointId != null) {
      await _focusSelected();
    }
  }
}

LatLng _latLng(CoordinateMapPoint point) =>
    LatLng(point.latitude!, point.longitude!);

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
          tooltip: 'Center map on coordinates',
          visualDensity: VisualDensity.compact,
          onPressed: onReset,
          icon: const Icon(Icons.center_focus_strong_outlined),
        ),
      ],
    ),
  );
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.selected,
    required this.focused,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final bool focused;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          Icons.location_on,
          size: focused
              ? 34
              : selected
              ? 28
              : 26,
          color: focused
              ? _focusedMarkerColor(Theme.of(context).colorScheme)
              : selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

Color _focusedMarkerColor(ColorScheme colorScheme) =>
    colorScheme.brightness == Brightness.dark
    ? const Color(0xFF90CAF9)
    : const Color(0xFF1565C0);

class _NaturalEarthAttribution extends StatelessWidget {
  const _NaturalEarthAttribution();

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(4),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text('Natural Earth', style: TextStyle(fontSize: 10)),
    ),
  );
}

class _OnlineAttribution extends StatelessWidget {
  const _OnlineAttribution();

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(4),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text(
        '© OpenStreetMap contributors · OpenFreeMap',
        style: TextStyle(fontSize: 10),
      ),
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
