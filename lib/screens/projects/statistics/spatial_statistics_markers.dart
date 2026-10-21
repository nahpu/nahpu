import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_marker_visuals.dart';
import 'package:nahpu/services/statistics/spatial_marker_clusters.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

/// Spatial statistic circles that group into one bubble where they overlap.
///
/// Grouping follows the camera, so bubbles split apart as the map zooms in.
/// Must sit inside a [FlutterMap].
class SpatialStatisticsMarkerLayer extends StatelessWidget {
  const SpatialStatisticsMarkerLayer({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
    required this.maximumCount,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final int maximumCount;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final clusters = clusterSpatialStatistics(
      rows: rows,
      maximumCount: maximumCount,
      screenPosition: (row) {
        final offset = camera.latLngToScreenOffset(_latLng(row));
        return math.Point(offset.dx, offset.dy);
      },
    );
    // Larger circles first so smaller ones stay visible on top; bubbles last.
    final singles = clusters.where((cluster) => cluster.isSingle).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final groups = clusters.where((cluster) => !cluster.isSingle);
    final canZoomIn = camera.zoom < (camera.maxZoom ?? 16) - 0.5;
    return MarkerLayer(
      markers: [
        for (final cluster in singles) _pointMarker(cluster.members.single),
        for (final cluster in groups)
          _clusterMarker(camera, cluster, canZoomIn: canZoomIn),
      ],
    );
  }

  Marker _pointMarker(SpatialStatisticDatum row) {
    final diameter =
        spatialMarkerRadius(
              kind: kind,
              count: row.count ?? 0,
              maximumCount: maximumCount,
            ) *
            2 +
        3;
    return Marker(
      point: _latLng(row),
      width: diameter,
      height: diameter,
      child: _SpatialPointMarker(
        label: spatialRowLabel(kind, row, total),
        countLabel: kind.hasCounts ? '${row.count ?? 0}' : null,
        diameter: diameter,
      ),
    );
  }

  Marker _clusterMarker(
    MapCamera camera,
    MarkerCluster<SpatialStatisticDatum> cluster, {
    required bool canZoomIn,
  }) {
    final diameter =
        spatialClusterDisplayRadius(
              count: cluster.count,
              maximumCount: maximumCount,
            ) *
            2 +
        3;
    final members = cluster.members;
    final tooltip = [
      spatialClusterTitle(kind, members, cluster.count),
      ...spatialClusterDetails(members, canZoomIn: canZoomIn),
    ].join('\n');
    return Marker(
      point: camera.screenOffsetToLatLng(
        Offset(cluster.center.x, cluster.center.y),
      ),
      width: diameter,
      height: diameter,
      child: _SpatialClusterMarker(
        diameter: diameter,
        tooltip: tooltip,
        countLabel: '${cluster.count}',
        coordinateCount: members.length,
        coordinates: [for (final row in members) _latLng(row)],
        canZoomIn: canZoomIn,
      ),
    );
  }

  LatLng _latLng(SpatialStatisticDatum row) =>
      LatLng(row.decimalLatitude!, row.decimalLongitude!);
}

class _SpatialPointMarker extends StatelessWidget {
  const _SpatialPointMarker({
    required this.label,
    required this.countLabel,
    required this.diameter,
  });

  final String label;
  final String? countLabel;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        triggerMode: TooltipTriggerMode.tap,
        waitDuration: Duration.zero,
        showDuration: const Duration(seconds: 4),
        child: SpatialPointCircle(diameter: diameter, countLabel: countLabel),
      ),
    );
  }
}

class _SpatialClusterMarker extends StatelessWidget {
  const _SpatialClusterMarker({
    required this.diameter,
    required this.tooltip,
    required this.countLabel,
    required this.coordinateCount,
    required this.coordinates,
    required this.canZoomIn,
  });

  final double diameter;
  final String tooltip;
  final String countLabel;
  final int coordinateCount;
  final List<LatLng> coordinates;
  final bool canZoomIn;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: canZoomIn,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        waitDuration: Duration.zero,
        showDuration: const Duration(seconds: 4),
        child: MouseRegion(
          cursor: canZoomIn
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: canZoomIn ? () => _zoomIn(context) : null,
            child: SpatialClusterBubble(
              diameter: diameter,
              countLabel: countLabel,
              coordinateCount: coordinateCount,
            ),
          ),
        ),
      ),
    );
  }

  void _zoomIn(BuildContext context) {
    final controller = MapController.of(context);
    final camera = MapCamera.of(context);
    final maxZoom = camera.maxZoom ?? 16;
    // Coordinates that share a point would fit at any zoom, so step in at
    // least one level each tap.
    controller.fitCamera(
      CameraFit.coordinates(
        coordinates: coordinates,
        padding: const EdgeInsets.all(64),
        maxZoom: maxZoom,
        minZoom: math.min(camera.zoom + 1, maxZoom),
      ),
    );
  }
}
