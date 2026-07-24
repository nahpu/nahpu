import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/measurement_outlier_services.dart';

void main() {
  test('IQR range excludes high outlier from displayed range', () {
    final range = IqrOutlierRange.fromValues(
      [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 100],
    );

    expect(range, isNotNull);
    expect(range!.inlierMin, 10);
    expect(range.inlierMax, 19);
    expect(range.inlierCount, 10);
  });

  test('IQR range keeps non-outlier values in displayed range', () {
    final range = IqrOutlierRange.fromValues(
      [202, 210, 225, 240, 250, 260, 276],
    );

    expect(range, isNotNull);
    expect(range!.contains(240), isTrue);
    expect(range.contains(500), isFalse);
  });
}
