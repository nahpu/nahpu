import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/utility_services.dart';

part 'collevent_queries.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class CollEventQuery extends DatabaseAccessor<Database>
    with _$CollEventQueryMixin {
  CollEventQuery(super.db);

  Future<int> createCollEvent(CollEventCompanion form) =>
      into(collEvent).insert(form);

  Future updateCollEventEntry(int id, CollEventCompanion entry) async {
    return await (update(collEvent)..where((t) => t.id.equals(id)))
        .write(entry);
  }

  Future<List<int?>> getAllDistinctSites(String projectUuid) async {
    List<CollEventData> data = await (select(collEvent)
          ..where((t) => t.projectUuid.equals(projectUuid)))
        .get();
    List<int?> sites = data.map((e) => e.siteID).toSet().toList();

    return sites;
  }

  Future<List<CollEventData>> getAllCollEvents(String projectUuid) async {
    return await (select(collEvent)
          ..where((t) => t.projectUuid.equals(projectUuid)))
        .get();
  }

  Future<List<int>> getEventPerSite(int siteID) async {
    List<CollEventData> data =
        await (select(collEvent)..where((t) => t.siteID.equals(siteID))).get();
    return data.map((e) => e.id).toList();
  }

  Future<CollEventData> getCollEventById(int id) async {
    return await (select(collEvent)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingle();
  }

  Future<void> deleteCollEvent(int id) {
    return (delete(collEvent)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAllCollEvents(String projectUuid) {
    return (delete(collEvent)..where((t) => t.projectUuid.equals(projectUuid)))
        .go();
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
    return await (select(collEffort)
          ..where((t) => t.eventID.equals(collEventId)))
        .get();
  }

  Future<CollEffortData> getCollEffortById(int effortId) async {
    return await (select(collEffort)
          ..where((t) => t.id.equals(effortId))
          ..limit(1))
        .getSingle();
  }

  Future<List<String>> getDistinctMethods() async {
    List<CollEffortData> data =
        await (select(collEffort, distinct: true)).get();
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
      List<String> uuids, String query) async {
    List<CollPersonnelData> personnelList = [];
    for (final personId in uuids) {
      final data = await (select(collPersonnel)
            ..where((t) => t.personnelId.equals(personId)))
          .get();
      personnelList.addAll(data);
    }
    return personnelList;
  }

  Future<List<CollPersonnelData>> getCollPersonnelByEventId(
      int collEventId) async {
    return await (select(collPersonnel)
          ..where((t) => t.eventID.equals(collEventId)))
        .get();
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
    return (delete(collPersonnel)..where((t) => t.eventID.equals(eventId)))
        .go();
  }

  Future<void> deleteCollPersonnelByEventId(int eventId) {
    return (delete(collPersonnel)..where((t) => t.eventID.equals(eventId)))
        .go();
  }
}

class WeatherDataQuery extends DatabaseAccessor<Database>
    with _$CollEventQueryMixin {
  WeatherDataQuery(super.db);

  Future<int> createWeatherData(WeatherCompanion form) =>
      into(weather).insert(form);

  Future updateWeatherDataEntry(int id, WeatherCompanion entry) {
    return (update(weather)..where((t) => t.eventID.equals(id))).write(entry);
  }

  Future<WeatherData> getWeatherDataByEventId(int weatherId) async {
    return await (select(weather)..where((t) => t.eventID.equals(weatherId)))
        .getSingle();
  }

  Future<void> deleteWeatherData(int eventId) {
    return (delete(weather)..where((t) => t.eventID.equals(eventId))).go();
  }
}
