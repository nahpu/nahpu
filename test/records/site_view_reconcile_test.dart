import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/menu_bar.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/sites.dart';

/// Regression tests for the issue #132 in-place refresh: they drive the real
/// [SiteViewer] against an in-memory database, exercising the same
/// `ref.listen`/`_reconcile` path as the running app.
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
    return db
        .into(db.site)
        .insert(const SiteCompanion(projectUuid: Value(projectUuid)));
  }

  // PageViewer schedules a one-shot 5s timer to hide the page-number overlay;
  // fire it so no timer is pending when the tree is disposed.
  Future<void> drainOverlayTimer(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 6));

  testWidgets('empty list renders without a setState-during-build error', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);

    await pumpViewer(tester, db);

    expect(find.byType(EmptySite), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting a mid-list site clamps the page counter into range', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await seedSite(db);
    final middleId = await seedSite(db);
    await seedSite(db);

    final container = await pumpViewer(tester, db);

    expect(find.byType(SitePages), findsOneWidget);
    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);

    // Delete the middle site the way the menu bar does: query + invalidate.
    await SiteQuery(db).deleteSite(middleId);
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    expect(find.text('Page 2 of 2'), findsAtLeastNWidgets(1));
    expect(find.text('Page 3 of 3'), findsNothing);
    expect(tester.takeException(), isNull);
    expect((await SiteQuery(db).getAllSites(projectUuid)).length, 2);

    await drainOverlayTimer(tester);
  });

  testWidgets('deleting the last page while viewing it clamps back one page', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await seedSite(db);
    await seedSite(db);
    final lastId = await seedSite(db);

    final container = await pumpViewer(tester, db);

    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));

    // Delete the record we're sitting on; currentPage must clamp from 3 to 2
    // instead of rendering "Page 3 of 2".
    await SiteQuery(db).deleteSite(lastId);
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    expect(find.text('Page 2 of 2'), findsAtLeastNWidgets(1));
    expect(find.text('Page 3 of 2'), findsNothing);
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });

  testWidgets('deleting the last remaining site shows the empty state', (
    tester,
  ) async {
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

  testWidgets('first load points the menu at the visible record', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    final onlyId = await seedSite(db);

    await pumpViewer(tester, db);

    // onPageChanged never fires for the initially shown page, so a null id
    // here would leave Duplicate/Delete and search permanently disabled.
    final menu = tester.widget<SiteMenu>(find.byType(SiteMenu));
    expect(menu.siteId, onlyId);

    await drainOverlayTimer(tester);
  });

  testWidgets('first load lands on the last record', (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await seedSite(db);
    await seedSite(db);
    final lastId = await seedSite(db);

    await pumpViewer(tester, db);

    // Matches the old behavior: a viewer opens on the most recent record.
    // Assert the real viewport, not just the counter text — the counter reads
    // bookkeeping and can lie about the view.
    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller;
    expect(controller?.page, 2.0);
    expect(tester.widget<SiteMenu>(find.byType(SiteMenu)).siteId, lastId);
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });

  testWidgets('creating a site lands on the new record', (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await seedSite(db);
    await seedSite(db);

    final container = await pumpViewer(tester, db);
    expect(find.text('Page 2 of 2'), findsAtLeastNWidgets(1));

    // Simulate the menu bar's create flow: insert the record, file the
    // pending jump under its id, and invalidate the list.
    final newId = await seedSite(db);
    container
            .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
            .state =
        newId;
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    // Lands on the new record and consumes the one-shot request. Check the
    // real viewport too — a counter-only check can pass while the view stays
    // behind.
    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller;
    expect(controller?.page, 2.0);
    expect(tester.widget<SiteMenu>(find.byType(SiteMenu)).siteId, newId);
    expect(
      container.read(pendingRecordJumpProvider(RecordViewer.site)),
      isNull,
    );
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });

  testWidgets('creating from a non-last page lands on the new record', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    for (var i = 0; i < 4; i++) {
      await seedSite(db);
    }

    final container = await pumpViewer(tester, db);

    // First load lands on 4 of 4; swipe back into the middle of the list.
    await tester.fling(find.byType(PageView), const Offset(600, 0), 2000);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(600, 0), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Page 2 of 4'), findsAtLeastNWidgets(1));

    final newId = await seedSite(db);
    container
            .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
            .state =
        newId;
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    // Regression guard: a live-controller jump raced the refreshed list's
    // layout and stuck the view one page short. The keyed controller swap
    // must land the real viewport on the new record.
    expect(find.text('Page 5 of 5'), findsAtLeastNWidgets(1));
    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller;
    expect(controller?.page, 4.0);
    expect(tester.widget<SiteMenu>(find.byType(SiteMenu)).siteId, newId);
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });

  testWidgets('creating while searching exits search and lands last', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await seedSite(db);
    await seedSite(db);
    final container = await pumpViewer(tester, db);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsOneWidget);

    final newId = await seedSite(db);
    container
        .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
        .updateState(newId);
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsNothing);
    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    expect(tester.widget<SiteMenu>(find.byType(SiteMenu)).siteId, newId);
    await drainOverlayTimer(tester);
  });
}
