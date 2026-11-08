import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/specimens/shared/symbiont_forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimens/symbiont_services.dart';

void main() {
  testWidgets('symbiont form links the selected lot individuals', (
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
        child: const MaterialApp(home: NewSymbiont(specimenUuid: 'specimen')),
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

    final symbiont = await database.select(database.symbiont).getSingle();
    final link = await database.select(database.symbiontIndividual).getSingle();
    expect(link.symbiontID, symbiont.id);
    expect(link.individualID, individualId);
  });

  testWidgets('symbiont form saves its displayed UUID with the record', (
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
        child: const MaterialApp(home: NewSymbiont(specimenUuid: 'specimen')),
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
    expect(await database.select(database.symbiont).get(), isEmpty);
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

    final symbiont = await database.select(database.symbiont).getSingle();
    expect(symbiont.symbiontUuid, displayedUuid);
  });

  testWidgets('a new symbiont starts with the host preparator as collector', (
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
        child: const MaterialApp(home: NewSymbiont(specimenUuid: 'specimen')),
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

    final symbiont = await database.select(database.symbiont).getSingle();
    expect(symbiont.collectorID, 'preparator');
    expect(symbiont.determinerID, isNull);
  });

  test('the default collector falls back from preparator to cataloger', () {
    SpecimenData host({String? cataloger, String? preparator}) => SpecimenData(
      uuid: 'host',
      catalogerID: cataloger,
      preparatorID: preparator,
    );
    expect(
      defaultSymbiontCollector(host(cataloger: 'c', preparator: 'p')),
      'p',
    );
    expect(defaultSymbiontCollector(host(cataloger: 'c', preparator: '')), 'c');
    expect(defaultSymbiontCollector(host()), isNull);
    expect(defaultSymbiontCollector(null), isNull);
  });

  testWidgets('symbiont fields are grouped into expandable sections', (
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
        child: const MaterialApp(home: NewSymbiont(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();

    _expectOutsideScroll(tester, 'Cancel');
    _expectOutsideScroll(tester, 'Add');
    expect(find.text('Symbiont details'), findsOneWidget);
    expect(find.text('Collection & identification'), findsOneWidget);
    expect(find.text('Preparation & preservation'), findsNothing);
    expect(find.text('Curation'), findsNothing);
    _expectFieldInSection(tester, 'Life stage', 'Symbiont details');
    _expectFieldInSection(tester, 'Association status', 'Symbiont details');

    final showMore = find.text('Show more');
    await tester.ensureVisible(showMore);
    await tester.tap(showMore);
    await tester.pumpAndSettle();

    expect(find.text('Preparation & preservation'), findsOneWidget);
    expect(find.text('Curation'), findsOneWidget);
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
    expect(find.text('Life stage'), findsOneWidget);
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
        child: const MaterialApp(home: NewSymbiont(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();

    await _selectOption(tester, 'Interaction type', 'Parasitic');
    await _openDropdown(tester, 'Category');
    await tester.tap(find.text('Endosymbiont').last);
    await tester.pumpAndSettle();

    await _openDropdown(tester, 'Anatomical location');
    expect(find.text('Liver'), findsWidgets);
    expect(find.text('Fur'), findsNothing);
  });

  testWidgets('category follows the interaction type and its hint', (
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
            (ref, prefKey) async => getDefaultOptionsList(prefKey),
          ),
        ],
        child: const MaterialApp(home: NewSymbiont(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Category'), findsNothing);

    await _selectOption(tester, 'Interaction type', 'Parasitic');
    expect(find.text('Lives on or in the host and harms it'), findsOneWidget);
    await _selectOption(tester, 'Category', 'Endosymbiont');

    await _selectOption(tester, 'Interaction type', 'Mutualistic');
    expect(find.text('Category'), findsNothing);
    expect(find.text('Both symbiont and host benefit'), findsOneWidget);

    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final symbiont = await database.select(database.symbiont).getSingle();
    expect(symbiont.interactionType, 'Mutualistic');
    expect(symbiont.category, isNull);
  });

  testWidgets('a new symbiont starts with the host collection date', (
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
            collectionDate: Value('2026-03-14'),
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
        child: const MaterialApp(home: NewSymbiont(specimenUuid: 'specimen')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final symbiont = await database.select(database.symbiont).getSingle();
    expect(symbiont.dateCollected, '2026-03-14');
  });

  test('the default collection date falls back to the preparation date', () {
    SpecimenData host({String? collected, String? prepared}) => SpecimenData(
      uuid: 'host',
      collectionDate: collected,
      prepDate: prepared,
    );
    expect(
      defaultSymbiontCollectionDate(
        host(collected: '2026-03-14', prepared: '2026-03-15'),
      ),
      '2026-03-14',
    );
    expect(
      defaultSymbiontCollectionDate(
        host(collected: '', prepared: '2026-03-15'),
      ),
      '2026-03-15',
    );
    expect(defaultSymbiontCollectionDate(host()), isNull);
    expect(defaultSymbiontCollectionDate(null), isNull);
  });
}

Future<void> _selectOption(
  WidgetTester tester,
  String label,
  String option,
) async {
  await _openDropdown(tester, label);
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
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
