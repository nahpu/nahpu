import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/fishes/attributes.dart';
import 'package:nahpu/screens/specimens/shared/individual_selector.dart';
import 'package:nahpu/screens/specimens/shared/specimen_parts.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  testWidgets('switching a fish record to a lot shows the lot fields', (
    tester,
  ) async {
    final database = await _seedFish();
    addTearDown(database.close);
    await _pump(
      tester,
      database,
      const FishAttributeForms(useHorizontalLayout: true, specimenUuid: 'fish'),
    );

    expect(find.text('Standard length (mm)'), findsOneWidget);
    expect(find.text('Total individuals'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('fish-specimen-type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lot').last);
    await tester.pumpAndSettle();

    expect(find.text('Standard length (mm)'), findsNothing);
    expect(find.text('Total individuals'), findsOneWidget);
    expect(find.text('Lot summary'), findsOneWidget);
    expect(find.text('Add individual'), findsOneWidget);
    final stored = await database.select(database.fishAttribute).getSingle();
    expect(stored.specimenType, FishSpecimenType.lot.index);
  });

  testWidgets('auto-updated lot ranges are read-only and follow individuals', (
    tester,
  ) async {
    final database = await _seedFish(specimenType: FishSpecimenType.lot);
    addTearDown(database.close);
    for (final (id, length) in [('A1', 40.0), ('A2', 50.0)]) {
      await database
          .into(database.specimenIndividual)
          .insert(
            SpecimenIndividualCompanion(
              specimenUuid: const Value('fish'),
              individualID: Value(id),
              standardLength: Value(length),
            ),
          );
    }
    await database
        .update(database.fishAttribute)
        .write(
          const FishAttributeCompanion(
            minStandardLength: Value(40),
            maxStandardLength: Value(50),
          ),
        );
    await _pump(
      tester,
      database,
      const FishAttributeForms(useHorizontalLayout: true, specimenUuid: 'fish'),
    );

    final minField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('fish-min-standard-length')),
        matching: find.byType(TextField),
      ),
    );
    expect(minField.enabled, isFalse);
    expect(minField.controller!.text, '40');
    expect(find.text('Individual A1'), findsOneWidget);
    expect(find.text('Mean 45 ± 7.07 SD'), findsOneWidget);
  });

  testWidgets('part form hides the individual picker without individuals', (
    tester,
  ) async {
    final database = await _seedFish(specimenType: FishSpecimenType.lot);
    addTearDown(database.close);
    await _pump(
      tester,
      database,
      PartIdForm(specimenUuid: 'fish', partCtr: PartFormCtrModel.empty()),
    );

    expect(find.byType(SpecimenIndividualSelector), findsOneWidget);
    expect(find.byType(FilterChip), findsNothing);
  });

  testWidgets('part form links the selected individuals', (tester) async {
    final database = await _seedFish(specimenType: FishSpecimenType.lot);
    addTearDown(database.close);
    final id = await database
        .into(database.specimenIndividual)
        .insert(
          const SpecimenIndividualCompanion(
            specimenUuid: Value('fish'),
            individualID: Value('A1'),
          ),
        );
    final controller = PartFormCtrModel.empty();
    await _pump(
      tester,
      database,
      PartIdForm(specimenUuid: 'fish', partCtr: controller),
    );

    expect(find.widgetWithText(FilterChip, 'A1'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'A1'));
    await tester.pump();
    expect(controller.individualIds, {id});
  });
}

Future<Database> _seedFish({
  FishSpecimenType specimenType = FishSpecimenType.individual,
}) async {
  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  await database
      .into(database.project)
      .insert(
        const ProjectCompanion(uuid: Value('project'), name: Value('Project')),
      );
  await database
      .into(database.specimen)
      .insert(
        const SpecimenCompanion(
          uuid: Value('fish'),
          projectUuid: Value('project'),
          taxonGroup: Value('Fishes'),
        ),
      );
  await database
      .into(database.fishAttribute)
      .insert(
        FishAttributeCompanion(
          specimenUuid: const Value('fish'),
          specimenType: Value(specimenType.index),
          isAutoRange: const Value(1),
          weightUnit: const Value('g'),
        ),
      );
  return database;
}

Future<void> _pump(WidgetTester tester, Database database, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        specimenSexVocabularyProvider.overrideWith(
          (ref) async => allowedSpecimenSexes,
        ),
        userDefinedFieldProvider.overrideWith((ref, prefKey) async => const []),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 900, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
