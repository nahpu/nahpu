import 'dart:math' as math;

import 'package:nahpu/services/types/spatial_statistics.dart';

/// Markers drawn as one bubble because their circles overlap on screen.
class MarkerCluster<T> {
  const MarkerCluster({
    required this.members,
    required this.count,
    required this.center,
  });

  /// Members, largest count first.
  final List<T> members;

  /// Sum of the member counts.
  final int count;

  /// Count-weighted center of the members, in screen coordinates.
  final math.Point<double> center;

  bool get isSingle => members.length == 1;
}

/// Groups markers whose circles overlap at the current zoom.
///
/// Each item is placed at [position] with a circle of `radius(count)`. Items
/// are taken largest count first and join the first group they overlap; groups
/// that grow into each other merge until no two groups overlap.
List<MarkerCluster<T>> clusterOverlappingMarkers<T>({
  required List<T> items,
  required math.Point<double> Function(T item) position,
  required int Function(T item) count,
  required double Function(int count) radius,
}) {
  final sorted = [...items]..sort((a, b) => count(b).compareTo(count(a)));
  final groups = <_Group<T>>[];
  for (final item in sorted) {
    final single = _Group<T>([item], count(item), position(item));
    final match = groups.where((group) => group.overlaps(single, radius));
    if (match.isEmpty) {
      groups.add(single);
    } else {
      match.first.absorb(single);
    }
  }
  var merged = true;
  while (merged) {
    merged = false;
    for (var i = 0; i < groups.length && !merged; i++) {
      for (var j = i + 1; j < groups.length; j++) {
        if (groups[i].overlaps(groups[j], radius)) {
          groups[i].absorb(groups.removeAt(j));
          merged = true;
          break;
        }
      }
    }
  }
  return [
    for (final group in groups)
      MarkerCluster(
        members: List.unmodifiable(
          group.members..sort((a, b) => count(b).compareTo(count(a))),
        ),
        count: group.count,
        center: group.center,
      ),
  ];
}

/// Groups spatial statistic rows whose circles overlap at [screenPosition].
List<MarkerCluster<SpatialStatisticDatum>> clusterSpatialStatistics({
  required List<SpatialStatisticDatum> rows,
  required int maximumCount,
  required math.Point<double> Function(SpatialStatisticDatum row)
  screenPosition,
}) => clusterOverlappingMarkers<SpatialStatisticDatum>(
  items: rows,
  position: screenPosition,
  count: (row) => row.count ?? 0,
  radius: (count) =>
      spatialClusterRadius(count: count, maximumCount: maximumCount),
);

/// Count-weighted geographic center of [rows], which must all be mappable.
({double latitude, double longitude}) spatialClusterCenter(
  List<SpatialStatisticDatum> rows,
) {
  var weight = 0;
  var latitude = 0.0;
  var longitude = 0.0;
  for (final row in rows) {
    final rowWeight = math.max(row.count ?? 0, 1);
    weight += rowWeight;
    latitude += row.decimalLatitude! * rowWeight;
    longitude += row.decimalLongitude! * rowWeight;
  }
  return (latitude: latitude / weight, longitude: longitude / weight);
}

class _Group<T> {
  _Group(this.members, this.count, this.center);

  final List<T> members;
  int count;
  math.Point<double> center;

  // Zero counts still pull the center, so empty coordinates are not ignored.
  int get _weight => math.max(count, members.length);

  bool overlaps(_Group<T> other, double Function(int count) radius) =>
      center.distanceTo(other.center) < radius(count) + radius(other.count);

  void absorb(_Group<T> other) {
    final weight = _weight;
    final otherWeight = other._weight;
    final totalWeight = weight + otherWeight;
    center = math.Point(
      (center.x * weight + other.center.x * otherWeight) / totalWeight,
      (center.y * weight + other.center.y * otherWeight) / totalWeight,
    );
    members.addAll(other.members);
    count += other.count;
  }
}
