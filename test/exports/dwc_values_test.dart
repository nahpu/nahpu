import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/dwc_values.dart';
import 'package:nahpu/services/projects/orcid.dart';

void main() {
  test('coordinate extent augments positive uncertainty only', () {
    expect(positiveCoordinateUncertainty(10, 2.5), 12.5);
    expect(positiveCoordinateUncertainty(null, 2.5), 2.5);
    expect(positiveCoordinateUncertainty(10, null), 10);
    expect(positiveCoordinateUncertainty(10, 0), 10);
    expect(positiveCoordinateUncertainty(0, 0), isNull);
    expect(positiveCoordinateUncertainty(-1, double.nan), isNull);
  });

  test('ORCID validation supports checksummed digits and X', () {
    expect(isValidOrcid('0000-0002-1825-0097'), isTrue);
    expect(isValidOrcid('0000-0002-1694-233X'), isTrue);
    expect(isValidOrcid('0000-0002-1825-0098'), isFalse);
    expect(isValidOrcid('https://orcid.org/0000-0002-1825-0097'), isFalse);
    expect(
      canonicalOrcidUrl('0000-0002-1825-0097'),
      'https://orcid.org/0000-0002-1825-0097',
    );
  });
}
