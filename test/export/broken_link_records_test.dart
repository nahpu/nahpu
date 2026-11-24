import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/record_writer.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/export.dart';

/// A specimen whose taxon or people were deleted must still show in the data
/// table and tabular exports, so the database check can lead users to it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempAppDirectory;

  setUp(() {
    tempAppDirectory = Directory.systemTemp.createTempSync(
      'nahpu-broken-link-records-test-',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return tempAppDirectory.path;
          }
          return Directory.systemTemp.path;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempAppDirectory.existsSync()) {
      await tempAppDirectory.delete(recursive: true);
    }
  });

  testWidgets('a specimen with a missing taxon and cataloger still writes', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
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
    capturedRef!.read(projectUuidProvider.notifier).updateProjectUuid('proj-a');
    final specimen = await tester.runAsync(() async {
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(uuid: Value('proj-a'), name: Value('A')),
          );
      await database.customStatement('PRAGMA foreign_keys = OFF');
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('spec-1'),
              projectUuid: Value('proj-a'),
              taxonGroup: Value('Mammals'),
              fieldNumber: Value(101),
              speciesID: Value(999999),
              catalogerID: Value('gone-person'),
              preparatorID: Value('gone-person'),
            ),
          );
      await database.customStatement('PRAGMA foreign_keys = ON');
      await database
          .into(database.mammalAttribute)
          .insert(
            const MammalAttributeCompanion(specimenUuid: Value('spec-1')),
          );
      return database.select(database.specimen).getSingle();
    });

    final rows = await tester.runAsync(
      () => SpecimenRecordWriter(
        ref: capturedRef!,
        recordType: SpecimenRecordType.allTaxa,
        includeBatFields: false,
      ).getRowsForSpecimen(specimen!),
    );

    expect(rows, hasLength(1));
    expect(rows!.single, contains('101'));
  });

  testWidgets('a bird without its attribute row still writes', (tester) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
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
    final specimen = await tester.runAsync(() async {
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(uuid: Value('proj-a'), name: Value('A')),
          );
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('bird-1'),
              projectUuid: Value('proj-a'),
              taxonGroup: Value('Birds'),
              fieldNumber: Value(202),
            ),
          );
      return database.select(database.specimen).getSingle();
    });

    final rows = await tester.runAsync(
      () => SpecimenRecordWriter(
        ref: capturedRef!,
        recordType: SpecimenRecordType.allTaxa,
        includeBatFields: false,
      ).getRowsForSpecimen(specimen!),
    );

    expect(rows, hasLength(1));
    expect(rows!.single, contains('202'));
  });
}
