import 'dart:async';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/record_sort.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/geography_queries.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/types/geography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final siteEntryProvider =
    AsyncNotifierProvider.autoDispose<SiteEntry, List<SiteRecord>>(
      SiteEntry.new,
    );

/// Every shared locality, for the site form's geography autocomplete.
///
/// The table is small and read on every keystroke, so it is loaded once and
/// filtered in memory, matching how the taxon provider backs the taxon field.
final geographyListProvider = FutureProvider.autoDispose<List<GeographyData>>(
  (ref) => GeographyQuery(ref.read(databaseProvider)).getAll(),
);

class SiteEntry extends AsyncNotifier<List<SiteRecord>> {
  Future<List<SiteRecord>> _fetchSiteEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);
    // Watched, not read: changing the sort has to refetch the list.
    final sort = ref.watch(recordSortProvider(RecordViewer.site));

    final siteEntries = SiteQuery(
      ref.read(databaseProvider),
    ).getAllSites(projectUuid, sort: sort);

    return siteEntries;
  }

  @override
  FutureOr<List<SiteRecord>> build() async {
    return await _fetchSiteEntry();
  }

  Future<void> search(String? query) async {
    if (query == null || query.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      final database = ref.read(databaseProvider);
      final sites = await _fetchSiteEntry();
      final attributes = await SiteQuery(
        database,
      ).getSiteAttributes(sites.map((site) => site.id));
      final filteredSites = SiteSearchServices(
        siteEntries: sites,
        attributesBySite: attributes,
      ).search(query.toLowerCase());
      return filteredSites;
    });
  }
}

final coordinateBySiteProvider = FutureProvider.family
    .autoDispose<List<CoordinateData>, int>(
      (ref, siteId) => CoordinateQuery(
        ref.read(databaseProvider),
      ).getCoordinatesBySiteID(siteId),
    );

final siteAttributeProvider = FutureProvider.family
    .autoDispose<SiteAttributeData?, int>(
      (ref, siteId) =>
          SiteQuery(ref.read(databaseProvider)).getSiteAttribute(siteId),
    );

final fossilSiteProvider = FutureProvider.autoDispose
    .family<FossilSiteData?, int>((ref, siteId) {
      return FossilSiteQuery(
        ref.watch(databaseProvider),
      ).getFossilSiteBySiteId(siteId);
    });

final coordinateByProjectProvider =
    FutureProvider.autoDispose<List<CoordinateData>>((ref) {
      final projectUuid = ref.watch(projectUuidProvider);
      return CoordinateQuery(
        ref.read(databaseProvider),
      ).getCoordinatesByProject(projectUuid);
    });

final coordinateByEventProvider = FutureProvider.family
    .autoDispose<List<CoordinateData>, int>((ref, collEventId) async {
      final database = ref.read(databaseProvider);
      final collEvent = await CollEventQuery(
        database,
      ).getCollEventById(collEventId);
      if (collEvent.siteID != null) {
        final siteId = collEvent.siteID!;
        final coordinates = CoordinateQuery(
          database,
        ).getCoordinatesBySiteID(siteId);
        return coordinates;
      } else {
        return [];
      }
    });

final siteMediaProvider = FutureProvider.family
    .autoDispose<List<MediaData>, int>((ref, siteId) async {
      final database = ref.read(databaseProvider);
      List<SiteMediaData> mediaList = await SiteQuery(
        database,
      ).getSiteMedia(siteId);
      List<MediaData> mediaDataList = [];
      for (SiteMediaData media in mediaList) {
        if (media.mediaId != null) {
          mediaDataList.add(
            await MediaDbQuery(database).getMedia(media.mediaId!),
          );
        }
      }
      return mediaDataList;
    });

final siteInEventProvider = FutureProvider.autoDispose<List<SiteRecord>>((
  ref,
) async {
  final database = ref.read(databaseProvider);
  List<int?> siteList = await CollEventQuery(
    database,
  ).getAllDistinctSites(ref.read(projectUuidProvider));
  List<SiteRecord> siteDataList = [];
  for (int? siteId in siteList) {
    if (siteId != null) {
      siteDataList.add(await SiteQuery(database).getSiteById(siteId));
    }
  }
  return siteDataList;
});
