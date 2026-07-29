import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/types/specimens.dart';

const String catalogFmtPrefKey = 'catalogFmt';

final catalogFmtNotifierProvider =
    AsyncNotifierProvider.autoDispose<CatalogFmtNotifier, CatalogFmt>(
        CatalogFmtNotifier.new);

class CatalogFmtNotifier extends AsyncNotifier<CatalogFmt> {
  Future<CatalogFmt> _fetchSetting() async {
    final prefs = ref.watch(settingProvider);
    final savedFmt = prefs.getString(catalogFmtPrefKey);

    // Set to default general mammals if no setting is found
    final CatalogFmt currentFmt = matchTaxonGroupToCatFmt(savedFmt);
    if (savedFmt == null) {
      await prefs.setString(
          catalogFmtPrefKey, matchCatFmtToTaxonGroup(currentFmt));
    }

    return currentFmt;
  }

  @override
  FutureOr<CatalogFmt> build() async {
    return await _fetchSetting();
  }

  Future<void> set(CatalogFmt fmt) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final value = prefs.getString(catalogFmtPrefKey);
      final setFmt = matchTaxonGroupToCatFmt(value);
      if (setFmt == fmt) return fmt;
      await prefs.setString(catalogFmtPrefKey, matchCatFmtToTaxonGroup(fmt));
      return fmt;
    });
  }

  // TODO: Placeholder per-project catalog-format persistence.
  //
  // The project table does not yet store a catalog format, so a project's type
  // is remembered here via SharedPreferences keyed by its UUID. This lets the
  // active format follow whichever project is opened (e.g. so paleontology
  // sites show the Sedimentology section). Replace with a real column on the
  // project table once the schema is updated.
  String _projectFmtKey(String projectUuid) =>
      '${catalogFmtPrefKey}_$projectUuid';

  /// Persists [fmt] for [projectUuid] and makes it the active format.
  Future<void> setForProject(String projectUuid, CatalogFmt fmt) async {
    final prefs = ref.read(settingProvider);
    await prefs.setString(
        _projectFmtKey(projectUuid), matchCatFmtToTaxonGroup(fmt));
    await set(fmt);
  }

  /// Restores the active format from [projectUuid]'s stored value, if any.
  /// Called when a project is opened so each project keeps its own type.
  Future<void> loadForProject(String projectUuid) async {
    final prefs = ref.read(settingProvider);
    final stored = prefs.getString(_projectFmtKey(projectUuid));
    if (stored != null) {
      await set(matchTaxonGroupToCatFmt(stored));
    }
  }
}

final specimenEntryProvider =
    AsyncNotifierProvider.autoDispose<SpecimenEntry, List<SpecimenData>>(
  SpecimenEntry.new,
);

class SpecimenEntry extends AsyncNotifier<List<SpecimenData>> {
  Future<List<SpecimenData>> _fetchSpecimenEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);

    final specimenEntries = await SpecimenQuery(ref.read(databaseProvider))
        .getAllSpecimens(projectUuid);

    return specimenEntries;
  }

  @override
  FutureOr<List<SpecimenData>> build() async {
    return await _fetchSpecimenEntry();
  }
}

final partBySpecimenProvider = FutureProvider.family
    .autoDispose<List<SpecimenPartData>, String>((ref, specimenUuid) =>
        SpecimenPartQuery(ref.read(databaseProvider))
            .getSpecimenParts(specimenUuid));

final associatedDataProvider = FutureProvider.family
    .autoDispose<List<AssociatedDataData>, String>((ref, specimenUuid) async {
  final associatedDataEntries =
      await AssociatedDataQuery(ref.read(databaseProvider))
          .getAllAssociatedData(specimenUuid);

  return associatedDataEntries;
});

final specimenMediaProvider = FutureProvider.family
    .autoDispose<List<MediaData>, String>((ref, specimenUuid) async {
  List<SpecimenMediaData> mediaList =
      await SpecimenQuery(ref.read(databaseProvider))
          .getSpecimenMedia(specimenUuid);
  List<MediaData> mediaDataList = [];
  for (SpecimenMediaData media in mediaList) {
    if (media.mediaId != null) {
      mediaDataList.add(
        await MediaDbQuery(ref.read(databaseProvider)).getMedia(media.mediaId!),
      );
    }
  }
  return mediaDataList;
});
