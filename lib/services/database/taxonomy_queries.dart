import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'taxonomy_queries.g.dart';

@DriftAccessor(include: {'tables.drift'})
class TaxonomyQuery extends DatabaseAccessor<Database>
    with _$TaxonomyQueryMixin {
  TaxonomyQuery(super.db);

  Future<TaxonRecordCounts> getTaxonRecordCounts(
    int taxonId, {
    String? activeProjectUuid,
  }) async {
    final allSpecimens = await _countSpecimenRecords(taxonId);
    final allParasites = await _countParasiteRecords(taxonId);
    final allProjects = allSpecimens + allParasites;
    final project = activeProjectUuid?.trim();
    if (project == null || project.isEmpty) {
      return TaxonRecordCounts(activeProject: null, allProjects: allProjects);
    }
    final projectSpecimens = await _countSpecimenRecords(taxonId, project);
    final projectParasites = await _countParasiteRecords(taxonId, project);
    return TaxonRecordCounts(
      activeProject: projectSpecimens + projectParasites,
      allProjects: allProjects,
    );
  }

  Future<int> _countSpecimenRecords(int taxonId, [String? projectUuid]) async {
    final count = specimen.uuid.count();
    final query = selectOnly(specimen)
      ..addColumns([count])
      ..where(specimen.speciesID.equals(taxonId));
    if (projectUuid != null) {
      query.where(specimen.projectUuid.equals(projectUuid));
    }
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> _countParasiteRecords(int taxonId, [String? projectUuid]) async {
    final count = parasite.id.count();
    if (projectUuid == null) {
      final query = selectOnly(parasite)
        ..addColumns([count])
        ..where(parasite.speciesID.equals(taxonId));
      final row = await query.getSingle();
      return row.read(count) ?? 0;
    }
    final query =
        selectOnly(parasite).join([
            innerJoin(specimen, parasite.specimenUuid.equalsExp(specimen.uuid)),
          ])
          ..addColumns([count])
          ..where(parasite.speciesID.equals(taxonId));
    query.where(specimen.projectUuid.equals(projectUuid));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

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

class TaxonRecordCounts {
  const TaxonRecordCounts({
    required this.activeProject,
    required this.allProjects,
  });

  final int? activeProject;
  final int allProjects;
}
