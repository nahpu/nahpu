import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  test('parasite life stages and association statuses are fixed', () {
    expect(parasiteLifeStages, [
      'Egg',
      'Larva',
      'Nymph',
      'Pupa',
      'Juvenile',
      'Adult',
      'Cyst',
      'Oocyst',
      'Trophozoite',
      'Sporozoite',
      'Merozoite',
      'Gametocyte',
    ]);
    expect(parasiteAssociationStatuses, {1: 'Confirmed', 0: 'Suspected'});
  });

  test('parasites support only the current compatible catalog formats', () {
    expect(parasiteCatalogFormats, {
      CatalogFmt.mammalogy,
      CatalogFmt.ornithology,
      CatalogFmt.herpetology,
    });
    expect(supportsParasites(CatalogFmt.mammalogy), isTrue);
    expect(supportsParasites(CatalogFmt.ornithology), isTrue);
    expect(supportsParasites(CatalogFmt.herpetology), isTrue);
    expect(supportsParasites(CatalogFmt.invertebrateZoology), isFalse);
    expect(supportsParasites(CatalogFmt.marineInvertebrates), isFalse);
  });
}
