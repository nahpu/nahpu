import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/custom_fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  testWidgets('manager has no creation or placement controls', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manageableCustomFieldsProvider(
            null,
          ).overrideWith((ref) async => const <CustomFieldDefinitionData>[]),
        ],
        child: const MaterialApp(
          home: CustomFieldsSettings(
            projectUuid: null,
            currentCatalog: CatalogFmt.mammals,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Placement'), findsNothing);
    expect(find.text('All placements'), findsNothing);
    expect(find.text('Add field'), findsNothing);
    expect(find.text('Add custom field'), findsNothing);
    expect(find.text('No custom fields in this context.'), findsOneWidget);
  });

  testWidgets('manager groups definitions and opens read-only details', (
    tester,
  ) async {
    const definition = CustomFieldDefinitionData(
      id: 1,
      uuid: 'definition-uuid',
      sourceTemplateUuid: 'template-uuid',
      name: 'Canopy cover',
      type: 'number',
      uiSection: 'siteAttribute',
      scope: 'project',
      projectUuid: 'project-a',
      sortOrder: 0,
      isArchived: 0,
      allowDwcConflict: 0,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manageableCustomFieldsProvider(
            'project-a',
          ).overrideWith((ref) async => const [definition]),
          customFieldUsageProvider(1).overrideWith(
            (ref) async =>
                const CustomFieldUsage(valueCount: 2, legacyValueCount: 0),
          ),
        ],
        child: const MaterialApp(
          home: CustomFieldsSettings(
            projectUuid: 'project-a',
            currentCatalog: CatalogFmt.mammals,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Site Attributes'), findsOneWidget);
    expect(find.text('Canopy cover'), findsOneWidget);

    await tester.tap(find.text('Canopy cover'));
    await tester.pumpAndSettle();

    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Definition UUID'), findsOneWidget);
    expect(find.text('definition-uuid'), findsOneWidget);
    expect(find.text('Source template UUID'), findsOneWidget);
    expect(find.text('template-uuid'), findsOneWidget);
    expect(find.text('Stored values'), findsOneWidget);
    expect(
      find.text('Unavailable until all stored values are cleared'),
      findsOneWidget,
    );
    expect(find.text('Edit definition'), findsOneWidget);
  });

  testWidgets('deleting an unused definition requires confirmation', (
    tester,
  ) async {
    const definition = CustomFieldDefinitionData(
      id: 1,
      uuid: 'definition-uuid',
      name: 'Canopy cover',
      type: 'number',
      uiSection: 'siteAttribute',
      scope: 'global',
      sortOrder: 0,
      isArchived: 0,
      allowDwcConflict: 0,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manageableCustomFieldsProvider(
            null,
          ).overrideWith((ref) async => const [definition]),
          customFieldUsageProvider(1).overrideWith(
            (ref) async =>
                const CustomFieldUsage(valueCount: 0, legacyValueCount: 0),
          ),
        ],
        child: const MaterialApp(
          home: CustomFieldsSettings(
            projectUuid: null,
            currentCatalog: CatalogFmt.mammals,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete custom field?'), findsOneWidget);
    expect(find.textContaining('cannot be undone'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete custom field?'), findsNothing);
  });
}
