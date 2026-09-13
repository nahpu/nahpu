import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  test('Match specimen icon path', () {
    CatalogFmt catalogFmt = CatalogFmt.mammalogy;
    String part = 'skull';
    String icon = SpecimenPartIcon(catalogFmt: catalogFmt, part: part).match();
    expect(icon, 'assets/icons/mammal_skull.svg');
  });

  test('Match whole-specimen icon path', () {
    CatalogFmt catalogFmt = CatalogFmt.mammalogy;
    String part = 'alcohol';
    String icon = SpecimenPartIcon(catalogFmt: catalogFmt, part: part).match();
    expect(icon, 'assets/icons/mouse_outlined.svg');
  });

  test('Match tissue icon path', () {
    CatalogFmt catalogFmt = CatalogFmt.mammalogy;
    String part = 'pectoral muscle';
    String icon = SpecimenPartIcon(catalogFmt: catalogFmt, part: part).match();
    expect(icon, 'assets/icons/muscles.svg');
  });

  test('Catalog formats display as their discipline', () {
    expect(catalogFmtDisplayName(CatalogFmt.mammalogy), 'Mammalogy');
    expect(catalogFmtDisplayName(CatalogFmt.ornithology), 'Ornithology');
    expect(catalogFmtDisplayName(CatalogFmt.herpetology), 'Herpetology');
    expect(
      catalogFmtDisplayName(CatalogFmt.invertebrateZoology),
      'Invertebrate zoology',
    );
  });

  test('Taxon groups are stored as their taxon, not the discipline', () {
    // The stored value is matched by the custom-field triggers and the Darwin
    // Core bundle writer, so it tracks the taxon rather than the catalog name.
    expect(matchCatFmtToTaxonGroup(CatalogFmt.mammalogy), 'Mammals');
    expect(matchCatFmtToTaxonGroup(CatalogFmt.ornithology), 'Birds');
    expect(matchCatFmtToTaxonGroup(CatalogFmt.herpetology), 'Herpetofauna');
    expect(
      matchCatFmtToTaxonGroup(CatalogFmt.invertebrateZoology),
      'Invertebrates',
    );
    for (final fmt in CatalogFmt.values) {
      expect(
        matchTaxonGroupToCatFmt(matchCatFmtToTaxonGroup(fmt)),
        fmt,
        reason: '\$fmt should round-trip through its taxon group',
      );
    }
  });

  test('The pre-v22 arthropod labels still resolve', () {
    // A catalog-format preference or template saved before v22 still spells
    // the taxon 'Arthropods'.
    expect(
      matchTaxonGroupToCatFmt('Arthropods'),
      CatalogFmt.invertebrateZoology,
    );
    expect(
      matchTaxonGroupToRecordType('Arthropods'),
      SpecimenRecordType.invertebrates,
    );
    expect(canonicalizeTaxonGroup('Arthropods'), 'Invertebrates');
    expect(canonicalizeTaxonGroup('Mammals'), 'Mammals');
  });

  test('Stored catalog-format names resolve across the v22 rename', () {
    expect(
      catalogFmtFromStoredName('arthropods'),
      CatalogFmt.invertebrateZoology,
    );
    expect(catalogFmtFromStoredName('mammals'), CatalogFmt.mammalogy);
    expect(catalogFmtFromStoredName('birds'), CatalogFmt.ornithology);
    expect(catalogFmtFromStoredName('herpetofauna'), CatalogFmt.herpetology);
    for (final fmt in CatalogFmt.values) {
      expect(catalogFmtFromStoredName(fmt.name), fmt);
    }
    expect(catalogFmtFromStoredName(null), isNull);
    expect(catalogFmtFromStoredName('nonsense'), isNull);
  });

  test('Herpetology and invertebrate zoology are marked beta', () {
    const betaFormats = {
      CatalogFmt.herpetology,
      CatalogFmt.invertebrateZoology,
    };
    for (final fmt in CatalogFmt.values) {
      expect(
        isCatalogFmtBeta(fmt),
        betaFormats.contains(fmt),
        reason: '$fmt beta status',
      );
    }
  });

  test('Every catalog format has a display name', () {
    for (final fmt in CatalogFmt.values) {
      expect(catalogFmtDisplayName(fmt), isNotEmpty);
    }
  });
}
