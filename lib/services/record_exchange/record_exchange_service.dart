import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/associated_data/associated_data_services.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/record_exchange/record_exchange_archive.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';
import 'package:nahpu/services/record_exchange/record_exchange_site_event.dart';
import 'package:nahpu/services/record_exchange/record_exchange_specimen.dart';

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

  Future<List<SiteData>> getCurrentProjectSites() =>
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
