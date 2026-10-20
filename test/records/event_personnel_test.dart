import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/events/components/personnel.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';

void main() {
  testWidgets('add personnel shows a new row right away', (tester) async {
    final harness = await _EventPersonnelHarness.create();
    addTearDown(harness.dispose);

    await harness.pump(tester);
    expect(find.text('No personnel added'), findsOneWidget);
    expect(find.byType(EventPersonnelField), findsNothing);

    await tester.tap(find.text('Add personnel'));
    await tester.pumpAndSettle();

    expect(find.text('No personnel added'), findsNothing);
    expect(find.byType(EventPersonnelField), findsOneWidget);
    expect(await harness.getEventPersonnel(), hasLength(1));
  });

  testWidgets('selected personnel persists and more rows can be added', (
    tester,
  ) async {
    final harness = await _EventPersonnelHarness.create();
    addTearDown(harness.dispose);

    await harness.pump(tester);
    await tester.tap(find.text('Add personnel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alice Cataloger').last);
    await tester.pumpAndSettle();

    final rows = await harness.getEventPersonnel();
    expect(rows.single.personnelId, 'cataloger-a');
    expect(rows.single.name, 'Alice Cataloger');

    await tester.tap(find.text('Add personnel'));
    await tester.pumpAndSettle();

    expect(find.byType(EventPersonnelField), findsNWidgets(2));
    expect(find.text('Alice Cataloger'), findsOneWidget);
    expect(await harness.getEventPersonnel(), hasLength(2));
  });

  testWidgets('personnel no longer in the project keeps its stored name', (
    tester,
  ) async {
    final harness = await _EventPersonnelHarness.create();
    addTearDown(harness.dispose);
    await harness.database
        .into(harness.database.collPersonnel)
        .insert(
          CollPersonnelCompanion(
            eventID: Value(harness.eventId),
            personnelId: const Value('former-a'),
            name: const Value('Former Member'),
          ),
        );

    await harness.pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(EventPersonnelField), findsOneWidget);
    expect(find.text('Former Member'), findsOneWidget);
  });
}

class _EventPersonnelHarness {
  _EventPersonnelHarness(this.database, this.container, this.eventId);

  final Database database;
  final ProviderContainer container;
  final int eventId;

  static Future<_EventPersonnelHarness> create() async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        userDefinedFieldProvider.overrideWith(
          (ref, prefKey) async => getDefaultOptionsList(prefKey),
        ),
      ],
    );
    container.read(projectUuidProvider.notifier).updateProjectUuid('project-a');

    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    await database.batch((batch) {
      batch.insertAll(database.personnel, const [
        PersonnelCompanion(
          uuid: Value('cataloger-a'),
          name: Value('Alice Cataloger'),
          role: Value('Cataloger'),
        ),
        PersonnelCompanion(
          uuid: Value('preparator-a'),
          name: Value('Pat Preparator'),
          role: Value('Preparator only'),
        ),
        PersonnelCompanion(
          uuid: Value('former-a'),
          name: Value('Former Member'),
          role: Value('Preparator only'),
        ),
      ]);
      batch.insertAll(database.personnelList, const [
        PersonnelListCompanion(
          projectUuid: Value('project-a'),
          personnelUuid: Value('cataloger-a'),
        ),
        PersonnelListCompanion(
          projectUuid: Value('project-a'),
          personnelUuid: Value('preparator-a'),
        ),
      ]);
    });
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion(projectUuid: Value('project-a')));

    return _EventPersonnelHarness(database, container, eventId);
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EventPersonnel(eventID: eventId),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<List<CollPersonnelData>> getEventPersonnel() {
    return (database.select(
      database.collPersonnel,
    )..where((row) => row.eventID.equals(eventId))).get();
  }

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}
