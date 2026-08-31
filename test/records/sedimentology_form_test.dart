import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/sedimentology.dart';
import 'package:nahpu/screens/sites/site_form.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/fossils.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Database database;
  late int siteId;
  late WidgetRef widgetRef;
  late SharedPreferences preferences;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database
        .into(database.project)
        .insert(const ProjectCompanion(uuid: Value('a'), name: Value('A')));
    siteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('a')));
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
          effectiveUserDefinedFieldProvider(
            habitatTypePrefKey,
          ).overrideWith((ref) async => ['Forest']),
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
  }

  testWidgets('loads saved sedimentology and reloads when the site changes', (
    tester,
  ) async {
    await FossilSiteQuery(database).save(
      siteId,
      const FossilSiteCompanion(
        rockType: Value('Sandstone'),
        depositionalEnvironmentType: Value(1),
        depositionalMarine: Value('Legacy shelf'),
        standardPreservationType: Value('Legacy preservation'),
        sedimentologyRemark: Value('Oxidized'),
      ),
    );
    await pumpForm(
      tester,
      Sedimentology(id: siteId, useHorizontalLayout: false),
    );
    expect(find.text('Sandstone'), findsOneWidget);
    expect(find.text('Legacy shelf'), findsOneWidget);
    expect(find.text('Legacy preservation'), findsOneWidget);
    final other = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('a')));
    await FossilSiteQuery(
      database,
    ).save(other, const FossilSiteCompanion(rockType: Value('Mudstone')));
    await pumpForm(
      tester,
      Sedimentology(id: other, useHorizontalLayout: false),
    );
    expect(find.text('Sandstone'), findsNothing);
    expect(find.text('Mudstone'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'first edits persist and changing the category clears both subtypes',
    (tester) async {
      await pumpForm(
        tester,
        Sedimentology(id: siteId, useHorizontalLayout: false),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Rock Type(s)'),
        'Mudstone',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(DropdownButtonFormField<DepositionalEnvironmentType>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continental').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fluvial').last);
      await tester.pumpAndSettle();
      var row = (await FossilSiteQuery(
        database,
      ).getFossilSiteBySiteId(siteId))!;
      expect(row.rockType, 'Mudstone');
      expect(row.depositionalContinent, 'Fluvial');
      await tester.tap(
        find.byType(DropdownButtonFormField<DepositionalEnvironmentType>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marine').last);
      await tester.pumpAndSettle();
      row = (await FossilSiteQuery(database).getFossilSiteBySiteId(siteId))!;
      expect(row.depositionalEnvironmentType, 1);
      expect(row.depositionalContinent, isNull);
      expect(row.depositionalMarine, isNull);
      expect(find.text('Fluvial'), findsNothing);
      expect(await database.select(database.fossilSite).get(), hasLength(1));
    },
  );

  testWidgets('save failures keep the draft and allow retry', (tester) async {
    await database.customStatement(
      "CREATE TRIGGER fail_fossil BEFORE INSERT ON fossilSite BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await pumpForm(
      tester,
      Sedimentology(id: siteId, useHorizontalLayout: false),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rock Type(s)'),
      'Unsaved rock',
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Could not save sedimentology:'),
      findsOneWidget,
    );
    expect(find.text('Unsaved rock'), findsOneWidget);
    await database.customStatement('DROP TRIGGER fail_fossil');
    await tester.ensureVisible(find.text('Retry saving'));
    await tester.tap(find.text('Retry saving'));
    await tester.pumpAndSettle();
    expect(
      (await FossilSiteQuery(database).getFossilSiteBySiteId(siteId))!.rockType,
      'Unsaved rock',
    );
    expect(find.textContaining('Could not save sedimentology:'), findsNothing);
  });

  for (final horizontal in [false, true]) {
    testWidgets(
      'sedimentology fits a narrow ${horizontal ? 'horizontal card' : 'vertical form'}',
      (tester) async {
        await pumpForm(
          tester,
          SizedBox(
            width: 320,
            height: horizontal ? 300 : null,
            child: Sedimentology(id: siteId, useHorizontalLayout: horizontal),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(
          find.widgetWithText(
            TextFormField,
            'Comments on sedimentology and paleoenvironment',
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('device catalog switching preserves habitat and fossil records', (
    tester,
  ) async {
    await database
        .into(database.siteAttribute)
        .insert(
          SiteAttributeCompanion(
            siteID: Value(siteId),
            habitatType: const Value('Forest'),
          ),
        );
    await FossilSiteQuery(
      database,
    ).save(siteId, const FossilSiteCompanion(rockType: Value('Sandstone')));
    final ctr = SiteFormCtrModel.empty();
    addTearDown(ctr.dispose);
    await pumpForm(
      tester,
      SiteContextFields(
        id: siteId,
        useHorizontalLayout: false,
        siteFormCtr: ctr,
      ),
    );
    expect(find.text('Sedimentology'), findsOneWidget);
    await widgetRef
        .read(catalogFmtNotifierProvider.notifier)
        .set(CatalogFmt.mammals);
    await tester.pumpAndSettle();
    expect(find.text('Sedimentology'), findsNothing);
    expect(find.text('Site Attributes'), findsOneWidget);
    await widgetRef
        .read(catalogFmtNotifierProvider.notifier)
        .set(CatalogFmt.fossils);
    await tester.pumpAndSettle();
    expect(find.text('Sandstone'), findsOneWidget);
    expect(
      (await SiteQuery(database).getSiteAttribute(siteId))!.habitatType,
      'Forest',
    );
    expect(preferences.getKeys(), {catalogFmtPrefKey});
    expect(tester.takeException(), isNull);
  });
}
