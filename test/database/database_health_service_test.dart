import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/database_health/database_health_service.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempAppDirectory;
  late Database database;
  late DatabaseHealthService service;

  setUp(() {
    tempAppDirectory = Directory.systemTemp.createTempSync(
      'nahpu-database-health-test-',
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

  Future<void> setUpService(WidgetTester tester) async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
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
    capturedRef!.read(projectUuidProvider.notifier).updateProjectUuid('proj-a');
    for (final (uuid, name) in [('proj-a', 'Project A'), ('proj-b', 'B')]) {
      await database
          .into(database.project)
          .insert(ProjectCompanion(uuid: Value(uuid), name: Value(name)));
    }
    service = DatabaseHealthService(ref: capturedRef!);
  }

  /// Runs [action] with foreign keys off, the way legacy data got broken.
  Future<void> withoutForeignKeys(Future<void> Function() action) async {
    await database.customStatement('PRAGMA foreign_keys = OFF');
    await action();
    await database.customStatement('PRAGMA foreign_keys = ON');
  }

  Future<HealthReport> scan(WidgetTester tester) async =>
      (await tester.runAsync(service.scan))!;

  testWidgets('a clean database has no issues', (tester) async {
    await setUpService(tester);
    addTearDown(database.close);
    final siteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('proj-a')));
    await database
        .into(database.collEvent)
        .insert(
          CollEventCompanion(
            projectUuid: const Value('proj-a'),
            siteID: Value(siteId),
          ),
        );

    final report = await scan(tester);

    expect(report.isHealthy, isTrue);
  });

  testWidgets('a specimen pointing at a deleted taxon is cleared', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(database.close);
    await withoutForeignKeys(() async {
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('spec-1'),
              projectUuid: Value('proj-a'),
              fieldNumber: Value(42),
              speciesID: Value(999),
            ),
          );
    });

    final report = await scan(tester);

    final issue = report.issues.single;
    expect(issue.kind, HealthIssueKind.brokenLink);
    expect(issue.severity, HealthSeverity.error);
    expect(issue.table, 'specimen');
    expect(issue.parentTable, 'taxonomy');
    expect(issue.columns, ['speciesID']);
    expect(issue.recordLabel, '42');
    expect(issue.fix, HealthFixAction.clearLink);
    expect(issue.target?.type, DataTableRecordType.specimenRecords);
    expect(issue.target?.keys, {'spec-1'});

    final result = await tester.runAsync(
      () => service.applyFixes(report.issues, backup: true),
    );

    expect(result!.fixed, 1);
    expect(result.failed, isEmpty);
    expect(result.backup!.existsSync(), isTrue);
    expect(
      p.dirname(result.backup!.path),
      p.join(tempAppDirectory.path, 'nahpu', 'backup'),
    );
    final specimen = await (database.select(
      database.specimen,
    )..where((t) => t.uuid.equals('spec-1'))).getSingle();
    expect(specimen.speciesID, isNull);
    expect((await scan(tester)).isHealthy, isTrue);
  });

  testWidgets('an orphan attribute row is removed', (tester) async {
    await setUpService(tester);
    addTearDown(database.close);
    await withoutForeignKeys(() async {
      await database
          .into(database.siteAttribute)
          .insert(const SiteAttributeCompanion(siteID: Value(77)));
    });

    final report = await scan(tester);

    final issue = report.issues.single;
    expect(issue.parentTable, 'site');
    expect(issue.fix, HealthFixAction.removeRow);
    expect(issue.target, isNull);

    await tester.runAsync(
      () => service.applyFixes(report.issues, backup: false),
    );

    expect(await database.select(database.siteAttribute).get(), isEmpty);
  });

  testWidgets('a record with a missing project has no automatic fix', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(database.close);
    await withoutForeignKeys(() async {
      await database
          .into(database.collEvent)
          .insert(const CollEventCompanion(projectUuid: Value('gone')));
    });

    final report = await scan(tester);

    expect(report.issues.single.table, 'collEvent');
    expect(report.issues.single.parentTable, 'project');
    expect(report.issues.single.fix, isNull);
  });

  testWidgets('a specimen linked to another project\'s event is cleared', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(database.close);
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion(projectUuid: Value('proj-b')));
    await database
        .into(database.specimen)
        .insert(
          SpecimenCompanion(
            uuid: const Value('spec-1'),
            projectUuid: const Value('proj-a'),
            collEventID: Value(eventId),
          ),
        );

    final report = await scan(tester);

    final issue = report.issues.single;
    expect(issue.kind, HealthIssueKind.crossProjectLink);
    expect(issue.columns, ['collEventID']);

    await tester.runAsync(
      () => service.applyFixes(report.issues, backup: false),
    );

    final specimen = await database.select(database.specimen).getSingle();
    expect(specimen.collEventID, isNull);
  });

  testWidgets('missing media is reported and removed with its links', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(database.close);
    final siteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('proj-a')));
    Future<int> addMedia(String fileName) async {
      final id = await database
          .into(database.media)
          .insert(
            MediaCompanion(
              projectUuid: const Value('proj-a'),
              category: const Value('site'),
              fileName: Value(fileName),
            ),
          );
      await database
          .into(database.siteMedia)
          .insert(
            SiteMediaCompanion(siteId: Value(siteId), mediaId: Value(id)),
          );
      return id;
    }

    final missingId = await addMedia('missing.jpg');
    await addMedia('present.jpg');
    final present = File(
      p.join(
        tempAppDirectory.path,
        'nahpu',
        'proj-a',
        'media',
        'site',
        'present.jpg',
      ),
    );
    await tester.runAsync(() async {
      await present.parent.create(recursive: true);
      await present.writeAsString('x');
    });

    final report = await scan(tester);

    final issue = report.issues.single;
    expect(issue.kind, HealthIssueKind.missingMedia);
    expect(issue.severity, HealthSeverity.warning);
    expect(issue.recordKey, missingId);
    expect(issue.recordLabel, 'missing.jpg');
    expect(issue.target?.type, DataTableRecordType.sites);
    expect(issue.target?.keys, {siteId});

    await tester.runAsync(
      () => service.applyFixes(report.issues, backup: false),
    );

    final media = await database.select(database.media).get();
    expect(media.map((row) => row.fileName), ['present.jpg']);
    expect(await database.select(database.siteMedia).get(), hasLength(1));
  });

  testWidgets('a missing personnel photo is forgotten', (tester) async {
    await setUpService(tester);
    addTearDown(database.close);
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(
            uuid: Value('person-1'),
            name: Value('Alex Rivera'),
            photoPath: Value('alex.jpg'),
          ),
        );

    final report = await scan(tester);

    final issue = report.issues.single;
    expect(issue.kind, HealthIssueKind.missingPersonnelPhoto);
    expect(issue.recordLabel, 'Alex Rivera');

    await tester.runAsync(
      () => service.applyFixes(report.issues, backup: false),
    );

    final person = await database.select(database.personnel).getSingle();
    expect(person.photoPath, isNull);
  });

  testWidgets('field number conflicts and duplicates need a manual fix', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(database.close);
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(
            uuid: Value('person-1'),
            name: Value('Alex Rivera'),
            initial: Value('AR'),
          ),
        );
    for (final (uuid, project) in [('a', 'proj-a'), ('b', 'proj-b')]) {
      await database
          .into(database.specimen)
          .insert(
            SpecimenCompanion(
              uuid: Value(uuid),
              projectUuid: Value(project),
              catalogerID: const Value('person-1'),
              fieldNumber: const Value(7),
            ),
          );
    }
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('c'),
            projectUuid: Value('proj-a'),
            fieldNumber: Value(8),
            projectFieldNumber: Value(3),
          ),
        );

    final report = await scan(tester);

    final byKind = report.byKind;
    final conflict = byKind[HealthIssueKind.fieldNumberConflict]!.single;
    expect(conflict.target?.keys, {'c'});
    expect(conflict.fix, isNull);
    final duplicate = byKind[HealthIssueKind.duplicateFieldNumber]!.single;
    expect(duplicate.recordLabel, 'AR 7');
    expect(duplicate.target?.keys, {'a', 'b'});
    expect(duplicate.fix, isNull);
    expect(report.fixable, isEmpty);
  });

  testWidgets('a specimen without its attribute row gets an empty one', (
    tester,
  ) async {
    await setUpService(tester);
    addTearDown(database.close);
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('bird-1'),
            projectUuid: Value('proj-a'),
            taxonGroup: Value('Birds'),
            fieldNumber: Value(12),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('mammal-1'),
            projectUuid: Value('proj-a'),
            taxonGroup: Value('Mammals'),
          ),
        );
    await database
        .into(database.mammalAttribute)
        .insert(
          const MammalAttributeCompanion(specimenUuid: Value('mammal-1')),
        );

    final report = await scan(tester);

    final issue = report.issues.single;
    expect(issue.kind, HealthIssueKind.missingAttributeRecord);
    expect(issue.severity, HealthSeverity.warning);
    expect(issue.recordLabel, '12');
    expect(issue.detail, 'birdAttribute');
    expect(issue.fix, HealthFixAction.createAttributeRow);

    await tester.runAsync(
      () => service.applyFixes(report.issues, backup: false),
    );

    final rows = await database.select(database.birdAttribute).get();
    expect(rows.map((row) => row.specimenUuid), ['bird-1']);
    expect((await scan(tester)).isHealthy, isTrue);
  });
}
