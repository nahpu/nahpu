import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/stratigraphy.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/providers/database.dart';

void main() {
  late Database database;
  late ProviderContainer container;
  late int siteId;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project-a'), name: Value('A')),
        );
    siteId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<void> pumpForm(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: Stratigraphy(siteId: siteId)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> revisit(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await pumpForm(tester);
  }

  Finder field(String label) => find.ancestor(
    of: find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    ),
    matching: find.byType(TextFormField),
  );

  Future<void> choose(WidgetTester tester, int index, String value) async {
    final dropdown = find.byType(DropdownButtonFormField<String>).at(index);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  testWidgets('saves all text fields and reloads them after leaving the page', (
    tester,
  ) async {
    await pumpForm(tester);
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
    await revisit(tester);
    for (final entry in values.entries) {
      expect(
        tester.widget<TextFormField>(field(entry.key)).controller!.text,
        entry.value,
      );
    }
    await tester.enterText(field('Formation'), '');
    await tester.pumpAndSettle();
    await revisit(tester);
    expect(
      tester.widget<TextFormField>(field('Formation')).controller!.text,
      '',
    );
  });

  testWidgets('reloads dropdowns and persists dependent resets', (
    tester,
  ) async {
    await pumpForm(tester);
    await choose(tester, 0, 'Mesozoic');
    await choose(tester, 1, 'Cretaceous');
    await choose(tester, 2, 'Upper Cretaceous');
    await choose(tester, 3, 'Late Cretaceous');
    await revisit(tester);
    final dropdowns = tester.widgetList<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdowns.map((field) => field.initialValue), [
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
    await revisit(tester);
    expect(find.text('Jurassic'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('finishes saving when the page closes immediately', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.enterText(field('Formation'), 'Saved on departure');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    final saved = await FossilSiteQuery(database).getFossilSiteBySiteId(siteId);
    expect(saved?.formation, 'Saved on departure');
    expect(tester.takeException(), isNull);
    await pumpForm(tester);
    expect(
      tester.widget<TextFormField>(field('Formation')).controller!.text,
      'Saved on departure',
    );
  });

  testWidgets('editing stratigraphy preserves sedimentology', (tester) async {
    await FossilSiteQuery(database).createFossilSite(
      FossilSiteCompanion(
        siteID: Value(siteId),
        rockType: const Value('Sandstone'),
        formation: const Value('Old formation'),
        geologicEra: const Value(999),
      ),
    );
    await pumpForm(tester);
    expect(tester.takeException(), isNull);
    await tester.enterText(field('Formation'), 'New formation');
    await tester.pumpAndSettle();
    final saved = (await FossilSiteQuery(
      database,
    ).getFossilSiteBySiteId(siteId))!;
    expect(saved.rockType, 'Sandstone');
    expect(saved.formation, 'New formation');
  });
}
