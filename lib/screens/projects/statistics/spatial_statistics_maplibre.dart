import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre/maplibre.dart';
import 'package:nahpu/screens/shared/maps/maplibre_gesture_surface.dart';
import 'package:nahpu/screens/shared/maps/maplibre_camera_readiness.dart';
import 'package:nahpu/screens/shared/maps/maplibre_viewport_projection.dart';
import 'package:nahpu/screens/shared/maps/map_point_hit_test.dart';
import 'package:nahpu/screens/shared/maps/map_tooltip_card.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/statistics/spatial_map_style.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_legend.dart';

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

class _MapLibreMap extends StatefulWidget {
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
  State<_MapLibreMap> createState() => _MapLibreMapState();
}

class _MapLibreMapState extends State<_MapLibreMap> {
  MapController? _controller;
  final _readiness = MapLibreCameraReadiness();
  SpatialStatisticDatum? _tooltipRow;

  bool get _isReady => mounted && _readiness.isReady;

  @override
  void didUpdateWidget(covariant _MapLibreMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tooltipRow != null &&
        !widget.rows.any(
          (row) => row.coordinateId == _tooltipRow!.coordinateId,
        )) {
      _tooltipRow = null;
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.rows.firstOrNull;
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
            options: MapOptions(
              initStyle: widget.style,
              initCenter: Geographic(
                lon: first?.decimalLongitude ?? 0,
                lat: first?.decimalLatitude ?? 18,
              ),
              initZoom: widget.rows.length == 1 ? 12 : 1.5,
              minZoom: 1,
              maxZoom: 16,
              maxPitch: 60,
              gestures: const MapGestures(
                pan: true,
                zoom: true,
                rotate: false,
                pitch: false,
              ),
            ),
            onMapCreated: (controller) {
              if (!mounted) return;
              _controller = controller;
              _readiness.markMapCreated();
              _initializeCamera();
            },
            onStyleLoaded: (_) {
              _readiness.markStyleLoaded();
              _initializeCamera();
            },
            onEvent: _handleEvent,
            children: [
              Positioned.fill(
                child: MapLibreGestureSurface(onTapUp: _handleMapTap),
              ),
              if (_tooltipRow != null)
                MapTooltipLayer(
                  point: Geographic(
                    lon: _tooltipRow!.decimalLongitude!,
                    lat: _tooltipRow!.decimalLatitude!,
                  ),
                  title: _tooltipRow!.displayName,
                  details: [
                    '${_tooltipRow!.count ?? 0} ${widget.kind.countLabel} '
                        '(${spatialStatisticPercent(_tooltipRow!, widget.total).toStringAsFixed(1)}%)',
                  ],
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
          if (widget.rows.isEmpty)
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
              ),
            ),
        ],
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
      zoom: (controller.getCamera().zoom + amount).clamp(1, 16).toDouble(),
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
    final maximumCount = widget.rows.fold<int>(
      0,
      (maximum, row) => math.max(maximum, row.count ?? 0),
    );
    final row = closestMapPoint<SpatialStatisticDatum>(
      tapPosition: details.localPosition,
      points: widget.rows,
      screenPosition: (row) => mapLibreViewportScreenLocation(
        camera: camera,
        viewportSize: details.viewportSize,
        point: Geographic(
          lon: row.decimalLongitude!,
          lat: row.decimalLatitude!,
        ),
      ),
      hitRadius: (row) => mapMarkerHitRadius(
        spatialMarkerRadius(
          kind: widget.kind,
          count: row.count ?? 0,
          maximumCount: maximumCount,
        ),
      ),
    );
    if (row == null || !mounted) {
      _clearTooltip();
      return;
    }
    setState(() {
      _tooltipRow = row;
    });
  }

  void _clearTooltip() {
    if (!mounted || _tooltipRow == null) return;
    setState(() => _tooltipRow = null);
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
