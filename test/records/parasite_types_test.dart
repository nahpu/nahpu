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
      CatalogFmt.ichthyology,
    });
    expect(supportsParasites(CatalogFmt.mammalogy), isTrue);
    expect(supportsParasites(CatalogFmt.ornithology), isTrue);
    expect(supportsParasites(CatalogFmt.herpetology), isTrue);
    expect(supportsParasites(CatalogFmt.ichthyology), isTrue);
    expect(supportsParasites(CatalogFmt.invertebrateZoology), isFalse);
  });

  test('anatomical locations narrow to the selected category', () {
    const options = [...defaultParasiteAnatomicalLocations, 'Wing membrane'];

    final ecto = filterAnatomicalLocations(options, 'Ectoparasite');
    expect(ecto, containsAll(['Fur', 'Feathers', 'Wing membrane']));
    expect(ecto, isNot(contains('Liver')));

    final endo = filterAnatomicalLocations(options, ' endoparasite ');
    expect(endo, containsAll(['Liver', 'Blood', 'Wing membrane']));
    expect(endo, isNot(contains('Fur')));

    final meso = filterAnatomicalLocations(options, 'Mesoparasite');
    expect(meso, containsAll(['Nasal cavity', 'Gill', 'Wing membrane']));
    expect(meso, isNot(contains('Tail')));
  });

  test('unmapped categories keep every anatomical location', () {
    const options = [...defaultParasiteAnatomicalLocations, 'Wing membrane'];
    for (final category in [null, '', 'Parasitoid', 'Hyperparasite']) {
      expect(filterAnatomicalLocations(options, category), options);
    }
  });

  test('every default location belongs to a mapped category', () {
    final mapped = parasiteCategoryLocations.values.expand((e) => e).toSet();
    final unmapped = defaultParasiteAnatomicalLocations.where(
      (location) => !mapped.contains(location.toLowerCase()),
    );
    expect(unmapped, isEmpty);
  });
}
