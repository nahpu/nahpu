import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/layout/navigation.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Counts navigator pushes so tests can assert that switching tabs swaps in
/// place instead of pushing a route.
class _PushCountingObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }
}

/// A page whose [State] carries a value, so a test can tell whether the shell
/// preserved the page element or rebuilt the subtree from scratch.
class _StateProbe extends StatefulWidget {
  const _StateProbe();

  @override
  State<_StateProbe> createState() => _StateProbeState();
}

class _StateProbeState extends State<_StateProbe> {
  int pageCount = 0;

  @override
  Widget build(BuildContext context) => Text('PROBE-$pageCount');
}

// Lightweight stand-ins for the five real project screens, which would
// otherwise pull in the database/provider stack.
const _pages = [
  Text('PAGE-Dashboard'),
  Text('PAGE-Sites'),
  Text('PAGE-Events'),
  Text('PAGE-Specimens'),
  Text('PAGE-Narrative'),
];

Future<_PushCountingObserver> _pumpShell(
  WidgetTester tester, {
  Size size = const Size(800, 600),
  List<Widget> pages = _pages,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final observer = _PushCountingObserver();
  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  addTearDown(database.close);
  await database
      .into(database.project)
      .insert(
        const ProjectCompanion(
          uuid: Value('project-shell'),
          name: Value('Project shell'),
        ),
      );
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      settingProvider.overrideWithValue(prefs),
    ],
  );
  addTearDown(container.dispose);
  container
      .read(projectUuidProvider.notifier)
      .updateProjectUuid('project-shell');

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorObservers: [observer],
        home: ProjectShell(pages: pages),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return observer;
}

void main() {
  testWidgets('shows the Dashboard page first', (tester) async {
    await _pumpShell(tester);

    expect(find.text('PAGE-Dashboard'), findsOneWidget);
    expect(find.byType(IndexedStack), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('tapping a tab swaps the page in place without pushing a route', (
    tester,
  ) async {
    final observer = await _pumpShell(tester);
    final pushesAfterInitialRoute = observer.pushCount;

    await tester.tap(find.text('Specimens'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(IndexedStack)),
    );
    expect(container.read(projectNavbarIndexProvider), 3);
    expect(find.text('PAGE-Specimens'), findsOneWidget);

    // Crucially, no new route was pushed.
    expect(observer.pushCount, pushesAfterInitialRoute);
  });

  testWidgets('keeps every page alive in the tree across switches', (
    tester,
  ) async {
    await _pumpShell(tester);

    await tester.tap(find.text('Narrative'));
    await tester.pumpAndSettle();

    // IndexedStack keeps unselected pages mounted (offstage) — this is what
    // preserves per-screen state across tab switches.
    expect(find.text('PAGE-Dashboard', skipOffstage: false), findsOneWidget);
    expect(find.text('PAGE-Narrative'), findsOneWidget);
  });

  testWidgets('resizing across the rail breakpoint keeps page state alive', (
    tester,
  ) async {
    await _pumpShell(
      tester,
      size: const Size(1200, 900),
      pages: const [_StateProbe()],
    );
    expect(find.byType(NavigationRail), findsOneWidget);

    // Stands in for state a screen builds up after it loads, such as the
    // record viewer's page counter.
    tester.state<_StateProbeState>(find.byType(_StateProbe)).pageCount = 3;

    // Crossing the breakpoint swaps the body between a bare stack and a Row.
    // The page stack must be reparented, not rebuilt.
    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('PROBE-3'), findsOneWidget);

    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('PROBE-3'), findsOneWidget);
  });

  testWidgets('uses a collapsed labeled rail on large screens', (tester) async {
    await _pumpShell(tester, size: const Size(1200, 900));

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    final theme = Theme.of(tester.element(find.byType(NavigationRail)));
    expect(rail.extended, isFalse);
    expect(rail.labelType, NavigationRailLabelType.all);
    expect(rail.unselectedIconTheme?.color, theme.colorScheme.onSurfaceVariant);
    expect(
      rail.unselectedLabelTextStyle?.color,
      theme.colorScheme.onSurfaceVariant,
    );

    final railSurfaceFinder = find.ancestor(
      of: find.byType(NavigationRail),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Material && widget.shape is RoundedRectangleBorder,
      ),
    );
    expect(railSurfaceFinder, findsOneWidget);
    final railSurface = tester.widget<Material>(railSurfaceFinder);
    expect(railSurface.elevation, NahpuElevation.none);
    expect(railSurface.shape, isA<RoundedRectangleBorder>());
    expect(
      (railSurface.shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(NahpuRadius.lg),
    );
    expect(railSurface.clipBehavior, Clip.antiAlias);
    final surfaceElement = tester.element(railSurfaceFinder);
    final railPadding = surfaceElement.findAncestorWidgetOfExactType<Padding>();
    expect(railPadding?.padding, const EdgeInsets.all(NahpuSpacing.md));

    final expandButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Expand'),
    );
    final menuButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Menu'),
    );
    final closeButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Close'),
    );
    expect(
      expandButton.style?.foregroundColor?.resolve({}),
      theme.colorScheme.onSurfaceVariant,
    );
    expect(
      menuButton.style?.foregroundColor?.resolve({}),
      theme.colorScheme.onSurfaceVariant,
    );
    expect(
      closeButton.style?.foregroundColor?.resolve({}),
      theme.colorScheme.onSurfaceVariant,
    );

    final menuY = tester.getTopLeft(find.text('Menu')).dy;
    final dashboardY = tester.getTopLeft(find.text('Dashboard')).dy;
    final sitesY = tester.getTopLeft(find.text('Sites')).dy;
    final eventsY = tester.getTopLeft(find.text('Events')).dy;
    final specimensY = tester.getTopLeft(find.text('Specimens')).dy;
    final narrativeY = tester.getTopLeft(find.text('Narrative')).dy;
    expect(menuY, lessThan(dashboardY));
    expect(dashboardY, lessThan(sitesY));
    expect(sitesY, lessThan(eventsY));
    expect(eventsY, lessThan(specimensY));
    expect(specimensY, lessThan(narrativeY));
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('the rail starts extended on laptop-sized screens', (
    tester,
  ) async {
    await _pumpShell(tester, size: const Size(1280, 900));

    var rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
    expect(rail.labelType, NavigationRailLabelType.none);

    // An explicit collapse still wins over the size default.
    await tester.tap(find.text('Collapse navigation'));
    await tester.pumpAndSettle();

    rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
  });

  testWidgets('expands and collapses the large-screen rail', (tester) async {
    await _pumpShell(tester, size: const Size(1200, 900));

    await tester.tap(find.text('Expand'));
    await tester.pumpAndSettle();

    var rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
    expect(rail.labelType, NavigationRailLabelType.none);
    expect(find.text('Collapse navigation'), findsOneWidget);
    expect(find.text('Close project'), findsOneWidget);

    await tester.tap(find.text('Collapse navigation'));
    await tester.pumpAndSettle();

    rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    expect(rail.labelType, NavigationRailLabelType.all);
  });

  testWidgets(
    'dismisses the menu outside the panel while keeping the rail interactive',
    (tester) async {
      await _pumpShell(tester, size: const Size(1200, 900));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(IndexedStack)),
      );
      final pageSizeBefore = tester.getSize(find.byType(IndexedStack));
      final railRect = tester.getRect(find.byType(ProjectNavigationRail));
      final modalBarriersBefore = find.byType(ModalBarrier).evaluate().length;

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      expect(container.read(projectNavbarIndexProvider), 0);
      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.byType(ModalBarrier).evaluate().length, modalBarriersBefore);
      expect(find.text('Delete project'), findsOneWidget);
      expect(find.text('Close project'), findsNothing);
      expect(tester.getSize(find.byType(IndexedStack)), pageSizeBefore);
      final drawerRect = tester.getRect(find.byType(NavigationDrawer));
      expect(drawerRect.left, railRect.right);
      expect(drawerRect.width, 360);

      await tester.tap(find.text('Sites'));
      await tester.pumpAndSettle();

      expect(container.read(projectNavbarIndexProvider), 1);
      expect(find.text('PAGE-Sites'), findsOneWidget);
      expect(find.byType(NavigationDrawer), findsNothing);

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDrawer), findsOneWidget);

      final reopenedDrawerRect = tester.getRect(find.byType(NavigationDrawer));
      await tester.tapAt(
        Offset(reopenedDrawerRect.right + 32, reopenedDrawerRect.center.dy),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDrawer), findsNothing);
      expect(container.read(projectNavbarIndexProvider), 1);
    },
  );

  testWidgets('toggles the menu closed from the rail button', (tester) async {
    await _pumpShell(tester, size: const Size(1200, 900));

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsOneWidget);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsNothing);

    await tester.tap(find.text('Expand'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsOneWidget);

    await tester.tap(find.text('Close menu'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsNothing);
  });

  testWidgets('closes the menu when its focus leaves the panel', (
    tester,
  ) async {
    await _pumpShell(tester, size: const Size(1200, 900));

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDrawer), findsOneWidget);
    expect(FocusManager.instance.primaryFocus, isNotNull);

    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDrawer), findsNothing);
  });

  testWidgets('rail destinations use the same page indexes as the bottom bar', (
    tester,
  ) async {
    final observer = await _pumpShell(tester, size: const Size(1200, 900));
    final pushesAfterInitialRoute = observer.pushCount;

    await tester.tap(find.text('Narrative'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(IndexedStack)),
    );
    expect(container.read(projectNavbarIndexProvider), 4);
    expect(find.text('PAGE-Narrative'), findsOneWidget);
    expect(observer.pushCount, pushesAfterInitialRoute);
  });
}
