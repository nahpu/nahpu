import 'dart:async';

import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/record_sort.dart';
import 'package:nahpu/services/types/events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collEventEntryProvider =
    AsyncNotifierProvider.autoDispose<CollEventEntry, List<CollEventData>>(
      CollEventEntry.new,
    );

class CollEventEntry extends AsyncNotifier<List<CollEventData>> {
  Future<List<CollEventData>> _fetchCollEventEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);
    // Watched, not read: changing the sort has to refetch the list.
    final sort = ref.watch(recordSortProvider(RecordViewer.collEvent));

    final collEvents = CollEventQuery(
      ref.read(databaseProvider),
    ).getAllCollEvents(projectUuid, sort: sort);

    return collEvents;
  }

  @override
  FutureOr<List<CollEventData>> build() async {
    return await _fetchCollEventEntry();
  }

  Future<void> search(String? query) async {
    if (query == null || query.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      final collEvents = await _fetchCollEventEntry();
      final filteredCollEvents = CollEventSearchServices(
        collEvents: collEvents,
      ).search(query.toLowerCase());
      return filteredCollEvents;
    });
  }
}

final collEventIDprovider = FutureProvider.family
    .autoDispose<CollEventData, int>((ref, id) async {
      final collEventID = CollEventQuery(
        ref.read(databaseProvider),
      ).getCollEventById(id);
      return collEventID;
    });

final collMethodByEventProvider = FutureProvider.family
    .autoDispose<List<CollMethodData>, int>(
      (ref, collEventId) => CollMethodQuery(
        ref.read(databaseProvider),
      ).getCollMethodByEventId(collEventId),
    );

final collPersonnelProvider = FutureProvider.family
    .autoDispose<List<CollPersonnelData>, int>(
      (ref, collEventId) => CollPersonnelQuery(
        ref.read(databaseProvider),
      ).getCollPersonnelByEventId(collEventId),
    );

final environmentDataProvider = FutureProvider.family
    .autoDispose<EditableEnvironmentData, int>(
      (ref, collEventId) => EnvironmentDataQuery(
        ref.read(databaseProvider),
      ).getEditableEnvironmentDataByEventId(collEventId),
    );

final eventMediaProvider = FutureProvider.family
    .autoDispose<List<MediaData>, int>((ref, eventId) async {
      final database = ref.read(databaseProvider);
      final links = await CollEventQuery(database).getEventMedia(eventId);
      return MediaDbQuery(
        database,
      ).getMediaByIds([for (final link in links) ?link.mediaId]);
    });
