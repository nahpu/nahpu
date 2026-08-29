import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/personnel/personnel_form.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/specimens/shared/general_records.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  test('Determiner only is a supported personnel role', () {
    expect(personnelRoleList, contains('Determiner only'));
  });

  test('specimen controller loads the persisted determiner', () {
    final controller = SpecimenFormCtrModel.fromData(
      const SpecimenData(uuid: 'specimen-a', determinerID: 'identifier-a'),
    );
    addTearDown(controller.dispose);

    expect(controller.determinerCtr, 'identifier-a');
  });

  testWidgets('general record uses one card with an identification section', (
    tester,
  ) async {
    final harness = await _SpecimenFormHarness.create();
    addTearDown(harness.dispose);
    final controller = SpecimenFormCtrModel.empty()
      ..catalogerCtr = 'cataloger-a'
      ..persFieldNumberCtr.text = '7'
      ..idConfidenceCtr = 2;
    addTearDown(controller.dispose);

    await harness.pump(
      tester,
      GeneralRecordField(
        specimenUuid: 'specimen-a',
        specimenCtr: controller,
        useHorizontalLayout: false,
      ),
    );

    final card = tester.widget<FormCard>(find.byType(FormCard));
    expect(card.title, 'Collection & Identification');
    expect(card.isPrimary, isTrue);
    expect(card.infoTopic, InfoTopic.specimenGeneralRecord);
    expect(find.byType(FormCardSectionLabel), findsOneWidget);
    final identificationY = tester.getCenter(find.text('Identification')).dy;

    expect(
      tester.getBottomRight(find.byType(SpecimenIdTile)).dy,
      lessThan(identificationY),
    );
    for (final label in const [
      'Cataloger',
      'Preparator',
      'Condition',
      'Collection date',
      'Collection time',
      'Prep. date',
      'Prep. time',
    ]) {
      expect(
        tester.getCenter(find.text(label)).dy,
        lessThan(identificationY),
        reason: label,
      );
    }

    for (final label in const [
      'Taxon',
      'Determiner',
      'ID Confidence',
      'Identification Method',
    ]) {
      expect(
        tester.getCenter(find.text(label)).dy,
        greaterThan(identificationY),
        reason: label,
      );
    }

    final showMore = find.text('Show more');
    await tester.ensureVisible(showMore);
    await tester.tap(showMore);
    await tester.pumpAndSettle();
    expect(find.text('Museum ID'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Museum ID')).dy,
      lessThan(identificationY),
    );
  });

  testWidgets(
    'determiner lists catalogers and determiners and persists selection',
    (tester) async {
      final harness = await _SpecimenFormHarness.create();
      addTearDown(harness.dispose);
      final controller = SpecimenFormCtrModel.empty();
      addTearDown(controller.dispose);

      await harness.pump(
        tester,
        DeterminerField(specimenUuid: 'specimen-a', specimenCtr: controller),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Alice Cataloger'), findsOneWidget);
      expect(find.text('Iris Identifier'), findsOneWidget);
      expect(find.text('Pat Preparator'), findsNothing);

      await tester.tap(find.text('Iris Identifier'));
      await tester.pumpAndSettle();

      expect(controller.determinerCtr, 'identifier-a');
      final specimen = await harness.getSpecimen();
      expect(specimen.determinerID, 'identifier-a');
    },
  );

  testWidgets('cataloger defaults preparator and determiner', (tester) async {
    final harness = await _SpecimenFormHarness.create();
    addTearDown(harness.dispose);
    final controller = SpecimenFormCtrModel.empty();
    addTearDown(controller.dispose);

    await harness.pump(
      tester,
      PersonnelRecords(
        specimenUuid: 'specimen-a',
        specimenCtr: controller,
        onCatalogerChanged: () {},
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alice Cataloger').last);
    await tester.pumpAndSettle();

    expect(controller.catalogerCtr, 'cataloger-a');
    expect(controller.determinerCtr, 'cataloger-a');
    expect(controller.preparatorCtr, 'cataloger-a');

    final specimen = await harness.getSpecimen();
    expect(specimen.catalogerID, 'cataloger-a');
    expect(specimen.determinerID, 'cataloger-a');
    expect(specimen.preparatorID, 'cataloger-a');
    expect(specimen.fieldNumber, 7);
    expect(specimen.projectFieldNumber, isNull);
  });

  testWidgets(
    'cataloger selection does not add a personnel ID to project-number record',
    (tester) async {
      final harness = await _SpecimenFormHarness.create();
      addTearDown(harness.dispose);
      await harness.database
          .update(harness.database.specimen)
          .write(const SpecimenCompanion(projectFieldNumber: Value(42)));
      final controller = SpecimenFormCtrModel.fromData(
        await harness.getSpecimen(),
      );
      addTearDown(controller.dispose);

      await harness.pump(
        tester,
        PersonnelRecords(
          specimenUuid: 'specimen-a',
          specimenCtr: controller,
          onCatalogerChanged: () {},
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alice Cataloger').last);
      await tester.pumpAndSettle();

      final specimen = await harness.getSpecimen();
      final cataloger = await (harness.database.select(
        harness.database.personnel,
      )..where((row) => row.uuid.equals('cataloger-a'))).getSingle();
      expect(specimen.fieldNumber, isNull);
      expect(specimen.projectFieldNumber, 42);
      expect(cataloger.currentFieldNumber, 7);
    },
  );

  testWidgets(
    'Identification Method follows ID Confidence and preserves a hidden legacy value',
    (tester) async {
      final harness = await _SpecimenFormHarness.create();
      addTearDown(harness.dispose);
      await harness.database
          .update(harness.database.specimen)
          .write(const SpecimenCompanion(iDMethod: Value('legacy microscopy')));
      final controller = SpecimenFormCtrModel.fromData(
        await harness.getSpecimen(),
      );
      addTearDown(controller.dispose);

      await harness.pump(
        tester,
        GeneralRecordField(
          specimenUuid: 'specimen-a',
          specimenCtr: controller,
          useHorizontalLayout: false,
        ),
      );

      expect(find.text('ID Confidence'), findsOneWidget);
      expect(find.text('Identification Method'), findsNothing);

      final confidenceField = find.byType(DropdownButtonFormField<int?>);
      await tester.ensureVisible(confidenceField);
      await tester.pumpAndSettle();
      await tester.tap(confidenceField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('High').last);
      await tester.pumpAndSettle();

      expect(find.text('Identification Method'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Identification Method')).dy,
        greaterThan(tester.getTopLeft(find.text('ID Confidence')).dy),
      );

      final methodField = find.byType(DropdownButtonFormField<String?>).last;
      await tester.ensureVisible(methodField);
      await tester.pumpAndSettle();
      await tester.tap(methodField);
      await tester.pumpAndSettle();
      for (final option in [...defaultIdMethods, 'legacy microscopy']) {
        expect(find.text(option), findsWidgets);
      }
      await tester.tap(find.text('legacy microscopy').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(confidenceField);
      await tester.pumpAndSettle();
      await tester.tap(confidenceField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not assigned').last);
      await tester.pumpAndSettle();

      expect(find.text('Identification Method'), findsNothing);
      expect(controller.idMethodCtr, 'legacy microscopy');
      expect((await harness.getSpecimen()).iDMethod, 'legacy microscopy');
    },
  );
}

class _SpecimenFormHarness {
  _SpecimenFormHarness(this.database, this.container);

  final Database database;
  final ProviderContainer container;

  static Future<_SpecimenFormHarness> create() async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        fieldIdModeNotifierProvider.overrideWith(_TestFieldIdModeNotifier.new),
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
          currentFieldNumber: Value(7),
          isRegisterField: Value(true),
        ),
        PersonnelCompanion(
          uuid: Value('identifier-a'),
          name: Value('Iris Identifier'),
          role: Value('Determiner only'),
          isRegisterField: Value(false),
        ),
        PersonnelCompanion(
          uuid: Value('preparator-a'),
          name: Value('Pat Preparator'),
          role: Value('Preparator only'),
          isRegisterField: Value(false),
        ),
      ]);
      batch.insertAll(database.personnelList, const [
        PersonnelListCompanion(
          projectUuid: Value('project-a'),
          personnelUuid: Value('cataloger-a'),
        ),
        PersonnelListCompanion(
          projectUuid: Value('project-a'),
          personnelUuid: Value('identifier-a'),
        ),
        PersonnelListCompanion(
          projectUuid: Value('project-a'),
          personnelUuid: Value('preparator-a'),
        ),
      ]);
    });
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen-a'),
            projectUuid: Value('project-a'),
          ),
        );

    return _SpecimenFormHarness(database, container);
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<SpecimenData> getSpecimen() {
    return (database.select(
      database.specimen,
    )..where((row) => row.uuid.equals('specimen-a'))).getSingle();
  }

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

class _TestFieldIdModeNotifier extends FieldIdModeNotifier {
  @override
  Future<FieldIdMode> build() async => FieldIdMode.personnel;
}
