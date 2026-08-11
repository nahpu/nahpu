import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/maps/map_point_hit_test.dart';

void main() {
  test('selects the nearest point inside its hit radius', () {
    final selected = closestMapPoint<String>(
      tapPosition: const Offset(101, 100),
      points: const ['far', 'near'],
      screenPosition: (point) =>
          point == 'near' ? const Offset(100, 100) : const Offset(106, 100),
      hitRadius: (_) => 8,
    );

    expect(selected, 'near');
  });

  test('returns no point when the tap misses every hit area', () {
    final selected = closestMapPoint<String>(
      tapPosition: const Offset(50, 50),
      points: const ['point'],
      screenPosition: (_) => const Offset(100, 100),
      hitRadius: (_) => 24,
    );

    expect(selected, isNull);
  });

  test('map marker hit radius preserves a touch-sized target', () {
    expect(mapMarkerHitRadius(7), 24);
    expect(mapMarkerHitRadius(32), 36);
  });
}
