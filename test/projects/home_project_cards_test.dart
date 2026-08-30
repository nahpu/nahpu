import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/home/components/body.dart';
import 'package:nahpu/screens/projects/edit_project.dart';
import 'package:nahpu/screens/shared/dialogs/project_exchange_dialogs.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _project = ProjectSummary(
  uuid: 'preview-project',
  name: 'Project',
  created: null,
  lastAccessed: null,
);

void main() {
  late Directory imageDirectory;
  late List<File> images;
  late Database database;
  late SharedPreferences preferences;

  setUp(() async {
    imageDirectory = Directory.systemTemp.createTempSync('nahpu-grid-preview');
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    images = List.generate(5, (index) {
      return File('${imageDirectory.path}/image-$index.png')
        ..writeAsBytesSync(bytes);
    });
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await ProjectQuery(database).createProject(
      const ProjectCompanion(
        uuid: Value('preview-project'),
        name: Value('Project'),
      ),
    );
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await database.close();
    await imageDirectory.delete(recursive: true);
  });

  void resize(WidgetTester tester, double width) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 1000);
    addTearDown(tester.view.reset);
  }

  Future<void> pumpCard(WidgetTester tester, {required bool isList}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
          projectPreviewImageFilesProvider.overrideWith(
            (ref, uuid) async => const [],
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                height: 320,
                child: isList
                    ? ListProjectCard(project: _project, onTap: () {})
                    : GridProjectCard(project: _project, onPressed: () {}),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpSlideshow(
    WidgetTester tester, {
    List<File>? files,
    bool reduceMotion = false,
    bool tickerEnabled = true,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    final previewFiles = files ?? images;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: TickerMode(
              enabled: tickerEnabled,
              child: SizedBox(
                width: 300,
                height: 200,
                child: ProjectImageSlideshow(images: previewFiles),
              ),
            ),
          ),
        ),
      ),
    );
    // File reads and codec creation need real event-loop turns between frames.
    // Keep the fake clock unchanged so slideshow timing assertions stay exact.
    for (var index = 0; index < 10; index++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
  }

  String currentImage(WidgetTester tester) {
    final switcher = tester.widget<AnimatedSwitcher>(
      find.descendant(
        of: find.byType(ProjectImageSlideshow),
        matching: find.byType(AnimatedSwitcher),
      ),
    );
    return (switcher.child!.key! as ValueKey<String>).value;
  }

  for (final width in [552.0, 752.0]) {
    testWidgets('grid uses its $width content width on a wide display', (
      tester,
    ) async {
      resize(tester, 1600);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectPreviewImageFilesProvider.overrideWith(
              (ref, uuid) async => const [],
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: const Column(
                    children: [
                      ProjectGridView(
                        projectList: [
                          _project,
                          ProjectSummary(
                            uuid: 'second-project',
                            name: 'Second project',
                            created: null,
                            lastAccessed: null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, width < 600 ? 1 : 2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'fallback icon fills 80 percent of the shorter preview dimension',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 300, height: 200, child: ProjectGridIcon()),
          ),
        ),
      );
      expect(tester.getSize(find.byType(ProjectIcon)), const Size(160, 160));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preview loading and query errors retain the project icon', (
    tester,
  ) async {
    final completer = Completer<List<File>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectPreviewImageFilesProvider.overrideWith(
            (ref, uuid) => completer.future,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: ProjectGridPreview(projectUuid: 'preview-project'),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(ProjectGridIcon), findsOneWidget);
    completer.completeError(StateError('Media unavailable'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectGridIcon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('returning from a project refreshes its grid preview', (
    tester,
  ) async {
    var loads = 0;
    final observer = _ReturnFromProjectObserver();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectPreviewImageFilesProvider.overrideWith((ref, uuid) async {
            loads++;
            return const [];
          }),
        ],
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const Scaffold(
            body: SizedBox(
              width: 350,
              height: 320,
              child: ProjectView(isList: false, project: _project),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(loads, 1);
    await tester.tap(find.byType(ProjectGridPreview));
    await tester.pumpAndSettle();
    expect(observer.openedProject, isTrue);
    expect(loads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selected images crossfade every five seconds and loop in order',
    (tester) async {
      await pumpSlideshow(tester);
      expect(currentImage(tester), images.first.path);
      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(switcher.duration, const Duration(seconds: 1));
      expect(switcher.switchInCurve, Curves.easeInOut);
      expect(switcher.switchOutCurve, Curves.easeInOut);
      expect((switcher.child! as Image).fit, BoxFit.cover);

      await tester.pump(const Duration(milliseconds: 4999));
      expect(currentImage(tester), images.first.path);
      await tester.pump(const Duration(milliseconds: 1));
      expect(currentImage(tester), images[1].path);
      expect(find.byType(Image), findsNWidgets(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Image), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byType(Image), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 3999));
      expect(currentImage(tester), images[2].path);
      for (var index = 3; index <= images.length; index++) {
        await tester.pump(const Duration(seconds: 5));
        expect(currentImage(tester), images[index % images.length].path);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 10));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('one image is static and changed image sets reset safely', (
    tester,
  ) async {
    await pumpSlideshow(tester);
    await tester.pump(const Duration(seconds: 10));
    expect(currentImage(tester), images[2].path);

    await pumpSlideshow(tester, files: [images.last]);
    await tester.pump(const Duration(seconds: 10));
    expect(currentImage(tester), images.last.path);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion and disabled ticker pause image rotation', (
    tester,
  ) async {
    await pumpSlideshow(tester, reduceMotion: true);
    await tester.pump(const Duration(seconds: 10));
    expect(currentImage(tester), images.first.path);

    await pumpSlideshow(tester, tickerEnabled: false);
    await tester.pump(const Duration(seconds: 10));
    expect(currentImage(tester), images.first.path);

    await pumpSlideshow(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(currentImage(tester), images[1].path);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('covered routes pause the slideshow and returning resumes it', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSlideshow(tester, navigatorKey: navigatorKey);
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Other route')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(currentImage(tester), images.first.path);
    await tester.pump(const Duration(seconds: 5));
    expect(currentImage(tester), images[1].path);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('modal routes pause the slideshow without hiding the preview', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSlideshow(tester, navigatorKey: navigatorKey);
    final context = tester.element(find.byType(ProjectImageSlideshow));
    navigatorKey.currentState!.push(
      DialogRoute<void>(
        context: context,
        builder: (_) => const AlertDialog(title: Text('Actions')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
    expect(currentImage(tester), images.first.path);
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    expect(currentImage(tester), images[1].path);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final missing in [false, true]) {
    testWidgets(
      '${missing ? 'missing' : 'undecodable'} images show the fallback icon',
      (tester) async {
        final file = File('${imageDirectory.path}/broken.png');
        if (!missing) file.writeAsStringSync('not an image');
        await pumpSlideshow(tester, files: [file]);
        for (
          var attempt = 0;
          attempt < 100 && find.byType(ProjectGridIcon).evaluate().isEmpty;
          attempt++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
        }
        expect(find.byType(ProjectGridIcon), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final isList in [true, false]) {
    for (final width in [599.0, 600.0]) {
      testWidgets('${isList ? 'list' : 'grid'} actions adapt at width $width', (
        tester,
      ) async {
        resize(tester, width);
        await pumpCard(tester, isList: isList);
        expect(
          find.byType(PopupMenuButton<MenuSelection>),
          width < 600 ? findsNothing : findsOneWidget,
        );
        await tester.tap(find.byTooltip('Project actions'));
        await tester.pumpAndSettle();
        for (final action in [
          'Edit info',
          'Show QR',
          'Export info',
          'Details',
        ]) {
          expect(find.text(action), findsOneWidget);
        }
        expect(
          find.byType(BottomSheet),
          width < 600 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(PopupMenuDivider),
          width < 600 ? findsNothing : findsNWidgets(2),
        );
        if (width < 600) {
          expect(
            tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
            isTrue,
          );
          expect(find.byType(Divider), findsNWidgets(2));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('compact action sheet scrolls on short displays', (tester) async {
    resize(tester, 390);
    tester.view.physicalSize = const Size(390, 240);
    await pumpCard(tester, isList: true);
    await tester.tap(find.byTooltip('Project actions'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.ensureVisible(find.text('Details'));
    expect(tester.takeException(), isNull);
  });

  for (final width in [599.0, 800.0]) {
    for (final action in ['Edit info', 'Show QR', 'Export info', 'Details']) {
      testWidgets(
        '$action dispatches from ${width < 600 ? 'bottom sheet' : 'popup'}',
        (tester) async {
          resize(tester, width);
          await pumpCard(tester, isList: true);
          await tester.tap(find.byTooltip('Project actions'));
          await tester.pumpAndSettle();
          await tester.tap(find.text(action));
          await tester.pumpAndSettle();

          switch (action) {
            case 'Edit info':
              expect(find.byType(EditProject), findsOneWidget);
            case 'Show QR':
              expect(find.byType(QrCodeDialog), findsOneWidget);
            case 'Export info':
              expect(find.byType(ProjectExportDialog), findsOneWidget);
            case 'Details':
              expect(find.text('Project information'), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}

class _ReturnFromProjectObserver extends NavigatorObserver {
  bool openedProject = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != ProjectShell.routeName) return;
    openedProject = true;
    // Return before building the bridge-backed project screens. This isolates
    // the home card's navigation-completion refresh from project startup.
    scheduleMicrotask(() => navigator!.pop());
  }
}
