import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/projects/project_transfer/export_project.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/project_transfer/project_transfer_models.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempAppDirectory;
  late Database database;
  late ProviderContainer container;

  setUp(() async {
    tempAppDirectory = Directory.systemTemp.createTempSync(
      'nahpu-archive-settings-test-',
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

    PackageInfo.setMockInitialValues(
      appName: 'NAHPU',
      packageName: 'org.nahpu.app',
      version: '1.0.0',
      buildNumber: '36',
      buildSignature: '',
    );

    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    container.read(projectUuidProvider.notifier).updateProjectUuid('project-a');
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempAppDirectory.existsSync()) {
      await tempAppDirectory.delete(recursive: true);
    }
  });

  testWidgets('backup settings use TAR.GZ-first archive controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ExportDbForm()),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pump();

    final selector = tester.widget<SegmentedButton<DbArchiveFormat>>(
      find.byType(SegmentedButton<DbArchiveFormat>),
    );
    expect(selector.segments.map((segment) => segment.value), [
      DbArchiveFormat.tarGzip,
      DbArchiveFormat.zip,
    ]);
    expect(find.text('backup'), findsOneWidget);
    expect(find.text('.tar.gz'), findsOneWidget);
    expect(find.text('Select directory'), findsOneWidget);
  });

  testWidgets('project export keeps matching archive controls', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ExportProjectScreen()),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pump();

    final selector = tester
        .widget<SegmentedButton<ProjectTransferArchiveFormat>>(
          find.byType(SegmentedButton<ProjectTransferArchiveFormat>),
        );
    expect(selector.segments.map((segment) => segment.value), [
      ProjectTransferArchiveFormat.tarGzip,
      ProjectTransferArchiveFormat.zip,
    ]);
    expect(find.text('.tar.gz'), findsOneWidget);
  });
}
