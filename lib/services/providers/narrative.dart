import 'dart:async';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/record_sort.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/narrative/narrative_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final narrativeEntryProvider =
    AsyncNotifierProvider.autoDispose<NarrativeEntry, List<NarrativeData>>(
      NarrativeEntry.new,
    );

class NarrativeEntry extends AsyncNotifier<List<NarrativeData>> {
  Future<List<NarrativeData>> _fetchNarrativeEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);
    // Watched, not read: changing the sort has to refetch the list.
    final sort = ref.watch(recordSortProvider(RecordViewer.narrative));

    final narrativeEntries = NarrativeQuery(
      ref.read(databaseProvider),
    ).getAllNarrative(projectUuid, sort: sort);

    return narrativeEntries;
  }

  @override
  FutureOr<List<NarrativeData>> build() async {
    return await _fetchNarrativeEntry();
  }

  Future<void> search(String? query) async {
    if (query == null || query.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      final narratives = await _fetchNarrativeEntry();
      final filteredNarratives = NarrativeSearchServices(
        narrativeEntries: narratives,
      ).search(query.toLowerCase());
      return filteredNarratives;
    });
  }
}

final narrativeMediaProvider = FutureProvider.family
    .autoDispose<List<MediaData>, int>((ref, narrativeId) async {
      final database = ref.read(databaseProvider);
      List<NarrativeMediaData> mediaList = await NarrativeQuery(
        database,
      ).getNarrativeMedia(narrativeId);
      List<MediaData> mediaDataList = [];
      for (NarrativeMediaData media in mediaList) {
        if (media.mediaId != null) {
          mediaDataList.add(
            await MediaDbQuery(database).getMedia(media.mediaId!),
          );
        }
      }
      return mediaDataList;
    });
