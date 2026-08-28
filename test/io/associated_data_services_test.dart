import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/associated_data/associated_data_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDirectory;
  late Database database;
  late WidgetRef ref;
  late int siteId;
  late int eventId;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'nahpu-associated-data-service',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async {
          return tempDirectory.path;
        });
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await database.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  Future<void> initialize(WidgetTester tester) async {
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('associated-service-project'),
            name: Value('Associated service'),
          ),
        );
    siteId = await database
        .into(database.site)
        .insert(
          const SiteCompanion(projectUuid: Value('associated-service-project')),
        );
    eventId = await database
        .into(database.collEvent)
        .insert(
          const CollEventCompanion(
            projectUuid: Value('associated-service-project'),
          ),
        );
    WidgetRef? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, widgetRef, child) {
              captured = widgetRef;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    ref = captured!;
    ref
        .read(projectUuidProvider.notifier)
        .updateProjectUuid('associated-service-project');
  }

  testWidgets('managed files retain their origin and clean up when orphaned', (
    tester,
  ) async {
    await initialize(tester);
    await tester.runAsync(() async {
      final source = File(path.join(tempDirectory.path, 'field-notes.pdf'))
        ..writeAsBytesSync('%PDF-1.7'.codeUnits);
      final service = AssociatedDataServices(ref: ref);

      final dataId = await service.createAssociatedData(
        target: AssociatedDataTarget.site(siteId),
        form: const AssociatedDataCompanion(type: Value('File')),
        selectedFile: source,
      );
      final data = await AssociatedDataQuery(
        database,
      ).getAssociatedDataById(dataId);
      expect(data?.uri, 'sites/field-notes.pdf');
      final managedFile = await service.resolveFile(data!);
      expect(managedFile.existsSync(), isTrue);

      await service.linkToTarget(dataId, AssociatedDataTarget.event(eventId));
      await service.detachFromTarget(dataId, AssociatedDataTarget.site(siteId));
      expect(managedFile.existsSync(), isTrue);
      expect(
        await AssociatedDataQuery(database).getAssociatedDataById(dataId),
        isNot(equals(null)),
      );

      await service.detachFromTarget(
        dataId,
        AssociatedDataTarget.event(eventId),
      );
      expect(managedFile.existsSync(), isFalse);
      expect(
        await AssociatedDataQuery(database).getAssociatedDataById(dataId),
        isNull,
      );
    });
  });

  testWidgets('external links are never deleted by NAHPU', (tester) async {
    await initialize(tester);
    await tester.runAsync(() async {
      final source = File(path.join(tempDirectory.path, 'external.pdf'))
        ..writeAsBytesSync('%PDF-1.7'.codeUnits);
      final service = AssociatedDataServices(ref: ref);

      final dataId = await service.createAssociatedData(
        target: AssociatedDataTarget.event(eventId),
        form: const AssociatedDataCompanion(type: Value('File')),
        selectedFile: source,
        storageMode: AssociatedDataFileStorageMode.linkOriginal,
      );
      final data = await AssociatedDataQuery(
        database,
      ).getAssociatedDataById(dataId);
      expect(data?.uri, startsWith('file:'));
      expect(service.isExternalFile(data!), isTrue);

      await service.detachFromTarget(
        dataId,
        AssociatedDataTarget.event(eventId),
      );
      expect(source.existsSync(), isTrue);
    });
  });

  testWidgets('replacement keeps the row creation origin after sharing', (
    tester,
  ) async {
    await initialize(tester);
    await tester.runAsync(() async {
      final first = File(path.join(tempDirectory.path, 'first.pdf'))
        ..writeAsBytesSync('%PDF-1.7 first'.codeUnits);
      final replacement = File(path.join(tempDirectory.path, 'replacement.pdf'))
        ..writeAsBytesSync('%PDF-1.7 replacement'.codeUnits);
      final service = AssociatedDataServices(ref: ref);
      final dataId = await service.createAssociatedData(
        target: AssociatedDataTarget.site(siteId),
        form: const AssociatedDataCompanion(type: Value('File')),
        selectedFile: first,
      );
      await service.linkToTarget(dataId, AssociatedDataTarget.event(eventId));

      await service.updateAssociatedData(
        target: AssociatedDataTarget.event(eventId),
        associatedDataId: dataId,
        form: const AssociatedDataCompanion(type: Value('File')),
        selectedFile: replacement,
      );

      final updated = await AssociatedDataQuery(
        database,
      ).getAssociatedDataById(dataId);
      expect(updated?.uri, 'sites/replacement.pdf');
    });
  });

  testWidgets('managed usage is scoped to the owning project', (tester) async {
    await initialize(tester);
    await tester.runAsync(() async {
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('other-project'),
              name: Value('Other project'),
            ),
          );
      final otherEvent = await database
          .into(database.collEvent)
          .insert(
            const CollEventCompanion(projectUuid: Value('other-project')),
          );
      final source = File(path.join(tempDirectory.path, 'same.pdf'))
        ..writeAsBytesSync('%PDF-1.7'.codeUnits);
      final service = AssociatedDataServices(ref: ref);
      final dataId = await service.createAssociatedData(
        target: AssociatedDataTarget.event(eventId),
        form: const AssociatedDataCompanion(type: Value('File')),
        selectedFile: source,
      );
      await AssociatedDataQuery(database).createEventDataAssociation(
        otherEvent,
        const AssociatedDataCompanion(
          type: Value('File'),
          uri: Value('events/same.pdf'),
        ),
      );
      final data = await AssociatedDataQuery(
        database,
      ).getAssociatedDataById(dataId);
      final managedFile = await service.resolveFile(data!);

      await service.detachFromTarget(
        dataId,
        AssociatedDataTarget.event(eventId),
      );

      expect(managedFile.existsSync(), isFalse);
    });
  });
}
