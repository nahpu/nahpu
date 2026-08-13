import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/custom_field.dart';

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
          onChanged: (_, _) {},
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
