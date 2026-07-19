import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';

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

/// All printable parts in the active project, paired with their parent
/// specimen. A part, not a specimen, is the document-record unit.
final specimenPartEntryProvider =
    FutureProvider.autoDispose<List<SpecimenPartProjectRecord>>((ref) async {
  final projectUuid = ref.watch(projectUuidProvider);
  return SpecimenPartQuery(ref.read(databaseProvider))
      .getSpecimenPartsForProject(projectUuid);
});

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
