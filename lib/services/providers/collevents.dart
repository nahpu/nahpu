import 'dart:async';

import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collEventEntryProvider =
    AsyncNotifierProvider.autoDispose<CollEventEntry, List<CollEventData>>(
      CollEventEntry.new,
    );

class CollEventEntry extends AsyncNotifier<List<CollEventData>> {
  Future<List<CollEventData>> _fetchCollEventEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);

    final collEvents = CollEventQuery(
      ref.read(databaseProvider),
    ).getAllCollEvents(projectUuid);

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

final collEffortByEventProvider = FutureProvider.family
    .autoDispose<List<CollEffortData>, int>(
      (ref, collEventId) => CollEffortQuery(
        ref.read(databaseProvider),
      ).getCollEffortByEventId(collEventId),
    );

final collPersonnelProvider = FutureProvider.family
    .autoDispose<List<CollPersonnelData>, int>(
      (ref, collEventId) => CollPersonnelQuery(
        ref.read(databaseProvider),
      ).getCollPersonnelByEventId(collEventId),
    );

final environmentDataProvider = FutureProvider.family
    .autoDispose<EnvironmentData, int>(
      (ref, collEventId) => EnvironmentDataQuery(
        ref.read(databaseProvider),
      ).getEnvironmentDataByEventId(collEventId),
    );

final eventMediaProvider = FutureProvider.family
    .autoDispose<List<MediaData>, int>((ref, eventId) async {
      final links = await CollEventQuery(
        ref.read(databaseProvider),
      ).getEventMedia(eventId);
      final mediaQuery = MediaDbQuery(ref.read(databaseProvider));
      final media = <MediaData>[];
      for (final link in links) {
        if (link.mediaId case final mediaId?) {
          media.add(await mediaQuery.getMedia(mediaId));
        }
      }
      return media;
    });
