import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/symbionts.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  test('symbiont life stages and association statuses are fixed', () {
    expect(symbiontLifeStages, [
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
    expect(symbiontAssociationStatuses, {1: 'Confirmed', 0: 'Suspected'});
  });

  test('symbionts support only the current compatible catalog formats', () {
    expect(symbiontCatalogFormats, {
      CatalogFmt.mammalogy,
      CatalogFmt.ornithology,
      CatalogFmt.herpetology,
      CatalogFmt.ichthyology,
    });
    expect(supportsSymbionts(CatalogFmt.mammalogy), isTrue);
    expect(supportsSymbionts(CatalogFmt.ornithology), isTrue);
    expect(supportsSymbionts(CatalogFmt.herpetology), isTrue);
    expect(supportsSymbionts(CatalogFmt.ichthyology), isTrue);
    expect(supportsSymbionts(CatalogFmt.invertebrateZoology), isFalse);
  });

  test('anatomical locations narrow to the selected category', () {
    const options = [...defaultSymbiontAnatomicalLocations, 'Wing membrane'];

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

  test('symbiont categories filter the same as their parasite names', () {
    const options = [...defaultSymbiontAnatomicalLocations, 'Wing membrane'];
    for (final (current, legacy) in const [
      ('Ectosymbiont', 'Ectoparasite'),
      ('Endosymbiont', 'Endoparasite'),
      ('Mesosymbiont', 'Mesoparasite'),
    ]) {
      expect(
        filterAnatomicalLocations(options, current),
        filterAnatomicalLocations(options, legacy),
      );
    }
    expect(defaultSymbiontCategories, [
      'Ectosymbiont',
      'Endosymbiont',
      'Mesosymbiont',
    ]);
    expect(defaultSymbiontInteractionTypes, contains('Mutualistic'));
  });

  test('unmapped categories keep every anatomical location', () {
    const options = [...defaultSymbiontAnatomicalLocations, 'Wing membrane'];
    for (final category in [null, '', 'Parasitoid', 'Hyperparasite']) {
      expect(filterAnatomicalLocations(options, category), options);
    }
  });

  test('every default location belongs to a mapped category', () {
    final mapped = symbiontCategoryLocations.values.expand((e) => e).toSet();
    final unmapped = defaultSymbiontAnatomicalLocations.where(
      (location) => !mapped.contains(location.toLowerCase()),
    );
    expect(unmapped, isEmpty);
  });
}
