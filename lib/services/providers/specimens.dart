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

final labelSpecimenSelectionProvider =
    NotifierProvider.autoDispose<LabelSpecimenSelection, Set<String>>(
  LabelSpecimenSelection.new,
);

class LabelSpecimenSelection extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final specimens = ref.watch(specimenEntryProvider).value ?? [];
    return specimens.map((e) => e.uuid).toSet();
  }

  void updateSelection(Set<String> selection) {
    state = selection;
  }
}
