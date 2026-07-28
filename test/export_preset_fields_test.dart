import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/export_preset_fields.dart';
import 'package:nahpu/services/conditional_brackets.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  late Database db;

  setUp(() {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  testWidgets('list mapping presents output modes and indexed preview', (
    tester,
  ) async {
    const preset = ExportPresetModel(
      recordType: RecordType.site,
      specimenRecordType: SpecimenRecordType.allTaxa,
      headerFormat: ExportHeaderFormat.fieldName,
      mappings: [
        ExportFieldMapping(
          expression: '[site::habitatType]',
          textType: 'list',
          formatOption: 'comma',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: ExportPresetFieldsScreen(preset: preset),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apply source fields'), findsNothing);
    expect(find.text('Preview'), findsOneWidget);

    await tester.tap(find.byTooltip('Customize'));
    await tester.pumpAndSettle();

    expect(find.text('List output'), findsOneWidget);
    expect(find.text('One column'), findsOneWidget);
    expect(find.text('Indexed columns'), findsOneWidget);
    expect(find.text('Output example'), findsOneWidget);

    await tester.tap(find.text('Indexed columns'));
    await tester.pumpAndSettle();

    expect(find.text('Indexed column names'), findsOneWidget);
    expect(find.text('habitatType_1'), findsOneWidget);
    expect(find.text('habitatType_2'), findsOneWidget);
    expect(find.text('habitatType_3'), findsOneWidget);
  });

  testWidgets('customizing a scalar preserves its value format', (
    tester,
  ) async {
    const preset = ExportPresetModel(
      recordType: RecordType.site,
      specimenRecordType: SpecimenRecordType.allTaxa,
      headerFormat: ExportHeaderFormat.fieldName,
      mappings: [
        ExportFieldMapping(expression: '[site::siteID]', textType: 'encoded'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: ExportPresetFieldsScreen(preset: preset),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Customize'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Done'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Format: encoded'), findsOneWidget);
  });

  testWidgets('combined text editors retain their values when reordered', (
    tester,
  ) async {
    const preset = ExportPresetModel(
      recordType: RecordType.site,
      specimenRecordType: SpecimenRecordType.allTaxa,
      headerFormat: ExportHeaderFormat.fieldName,
      mappings: [
        ExportFieldMapping(
          expression: '[site::siteID]-[site::siteName]/[site::country]',
          headerOverride: 'combined',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: ExportPresetFieldsScreen(preset: preset),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Customize'));
    await tester.pumpAndSettle();

    final secondTextCard = find.byKey(const ValueKey('combined-segment-3'));
    final secondEditor = find.descendant(
      of: secondTextCard,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(secondEditor).controller.text, '/');

    await tester.tap(
      find.descendant(
        of: secondTextCard,
        matching: find.byTooltip('Move segment up'),
      ),
    );
    await tester.pump();

    final movedEditor = find.descendant(
      of: find.byKey(const ValueKey('combined-segment-3')),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(movedEditor).controller.text, '/');
    expect(
      find.text('Expression: [site::siteID]-/[site::siteName][site::country]'),
      findsOneWidget,
    );
  });

  testWidgets(
    'field picker groups results by table and stores full field keys',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const preset = ExportPresetModel(
        recordType: RecordType.site,
        specimenRecordType: SpecimenRecordType.allTaxa,
        headerFormat: ExportHeaderFormat.fieldName,
        mappings: [ExportFieldMapping(expression: '[site::siteID]')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            home: ExportPresetFieldsScreen(preset: preset),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add combined'), findsOneWidget);
      expect(find.text('Add nested'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('selected-mappings-header')),
          matching: find.byType(Row),
        ),
        findsAtLeastNWidgets(1),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('available-fields-header'))),
        tester.getSize(find.byKey(const ValueKey('selected-mappings-header'))),
      );

      await tester.tap(find.byTooltip('Customize'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('source-site::siteID')));
      await tester.pumpAndSettle();

      expect(find.text('Search fields or tables'), findsOneWidget);
      expect(find.text('site'), findsWidgets);
      expect(find.text('siteID'), findsWidgets);

      final searchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Search fields or tables',
      );
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'habitatType');
      await tester.pumpAndSettle();
      expect(find.text('habitatType'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('habitatType').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Field: [site::habitatType]'), findsOneWidget);
    },
  );

  testWidgets('conditional brackets is the value-format label', (tester) async {
    const preset = ExportPresetModel(
      recordType: RecordType.site,
      specimenRecordType: SpecimenRecordType.allTaxa,
      headerFormat: ExportHeaderFormat.fieldName,
      mappings: [ExportFieldMapping(expression: '[site::siteID]')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: ExportPresetFieldsScreen(preset: preset),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Customize'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Normal text'));
    await tester.pumpAndSettle();

    expect(find.text('Conditional brackets'), findsOneWidget);
    expect(find.text('Can be inaccurate measurement'), findsNothing);
  });

  testWidgets(
    'mammal accuracy auto-configures contains without picker overlap',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const preset = ExportPresetModel(
        recordType: RecordType.specimenRecord,
        specimenRecordType: SpecimenRecordType.generalMammals,
        headerFormat: ExportHeaderFormat.fieldName,
        mappings: [
          ExportFieldMapping(
            expression: '[mammalAttribute::tailLength]',
            textType: kConditionalBracketExportTextType,
            bracketConditions: [
              ConditionalBracketCondition(
                sourceField: '',
                operator: ConditionalComparisonOperator.equals,
                comparisonValue: '',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            home: ExportPresetFieldsScreen(preset: preset),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Customize'));
      await tester.pumpAndSettle();

      final decoratorFinder = find.byWidgetPredicate(
        (widget) =>
            widget is InputDecorator &&
            widget.decoration.labelText == 'Controlling field',
      );
      expect(decoratorFinder, findsOneWidget);
      final decorator = tester.widget<InputDecorator>(decoratorFinder);
      expect(decorator.decoration.hintText, 'Choose a field');
      expect(
        decorator.decoration.floatingLabelBehavior,
        FloatingLabelBehavior.always,
      );

      await tester.tap(find.byKey(const ValueKey('condition-field-')));
      await tester.pumpAndSettle();
      final searchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Search fields or tables',
      );
      await tester.enterText(searchField, 'accuracy');
      await tester.pumpAndSettle();
      await tester.tap(find.text('accuracy').last);
      await tester.pumpAndSettle();

      expect(find.text('Contains'), findsOneWidget);
      final valueField = find.byKey(
        const ValueKey('condition-value-tailLength'),
      );
      expect(valueField, findsOneWidget);
      final editable = find.descendant(
        of: valueField,
        matching: find.byType(EditableText),
      );
      expect(
        tester.widget<EditableText>(editable).controller.text,
        'tailLength',
      );
    },
  );
}
