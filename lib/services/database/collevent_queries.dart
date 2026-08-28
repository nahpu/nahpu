import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/record_sort_terms.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/types/record_sort.dart';

part 'collevent_queries.g.dart';

@DriftAccessor(include: {'tables.drift'})
class CollEventQuery extends DatabaseAccessor<Database>
    with _$CollEventQueryMixin {
  CollEventQuery(super.db);

  Future<int> createCollEvent(CollEventCompanion form) =>
      into(collEvent).insert(form);

  Future updateCollEventEntry(int id, CollEventCompanion entry) async {
    return await (update(
      collEvent,
    )..where((t) => t.id.equals(id))).write(entry);
  }

  Future<List<int?>> getAllDistinctSites(String projectUuid) async {
    List<CollEventData> data = await (select(
      collEvent,
    )..where((t) => t.projectUuid.equals(projectUuid))).get();
    List<int?> sites = data.map((e) => e.siteID).toSet().toList();

    return sites;
  }

  /// Returns events in [sort] order. The default keeps insertion order, so new
  /// records are the final form page.
  Future<List<CollEventData>> getAllCollEvents(
    String projectUuid, {
    RecordSort sort = RecordSort.defaultSort,
  }) async {
    if (sort.isDefault) {
      return await (select(collEvent)
            ..where((t) => t.projectUuid.equals(projectUuid))
            ..orderBy([(row) => OrderingTerm.asc(row.id)]))
          .get();
    }
    // The displayed event id spans the site, so join it in even when the sort
    // does not need it — an empty join is not worth a second query shape.
    final query =
        select(
            collEvent,
          ).join([leftOuterJoin(site, collEvent.siteID.equalsExp(site.id))])
          ..where(collEvent.projectUuid.equals(projectUuid))
          ..orderBy(_orderingTerms(sort));
    final rows = await query.get();
    return rows.map((row) => row.readTable(collEvent)).toList(growable: false);
  }

  List<OrderingTerm> _orderingTerms(RecordSort sort) {
    final direction = sort.direction;
    return [
      ...switch (sort.field) {
        // Order by the components `formatCollEventId` composes, not by a
        // concatenated string: that keeps `2-` ahead of `10-`.
        RecordSortField.eventId => [
          ...textSortTerms(site.siteID, direction),
          ...textSortTerms(collEvent.startDate, direction),
          ...textSortTerms(collEvent.idSuffix, direction),
        ],
        // Start dates are ISO `yyyy-MM-dd` text, so lexicographic ordering is
        // chronological.
        RecordSortField.startDate => textSortTerms(
          collEvent.startDate,
          direction,
        ),
        // Insertion order, and any field this viewer does not offer.
        _ => [
          OrderingTerm(
            expression: collEvent.id,
            mode: orderingModeFor(direction),
          ),
        ],
      },
      // Ties must break the same way on every refetch (see record_sort_terms).
      OrderingTerm.asc(collEvent.id),
    ];
  }

  Future<List<int>> getEventPerSite(int siteID) async {
    List<CollEventData> data = await (select(
      collEvent,
    )..where((t) => t.siteID.equals(siteID))).get();
    return data.map((e) => e.id).toList();
  }

  Future<CollEventData> getCollEventById(int id) async {
    return await (select(collEvent)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingle();
  }

  Future<List<String>> getDistinctPrimaryActivities() async {
    final data = await select(collEvent).get();
    return getDistinctList(
      data.map((event) => event.primaryCollMethod).toList(),
    );
  }

  Future<void> createEventMedia(EventMediaCompanion form) {
    return into(eventMedia).insert(form);
  }

  Future<List<EventMediaData>> getEventMedia(int eventId) {
    return (select(eventMedia)..where((t) => t.eventID.equals(eventId))).get();
  }

  Future<void> deleteEventMedia(int mediaId) {
    return (delete(eventMedia)..where((t) => t.mediaId.equals(mediaId))).go();
  }

  Future<void> deleteAllEventMedia(int eventId) {
    return (delete(eventMedia)..where((t) => t.eventID.equals(eventId))).go();
  }

  Future<void> deleteCollEvent(int id) {
    return (delete(collEvent)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAllCollEvents(String projectUuid) {
    return (delete(
      collEvent,
    )..where((t) => t.projectUuid.equals(projectUuid))).go();
  }
}

// We use the class mixin from CollEventQuery to create a new class
class CollEffortQuery extends DatabaseAccessor<Database>
    with _$CollEventQueryMixin {
  CollEffortQuery(super.db);

  Future<int> createCollEffort(CollEffortCompanion form) =>
      into(collEffort).insert(form);

  Future updateCollEffortEntry(int id, CollEffortCompanion entry) {
    return (update(collEffort)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<List<CollEffortData>> getCollEffortByEventId(int collEventId) async {
    return await (select(
      collEffort,
    )..where((t) => t.eventID.equals(collEventId))).get();
  }

  Future<CollEffortData> getCollEffortById(int effortId) async {
    return await (select(collEffort)
          ..where((t) => t.id.equals(effortId))
          ..limit(1))
        .getSingle();
  }

  Future<List<String>> getDistinctMethods() async {
    List<CollEffortData> data = await (select(
      collEffort,
      distinct: true,
    )).get();
    List<String> methods = getDistinctList(data.map((e) => e.method).toList());

    if (kDebugMode) print('getDistinctMethods: $methods');

    return methods;
  }

  Future<void> deleteCollEffort(int id) {
    return (delete(collEffort)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteCollEffortsFromList(List<int> ids) {
    return (delete(collEffort)..where((t) => t.id.isIn(ids))).go();
  }

  Future<void> deleteCollEffortByEventId(int eventId) {
    return (delete(collEffort)..where((t) => t.eventID.equals(eventId))).go();
  }
}

class CollPersonnelQuery extends DatabaseAccessor<Database>
    with _$CollEventQueryMixin {
  CollPersonnelQuery(super.db);

  Future<int> createCollPersonnel(CollPersonnelCompanion form) =>
      into(collPersonnel).insert(form);

  Future updateCollPersonnelEntry(int id, CollPersonnelCompanion entry) {
    return (update(collPersonnel)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<List<CollPersonnelData>> searchCollectingPersonnel(
    List<String> uuids,
    String query,
  ) async {
    List<CollPersonnelData> personnelList = [];
    for (final personId in uuids) {
      final data = await (select(
        collPersonnel,
      )..where((t) => t.personnelId.equals(personId))).get();
      personnelList.addAll(data);
    }
    return personnelList;
  }

  Future<List<CollPersonnelData>> getCollPersonnelByEventId(
    int collEventId,
  ) async {
    return await (select(
      collPersonnel,
    )..where((t) => t.eventID.equals(collEventId))).get();
  }

  Future<CollPersonnelData> getCollPersonnelById(int personnelId) async {
    return await (select(collPersonnel)
          ..where((t) => t.id.equals(personnelId))
          ..limit(1))
        .getSingle();
  }

  Future<List<String>> getDistinctRoles() async {
    List<CollPersonnelData> data = await select(collPersonnel).get();
    List<String> roles = getDistinctList(data.map((e) => e.role).toList());
    if (kDebugMode) {
      print('getDistinctRoles: $roles');
    }

    return roles;
  }

  Future<void> deleteCollPersonnel(int personnelId) {
    return (delete(collPersonnel)..where((t) => t.id.equals(personnelId))).go();
  }

  Future<void> deleteCollPersonnelFromList(List<int> personnelIds) {
    return (delete(collPersonnel)..where((t) => t.id.isIn(personnelIds))).go();
  }

  Future<void> deleteAllEventPersonnel(int eventId) {
    return (delete(
      collPersonnel,
    )..where((t) => t.eventID.equals(eventId))).go();
  }

  Future<void> deleteCollPersonnelByEventId(int eventId) {
    return (delete(
      collPersonnel,
    )..where((t) => t.eventID.equals(eventId))).go();
  }
}

class EnvironmentDataQuery extends DatabaseAccessor<Database>
    with _$CollEventQueryMixin {
  EnvironmentDataQuery(super.db);

  Future<int> createEnvironmentData(EnvironmentCompanion form) =>
      into(environment).insert(form);

  Future updateEnvironmentDataEntry(int id, EnvironmentCompanion entry) {
    return (update(
      environment,
    )..where((t) => t.eventID.equals(id))).write(entry);
  }

  Future<EnvironmentData> getEnvironmentDataByEventId(int eventId) async {
    return await (select(
      environment,
    )..where((t) => t.eventID.equals(eventId))).getSingle();
  }

  Future<void> deleteEnvironmentData(int eventId) {
    return (delete(environment)..where((t) => t.eventID.equals(eventId))).go();
  }
}
