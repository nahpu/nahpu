import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';

void main() {
  const myotis = TaxonomyData(
    id: 1,
    taxonRank: 'species',
    kingdom: 'Animalia',
    phylum: 'Chordata',
    taxonClass: 'Mammalia',
    taxonOrder: 'Chiroptera',
    taxonFamily: 'Vespertilionidae',
    genus: 'Myotis',
    specificEpithet: 'lucifugus',
    authors: 'Le Conte',
    commonName: 'Little brown bat',
    citesStatus: 'Non-CITES',
    redListCategory: 'Least Concern',
    countryStatus: 'Protected',
    sortingOrder: 7,
    notes: 'Nocturnal insectivore',
  );
  const rattus = TaxonomyData(
    id: 2,
    taxonRank: 'species',
    taxonClass: 'Mammalia',
    taxonOrder: 'Rodentia',
    taxonFamily: 'Muridae',
    genus: 'Rattus',
    specificEpithet: 'rattus',
  );

  final service = TaxonFilterServices();

  test('all fields searches every visible taxonomy field', () {
    expect(service.filterTaxonList([myotis], 'protected'), [myotis]);
    expect(service.filterTaxonList([myotis], 'nocturnal'), [myotis]);
    expect(service.filterTaxonList([myotis], '7'), [myotis]);
  });

  test('category search only matches the selected field', () {
    final taxa = [myotis, rattus];

    expect(
      service.filterTaxonList(
        taxa,
        'mammalia',
        category: TaxonSearchCategory.taxonClass,
      ),
      taxa,
    );
    expect(
      service.filterTaxonList(
        taxa,
        'mammalia',
        category: TaxonSearchCategory.family,
      ),
      isEmpty,
    );
    expect(
      service.filterTaxonList(
        taxa,
        'myotis lucifugus',
        category: TaxonSearchCategory.species,
      ),
      [myotis],
    );
    expect(
      service.filterTaxonList(
        taxa,
        'LITTLE BROWN',
        category: TaxonSearchCategory.commonName,
      ),
      [myotis],
    );
  });

  test('empty search returns the original list', () {
    final taxa = [myotis, rattus];
    expect(
      service.filterTaxonList(taxa, '  ', category: TaxonSearchCategory.notes),
      same(taxa),
    );
  });
}
