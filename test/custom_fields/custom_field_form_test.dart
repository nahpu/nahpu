import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/custom_fields.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  late Database database;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    await database
        .into(database.site)
        .insert(
          const SiteCompanion(id: Value(1), projectUuid: Value('project-a')),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('bird'),
            projectUuid: Value('project-a'),
            taxonGroup: Value('Birds'),
          ),
        );
  });

  tearDown(() => database.close());

  testWidgets('site add action creates a project definition for its location', (
    tester,
  ) async {
    await _pump(
      tester,
      database,
      const CustomFieldForm(owner: CustomFieldOwner.site(1)),
    );

    expect(find.text('Add custom field'), findsOneWidget);
    await tester.tap(find.text('Add custom field'));
    await tester.pumpAndSettle();

    expect(find.text('Add custom field to Site Attributes'), findsOneWidget);
    expect(find.text('Placement'), findsNothing);
    expect(find.text('Catalog applicability'), findsNothing);
    expect(find.text('Scope'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Canopy cover');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final definition = await database
        .select(database.customFieldDefinition)
        .getSingle();
    expect(definition.placement, FieldUISection.siteAttribute);
    expect(definition.fieldScope, FieldScope.project);
    expect(definition.projectUuid, 'project-a');
    expect(definition.catalogFormat, isNull);
    expect(find.text('Canopy cover'), findsOneWidget);
    expect(find.byTooltip('Manage custom fields'), findsOneWidget);
  });

  testWidgets(
    'unsaved parasite form creates its reusable definition immediately',
    (tester) async {
      await _pump(
        tester,
        database,
        CustomFieldDraftForm(
          placement: FieldUISection.parasite,
          specimenUuid: 'bird',
          controller: CustomFieldDraftController(),
        ),
      );

      await tester.tap(find.text('Add custom field'));
      await tester.pumpAndSettle();

      expect(find.text('Add custom field to Parasite'), findsOneWidget);
      expect(find.text('Placement'), findsNothing);
      expect(find.text('All catalog formats'), findsOneWidget);
      await tester.tap(find.text('All catalog formats'));
      await tester.pumpAndSettle();
      expect(find.text('Current catalog only (Birds)'), findsOneWidget);
      await tester.tap(find.text('All catalog formats').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Parasite score');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      final definition = await database
          .select(database.customFieldDefinition)
          .getSingle();
      expect(definition.placement, FieldUISection.parasite);
      expect(definition.fieldScope, FieldScope.project);
      expect(definition.projectUuid, 'project-a');
      expect(definition.catalogFormat, isNull);
      expect(await database.select(database.customFieldValue).get(), isEmpty);
    },
  );

  testWidgets('deleting a definition refreshes an already-mounted form', (
    tester,
  ) async {
    await CustomFieldService(database).createDefinition(
      const CustomFieldDraft(
        name: 'Transient field',
        type: FieldType.text,
        placement: FieldUISection.siteAttribute,
        scope: FieldScope.project,
        projectUuid: 'project-a',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  const CustomFieldForm(owner: CustomFieldOwner.site(1)),
                  TextButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomFieldsSettings(
                          projectUuid: 'project-a',
                          currentCatalog: CatalogFmt.mammals,
                        ),
                      ),
                    ),
                    child: const Text('Open settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Transient field'), findsOneWidget);

    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Definition actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Transient field'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Transient field'), findsNothing);
  });

  testWidgets('collapsed draft shows values but hides blank field actions', (
    tester,
  ) async {
    final definition = await CustomFieldService(database).createDefinition(
      const CustomFieldDraft(
        name: 'Draft note',
        type: FieldType.text,
        placement: FieldUISection.specimenPart,
        scope: FieldScope.project,
        projectUuid: 'project-a',
      ),
    );
    final controller = CustomFieldDraftController()
      ..setValue(definition.id!, 'Retained value');
    addTearDown(controller.dispose);

    await _pump(
      tester,
      database,
      CustomFieldDraftForm(
        placement: FieldUISection.specimenPart,
        specimenUuid: 'bird',
        controller: controller,
        showAll: false,
      ),
    );

    expect(find.text('Custom fields'), findsOneWidget);
    expect(find.text('Draft note'), findsOneWidget);
    expect(find.text('Add custom field'), findsNothing);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Custom fields'), findsNothing);
  });

  testWidgets('deleting a draft definition removes its staged value', (
    tester,
  ) async {
    final definition = await CustomFieldService(database).createDefinition(
      const CustomFieldDraft(
        name: 'Draft-only field',
        type: FieldType.text,
        placement: FieldUISection.specimenPart,
        scope: FieldScope.project,
        projectUuid: 'project-a',
      ),
    );
    final controller = CustomFieldDraftController()
      ..setValue(definition.id!, 'Unsaved value');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  CustomFieldDraftForm(
                    placement: FieldUISection.specimenPart,
                    specimenUuid: 'bird',
                    controller: controller,
                    showAll: false,
                  ),
                  TextButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomFieldsSettings(
                          projectUuid: 'project-a',
                          currentCatalog: CatalogFmt.birds,
                        ),
                      ),
                    ),
                    child: const Text('Open draft settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.values, {definition.id!: 'Unsaved value'});

    await tester.tap(find.text('Open draft settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Definition actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(controller.values, isEmpty);
  });
}

Future<void> _pump(WidgetTester tester, Database database, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}
