import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/home/components/body.dart';
import 'package:nahpu/l10n/app_localizations.dart';
import 'package:nahpu/screens/home/components/project_actions.dart';
import 'package:nahpu/screens/shared/common/tropical_mountains.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _createKey = ValueKey('home-create-project');
const _importKey = ValueKey('home-import-project');
const _statsKey = ValueKey('home-database-statistics');
const _galleryKey = ValueKey('home-media-gallery');
const _searchKey = ValueKey('home-global-search');
const _moreKey = ValueKey('home-more-actions');

void main() {
  late Database database;
  late SharedPreferences preferences;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    required Size size,
    int projects = 0,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    for (var index = 0; index < projects; index++) {
      await ProjectQuery(database).createProject(
        ProjectCompanion(
          uuid: Value('project-$index'),
          name: Value('Project $index'),
        ),
      );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
          projectPreviewImageFilesProvider.overrideWith(
            (ref, uuid) async => const [],
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: HomeBody())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('compact home pins search and actions above the list', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(400, 800), projects: 20);

    final search = tester.getRect(find.byKey(_searchKey));
    final create = tester.getRect(find.byKey(_createKey));
    final more = tester.getRect(find.byKey(_moreKey));
    final list = find.byType(ListView);
    for (final key in [_searchKey, _createKey, _moreKey]) {
      expect(
        find.ancestor(of: find.byKey(key), matching: find.byType(Scrollable)),
        findsNothing,
      );
    }
    // Search takes its own row; create leads the pill row below it, and
    // the actions without room wait in More.
    expect(create.top, greaterThan(search.bottom));
    expect(more.top, create.top);
    expect(more.left, greaterThan(create.right));
    expect(more.right, lessThanOrEqualTo(search.right + 0.5));
    expect(more.bottom, lessThan(tester.getTopLeft(list).dy));

    final hidden = [
      for (final action in HomeProjectAction.secondary)
        if (find.byKey(action.key).evaluate().isEmpty) action,
    ];
    expect(hidden, isNotEmpty);
    await tester.tap(find.byKey(_moreKey));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    for (final action in hidden) {
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(
            action.title(lookupAppLocalizations(const Locale('en'))),
          ),
        ),
        findsOneWidget,
      );
    }
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();

    final actionsTop = create.top;
    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: list, matching: find.byType(Scrollable)).first,
    );
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.getRect(find.byKey(_createKey)).top, actionsTop);
    expect(tester.takeException(), isNull);
  });

  for (final width in [700.0, 1400.0]) {
    testWidgets('home sets create beside search at ${width.toInt()} wide', (
      tester,
    ) async {
      await pumpHome(tester, size: Size(width, 900), projects: 2);

      final search = tester.getRect(find.byKey(_searchKey));
      final create = tester.getRect(find.byKey(_createKey));
      final projects = tester.getRect(find.byType(ToggleView));
      expect(create.top, search.top);
      expect(create.height, search.height);
      expect(create.left, greaterThan(search.right));
      expect(search.width, greaterThan(create.width));

      // The other actions share one row below, in order, and any without
      // room wait in More at the end.
      final shown = [
        for (final action in HomeProjectAction.secondary)
          if (find.byKey(action.key).evaluate().isNotEmpty)
            tester.getRect(find.byKey(action.key)),
      ];
      final hasHidden = shown.length < HomeProjectAction.secondary.length;
      if (width >= 1400) expect(hasHidden, isFalse);
      expect(find.byKey(_moreKey), hasHidden ? findsOneWidget : findsNothing);
      final row = [
        ...shown,
        if (hasHidden) tester.getRect(find.byKey(_moreKey)),
      ];
      expect(row.first.top, greaterThan(search.bottom));
      for (var index = 1; index < row.length; index++) {
        expect(row[index].top, row.first.top);
        expect(row[index].left, greaterThan(row[index - 1].right));
      }
      expect(row.last.right, lessThanOrEqualTo(create.right + 0.5));
      expect(row.first.bottom, lessThan(projects.top));
      expect(
        tester.widget<Material>(find.byKey(_createKey)).color,
        NahpuTheme.primaryAction,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final (width, columns) in const [
    (400.0, 1),
    (700.0, 2),
    (960.0, 3),
    (1400.0, 3),
  ]) {
    testWidgets(
      'project grid shows $columns columns at ${width.toInt()} wide',
      (tester) async {
        await pumpHome(tester, size: Size(width, 1200), projects: 4);

        await tester.tap(find.byIcon(Icons.grid_view));
        await tester.pumpAndSettle();

        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, columns);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('More opens a popup on wide screens and runs the action', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(640, 900), projects: 2);

    expect(find.byKey(_statsKey), findsNothing);
    await tester.tap(find.byKey(_moreKey));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(
      find.widgetWithText(PopupMenuItem<HomeProjectAction>, 'Statistics'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Database statistics'), findsOneWidget);

    // Close the statistics streams so drift's close timers run in the test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  group('visiblePillCount', () {
    int count(double maxWidth) => visiblePillCount(
      widths: const [100, 100, 100],
      moreWidth: 80,
      gap: 10,
      maxWidth: maxWidth,
    );

    test('shows every pill when they all fit', () {
      expect(count(320), 3);
    });

    test('keeps room for More once any pill is hidden', () {
      expect(count(319), 2);
      expect(count(300), 2);
      expect(count(299), 1);
      expect(count(190), 1);
      expect(count(189), 0);
    });
  });

  for (final size in const [Size(400, 900), Size(1400, 900)]) {
    testWidgets(
      'empty home centers the project actions at ${size.width.toInt()} wide',
      (tester) async {
        await pumpHome(tester, size: size);

        expect(find.text('No projects found.'), findsOneWidget);
        expect(find.text('Setup NAHPU'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
        expect(find.byKey(_statsKey), findsNothing);

        final actions = find.byType(HomeProjectActions);
        expect(actions, findsOneWidget);
        expect(tester.getCenter(actions).dx, closeTo(size.width / 2, 1));

        final create = tester.getRect(find.byKey(_createKey));
        final importCard = tester.getRect(find.byKey(_importKey));
        if (size.width < 600) {
          expect(importCard.top, greaterThan(create.bottom));
        } else {
          expect(importCard.left, greaterThan(create.right));
          expect(importCard.height, create.height);
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('empty home keeps its message clear of the skyline at '
        '${size.width.toInt()} wide', (tester) async {
      await pumpHome(tester, size: size);

      expect(find.byType(EmptyHomeBackdrop), findsOneWidget);
      final backdrop = find.byType(TropicalMountainsBackdrop);
      expect(backdrop, findsOneWidget);
      final ridges = tester.widget<TropicalMountainsBackdrop>(backdrop);
      expect(ridges.tone, TropicalMountainsTone.muted);
      expect(ridges.fadeTop, isTrue);

      // The message reads on plain ground above the ridges.
      final ridgesTop = tester.getRect(backdrop).top;
      expect(
        tester.getRect(find.text('No projects found.')).bottom,
        lessThan(ridgesTop),
      );
      expect(
        tester
            .getRect(find.text('Create or import a project to get started.'))
            .bottom,
        lessThan(ridgesTop),
      );

      // The teal action stays the one saturated colour, and the backdrop
      // does not take its taps.
      expect(
        tester.widget<Material>(find.byKey(_createKey)).color,
        NahpuTheme.primaryAction,
      );
      expect(find.byKey(_createKey).hitTestable(), findsOneWidget);
      expect(find.byKey(_importKey).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('database statistics pages the per-project table by four', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(1200, 1600), projects: 6);

    await tester.tap(find.byKey(_statsKey));
    await tester.pumpAndSettle();

    final perProject = find.byKey(
      const ValueKey('full-screen-record-stat-per-project'),
    );
    Finder inTable(String name) =>
        find.descendant(of: perProject, matching: find.text(name));
    for (var index = 0; index < 4; index++) {
      expect(inTable('Project $index'), findsOneWidget);
    }
    expect(inTable('Project 4'), findsNothing);

    final nextPage = find.descendant(
      of: perProject,
      matching: find.byTooltip('Next page'),
    );
    await tester.ensureVisible(nextPage);
    await tester.tap(nextPage);
    await tester.pumpAndSettle();
    expect(inTable('Project 0'), findsNothing);
    expect(inTable('Project 4'), findsOneWidget);
    expect(inTable('Project 5'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Close the statistics streams so drift's close timers run in the test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('home opens database statistics across every project', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(1200, 1600), projects: 2);

    await tester.tap(find.byKey(_statsKey));
    await tester.pumpAndSettle();

    expect(find.text('Database statistics'), findsOneWidget);
    expect(find.text('Total across all projects'), findsOneWidget);
    final perProject = find.byKey(
      const ValueKey('full-screen-record-stat-per-project'),
    );
    expect(perProject, findsOneWidget);
    for (final name in ['Project 0', 'Project 1']) {
      expect(
        find.descendant(of: perProject, matching: find.text(name)),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);

    // Close the statistics streams so drift's close timers run in the test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('home with projects has no skyline backdrop', (tester) async {
    await pumpHome(tester, size: const Size(400, 800), projects: 2);

    expect(find.byType(EmptyHomeBackdrop), findsNothing);
    expect(find.byType(TropicalMountainsBackdrop), findsNothing);
  });

  testWidgets('create project is the high-contrast primary action', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(1400, 900), projects: 1);

    final create = find.byKey(_createKey);
    final importPill = find.byKey(_importKey);
    final fill = tester.widget<Material>(create).color!;
    final title = tester.widget<Text>(
      find.descendant(of: create, matching: find.byType(Text)),
    );
    final titleLuminance = title.style!.color!.computeLuminance();
    final fillLuminance = fill.computeLuminance();
    final contrast = titleLuminance > fillLuminance
        ? (titleLuminance + 0.05) / (fillLuminance + 0.05)
        : (fillLuminance + 0.05) / (titleLuminance + 0.05);
    expect(contrast, greaterThanOrEqualTo(4.5));
    expect(tester.widget<Material>(importPill).color, isNot(fill));

    for (final (key, path) in const [
      (_createKey, 'assets/icons/project_create.svg'),
      (_importKey, 'assets/icons/project_import.svg'),
      (_galleryKey, 'assets/icons/image-gallery.svg'),
    ]) {
      final picture = tester.widget<SvgPicture>(
        find.descendant(of: find.byKey(key), matching: find.byType(SvgPicture)),
      );
      expect((picture.bytesLoader as SvgAssetLoader).assetName, path);
    }
  });
}
