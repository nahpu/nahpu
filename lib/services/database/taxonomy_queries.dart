import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'taxonomy_queries.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class TaxonomyQuery extends DatabaseAccessor<Database>
    with _$TaxonomyQueryMixin {
  TaxonomyQuery(super.db);

  Future<TaxonomyData> getTaxonById(int id) {
    return (select(taxonomy)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<String> getSpeciesById(int id) {
    return (select(taxonomy)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .map((t) => '${t.genus} ${t.specificEpithet}')
        .getSingle();
  }

  Future<List<TaxonomyData>> searchTaxon(String query) async {
    if (query.isEmpty) {
      return [];
    }
    if (query.split(' ').length == 2) {
      // Search by genus and species
      List<String> taxon = query.split(' ');
      return await (select(taxonomy)
            ..where((t) => t.genus.like('%${taxon[0]}%'))
            ..where((t) => t.specificEpithet.like('%${taxon[1]}%')))
          .get();
    }
    return await (select(taxonomy)
          ..where((t) =>
              t.taxonOrder.like('%$query%') |
              t.taxonFamily.like('%$query%') |
              t.genus.like('%$query%') |
              t.specificEpithet.like('%$query%') |
              t.commonName.like('%$query%')))
        .get();
  }

  Future<TaxonomyData?> getTaxonIdByGenusEpithet(String genus, String epithet) {
    return (select(taxonomy)
          ..where((t) => t.genus.equals(genus))
          ..where((t) => t.specificEpithet.equals(epithet)))
        .getSingleOrNull();
  }

  Future<List<TaxonomyData>> getTaxonList() async {
    // Get all taxon order by genus and species
    return (select(taxonomy)
          ..orderBy([
            (t) => OrderingTerm(expression: t.genus),
            (t) => OrderingTerm(expression: t.specificEpithet),
          ]))
        .get();
  }

  Future<List<int>> getAllUniqueTaxonFromSpecimen() async {
    List<int?> specimenTaxonIds =
        await select(specimen).map((s) => s.speciesID).get();
    return specimenTaxonIds
        .toSet()
        .toList()
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
  }

  // this isn't used
  Future<List<TaxonomyData>> getTaxaWithSpecimenData(String projectUuid) async {
    final query = select(specimen)
      ..where((t) => t.projectUuid.equals(projectUuid))
      ..where((t) => t.speciesID.isNotNull());
    final specimenList = await query.get();
    final speciesCount = <int, int>{};
    for (final s in specimenList) {
      speciesCount[s.speciesID!] = (speciesCount[s.speciesID!] ?? 0) + 1;
    }

    final speciesWithEnoughSpecimens = <int>[];
    speciesCount.forEach((speciesId, count) {
      if (count >= 3) {
        // Using 3 as the minimum
        speciesWithEnoughSpecimens.add(speciesId);
      }
    });

    if (speciesWithEnoughSpecimens.isEmpty) {
      return [];
    }

    final taxonQuery = select(taxonomy)
      ..where((t) => t.id.isIn(speciesWithEnoughSpecimens));
    return await taxonQuery.get();
  }

  Future<List<TaxonomyData>> getAllTaxaWithSpecimenData(String projectUuid) async {
    final query = select(specimen)
      ..where((t) => t.projectUuid.equals(projectUuid))
      ..where((t) => t.speciesID.isNotNull());
    final specimenList = await query.get();
    final speciesIdSet = specimenList.map((s) => s.speciesID).toSet();

    if (speciesIdSet.isEmpty) {
       return [];
     }

    final nonNullableIds = speciesIdSet.whereType<int>();

    if (nonNullableIds.isEmpty) {
      return [];
    }

    return await (select(taxonomy)..where((t) => t.id.isIn(nonNullableIds))).get();
  }

  Future<void> createTaxon(TaxonomyCompanion form) {
    return into(taxonomy).insert(form);
  }

  Future<void> updateTaxonEntry(int id, TaxonomyCompanion entry) {
    return (update(taxonomy)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> deleteTaxon(int id) {
    return (delete(taxonomy)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAllTaxon() {
    return delete(taxonomy).go();
  }
}
