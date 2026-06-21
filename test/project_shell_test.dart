import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/project_shell.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
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

Future<_PushCountingObserver> _pumpShell(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final observer = _PushCountingObserver();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [settingProvider.overrideWithValue(prefs)],
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
  });

  testWidgets('tapping a tab swaps the page in place without pushing a route',
      (tester) async {
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

  testWidgets('keeps every page alive in the tree across switches',
      (tester) async {
    await _pumpShell(tester);

    await tester.tap(find.text('Narrative'));
    await tester.pumpAndSettle();

    // IndexedStack keeps unselected pages mounted (offstage) — this is what
    // preserves per-screen state across tab switches.
    expect(
      find.text('PAGE-Dashboard', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('PAGE-Narrative'), findsOneWidget);
  });
}
