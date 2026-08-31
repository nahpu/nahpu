import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/fossils/attributes.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/screens/specimens/shared/weight_field.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/export/fossil_attributes.dart';
import 'package:nahpu/services/export/dynamic_record_exporter.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Database database;
  late WidgetRef widgetRef;
  late SharedPreferences preferences;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database.customStatement('PRAGMA foreign_keys = ON');
    await database
        .into(database.project)
        .insert(const ProjectCompanion(uuid: Value('a'), name: Value('A')));
    SharedPreferences.setMockInitialValues({catalogFmtPrefKey: 'Fossils'});
    preferences = await SharedPreferences.getInstance();
  });
  tearDown(() => database.close());

  Future<void> pumpForm(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
          fieldIdModeNotifierProvider.overrideWith(_PersonnelFieldIds.new),
          specimenSexVocabularyProvider.overrideWith(
            (ref) async => allowedSpecimenSexes,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                widgetRef = ref;
                return SingleChildScrollView(child: child);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    widgetRef.read(projectUuidProvider.notifier).updateProjectUuid('a');
  }

  Future<void> insertSpecimen(String uuid) => database
      .into(database.specimen)
      .insert(
        SpecimenCompanion(
          uuid: Value(uuid),
          projectUuid: const Value('a'),
          taxonGroup: const Value('Fossils'),
        ),
      );

  testWidgets('fossil lifecycle owns only native attributes and no parasites', (
    tester,
  ) async {
    await pumpForm(tester, const SizedBox.shrink());
    final service = SpecimenServices(ref: widgetRef);
    final uuid = await service.createSpecimen();
    var fossil = await FossilSpecimenQuery(database).getByUuid(uuid);
    expect(fossil, isNotNull);
    expect(fossil!.weightUnit, 'g');
    expect(await database.select(database.mammalAttribute).get(), isEmpty);
    expect(await database.select(database.parasiteDetection).get(), isEmpty);
    await service.updateFossilAttribute(
      uuid,
      const FossilAttributeCompanion(
        fossilType: Value('Body fossil'),
        sex: Value(2),
        ontogeneticStage: Value('Subadult'),
        weight: Value(2.5),
        weightUnit: Value('kg'),
        specimenDescription: Value('Partial skeleton'),
      ),
    );
    fossil = await FossilSpecimenQuery(database).getByUuid(uuid);
    expect(fossil!.ontogeneticStage, 'Subadult');
    final values = await FossilAttributes(
      ref: widgetRef,
      specimenUuid: uuid,
    ).getAttributes();
    expect(values, hasLength(fossilAttributeExportList.length));
    expect(
      values[fossilAttributeExportList.indexOf('measurement::fossilType')],
      'Body fossil',
    );
    final record = await (database.select(
      database.specimen,
    )..where((row) => row.uuid.equals(uuid))).getSingle();
    final fields = await DynamicRecordExporter(
      ref: widgetRef,
      expansion: MultiEntryExpansion.concatenate,
    ).getRecord(record);
    expect(fields.single['fossilAttribute::weightUnit'], 'kg');
    expect(fields.single['fossilAttribute::ontogeneticStage'], 'Subadult');
    await service.deleteSpecimen(uuid, CatalogFmt.fossils);
    expect(await database.select(database.fossilAttribute).get(), isEmpty);
    await service.createSpecimen();
    await service.deleteAllSpecimens('a');
    expect(await database.select(database.fossilAttribute).get(), isEmpty);
    expect(await database.select(database.specimen).get(), isEmpty);
  });

  testWidgets('native fossil fields edit and reload without mammal controls', (
    tester,
  ) async {
    await insertSpecimen('one');
    await FossilSpecimenQuery(database).save(
      'one',
      const FossilAttributeCompanion(
        fossilType: Value('Trace fossil'),
        sex: Value(2),
        ontogeneticStage: Value('Adult'),
        weight: Value(5),
        weightUnit: Value('kg'),
        specimenDescription: Value('Trackway'),
        remark: Value('Remark'),
      ),
    );
    await pumpForm(
      tester,
      const FossilAttributeForms(
        specimenUuid: 'one',
        useHorizontalLayout: false,
      ),
    );
    expect(find.text('Trace fossil'), findsOneWidget);
    expect(find.text('Adult'), findsOneWidget);
    expect(find.byType(WeightField), findsOneWidget);
    expect(find.byType(SpecimenSexDropdown), findsOneWidget);
    expect(find.byType(ParasiteDetectionForm), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ontogenetic stage'),
      'Juvenile',
    );
    await tester.pumpAndSettle();
    expect(
      (await FossilSpecimenQuery(database).getByUuid('one'))!.ontogeneticStage,
      'Juvenile',
    );
    await insertSpecimen('two');
    await FossilSpecimenQuery(database).save(
      'two',
      const FossilAttributeCompanion(fossilType: Value('Body fossil')),
    );
    await pumpForm(
      tester,
      const FossilAttributeForms(
        specimenUuid: 'two',
        useHorizontalLayout: false,
      ),
    );
    expect(find.text('Body fossil'), findsOneWidget);
    expect(find.text('Juvenile'), findsNothing);
    expect(find.text('Trackway'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'fossil attribute card scrolls within a compact horizontal layout',
    (tester) async {
      await insertSpecimen('one');
      await pumpForm(
        tester,
        const SizedBox(
          width: 320,
          height: 300,
          child: FossilAttributeForms(
            specimenUuid: 'one',
            useHorizontalLayout: true,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.widgetWithText(TextFormField, 'Remarks'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

class _PersonnelFieldIds extends FieldIdModeNotifier {
  @override
  Future<FieldIdMode> build() async => FieldIdMode.personnel;
}
