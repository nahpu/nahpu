import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/events/components/media.dart';
import 'package:nahpu/screens/events/components/tab_bar.dart';
import 'package:nahpu/screens/events/event_view.dart';
import 'package:nahpu/screens/shared/media/media.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'event-media-layout-project';

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async => '/tmp');
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  testWidgets('event media is a standalone section below the event tabs', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1800);
    addTearDown(tester.view.reset);

    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value(projectUuid),
            name: Value('Event media layout'),
          ),
        );
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion(projectUuid: Value(projectUuid)));
    await database
        .into(database.environment)
        .insert(EnvironmentCompanion(eventID: Value(eventId)));

    SharedPreferences.setMockInitialValues(const {});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        settingProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);
    container.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CollEventViewer()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EventMediaForm), findsOneWidget);
    expect(find.byType(MediaViewer), findsOneWidget);
    expect(find.text('No media added'), findsOneWidget);

    final eventTabBar = find.descendant(
      of: find.byType(CollEventTabBar),
      matching: find.byType(TabBar),
    );
    expect(eventTabBar, findsOneWidget);
    expect(tester.widget<TabBar>(eventTabBar).tabs, hasLength(3));
    expect(
      tester.getTopLeft(find.byType(EventMediaForm)).dy,
      greaterThan(tester.getTopLeft(find.byType(CollEventTabBar)).dy),
    );
    await tester.pump(const Duration(seconds: 6));
  });
}
