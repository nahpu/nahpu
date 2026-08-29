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
      CatalogFmt.mammals,
      CatalogFmt.birds,
      CatalogFmt.herpetofauna,
    });
    expect(supportsParasites(CatalogFmt.mammals), isTrue);
    expect(supportsParasites(CatalogFmt.birds), isTrue);
    expect(supportsParasites(CatalogFmt.herpetofauna), isTrue);
    expect(supportsParasites(CatalogFmt.arthropods), isFalse);
  });
}
