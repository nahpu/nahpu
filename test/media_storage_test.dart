import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/specimen_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late Directory tempAppDir;
  late Database db;

  setUp(() {
    tempAppDir =
        Directory.systemTemp.createTempSync('nahpu-media-storage-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async {
      return tempAppDir.path;
    });
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (tempAppDir.existsSync()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  testWidgets('stores non-image narrative media and join row', (tester) async {
    const projectUuid = 'proj-narrative-media';
    final ref = await _buildRef(tester, db, projectUuid);
    final narrativeId = await _seedNarrative(db, projectUuid);
    final sourceFile = _createTempFile('narrative-audio.mp3', [1, 2, 3]);
    addTearDown(() => _safeDelete(sourceFile));

    await tester.runAsync(() => NarrativeServices(ref: ref)
        .createNarrativeMediaFromList(narrativeId, [sourceFile.path]));

    final mediaRows = await MediaDbQuery(db).getMediaByProject(projectUuid);
    expect(mediaRows, hasLength(1));
    final media = mediaRows.single;
    expect(media.fileName, 'narrative-audio.mp3');
    expect(media.category, 'narrative');
    expect(media.taken, isEmpty);
    expect(media.camera, isEmpty);
    expect(media.lenses, isEmpty);
    expect(media.additionalExif ?? '', contains('Type: Audio'));

    final links = await NarrativeQuery(db).getNarrativeMedia(narrativeId);
    expect(links, hasLength(1));
    expect(links.single.mediaId, media.primaryId);
  });

  testWidgets('stores non-image site media and join row', (tester) async {
    const projectUuid = 'proj-site-media';
    final ref = await _buildRef(tester, db, projectUuid);
    final siteId = await _seedSite(db, projectUuid);
    final sourceFile = _createTempFile('site-video.mp4', [4, 5, 6, 7]);
    addTearDown(() => _safeDelete(sourceFile));

    await tester.runAsync(
        () => SiteServices(ref: ref).createSiteMedia(siteId, sourceFile.path));

    final mediaRows = await MediaDbQuery(db).getMediaByProject(projectUuid);
    expect(mediaRows, hasLength(1));
    final media = mediaRows.single;
    expect(media.fileName, 'site-video.mp4');
    expect(media.category, 'site');
    expect(media.taken, isEmpty);
    expect(media.camera, isEmpty);
    expect(media.lenses, isEmpty);
    expect(media.additionalExif ?? '', contains('Type: Video'));

    final links = await SiteQuery(db).getSiteMedia(siteId);
    expect(links, hasLength(1));
    expect(links.single.mediaId, media.primaryId);
  });

  testWidgets('stores non-image specimen media and join row', (tester) async {
    const projectUuid = 'proj-specimen-media';
    final ref = await _buildRef(tester, db, projectUuid);
    final specimenUuid = await _seedSpecimen(db, projectUuid);
    final sourceFile = _createTempFile('specimen-doc.pdf', [8, 9, 10]);
    addTearDown(() => _safeDelete(sourceFile));

    await tester.runAsync(() => SpecimenServices(ref: ref)
        .createSpecimenMediaFromList(specimenUuid, [sourceFile.path]));

    final mediaRows = await MediaDbQuery(db).getMediaByProject(projectUuid);
    expect(mediaRows, hasLength(1));
    final media = mediaRows.single;
    expect(media.fileName, 'specimen-doc.pdf');
    expect(media.category, 'specimen');
    expect(media.taken, isEmpty);
    expect(media.camera, isEmpty);
    expect(media.lenses, isEmpty);
    expect(media.additionalExif ?? '', contains('Type: Other'));

    final links = await SpecimenQuery(db).getSpecimenMedia(specimenUuid);
    expect(links, hasLength(1));
    expect(links.single.mediaId, media.primaryId);
  });
}

Future<WidgetRef> _buildRef(
  WidgetTester tester,
  Database db,
  String projectUuid,
) async {
  WidgetRef? widgetRef;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, child) {
            widgetRef = ref;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );

  await tester.pump();
  widgetRef!.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);
  return widgetRef!;
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

File _createTempFile(String fileName, List<int> bytes) {
  final dir = Directory.systemTemp.createTempSync('nahpu-media-storage-src');
  final file = File('${dir.path}${Platform.pathSeparator}$fileName');
  file.writeAsBytesSync(bytes);
  return file;
}

void _safeDelete(File file) {
  final dir = file.parent;
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}
