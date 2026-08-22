import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/events/components/environment_data.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/controllers.dart';
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
    final data = await database.select(database.environment).getSingle();

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
                environmentCtr: CollEnvironmentCtrModel.fromData(data),
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
    final data = await database.select(database.environment).getSingle();

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
                environmentCtr: CollEnvironmentCtrModel.fromData(data),
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
}
