import 'dart:math' as math;

import 'package:nahpu/services/statistics/spatial_marker_clusters.dart';

class CoordinateMapPoint {
  const CoordinateMapPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final double? latitude;
  final double? longitude;

  bool get isMappable =>
      latitude != null &&
      longitude != null &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180;
}

/// Drawn radius of one coordinate marker.
double coordinateMarkerRadius({required bool selected, required bool focused}) {
  if (focused) return 11;
  return selected ? 8 : 7;
}

/// Drawn radius of a bubble grouping [count] coordinates. It grows slowly so
/// large groups stay compact.
double coordinateClusterRadius(int count) {
  if (count <= 1) return coordinateMarkerRadius(selected: true, focused: false);
  return (12 + 2 * math.log(count) / math.ln2).clamp(14, 24).toDouble();
}

/// Geographic center of [points], which must all be mappable.
({double latitude, double longitude}) coordinateClusterCenter(
  List<CoordinateMapPoint> points,
) {
  var latitude = 0.0;
  var longitude = 0.0;
  for (final point in points) {
    latitude += point.latitude!;
    longitude += point.longitude!;
  }
  return (
    latitude: latitude / points.length,
    longitude: longitude / points.length,
  );
}

/// Groups coordinates whose markers overlap at [screenPosition].
///
/// The focused coordinate is never grouped, so the one being worked on stays
/// visible and tappable at any zoom. With [groupsOverlaps] off, every
/// coordinate stays its own marker.
List<MarkerCluster<CoordinateMapPoint>> clusterCoordinatePoints({
  required List<CoordinateMapPoint> points,
  required int? focusedPointId,
  required math.Point<double> Function(CoordinateMapPoint point) screenPosition,
  bool groupsOverlaps = true,
}) {
  if (!groupsOverlaps) {
    return [
      for (final point in points)
        MarkerCluster(
          members: [point],
          count: 1,
          center: screenPosition(point),
        ),
    ];
  }
  final focused = points.where((point) => point.id == focusedPointId);
  final clusters = clusterOverlappingMarkers<CoordinateMapPoint>(
    items: [
      for (final point in points)
        if (point.id != focusedPointId) point,
    ],
    position: screenPosition,
    count: (_) => 1,
    radius: coordinateClusterRadius,
  );
  return [
    ...clusters,
    for (final point in focused)
      MarkerCluster(members: [point], count: 1, center: screenPosition(point)),
  ];
}
