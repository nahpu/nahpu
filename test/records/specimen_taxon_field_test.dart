import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/specimens/shared/taxonomy.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:nahpu/screens/specimens/shared/general_records.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';

void main() {
  testWidgets('specimen taxon fields use taxon terminology', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SpeciesAutoComplete(
                  specimenUuid: 'specimen',
                  speciesCtr: controller,
                  options: const [],
                ),
                const DisabledSpeciesField(),
              ],
            ),
          ),
        ),
      ),
    );

    final fields = tester.widgetList<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(fields, hasLength(2));
    expect(fields.first.decoration.labelText, 'Taxon');
    expect(fields.first.decoration.hintText, 'Type taxon name');
    expect(fields.last.decoration.labelText, 'Taxon');
    expect(fields.last.decoration.hintText, 'Enter taxon');
    expect(find.byTooltip('Type taxon name and select from list'), findsOne);
    expect(find.text('Species'), findsNothing);
  });

  group('taxon selection', () {
    late Database database;

    Future<int> addTaxon({
      String? genus,
      String? specificEpithet,
      String? subspecificEpithet,
      String? taxonFamily,
      required String rank,
    }) {
      return database
          .into(database.taxonomy)
          .insert(
            TaxonomyCompanion(
              taxonRank: Value(rank),
              taxonFamily: Value(taxonFamily),
              genus: Value(genus),
              specificEpithet: Value(specificEpithet),
              subspecificEpithet: Value(subspecificEpithet),
            ),
          );
    }

    Future<String> addSpecimen() async {
      const uuid = 'specimen-1';
      await database
          .into(database.specimen)
          .insert(const SpecimenCompanion(uuid: Value(uuid)));
      return uuid;
    }

    Future<void> mount(
      WidgetTester tester,
      String uuid, {
      int? speciesId,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            home: Scaffold(
              body: SpeciesFieldCtr(specimenUuid: uuid, speciesCtr: speciesId),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<int?> storedSpecies(String uuid) async {
      final row = await (database.select(
        database.specimen,
      )..where((r) => r.uuid.equals(uuid))).getSingle();
      return row.speciesID;
    }

    setUp(() {
      database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
    });

    tearDown(() => database.close());

    testWidgets('two taxa sharing genus and epithet each select their own', (
      tester,
    ) async {
      // A species and its nominate subspecies share genus + specificEpithet.
      // Resolving a selection by re-querying those two columns used to throw.
      final species = await addTaxon(
        genus: 'Rattus',
        specificEpithet: 'rattus',
        rank: 'species',
      );
      final subspecies = await addTaxon(
        genus: 'Rattus',
        specificEpithet: 'rattus',
        subspecificEpithet: 'rattus',
        rank: 'subspecies',
      );
      final uuid = await addSpecimen();
      await mount(tester, uuid);

      await tester.enterText(find.byType(TextFormField), 'Rattus');
      await tester.pumpAndSettle();

      expect(find.text('Rattus rattus'), findsOneWidget);
      expect(find.text('Rattus rattus rattus'), findsOneWidget);

      await tester.tap(find.text('Rattus rattus rattus'));
      await tester.pumpAndSettle();
      expect(await storedSpecies(uuid), subspecies);

      await tester.enterText(find.byType(TextFormField), 'Rattus');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rattus rattus'));
      await tester.pumpAndSettle();
      expect(await storedSpecies(uuid), species);
    });

    testWidgets('a genus-rank taxon renders its name, not "null"', (
      tester,
    ) async {
      final genusId = await addTaxon(genus: 'Rattus', rank: 'genus');
      final uuid = await addSpecimen();
      await mount(tester, uuid);

      await tester.enterText(find.byType(TextFormField), 'Rat');
      await tester.pumpAndSettle();

      expect(find.text('Rattus'), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);

      await tester.tap(find.text('Rattus'));
      await tester.pumpAndSettle();
      // Selecting it stores the taxon rather than wiping the reference.
      expect(await storedSpecies(uuid), genusId);
    });

    testWidgets('a multi-word epithet stores the right taxon', (tester) async {
      final id = await addTaxon(
        genus: 'Rattus',
        specificEpithet: 'sp. nov.',
        rank: 'species',
      );
      final uuid = await addSpecimen();
      await mount(tester, uuid);

      await tester.enterText(find.byType(TextFormField), 'Rattus sp');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rattus sp. nov.'));
      await tester.pumpAndSettle();

      expect(await storedSpecies(uuid), id);
    });

    testWidgets('shows the stored taxon and keeps typing across rebuilds', (
      tester,
    ) async {
      final id = await addTaxon(
        genus: 'Rattus',
        specificEpithet: 'rattus',
        rank: 'species',
      );
      final uuid = await addSpecimen();
      await mount(tester, uuid, speciesId: id);

      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Rattus rattus',
      );

      await tester.enterText(find.byType(TextFormField), 'Mus mu');
      // A rebuild that does not change the stored taxon must not reset the text.
      await tester.pump();
      await mount(tester, uuid, speciesId: id);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Mus mu',
      );
    });

    testWidgets('tolerates a stored taxon missing from the list', (
      tester,
    ) async {
      final uuid = await addSpecimen();
      await addTaxon(
        genus: 'Rattus',
        specificEpithet: 'rattus',
        rank: 'species',
      );
      // An id no taxon carries: the field must render empty, not throw.
      await mount(tester, uuid, speciesId: 9999);

      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '',
      );
    });
  });

  test('collection help describes the taxon field', () async {
    final document = await DocumentationRepository().loadInfo(
      InfoTopic.specimenGeneralRecord,
      DocsLanguage.english,
    );

    expect(document.title, 'Specimen general record');
    expect(document.markdown, contains('Choose the taxon'));
    expect(document.markdown, contains('`dwc:Occurrence`'));
  });
}
