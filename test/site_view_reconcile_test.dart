import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/sites.dart';

/// Widget-level regression tests for the in-place refresh hardening from issue
/// #132 (Fix B/C). They drive the real [SiteViewer] against an in-memory
/// database — no mocked widgets — so they exercise the same `ref.listen` /
/// `_reconcile` path the running app uses.
///
/// Under the pre-fix code these would fail: the empty branch called
/// `setState` during build (illegal in a test), and after a delete the page
/// counter went out of range ("Page 1 of 3" against a 2-item list).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'proj-1';

  setUpAll(() {
    // SiteForm's media/coordinate components touch path_provider.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => '/tmp');
  });

  Future<ProviderContainer> pumpViewer(WidgetTester tester, Database db) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    container.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SiteViewer()),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<int> seedSite(Database db) {
    return db.into(db.site).insert(
          const SiteCompanion(projectUuid: Value(projectUuid)),
        );
  }

  // PageViewer schedules a one-shot 5s timer to hide the page-number overlay;
  // fire it so no timer is pending when the tree is disposed.
  Future<void> drainOverlayTimer(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 6));

  testWidgets('empty list renders without a setState-during-build error',
      (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);

    await pumpViewer(tester, db);

    expect(find.byType(EmptySite), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting a mid-list site clamps the page counter into range',
      (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await seedSite(db);
    final middleId = await seedSite(db);
    await seedSite(db);

    final container = await pumpViewer(tester, db);

    // Three sites, sitting on the first page.
    expect(find.byType(SitePages), findsOneWidget);
    expect(find.text('Page 1 of 3'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);

    // Delete the middle site the way the menu bar does: query + invalidate.
    await SiteQuery(db).deleteSite(middleId);
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    // The counter is reconciled to the shrunk list, not left out of range.
    expect(find.text('Page 1 of 2'), findsAtLeastNWidgets(1));
    expect(find.text('Page 1 of 3'), findsNothing);
    expect(tester.takeException(), isNull);
    expect((await SiteQuery(db).getAllSites(projectUuid)).length, 2);

    await drainOverlayTimer(tester);
  });

  testWidgets('deleting the last page while viewing it clamps back one page',
      (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await seedSite(db);
    await seedSite(db);
    final lastId = await seedSite(db);

    final container = await pumpViewer(tester, db);

    // Navigate to the last page (3 of 3).
    await tester.fling(find.byType(PageView), const Offset(-600, 0), 2000);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-600, 0), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));

    // Delete the record we're sitting on; currentPage (3) now exceeds the new
    // count (2) and must be clamped instead of rendering "Page 3 of 2".
    await SiteQuery(db).deleteSite(lastId);
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    expect(find.text('Page 2 of 2'), findsAtLeastNWidgets(1));
    expect(find.text('Page 3 of 2'), findsNothing);
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });

  testWidgets('deleting the last remaining site shows the empty state',
      (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    final onlyId = await seedSite(db);

    final container = await pumpViewer(tester, db);
    expect(find.byType(SitePages), findsOneWidget);

    await SiteQuery(db).deleteSite(onlyId);
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    expect(find.byType(EmptySite), findsOneWidget);
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });
}
