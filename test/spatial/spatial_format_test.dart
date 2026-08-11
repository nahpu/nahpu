import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/statistics/spatial.dart';

void main() {
  test('coordinate formatting removes insignificant trailing zeros', () {
    expect(formatCoordinate(123, decimals: 2), '123');
    expect(formatCoordinate(123.4, decimals: 2), '123.4');
    expect(formatCoordinate(0, decimals: 3), '0');
    expect(formatCoordinate(-12.5, decimals: 3), '-12.5');
    expect(formatCoordinate(null, decimals: 2), '—');
  });
}
