import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/geography_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/associated_data/associated_data_services.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/record_exchange/record_exchange_archive.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';
import 'package:nahpu/services/record_exchange/record_exchange_site_event.dart';
import 'package:nahpu/services/record_exchange/record_exchange_specimen.dart';
import 'package:nahpu/services/types/geography.dart';

export 'record_exchange_models.dart';
export 'record_exchange_archive.dart';

class RecordExchangeService extends AppServices {
  const RecordExchangeService({required super.ref});

  RecordExchangeSiteEvent get siteEvent => RecordExchangeSiteEvent(ref: ref);

  RecordExchangeSpecimen get specimen => RecordExchangeSpecimen(ref: ref);

  RecordExchangeArchiveService get archive =>
      RecordExchangeArchiveService(ref: ref);

  Future<RecordExchangePayload> exportSite(int siteId) =>
      siteEvent.exportSite(siteId);

  Future<RecordExchangePayload> exportEvent(
    int eventId, {
    bool includeMedia = false,
  }) => siteEvent.exportEvent(eventId, includeMedia: includeMedia);

  /// The open project, which a payload's `siteRef` names.
  String get projectUuid => currentProjectUuid;

  Future<int> getEventMediaCount(int eventId) async {
    return (await CollEventQuery(
      dbAccess,
    ).getEventMedia(eventId)).where((entry) => entry.mediaId != null).length;
  }

  Future<RecordExchangePayload> exportSpecimen(
    String specimenUuid, {
    bool includeMedia = false,
  }) async {
    final mediaCount = await getSpecimenMediaCount(specimenUuid);
    if (mediaCount > 0 && !includeMedia) {
      throw FormatException(
        'This specimen has $mediaCount linked media file(s). '
        'Export it as a compressed archive to include them.',
      );
    }
    return specimen.exportSpecimen(specimenUuid, includeMedia: includeMedia);
  }

  Future<int> getSpecimenMediaCount(String specimenUuid) async {
    return (await SpecimenQuery(dbAccess).getSpecimenMedia(
      specimenUuid,
    )).where((entry) => entry.mediaId != null).length;
  }

  Future<File> saveJson(
    RecordExchangePayload payload, {
    required String fileStem,
    Directory? destinationDirectory,
  }) {
    return archive.save(
      payload,
      fileStem: fileStem,
      destinationDirectory: destinationDirectory,
    );
  }

  Future<File> saveSpecimen(
    RecordExchangePayload payload, {
    required String fileStem,
    required RecordArchiveFormat archiveFormat,
    Directory? destinationDirectory,
  }) {
    return saveRecordArchive(
      payload,
      fileStem: fileStem,
      archiveFormat: archiveFormat,
      destinationDirectory: destinationDirectory,
    );
  }

  Future<File> saveRecordArchive(
    RecordExchangePayload payload, {
    required String fileStem,
    required RecordArchiveFormat archiveFormat,
    Directory? destinationDirectory,
  }) {
    return archive.save(
      payload,
      fileStem: fileStem,
      archiveFormat: archiveFormat,
      destinationDirectory: destinationDirectory,
    );
  }

  Future<RecordExchangeResult> importPayload(
    RecordExchangePayload payload, {
    int? targetId,
    int? linkedSiteId,
    bool createEmbeddedSite = false,
    String? targetSpecimenUuid,
    SpecimenImportReferences references = const SpecimenImportReferences(),
    Directory? extractedMediaDirectory,
  }) async {
    payload.validate();
    final deferredAssociatedDataCleanup = <AssociatedDataData>[];
    final result = await dbAccess.transaction(() async {
      switch (payload.type) {
        case RecordExchangeType.site:
          return siteEvent.importSite(
            payload,
            targetId: targetId,
            deferredAssociatedDataCleanup: deferredAssociatedDataCleanup,
          );
        case RecordExchangeType.event:
          return siteEvent.importEvent(
            payload,
            targetId: targetId,
            linkedSiteId: linkedSiteId,
            createEmbeddedSite: createEmbeddedSite,
            extractedMediaDirectory: extractedMediaDirectory,
            deferredAssociatedDataCleanup: deferredAssociatedDataCleanup,
          );
        case RecordExchangeType.specimen:
          return specimen.importSpecimen(
            payload,
            targetUuid: targetSpecimenUuid,
            references: references,
            extractedMediaDirectory: extractedMediaDirectory,
            deferredAssociatedDataCleanup: deferredAssociatedDataCleanup,
          );
      }
    });
    final associatedData = AssociatedDataServices(ref: ref);
    for (final data in deferredAssociatedDataCleanup) {
      await associatedData.cleanupManagedFileIfUnused(data);
    }
    return result;
  }

  /// Finds the personnel and site [payload] points to that are neither in it
  /// nor on this device. Run before asking where to import, so a payload made
  /// of references never gets that far when its records are missing.
  Future<RecordReferenceCheck> checkReferences(
    RecordExchangePayload payload,
  ) async {
    final carried = {
      for (final person in RecordExchangePayload.mapList(
        payload.data['personnel'],
      ))
        if (person['uuid'] is String) person['uuid'] as String,
    };
    final referenced = <String, MissingPersonnelReference>{};
    void add(Object? uuid, {Object? name, Object? initial}) {
      if (uuid is! String || uuid.isEmpty || carried.contains(uuid)) return;
      final known = referenced[uuid];
      referenced[uuid] = MissingPersonnelReference(
        uuid: uuid,
        name: known?.name ?? (name is String ? name : null),
        initial: known?.initial ?? (initial is String ? initial : null),
      );
    }

    for (final ref in payload.personnelRefs) {
      add(ref['uuid'], name: ref['name'], initial: ref['initial']);
    }
    for (final assignment in RecordExchangePayload.mapList(
      payload.data['personnelAssignments'],
    )) {
      add(assignment['personnelId'], name: assignment['name']);
    }
    final record = payload.data[payload.typeName];
    if (record is Map) {
      for (final key in const [
        'leadStaffId',
        'catalogerID',
        'determinerID',
        'preparatorID',
      ]) {
        add(record[key]);
      }
    }
    final linked = payload.data['site'];
    if (linked is Map && linked['site'] is Map) {
      add((linked['site'] as Map)['leadStaffId']);
    }

    final missing = <MissingPersonnelReference>[];
    for (final person in referenced.values) {
      final onDevice = await (dbAccess.select(
        dbAccess.personnel,
      )..where((row) => row.uuid.equals(person.uuid))).getSingleOrNull();
      if (onDevice == null) missing.add(person);
    }

    final siteRef = payload.siteRef;
    if (siteRef == null) {
      return RecordReferenceCheck(missingPersonnel: missing);
    }
    final code = (siteRef['siteID'] as String).trim();
    final projectUuid = siteRef['projectUuid'];
    if (projectUuid is String && projectUuid != currentProjectUuid) {
      return RecordReferenceCheck(
        missingPersonnel: missing,
        siteCode: code,
        siteStatus: SiteReferenceStatus.otherProject,
      );
    }
    final matches = await siteEvent.support.sitesForReference(siteRef);
    return RecordReferenceCheck(
      missingPersonnel: missing,
      siteCode: code,
      siteStatus: switch (matches.length) {
        0 => SiteReferenceStatus.missing,
        1 => SiteReferenceStatus.match,
        _ => SiteReferenceStatus.ambiguous,
      },
      siteMatchIds: [for (final site in matches) site.id],
    );
  }

  /// Returns the locality already saved for [payload]'s site, if any.
  ///
  /// Lets the import dialog say the incoming locality will be reused rather
  /// than silently matching it behind the user's back.
  Future<GeographyData?> matchedGeography(RecordExchangePayload payload) {
    final site = payload.data['site'];
    if (site is! Map) return Future.value();
    return GeographyQuery(
      dbAccess,
    ).findMatch(GeographyDraft.fromJson(Map<String, dynamic>.from(site)));
  }

  Future<List<SiteRecord>> getCurrentProjectSites() =>
      siteEvent.getCurrentProjectSites();

  Future<List<CollEventData>> getCurrentProjectEvents() =>
      siteEvent.getCurrentProjectEvents();

  Future<List<SpecimenData>> getCurrentProjectSpecimens() =>
      SpecimenQuery(dbAccess).getAllSpecimens(currentProjectUuid);

  Future<List<TaxonomyData>> getTaxonomyList() => (dbAccess.select(
    dbAccess.taxonomy,
  )..orderBy([(row) => db.OrderingTerm(expression: row.genus)])).get();

  Future<XFile?> selectRecordFile() => FilePickerServices().selectRecordFile();

  Future<XFile?> selectJsonFile() => FilePickerServices().selectJsonFile();

  Future<RecordExchangeArchiveFile> readRecordFile(
    XFile file, {
    required RecordExchangeType expectedType,
  }) => archive.read(file, expectedType: expectedType);
}
