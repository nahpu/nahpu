import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sites.g.dart';

const String siteTypePrefKey = 'siteTypes';
const String siteTypeFmtPrefKey = 'siteTypeFmt';
const String habitatTypePrefKey = 'habitatTypes';
const String habitatTypeFmtPrefKey = 'habitatTypeFmt';

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

List<String> getDefaultTypeList(String prefKey) {
  switch (prefKey) {
    case habitatTypePrefKey:
      return defaultHabitatTypes;
    case siteTypePrefKey:
      return defaultSiteTypes;
    default:
      return [];
  }
}

@riverpod
class UserDefinedType extends _$UserDefinedType {
  Future<List<String>> _fetchSettings(String prefKey) async {
    final prefs = ref.watch(settingProvider);
    final typesList = prefs.getStringList(prefKey);

    List<String> currentTypes = typesList ?? getDefaultTypeList(prefKey);

    if (typesList == null) {
      await prefs.setStringList(prefKey, currentTypes);
    }

    return currentTypes;
  }

  @override
  FutureOr<List<String>> build(String prefKey) async {
    return await _fetchSettings(prefKey);
  }

  Future<void> add(String prefKey, String newType) async {
    if (newType.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final typesList = prefs.getStringList(prefKey);
      if (typesList != null && isListContains(typesList, newType)) {
        return typesList;
      }

      // Add new type to list or create new list if null
      // and then add a new type to the list
      List<String> newList = [...typesList ?? [], newType];
      await prefs.setStringList(prefKey, newList);
      return newList;
    });
  }

  Future<void> replaceAll(List<String> newTypes) async {
    if (newTypes.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.setStringList(prefKey, newTypes);
      return newTypes;
    });
  }

  Future<void> remove(String type) async {
    if (type.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final typesList = prefs.getStringList(prefKey);
      if (typesList == null || typesList.isEmpty) return [];

      // Remove habitat from list
      List<String> newList = [...typesList]..remove(type);
      await prefs.setStringList(prefKey, newList);
      return newList;
    });
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.remove(prefKey);
      return [];
    });
  }
}
