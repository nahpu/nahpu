import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deleting a project runs from the rail menu panel. The shell used to dismiss
/// that panel the moment the confirmation dialog took focus, unmounting the
/// tile whose `ref` and `context` the deletion still needed — so nothing was
/// deleted and, because both outcome paths were gated on `context.mounted`,
/// nothing was reported either.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'abcde-doomed-project';

  // Project media cleanup touches path_provider.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => '/tmp');
  });

  // Lightweight stand-ins for the five real project screens.
  const pages = [
    Text('PAGE-Dashboard'),
    Text('PAGE-Sites'),
    Text('PAGE-Events'),
    Text('PAGE-Specimens'),
    Text('PAGE-Narrative'),
  ];

  Future<Database> pumpShellWithProject(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value(projectUuid),
            name: Value('Doomed project'),
          ),
        );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        settingProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);
    container.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProjectShell(pages: pages)),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  Future<void> openDeleteDialog(WidgetTester tester) async {
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete project'));
    await tester.pumpAndSettle();
  }

  testWidgets('the rail menu deletes the project', (tester) async {
    final database = await pumpShellWithProject(tester);

    await openDeleteDialog(tester);

    expect(find.text('Delete project?'), findsOneWidget);
    // The panel — and the tile driving the deletion — outlives the dialog.
    expect(find.text('Delete project'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'abcde');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(await database.select(database.project).get(), isEmpty);
  });

  testWidgets('the menu closes once its dialog is dismissed', (tester) async {
    final database = await pumpShellWithProject(tester);

    await openDeleteDialog(tester);
    expect(find.byType(NavigationDrawer), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // The menu is held open only for the dialog's lifetime.
    expect(find.text('Delete project?'), findsNothing);
    expect(find.byType(NavigationDrawer), findsNothing);
    expect(await database.select(database.project).get(), hasLength(1));
  });
}
