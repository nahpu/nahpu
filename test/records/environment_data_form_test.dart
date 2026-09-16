import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/events/components/environment_data.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/events.dart';

void main() {
  testWidgets('Environmental Data shows only the five default fields', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project'),
            name: Value('Project'),
          ),
        );
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion(projectUuid: Value('project')));
    await database
        .into(database.environment)
        .insert(
          EnvironmentCompanion(
            eventID: Value(eventId),
            waterTemperature: const Value(22),
          ),
        );
    final data = await EnvironmentDataQuery(
      database,
    ).getEditableEnvironmentDataByEventId(eventId);

    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvironmentDataForm(
                useHorizontalLayout: false,
                eventID: eventId,
                environmentData: data,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ambient temperature (°C)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('environment-ambient-humidity')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('environment-cloud-cover')),
      findsOneWidget,
    );
    expect(find.text('Rainfall (mm)'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Environmental measurements'), findsNothing);
    expect(find.text('Water temperature (°C)'), findsNothing);
    expect(find.text('Aquatic Data'), findsNothing);
    expect(find.text('Add custom field'), findsOneWidget);
    expect(find.byTooltip('Manage custom fields'), findsOneWidget);

    final customFieldPanel = find
        .ancestor(
          of: find.text('Custom fields'),
          matching: find.byType(Container),
        )
        .last;
    expect(
      tester.getTopLeft(customFieldPanel).dx,
      tester
          .getTopLeft(
            find.byKey(const ValueKey('environment-ambient-humidity')),
          )
          .dx,
    );
    expect(
      (await database.select(database.environment).getSingle())
          .waterTemperature,
      22,
    );
  });

  testWidgets('Environmental Data validates ranges and stores oktas codes', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion());
    await database
        .into(database.environment)
        .insert(EnvironmentCompanion(eventID: Value(eventId)));
    final data = await EnvironmentDataQuery(
      database,
    ).getEditableEnvironmentDataByEventId(eventId);

    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvironmentDataForm(
                useHorizontalLayout: false,
                eventID: eventId,
                environmentData: data,
                visibleFields: environmentalDataFields.toSet(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aquatic Data'), findsOneWidget);
    expect(find.text('Water temperature (°C)'), findsOneWidget);
    expect(find.text('Dissolved oxygen (mg/L)'), findsOneWidget);
    expect(find.text('Cloud cover (oktas)'), findsOneWidget);
    expect(
      find.text('One okta represents one eighth of the visible sky.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('environment-cloud-cover')));
    await tester.pumpAndSettle();
    for (final label in oktaOptionLabels.values) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text(oktaOptionLabels['9']!));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('environment-average-humidity')),
      '101',
    );
    await tester.pumpAndSettle();
    expect(find.text('Enter a value from 0 to 100'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('environment-ambient-humidity')),
      '88',
    );
    await tester.enterText(find.byKey(const ValueKey('environment-ph')), '15');
    await tester.pumpAndSettle();
    expect(find.text('Enter a value from 0 to 14'), findsOneWidget);

    final stored = await database.select(database.environment).getSingle();
    expect(stored.cloudCover, '9');
    expect(stored.averageHumidity, isNull);
    expect(stored.ambientHumidity, 88);
    expect(stored.pH, isNull);
  });

  testWidgets('shows raw invalid values in their fields on initial load', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion());
    await database
        .into(database.environment)
        .insert(EnvironmentCompanion(eventID: Value(eventId)));
    await database.customStatement(
      "UPDATE environment SET ambientTemperature = 'warm', "
      "averageHumidity = 101, pH = 15, cloudCover = '11', "
      "moonPhase = 'Full moon', notes = X'3132' WHERE eventID = ?",
      [eventId],
    );

    _setLargeView(tester);
    await tester.pumpWidget(
      _environmentViewHarness(database: database, eventId: eventId),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Some stored environmental values need attention (6)'),
      findsOneWidget,
    );
    expect(find.text('warm'), findsOneWidget);
    expect(find.text('101.0'), findsOneWidget);
    expect(find.text('15.0'), findsOneWidget);
    expect(find.text('11 — Invalid stored value'), findsOneWidget);
    expect(find.text('Full moon — Invalid stored value'), findsOneWidget);
    expect(find.text('[49, 50]'), findsOneWidget);
    expect(
      find.text('Stored value is not a finite number. Enter a valid number.'),
      findsOneWidget,
    );
    expect(find.text('Enter a value from 0 to 100'), findsOneWidget);
    expect(find.text('Enter a value from 0 to 14'), findsOneWidget);
    expect(
      find.text('Select a cloud cover value from 0 to 9.'),
      findsOneWidget,
    );
    expect(find.text('Select a supported moon phase.'), findsOneWidget);
    expect(
      find.text('Stored value must be text. Enter a valid value.'),
      findsOneWidget,
    );
    expect(find.text('Ambient humidity (%)'), findsOneWidget);
  });

  testWidgets('repairs a hidden malformed number without changing other data', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion());
    await database
        .into(database.environment)
        .insert(
          EnvironmentCompanion(
            eventID: Value(eventId),
            notes: const Value('Keep this note'),
          ),
        );
    await database.customStatement(
      "UPDATE environment SET waterTemperature = 'warm' WHERE eventID = ?",
      [eventId],
    );

    _setLargeView(tester);
    await tester.pumpWidget(
      _environmentViewHarness(
        database: database,
        eventId: eventId,
        configuredFields: const [],
      ),
    );
    await tester.pumpAndSettle();

    final waterTemperature = find.byKey(
      const ValueKey('environment-water-temperature'),
    );
    expect(waterTemperature, findsOneWidget);
    expect(find.text('warm'), findsOneWidget);

    await tester.enterText(waterTemperature, '-2.5');
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('environment-error-summary')),
      findsNothing,
    );
    expect(waterTemperature, findsOneWidget);
    final stored = await database.select(database.environment).getSingle();
    expect(stored.waterTemperature, -2.5);
    expect(stored.notes, 'Keep this note');
  });

  testWidgets('repairs or clears unsupported dropdown values', (tester) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion());
    await database
        .into(database.environment)
        .insert(
          EnvironmentCompanion(
            eventID: Value(eventId),
            cloudCover: const Value('11'),
            moonPhase: const Value('Full moon'),
          ),
        );

    _setLargeView(tester);
    await tester.pumpWidget(
      _environmentViewHarness(database: database, eventId: eventId),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('environment-cloud-cover')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not recorded').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Some stored environmental values need attention (1)'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('environment-moon-phase')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Full Moon').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('environment-error-summary')),
      findsNothing,
    );
    final stored = await database.select(database.environment).getSingle();
    expect(stored.cloudCover, isNull);
    expect(stored.moonPhase, 'Full Moon');
  });

  testWidgets('keeps a corrected value marked when its write fails', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    final eventId = await database
        .into(database.collEvent)
        .insert(const CollEventCompanion());
    await database
        .into(database.environment)
        .insert(EnvironmentCompanion(eventID: Value(eventId)));
    await database.customStatement(
      "UPDATE environment SET ambientTemperature = 'warm' WHERE eventID = ?",
      [eventId],
    );

    _setLargeView(tester);
    await tester.pumpWidget(
      _environmentViewHarness(database: database, eventId: eventId),
    );
    await tester.pumpAndSettle();
    await database.delete(database.environment).go();

    final field = find.byKey(const ValueKey('environment-ambient-temperature'));
    await tester.enterText(field, '21.5');
    await tester.pumpAndSettle();

    expect(find.text('21.5'), findsOneWidget);
    expect(find.textContaining('Could not save this value:'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('environment-error-summary')),
      findsOneWidget,
    );
  });

  test(
    'editable query reports missing and duplicate environmental rows',
    () async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);
      final eventId = await database
          .into(database.collEvent)
          .insert(const CollEventCompanion());
      final query = EnvironmentDataQuery(database);

      await expectLater(
        query.getEditableEnvironmentDataByEventId(eventId),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('missing'),
          ),
        ),
      );

      await database.batch((batch) {
        batch.insertAll(database.environment, [
          EnvironmentCompanion(eventID: Value(eventId)),
          EnvironmentCompanion(eventID: Value(eventId)),
        ]);
      });
      await expectLater(
        query.getEditableEnvironmentDataByEventId(eventId),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('multiple'),
          ),
        ),
      );
    },
  );

  testWidgets('shows contextual unexpected load errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          environmentDataProvider.overrideWith((ref, eventId) async {
            throw StateError('database offline');
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: EnvironmentDataView(useHorizontalLayout: false, eventID: 4),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'Unable to load environmental data: Bad state: database offline',
      ),
      findsOneWidget,
    );
    expect(find.text('Error'), findsNothing);
  });
}

Widget _environmentViewHarness({
  required Database database,
  required int eventId,
  List<String> configuredFields = defaultVisibleEnvironmentalDataFields,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      userDefinedFieldProvider.overrideWith(
        (ref, prefKey) async => configuredFields,
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: EnvironmentDataView(useHorizontalLayout: false, eventID: eventId),
      ),
    ),
  );
}

void _setLargeView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
