import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/menu_bar.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/record_sort.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/types/record_sort.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the real [SiteViewer] across a sort change: the pages reorder, the
/// record the user was reading stays on screen, and creating a record still
/// lands on it even though it is no longer last in the list.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'project-sort-view';

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => '/tmp');
  });

  Future<ProviderContainer> pumpViewer(WidgetTester tester, Database db) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);
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

  Future<int> seedSite(Database db, String siteId) {
    return db
        .into(db.site)
        .insert(
          SiteCompanion(
            projectUuid: const Value(projectUuid),
            siteID: Value(siteId),
          ),
        );
  }

  Future<void> drainOverlayTimer(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 6));

  int? menuSiteId(WidgetTester tester) =>
      tester.widget<SiteMenu>(find.byType(SiteMenu)).siteId;

  testWidgets('changing the sort reorders pages and keeps the record', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    final siteC = await seedSite(db, 'C');
    final siteA = await seedSite(db, 'A');
    final siteB = await seedSite(db, 'B');

    final container = await pumpViewer(tester, db);
    // Insertion order: C, A, B — first load opens on the newest, B.
    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    expect(menuSiteId(tester), siteB);

    await container
        .read(recordSortProvider(RecordViewer.site).notifier)
        .set(const RecordSort(field: RecordSortField.siteName));
    await tester.pumpAndSettle();

    // Site ID order is A, B, C, so B moves from page 3 to page 2. The user
    // keeps reading the same record; only its page number changes.
    expect(find.text('Page 2 of 3'), findsAtLeastNWidgets(1));
    expect(menuSiteId(tester), siteB);

    await container
        .read(recordSortProvider(RecordViewer.site).notifier)
        .set(
          const RecordSort(
            field: RecordSortField.siteName,
            direction: RecordSortDirection.descending,
          ),
        );
    await tester.pumpAndSettle();

    // Reversed to C, B, A: B is still page 2, and A and C swapped ends.
    expect(find.text('Page 2 of 3'), findsAtLeastNWidgets(1));
    expect(menuSiteId(tester), siteB);
    final sites = await container.read(siteEntryProvider.future);
    expect(sites.map((site) => site.id), [siteC, siteB, siteA]);

    await drainOverlayTimer(tester);
  });

  testWidgets('a new record is still landed on under a non-default sort', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await seedSite(db, 'B');
    await seedSite(db, 'C');

    final container = await pumpViewer(tester, db);
    await container
        .read(recordSortProvider(RecordViewer.site).notifier)
        .set(const RecordSort(field: RecordSortField.siteName));
    await tester.pumpAndSettle();

    // "A" sorts to the front, not the end, so the id-keyed handoff — not the
    // old land-on-the-last-page rule — is what has to find it.
    final newId = await seedSite(db, 'A');
    container
        .read(pendingRecordJumpProvider(RecordViewer.site).notifier)
        .updateState(newId);
    container.invalidate(siteEntryProvider);
    await tester.pumpAndSettle();

    expect(find.text('Page 1 of 3'), findsAtLeastNWidgets(1));
    expect(menuSiteId(tester), newId);
    expect(
      container.read(pendingRecordJumpProvider(RecordViewer.site)),
      isNull,
    );
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });

  testWidgets('a recreated State restores the record under a sort', (
    tester,
  ) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    final siteC = await seedSite(db, 'C');
    await seedSite(db, 'A');
    await seedSite(db, 'B');

    final container = await pumpViewer(tester, db);
    await container
        .read(recordSortProvider(RecordViewer.site).notifier)
        .set(const RecordSort(field: RecordSortField.siteName));
    await tester.pumpAndSettle();

    // Move to C, the last page under the A, B, C ordering.
    final pageView = find.byWidgetPredicate(
      (widget) => widget is PageView && widget.key is ObjectKey,
      description: 'site record PageView',
    );
    await tester.fling(pageView, const Offset(-600, 0), 2000);
    await tester.pumpAndSettle();
    expect(menuSiteId(tester), siteC);

    // Rotate/resize: the State is recreated, but the sort and the position
    // both live outside it.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: SiteViewer(key: UniqueKey())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Page 0 of 0'), findsNothing);
    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    expect(menuSiteId(tester), siteC);
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });
}
