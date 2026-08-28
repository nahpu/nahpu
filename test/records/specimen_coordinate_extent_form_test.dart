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
  testWidgets('coordinate extent persists only an empty or positive value', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.specimen)
        .insert(const SpecimenCompanion(uuid: Value('specimen-a')));
    final controller = SpecimenFormCtrModel.empty();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: CoordinateExtentField(
              specimenUuid: 'specimen-a',
              specimenCtr: controller,
            ),
          ),
        ),
      ),
    );

    final field = find.byType(TextField);
    expect(find.text('Coordinate extent (m)'), findsOneWidget);

    await tester.enterText(field, '12.5');
    await tester.pumpAndSettle();
    expect((await _specimen(database)).coordinateExtentMeters, 12.5);

    await tester.enterText(field, '.');
    await tester.pumpAndSettle();
    expect(
      find.text('Extent must be a number greater than zero'),
      findsOneWidget,
    );
    expect((await _specimen(database)).coordinateExtentMeters, 12.5);

    await tester.enterText(field, '');
    await tester.pumpAndSettle();
    expect((await _specimen(database)).coordinateExtentMeters, isNull);
  });
}

Future<SpecimenData> _specimen(Database database) {
  return (database.select(
    database.specimen,
  )..where((row) => row.uuid.equals('specimen-a'))).getSingle();
}
