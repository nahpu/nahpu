import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  test('Match specimen icon path', () {
    CatalogFmt catalogFmt = CatalogFmt.mammals;
    String part = 'skull';
    String icon = SpecimenPartIcon(catalogFmt: catalogFmt, part: part).match();
    expect(icon, 'assets/icons/mammal_skull.svg');
  });

  test('Match whole-specimen icon path', () {
    CatalogFmt catalogFmt = CatalogFmt.mammals;
    String part = 'alcohol';
    String icon = SpecimenPartIcon(catalogFmt: catalogFmt, part: part).match();
    expect(icon, 'assets/icons/mouse_outlined.svg');
  });

  test('Match tissue icon path', () {
    CatalogFmt catalogFmt = CatalogFmt.mammals;
    String part = 'pectoral muscle';
    String icon = SpecimenPartIcon(catalogFmt: catalogFmt, part: part).match();
    expect(icon, 'assets/icons/muscles.svg');
  });

  test('Arthropod catalog displays as invertebrates', () {
    expect(catalogFmtDisplayName(CatalogFmt.arthropods), 'Invertebrates');
  });

  test('Display names leave the persisted taxon group untouched', () {
    // The stored value is matched by the custom-field triggers and the Darwin
    // Core bundle writer, so renaming a format for readers must not change it.
    expect(matchCatFmtToTaxonGroup(CatalogFmt.arthropods), 'Arthropods');
    expect(
      matchTaxonGroupToCatFmt(matchCatFmtToTaxonGroup(CatalogFmt.arthropods)),
      CatalogFmt.arthropods,
    );
  });

  test('Only the arthropod catalog is marked beta', () {
    expect(isCatalogFmtBeta(CatalogFmt.arthropods), isTrue);
    for (final fmt in CatalogFmt.values.where(
      (fmt) => fmt != CatalogFmt.arthropods,
    )) {
      expect(isCatalogFmtBeta(fmt), isFalse, reason: '$fmt should not be beta');
    }
  });

  test('Every catalog format has a display name', () {
    for (final fmt in CatalogFmt.values) {
      expect(catalogFmtDisplayName(fmt), isNotEmpty);
    }
  });
}
