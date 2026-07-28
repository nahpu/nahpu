import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'taxonomy_queries.g.dart';

@DriftAccessor(include: {'tables.drift'})
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
    return await (select(taxonomy)..where(
          (t) =>
              t.taxonOrder.like('%$query%') |
              t.taxonFamily.like('%$query%') |
              t.genus.like('%$query%') |
              t.specificEpithet.like('%$query%') |
              t.commonName.like('%$query%'),
        ))
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
    return (select(taxonomy)..orderBy([
          (t) => OrderingTerm(expression: t.genus),
          (t) => OrderingTerm(expression: t.specificEpithet),
        ]))
        .get();
  }

  Future<List<int>> getAllUniqueTaxonFromSpecimen() async {
    List<int?> specimenTaxonIds = await select(
      specimen,
    ).map((s) => s.speciesID).get();
    return specimenTaxonIds
        .toSet()
        .toList()
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
  }

  Future<List<int>> getAllUniqueTaxonInUse() async {
    final specimenTaxa = await select(specimen).map((s) => s.speciesID).get();
    final parasiteTaxa = await select(parasite).map((p) => p.speciesID).get();
    return {...specimenTaxa, ...parasiteTaxa}.whereType<int>().toList();
  }

  Future<int> createTaxon(TaxonomyCompanion form) {
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
