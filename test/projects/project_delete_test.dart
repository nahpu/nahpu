import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  final tempAppDir = Directory.systemTemp.createTempSync(
    'nahpu-project-delete-test',
  );

  late Database db;
  late WidgetRef ref;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return tempAppDir.path;
          }
          return tempAppDir.path;
        });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempAppDir.existsSync()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('deleteProjectAndData removes all dependent records', (
    tester,
  ) async {
    ref = await _buildRef(tester, db);

    const projectUuid = 'proj-delete-1';
    await _seedProjectWithLinkedData(db, projectUuid);

    final result = await tester.runAsync(
      () => ProjectServices(ref: ref).deleteProjectAndData(projectUuid),
    );

    expect(result, isNull);
    expect(await ProjectQuery(db).getAllProjects(), isEmpty);
    expect(await SpecimenQuery(db).getAllSpecimens(projectUuid), isEmpty);
    expect(await NarrativeQuery(db).getAllNarrative(projectUuid), isEmpty);
    expect(await MediaDbQuery(db).getMediaByProject(projectUuid), isEmpty);
    expect(
      await PersonnelQuery(db).getProjectPersonnelLinks(projectUuid),
      isEmpty,
    );
  });

  testWidgets('associatedData no longer blocks project deletion', (
    tester,
  ) async {
    ref = await _buildRef(tester, db);

    const projectUuid = 'proj-delete-2';
    await _seedProjectWithLinkedData(db, projectUuid);

    final result = await tester.runAsync(
      () => ProjectServices(ref: ref).deleteProjectAndData(projectUuid),
    );

    expect(result, isNull);
    final associatedRows = await AssociatedDataQuery(
      db,
    ).getAllAssociatedData('specimen-$projectUuid');
    expect(associatedRows, isEmpty);
    expect(await ProjectQuery(db).getAllProjects(), isEmpty);
  });

  testWidgets('former blockers are deleted instead of blocking', (
    tester,
  ) async {
    ref = await _buildRef(tester, db);

    const projectUuid = 'proj-delete-3';
    await _seedProjectWithLinkedData(db, projectUuid);

    final result = await tester.runAsync(
      () => ProjectServices(ref: ref).deleteProjectAndData(projectUuid),
    );

    expect(result, isNull);
    expect(await NarrativeQuery(db).getAllNarrative(projectUuid), isEmpty);
    expect(await MediaDbQuery(db).getMediaByProject(projectUuid), isEmpty);
    expect(
      await PersonnelQuery(db).getProjectPersonnelLinks(projectUuid),
      isEmpty,
    );
  });

  testWidgets('taxonomy-linked media is preserved and detached from project', (
    tester,
  ) async {
    ref = await _buildRef(tester, db);

    const projectUuid = 'proj-delete-4';
    final seeded = await _seedProjectWithLinkedData(
      db,
      projectUuid,
      includeTaxonomyLinkedMedia: true,
    );

    final result = await tester.runAsync(
      () => ProjectServices(ref: ref).deleteProjectAndData(projectUuid),
    );

    expect(result, isNull);
    expect(await ProjectQuery(db).getAllProjects(), isEmpty);

    final taxonomyRow = await (db.select(
      db.taxonomy,
    )..where((t) => t.id.equals(seeded.taxonomyId!))).getSingleOrNull();
    expect(taxonomyRow, isNotNull);

    final preservedMedia = await MediaDbQuery(
      db,
    ).getMedia(seeded.sharedMediaId!);
    expect(preservedMedia.projectUuid, isNull);
  });
}

Future<WidgetRef> _buildRef(WidgetTester tester, Database db) async {
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
  return widgetRef!;
}

Future<({int? sharedMediaId, int? taxonomyId})> _seedProjectWithLinkedData(
  Database db,
  String projectUuid, {
  bool includeTaxonomyLinkedMedia = false,
}) async {
  await ProjectQuery(db).createProject(
    ProjectCompanion(
      uuid: Value(projectUuid),
      name: Value('Project $projectUuid'),
    ),
  );

  await PersonnelQuery(db).createPersonnel(
    PersonnelCompanion(
      uuid: Value('person-$projectUuid'),
      name: const Value('Test Person'),
    ),
  );

  await PersonnelQuery(db).createProjectPersonnelEntry(
    PersonnelListCompanion(
      projectUuid: Value(projectUuid),
      personnelUuid: Value('person-$projectUuid'),
    ),
  );

  final siteId = await db
      .into(db.site)
      .insert(SiteCompanion(projectUuid: Value(projectUuid)));

  final eventId = await db
      .into(db.collEvent)
      .insert(
        CollEventCompanion(
          projectUuid: Value(projectUuid),
          siteID: Value(siteId),
        ),
      );

  await db
      .into(db.environment)
      .insert(EnvironmentCompanion(eventID: Value(eventId)));

  final specimenUuid = 'specimen-$projectUuid';
  await SpecimenQuery(db).createSpecimen(
    SpecimenCompanion(
      uuid: Value(specimenUuid),
      projectUuid: Value(projectUuid),
      taxonGroup: const Value('General Mammals'),
      collEventID: Value(eventId),
    ),
  );

  await AssociatedDataQuery(db).createSpecimenDataAssociation(
    specimenUuid,
    AssociatedDataCompanion(
      name: const Value('Sound file'),
      uri: const Value('recording.wav'),
    ),
  );

  final mediaId = await MediaDbQuery(db).createMedia(
    MediaCompanion(
      projectUuid: Value(projectUuid),
      fileName: const Value('photo.jpg'),
      category: const Value('narrative'),
    ),
  );

  final narrativeId = await NarrativeQuery(db).createNarrative(
    NarrativeCompanion(
      projectUuid: Value(projectUuid),
      siteID: Value(siteId),
      narrative: const Value('Narrative content'),
    ),
  );

  await NarrativeQuery(db).createNarrativeMedia(
    NarrativeMediaCompanion(
      narrativeId: Value(narrativeId),
      mediaId: Value(mediaId),
    ),
  );

  if (!includeTaxonomyLinkedMedia) {
    return (sharedMediaId: null, taxonomyId: null);
  }

  final taxonomyMediaId = await MediaDbQuery(db).createMedia(
    MediaCompanion(
      projectUuid: Value(projectUuid),
      fileName: const Value('taxon-photo.jpg'),
      category: const Value('taxonomy'),
    ),
  );

  final taxonomyId = await db
      .into(db.taxonomy)
      .insert(TaxonomyCompanion(mediaId: Value(taxonomyMediaId)));

  return (sharedMediaId: taxonomyMediaId, taxonomyId: taxonomyId);
}
