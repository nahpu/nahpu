import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/application/data_usage.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/file_explorer.dart';
import 'package:path/path.dart' as path;

/// Drives the real screen against a real scan, so the provider, the classifier,
/// and the tree are exercised together rather than in isolation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'project-uuid-1';

  late Directory tempAppDir;
  late Directory nahpuDir;
  late Database db;

  setUp(() {
    tempAppDir = Directory.systemTemp.createTempSync('nahpu-data-usage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getApplicationDocumentsDirectory':
              return tempAppDir.path;
            case 'getTemporaryDirectory':
              return Directory.systemTemp.path;
            default:
              return null;
          }
        });
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    nahpuDir = Directory(path.join(tempAppDir.path, nahpuAppDir))
      ..createSync(recursive: true);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (tempAppDir.existsSync()) tempAppDir.deleteSync(recursive: true);
  });

  File writeFile(List<String> segments) {
    final file = File(path.join(nahpuDir.path, path.joinAll(segments)));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('payload');
    file.setLastModifiedSync(DateTime.now().subtract(const Duration(days: 2)));
    return file;
  }

  Future<void> seed() async {
    await db
        .into(db.project)
        .insert(
          ProjectCompanion.insert(uuid: projectUuid, name: 'Test Project'),
        );
    await db
        .into(db.media)
        .insert(
          MediaCompanion.insert(
            projectUuid: const Value(projectUuid),
            fileName: const Value('kept.jpg'),
            category: const Value('specimen'),
          ),
        );
  }

  /// Mounts the screen with the scan already complete.
  ///
  /// The scan does real database and filesystem work, which does not progress
  /// inside the fake-async zone widget tests run in, so the container is warmed
  /// under [WidgetTester.runAsync] and then handed to the widget tree.
  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    // The tree sits below the summary and the prune panel, past the bottom of
    // the default test surface.
    tester.view.physicalSize = const Size(1400, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(appFileTreeProvider.future));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DataUsageSettings()),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('shows totals, the project name, and the prune action', (
    tester,
  ) async {
    await seed();
    writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
    writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);
    writeFile(['nahpu.db']);

    await pumpScreen(tester);

    expect(find.text('Total usage'), findsOneWidget);
    expect(find.text('Reclaimable'), findsOneWidget);
    // Project directories are labelled by name and file count, not by UUID.
    expect(find.textContaining('Test Project · 2 files'), findsOneWidget);
    expect(find.text('Remove unlinked files'), findsOneWidget);
    expect(find.textContaining('Remove 1 unlinked file'), findsOneWidget);
  });

  testWidgets('pruning removes the orphan and keeps everything else', (
    tester,
  ) async {
    await seed();
    final kept = writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
    final orphan = writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);
    final database = writeFile(['nahpu.db']);
    final font = writeFile([userConfigDirName, userFontDirName, 'a.ttf']);

    final container = await pumpScreen(tester);

    // The button carries the count, and confirming names it again.
    await tester.tap(find.textContaining('Remove 1 unlinked file'));
    await tester.pumpAndSettle();
    expect(find.text('Remove 1 unlinked files?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    final result = await tester.runAsync(
      () => container.read(appFileTreeProvider.notifier).prune(),
    );

    expect(result?.deletedCount, 1);
    expect(orphan.existsSync(), isFalse);
    expect(kept.existsSync(), isTrue);
    expect(database.existsSync(), isTrue);
    expect(font.existsSync(), isTrue);
  });

  testWidgets('offers nothing to reclaim when everything is linked', (
    tester,
  ) async {
    await seed();
    writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);

    await pumpScreen(tester);

    expect(find.text('Nothing to reclaim.'), findsOneWidget);
    expect(find.textContaining('Remove 1 unlinked'), findsNothing);
  });
}
