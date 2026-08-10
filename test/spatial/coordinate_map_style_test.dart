import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/sites/coordinate_map_point.dart';
import 'package:nahpu/services/statistics/spatial_map_style.dart';

void main() {
  test('coordinate feature collection separates selection and focus', () {
    const points = [
      CoordinateMapPoint(id: 1, name: 'Selected', latitude: 45, longitude: -93),
      CoordinateMapPoint(id: 2, name: 'Focused', latitude: 46, longitude: -94),
      CoordinateMapPoint(
        id: 3,
        name: 'Unselected',
        latitude: 47,
        longitude: -95,
      ),
      CoordinateMapPoint(id: 4, name: 'Invalid', latitude: 91, longitude: -96),
    ];

    final collection =
        jsonDecode(
              SpatialMapStyleService.coordinateFeatureCollection(
                points: points,
                selectedPointIds: const {1, 2},
                focusedPointId: 2,
              ),
            )
            as Map<String, dynamic>;
    final features = collection['features'] as List<dynamic>;

    expect(features, hasLength(3));
    expect(_properties(features, 1), {
      'coordinateId': 1,
      'name': 'Selected',
      'selected': true,
      'focused': false,
    });
    expect(_properties(features, 2), {
      'coordinateId': 2,
      'name': 'Focused',
      'selected': true,
      'focused': true,
    });
    expect(_properties(features, 3), {
      'coordinateId': 3,
      'name': 'Unselected',
      'selected': false,
      'focused': false,
    });
  });
}

Map<String, dynamic> _properties(List<dynamic> features, int coordinateId) {
  final feature = features.cast<Map<String, dynamic>>().singleWhere(
    (feature) => feature['id'] == coordinateId,
  );
  return Map<String, dynamic>.from(feature['properties'] as Map);
}
