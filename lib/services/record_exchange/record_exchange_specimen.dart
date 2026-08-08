import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:path/path.dart' as path;
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/media_services.dart';
import 'package:nahpu/services/record_exchange/record_exchange_database.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';
import 'package:nahpu/services/record_exchange/record_exchange_site_event.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/controlled_vocabulary_services.dart';
import 'package:uuid/uuid.dart';

/// Exchanges a specimen and its related attributes using the portable v1 wire
/// format.
///
/// The wire key remains `measurements` for compatibility even though records
/// are persisted in the mammal, bird, and herpetofauna attribute tables.
class RecordExchangeSpecimen extends AppServices {
  const RecordExchangeSpecimen({required super.ref});

  RecordExchangeDatabase get support => RecordExchangeDatabase(ref: ref);

  Future<RecordExchangePayload> exportSpecimen(
    String specimenUuid, {
    required bool includeMedia,
  }) async {
    final specimen =
        await (dbAccess.select(dbAccess.specimen)
              ..where((row) => row.uuid.equals(specimenUuid))
              ..where((row) => row.projectUuid.equals(currentProjectUuid)))
            .getSingleOrNull();
    if (specimen == null) {
      throw const FormatException('Specimen could not be found.');
    }

    final data = <String, dynamic>{
      'specimen':
          RecordExchangeDatabase.without(specimen.toJson(), {
            'projectUuid',
            'coordinateID',
            'collEventID',
            'speciesID',
          })..addAll({
            'sourceCoordinateID': specimen.coordinateID,
            'sourceCollEventID': specimen.collEventID,
            'sourceSpeciesID': specimen.speciesID,
          }),
      'measurements': await _exportAttributes(specimenUuid),
      'parts':
          (await SpecimenPartQuery(dbAccess).getSpecimenParts(specimenUuid))
              .map(
                (value) => RecordExchangeDatabase.without(value.toJson(), {
                  'id',
                  'specimenUuid',
                }),
              )
              .toList(growable: false),
      'associatedData':
          (await AssociatedDataQuery(dbAccess).getAllAssociatedData(
            specimenUuid,
          )).map(support.portableAssociatedData).toList(growable: false),
      'coordinates': await _exportCoordinate(specimen.coordinateID),
      'taxonomy': await _exportTaxonomy(specimen.speciesID),
      'event': await _exportEvent(specimen.collEventID),
      'personnel': <Map<String, dynamic>>[],
    };

    final personnel = <String, Map<String, dynamic>>{};
    await _addPersonnel(personnel, specimen.catalogerID);
    await _addPersonnel(personnel, specimen.determinerID);
    await _addPersonnel(personnel, specimen.preparatorID);
    for (final part in await SpecimenPartQuery(
      dbAccess,
    ).getSpecimenParts(specimenUuid)) {
      await _addPersonnel(personnel, part.personnelId);
    }
    final event = data['event'];
    if (event is Map) {
      for (final person in RecordExchangePayload.mapList(event['personnel'])) {
        final uuid = person['uuid'];
        if (uuid is String) personnel[uuid] = person;
      }
    }

    final mediaFiles = <RecordExchangeMediaFile>[];
    if (includeMedia) {
      final media = await _exportMedia(specimenUuid, mediaFiles);
      data['media'] = media;
    }
    data['personnel'] = personnel.values.toList(growable: false);

    return RecordExchangePayload(
      type: RecordExchangeType.specimen,
      data: data,
      mediaFiles: mediaFiles,
    );
  }

  Future<RecordExchangeResult> importSpecimen(
    RecordExchangePayload payload, {
    String? targetUuid,
    SpecimenImportReferences references = const SpecimenImportReferences(),
    Directory? extractedMediaDirectory,
  }) async {
    final specimenJson = _requiredMap(payload.data['specimen'], 'specimen');
    final personnelIds = await support.importPersonnel(
      RecordExchangePayload.mapList(payload.data['personnel']),
    );
    final resolvedEvent = await _resolveEvent(
      payload,
      references,
      personnelIds,
    );
    final eventId = resolvedEvent.eventId;
    final taxonomyId = await _resolveTaxonomy(payload, references);
    final coordinateId = await _importCoordinate(payload, references.siteId);

    final existingUuid = targetUuid ?? _optionalString(specimenJson['uuid']);
    final newUuid = targetUuid == null && await _specimenExists(existingUuid)
        ? const Uuid().v4()
        : (targetUuid ?? existingUuid ?? const Uuid().v4());
    if (await _specimenExists(targetUuid)) {
      await _deleteSpecimenChildren(targetUuid!);
      await (dbAccess.update(
        dbAccess.specimen,
      )..where((row) => row.uuid.equals(targetUuid))).write(
        _specimenCompanion(
          specimenJson,
          targetUuid,
          eventId,
          taxonomyId,
          coordinateId,
        ),
      );
    } else {
      await dbAccess
          .into(dbAccess.specimen)
          .insert(
            _specimenCompanion(
              specimenJson,
              newUuid,
              eventId,
              taxonomyId,
              coordinateId,
            ).copyWith(projectUuid: db.Value(currentProjectUuid)),
          );
    }

    await _importAttributes(payload, newUuid);
    await _importParts(payload, newUuid, personnelIds);
    await _importAssociatedData(payload, newUuid);
    if (payload.hasMedia) {
      await _importMedia(payload, newUuid, extractedMediaDirectory);
    }

    invalidateEffectiveControlledVocabularies(ref);

    return RecordExchangeResult(
      recordUuid: newUuid,
      createdEventId: resolvedEvent.createdEventId,
      createdSiteId: resolvedEvent.createdSiteId,
    );
  }

  Future<Map<String, dynamic>> _exportAttributes(String uuid) async {
    final mammal = await (dbAccess.select(
      dbAccess.mammalAttribute,
    )..where((row) => row.specimenUuid.equals(uuid))).getSingleOrNull();
    final bird = await (dbAccess.select(
      dbAccess.birdAttribute,
    )..where((row) => row.specimenUuid.equals(uuid))).getSingleOrNull();
    final herp = await (dbAccess.select(
      dbAccess.herpAttribute,
    )..where((row) => row.specimenUuid.equals(uuid))).getSingleOrNull();
    return {
      'mammal': mammal?.toJson(),
      'avian': bird?.toJson(),
      'herp': herp?.toJson(),
    };
  }

  Future<List<Map<String, dynamic>>> _exportCoordinate(
    int? coordinateId,
  ) async {
    if (coordinateId == null) return const [];
    final coordinate = await (dbAccess.select(
      dbAccess.coordinate,
    )..where((row) => row.id.equals(coordinateId))).getSingleOrNull();
    return coordinate == null
        ? const []
        : [
            RecordExchangeDatabase.without(coordinate.toJson(), {
              'id',
              'siteID',
            }),
          ];
  }

  Future<Map<String, dynamic>?> _exportTaxonomy(int? taxonomyId) async {
    if (taxonomyId == null) return null;
    final taxonomy = await (dbAccess.select(
      dbAccess.taxonomy,
    )..where((row) => row.id.equals(taxonomyId))).getSingleOrNull();
    return taxonomy == null
        ? null
        : RecordExchangeDatabase.without(taxonomy.toJson(), {'id', 'mediaId'});
  }

  Future<Map<String, dynamic>?> _exportEvent(int? eventId) async {
    if (eventId == null) return null;
    try {
      final payload = await RecordExchangeSiteEvent(
        ref: ref,
      ).exportEvent(eventId);
      return payload.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> _addPersonnel(
    Map<String, Map<String, dynamic>> target,
    String? uuid,
  ) async {
    if (uuid == null) return;
    final person = await support.getPersonnel(uuid);
    if (person != null) target[uuid] = support.portablePersonnel(person);
  }

  Future<List<Map<String, dynamic>>> _exportMedia(
    String specimenUuid,
    List<RecordExchangeMediaFile> files,
  ) async {
    final links = await SpecimenQuery(dbAccess).getSpecimenMedia(specimenUuid);
    final result = <Map<String, dynamic>>[];
    for (final link in links) {
      final mediaId = link.mediaId;
      if (mediaId == null) continue;
      final media = await MediaDbQuery(dbAccess).getMedia(mediaId);
      if (media.fileName == null || media.category == null) {
        throw FormatException('Media $mediaId has no file name or category.');
      }
      final source = await MediaFinder(ref: ref).getPathForMedia(
        media.fileName!,
        matchMediaCategoryString(media.category!),
      );
      if (!source.existsSync()) {
        throw FormatException('Media file is missing: ${media.fileName}');
      }
      final archivePath = path.join(
        'media',
        '$mediaId-${path.basename(media.fileName!)}',
      );
      files.add(
        RecordExchangeMediaFile(
          sourcePath: source.path,
          archivePath: archivePath,
        ),
      );
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

  Future<bool> _specimenExists(String? uuid) async {
    if (uuid == null) return false;
    return (await (dbAccess.select(
          dbAccess.specimen,
        )..where((row) => row.uuid.equals(uuid))).getSingleOrNull()) !=
        null;
  }

  Future<({int? eventId, int? createdEventId, int? createdSiteId})>
  _resolveEvent(
    RecordExchangePayload payload,
    SpecimenImportReferences references,
    Map<String, String> personnelIds,
  ) async {
    final event = payload.data['event'];
    if (event == null) {
      return (
        eventId: references.eventId,
        createdEventId: null,
        createdSiteId: null,
      );
    }
    if (references.eventId != null && !references.createEmbeddedEvent) {
      return (
        eventId: references.eventId,
        createdEventId: null,
        createdSiteId: null,
      );
    }
    if (!references.createEmbeddedEvent) {
      throw const FormatException('Select or create the specimen event.');
    }
    final eventData = Map<String, dynamic>.from(event as Map);
    final eventPayload = RecordExchangePayload(
      type: RecordExchangeType.event,
      data: eventData,
    );
    final result = await RecordExchangeSiteEvent(ref: ref).importEvent(
      eventPayload,
      linkedSiteId: references.siteId,
      createEmbeddedSite: references.createEmbeddedSite,
    );
    return (
      eventId: result.recordId,
      createdEventId: result.recordId,
      createdSiteId: result.createdSiteId,
    );
  }

  Future<int?> _resolveTaxonomy(
    RecordExchangePayload payload,
    SpecimenImportReferences references,
  ) async {
    final taxonomy = payload.data['taxonomy'];
    if (taxonomy == null) return references.taxonomyId;
    if (references.taxonomyId != null && !references.createEmbeddedTaxonomy) {
      return references.taxonomyId;
    }
    if (!references.createEmbeddedTaxonomy) {
      throw const FormatException('Select or create the specimen taxonomy.');
    }
    final json = RecordExchangeDatabase.without(
      Map<String, dynamic>.from(taxonomy as Map),
      {'id', 'mediaId'},
    );
    final taxon = TaxonomyData.fromJson({...json, 'id': 0});
    return dbAccess
        .into(dbAccess.taxonomy)
        .insert(
          TaxonomyCompanion.insert(
            taxonClass: db.Value(taxon.taxonClass),
            taxonOrder: db.Value(taxon.taxonOrder),
            taxonFamily: db.Value(taxon.taxonFamily),
            genus: db.Value(taxon.genus),
            specificEpithet: db.Value(taxon.specificEpithet),
            authors: db.Value(taxon.authors),
            commonName: db.Value(taxon.commonName),
            notes: db.Value(taxon.notes),
            citesStatus: db.Value(taxon.citesStatus),
            redListCategory: db.Value(taxon.redListCategory),
            countryStatus: db.Value(taxon.countryStatus),
            sortingOrder: db.Value(taxon.sortingOrder),
          ),
        );
  }

  Future<int?> _importCoordinate(
    RecordExchangePayload payload,
    int? siteId,
  ) async {
    final coordinates = RecordExchangePayload.mapList(
      payload.data['coordinates'],
    );
    if (coordinates.isEmpty) return null;
    return dbAccess
        .into(dbAccess.coordinate)
        .insert(support.coordinateCompanion(coordinates.first, siteId));
  }

  SpecimenCompanion _specimenCompanion(
    Map<String, dynamic> json,
    String uuid,
    int? eventId,
    int? taxonomyId,
    int? coordinateId,
  ) {
    final source = SpecimenData.fromJson({
      ...json,
      'condition': canonicalizeCondition(json['condition'] as String?),
      'uuid': uuid,
      'projectUuid': currentProjectUuid,
      'speciesID': taxonomyId,
      'collEventID': eventId,
      'coordinateID': coordinateId,
      'collPersonnelID': null,
    });
    return source.toCompanion(false);
  }

  Future<void> _deleteSpecimenChildren(String uuid) async {
    await SpecimenPartQuery(dbAccess).deleteAllSpecimenParts(uuid);
    await AssociatedDataQuery(dbAccess).deleteAllAssociatedData(uuid);
    await SpecimenQuery(dbAccess).deleteAllSpecimenMedias(uuid);
    await (dbAccess.delete(
      dbAccess.mammalAttribute,
    )..where((row) => row.specimenUuid.equals(uuid))).go();
    await (dbAccess.delete(
      dbAccess.birdAttribute,
    )..where((row) => row.specimenUuid.equals(uuid))).go();
    await (dbAccess.delete(
      dbAccess.herpAttribute,
    )..where((row) => row.specimenUuid.equals(uuid))).go();
  }

  Future<void> _importAttributes(
    RecordExchangePayload payload,
    String uuid,
  ) async {
    final attributes = Map<String, dynamic>.from(
      (payload.data['measurements'] as Map?)?.cast<String, dynamic>() ??
          const {},
    );
    final mammal = attributes['mammal'];
    if (mammal is Map) {
      final mammalJson = Map<String, dynamic>.from(mammal);
      if (mammalJson['weight'] != null && mammalJson['weightUnit'] == null) {
        mammalJson['weightUnit'] = 'g';
      }
      await dbAccess
          .into(dbAccess.mammalAttribute)
          .insert(
            MammalAttributeData.fromJson({
              ...mammalJson,
              'specimenUuid': uuid,
            }).toCompanion(true),
          );
    }
    final bird = attributes['avian'];
    if (bird is Map) {
      final birdJson = Map<String, dynamic>.from(bird);
      birdJson['toeColor'] ??= birdJson['footColor'];
      birdJson['toeHex'] ??= birdJson['footHex'];
      birdJson.remove('footColor');
      birdJson.remove('footHex');
      if (birdJson['weight'] != null && birdJson['weightUnit'] == null) {
        birdJson['weightUnit'] = 'g';
      }
      await dbAccess
          .into(dbAccess.birdAttribute)
          .insert(
            BirdAttributeData.fromJson({
              ...birdJson,
              'specimenUuid': uuid,
            }).toCompanion(true),
          );
    }
    final herp = attributes['herp'];
    if (herp is Map) {
      final herpJson = Map<String, dynamic>.from(herp);
      if (herpJson['weight'] != null && herpJson['weightUnit'] == null) {
        herpJson['weightUnit'] = 'g';
      }
      await dbAccess
          .into(dbAccess.herpAttribute)
          .insert(
            HerpAttributeData.fromJson({
              ...herpJson,
              'specimenUuid': uuid,
            }).toCompanion(true),
          );
    }
  }

  Future<void> _importParts(
    RecordExchangePayload payload,
    String uuid,
    Map<String, String> personnelIds,
  ) async {
    for (final json in RecordExchangePayload.mapList(payload.data['parts'])) {
      final personnelId = RecordExchangeDatabase.optionalString(
        json['personnelId'],
      );
      support.validatePersonnelReference(personnelId, personnelIds);
      await dbAccess
          .into(dbAccess.specimenPart)
          .insert(
            SpecimenPartData.fromJson({
              ...json,
              'id': null,
              'specimenUuid': uuid,
            }).toCompanion(true),
          );
    }
  }

  Future<void> _importAssociatedData(
    RecordExchangePayload payload,
    String uuid,
  ) async {
    for (final json in RecordExchangePayload.mapList(
      payload.data['associatedData'],
    )) {
      await AssociatedDataQuery(dbAccess).createSpecimenDataAssociation(
        uuid,
        AssociatedDataData.fromJson(
          support.associatedDataJson(json),
        ).toCompanion(true),
      );
    }
  }

  Future<void> _importMedia(
    RecordExchangePayload payload,
    String uuid,
    Directory? extractedMediaDirectory,
  ) async {
    if (extractedMediaDirectory == null) {
      throw const FormatException('Media archive contents are missing.');
    }
    for (final entry in RecordExchangePayload.mapList(payload.data['media'])) {
      final mediaJson = _requiredMap(entry['media'], 'media');
      final archivePath = RecordExchangeDatabase.optionalString(
        entry['archivePath'],
      );
      final normalizedPath = archivePath == null
          ? null
          : path.normalize(archivePath);
      if (archivePath == null ||
          path.isAbsolute(archivePath) ||
          normalizedPath != archivePath ||
          !archivePath.startsWith('media${path.separator}')) {
        throw const FormatException('Media archive path is invalid.');
      }
      final source = File(path.join(extractedMediaDirectory.path, archivePath));
      if (!source.existsSync()) {
        throw FormatException('Media archive file is missing: $archivePath');
      }
      final media = MediaData.fromJson({
        ...mediaJson,
        'primaryId': 0,
        'projectUuid': currentProjectUuid,
      });
      final category = media.category == null
          ? MediaCategory.specimen
          : matchMediaCategoryString(media.category!);
      final target = await MediaFinder(ref: ref).getPathForMedia(
        _uniqueMediaName(media.fileName ?? path.basename(archivePath)),
        category,
      );
      await target.parent.create(recursive: true);
      await source.copy(target.path);
      final mediaId = await dbAccess
          .into(dbAccess.media)
          .insert(
            MediaCompanion.insert(
              projectUuid: db.Value(currentProjectUuid),
              secondaryId: db.Value(media.secondaryId),
              category: db.Value(media.category),
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
      await dbAccess
          .into(dbAccess.specimenMedia)
          .insert(
            SpecimenMediaCompanion(
              specimenUuid: db.Value(uuid),
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

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    throw const FormatException('NAHPU record contains an invalid text value.');
  }
}
