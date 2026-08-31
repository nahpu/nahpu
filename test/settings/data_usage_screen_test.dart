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
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as path;

Finder buttonWithLabel(String label) => find
    .ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    )
    .first;

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
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextButton>(buttonWithLabel('Select all')).onPressed,
      isNull,
    );
  });

  for (final width in [320.0, 900.0]) {
    testWidgets('empty file tree fills the container at $width pixels', (
      tester,
    ) async {
      await seed();
      await pumpScreen(tester, size: Size(width, 700));

      final emptyMessage = find.text('The application folder is empty.');
      await tester.scrollUntilVisible(
        emptyMessage,
        300,
        scrollable: find.byType(Scrollable).first,
      );
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
      expect(
        tester.widget<TextButton>(buttonWithLabel('Expand all')).onPressed,
        isNull,
      );
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextButton>(buttonWithLabel('Select all')).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tree controls stay inside the file container header', (
    tester,
  ) async {
    await seed();
    writeFile([projectUuid, mediaDir, 'specimen', 'kept.jpg']);
    writeFile([projectUuid, mediaDir, 'specimen', 'orphan.jpg']);

    await pumpScreen(tester, size: const Size(900, 700));

    await tester.ensureVisible(find.text('Select'));
    await tester.pumpAndSettle();
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Expand all'), findsOneWidget);
    expect(find.textContaining('Review'), findsNothing);

    final fileTree = find.byType(NahpuFileTreeView);
    final surface = find
        .ancestor(of: fileTree, matching: find.byType(Material))
        .first;
    final surfaceRect = tester.getRect(surface);
    expect(
      tester.getBottomLeft(find.text('Files').last).dy,
      lessThanOrEqualTo(surfaceRect.top),
    );
    for (final label in ['Expand all', 'Select']) {
      final buttonRect = tester.getRect(buttonWithLabel(label));
      expect(buttonRect.intersect(surfaceRect), buttonRect);
      expect(buttonRect.bottom, lessThan(tester.getTopLeft(fileTree).dy));
    }
    expect(
      tester.getTopRight(buttonWithLabel('Select')).dx,
      closeTo(surfaceRect.right - NahpuSpacing.md, 0.01),
    );
    expect(
      find.descendant(of: surface, matching: find.byType(Divider)),
      findsOneWidget,
    );

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
    expect(
      find.descendant(of: surface, matching: find.text('Select all')),
      findsOneWidget,
    );
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final toolbar = find.byWidget(scaffold.bottomNavigationBar!);
    expect(
      find.descendant(of: toolbar, matching: find.text('Select all')),
      findsNothing,
    );
    for (final label in ['Clear', 'Review 0', 'Done']) {
      expect(
        find.descendant(of: toolbar, matching: find.text(label)),
        findsOneWidget,
      );
    }

    final clear = tester.getCenter(find.text('Clear'));
    final review = tester.getCenter(find.text('Review 0'));
    final done = tester.getCenter(find.text('Done'));
    expect(clear.dx, lessThan(review.dx));
    expect(review.dx, lessThan(done.dx));
    expect(clear.dy, closeTo(review.dy, 0.01));
    expect(done.dy, closeTo(review.dy, 0.01));

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(find.text('Review 1'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.textContaining('selected'), findsNothing);

    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Review 1'), findsOneWidget);
    expect(
      tester.widget<TextButton>(buttonWithLabel('Select all')).onPressed,
      isNull,
    );

    await tester.tap(find.text('Expand all'));
    await tester.pumpAndSettle();
    expect(find.text('Collapse all'), findsOneWidget);
    expect(find.text('Review 1'), findsOneWidget);
    await tester.tap(find.text('Collapse all'));
    await tester.pumpAndSettle();
    expect(find.text('Expand all'), findsOneWidget);
    expect(find.text('Review 1'), findsOneWidget);
  });

  testWidgets('file header stays fixed while a large tree scrolls', (
    tester,
  ) async {
    await seed();
    for (var index = 0; index < 100; index++) {
      writeFile([
        projectUuid,
        mediaDir,
        'specimen',
        'file-${index.toString().padLeft(3, '0')}.jpg',
      ]);
    }
    await pumpScreen(tester);
    await tester.tap(find.text('Expand all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    final tree = find.byType(NahpuFileTreeView);
    final collapseBefore = tester.getRect(buttonWithLabel('Collapse all'));
    final selectBefore = tester.getRect(buttonWithLabel('Select all'));
    expect(tester.getSize(tree).height, 560);
    expect(find.text('file-099.jpg'), findsNothing);

    await tester.drag(
      find.descendant(of: tree, matching: find.byType(Scrollable)),
      const Offset(0, -6000),
    );
    await tester.pumpAndSettle();

    expect(find.text('file-099.jpg'), findsOneWidget);
    expect(tester.getRect(buttonWithLabel('Collapse all')), collapseBefore);
    expect(tester.getRect(buttonWithLabel('Select all')), selectBefore);
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('Review 100'), findsOneWidget);
  });

  testWidgets('header and selection panel fit a compact screen', (
    tester,
  ) async {
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
    await tester.tap(find.text('Expand all'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('Review 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final clear = tester.getRect(buttonWithLabel('Clear'));
    final review = tester.getRect(buttonWithLabel('Review 0'));
    final done = tester.getRect(buttonWithLabel('Done'));
    expect(clear.center.dy, closeTo(review.center.dy, 0.01));
    expect(done.center.dy, closeTo(review.center.dy, 0.01));
    expect(clear.height, review.height);
    expect(done.height, review.height);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(
      tester.getSize(find.byWidget(scaffold.bottomNavigationBar!)).height,
      NahpuControlSize.touchTarget + NahpuSpacing.md * 2,
    );
    await tester.ensureVisible(find.text('Select all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('Review 1'), findsOneWidget);
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
    expect(find.text('Review 0'), findsOneWidget);
    expect(
      tester.widget<TextButton>(buttonWithLabel('Select all')).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Select all'), findsNothing);
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
