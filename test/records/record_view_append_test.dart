import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/events/components/menu_bar.dart';
import 'package:nahpu/screens/events/event_view.dart';
import 'package:nahpu/screens/narrative/components/menu_bar.dart';
import 'package:nahpu/screens/narrative/narrative_view.dart';
import 'package:nahpu/screens/specimens/shared/menu_bar.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const projectUuid = 'project-append';

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => '/tmp');
  });

  Future<ProviderContainer> pumpViewer(
    WidgetTester tester,
    Database database,
    Widget viewer,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({
      catalogFmtPrefKey: 'General Mammals',
    });
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
        child: MaterialApp(home: viewer),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<Database> createDatabase() async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value(projectUuid),
            name: Value('Append project'),
          ),
        );
    return database;
  }

  Future<int> seedEvent(Database database) async {
    final id = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion(projectUuid: Value(projectUuid)));
    await database
        .into(database.weather)
        .insert(WeatherCompanion(eventID: Value(id)));
    return id;
  }

  Future<int> seedNarrative(Database database) {
    return database
        .into(database.narrative)
        .insert(const NarrativeCompanion(projectUuid: Value(projectUuid)));
  }

  Future<void> seedSpecimen(Database database, String uuid) async {
    await database
        .into(database.specimen)
        .insert(
          SpecimenCompanion(
            uuid: Value(uuid),
            projectUuid: const Value(projectUuid),
            taxonGroup: const Value('General Mammals'),
          ),
        );
    await database
        .into(database.mammalAttribute)
        .insert(MammalAttributeCompanion.insert(specimenUuid: uuid));
  }

  Future<void> drainOverlayTimer(WidgetTester tester) {
    return tester.pump(const Duration(seconds: 6));
  }

  testWidgets('new event opens as the last event form', (tester) async {
    final database = await createDatabase();
    await seedEvent(database);
    await seedEvent(database);
    final container = await pumpViewer(
      tester,
      database,
      const CollEventViewer(),
    );

    final newId = await seedEvent(database);
    container
        .read(pendingRecordJumpProvider(RecordViewer.collEvent).notifier)
        .updateState(newId);
    container.invalidate(collEventEntryProvider);
    await tester.pumpAndSettle();

    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    final pager = find.descendant(
      of: find.byType(CollEventPages),
      matching: find.byType(PageView),
    );
    expect(tester.widget<PageView>(pager.first).controller?.page, 2);
    expect(
      tester.widget<CollEventMenu>(find.byType(CollEventMenu)).collEventId,
      newId,
    );
    await drainOverlayTimer(tester);
  });

  testWidgets('new narrative opens as the last narrative form', (tester) async {
    final database = await createDatabase();
    await seedNarrative(database);
    await seedNarrative(database);
    final container = await pumpViewer(
      tester,
      database,
      const NarrativeViewer(),
    );

    final newId = await seedNarrative(database);
    container
        .read(pendingRecordJumpProvider(RecordViewer.narrative).notifier)
        .updateState(newId);
    container.invalidate(narrativeEntryProvider);
    await tester.pumpAndSettle();

    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    final pager = find.descendant(
      of: find.byType(NarrativePages),
      matching: find.byType(PageView),
    );
    expect(tester.widget<PageView>(pager.first).controller?.page, 2);
    expect(
      tester.widget<NarrativeMenu>(find.byType(NarrativeMenu)).narrativeId,
      newId,
    );
    await drainOverlayTimer(tester);
  });

  testWidgets('new specimen opens as the last specimen form', (tester) async {
    final database = await createDatabase();
    await seedSpecimen(database, 'z-first');
    await seedSpecimen(database, 'm-second');
    final container = await pumpViewer(
      tester,
      database,
      const SpecimenViewer(),
    );

    const newUuid = 'a-third';
    await seedSpecimen(database, newUuid);
    container
        .read(pendingRecordJumpProvider(RecordViewer.specimen).notifier)
        .updateState(newUuid);
    container.invalidate(specimenEntryProvider);
    await tester.pumpAndSettle();

    expect(find.text('Page 3 of 3'), findsAtLeastNWidgets(1));
    final pager = find.descendant(
      of: find.byType(SpecimenPages),
      matching: find.byType(PageView),
    );
    expect(tester.widget<PageView>(pager.first).controller?.page, 2);
    expect(
      tester.widget<SpecimenMenu>(find.byType(SpecimenMenu)).specimenUuid,
      newUuid,
    );
    await drainOverlayTimer(tester);
  });
}
