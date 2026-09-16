import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/specimen_form.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Selecting a taxon writes the specimen, which invalidates the specimen list
/// and rebuilds the page. The form used to be keyed by the selected taxon, so
/// that rebuild discarded it and scrolled the user back to the top.
void main() {
  late Database database;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    final preferences = await SharedPreferences.getInstance();
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        settingProvider.overrideWithValue(preferences),
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
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen-a'),
            projectUuid: Value('project-a'),
            taxonGroup: Value('mammals'),
          ),
        );
    await database
        .into(database.mammalAttribute)
        .insert(
          const MammalAttributeCompanion(specimenUuid: Value('specimen-a')),
        );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<SpecimenData> specimen() {
    return (database.select(
      database.specimen,
    )..where((row) => row.uuid.equals('specimen-a'))).getSingle();
  }

  Future<void> pump(WidgetTester tester, SpecimenData record) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SpecimenForm(
              key: ValueKey(record.uuid),
              specimen: record,
              catalogFmt: CatalogFmt.mammalogy,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ScrollableState formScroll(WidgetTester tester) {
    return tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(FocusDetectedLayout),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }

  testWidgets('selecting a taxon keeps the form and its scroll position', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final taxonId = await database
        .into(database.taxonomy)
        .insert(
          const TaxonomyCompanion(
            taxonRank: Value('species'),
            genus: Value('Rattus'),
            specificEpithet: Value('rattus'),
          ),
        );

    await pump(tester, await specimen());
    final formState = tester.state<SpecimenFormState>(
      find.byType(SpecimenForm),
    );

    formScroll(tester).position.jumpTo(300);
    await tester.pump();
    expect(formScroll(tester).position.pixels, 300);

    // What selecting a taxon does: write the species, then rebuild the page
    // from the reloaded record.
    await database
        .update(database.specimen)
        .write(SpecimenCompanion(speciesID: Value(taxonId)));
    await pump(tester, await specimen());

    expect(
      formScroll(tester).position.pixels,
      300,
      reason: 'the form must stay where the user left it',
    );
    expect(
      tester.state<SpecimenFormState>(find.byType(SpecimenForm)),
      same(formState),
      reason: 'the form must not be rebuilt from scratch',
    );
    expect(find.text('Rattus rattus'), findsOneWidget);
  });
}
