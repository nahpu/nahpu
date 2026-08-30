import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/application/data_usage.dart';
import 'package:nahpu/screens/settings/application/file_tree.dart';
import 'package:nahpu/screens/settings/common.dart';
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
  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    Size size = const Size(1400, 2200),
  }) async {
    // The tree sits below the summary and the prune panel, past the bottom of
    // the default test surface.
    tester.view.physicalSize = size;
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
    // The folder keeps the name it has on disk — a UUID — and the project it
    // belongs to moves to the description line.
    expect(find.text(projectUuid), findsOneWidget);
    expect(find.textContaining('2 files · Test Project'), findsOneWidget);
    expect(find.text('Remove unlinked files'), findsOneWidget);
    expect(
      find.textContaining('Unlinked files are no longer used by any record'),
      findsOneWidget,
    );
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

  testWidgets('empty file tree fills the settings container', (tester) async {
    await seed();
    await pumpScreen(tester, size: const Size(900, 700));

    final emptyMessage = find.text('The application folder is empty.');
    await tester.ensureVisible(emptyMessage);
    await tester.pumpAndSettle();

    final fileSection = find.ancestor(
      of: emptyMessage,
      matching: find.byType(CommonSettingSection),
    );
    final fileTreeSurface = find
        .ancestor(of: emptyMessage, matching: find.byType(Material))
        .first;
    expect(
      tester.getSize(fileTreeSurface).width,
      tester.getSize(fileSection).width,
    );
  });

  testWidgets('selection controls stay in the bottom panel', (tester) async {
    await seed();
    writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
    writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

    await pumpScreen(tester, size: const Size(900, 700));

    await tester.ensureVisible(find.text('Select'));
    await tester.pumpAndSettle();
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Expand all'), findsOneWidget);
    expect(find.textContaining('Review'), findsNothing);

    final filesTop = tester.getTopLeft(find.text('Files').last).dy;
    final expandTop = tester.getTopLeft(find.text('Expand all')).dy;
    final selectTop = tester.getTopLeft(find.text('Select')).dy;
    expect(expandTop, closeTo(filesTop, 16));
    expect(selectTop, closeTo(filesTop, 16));

    final fileSection = find.ancestor(
      of: find.text('Expand all'),
      matching: find.byType(CommonSettingSection),
    );
    expect(
      tester.getSize(find.byType(NahpuFileTreeView)).width,
      tester.getSize(fileSection).width,
    );

    await tester.tap(find.text('Expand all'));
    await tester.pumpAndSettle();
    expect(find.text('Collapse all'), findsOneWidget);
    await tester.tap(find.text('Collapse all'));
    await tester.pumpAndSettle();
    expect(find.text('Expand all'), findsOneWidget);

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Clear')),
      findsNothing,
    );
    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Review 0'), findsOneWidget);

    final clear = tester.getCenter(find.text('Clear'));
    final review = tester.getCenter(find.text('Review 0'));
    final done = tester.getCenter(find.text('Done'));
    expect(clear.dx, lessThan(review.dx));
    expect(review.dx, lessThan(done.dx));

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(find.text('Review 1'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.textContaining('selected'), findsNothing);

    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Review 1'), findsOneWidget);
  });

  testWidgets('selection panel fits a compact screen', (tester) async {
    await seed();
    writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
    writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

    await pumpScreen(tester, size: const Size(320, 700));
    await tester.drag(
      find.byType(ListView).first,
      const Offset(0, -1000),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('Review 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Clear resets selection and Done exits selection mode', (
    tester,
  ) async {
    await seed();
    writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
    writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

    await pumpScreen(tester);
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Select'), findsOneWidget);
    expect(find.textContaining('selected'), findsNothing);
  });

  testWidgets('selecting a folder picks up only its removable files', (
    tester,
  ) async {
    await seed();
    writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
    writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

    await pumpScreen(tester);
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    // The first checkbox belongs to the outermost folder.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Only the orphan is removable; the linked photo is skipped.
    expect(find.text('Review 1'), findsOneWidget);
  });
}
