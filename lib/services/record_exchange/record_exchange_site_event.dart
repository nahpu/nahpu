import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:path/path.dart' as path;
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/record_exchange/record_exchange_database.dart';
import 'package:nahpu/services/record_exchange/record_exchange_custom_fields.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/associated_data/associated_data_services.dart';

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
            (await AssociatedDataQuery(dbAccess).getAssociatedDataForSite(
              site.id,
            )).map(support.portableAssociatedData).toList(growable: false),
        'personnel': personnel,
        'customFields': await RecordExchangeCustomFields(
          ref: ref,
        ).export(siteId: site.id),
      },
    );
  }

  Future<RecordExchangePayload> exportEvent(
    int eventId, {
    bool includeMedia = false,
  }) async {
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
          'customFields': await RecordExchangeCustomFields(
            ref: ref,
          ).export(siteId: site.id),
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

    final mediaFiles = <RecordExchangeMediaFile>[];
    final data = <String, dynamic>{
      'event': support.portableEvent(event),
      'effort': effort.map(support.portableEffort).toList(growable: false),
      'personnelAssignments': assignments
          .map(support.portableAssignment)
          .toList(growable: false),
      'weather': weather == null ? null : support.portableWeather(weather),
      'associatedData':
          (await AssociatedDataQuery(dbAccess).getAssociatedDataForEvent(
            event.id,
          )).map(support.portableAssociatedData).toList(growable: false),
      'site': ?linkedSite,
    };
    if (includeMedia) {
      data['media'] = await _exportEventMedia(event.id, mediaFiles, personnel);
    }
    data['personnel'] = personnel.values.toList(growable: false);

    return RecordExchangePayload(
      type: RecordExchangeType.event,
      data: data,
      mediaFiles: mediaFiles,
    );
  }

  Future<RecordExchangeResult> importSite(
    RecordExchangePayload payload, {
    int? targetId,
    List<AssociatedDataData>? deferredAssociatedDataCleanup,
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
      final orphaned = await AssociatedDataServices(ref: ref)
          .detachAllFromTarget(
            AssociatedDataTarget.site(targetId),
            cleanupFiles: false,
          );
      deferredAssociatedDataCleanup?.addAll(orphaned);
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
      await AssociatedDataServices(ref: ref).createAssociatedData(
        target: AssociatedDataTarget.site(siteId),
        form: AssociatedDataData.fromJson(
          support.associatedDataJson(json),
        ).toCompanion(true),
      );
    }
    await RecordExchangeCustomFields(
      ref: ref,
    ).import(payload.data['customFields'], siteId: siteId);
    return RecordExchangeResult(recordId: siteId);
  }

  Future<RecordExchangeResult> importEvent(
    RecordExchangePayload payload, {
    int? targetId,
    int? linkedSiteId,
    bool createEmbeddedSite = false,
    Directory? extractedMediaDirectory,
    List<AssociatedDataData>? deferredAssociatedDataCleanup,
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
      await RecordExchangeCustomFields(
        ref: ref,
      ).import(linked['customFields'], siteId: createdSiteId);
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
      final orphaned = await AssociatedDataServices(ref: ref)
          .detachAllFromTarget(
            AssociatedDataTarget.event(targetId),
            cleanupFiles: false,
          );
      deferredAssociatedDataCleanup?.addAll(orphaned);
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
    for (final json in RecordExchangePayload.mapList(
      payload.data['associatedData'],
    )) {
      await AssociatedDataServices(ref: ref).createAssociatedData(
        target: AssociatedDataTarget.event(eventId),
        form: AssociatedDataData.fromJson(
          support.associatedDataJson(json),
        ).toCompanion(true),
      );
    }
    if (payload.data.containsKey('media')) {
      await _deleteEventMedia(eventId);
      await _importEventMedia(
        payload,
        eventId,
        personnelIds,
        extractedMediaDirectory,
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

  Future<List<Map<String, dynamic>>> _exportEventMedia(
    int eventId,
    List<RecordExchangeMediaFile> files,
    Map<String, Map<String, dynamic>> personnel,
  ) async {
    final links = await CollEventQuery(dbAccess).getEventMedia(eventId);
    final result = <Map<String, dynamic>>[];
    for (final link in links) {
      final mediaId = link.mediaId;
      if (mediaId == null) continue;
      final media = await MediaDbQuery(dbAccess).getMedia(mediaId);
      final fileName = media.fileName;
      if (fileName == null) {
        throw FormatException('Media $mediaId has no file name.');
      }
      final source = await MediaFinder(
        ref: ref,
      ).getPathForMedia(fileName, MediaCategory.event);
      if (!source.existsSync()) {
        throw FormatException('Media file is missing: $fileName');
      }
      final archivePath = path.posix.join(
        'media',
        '$mediaId-${path.basename(fileName)}',
      );
      files.add(
        RecordExchangeMediaFile(
          sourcePath: source.path,
          archivePath: archivePath,
        ),
      );
      if (media.personnelId case final personnelId?) {
        final person = await support.getPersonnel(personnelId);
        if (person != null) {
          personnel[personnelId] = support.portablePersonnel(person);
        }
      }
      result.add({
        'media': RecordExchangeDatabase.without(media.toJson(), {
          'primaryId',
          'projectUuid',
        }),
        'sourceMediaId': mediaId,
        'archivePath': archivePath,
      });
    }
    return result;
  }

  Future<void> _deleteEventMedia(int eventId) async {
    final eventQuery = CollEventQuery(dbAccess);
    final links = await eventQuery.getEventMedia(eventId);
    for (final link in links) {
      final mediaId = link.mediaId;
      if (mediaId == null) continue;
      await eventQuery.deleteEventMedia(mediaId);
      await MediaDbQuery(dbAccess).deleteMedia(mediaId);
    }
  }

  Future<void> _importEventMedia(
    RecordExchangePayload payload,
    int eventId,
    Map<String, String> personnelIds,
    Directory? extractedMediaDirectory,
  ) async {
    final entries = RecordExchangePayload.mapList(payload.data['media']);
    if (entries.isEmpty) return;
    if (extractedMediaDirectory == null) {
      throw const FormatException('Media archive contents are missing.');
    }
    for (final entry in entries) {
      final mediaJson = _requiredMap(entry['media'], 'media');
      final archivePath = RecordExchangeDatabase.optionalString(
        entry['archivePath'],
      );
      final normalizedPath = archivePath == null
          ? null
          : path.posix.normalize(archivePath);
      if (archivePath == null ||
          path.posix.isAbsolute(archivePath) ||
          normalizedPath != archivePath ||
          !archivePath.startsWith('media/')) {
        throw const FormatException('Media archive path is invalid.');
      }
      final source = File(
        path.joinAll([
          extractedMediaDirectory.path,
          ...path.posix.split(archivePath),
        ]),
      );
      if (!source.existsSync()) {
        throw FormatException('Media archive file is missing: $archivePath');
      }
      final media = MediaData.fromJson({
        ...mediaJson,
        'primaryId': 0,
        'projectUuid': currentProjectUuid,
      });
      support.validatePersonnelReference(media.personnelId, personnelIds);
      final target = await MediaFinder(ref: ref).getPathForMedia(
        _uniqueMediaName(media.fileName ?? path.basename(archivePath)),
        MediaCategory.event,
      );
      await target.parent.create(recursive: true);
      await source.copy(target.path);
      final mediaId = await dbAccess
          .into(dbAccess.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: db.Value(currentProjectUuid),
              secondaryId: db.Value(media.secondaryId),
              category: db.Value(matchMediaCategory(MediaCategory.event)),
              tag: db.Value(media.tag),
              taken: db.Value(media.taken),
              camera: db.Value(media.camera),
              lenses: db.Value(media.lenses),
              additionalExif: db.Value(media.additionalExif),
              personnelId: db.Value(media.personnelId),
              fileName: db.Value(path.basename(target.path)),
              uri: db.Value(media.uri),
              caption: db.Value(media.caption),
            ),
          );
      await CollEventQuery(dbAccess).createEventMedia(
        EventMediaCompanion(
          eventID: db.Value(eventId),
          mediaId: db.Value(mediaId),
        ),
      );
    }
  }

  String _uniqueMediaName(String name) {
    final base = path
        .basename(name)
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return 'imported-${DateTime.now().microsecondsSinceEpoch}-$base';
  }

  static Map<String, dynamic> _requiredMap(dynamic value, String name) {
    if (value is! Map) throw FormatException('NAHPU $name data is invalid.');
    return Map<String, dynamic>.from(value);
  }
}
