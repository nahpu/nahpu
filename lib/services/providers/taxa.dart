import 'package:nahpu/services/database/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';

final taxonRegistryProvider = FutureProvider.autoDispose<List<TaxonomyData>>((
  ref,
) async {
  final projectTaxon = TaxonomyQuery(ref.read(databaseProvider)).getTaxonList();
  return await projectTaxon;
});

final taxonDataProvider = FutureProvider.family
    .autoDispose<TaxonomyData?, String>((ref, specimenUuid) async {
      final database = ref.read(databaseProvider);
      final taxonId = await SpecimenQuery(
        database,
      ).getSpeciesByUuid(specimenUuid);

      if (taxonId == null) {
        return null;
      }

      final taxonData = TaxonomyQuery(database).getTaxonById(taxonId);
      return taxonData;
    });

final taxonProvider = FutureProvider.autoDispose<List<TaxonomyData>>((ref) {
  final taxonList = TaxonomyQuery(ref.read(databaseProvider)).getTaxonList();
  return taxonList;
});

final taxonRecordCountsProvider = FutureProvider.family
    .autoDispose<TaxonRecordCounts, int>((ref, taxonId) {
      final projectUuid = ref.watch(projectUuidProvider);
      return TaxonomyQuery(
        ref.read(databaseProvider),
      ).getTaxonRecordCounts(taxonId, activeProjectUuid: projectUuid);
    });
