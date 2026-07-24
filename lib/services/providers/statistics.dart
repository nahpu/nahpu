import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/statistics_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/types/statistics.dart';

final statisticDataProvider = StreamProvider.autoDispose
    .family<List<StatisticDatum>, StatisticRequest>((ref, request) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchStatistics(request);
    });

final statisticFilterOptionsProvider = StreamProvider.autoDispose
    .family<List<StatisticFilterOption>, StatisticKind>((ref, kind) {
      final projectUuid = ref.watch(projectUuidProvider);
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchFilterOptions(projectUuid, kind);
    });

final recordStatisticTotalsProvider =
    StreamProvider.autoDispose<RecordStatisticTotals>((ref) {
      final projectUuid = ref.watch(projectUuidProvider);
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchRecordTotals(projectUuid);
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
    .family<List<StatisticFilterOption>, String>((ref, projectUuid) {
      return StatisticsQuery(
        ref.watch(databaseProvider),
      ).watchSpatialSpeciesOptions(projectUuid);
    });
