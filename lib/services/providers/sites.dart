import 'dart:async';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final siteEntryProvider =
    AsyncNotifierProvider.autoDispose<SiteEntry, List<SiteData>>(SiteEntry.new);

class SiteEntry extends AsyncNotifier<List<SiteData>> {
  Future<List<SiteData>> _fetchSiteEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);

    final siteEntries = SiteQuery(
      ref.read(databaseProvider),
    ).getAllSites(projectUuid);

    return siteEntries;
  }

  @override
  FutureOr<List<SiteData>> build() async {
    return await _fetchSiteEntry();
  }

  Future<void> search(String? query) async {
    if (query == null || query.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      final sites = await _fetchSiteEntry();
      final attributes = await SiteQuery(
        ref.read(databaseProvider),
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

final coordinateByProjectProvider =
    FutureProvider.autoDispose<List<CoordinateData>>((ref) {
      final projectUuid = ref.watch(projectUuidProvider);
      return CoordinateQuery(
        ref.read(databaseProvider),
      ).getCoordinatesByProject(projectUuid);
    });

final coordinateByEventProvider = FutureProvider.family
    .autoDispose<List<CoordinateData>, int>((ref, collEventId) async {
      final collEvent = await CollEventQuery(
        ref.read(databaseProvider),
      ).getCollEventById(collEventId);
      if (collEvent.siteID != null) {
        final siteId = collEvent.siteID!;
        final coordinates = CoordinateQuery(
          ref.read(databaseProvider),
        ).getCoordinatesBySiteID(siteId);
        return coordinates;
      } else {
        return [];
      }
    });

final siteMediaProvider = FutureProvider.family
    .autoDispose<List<MediaData>, int>((ref, siteId) async {
      List<SiteMediaData> mediaList = await SiteQuery(
        ref.read(databaseProvider),
      ).getSiteMedia(siteId);
      List<MediaData> mediaDataList = [];
      for (SiteMediaData media in mediaList) {
        if (media.mediaId != null) {
          mediaDataList.add(
            await MediaDbQuery(
              ref.read(databaseProvider),
            ).getMedia(media.mediaId!),
          );
        }
      }
      return mediaDataList;
    });

final siteInEventProvider = FutureProvider.autoDispose<List<SiteData>>((
  ref,
) async {
  List<int?> siteList = await CollEventQuery(
    ref.read(databaseProvider),
  ).getAllDistinctSites(ref.read(projectUuidProvider));
  List<SiteData> siteDataList = [];
  for (int? siteId in siteList) {
    if (siteId != null) {
      siteDataList.add(
        await SiteQuery(ref.read(databaseProvider)).getSiteById(siteId),
      );
    }
  }
  return siteDataList;
});
