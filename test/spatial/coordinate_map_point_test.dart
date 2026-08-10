import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/sites/coordinate_map_point.dart';

void main() {
  test('coordinate map points accept valid WGS84 positions', () {
    const point = CoordinateMapPoint(
      id: 1,
      name: 'Camp',
      latitude: 45,
      longitude: -93,
    );

    expect(point.isMappable, isTrue);
  });

  test('coordinate map points reject missing and out-of-range positions', () {
    const missing = CoordinateMapPoint(
      id: 1,
      name: 'Missing',
      latitude: null,
      longitude: 1,
    );
    const latitudeOutOfRange = CoordinateMapPoint(
      id: 2,
      name: 'Invalid latitude',
      latitude: 91,
      longitude: 1,
    );
    const longitudeOutOfRange = CoordinateMapPoint(
      id: 3,
      name: 'Invalid longitude',
      latitude: 1,
      longitude: 181,
    );

    expect(missing.isMappable, isFalse);
    expect(latitudeOutOfRange.isMappable, isFalse);
    expect(longitudeOutOfRange.isMappable, isFalse);
  });
}
