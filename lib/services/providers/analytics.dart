import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/analytics_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/statistics/pca_service.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/services/types/export.dart';

/// Taxon groups with specimens in a project, or in every project when the
/// UUID is null.
final analyticsTaxonGroupsProvider = StreamProvider.autoDispose
    .family<List<SpecimenRecordType>, String?>((ref, projectUuid) {
      return AnalyticsQuery(
        ref.watch(databaseProvider),
      ).watchTaxonGroups(projectUuid);
    });

/// Variables a taxon group offers in a project, or in every project when the
/// UUID is null.
final analyticsVariableOptionsProvider = StreamProvider.autoDispose
    .family<
      List<AnalyticsVariableOption>,
      ({String? projectUuid, SpecimenRecordType taxonGroup})
    >((ref, key) {
      return AnalyticsQuery(
        ref.watch(databaseProvider),
      ).watchVariableOptions(key.projectUuid, key.taxonGroup);
    });

/// Principal component analysis of the records a request covers.
///
/// Fails with a `PcaFailure` when the data cannot be analyzed.
final pcaResultProvider = FutureProvider.autoDispose
    .family<PcaAnalysisResult, PcaRequest>((ref, request) {
      return PcaService(
        AnalyticsQuery(ref.watch(databaseProvider)),
      ).run(request);
    });
