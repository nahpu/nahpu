import 'package:intl/intl.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/site_services.dart';

class CollEventServices extends AppServices {
  const CollEventServices({required super.ref});

  Future<int> createNewCollEvents() async {
    int eventID =
        await CollEventQuery(dbAccess).createCollEvent(CollEventCompanion(
      projectUuid: db.Value(currentProjectUuid),
    ));
    // Weather data used collecting event id as a foreign key
    // so we need to create a new weather data entry
    // for the new collecting event
    createWeatherData(eventID);
    invalidateCollEvent();
    return eventID;
  }

  Future<void> createWeatherData(int eventID) async {
    await WeatherDataQuery(dbAccess)
        .createWeatherData(WeatherCompanion(eventID: db.Value(eventID)));
  }

  Future<String> getCollEventID(CollEventData collEventData) async {
    final site = await SiteServices(ref: ref).getSite(collEventData.siteID);
    String siteID = site != null ? site.siteID ?? '' : '';
    String startDate = collEventData.startDate != null
        ? collEventData.startDate.toString()
        : '';
    String suffix =
        collEventData.idSuffix != null && collEventData.idSuffix!.isNotEmpty
            ? '-${collEventData.idSuffix ?? ''}'
            : '';
    return '$siteID-$startDate$suffix';
  }

  Future<List<CollEventData>> getAllCollEvents() async {
    return CollEventQuery(dbAccess).getAllCollEvents(currentProjectUuid);
  }

  Future<List<int>> getEventPerSite(int siteID) async {
    return CollEventQuery(dbAccess).getEventPerSite(siteID);
  }

  Future<Map<int, String>> getSitesForAllEvents() async {
    List<CollEventData> collEvents = await getAllCollEvents();
    List<int> siteIDs = [];
    for (CollEventData collEvent in collEvents) {
      final site = await SiteServices(ref: ref).getSite(collEvent.siteID);
      if (site != null) {
        siteIDs.add(site.id);
      }
    }
    final sites = siteIDs.toSet().toList();
    Map<int, String> siteMap = {};
    for (int id in sites) {
      final site = await SiteServices(ref: ref).getSite(id);
      if (site != null) {
        siteMap[id] = site.siteID ?? '';
      }
    }
    return siteMap;
  }

  Future<List<CollPersonnelData>> getAllCollPersonnel(int collEventId) async {
    return CollPersonnelQuery(dbAccess).getCollPersonnelByEventId(collEventId);
  }

  Future<CollPersonnelData> getCollPersonnel(int id) async {
    return CollPersonnelQuery(dbAccess).getCollPersonnelById(id);
  }

  Future<List<CollEffortData>> getAllCollEffort(int collEventId) async {
    return CollEffortQuery(dbAccess).getCollEffortByEventId(collEventId);
  }

  Future<CollEffortData> getCollEffort(int id) async {
    return CollEffortQuery(dbAccess).getCollEffortById(id);
  }

  Future<WeatherData> getAllWeatherData(int collEventId) async {
    return WeatherDataQuery(dbAccess).getWeatherDataByEventId(collEventId);
  }

  Future<CollEventData?> getCollEvent(int? eventID) async {
    if (eventID == null) {
      return null;
    } else {
      return CollEventQuery(dbAccess).getCollEventById(eventID);
    }
  }

  Future<int> createCollPersonnel(CollPersonnelCompanion form) async {
    int id = await CollPersonnelQuery(dbAccess).createCollPersonnel(form);
    invalidateCollPersonnel();
    return id;
  }

  Future<int> createCollEffort(CollEffortCompanion form) async {
    return await CollEffortQuery(dbAccess).createCollEffort(form);
  }

  void updateCollPersonnel(int id, CollPersonnelCompanion form) async {
    CollPersonnelQuery(dbAccess).updateCollPersonnelEntry(id, form);
    invalidateCollPersonnel();
  }

  void updateCollEvent(int id, CollEventCompanion entries) {
    CollEventQuery(dbAccess).updateCollEventEntry(id, entries);
  }

  void updateWeatherData(int eventID, WeatherCompanion weatherData) {
    WeatherDataQuery(dbAccess).updateWeatherDataEntry(eventID, weatherData);
  }

  Future<void> updateCollEffortEntry(int id, CollEffortCompanion entry) async {
    return await CollEffortQuery(dbAccess).updateCollEffortEntry(id, entry);
  }

  Future<void> deleteCollEvent(int collEvenId) async {
    try {
      await WeatherDataQuery(dbAccess).deleteWeatherData(collEvenId);
      await CollPersonnelQuery(dbAccess)
          .deleteCollPersonnelByEventId(collEvenId);
      await CollEffortQuery(dbAccess).deleteCollEffortByEventId(collEvenId);
      await CollEventQuery(dbAccess).deleteCollEvent(collEvenId);
      invalidateCollEvent();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCollEffort(int id) async {
    try {
      await CollEffortQuery(dbAccess).deleteCollEffort(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCollEffortFromList(List<int> collEffortList) async {
    await CollEffortQuery(dbAccess).deleteCollEffortsFromList(collEffortList);
  }

  Future<void> deleteAllCollEvents(String projectUuid) async {
    try {
      List<CollEventData> collEvents = await getAllCollEvents();
      for (CollEventData collEvent in collEvents) {
        await WeatherDataQuery(dbAccess).deleteWeatherData(collEvent.id);
        await CollPersonnelQuery(dbAccess)
            .deleteCollPersonnelByEventId(collEvent.id);
        await CollEffortQuery(dbAccess).deleteCollEffortByEventId(collEvent.id);
      }
      await CollEventQuery(dbAccess).deleteAllCollEvents(projectUuid);
      invalidateCollEvent();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCollPersonnel(int id) async {
    await CollPersonnelQuery(dbAccess).deleteCollPersonnel(id);
    invalidateCollPersonnel();
  }

  Future<void> deleteCollPersonnelFromList(List<int> collEffortList) async {
    await CollPersonnelQuery(dbAccess)
        .deleteCollPersonnelFromList(collEffortList);
  }

  void invalidateCollEvent() {
    ref.invalidate(collEventEntryProvider);
    ref.invalidate(weatherDataProvider);
    ref.invalidate(collPersonnelProvider);
  }

  void invalidateCollPersonnel() {
    ref.invalidate(collPersonnelProvider);
  }
}

class EventDuplicateService extends AppServices {
  const EventDuplicateService({required super.ref});

  CollEventServices get collEventServices => CollEventServices(ref: ref);

  /// We duplicate most of the data from the origin event
  Future<void> duplicate(int originEventID) async {
    CollEventData? collEventData =
        await collEventServices.getCollEvent(originEventID);

    if (collEventData == null) {
      return;
    }
    String newStartDate = _incrementDate(collEventData.startDate ?? '') ?? '';
    String newEndDate = _incrementDate(collEventData.endDate ?? '') ?? '';
    int destinationEventId =
        await CollEventQuery(dbAccess).createCollEvent(CollEventCompanion(
      projectUuid: db.Value(currentProjectUuid),
      siteID: db.Value(collEventData.siteID),
      startDate: db.Value(newStartDate),
      endDate: db.Value(newEndDate),
      startTime: db.Value(collEventData.startTime),
      endTime: db.Value(collEventData.endTime),
      idSuffix: db.Value(collEventData.idSuffix),
      primaryCollMethod: db.Value(collEventData.primaryCollMethod),
      collMethodNotes: db.Value(collEventData.collMethodNotes),
    ));
    await _duplicateCollEffort(originEventID, destinationEventId);
    await _duplicateCollPersonnel(originEventID, destinationEventId);
    collEventServices.createWeatherData(destinationEventId);
    collEventServices.invalidateCollEvent();
  }

  Future<void> _duplicateCollEffort(
      int originEventID, int destinationEventId) async {
    List<CollEffortData> collEfforts =
        await collEventServices.getAllCollEffort(originEventID);
    for (CollEffortData collEffort in collEfforts) {
      await collEventServices.createCollEffort(CollEffortCompanion(
        eventID: db.Value(destinationEventId),
        method: db.Value(collEffort.method),
        brand: db.Value(collEffort.brand),
        count: db.Value(collEffort.count),
        size: db.Value(collEffort.size),
        notes: db.Value(collEffort.notes),
      ));
    }
  }

  Future<void> _duplicateCollPersonnel(
      int originEventID, int destinationEventId) async {
    List<CollPersonnelData> collPersonnel =
        await collEventServices.getAllCollPersonnel(originEventID);
    for (CollPersonnelData personnel in collPersonnel) {
      await collEventServices.createCollPersonnel(CollPersonnelCompanion(
        eventID: db.Value(destinationEventId),
        personnelId: db.Value(personnel.personnelId),
        name: db.Value(personnel.name),
        role: db.Value(personnel.role),
      ));
    }
  }

  // Increment date by one day
  String? _incrementDate(String date) {
    DateFormat dateFormat = DateFormat.yMMMd();
    try {
      DateTime? parsedDate = dateFormat.parse(date);
      DateTime newDate = parsedDate.add(const Duration(days: 1));
      return dateFormat.format(newDate);
    } catch (e) {
      return null;
    }
  }
}

class CollEventSearchServices {
  final List<CollEventData> collEvents;

  CollEventSearchServices({required this.collEvents});

  List<CollEventData> search(String query) {
    List<CollEventData> filteredCollEvents = collEvents
        .where((collEvent) =>
            _isMatch(collEvent.startDate, query) ||
            _isMatch(collEvent.endDate, query))
        .toList();
    return filteredCollEvents;
  }

  List<CollEventData> searchBySiteID(int siteID) {
    List<CollEventData> filteredCollEvents =
        collEvents.where((collEvent) => collEvent.siteID == siteID).toList();
    return filteredCollEvents;
  }

  bool _isMatch(String? value, String query) {
    if (value == null) return false;
    return value.toLowerCase().contains(query);
  }
}

class CollEvenPersonnelServices extends AppServices {
  const CollEvenPersonnelServices({required super.ref});

  Future<List<int>> searchPersonnel(
      List<String> personnelUuids, String query) async {
    List<CollPersonnelData> data = await CollPersonnelQuery(dbAccess)
        .searchCollectingPersonnel(personnelUuids, query);
    return data.map((e) => e.id).toList();
  }
}
