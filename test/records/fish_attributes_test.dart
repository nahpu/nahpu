import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/screens/specimens/fishes/attributes.dart';
import 'package:nahpu/screens/specimens/shared/individual_selector.dart';
import 'package:nahpu/screens/specimens/shared/specimen_parts.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

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
    expect(find.text('Many individuals stored together'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('fish-specimen-type')),
        matching: find.byIcon(Icons.layers_outlined),
      ),
      findsOneWidget,
    );
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
    final autoRange = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('fish-auto-range')),
    );
    expect(
      autoRange.contentPadding,
      const EdgeInsets.symmetric(horizontal: NahpuSpacing.xs),
    );
    expect(
      tester.getTopLeft(find.text('Auto-update min and max')).dx,
      tester.getTopLeft(find.text('Total individuals')).dx,
    );
    final individualsBox = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Individuals'),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = individualsBox.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
    expect(decoration.borderRadius, BorderRadius.circular(NahpuRadius.lg));
    expect(minField.controller!.text, '40');
    expect(find.text('Individual A1'), findsOneWidget);
    expect(find.text('45 mm'), findsOneWidget);
    expect(find.text('± 7.1 SD · n = 2'), findsOneWidget);
    expect(find.text('Range 40–50 mm'), findsOneWidget);
    expect(find.text('2 measured'), findsOneWidget);
    expect(find.text('Not measured'), findsNWidgets(2));
  });

  testWidgets('individual form auto-numbers tags and saves another', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      individualTagPrefixKey: 'FT-',
      individualTagNumberKey: '0009',
      individualTagSuffixKey: '-A',
    });
    final preferences = await SharedPreferences.getInstance();
    final database = await _seedFish(specimenType: FishSpecimenType.lot);
    addTearDown(database.close);
    await _pump(
      tester,
      database,
      const FishAttributeForms(useHorizontalLayout: true, specimenUuid: 'fish'),
      preferences: preferences,
    );

    await tester.ensureVisible(find.text('Add individual'));
    await tester.tap(find.text('Add individual'));
    await tester.pumpAndSettle();

    // Wide screens get the two-column dialog.
    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Measurements'), findsOneWidget);
    expect(find.text('Auto-numbered. Edit to override.'), findsOneWidget);
    final tag = find.byKey(const ValueKey('individual-id'));
    expect(tester.widget<TextField>(tag).controller!.text, 'FT-0009-A');

    await tester.enterText(
      find.byKey(const ValueKey('individual-standard-length')),
      '42',
    );
    await tester.tap(find.byKey(const ValueKey('individual-save-another')));
    await tester.pumpAndSettle();

    // The auto tag advances, padded, and the form resets for the next one.
    expect(tester.widget<TextField>(tag).controller!.text, 'FT-0010-A');
    expect(find.text('1 entered'), findsOneWidget);

    // An override is saved as typed and does not use up a number.
    await tester.enterText(tag, 'Tag 77');
    await tester.pump();
    expect(find.text('Auto-numbered. Edit to override.'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('individual-save')));
    await tester.pumpAndSettle();

    final tags = (await database.select(database.specimenIndividual).get()).map(
      (e) => e.individualID,
    );
    expect(tags, ['FT-0009-A', 'Tag 77']);
    expect(preferences.getString(individualTagNumberKey), '0010');
  });

  testWidgets('individual form is a one-column sheet on phones', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = await _seedFish(specimenType: FishSpecimenType.lot);
    addTearDown(database.close);
    await _pump(
      tester,
      database,
      const FishAttributeForms(
        useHorizontalLayout: false,
        specimenUuid: 'fish',
      ),
      preferences: preferences,
    );

    await tester.ensureVisible(find.text('Add individual'));
    await tester.tap(find.text('Add individual'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Identity'), findsNothing);
    // Without numbering set up, the tag falls back to the next count.
    final tag = find.byKey(const ValueKey('individual-id'));
    expect(tester.widget<TextField>(tag).controller!.text, '1');
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
    expect(find.byType(InputChip), findsNothing);
    expect(find.text('Individuals'), findsNothing);
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

    expect(find.text('None selected'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('individual-add-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1').last);
    await tester.pumpAndSettle();
    expect(controller.individualIds, {id});
    expect(find.widgetWithText(InputChip, 'A1'), findsOneWidget);
    expect(find.text('All individuals added'), findsOneWidget);

    // Tapping the tag itself does not unlink it.
    await tester.tap(find.widgetWithText(InputChip, 'A1'));
    await tester.pump();
    expect(controller.individualIds, {id});

    // Removing asks first; cancelling keeps the link.
    await tester.tap(find.byTooltip('Remove A1'));
    await tester.pumpAndSettle();
    expect(find.text('Remove A1?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.individualIds, {id});

    await tester.tap(find.byTooltip('Remove A1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(controller.individualIds, isEmpty);
    expect(find.text('None selected'), findsOneWidget);
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

Future<void> _pump(
  WidgetTester tester,
  Database database,
  Widget child, {
  SharedPreferences? preferences,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        if (preferences != null) settingProvider.overrideWithValue(preferences),
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
