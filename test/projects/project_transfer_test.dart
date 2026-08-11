import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/home/components/menu_drawer.dart';
import 'package:nahpu/screens/home/home.dart';
import 'package:nahpu/screens/projects/components/menu_drawer.dart';
import 'package:nahpu/screens/projects/project_transfer/import_project.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/projects/project_transfer_service.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final payload = _payload(
        records: {
          'site': [
            {'id': 1, 'siteID': 'Camp A', 'projectUuid': 'project-a'},
          ],
          'mammalAttribute': [
            {
              'specimenUuid': 'specimen-a',
              'accuracy': 'inaccurate:earLength,weight',
              'accuracySpecify': 'Ear damaged',
            },
          ],
        },
      );

      final decoded = ProjectTransferPayload.parse(payload.encoded);

      expect(decoded.sourceProjectUuid, 'project-a');
      expect(decoded.projectName, 'Project A');
      expect(decoded.rows('site'), hasLength(1));
      expect(
        decoded.rows('mammalAttribute').single['accuracy'],
        'inaccurate:earLength,weight',
      );
      expect(
        decoded.rows('mammalAttribute').single['accuracySpecify'],
        'Ear damaged',
      );
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

    test('normalizes legacy bird foot colors to toe colors', () {
      final decoded = ProjectTransferPayload.parse(
        jsonEncode({
          'nahpu_project': 'project',
          'version': 1,
          'project': {'uuid': 'project-a', 'name': 'Project A'},
          'records': {
            'avianMeasurement': [
              {
                'specimenUuid': 'bird',
                'footColor': 'Gray',
                'footHex': '#808080',
              },
            ],
          },
        }),
      );

      final bird = decoded.rows('birdAttribute').single;
      expect(bird['toeColor'], 'Gray');
      expect(bird['toeHex'], '#808080');
      expect(bird, isNot(contains('footColor')));
      expect(bird, isNot(contains('footHex')));
    });

    test('normalizes legacy associated-data URL fields', () {
      final decoded = ProjectTransferPayload.parse(
        jsonEncode({
          'nahpu_project': 'project',
          'version': 3,
          'project': {'uuid': 'project-a', 'name': 'Project A'},
          'records': {
            'associatedData': [
              {
                'primaryId': 1,
                'specimenUuid': 'specimen-a',
                'url': 'https://example.org/record',
              },
            ],
          },
        }),
      );

      final data = decoded.rows('associatedData').single;
      expect(data['uri'], 'https://example.org/record');
      expect(data, isNot(contains('url')));
      expect(data['specimenUuid'], 'specimen-a');
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

    testWidgets('exports arthropod attributes with project specimens', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('arthropod-a'),
              projectUuid: Value('project-a'),
              taxonGroup: Value('Arthropods'),
            ),
          );
      await database
          .into(database.arthropodAttribute)
          .insert(
            const ArthropodAttributeCompanion(
              specimenUuid: Value('arthropod-a'),
              headWidth: Value(3.25),
              dissolvedOxygen: Value(8.4),
            ),
          );

      final payload = await tester.runAsync(service.buildExport);

      expect(payload!.version, projectTransferVersion);
      expect(payload.rows('arthropodAttribute'), hasLength(1));
      expect(payload.rows('arthropodAttribute').single['headWidth'], 3.25);
      expect(payload.rows('arthropodAttribute').single['dissolvedOxygen'], 8.4);
    });

    testWidgets('exports parasite identifiers and event data links', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      await database
          .into(database.personnel)
          .insert(
            const PersonnelCompanion(
              uuid: Value('identifier'),
              name: Value('Parasite identifier'),
            ),
          );
      final parasiteTaxon = await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              taxonRank: Value('genus'),
              genus: Value('Ixodes'),
            ),
          );
      final eventId = await database
          .into(database.collEvent)
          .insert(const CollEventCompanion(projectUuid: Value('project-a')));
      await database
          .into(database.specimen)
          .insert(
            SpecimenCompanion(
              uuid: const Value('specimen-a'),
              projectUuid: const Value('project-a'),
              collEventID: Value(eventId),
            ),
          );
      await database
          .into(database.parasiteDetection)
          .insert(
            const ParasiteDetectionCompanion(
              specimenUuid: Value('specimen-a'),
              parasiteDetected: Value(1),
            ),
          );
      await database
          .into(database.parasite)
          .insert(
            ParasiteCompanion(
              specimenUuid: const Value('specimen-a'),
              speciesID: Value(parasiteTaxon),
              identifierID: const Value('identifier'),
              parasiteID: const Value('P-1'),
              parasiteUuid: const Value('parasite-uuid'),
            ),
          );
      final dataId = await database
          .into(database.associatedData)
          .insert(
            const AssociatedDataCompanion(
              projectUuid: Value('project-a'),
              name: Value('Event data'),
            ),
          );
      await database
          .into(database.eventAssociatedData)
          .insert(
            EventAssociatedDataCompanion(
              eventID: Value(eventId),
              associatedDataId: Value(dataId),
            ),
          );

      final payload = await tester.runAsync(service.buildExport);

      expect(payload!.rows('parasite'), hasLength(1));
      expect(payload.rows('parasite').single['identifierID'], 'identifier');
      expect(payload.rows('personnel').single['uuid'], 'identifier');
      expect(payload.rows('taxonomy').single['genus'], 'Ixodes');
      expect(payload.rows('eventAssociatedData'), hasLength(1));
      expect(payload.rows('eventAssociatedData').single['eventID'], eventId);
    });

    testWidgets('export survives disposal of its originating widget', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      final payload = await tester.runAsync(service.buildExport);

      expect(payload!.sourceProjectUuid, 'project-a');
      expect(payload.projectName, 'Project A');
    });

    testWidgets('exports shared specimen and site associated-data links', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('specimen-a'),
              projectUuid: Value('project-a'),
            ),
          );
      final siteId = await database
          .into(database.site)
          .insert(const SiteCompanion(projectUuid: Value('project-a')));
      final query = AssociatedDataQuery(database);
      final dataId = await query.createSpecimenDataAssociation(
        'specimen-a',
        const AssociatedDataCompanion(name: Value('Recording')),
      );
      await query.linkToSite(dataId, siteId);

      final payload = await tester.runAsync(service.buildExport);

      expect(payload!.version, projectTransferVersion);
      expect(payload.rows('associatedData'), hasLength(1));
      expect(payload.rows('specimenAssociatedData'), hasLength(1));
      expect(payload.rows('siteAssociatedData'), hasLength(1));
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

    testWidgets('new-project import rejects an existing project UUID', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);

      await expectLater(
        service.planImport(
          _payload(),
          mode: ProjectTransferImportMode.newProject,
        ),
        throwsA(isA<ProjectTransferProjectExistsException>()),
      );
    });

    testWidgets(
      'new-project import detects normalized names and accepts a rename',
      (tester) async {
        await setUpService(tester);
        addTearDown(database.close);
        final payload = _payload(
          projectUuid: 'project-b',
          projectName: ' project a ',
        );
        final plan = await service.planImport(
          payload,
          mode: ProjectTransferImportMode.newProject,
        );
        expect(plan.nameConflict?.uuid, 'project-a');

        final extraction = Directory.systemTemp.createTempSync(
          'nahpu-transfer-test-',
        );
        addTearDown(() {
          if (extraction.existsSync()) extraction.deleteSync(recursive: true);
        });
        Object? blockedError;
        await tester.runAsync(() async {
          try {
            await service.importProject(
              plan,
              forceMerge: false,
              conflictActions: const {},
              importedProjectFields: const {},
              extractedDirectory: extraction,
            );
          } catch (error) {
            blockedError = error;
          }
        });
        expect(blockedError, isA<FormatException>());
        expect(
          await (database.select(
            database.project,
          )..where((row) => row.uuid.equals('project-b'))).get(),
          isEmpty,
        );
        await tester.runAsync(
          () => service.importProject(
            plan,
            forceMerge: false,
            conflictActions: const {},
            importedProjectFields: const {},
            extractedDirectory: extraction,
            destinationProjectName: 'Project B',
          ),
        );

        final imported = await (database.select(
          database.project,
        )..where((row) => row.uuid.equals('project-b'))).getSingle();
        expect(imported.name, 'Project B');
      },
    );

    testWidgets('new-project import creates project-scoped records', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      await database
          .into(database.personnel)
          .insert(
            const PersonnelCompanion(
              uuid: Value('person-1'),
              name: Value('Current person'),
            ),
          );
      final taxonId = await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Myotis'),
              specificEpithet: Value('lucifugus'),
            ),
          );
      final payload = _payload(
        projectUuid: 'project-b',
        projectName: 'Project B',
        records: {
          'personnel': [
            {'uuid': 'person-1', 'name': 'Imported person'},
          ],
          'taxonomy': [
            {'id': 20, 'genus': 'myotis', 'specificEpithet': 'Lucifugus'},
          ],
          'site': [
            {
              'id': 8,
              'siteID': 'Remote camp',
              'projectUuid': 'project-b',
              'leadStaffId': 'person-1',
            },
          ],
          'collEvent': [
            {'id': 9, 'projectUuid': 'project-b', 'siteID': 8},
          ],
          'specimen': [
            {
              'uuid': 'remote-specimen',
              'projectUuid': 'project-b',
              'collEventID': 9,
              'speciesID': 20,
            },
          ],
          'narrative': [
            {'id': 10, 'projectUuid': 'project-b', 'siteID': 8},
          ],
        },
      );
      final plan = await service.planImport(
        payload,
        mode: ProjectTransferImportMode.newProject,
      );
      final extraction = Directory.systemTemp.createTempSync(
        'nahpu-transfer-test-',
      );
      addTearDown(() {
        if (extraction.existsSync()) extraction.deleteSync(recursive: true);
      });

      await tester.runAsync(
        () => service.importProject(
          plan,
          forceMerge: false,
          conflictActions: const {},
          importedProjectFields: const {},
          extractedDirectory: extraction,
        ),
      );

      expect(
        (await database.select(database.site).get()).single.projectUuid,
        'project-b',
      );
      expect(
        (await database.select(database.collEvent).get()).single.projectUuid,
        'project-b',
      );
      final specimen = await database.select(database.specimen).getSingle();
      expect(specimen.projectUuid, 'project-b');
      expect(specimen.speciesID, taxonId);
      expect(
        (await database.select(database.narrative).get()).single.projectUuid,
        'project-b',
      );
      final links = await database.select(database.personnelList).get();
      expect(
        links.any(
          (link) =>
              link.projectUuid == 'project-b' &&
              link.personnelUuid == 'person-1',
        ),
        isTrue,
      );
    });

    testWidgets('new-project import regenerates conflicting specimen UUIDs', (
      tester,
    ) async {
      await setUpService(tester);
      addTearDown(database.close);
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('shared-specimen'),
              projectUuid: Value('project-a'),
            ),
          );
      final payload = _payload(
        projectUuid: 'project-b',
        projectName: 'Project B',
        records: {
          'specimen': [
            {'uuid': 'shared-specimen', 'projectUuid': 'project-b'},
          ],
        },
      );
      final plan = await service.planImport(
        payload,
        mode: ProjectTransferImportMode.newProject,
      );
      final conflict = plan.conflicts.single;
      expect(conflict.allowedActions, [
        ProjectTransferConflictAction.importAsNew,
        ProjectTransferConflictAction.skip,
      ]);
      final extraction = Directory.systemTemp.createTempSync(
        'nahpu-transfer-test-',
      );
      addTearDown(() {
        if (extraction.existsSync()) extraction.deleteSync(recursive: true);
      });

      await tester.runAsync(
        () => service.importProject(
          plan,
          forceMerge: false,
          conflictActions: const {},
          importedProjectFields: const {},
          extractedDirectory: extraction,
        ),
      );

      final imported = await (database.select(
        database.specimen,
      )..where((row) => row.projectUuid.equals('project-b'))).getSingle();
      expect(imported.uuid, isNot('shared-specimen'));
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

    testWidgets('force merge remaps associated-data links', (tester) async {
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
          'specimen': [
            {'uuid': 'remote-specimen', 'projectUuid': 'project-from-device-b'},
          ],
          'associatedData': [
            {
              'primaryId': 5,
              'projectUuid': 'project-from-device-b',
              'name': 'Recording',
            },
          ],
          'specimenAssociatedData': [
            {'specimenUuid': 'remote-specimen', 'associatedDataId': 5},
          ],
          'siteAssociatedData': [
            {'siteId': 8, 'associatedDataId': 5},
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

      final data = await database.select(database.associatedData).getSingle();
      expect(data.projectUuid, 'project-a');
      expect(data.name, 'Recording');
      expect(
        await database.select(database.specimenAssociatedData).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.siteAssociatedData).get(),
        hasLength(1),
      );
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
    expect(find.text('Create project'), findsNothing);
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

  testWidgets('wide transfer wizards use the rounded themed step rail', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);

    for (final screen in <Widget>[
      const ImportProjectScreen(),
      const ImportProjectScreen.newProject(),
    ]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(home: screen),
        ),
      );
      await tester.pump();

      final rail = tester.widget<Container>(
        find.byKey(const ValueKey('project-transfer-step-rail')),
      );
      final decoration = rail.decoration! as BoxDecoration;
      final theme = Theme.of(
        tester.element(
          find.byKey(const ValueKey('project-transfer-step-rail')),
        ),
      );
      final firstStep = tester.widget<ListTile>(find.byType(ListTile).first);

      expect(decoration.borderRadius, BorderRadius.circular(NahpuRadius.large));
      expect(decoration.border, isA<Border>());
      expect(find.byType(VerticalDivider), findsNothing);
      expect(firstStep.selectedTileColor, theme.colorScheme.primaryContainer);
      expect(firstStep.selectedColor, theme.colorScheme.onPrimaryContainer);
    }
  });

  testWidgets('compact transfer wizard keeps horizontal step chips', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: ImportProjectScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(ChoiceChip), findsWidgets);
    expect(
      find.byKey(const ValueKey('project-transfer-step-rail')),
      findsNothing,
    );
  });

  testWidgets('home menu exposes project creation and import', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(drawer: HomeMenuDrawer())),
    );
    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffold.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Create project'), findsOneWidget);
    expect(find.text('Import project'), findsOneWidget);
  });

  testWidgets('home speed dial exposes project creation and import', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: Home()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SpeedDial));
    await tester.pumpAndSettle();

    expect(find.text('New project'), findsOneWidget);
    expect(find.text('Import project'), findsOneWidget);
  });

  testWidgets('new-project import uses the focused conflict wizard', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: ImportProjectScreen.newProject()),
      ),
    );
    await tester.pump();

    expect(find.text('Import project'), findsOneWidget);
    expect(find.text('Back up before importing'), findsOneWidget);
    expect(find.text('Sites'), findsNothing);
    expect(find.text('Events'), findsNothing);
    expect(find.text('Narratives'), findsNothing);
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
