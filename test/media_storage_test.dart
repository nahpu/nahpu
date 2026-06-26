import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/import/multimedia.dart';

void main() {
  late Database db;

  setUp(() {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  test('stores non-image narrative media and join row', () async {
    const projectUuid = 'proj-narrative-media';
    final narrativeId = await _seedNarrative(db, projectUuid);
    final sourceFile = await _createTempFile('narrative-audio.mp3', [1, 2, 3]);
    addTearDown(() async => _safeDelete(sourceFile));

    final mediaId = await _insertNarrativeMedia(
        db, projectUuid, narrativeId, sourceFile.path);

    final mediaRows = await MediaDbQuery(db).getMediaByProject(projectUuid);
    expect(mediaRows, hasLength(1));
    final media = mediaRows.single;
    expect(media.primaryId, mediaId);
    expect(media.fileName, 'narrative-audio.mp3');
    expect(media.category, 'narrative');
    expect(media.taken, isEmpty);
    expect(media.camera, isEmpty);
    expect(media.lenses, isEmpty);
    expect(media.additionalExif ?? '', contains('Type: Audio'));

    final links = await NarrativeQuery(db).getNarrativeMedia(narrativeId);
    expect(links, hasLength(1));
    expect(links.single.mediaId, mediaId);
  });

  test('stores non-image site media and join row', () async {
    const projectUuid = 'proj-site-media';
    final siteId = await _seedSite(db, projectUuid);
    final sourceFile = await _createTempFile('site-video.mp4', [4, 5, 6, 7]);
    addTearDown(() async => _safeDelete(sourceFile));

    final mediaId =
        await _insertSiteMedia(db, projectUuid, siteId, sourceFile.path);

    final mediaRows = await MediaDbQuery(db).getMediaByProject(projectUuid);
    expect(mediaRows, hasLength(1));
    final media = mediaRows.single;
    expect(media.primaryId, mediaId);
    expect(media.fileName, 'site-video.mp4');
    expect(media.category, 'site');
    expect(media.taken, isEmpty);
    expect(media.camera, isEmpty);
    expect(media.lenses, isEmpty);
    expect(media.additionalExif ?? '', contains('Type: Video'));

    final links = await SiteQuery(db).getSiteMedia(siteId);
    expect(links, hasLength(1));
    expect(links.single.mediaId, mediaId);
  });

  test('stores non-image specimen media and join row', () async {
    const projectUuid = 'proj-specimen-media';
    final specimenUuid = await _seedSpecimen(db, projectUuid);
    final sourceFile = await _createTempFile('specimen-doc.pdf', [8, 9, 10]);
    addTearDown(() async => _safeDelete(sourceFile));

    final mediaId = await _insertSpecimenMedia(
        db, projectUuid, specimenUuid, sourceFile.path);

    final mediaRows = await MediaDbQuery(db).getMediaByProject(projectUuid);
    expect(mediaRows, hasLength(1));
    final media = mediaRows.single;
    expect(media.primaryId, mediaId);
    expect(media.fileName, 'specimen-doc.pdf');
    expect(media.category, 'specimen');
    expect(media.taken, isEmpty);
    expect(media.camera, isEmpty);
    expect(media.lenses, isEmpty);
    expect(media.additionalExif ?? '', contains('Type: PDF'));

    final links = await SpecimenQuery(db).getSpecimenMedia(specimenUuid);
    expect(links, hasLength(1));
    expect(links.single.mediaId, mediaId);
  });
}

Future<int> _insertNarrativeMedia(
  Database db,
  String projectUuid,
  int narrativeId,
  String filePath,
) async {
  final metadata = await MediaMetadataServices().extract(File(filePath));
  final mediaId = await MediaDbQuery(db).createMedia(MediaCompanion(
    projectUuid: Value(projectUuid),
    fileName: Value(_basename(filePath)),
    category: const Value('narrative'),
    taken: Value(metadata.taken),
    camera: Value(metadata.camera),
    lenses: Value(metadata.lenses),
    additionalExif: Value(metadata.additionalExif),
  ));
  await NarrativeQuery(db).createNarrativeMedia(
    NarrativeMediaCompanion(
      narrativeId: Value(narrativeId),
      mediaId: Value(mediaId),
    ),
  );
  return mediaId;
}

Future<int> _insertSiteMedia(
  Database db,
  String projectUuid,
  int siteId,
  String filePath,
) async {
  final metadata = await MediaMetadataServices().extract(File(filePath));
  final mediaId = await MediaDbQuery(db).createMedia(MediaCompanion(
    projectUuid: Value(projectUuid),
    fileName: Value(_basename(filePath)),
    category: const Value('site'),
    taken: Value(metadata.taken),
    camera: Value(metadata.camera),
    lenses: Value(metadata.lenses),
    additionalExif: Value(metadata.additionalExif),
  ));
  await SiteQuery(db).createSiteMedia(
    SiteMediaCompanion(
      siteId: Value(siteId),
      mediaId: Value(mediaId),
    ),
  );
  return mediaId;
}

Future<int> _insertSpecimenMedia(
  Database db,
  String projectUuid,
  String specimenUuid,
  String filePath,
) async {
  final metadata = await MediaMetadataServices().extract(File(filePath));
  final mediaId = await MediaDbQuery(db).createMedia(MediaCompanion(
    projectUuid: Value(projectUuid),
    fileName: Value(_basename(filePath)),
    category: const Value('specimen'),
    taken: Value(metadata.taken),
    camera: Value(metadata.camera),
    lenses: Value(metadata.lenses),
    additionalExif: Value(metadata.additionalExif),
  ));
  await SpecimenQuery(db).createSpecimenMedia(
    SpecimenMediaCompanion(
      specimenUuid: Value(specimenUuid),
      mediaId: Value(mediaId),
    ),
  );
  return mediaId;
}

Future<int> _seedSite(Database db, String projectUuid) async {
  await ProjectQuery(db).createProject(ProjectCompanion(
    uuid: Value(projectUuid),
    name: Value('Project $projectUuid'),
  ));
  return db
      .into(db.site)
      .insert(SiteCompanion(projectUuid: Value(projectUuid)));
}

Future<int> _seedNarrative(Database db, String projectUuid) async {
  final siteId = await _seedSite(db, projectUuid);
  return NarrativeQuery(db).createNarrative(
    NarrativeCompanion(
      projectUuid: Value(projectUuid),
      siteID: Value(siteId),
      narrative: const Value('A narrative'),
    ),
  );
}

Future<String> _seedSpecimen(Database db, String projectUuid) async {
  final siteId = await _seedSite(db, projectUuid);
  final eventId = await db.into(db.collEvent).insert(
        CollEventCompanion(
          projectUuid: Value(projectUuid),
          siteID: Value(siteId),
        ),
      );

  const specimenUuid = 'specimen-media-1';
  await SpecimenQuery(db).createSpecimen(
    SpecimenCompanion(
      uuid: const Value(specimenUuid),
      projectUuid: Value(projectUuid),
      taxonGroup: const Value('General Mammals'),
      collEventID: Value(eventId),
    ),
  );
  return specimenUuid;
}

Future<File> _createTempFile(String fileName, List<int> bytes) async {
  final dir = await Directory.systemTemp.createTemp('nahpu-media-storage-src');
  final file = File('${dir.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes);
  return file;
}

Future<void> _safeDelete(File file) async {
  final dir = file.parent;
  if (dir.existsSync()) {
    await dir.delete(recursive: true);
  }
}

String _basename(String filePath) =>
    filePath.split(Platform.pathSeparator).last;
