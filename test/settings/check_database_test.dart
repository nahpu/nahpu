import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/database/check_database.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempAppDirectory;

  setUp(() {
    tempAppDirectory = Directory.systemTemp.createTempSync(
      'nahpu-check-database-test-',
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

  Future<Database> pumpScreen(
    WidgetTester tester,
    Future<void> Function(Database database) seed,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    await tester.runAsync(() async {
      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(uuid: Value('proj-a'), name: Value('A')),
          );
      await seed(database);
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          projectUuidProvider.overrideWith(() => _FixedProjectUuid()),
        ],
        child: const MaterialApp(home: CheckDatabaseScreen()),
      ),
    );
    // The scan runs real IO, so let it finish outside the fake clock.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    return database;
  }

  testWidgets('reports a healthy database', (tester) async {
    final database = await pumpScreen(tester, (_) async {});
    addTearDown(database.close);

    expect(find.text('No problems found.'), findsOneWidget);
    expect(find.textContaining('Fix '), findsNothing);
  });

  testWidgets('lists missing media and confirms fixes with a backup', (
    tester,
  ) async {
    final database = await pumpScreen(tester, (database) async {
      await database
          .into(database.media)
          .insert(
            const MediaCompanion(
              projectUuid: Value('proj-a'),
              category: Value('site'),
              fileName: Value('missing.jpg'),
            ),
          );
    });
    addTearDown(database.close);

    expect(find.text('Missing media files (1)'), findsOneWidget);
    expect(find.textContaining('missing.jpg'), findsOneWidget);
    expect(find.text('Errors: 0 · Warnings: 1'), findsOneWidget);

    await tester.tap(find.text('Select all fixes'));
    await tester.pump();
    await tester.tap(find.text('Fix 1 selected'));
    await tester.pumpAndSettle();

    expect(find.text('Apply 1 fix?'), findsOneWidget);
    final backupSwitch = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(backupSwitch.value, isTrue);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Missing media files (1)'), findsOneWidget);
  });
}

class _FixedProjectUuid extends ProjectUuid {
  @override
  String build() => 'proj-a';
}
