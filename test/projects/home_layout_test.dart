import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/home/components/body.dart';
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

  testWidgets('compact home pins project actions above the scrolling list', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(400, 800), projects: 20);

    final create = find.byKey(_createKey);
    final importCard = find.byKey(_importKey);
    final list = find.byType(ListView);
    expect(create, findsOneWidget);
    expect(importCard, findsOneWidget);
    expect(
      find.ancestor(of: create, matching: find.byType(Scrollable)),
      findsNothing,
    );
    expect(tester.getTopLeft(importCard).dy, tester.getTopLeft(create).dy);
    expect(
      tester.getBottomLeft(create).dy,
      lessThan(tester.getTopLeft(list).dy),
    );

    final actionsTop = tester.getTopLeft(create);
    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: list, matching: find.byType(Scrollable)).first,
    );
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.getTopLeft(create), actionsTop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide home gives projects three quarters of the width', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(1400, 900), projects: 2);

    final projectsRect = tester.getRect(find.byType(ToggleView));
    final actionsRect = tester.getRect(find.byType(HomeProjectActions));
    expect(actionsRect.left, greaterThan(projectsRect.right));
    expect(projectsRect.width / actionsRect.width, closeTo(3, 0.01));
    // The action column starts level with the "Existing projects" header row.
    expect(actionsRect.top, projectsRect.top);

    // The actions stack at the full width of the side column.
    final create = tester.getRect(find.byKey(_createKey));
    final importCard = tester.getRect(find.byKey(_importKey));
    expect(importCard.top, greaterThan(create.bottom));
    expect(create.width, actionsRect.width);
    expect(importCard.size, create.size);

    // Square cards keep the icon above the title and the arrow, without a
    // description.
    for (final key in [_createKey, _importKey]) {
      final card = find.byKey(key);
      final title = find.descendant(of: card, matching: find.byType(Text));
      final icon = find.descendant(of: card, matching: find.byType(SvgPicture));
      expect(title, findsOneWidget);
      expect(
        tester.getTopLeft(title).dy,
        greaterThan(tester.getBottomLeft(icon).dy),
      );
      expect(
        find.descendant(
          of: card,
          matching: find.byIcon(Icons.arrow_forward_rounded),
        ),
        findsOneWidget,
      );
    }

    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(tester.getRect(find.byType(HomeProjectActions)), actionsRect);
    expect(tester.takeException(), isNull);
  });

  for (final width in [899.0, 900.0]) {
    testWidgets(
      'home ${width < 900 ? 'pins' : 'splits'} actions at ${width.toInt()} wide',
      (tester) async {
        await pumpHome(tester, size: Size(width, 800), projects: 2);

        final create = tester.getRect(find.byKey(_createKey));
        final importCard = tester.getRect(find.byKey(_importKey));
        final projects = tester.getRect(find.byType(ToggleView));
        if (width < 900) {
          expect(importCard.top, create.top);
          expect(create.bottom, lessThan(projects.top));
        } else {
          expect(importCard.top, greaterThan(create.bottom));
          expect(create.left, greaterThan(projects.right));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in const [Size(400, 900), Size(1400, 900)]) {
    testWidgets(
      'empty home centers the project actions at ${size.width.toInt()} wide',
      (tester) async {
        await pumpHome(tester, size: size);

        expect(find.text('No projects found.'), findsOneWidget);
        expect(find.text('Setup NAHPU'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);

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
    final importCard = find.byKey(_importKey);
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
    expect(tester.widget<Material>(importCard).color, isNot(fill));

    // Only the secondary action sits its icon on a tinted container.
    expect(
      find.descendant(of: create, matching: find.byType(DecoratedBox)),
      findsNothing,
    );
    expect(
      find.descendant(of: importCard, matching: find.byType(DecoratedBox)),
      findsOneWidget,
    );

    for (final (key, path) in const [
      (_createKey, 'assets/icons/project_create.svg'),
      (_importKey, 'assets/icons/project_import.svg'),
    ]) {
      final picture = tester.widget<SvgPicture>(
        find.descendant(of: find.byKey(key), matching: find.byType(SvgPicture)),
      );
      expect((picture.bytesLoader as SvgAssetLoader).assetName, path);
    }
  });
}
