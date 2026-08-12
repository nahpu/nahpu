import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/sites/components/sedimentology.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/fossils.dart';

final _environmentTypeField = find.byType(
  DropdownButtonFormField<DepositionalEnvironmentType>,
);

/// The sub-environment dropdown, the first of the two string dropdowns.
final _subEnvironmentField = find.byType(DropdownButtonFormField<String>).first;

void main() {
  late Database database;
  ProviderContainer? container;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    container?.dispose();
    await database.close();
  });

  Future<int> createSite() async {
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project-a'), name: Value('A')),
        );
    return database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
  }

  Future<void> pumpForm(WidgetTester tester, int siteId) async {
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    container!
        .read(projectUuidProvider.notifier)
        .updateProjectUuid('project-a');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container!,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Sedimentology(
                id: siteId,
                useHorizontalLayout: false,
                siteFormCtr: SiteFormCtrModel.empty(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the fossil data already recorded for the site', (
    tester,
  ) async {
    final siteId = await createSite();
    await FossilSiteQuery(database).createFossilSite(
      FossilSiteCompanion(
        siteID: Value(siteId),
        rockType: const Value('Sandstone'),
        depositionalEnvironmentType: Value(
          DepositionalEnvironmentType.marine.index,
        ),
        depositionalMarine: const Value('Carbonate'),
        standardPreservationType: const Value('Amber'),
        sedimentologyRemark: const Value('Oxidized'),
      ),
    );

    await pumpForm(tester, siteId);

    expect(find.text('Sandstone'), findsOneWidget);
    expect(find.text('Marine'), findsOneWidget);
    expect(find.text('Carbonate'), findsOneWidget);
    expect(find.text('Amber'), findsOneWidget);
    expect(find.text('Oxidized'), findsOneWidget);
  });

  testWidgets('creates the fossil row on the first edit', (tester) async {
    final siteId = await createSite();
    await pumpForm(tester, siteId);

    await tester.enterText(find.byType(TextFormField).first, 'Mudstone');
    await tester.pumpAndSettle();

    final fossilSite = await FossilSiteQuery(
      database,
    ).getFossilSiteBySiteId(siteId);
    expect(fossilSite?.rockType, 'Mudstone');
  });

  testWidgets('stores the sub-environment in the column of its category', (
    tester,
  ) async {
    final siteId = await createSite();
    await pumpForm(tester, siteId);

    await tester.tap(_environmentTypeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continental').last);
    await tester.pumpAndSettle();

    await tester.tap(_subEnvironmentField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fluvial').last);
    await tester.pumpAndSettle();

    final fossilSite = await FossilSiteQuery(
      database,
    ).getFossilSiteBySiteId(siteId);
    expect(
      fossilSite?.depositionalEnvironmentType,
      DepositionalEnvironmentType.continental.index,
    );
    expect(fossilSite?.depositionalContinent, 'Fluvial');
    expect(fossilSite?.depositionalMarine, isNull);
  });

  testWidgets('clears the sub-environment when the category changes', (
    tester,
  ) async {
    final siteId = await createSite();
    await FossilSiteQuery(database).createFossilSite(
      FossilSiteCompanion(
        siteID: Value(siteId),
        depositionalEnvironmentType: Value(
          DepositionalEnvironmentType.continental.index,
        ),
        depositionalContinent: const Value('Fluvial'),
      ),
    );
    await pumpForm(tester, siteId);

    await tester.tap(_environmentTypeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marine').last);
    await tester.pumpAndSettle();

    final fossilSite = await FossilSiteQuery(
      database,
    ).getFossilSiteBySiteId(siteId);
    expect(
      fossilSite?.depositionalEnvironmentType,
      DepositionalEnvironmentType.marine.index,
    );
    expect(fossilSite?.depositionalContinent, isNull);
    // The stale selection must not be shown under the new category.
    expect(find.text('Fluvial'), findsNothing);
  });
}
