import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/canvas/line_hit_test_region.dart';

void main() {
  group('pointToLineSegmentDistance', () {
    test('uses the perpendicular distance within the line endpoints', () {
      expect(
        pointToLineSegmentDistance(
          const Offset(50, 6),
          const Offset(0, 0),
          const Offset(100, 0),
        ),
        6,
      );
    });

    test('uses the nearest endpoint beyond the segment', () {
      expect(
        pointToLineSegmentDistance(
          const Offset(110, 8),
          const Offset(0, 0),
          const Offset(100, 0),
        ),
        closeTo(12.806, 0.001),
      );
    });
  });
}
