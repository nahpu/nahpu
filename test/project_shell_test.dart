import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
        home: const ProjectShell(pages: _pages),
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

  testWidgets('uses a collapsed labeled rail on large screens', (tester) async {
    await _pumpShell(tester, size: const Size(1200, 900));

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    final theme = Theme.of(tester.element(find.byType(NavigationRail)));
    expect(rail.extended, isFalse);
    expect(rail.labelType, NavigationRailLabelType.all);
    expect(rail.selectedIconTheme?.color, theme.colorScheme.primary);
    expect(rail.unselectedIconTheme?.color, theme.colorScheme.onSurfaceVariant);
    expect(rail.selectedLabelTextStyle?.color, theme.colorScheme.primary);
    expect(
      rail.unselectedLabelTextStyle?.color,
      theme.colorScheme.onSurfaceVariant,
    );

    final railElement = tester.element(find.byType(NavigationRail));
    final railSurface = railElement.findAncestorWidgetOfExactType<Material>();
    expect(railSurface, isNotNull);
    expect(railSurface!.elevation, NahpuElevation.high);
    expect(railSurface.borderRadius, BorderRadius.circular(NahpuRadius.large));
    expect(railSurface.clipBehavior, Clip.antiAlias);
    final surfaceElement = tester.element(find.byWidget(railSurface));
    final railPadding = surfaceElement.findAncestorWidgetOfExactType<Padding>();
    expect(railPadding?.padding, const EdgeInsets.all(NahpuSpacing.xs));

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
      theme.colorScheme.error,
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

  testWidgets('overlays the page while leaving the rail interactive', (
    tester,
  ) async {
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
    expect(find.byType(NavigationDrawer), findsOneWidget);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDrawer), findsNothing);
    expect(container.read(projectNavbarIndexProvider), 1);
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
