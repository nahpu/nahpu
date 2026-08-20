import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_details.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_list.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_registry.dart';
import 'package:nahpu/screens/projects/taxonomy/new_taxa.dart';
import 'package:nahpu/screens/settings/settings.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';

void main() {
  testWidgets('manage taxa uses outlined tap-driven details and search', (
    tester,
  ) async {
    final fixture = await _pumpManageTaxa(tester, size: const Size(1000, 900));

    expect(
      find.byKey(const ValueKey('manage-taxa-wide-layout')),
      findsOneWidget,
    );
    expect(find.byType(TaxonManagementDetails), findsNothing);
    expect(find.text('Select a taxon to view details'), findsOneWidget);

    final myotisTile = find.byKey(
      ValueKey('managed-taxon-${fixture.myotisId}'),
    );
    final outlinedMaterial = tester
        .widgetList<Material>(
          find.descendant(of: myotisTile, matching: find.byType(Material)),
        )
        .firstWhere((material) => material.shape is RoundedRectangleBorder);
    final shape = outlinedMaterial.shape! as RoundedRectangleBorder;
    expect(
      shape.side.color,
      Theme.of(tester.element(myotisTile)).colorScheme.outlineVariant,
    );

    await tester.tap(myotisTile);
    await tester.pump();

    expect(find.byType(TaxonManagementDetails), findsOneWidget);
    expect(find.text('Myotis lucifugus'), findsAtLeastNWidgets(1));
    expect(find.text('Edit taxon'), findsOneWidget);

    final searchField = find.descendant(
      of: find.byType(CommonSearchBar),
      matching: find.byType(TextField),
    );
    await tester.enterText(searchField, 'nobody');
    await tester.pump();

    expect(find.text('No taxa match “nobody”.'), findsOneWidget);
    expect(find.byType(TaxonManagementDetails), findsNothing);
    expect(find.text('Select a taxon to view details'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(myotisTile, findsOneWidget);

    await tester.tap(find.text('Edit taxon'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTaxon), findsOneWidget);
  });

  testWidgets('compact manage taxa opens a detail sheet', (tester) async {
    final fixture = await _pumpManageTaxa(tester, size: const Size(390, 844));

    expect(find.byKey(const ValueKey('manage-taxa-wide-layout')), findsNothing);
    expect(find.byType(TaxonManagementDetails), findsNothing);

    await tester.tap(find.byKey(ValueKey('managed-taxon-${fixture.myotisId}')));
    await tester.pumpAndSettle();

    expect(find.byType(TaxonManagementDetails), findsOneWidget);
    expect(find.text('Edit taxon'), findsOneWidget);
  });

  testWidgets('taxon registry manage action opens Manage taxa', (tester) async {
    final fixture = await _taxonFixture();
    addTearDown(fixture.database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(fixture.database)],
        child: const MaterialApp(home: Scaffold(body: TaxonRegistryViewer())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manage'));
    await tester.pumpAndSettle();

    expect(find.byType(ManageTaxa), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Manage taxa'), findsOneWidget);
  });

  testWidgets('settings Taxa entry opens Manage taxa', (tester) async {
    final fixture = await _taxonFixture();
    addTearDown(fixture.database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(fixture.database)],
        child: const MaterialApp(
          home: Scaffold(body: DatabaseSettingSections()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Taxa'));
    await tester.pumpAndSettle();

    expect(find.byType(ManageTaxa), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Manage taxa'), findsOneWidget);
  });

  testWidgets('manage taxa selection mode protects used taxa', (tester) async {
    final fixture = await _pumpManageTaxa(
      tester,
      size: const Size(1000, 900),
      useMyotis: true,
    );

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    final myotisTile = find.byKey(
      ValueKey('managed-taxon-${fixture.myotisId}'),
    );
    final rattusTile = find.byKey(
      ValueKey('managed-taxon-${fixture.rattusId}'),
    );
    Checkbox checkboxFor(Finder tile) => tester.widget<Checkbox>(
      find.descendant(of: tile, matching: find.byType(Checkbox)),
    );

    expect(checkboxFor(myotisTile).onChanged, isNull);
    await tester.tap(myotisTile);
    await tester.pump();
    expect(checkboxFor(myotisTile).value, isFalse);

    await tester.tap(rattusTile);
    await tester.pump();
    expect(checkboxFor(rattusTile).value, isTrue);
    expect(find.byType(TaxonManagementDetails), findsNothing);
  });

  testWidgets('manage taxa stays open after deletion', (tester) async {
    final fixture = await _pumpManageTaxa(tester, size: const Size(1000, 900));

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('managed-taxon-${fixture.rattusId}')));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(ManageTaxa), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.byKey(ValueKey('managed-taxon-${fixture.rattusId}')),
      findsNothing,
    );
    expect(
      find.byKey(ValueKey('managed-taxon-${fixture.myotisId}')),
      findsOneWidget,
    );
  });
}

Future<_TaxonFixture> _pumpManageTaxa(
  WidgetTester tester, {
  required Size size,
  bool useMyotis = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final fixture = await _taxonFixture(useMyotis: useMyotis);
  addTearDown(fixture.database.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(fixture.database)],
      child: const MaterialApp(home: ManageTaxa()),
    ),
  );
  await tester.pumpAndSettle();
  return fixture;
}

Future<_TaxonFixture> _taxonFixture({bool useMyotis = false}) async {
  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  final myotisId = await database
      .into(database.taxonomy)
      .insert(
        const TaxonomyCompanion(
          taxonRank: Value('species'),
          taxonClass: Value('Mammalia'),
          taxonOrder: Value('Chiroptera'),
          taxonFamily: Value('Vespertilionidae'),
          genus: Value('Myotis'),
          specificEpithet: Value('lucifugus'),
          commonName: Value('little brown bat'),
        ),
      );
  final rattusId = await database
      .into(database.taxonomy)
      .insert(
        const TaxonomyCompanion(
          taxonRank: Value('species'),
          taxonClass: Value('Mammalia'),
          taxonOrder: Value('Rodentia'),
          taxonFamily: Value('Muridae'),
          genus: Value('Rattus'),
          specificEpithet: Value('rattus'),
        ),
      );
  if (useMyotis) {
    await database
        .into(database.specimen)
        .insert(
          SpecimenCompanion(
            uuid: const Value('used-myotis'),
            speciesID: Value(myotisId),
          ),
        );
  }
  return _TaxonFixture(
    database: database,
    myotisId: myotisId,
    rattusId: rattusId,
  );
}

class _TaxonFixture {
  const _TaxonFixture({
    required this.database,
    required this.myotisId,
    required this.rattusId,
  });

  final Database database;
  final int myotisId;
  final int rattusId;
}
