import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/menu_drawer.dart';
import 'package:nahpu/screens/projects/project_transfer/import_project.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/project_transfer/project_transfer_service.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempAppDirectory;

  setUp(() {
    tempAppDirectory = Directory.systemTemp.createTempSync(
      'nahpu-project-transfer-test-',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return tempAppDirectory.path;
          }
          if (call.method == 'getTemporaryDirectory') {
            return Directory.systemTemp.path;
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempAppDirectory.existsSync()) {
      await tempAppDirectory.delete(recursive: true);
    }
  });

  group('ProjectTransferPayload', () {
    test('round-trips the versioned project envelope', () {
      final payload = _payload();

      final decoded = ProjectTransferPayload.parse(payload.encoded);

      expect(decoded.sourceProjectUuid, 'project-a');
      expect(decoded.projectName, 'Project A');
      expect(decoded.rows('site'), hasLength(1));
      expect(decoded.version, projectTransferVersion);
    });

    test('normalizes version 1 measurement collections', () {
      final decoded = ProjectTransferPayload.parse(
        jsonEncode({
          'nahpu_project': 'project',
          'version': 1,
          'project': {'uuid': 'project-a', 'name': 'Project A'},
          'records': {
            'mammalMeasurement': [
              {'specimenUuid': 'mammal', 'weight': 12.5},
            ],
            'avianMeasurement': [
              {'specimenUuid': 'bird', 'wingspan': 42.0},
            ],
            'herpMeasurement': [
              {'specimenUuid': 'herp', 'svl': 7.5},
            ],
          },
        }),
      );

      expect(decoded.rows('mammalAttribute').single['weight'], 12.5);
      expect(decoded.rows('birdAttribute').single['wingspan'], 42.0);
      expect(decoded.rows('herpAttribute').single['svl'], 7.5);
      expect(decoded.records, isNot(contains('mammalMeasurement')));
      expect(decoded.records, isNot(contains('avianMeasurement')));
      expect(decoded.records, isNot(contains('herpMeasurement')));
    });

    test('rejects conflicting legacy and canonical collections', () {
      expect(
        () => ProjectTransferPayload.parse(
          jsonEncode({
            'nahpu_project': 'project',
            'version': 2,
            'project': {'uuid': 'project-a', 'name': 'Project A'},
            'records': {
              'mammalMeasurement': [
                {'specimenUuid': 'legacy'},
              ],
              'mammalAttribute': [
                {'specimenUuid': 'canonical'},
              ],
            },
          }),
        ),
        throwsFormatException,
      );
    });

    test('light encoding excludes media and clears media references', () {
      final payload = ProjectTransferPayload(
        exportedAt: '2026-07-23T12:00:00Z',
        appVersion: '1.0.0+36',
        databaseVersion: kSchemaVersion,
        project: const {'uuid': 'project-a', 'name': 'Project A'},
        records: {
          'personnel': [
            {'uuid': 'person-1', 'photoPath': 'person.jpg'},
          ],
          'taxonomy': [
            {'id': 1, 'mediaId': 4},
          ],
          'site': [
            {'id': 1, 'mediaID': '4'},
          ],
          'narrative': [
            {'id': 1, 'mediaID': 4},
          ],
          'media': [
            {'primaryId': 4, 'fileName': 'site.jpg'},
          ],
          'siteMedia': [
            {'siteId': 1, 'mediaId': 4},
          ],
          'personnelPhoto': [
            {'personnelUuid': 'person-1'},
          ],
        },
        mediaFiles: [
          const ProjectTransferMediaFile(
            sourceId: 'media:4',
            kind: 'site',
            archivePath: 'media/4-site.jpg',
            originalFileName: 'site.jpg',
          ),
        ],
      );

      final decoded =
          jsonDecode(payload.encodedWithoutMedia) as Map<String, dynamic>;
      final records = decoded['records'] as Map<String, dynamic>;

      expect(records.keys, isNot(contains('media')));
      expect(records.keys, isNot(contains('siteMedia')));
      expect(records.keys, isNot(contains('personnelPhoto')));
      expect(decoded['media'], isEmpty);
      expect((records['personnel'] as List).single['photoPath'], isNull);
      expect((records['taxonomy'] as List).single['mediaId'], isNull);
      expect((records['site'] as List).single['mediaID'], isNull);
      expect((records['narrative'] as List).single['mediaID'], isNull);

      final parsed = ProjectTransferPayload.parse(payload.encodedWithoutMedia);
      expect(parsed.mediaFiles, isEmpty);
      expect(parsed.rows('media'), isEmpty);
    });

    test('rejects bundle records and unsupported versions', () {
      expect(
        () => ProjectTransferPayload.parse(
          jsonEncode({
            'nahpu_project': 'records',
            'version': 1,
            'project': {'uuid': 'a', 'name': 'A'},
            'records': <String, dynamic>{},
          }),
        ),
        throwsFormatException,
      );
      expect(
        () => ProjectTransferPayload.parse(
          jsonEncode({
            'nahpu_project': 'project',
            'version': 99,
            'project': {'uuid': 'a', 'name': 'A'},
            'records': <String, dynamic>{},
          }),
        ),
        throwsFormatException,
      );
    });

    test('rejects unsafe archive paths', () {
      final json = _payload().toJson();
      json['media'] = [
        {
          'sourceId': 'media:1',
          'kind': 'site',
          'archivePath': '../outside.jpg',
          'originalFileName': 'outside.jpg',
        },
      ];

      expect(
        () => ProjectTransferPayload.parse(jsonEncode(json)),
        throwsFormatException,
      );
    });
  });

  group('ProjectTransferService', () {
    late Database database;
    late WidgetRef widgetRef;
    late ProjectTransferService service;

    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'NAHPU',
        packageName: 'org.nahpu.app',
        version: '1.0.0',
        buildNumber: '36',
        buildSignature: '',
      );
    });

    Future<void> setUpService(WidgetTester tester) async {
      database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      WidgetRef? capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();
      widgetRef = capturedRef!;
      widgetRef
          .read(projectUuidProvider.notifier)
          .updateProjectUuid('project-a');
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project-a'),
              name: Value('Project A'),
            ),
          );
      service = ProjectTransferService(ref: widgetRef);
    }

    testWidgets('exports only taxonomy referenced by active specimens', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      final usedTaxon = await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Myotis'),
              specificEpithet: Value('lucifugus'),
            ),
          );
      await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Unused'),
              specificEpithet: Value('taxon'),
            ),
          );
      await database
          .into(database.specimen)
          .insert(
            SpecimenCompanion(
              uuid: const Value('specimen-a'),
              projectUuid: const Value('project-a'),
              speciesID: Value(usedTaxon),
            ),
          );

      final payload = await tester.runAsync(service.buildExport);

      expect(payload!.rows('taxonomy'), hasLength(1));
      expect(payload.rows('taxonomy').single['genus'], 'Myotis');
      expect(payload.rows('specimen'), hasLength(1));
    });

    testWidgets('finds normalized taxonomy and cross-project UUID conflicts', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Myotis'),
              specificEpithet: Value('Lucifugus'),
            ),
          );
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project-b'),
              name: Value('Project B'),
            ),
          );
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('shared-specimen'),
              projectUuid: Value('project-b'),
            ),
          );
      final payload = _payload(
        records: {
          'taxonomy': [
            {'id': 10, 'genus': ' myotis ', 'specificEpithet': 'lucifugus'},
          ],
          'specimen': [
            {
              'uuid': 'shared-specimen',
              'projectUuid': 'project-a',
              'speciesID': 10,
            },
          ],
        },
      );

      final plan = await service.planImport(payload);
      final taxonConflict = plan.conflicts.singleWhere(
        (conflict) => conflict.section == ProjectTransferSection.taxonomy,
      );
      final specimenConflict = plan.conflicts.singleWhere(
        (conflict) => conflict.section == ProjectTransferSection.specimens,
      );

      expect(taxonConflict.warning, contains('shared across projects'));
      expect(specimenConflict.allowedActions, [
        ProjectTransferConflictAction.importAsNew,
        ProjectTransferConflictAction.skip,
      ]);
    });

    testWidgets('blocks UUID mismatch unless force merge is enabled', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      final plan = await service.planImport(
        _payload(projectUuid: 'project-from-device-b'),
      );
      final extraction = Directory.systemTemp.createTempSync(
        'nahpu-transfer-test-',
      );
      addTearDown(() {
        if (extraction.existsSync()) extraction.deleteSync(recursive: true);
      });

      await tester.runAsync(
        () => expectLater(
          service.importProject(
            plan,
            forceMerge: false,
            conflictActions: const {},
            importedProjectFields: const {},
            extractedDirectory: extraction,
          ),
          throwsFormatException,
        ),
      );
    });

    testWidgets('force merge assigns the active project UUID', (tester) async {
      await setUpService(tester);
      addTearDown(database.close);
      final payload = _payload(
        projectUuid: 'project-from-device-b',
        records: {
          'site': [
            {
              'id': 8,
              'siteID': 'Remote camp',
              'projectUuid': 'project-from-device-b',
            },
          ],
        },
      );
      final plan = await service.planImport(payload);
      final extraction = Directory.systemTemp.createTempSync(
        'nahpu-transfer-test-',
      );
      addTearDown(() {
        if (extraction.existsSync()) extraction.deleteSync(recursive: true);
      });

      await tester.runAsync(
        () => service.importProject(
          plan,
          forceMerge: true,
          conflictActions: const {},
          importedProjectFields: const {},
          extractedDirectory: extraction,
        ),
      );

      final importedSite = await database.select(database.site).getSingle();
      expect(importedSite.siteID, 'Remote camp');
      expect(importedSite.projectUuid, 'project-a');
    });

    testWidgets('rolls back all database writes when final import fails', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project-b'),
              name: Value('Duplicate name'),
            ),
          );
      final payload = _payload(
        projectName: 'Duplicate name',
        records: {
          'site': [
            {'id': 8, 'siteID': 'Should roll back', 'projectUuid': 'project-a'},
          ],
        },
      );
      final plan = await service.planImport(payload);
      final extraction = Directory.systemTemp.createTempSync(
        'nahpu-transfer-test-',
      );
      addTearDown(() {
        if (extraction.existsSync()) extraction.deleteSync(recursive: true);
      });

      Object? importError;
      await tester.runAsync(() async {
        try {
          await service.importProject(
            plan,
            forceMerge: false,
            conflictActions: const {},
            importedProjectFields: const {'name': true},
            extractedDirectory: extraction,
          );
        } catch (error) {
          importError = error;
        }
      });
      expect(importError, isNotNull);

      final active = await (database.select(
        database.project,
      )..where((row) => row.uuid.equals('project-a'))).getSingle();
      expect(active.name, 'Project A');
      expect(await database.select(database.site).get(), isEmpty);
    });
  });

  testWidgets('project menu distinguishes transfers from record bundles', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    container.read(projectUuidProvider.notifier).updateProjectUuid('project-a');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(drawer: ProjectMenuDrawer())),
      ),
    );
    await tester.pump();
    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffold.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Merge project'), findsOneWidget);
    expect(find.text('Export project'), findsOneWidget);
    expect(find.text('Bundle records'), findsOneWidget);
    expect(find.text('Bundle project'), findsNothing);
  });

  testWidgets('import wizard requires file and backup acknowledgment', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: ImportProjectScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Merge project'), findsOneWidget);
    expect(find.text('Back up before merging'), findsOneWidget);
    expect(find.text('Back up before importing'), findsNothing);
    expect(find.text('Back up now'), findsOneWidget);
    final continueButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);
  });
}

ProjectTransferPayload _payload({
  String projectUuid = 'project-a',
  String projectName = 'Project A',
  Map<String, List<Map<String, dynamic>>>? records,
}) {
  return ProjectTransferPayload(
    exportedAt: '2026-07-23T12:00:00Z',
    appVersion: '1.0.0+36',
    databaseVersion: kSchemaVersion,
    project: {'uuid': projectUuid, 'name': projectName},
    records:
        records ??
        {
          'site': [
            {'id': 1, 'siteID': 'Camp A', 'projectUuid': projectUuid},
          ],
        },
  );
}
