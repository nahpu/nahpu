import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/events/components/environment_data.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
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
    await tester.tap(find.byKey(const ValueKey('environment-cloud-cover')));
    await tester.pumpAndSettle();
    for (var index = 0; index <= 8; index++) {
      expect(find.text('$index — $index/8'), findsOneWidget);
    }
    expect(find.text('9 — Sky obscured'), findsOneWidget);
    await tester.tap(find.text('9 — Sky obscured'));
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
