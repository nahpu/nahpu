import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/custom_fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/nahpu_icons.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  testWidgets('manager creates only after choosing a fixed target', (
    tester,
  ) async {
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
    expect(find.byTooltip('Create new custom field'), findsOneWidget);
    expect(find.text('No custom fields in this context.'), findsOneWidget);

    await tester.tap(find.byTooltip('Create new custom field'));
    await tester.pumpAndSettle();
    expect(find.text('Create custom field'), findsOneWidget);
    expect(find.text('Site Attributes'), findsOneWidget);
    expect(find.text('Specimen Attributes'), findsOneWidget);
    expect(find.text('Specimen Part'), findsOneWidget);
    expect(find.text('Parasite'), findsOneWidget);
    await tester.tap(find.text('Site Attributes'));
    await tester.pumpAndSettle();
    expect(find.text('Add custom field to Site Attributes'), findsOneWidget);
    expect(find.text('Placement'), findsNothing);
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

    await tester.tap(find.byTooltip('Definition actions'));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuDivider), findsNWidgets(2));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete custom field?'), findsOneWidget);
    expect(find.textContaining('cannot be undone'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete custom field?'), findsNothing);
  });

  testWidgets('groups use their location-specific icons', (tester) async {
    final definitions = FieldUISection.values.indexed
        .map(
          (entry) => CustomFieldDefinitionData(
            id: entry.$1 + 1,
            uuid: 'definition-${entry.$1}',
            name: entry.$2.label,
            type: 'text',
            uiSection: entry.$2.name,
            scope: 'global',
            sortOrder: 0,
            isArchived: 0,
            allowDwcConflict: 0,
          ),
        )
        .toList();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manageableCustomFieldsProvider(
            null,
          ).overrideWith((ref) async => definitions),
          for (final definition in definitions)
            customFieldUsageProvider(definition.id!).overrideWith(
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

    expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    expect(find.byIcon(matchCatFmtToIcon(CatalogFmt.mammals)), findsOneWidget);
    expect(find.byIcon(NahpuIcons.vialOutlined), findsOneWidget);
    expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
  });

  testWidgets('narrow definition actions open a divided bottom sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

    await tester.tap(find.byTooltip('Definition actions'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Divider), findsAtLeastNWidgets(2));
    expect(find.text('View definition'), findsOneWidget);
  });
}
