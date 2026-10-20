import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/shared/capture_records.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
  testWidgets('coordinate choices stay readable without a name', (
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
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    final siteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
    final coordinateId = await database
        .into(database.coordinate)
        .insert(
          CoordinateCompanion(
            decimalLatitude: const Value(7.92282),
            decimalLongitude: const Value(124.84347),
            elevationInMeter: const Value(1869),
            siteID: Value(siteId),
          ),
        );
    final eventId = await database
        .into(database.collEvent)
        .insert(
          CollEventCompanion(
            projectUuid: const Value('project-a'),
            siteID: Value(siteId),
          ),
        );
    await database
        .into(database.specimen)
        .insert(const SpecimenCompanion(uuid: Value('specimen-a')));
    final controller = SpecimenFormCtrModel.empty()
      ..collEventIDCtr = eventId
      ..coordinateCtr = coordinateId;
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: CoordinateField(
              specimenUuid: 'specimen-a',
              specimenCtr: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('7.92282, 124.84347 · 1869 m'), findsOneWidget);
  });
}
