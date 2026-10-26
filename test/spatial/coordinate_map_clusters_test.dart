import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/sites/coordinate_map_point.dart';

void main() {
  const near = [
    CoordinateMapPoint(id: 1, name: 'A', latitude: 0, longitude: 0),
    CoordinateMapPoint(id: 2, name: 'B', latitude: 0, longitude: 1),
    CoordinateMapPoint(id: 3, name: 'C', latitude: 0, longitude: 2),
  ];
  const far = CoordinateMapPoint(id: 4, name: 'D', latitude: 0, longitude: 50);

  // One screen pixel per degree of longitude, so A, B and C overlap.
  math.Point<double> position(CoordinateMapPoint point) =>
      math.Point(point.longitude!, point.latitude!);

  Set<Set<int>> groups(List<CoordinateMapPoint> points, {int? focused}) => {
    for (final cluster in clusterCoordinatePoints(
      points: points,
      focusedPointId: focused,
      screenPosition: position,
    ))
      {for (final point in cluster.members) point.id},
  };

  test('overlapping coordinates group into one bubble', () {
    expect(groups([...near, far]), {
      {1, 2, 3},
      {4},
    });
  });

  test('the focused coordinate is never grouped', () {
    expect(groups([...near, far], focused: 2), {
      {1, 3},
      {2},
      {4},
    });
  });

  test('grouping can be turned off', () {
    final clusters = clusterCoordinatePoints(
      points: [...near, far],
      focusedPointId: null,
      screenPosition: position,
      groupsOverlaps: false,
    );
    expect(clusters.every((cluster) => cluster.isSingle), isTrue);
    expect(clusters, hasLength(4));
  });

  test('cluster center averages its members', () {
    final center = coordinateClusterCenter(near);
    expect(center.latitude, 0);
    expect(center.longitude, 1);
  });
}
