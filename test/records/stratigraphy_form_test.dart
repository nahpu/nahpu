import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/stratigraphy.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/providers/database.dart';

void main() {
  late Database database;
  late int siteId;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project-a'), name: Value('A')),
        );
    siteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
  });

  tearDown(() => database.close());

  Future<void> pumpForm(WidgetTester tester, int id) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: Stratigraphy(siteId: id)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> choose(WidgetTester tester, int index, String value) async {
    final dropdown = find.byType(DropdownButtonFormField<String>).at(index);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  testWidgets('creates a row, persists text, and reloads another site', (
    tester,
  ) async {
    await pumpForm(tester, siteId);
    final values = {
      'Formation': 'Hell Creek',
      'Narrower Geologic Stage': 'Maastrichtian',
      'Biozone': 'Triceratops',
      'Comments': 'Measured section',
      'Reference source(s) for stratigraphy': 'Field reference',
    };
    for (final entry in values.entries) {
      await tester.ensureVisible(field(entry.key));
      await tester.enterText(field(entry.key), entry.value);
      await tester.pumpAndSettle();
    }

    final saved = (await FossilSiteQuery(
      database,
    ).getFossilSiteBySiteId(siteId))!;
    expect(saved.formation, 'Hell Creek');
    expect(saved.narrowerGeologicStage, 'Maastrichtian');
    expect(saved.biozone, 'Triceratops');
    expect(saved.stratigraphyRemark, 'Measured section');
    expect(saved.stratigraphicSource, 'Field reference');
    expect(await database.select(database.fossilSite).get(), hasLength(1));

    final otherSiteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
    await FossilSiteQuery(database).save(
      otherSiteId,
      const FossilSiteCompanion(formation: Value('Morrison')),
    );
    await pumpForm(tester, otherSiteId);
    expect(find.text('Hell Creek'), findsNothing);
    expect(find.text('Morrison'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('persists dropdowns and clears dependent selections', (
    tester,
  ) async {
    await pumpForm(tester, siteId);
    await choose(tester, 0, 'Mesozoic');
    await choose(tester, 1, 'Cretaceous');
    await choose(tester, 2, 'Upper Cretaceous');
    await choose(tester, 3, 'Late Cretaceous');
    await pumpForm(tester, siteId);

    final dropdowns = tester.widgetList<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdowns.map((dropdown) => dropdown.initialValue), [
      'Mesozoic',
      'Cretaceous',
      'Upper Cretaceous',
      'Late Cretaceous',
    ]);

    await choose(tester, 1, 'Jurassic');
    var saved = (await FossilSiteQuery(
      database,
    ).getFossilSiteBySiteId(siteId))!;
    expect(saved.geologicSeries, isNull);
    expect(saved.geologicEpoch, isNull);

    await choose(tester, 0, 'Cenozoic');
    saved = (await FossilSiteQuery(database).getFossilSiteBySiteId(siteId))!;
    expect(saved.geologicEra, 2);
    expect(saved.geologicPeriod, isNull);
    expect(saved.geologicSeries, isNull);
    expect(saved.geologicEpoch, isNull);
  });

  testWidgets('invalid stored indexes render empty without crashing', (
    tester,
  ) async {
    await FossilSiteQuery(database).save(
      siteId,
      const FossilSiteCompanion(
        geologicEra: Value(999),
        geologicPeriod: Value(999),
        geologicSeries: Value(999),
        geologicEpoch: Value(999),
      ),
    );
    await pumpForm(tester, siteId);
    expect(tester.takeException(), isNull);
    final dropdowns = tester.widgetList<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(
      dropdowns.map((dropdown) => dropdown.initialValue),
      everyElement(isNull),
    );
  });

  testWidgets('save failures keep the draft and allow retry', (tester) async {
    await database.customStatement(
      "CREATE TRIGGER fail_stratigraphy BEFORE INSERT ON fossilSite "
      "BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await pumpForm(tester, siteId);
    await tester.enterText(field('Formation'), 'Unsaved formation');
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not save stratigraphy:'), findsOneWidget);
    expect(find.text('Unsaved formation'), findsOneWidget);

    await database.customStatement('DROP TRIGGER fail_stratigraphy');
    await tester.ensureVisible(find.text('Retry saving'));
    await tester.tap(find.text('Retry saving'));
    await tester.pumpAndSettle();
    expect(
      (await FossilSiteQuery(
        database,
      ).getFossilSiteBySiteId(siteId))!.formation,
      'Unsaved formation',
    );
    expect(find.textContaining('Could not save stratigraphy:'), findsNothing);
  });

  testWidgets('closing the page completes saves and preserves sedimentology', (
    tester,
  ) async {
    await FossilSiteQuery(
      database,
    ).save(siteId, const FossilSiteCompanion(rockType: Value('Sandstone')));
    await pumpForm(tester, siteId);
    await tester.enterText(field('Formation'), 'Saved on departure');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final saved = (await FossilSiteQuery(
      database,
    ).getFossilSiteBySiteId(siteId))!;
    expect(saved.formation, 'Saved on departure');
    expect(saved.rockType, 'Sandstone');
    expect(tester.takeException(), isNull);
  });
}
