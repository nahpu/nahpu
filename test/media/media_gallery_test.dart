import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/screens/shared/media/media_details.dart';
import 'package:nahpu/screens/shared/media/media_gallery.dart';
import 'package:nahpu/screens/shared/media/media_viewer_dialog.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/media/media_gallery_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:path/path.dart' as path;

const _projectUuid = 'project-media-gallery';
final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
  'AAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late Directory tempAppDir;
  late Database db;

  setUp(() async {
    tempAppDir = Directory.systemTemp.createTempSync('nahpu-gallery-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async {
          return tempAppDir.path;
        });
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await ProjectQuery(db).createProject(
      const ProjectCompanion(
        uuid: Value(_projectUuid),
        name: Value('Gallery project'),
      ),
    );
    await _seedMedia(db, tempAppDir);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (tempAppDir.existsSync()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  testWidgets('defaults category, searches metadata, and changes sort', (
    tester,
  ) async {
    await _pumpGallery(tester, db);

    final specimenChip = find.widgetWithText(ChoiceChip, 'Specimen');
    expect(tester.widget<ChoiceChip>(specimenChip).selected, isTrue);
    expect(_cardIds(tester), [1]);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pump();
    expect(_cardIds(tester), [2, 1]);

    await tester.tap(find.byTooltip('Search media'));
    await tester.pump();
    await tester.enterText(find.byType(SearchBar), 'habitat nikon');
    await tester.pump();
    expect(_cardIds(tester), [2]);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.tap(find.byTooltip('Sort media'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is CheckedPopupMenuItem<MediaGallerySort> &&
            widget.value == MediaGallerySort.addedOldest,
      ),
    );
    await tester.pump();
    expect(_cardIds(tester), [1, 2]);
  });

  testWidgets('gallery helper pushes a full-screen category-aware route', (
    tester,
  ) async {
    WidgetRef? widgetRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) {
              widgetRef = ref;
              return Scaffold(
                body: TextButton(
                  onPressed: () => showMediaGallery(
                    context,
                    initialCategory: MediaCategory.site,
                  ),
                  child: const Text('Open gallery'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    widgetRef!
        .read(projectUuidProvider.notifier)
        .updateProjectUuid(_projectUuid);
    await tester.tap(find.text('Open gallery'));
    await tester.pump();
    await _flushMediaLoad(tester);

    expect(find.byType(MediaGalleryScreen), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Site'))
          .selected,
      isTrue,
    );
    expect(_cardIds(tester), [2]);
  });

  testWidgets('select all and category changes keep only visible selection', (
    tester,
  ) async {
    await _pumpGallery(tester, db);
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pump();
    await tester.tap(find.text('Select'));
    await tester.pump();
    await tester.tap(find.text('Select all'));
    await tester.pump();

    expect(
      tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .every((checkbox) => checkbox.value == true),
      isTrue,
    );
    expect(find.text('Delete 2 media files'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Specimen'));
    await tester.pump();
    expect(find.byType(Checkbox), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.text('Delete 1 media file'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('gallery cards open the shared viewer and grouped info', (
    tester,
  ) async {
    await _pumpGallery(tester, db);
    final cardTopLeft = tester.getTopLeft(find.byType(MediaCard));
    await tester.tapAt(cardTopLeft + const Offset(30, 30));
    await tester.pump();
    await _flushMediaLoad(tester);

    expect(find.byType(MediaViewerDialog), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.byType(FormSection), findsAtLeastNWidgets(3));

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byTooltip('Media actions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Show info'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('File'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    await tester.drag(find.byType(MediaDetailsView), const Offset(0, -400));
    await tester.pump();
    expect(find.text('Capture and equipment'), findsOneWidget);
    await tester.drag(find.byType(MediaDetailsView), const Offset(0, -500));
    await tester.pump();
    expect(find.text('Identifiers'), findsOneWidget);
  });
}

Future<void> _seedMedia(Database db, Directory appDir) async {
  await db
      .into(db.media)
      .insert(
        const MediaCompanion(
          projectUuid: Value(_projectUuid),
          category: Value('specimen'),
          fileName: Value('specimen10.png'),
          caption: Value('Wing detail'),
          camera: Value('Canon R5'),
          taken: Value('2024:01:01 10:00:00'),
        ),
      );
  await db
      .into(db.media)
      .insert(
        const MediaCompanion(
          projectUuid: Value(_projectUuid),
          category: Value('site'),
          fileName: Value('site2.png'),
          caption: Value('Habitat overview'),
          camera: Value('Nikon Z8'),
          taken: Value('2025:01:01 10:00:00'),
        ),
      );
  _writeMediaFile(appDir, 'specimen', 'specimen10.png');
  _writeMediaFile(appDir, 'site', 'site2.png');
}

void _writeMediaFile(Directory appDir, String category, String fileName) {
  File(
      path.join(
        appDir.path,
        nahpuAppDir,
        _projectUuid,
        mediaDir,
        category,
        fileName,
      ),
    )
    ..createSync(recursive: true)
    ..writeAsBytesSync(_pngBytes);
}

Future<void> _pumpGallery(WidgetTester tester, Database db) async {
  WidgetRef? widgetRef;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, child) {
            widgetRef = ref;
            return const MediaGalleryScreen(
              initialCategory: MediaCategory.specimen,
            );
          },
        ),
      ),
    ),
  );
  await tester.pump();
  widgetRef!.read(projectUuidProvider.notifier).updateProjectUuid(_projectUuid);
  await _flushMediaLoad(tester);
}

List<int> _cardIds(WidgetTester tester) {
  return tester
      .widgetList<MediaCard>(find.byType(MediaCard))
      .map((card) => card.media.primaryId)
      .toList();
}

Future<void> _flushMediaLoad(WidgetTester tester) async {
  for (var index = 0; index < 30; index++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 300));
      return;
    }
  }
}
