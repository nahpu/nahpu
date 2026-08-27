import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/geography.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/geography_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/geography.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/site_fixture.dart';

void main() {
  late Database database;
  late SiteFormCtrModel controllers;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
    controllers = SiteFormCtrModel.empty();
  });

  tearDown(() async {
    controllers.dispose();
    await database.close();
  });

  Future<int> seedSite() => insertSiteWithGeography(database, siteID: 'S1');

  Future<void> mount(
    WidgetTester tester,
    int siteId, {
    List<String> visibleFields = defaultVisibleSiteGeographyFields,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          // Field visibility is read through the Rust config bridge, which is
          // not initialized in widget tests.
          userDefinedFieldProvider(
            siteGeographyFieldsPrefKey,
          ).overrideWith((ref) async => visibleFields),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SiteGeography(
              id: siteId,
              useHorizontalLayout: false,
              siteFormCtr: controllers,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offers a saved locality and fills every field on selection', (
    tester,
  ) async {
    await GeographyQuery(database).resolve(
      const GeographyDraft(
        country: 'Indonesia',
        stateProvince: 'Sulawesi Selatan',
        county: 'Gowa',
        municipality: 'Tinggimoncong',
        locality: 'Mt. Bawakaraeng',
      ),
    );
    final siteId = await seedSite();
    await mount(tester, siteId);

    expect(find.text('Find existing locality'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Find existing locality'),
      'Bawakaraeng',
    );
    await tester.pumpAndSettle();

    const label =
        'Indonesia, Sulawesi Selatan, Gowa, Tinggimoncong, Mt. Bawakaraeng';
    expect(find.text(label), findsOneWidget);
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();

    // One selection fills the whole hierarchy.
    expect(controllers.countryCtr.text, 'Indonesia');
    expect(controllers.stateProvinceCtr.text, 'Sulawesi Selatan');
    expect(controllers.countyCtr.text, 'Gowa');
    expect(controllers.municipalityCtr.text, 'Tinggimoncong');
    expect(controllers.localityCtr.text, 'Mt. Bawakaraeng');

    // The site is linked to the existing record rather than a new one.
    final localities = await GeographyQuery(database).getAll();
    expect(localities, hasLength(1));
    final site = await (database.select(
      database.site,
    )..where((row) => row.id.equals(siteId))).getSingle();
    expect(site.geographyId, localities.single.id);
  });

  testWidgets('hides the lookup when no locality has been recorded', (
    tester,
  ) async {
    await mount(tester, await seedSite());
    expect(find.text('Find existing locality'), findsNothing);
    expect(find.text('Country'), findsOneWidget);
  });

  testWidgets('typing a field does not create a record until focus leaves', (
    tester,
  ) async {
    final siteId = await seedSite();
    await mount(tester, siteId);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Country'),
      'Indonesia',
    );
    await tester.pump();
    // No per-keystroke rows: a prefix must not become a saved locality.
    expect(await GeographyQuery(database).getAll(), isEmpty);

    // Dropping the card resolves what was typed, once.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final localities = await GeographyQuery(database).getAll();
    expect(localities, hasLength(1));
    expect(localities.single.country, 'Indonesia');
  });

  testWidgets('suggests values already recorded for one field', (tester) async {
    await GeographyQuery(
      database,
    ).resolve(const GeographyDraft(country: 'Indonesia', locality: 'A'));
    await GeographyQuery(
      database,
    ).resolve(const GeographyDraft(country: 'Peru', locality: 'B'));
    await mount(tester, await seedSite());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Country'),
      'Ind',
    );
    await tester.pumpAndSettle();

    expect(find.text('Indonesia'), findsOneWidget);
    expect(find.text('Peru'), findsNothing);
  });

  testWidgets('hides fields the user turned off', (tester) async {
    await mount(
      tester,
      await seedSite(),
      visibleFields: const ['country', 'stateProvince'],
    );

    expect(find.text('Country'), findsOneWidget);
    expect(find.text('State/Province'), findsOneWidget);
    expect(find.text('County/Parish/District'), findsNothing);
    expect(find.text('Precise Locality'), findsOneWidget);
  });
}
