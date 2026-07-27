import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/record_exchange/record_exchange_database.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';

class RecordExchangeSiteEvent extends AppServices {
  const RecordExchangeSiteEvent({required super.ref});

  RecordExchangeDatabase get support => RecordExchangeDatabase(ref: ref);

  Future<RecordExchangePayload> exportSite(int siteId) async {
    final site =
        await (dbAccess.select(dbAccess.site)
              ..where((row) => row.id.equals(siteId))
              ..where((row) => row.projectUuid.equals(currentProjectUuid)))
            .getSingleOrNull();
    if (site == null) throw const FormatException('Site could not be found.');

    final coordinates = await CoordinateQuery(
      dbAccess,
    ).getCoordinatesBySiteID(site.id);
    final personnel = <Map<String, dynamic>>[];
    if (site.leadStaffId != null) {
      final leadStaff = await support.getPersonnel(site.leadStaffId!);
      if (leadStaff != null) {
        personnel.add(support.portablePersonnel(leadStaff));
      }
    }

    return RecordExchangePayload(
      type: RecordExchangeType.site,
      data: {
        'site': support.portableSite(site),
        'coordinates': coordinates
            .map(support.portableCoordinate)
            .toList(growable: false),
        'associatedData':
            (await AssociatedDataQuery(
                  dbAccess,
                ).getAssociatedDataForSite(site.id))
                .map(
                  (value) => RecordExchangeDatabase.without(value.toJson(), {
                    'primaryId',
                    'specimenUuid',
                    'projectUuid',
                  }),
                )
                .toList(growable: false),
        'personnel': personnel,
      },
    );
  }

  Future<RecordExchangePayload> exportEvent(int eventId) async {
    final event =
        await (dbAccess.select(dbAccess.collEvent)
              ..where((row) => row.id.equals(eventId))
              ..where((row) => row.projectUuid.equals(currentProjectUuid)))
            .getSingleOrNull();
    if (event == null) {
      throw const FormatException('Event could not be found.');
    }

    final effort = await CollEffortQuery(
      dbAccess,
    ).getCollEffortByEventId(event.id);
    final assignments = await CollPersonnelQuery(
      dbAccess,
    ).getCollPersonnelByEventId(event.id);
    final personnel = <String, Map<String, dynamic>>{};
    for (final assignment in assignments) {
      final id = assignment.personnelId;
      if (id != null) {
        final person = await support.getPersonnel(id);
        if (person != null) personnel[id] = support.portablePersonnel(person);
      }
    }

    Map<String, dynamic>? linkedSite;
    if (event.siteID != null) {
      final site =
          await (dbAccess.select(dbAccess.site)
                ..where((row) => row.id.equals(event.siteID!))
                ..where((row) => row.projectUuid.equals(currentProjectUuid)))
              .getSingleOrNull();
      if (site != null) {
        final coordinates = await CoordinateQuery(
          dbAccess,
        ).getCoordinatesBySiteID(site.id);
        linkedSite = {
          'site': support.portableSite(site),
          'coordinates': coordinates
              .map(support.portableCoordinate)
              .toList(growable: false),
        };
        if (site.leadStaffId != null) {
          final leadStaff = await support.getPersonnel(site.leadStaffId!);
          if (leadStaff != null) {
            personnel[leadStaff.uuid] = support.portablePersonnel(leadStaff);
          }
        }
      }
    }

    WeatherData? weather;
    try {
      weather = await (dbAccess.select(
        dbAccess.weather,
      )..where((row) => row.eventID.equals(event.id))).getSingleOrNull();
    } catch (_) {
      weather = null;
    }

    return RecordExchangePayload(
      type: RecordExchangeType.event,
      data: {
        'event': support.portableEvent(event),
        'effort': effort.map(support.portableEffort).toList(growable: false),
        'personnelAssignments': assignments
            .map(support.portableAssignment)
            .toList(growable: false),
        'personnel': personnel.values.toList(growable: false),
        'weather': weather == null ? null : support.portableWeather(weather),
        'site': ?linkedSite,
      },
    );
  }

  Future<RecordExchangeResult> importSite(
    RecordExchangePayload payload, {
    int? targetId,
  }) async {
    final personnelIds = await support.importPersonnel(
      RecordExchangePayload.mapList(payload.data['personnel']),
    );
    final siteJson = _requiredMap(payload.data['site'], 'site');
    final leadStaffId = RecordExchangeDatabase.optionalString(
      siteJson['leadStaffId'],
    );
    support.validatePersonnelReference(leadStaffId, personnelIds);
    final companion = support.siteCompanion(siteJson);
    if (targetId != null) {
      final target =
          await (dbAccess.select(dbAccess.site)
                ..where((row) => row.id.equals(targetId))
                ..where((row) => row.projectUuid.equals(currentProjectUuid)))
              .getSingleOrNull();
      if (target == null) {
        throw const FormatException('The selected site no longer exists.');
      }
    }
    final siteId =
        targetId ??
        await dbAccess
            .into(dbAccess.site)
            .insert(
              companion.copyWith(projectUuid: db.Value(currentProjectUuid)),
            );
    if (targetId != null) {
      await (dbAccess.update(dbAccess.site)
            ..where((row) => row.id.equals(targetId)))
          .write(companion.copyWith(projectUuid: db.Value(currentProjectUuid)));
      await (dbAccess.delete(
        dbAccess.coordinate,
      )..where((row) => row.siteID.equals(targetId))).go();
      await AssociatedDataQuery(dbAccess).unlinkAllFromSite(targetId);
    }
    for (final coordinateJson in RecordExchangePayload.mapList(
      payload.data['coordinates'],
    )) {
      await dbAccess
          .into(dbAccess.coordinate)
          .insert(support.coordinateCompanion(coordinateJson, siteId));
    }
    for (final json in RecordExchangePayload.mapList(
      payload.data['associatedData'],
    )) {
      final associatedDataId = await AssociatedDataQuery(dbAccess)
          .createProjectAssociatedData(
            AssociatedDataData.fromJson({
              ...json,
              'primaryId': null,
              'specimenUuid': null,
              'projectUuid': currentProjectUuid,
            }).toCompanion(true),
          );
      await AssociatedDataQuery(dbAccess).linkToSite(associatedDataId, siteId);
    }
    return RecordExchangeResult(recordId: siteId);
  }

  Future<RecordExchangeResult> importEvent(
    RecordExchangePayload payload, {
    int? targetId,
    int? linkedSiteId,
    bool createEmbeddedSite = false,
  }) async {
    final personnelIds = await support.importPersonnel(
      RecordExchangePayload.mapList(payload.data['personnel']),
    );
    final eventJson = _requiredMap(payload.data['event'], 'event');
    final siteData = payload.data['site'];
    var resolvedSiteId = linkedSiteId;
    int? createdSiteId;
    if (siteData != null && createEmbeddedSite) {
      final linked = _requiredMap(siteData, 'linked site');
      createdSiteId = await support.insertPortableSite(
        _requiredMap(linked['site'], 'linked site'),
        RecordExchangePayload.mapList(linked['coordinates']),
        personnelIds,
      );
      resolvedSiteId = createdSiteId;
    }
    if (siteData != null && resolvedSiteId == null) {
      throw const FormatException('Select a site for the imported event.');
    }
    if (resolvedSiteId != null) {
      final linkedSite =
          await (dbAccess.select(dbAccess.site)
                ..where((row) => row.id.equals(resolvedSiteId!))
                ..where((row) => row.projectUuid.equals(currentProjectUuid)))
              .getSingleOrNull();
      if (linkedSite == null && !createEmbeddedSite) {
        throw const FormatException(
          'The selected event site no longer exists.',
        );
      }
    }

    final companion = support.eventCompanion(eventJson, resolvedSiteId);
    if (targetId != null) {
      final target =
          await (dbAccess.select(dbAccess.collEvent)
                ..where((row) => row.id.equals(targetId))
                ..where((row) => row.projectUuid.equals(currentProjectUuid)))
              .getSingleOrNull();
      if (target == null) {
        throw const FormatException('The selected event no longer exists.');
      }
    }
    final eventId =
        targetId ??
        await dbAccess
            .into(dbAccess.collEvent)
            .insert(
              companion.copyWith(projectUuid: db.Value(currentProjectUuid)),
            );
    if (targetId != null) {
      await (dbAccess.update(dbAccess.collEvent)
            ..where((row) => row.id.equals(targetId)))
          .write(companion.copyWith(projectUuid: db.Value(currentProjectUuid)));
      await (dbAccess.delete(
        dbAccess.collEffort,
      )..where((row) => row.eventID.equals(targetId))).go();
      await (dbAccess.delete(
        dbAccess.collPersonnel,
      )..where((row) => row.eventID.equals(targetId))).go();
      await (dbAccess.delete(
        dbAccess.weather,
      )..where((row) => row.eventID.equals(targetId))).go();
    }

    for (final effortJson in RecordExchangePayload.mapList(
      payload.data['effort'],
    )) {
      await dbAccess
          .into(dbAccess.collEffort)
          .insert(support.effortCompanion(effortJson, eventId));
    }
    for (final assignmentJson in RecordExchangePayload.mapList(
      payload.data['personnelAssignments'],
    )) {
      final personnelId = RecordExchangeDatabase.optionalString(
        assignmentJson['personnelId'],
      );
      support.validatePersonnelReference(personnelId, personnelIds);
      await dbAccess
          .into(dbAccess.collPersonnel)
          .insert(support.assignmentCompanion(assignmentJson, eventId));
    }
    final weather = payload.data['weather'];
    if (weather is Map) {
      await dbAccess
          .into(dbAccess.weather)
          .insert(
            support.weatherCompanion(
              Map<String, dynamic>.from(weather),
              eventId,
            ),
          );
    }
    return RecordExchangeResult(
      recordId: eventId,
      createdSiteId: createdSiteId,
    );
  }

  Future<List<SiteData>> getCurrentProjectSites() {
    return SiteQuery(dbAccess).getAllSites(currentProjectUuid);
  }

  Future<List<CollEventData>> getCurrentProjectEvents() {
    return CollEventQuery(dbAccess).getAllCollEvents(currentProjectUuid);
  }

  static Map<String, dynamic> _requiredMap(dynamic value, String name) {
    if (value is! Map) throw FormatException('NAHPU $name data is invalid.');
    return Map<String, dynamic>.from(value);
  }
}
