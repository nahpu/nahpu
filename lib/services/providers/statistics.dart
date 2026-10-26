import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/statistics_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/types/statistics.dart';

final statisticDataProvider = StreamProvider.autoDispose
    .family<List<StatisticDatum>, StatisticRequest>((ref, request) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchStatistics(request);
    });

/// Lists the keys of the records behind one statistics group.
typedef StatisticRecordKeysLoader =
    Future<List<Object>> Function(
      StatisticRequest request, {
      required String label,
      String? seriesLabel,
    });

final statisticRecordKeysLoaderProvider = Provider<StatisticRecordKeysLoader>(
  (ref) =>
      (request, {required label, seriesLabel}) => StatisticsQuery(
        ref.read(databaseProvider),
      ).groupRecordKeys(request, label: label, seriesLabel: seriesLabel),
);

/// Filter options for one project, or for every project when the UUID is
/// null.
final statisticFilterOptionsProvider = StreamProvider.autoDispose
    .family<
      List<StatisticFilterOption>,
      ({String? projectUuid, StatisticFilterKind kind})
    >((ref, key) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchFilterOptions(key.projectUuid, key.kind);
    });

/// Which breakdowns the records of a project, or of every project when
/// null, can offer.
final statisticAvailabilityProvider = StreamProvider.autoDispose
    .family<StatisticAvailability, String?>((ref, projectUuid) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchAvailability(projectUuid);
    });

/// Record totals for a project, or across every project when null.
final recordStatisticTotalsProvider = StreamProvider.autoDispose
    .family<RecordStatisticTotals, String?>((ref, projectUuid) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchRecordTotals(projectUuid);
    });

/// Record totals for each project in the database.
final projectRecordTotalsProvider =
    StreamProvider.autoDispose<List<ProjectRecordTotals>>((ref) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchProjectRecordTotals();
    });

final spatialStatisticDataProvider = StreamProvider.autoDispose
    .family<List<SpatialStatisticDatum>, SpatialStatisticRequest>((
      ref,
      request,
    ) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchSpatialStatistics(request);
    });

final spatialSpeciesFilterOptionsProvider = StreamProvider.autoDispose
    .family<List<StatisticFilterOption>, String?>((ref, projectUuid) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchSpatialSpeciesOptions(projectUuid);
    });
