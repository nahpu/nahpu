import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/action_buttons.dart';
import 'package:nahpu/screens/shared/project_shell.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression tests for the Dashboard `+` speed dial (issue #132): creating a
/// record must switch the shell to the tab that shows it, not silently insert
/// behind the Dashboard.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'proj-1';

  setUpAll(() {
    // SiteForm's media/coordinate components touch path_provider.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => '/tmp');
  });

  Future<ProviderContainer> pumpShell(WidgetTester tester, Database db) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);
    container.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);

    // collEvent (unlike site) enforces its projectUuid foreign key, so the
    // project row must exist before any create.
    await db.into(db.project).insert(const ProjectCompanion(
          uuid: Value(projectUuid),
          name: Value('Test project'),
        ));

    // Dashboard and Sites slots are real (ActionButtons / SiteViewer) so the
    // test can assert the new record is actually shown; the rest are stand-ins.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ProjectShell(pages: [
            Scaffold(
              body: Text('PAGE-Dashboard'),
              floatingActionButton: ActionButtons(),
            ),
            SiteViewer(),
            Text('PAGE-Events'),
            Text('PAGE-Specimens'),
            Text('PAGE-Narrative'),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  // PageViewer schedules a one-shot 5s timer to hide the page-number overlay;
  // fire it so no timer is pending when the tree is disposed.
  Future<void> drainOverlayTimer(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 6));

  testWidgets(
      'Dashboard + > Create site switches to the Sites tab on the new record',
      (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);

    final container = await pumpShell(tester, db);
    expect(container.read(projectNavbarIndexProvider), 0);

    await tester.tap(find.byType(SpeedDial));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create site'));
    await tester.pumpAndSettle();

    expect(container.read(projectNavbarIndexProvider), 1);
    expect(find.text('Page 1 of 1'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);

    await drainOverlayTimer(tester);
  });

  testWidgets('Dashboard + > Create event switches to the Events tab',
      (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);

    final container = await pumpShell(tester, db);

    await tester.tap(find.byType(SpeedDial));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create event'));
    await tester.pumpAndSettle();

    expect(container.read(projectNavbarIndexProvider), 2);
    expect(find.text('PAGE-Events'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
