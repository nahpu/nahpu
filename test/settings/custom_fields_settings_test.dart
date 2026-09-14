import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/records/custom_fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  testWidgets('location chips switch the listed fields', (tester) async {
    await _pumpManager(
      tester,
      definitions: [
        _definition(1, name: 'Canopy cover'),
        _definition(2, name: 'Mite load', uiSection: 'parasite'),
      ],
    );

    expect(tester.takeException(), isNull);
    expect(
      find.byType(ChoiceChip),
      findsNWidgets(FieldUISection.values.length),
    );
    // Opens on the first location that has fields.
    expect(_chip(tester, 'Site Attributes').selected, isTrue);
    expect(
      find.descendant(
        of: _chipFinder('Site Attributes'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(find.text('Canopy cover'), findsOneWidget);
    expect(find.text('Mite load'), findsNothing);

    await tester.tap(find.text('Parasite'));
    await tester.pumpAndSettle();

    expect(_chip(tester, 'Parasite').selected, isTrue);
    expect(_chip(tester, 'Site Attributes').selected, isFalse);
    expect(find.text('Mite load'), findsOneWidget);
    expect(find.text('Canopy cover'), findsNothing);
  });

  testWidgets('an initial placement opens that location', (tester) async {
    await _pumpManager(
      tester,
      initialPlacement: FieldUISection.parasite,
      definitions: [_definition(1, name: 'Canopy cover')],
    );

    expect(_chip(tester, 'Parasite').selected, isTrue);
    expect(find.text('No custom fields in Parasite yet.'), findsOneWidget);
    expect(find.text('Canopy cover'), findsNothing);
  });

  testWidgets('create opens a blank form for the selected location', (
    tester,
  ) async {
    await _pumpManager(tester, definitions: const []);

    expect(
      find.text('Select a custom field to edit, or add a new one.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Site Attributes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create new custom field'));
    await tester.pumpAndSettle();

    // The chip is the target, so no picker, dialog, or sheet opens.
    expect(find.text('Create custom field'), findsNothing);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('New custom field'), findsOneWidget);
    expect(find.text('Shown in Site Attributes'), findsOneWidget);
    expect(find.text('Scope'), findsOneWidget);
    expect(find.text('Catalog applicability'), findsNothing);

    await tester.ensureVisible(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('New custom field'), findsNothing);
  });

  testWidgets('selecting a field opens its form and details', (tester) async {
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
    await _pumpManager(
      tester,
      projectUuid: 'project-a',
      definitions: const [definition],
      usage: const CustomFieldUsage(valueCount: 2, legacyValueCount: 0),
    );
    expect(find.text('Show archived fields'), findsNothing);

    await tester.tap(find.text('Canopy cover'));
    await tester.pumpAndSettle();

    // The chip and the chosen list tile.
    expect(find.byIcon(Icons.radio_button_checked), findsNWidgets(2));
    expect(find.text('Edit Canopy cover'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Canopy cover'), findsOneWidget);
    expect(find.text('Definition UUID'), findsOneWidget);
    expect(find.text('definition-uuid'), findsOneWidget);
    expect(find.text('Source template UUID'), findsOneWidget);
    expect(find.text('template-uuid'), findsOneWidget);
    expect(find.text('Stored values'), findsOneWidget);
    expect(
      find.text('Unavailable until all stored values are cleared'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Canopy cover'),
      'Changed label',
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Canopy cover'), findsOneWidget);
    expect(find.text('Changed label'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting an unused definition requires confirmation', (
    tester,
  ) async {
    await _pumpManager(tester, definitions: [_definition(1)]);

    await tester.tap(find.byTooltip('Definition actions'));
    await tester.pumpAndSettle();
    // A lone definition has nothing to swap with, so the move group is gone.
    expect(find.byType(PopupMenuDivider), findsNothing);
    expect(find.text('Move up'), findsNothing);
    expect(find.text('Move down'), findsNothing);
    expect(find.text('Archive'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete custom field?'), findsOneWidget);
    expect(find.textContaining('cannot be undone'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete custom field?'), findsNothing);
  });

  testWidgets('move actions offer only the directions with a neighbor', (
    tester,
  ) async {
    await _pumpManager(
      tester,
      definitions: [
        _definition(1),
        _definition(2),
        // Another scope is another group, so it adds no neighbor.
        _definition(3, scope: 'project', projectUuid: 'project-a'),
      ],
    );

    await tester.tap(find.byTooltip('Definition actions').first);
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuDivider), findsOneWidget);
    expect(_menuItem(tester, 'Move up').enabled, isFalse);
    expect(_menuItem(tester, 'Move down').enabled, isTrue);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Definition actions').at(1));
    await tester.pumpAndSettle();
    expect(_menuItem(tester, 'Move up').enabled, isTrue);
    expect(_menuItem(tester, 'Move down').enabled, isFalse);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Definition actions').at(2));
    await tester.pumpAndSettle();
    expect(find.text('Move up'), findsNothing);
    expect(find.text('Move down'), findsNothing);
  });

  testWidgets('archived fields stay hidden until the switch is on', (
    tester,
  ) async {
    await _pumpManager(tester, definitions: [_definition(1, archived: true)]);

    expect(find.text('Show archived fields'), findsOneWidget);
    expect(
      find.text('All custom fields in Site Attributes are archived.'),
      findsOneWidget,
    );
    expect(find.text('Field 1'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Field 1'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
  });

  testWidgets('narrow screens switch between the list and form tabs', (
    tester,
  ) async {
    _setViewSize(tester, const Size(400, 800));
    await _pumpManager(tester, definitions: [_definition(1), _definition(2)]);

    expect(find.widgetWithText(Tab, 'Fields'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Edit field'), findsOneWidget);

    await tester.tap(find.text('Field 1'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Field 1'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(Tab, 'Fields'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Definition actions').first);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Divider), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Delete custom field?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the form fits a small phone with every option shown', (
    tester,
  ) async {
    _setViewSize(tester, const Size(320, 640));
    await _pumpManager(tester, definitions: const []);

    await tester.tap(find.byTooltip('Create new custom field'));
    await tester.pumpAndSettle();
    expect(find.text('New custom field'), findsOneWidget);
    expect(find.text('Catalog applicability'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dropdown').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Map to Darwin Core'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Map to Darwin Core'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mapping mode'));
    await tester.pumpAndSettle();

    expect(find.text('Options'), findsOneWidget);
    expect(find.text('Direct field'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpManager(
  WidgetTester tester, {
  String? projectUuid,
  FieldUISection? initialPlacement,
  required List<CustomFieldDefinitionData> definitions,
  CustomFieldUsage usage = const CustomFieldUsage(
    valueCount: 0,
    legacyValueCount: 0,
  ),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        manageableCustomFieldsProvider(
          projectUuid,
        ).overrideWith((ref) async => definitions),
        for (final definition in definitions)
          customFieldUsageProvider(
            definition.id!,
          ).overrideWith((ref) async => usage),
      ],
      child: MaterialApp(
        home: CustomFieldsSettings(
          projectUuid: projectUuid,
          currentCatalog: CatalogFmt.mammalogy,
          initialPlacement: initialPlacement,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _chipFinder(String label) {
  return find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip));
}

ChoiceChip _chip(WidgetTester tester, String label) {
  return tester.widget<ChoiceChip>(_chipFinder(label));
}

PopupMenuItem<Object?> _menuItem(WidgetTester tester, String label) {
  return tester.widget(
    find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is PopupMenuItem),
    ),
  );
}

CustomFieldDefinitionData _definition(
  int id, {
  String? name,
  String uiSection = 'siteAttribute',
  String scope = 'global',
  String? projectUuid,
  bool archived = false,
}) {
  return CustomFieldDefinitionData(
    id: id,
    uuid: 'definition-$id',
    name: name ?? 'Field $id',
    type: 'text',
    uiSection: uiSection,
    scope: scope,
    projectUuid: projectUuid,
    sortOrder: id,
    isArchived: archived ? 1 : 0,
    allowDwcConflict: 0,
  );
}
