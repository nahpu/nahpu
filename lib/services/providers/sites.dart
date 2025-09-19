import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sites.g.dart';

const String habitatTypePrefKey = 'habitatTypes';
const List<String> defaultHabitatTypes = [
  'Forest / Woodland',
  'Grassland / Savanna',
  'Wetland / Aquatic (rivers, lakes, marshes)',
  'Desert / Arid',
  'Urban / Built-up',
];

@riverpod
class SiteEntry extends _$SiteEntry {
  Future<List<SiteData>> _fetchSiteEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);

    final siteEntries =
        SiteQuery(ref.read(databaseProvider)).getAllSites(projectUuid);

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
      final filteredSites =
          SiteSearchServices(siteEntries: sites).search(query.toLowerCase());
      return filteredSites;
    });
  }
}

final coordinateBySiteProvider = FutureProvider.family
    .autoDispose<List<CoordinateData>, int>((ref, siteId) =>
        CoordinateQuery(ref.read(databaseProvider))
            .getCoordinatesBySiteID(siteId));

final coordinateByEventProvider = FutureProvider.family
    .autoDispose<List<CoordinateData>, int>((ref, collEventId) async {
  final collEvent = await CollEventQuery(ref.read(databaseProvider))
      .getCollEventById(collEventId);
  if (collEvent.siteID != null) {
    final siteId = collEvent.siteID!;
    final coordinates = CoordinateQuery(ref.read(databaseProvider))
        .getCoordinatesBySiteID(siteId);
    return coordinates;
  } else {
    return [];
  }
});

@riverpod
Future<List<MediaData>> siteMedia(Ref ref, {required int siteId}) async {
  List<SiteMediaData> mediaList =
      await SiteQuery(ref.read(databaseProvider)).getSiteMedia(siteId);
  List<MediaData> mediaDataList = [];
  for (SiteMediaData media in mediaList) {
    if (media.mediaId != null) {
      mediaDataList.add(
        await MediaDbQuery(ref.read(databaseProvider)).getMedia(media.mediaId!),
      );
    }
  }
  return mediaDataList;
}

@riverpod
Future<List<SiteData>> siteInEvent(Ref ref) async {
  List<int?> siteList = await CollEventQuery(ref.read(databaseProvider))
      .getAllDistinctSites(ref.read(projectUuidProvider));
  List<SiteData> siteDataList = [];
  for (int? siteId in siteList) {
    if (siteId != null) {
      siteDataList.add(
        await SiteQuery(ref.read(databaseProvider)).getSiteById(siteId),
      );
    }
  }
  return siteDataList;
}

@riverpod
class HabitatType extends _$HabitatType {
  Future<List<String>> _fetchSettings() async {
    final prefs = ref.watch(settingProvider);
    final habitatList = prefs.getStringList(habitatTypePrefKey);

    List<String> currentHabitats = habitatList ?? defaultHabitatTypes;

    if (habitatList == null) {
      await prefs.setStringList(habitatTypePrefKey, currentHabitats);
    }

    return currentHabitats;
  }

  @override
  FutureOr<List<String>> build() async {
    return await _fetchSettings();
  }

  Future<void> add(String newHabitat) async {
    if (newHabitat.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final habitatList = prefs.getStringList(habitatTypePrefKey);
      if (habitatList != null && isListContains(habitatList, newHabitat)) {
        return habitatList;
      }
      // Add new habitat to list or create new list if null
      // and then add a new habitat to the list
      List<String> newList = [...habitatList ?? [], newHabitat];
      await prefs.setStringList(habitatTypePrefKey, newList);
      return newList;
    });
  }

  Future<void> replaceAll(List<String> newHabitats) async {
    if (newHabitats.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.setStringList(habitatTypePrefKey, newHabitats);
      return newHabitats;
    });
  }

  Future<void> remove(String habitat) async {
    if (habitat.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final habitatList = prefs.getStringList(habitatTypePrefKey);
      if (habitatList == null || habitatList.isEmpty) return [];

      // Remove habitat from list
      List<String> newList = [...habitatList]..remove(habitat);
      await prefs.setStringList(habitatTypePrefKey, newList);
      return newList;
    });
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.remove(habitatTypePrefKey);
      return [];
    });
  }
}