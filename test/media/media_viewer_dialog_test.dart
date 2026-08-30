import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/screens/shared/media/media_details.dart';
import 'package:nahpu/screens/shared/media/media_viewer_dialog.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:path/path.dart' as path;

const String _projectUuid = 'proj-media-viewer';

/// A valid 1x1 transparent PNG.
final List<int> _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
  'AAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late Directory tempAppDir;
  late Database db;

  setUp(() {
    tempAppDir = Directory.systemTemp.createTempSync('nahpu-media-viewer-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async {
          return tempAppDir.path;
        });
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (tempAppDir.existsSync()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  List<MediaData> seedImages(int count) {
    final mediaList = <MediaData>[];
    for (int i = 1; i <= count; i++) {
      final fileName = 'photo$i.png';
      _writeMediaFile(tempAppDir, fileName, _pngBytes);
      mediaList.add(
        _buildMedia(id: i, fileName: fileName, caption: 'Caption $i'),
      );
    }
    return mediaList;
  }

  testWidgets('opening the dialog shows the image area and counter', (
    tester,
  ) async {
    final mediaList = seedImages(2);
    await _pumpViewerLauncher(tester, db, mediaList);
    await _openDialog(tester);

    expect(find.byType(MediaViewerDialog), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    // File name shows in the top bar and in the metadata panel.
    expect(find.text('photo1.png'), findsWidgets);
  });

  testWidgets('image viewer allows deep zoom', (tester) async {
    final mediaList = seedImages(1);
    await _pumpViewerLauncher(tester, db, mediaList);
    await _openDialog(tester);

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.maxScale, 10);
    expect(viewer.minScale, 0.8);
  });

  testWidgets('next and previous navigate without wraparound', (tester) async {
    final mediaList = seedImages(3);
    await _pumpViewerLauncher(tester, db, mediaList);
    await _openDialog(tester);

    // At the first item there is no previous button.
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await _flushMediaLoad(tester);
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text('photo2.png'), findsWidgets);
    expect(find.text('photo1.png'), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await _flushMediaLoad(tester);
    expect(find.text('3 / 3'), findsOneWidget);
    // At the last item there is no next button.
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await _flushMediaLoad(tester);
    expect(find.text('2 / 3'), findsOneWidget);

    // Arrow keys also navigate.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await _flushMediaLoad(tester);
    expect(find.text('1 / 3'), findsOneWidget);
    // No wraparound past the first item.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await _flushMediaLoad(tester);
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('metadata panel toggles on and off', (tester) async {
    _writeMediaFile(tempAppDir, 'photo1.png', _pngBytes);
    final mediaList = [
      _buildMedia(
        id: 1,
        fileName: 'photo1.png',
        caption: 'A nice view',
        tag: 'tag-1',
      ),
    ];
    await _pumpViewerLauncher(tester, db, mediaList);
    await _openDialog(tester);

    // Metadata visible by default.
    expect(find.text('Details'), findsNothing);
    expect(find.byType(MediaDetailsView), findsOneWidget);
    expect(find.text('A nice view'), findsOneWidget);
    expect(find.text('tag-1'), findsOneWidget);
    expect(find.byType(FormSection), findsAtLeastNWidgets(3));

    await tester.tap(find.byIcon(Icons.info));
    await tester.pump();
    expect(find.byType(MediaDetailsView), findsNothing);
    expect(find.text('A nice view'), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pump();
    expect(find.byType(MediaDetailsView), findsOneWidget);
    expect(find.text('A nice view'), findsOneWidget);
  });

  testWidgets('wide layout shows metadata in a side panel', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final mediaList = seedImages(1);
    await _pumpViewerLauncher(tester, db, mediaList);
    await _openDialog(tester);

    final sidePanel = find.ancestor(
      of: find.byType(MediaDetailsView),
      matching: find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 360,
      ),
    );
    final bottomPanel = find.ancestor(
      of: find.byType(MediaDetailsView),
      matching: find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 280,
      ),
    );
    expect(sidePanel, findsOneWidget);
    expect(bottomPanel, findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
  });

  testWidgets('narrow layout toggles between media and info views', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    _writeMediaFile(tempAppDir, 'photo1.png', _pngBytes);
    final mediaList = [
      _buildMedia(id: 1, fileName: 'photo1.png', caption: 'A nice view'),
    ];
    await _pumpViewerLauncher(tester, db, mediaList);
    await _openDialog(tester);

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
      isTrue,
    );
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byType(TabBar), findsNothing);
    expect(find.byTooltip('Show details'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('A nice view'), findsNothing);

    await tester.tap(find.byTooltip('Show details'));
    await tester.pumpAndSettle();
    expect(find.byType(MediaDetailsView), findsOneWidget);
    expect(find.text('A nice view'), findsOneWidget);
    expect(find.byTooltip('Hide details'), findsOneWidget);

    await tester.tap(find.byTooltip('Hide details'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('A nice view'), findsNothing);
  });

  testWidgets('falls back gracefully for audio when playback is unavailable', (
    tester,
  ) async {
    _writeMediaFile(tempAppDir, 'sound.mp3', [1, 2, 3]);
    final mediaList = [_buildMedia(id: 1, fileName: 'sound.mp3')];
    await _pumpViewerLauncher(tester, db, mediaList);
    await _openDialog(tester);

    // No video_player platform implementation exists in the test
    // environment, so controller initialization fails and the dialog
    // must fall back without crashing.
    expect(find.byType(MediaViewerDialog), findsOneWidget);
    expect(find.text('Cannot display this audio file'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a media card thumbnail opens the viewer dialog', (
    tester,
  ) async {
    final mediaList = seedImages(2);
    WidgetRef? widgetRef;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, child) {
                widgetRef = ref;
                return MediaViewerBuilder(images: mediaList);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    widgetRef!
        .read(projectUuidProvider.notifier)
        .updateProjectUuid(_projectUuid);
    await _flushMediaLoad(tester);

    expect(find.byType(MediaCard), findsNWidgets(2));
    expect(find.byType(MediaViewerDialog), findsNothing);

    // Tap the thumbnail area of the first card (away from the bottom
    // file-name tile).
    final cardTopLeft = tester.getTopLeft(find.byType(MediaCard).first);
    await tester.tapAt(cardTopLeft + const Offset(30, 30));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _flushMediaLoad(tester);

    expect(find.byType(MediaViewerDialog), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('narrow media menu uses sheets and separates edit from info', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    _writeMediaFile(tempAppDir, 'photo1.png', _pngBytes);
    final media = _buildMedia(
      id: 1,
      fileName: 'photo1.png',
      caption: 'Habitat overview',
      tag: 'habitat',
      camera: 'NAHPU Camera',
    );
    await _pumpMediaGrid(tester, db, [media]);

    await tester.tap(find.byTooltip('Media actions'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Show info'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit media'), findsOneWidget);
    expect(find.text('File name'), findsOneWidget);
    expect(find.text('Caption'), findsOneWidget);
    expect(find.text('Tag'), findsOneWidget);
    expect(find.text('Photographer'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Camera'), findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Media actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show info'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    await _flushMediaLoad(tester);
    expect(find.text('Media info'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('NAHPU Camera'), findsOneWidget);
    expect(find.text('Additional EXIF'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
    expect(find.text('${_pngBytes.length} B'), findsOneWidget);
    expect(find.byType(FormSection), findsNWidgets(4));
  });

  testWidgets('media labels show type icons and switch to checkboxes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final mediaList = [
      _buildMedia(id: 1, fileName: 'photo.png'),
      _buildMedia(id: 2, fileName: 'sound.wav'),
      _buildMedia(id: 3, fileName: 'clip.mp4'),
      _buildMedia(id: 4, fileName: 'document.pdf'),
    ];
    await _pumpMediaViewer(tester, db, mediaList);
    await _flushMediaLoad(tester);

    final expectedIcons = [
      Icons.image_outlined,
      Icons.audio_file_outlined,
      Icons.video_file_outlined,
      Icons.insert_drive_file_outlined,
    ];
    final cards = find.byType(MediaCard);
    expect(cards, findsNWidgets(expectedIcons.length));
    for (var index = 0; index < expectedIcons.length; index++) {
      final label = tester.widget<ListTile>(
        find.descendant(of: cards.at(index), matching: find.byType(ListTile)),
      );
      expect((label.leading! as Icon).icon, expectedIcons[index]);
    }

    await tester.tap(find.text('Select'));
    await tester.pump();

    for (var index = 0; index < expectedIcons.length; index++) {
      final label = tester.widget<ListTile>(
        find.descendant(of: cards.at(index), matching: find.byType(ListTile)),
      );
      expect(label.leading, isA<ListCheckBox>());
    }
  });

  testWidgets('media selection controls align actions and select every card', (
    tester,
  ) async {
    final mediaList = seedImages(2);
    await _pumpMediaViewer(tester, db, mediaList);
    await _flushMediaLoad(tester);

    expect(find.text('Caption 1'), findsNothing);
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Gallery')).dx,
      lessThan(tester.getCenter(find.text('Select')).dx),
    );
    await tester.tap(find.text('Select'));
    await tester.pump();

    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Clear')).dx,
      lessThan(tester.getCenter(find.text('Select all')).dx),
    );
    expect(
      tester.getCenter(find.text('Select all')).dx,
      lessThan(tester.getCenter(find.text('Done')).dx),
    );
    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(find.byTooltip('Media actions'), findsNothing);

    await tester.tap(find.text('Select all'));
    await tester.pump();
    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    expect(checkboxes.every((checkbox) => checkbox.value == true), isTrue);
    expect(find.text('Delete 2 media files'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pump();
    expect(
      tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .every((checkbox) => checkbox.value == false),
      isTrue,
    );
  });

  testWidgets('empty media grid still opens the project gallery', (
    tester,
  ) async {
    var galleryOpenCount = 0;
    await _pumpMediaViewer(
      tester,
      db,
      const [],
      onOpenGallery: () => galleryOpenCount++,
    );

    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.ancestor(
              of: find.text('Select'),
              matching: find.byType(TextButton),
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Gallery'));
    expect(galleryOpenCount, 1);
  });
}

MediaData _buildMedia({
  required int id,
  required String fileName,
  String? caption,
  String? tag,
  String? camera,
}) {
  return MediaData(
    primaryId: id,
    projectUuid: _projectUuid,
    category: 'site',
    fileName: fileName,
    caption: caption,
    tag: tag,
    taken: '',
    camera: camera ?? '',
    lenses: '',
    additionalExif: '',
  );
}

Future<void> _pumpMediaGrid(
  WidgetTester tester,
  Database db,
  List<MediaData> mediaList,
) async {
  WidgetRef? widgetRef;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, child) {
              widgetRef = ref;
              return MediaViewerBuilder(images: mediaList);
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  widgetRef!.read(projectUuidProvider.notifier).updateProjectUuid(_projectUuid);
  await _flushMediaLoad(tester);
}

Future<void> _pumpMediaViewer(
  WidgetTester tester,
  Database db,
  List<MediaData> mediaList, {
  double contentHeight = 360,
  VoidCallback? onOpenGallery,
}) async {
  WidgetRef? widgetRef;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, child) {
              widgetRef = ref;
              return MediaViewer(
                images: mediaList,
                contentHeight: contentHeight,
                onAddFromGallery: () async {},
                onAddFromFiles: () async {},
                onTakeMedia: () async {},
                onRecordAudio: () async {},
                onOpenGallery: onOpenGallery ?? () {},
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  widgetRef!.read(projectUuidProvider.notifier).updateProjectUuid(_projectUuid);
}

File _writeMediaFile(Directory appDir, String fileName, List<int> bytes) {
  final file = File(
    path.join(
      appDir.path,
      nahpuAppDir,
      _projectUuid,
      mediaDir,
      'site',
      fileName,
    ),
  );
  file.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  return file;
}

Future<void> _pumpViewerLauncher(
  WidgetTester tester,
  Database db,
  List<MediaData> mediaList, {
  int initialIndex = 0,
}) async {
  WidgetRef? widgetRef;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, child) {
              widgetRef = ref;
              return Center(
                child: TextButton(
                  onPressed: () => showMediaViewerDialog(
                    context,
                    mediaList: mediaList,
                    initialIndex: initialIndex,
                  ),
                  child: const Text('Open viewer'),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  widgetRef!.read(projectUuidProvider.notifier).updateProjectUuid(_projectUuid);
}

Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.text('Open viewer'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await _flushMediaLoad(tester);
}

/// Lets the dialog finish its real async file IO (path lookup, existence
/// check, image decode) and pumps frames until the loading indicator is gone.
///
/// `pumpAndSettle` cannot be used while a [CircularProgressIndicator] is
/// animating, so this pumps in small steps instead.
Future<void> _flushMediaLoad(WidgetTester tester) async {
  for (int i = 0; i < 20; i++) {
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
