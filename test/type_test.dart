import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  test('Match specimen icon path', () {
    CatalogFmt catalogFmt = CatalogFmt.mammals;
    String part = 'skull';
    String icon = SpecimenPartIcon(catalogFmt: catalogFmt, part: part).match();
    expect(icon, 'assets/icons/mouse.svg');
  });

  test('Match tissue icon path', () {
    CatalogFmt catalogFmt = CatalogFmt.mammals;
    String part = 'pectoral muscle';
    String icon = SpecimenPartIcon(catalogFmt: catalogFmt, part: part).match();
    expect(icon, 'assets/icons/muscles.svg');
  });
}
