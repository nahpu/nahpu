import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/specimens/shared/parasite_forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimens/parasite_services.dart';

void main() {
  testWidgets('parasite form links the selected lot individuals', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project'), name: Value('Test')),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen'),
            projectUuid: Value('project'),
            taxonGroup: Value('Fishes'),
          ),
        );
    final individualId = await database
        .into(database.specimenIndividual)
        .insert(
          const SpecimenIndividualCompanion(
            specimenUuid: Value('specimen'),
            individualID: Value('A1'),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          userDefinedFieldProvider.overrideWith(
            (ref, prefKey) async => const [],
          ),
        ],
        child: const MaterialApp(home: NewParasite(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('individual-add-0')));
    await tester.tap(find.byKey(const ValueKey('individual-add-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final parasite = await database.select(database.parasite).getSingle();
    final link = await database.select(database.parasiteIndividual).getSingle();
    expect(link.parasiteID, parasite.id);
    expect(link.individualID, individualId);
  });

  testWidgets('parasite form saves its displayed UUID with the record', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project'), name: Value('Test')),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen'),
            projectUuid: Value('project'),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          userDefinedFieldProvider.overrideWith(
            (ref, prefKey) async => const [],
          ),
        ],
        child: const MaterialApp(home: NewParasite(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();

    _expectOutsideScroll(tester, 'Cancel');
    _expectOutsideScroll(tester, 'Add');
    final uuidText = tester.widget<SelectableText>(find.byType(SelectableText));
    final displayedUuid = uuidText.data!.replaceFirst('UUID: ', '');
    expect(
      displayedUuid,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(await database.select(database.parasite).get(), isEmpty);
    expect(find.text('Set options in Specimen settings'), findsWidgets);

    final idMenu = find.byWidgetPredicate(
      (widget) => widget is PopupMenuButton,
    );
    await tester.tap(idMenu.first);
    await tester.pumpAndSettle();
    expect(find.text('Generate UUID'), findsNothing);
    expect(find.text('New number'), findsOneWidget);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final parasite = await database.select(database.parasite).getSingle();
    expect(parasite.parasiteUuid, displayedUuid);
  });

  testWidgets('a new parasite starts with the host preparator as collector', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project'), name: Value('Test')),
        );
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(
            uuid: Value('preparator'),
            name: Value('A. Preparator'),
          ),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen'),
            projectUuid: Value('project'),
            preparatorID: Value('preparator'),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          userDefinedFieldProvider.overrideWith(
            (ref, prefKey) async => const [],
          ),
        ],
        child: const MaterialApp(home: NewParasite(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in [
      'Collector',
      'Determiner',
      'Date determined',
      'Determination method',
    ]) {
      _expectFieldInSection(tester, label, 'Collection & identification');
    }

    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final parasite = await database.select(database.parasite).getSingle();
    expect(parasite.collectorID, 'preparator');
    expect(parasite.determinerID, isNull);
  });

  test('the default collector falls back from preparator to cataloger', () {
    SpecimenData host({String? cataloger, String? preparator}) => SpecimenData(
      uuid: 'host',
      catalogerID: cataloger,
      preparatorID: preparator,
    );
    expect(
      defaultParasiteCollector(host(cataloger: 'c', preparator: 'p')),
      'p',
    );
    expect(defaultParasiteCollector(host(cataloger: 'c', preparator: '')), 'c');
    expect(defaultParasiteCollector(host()), isNull);
    expect(defaultParasiteCollector(null), isNull);
  });

  testWidgets('parasite fields are grouped into expandable sections', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          userDefinedFieldProvider.overrideWith(
            (ref, prefKey) async => const [],
          ),
        ],
        child: const MaterialApp(home: NewParasite(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();

    _expectOutsideScroll(tester, 'Cancel');
    _expectOutsideScroll(tester, 'Add');
    expect(find.text('Parasite details'), findsOneWidget);
    expect(find.text('Collection & identification'), findsOneWidget);
    expect(find.text('Preparation & preservation'), findsNothing);
    expect(find.text('Curation'), findsNothing);
    expect(find.text('Life stage'), findsNothing);

    final showMore = find.text('Show more');
    await tester.ensureVisible(showMore);
    await tester.tap(showMore);
    await tester.pumpAndSettle();

    expect(find.text('Preparation & preservation'), findsOneWidget);
    expect(find.text('Curation'), findsOneWidget);
    _expectFieldInSection(tester, 'Life stage', 'Parasite details');
    _expectFieldInSection(
      tester,
      'Preparation method',
      'Preparation & preservation',
    );
    _expectFieldInSection(tester, 'Storage', 'Curation');

    final showLess = find.text('Show less');
    await tester.ensureVisible(showLess);
    await tester.tap(showLess);
    await tester.pumpAndSettle();

    expect(find.text('Preparation & preservation'), findsNothing);
    expect(find.text('Life stage'), findsNothing);
  });

  testWidgets('anatomical locations follow the selected category', (
    tester,
  ) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          userDefinedFieldProvider.overrideWith(
            (ref, prefKey) async => getDefaultOptionsList(prefKey),
          ),
        ],
        child: const MaterialApp(home: NewParasite(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();

    await _openDropdown(tester, 'Category');
    await tester.tap(find.text('Endoparasite').last);
    await tester.pumpAndSettle();

    await _openDropdown(tester, 'Anatomical location');
    expect(find.text('Liver'), findsWidgets);
    expect(find.text('Fur'), findsNothing);
  });
}

Future<void> _openDropdown(WidgetTester tester, String label) async {
  final dropdown = find.ancestor(
    of: find.text(label),
    matching: find.byType(DropdownButtonFormField<String>),
  );
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
}

void _expectOutsideScroll(WidgetTester tester, String label) {
  expect(
    find.ancestor(
      of: find.text(label),
      matching: find.byType(SingleChildScrollView),
    ),
    findsNothing,
  );
}

void _expectFieldInSection(
  WidgetTester tester,
  String fieldLabel,
  String sectionTitle,
) {
  final sections = tester.widgetList<FormSection>(
    find.ancestor(
      of: find.text(fieldLabel),
      matching: find.byType(FormSection),
    ),
  );
  expect(sections.map((section) => section.title), contains(sectionTitle));
}
