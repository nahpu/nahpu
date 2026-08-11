import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  late Database database;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => database.close());

  Future<void> pumpWizard(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          catalogFmtNotifierProvider.overrideWith(_TestCatalogFormat.new),
          fieldIdModeNotifierProvider.overrideWith(_TestFieldIdMode.new),
          projectFieldIdAutoIncrementProvider.overrideWith(
            _TestAutoIncrement.new,
          ),
        ],
        child: const MaterialApp(home: CreateProjectForm()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> goToFieldId(WidgetTester tester) async {
    await tester.tap(find.text('Create new project'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project name*'),
      'Field Project',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
  }

  testWidgets('welcome explains shared project identity', (tester) async {
    await pumpWizard(tester);

    expect(find.text('One project, one identity'), findsOneWidget);
    expect(
      find.textContaining('keeps one UUID across devices'),
      findsOneWidget,
    );
    expect(find.text('Create new project'), findsOneWidget);
    expect(find.text('Import project-info JSON'), findsOneWidget);
  });

  testWidgets('wide wizard uses a rounded step rail without a divider', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await pumpWizard(tester);

    final rail = tester.widget<Container>(
      find.byKey(const ValueKey('create-project-step-rail')),
    );
    final decoration = rail.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(16));
    expect(decoration.border, isA<Border>());
    expect(find.byType(VerticalDivider), findsNothing);
  });

  testWidgets('compact wizard keeps the horizontal step chips', (tester) async {
    await pumpWizard(tester);

    expect(find.byType(ChoiceChip), findsWidgets);
    expect(
      find.byKey(const ValueKey('create-project-step-rail')),
      findsNothing,
    );
  });

  testWidgets('optional setup can be skipped and zero taxa are reported', (
    tester,
  ) async {
    await pumpWizard(tester);

    await tester.tap(find.text('Create new project'));
    await tester.pumpAndSettle();
    expect(find.text('Project details'), findsOneWidget);
    expect(find.text('Accession'), findsOneWidget);
    expect(
      find.textContaining('third-party collection management'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project name*'),
      'Field Project',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Main taxon'), findsWidgets);
    expect(find.textContaining('multiple taxon groups'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Set up field IDs'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Taxonomy readiness'), findsOneWidget);
    expect(find.text('Available taxa: 0'), findsOneWidget);
    expect(
      find.textContaining('before creating a new specimen record'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Create project'), findsOneWidget);
  });

  testWidgets('project field ID mode includes every setup control', (
    tester,
  ) async {
    await pumpWizard(tester);
    await goToFieldId(tester);

    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Prefix'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Current catalog number'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'Suffix'), findsOneWidget);
    expect(find.text('Auto-increment catalog number'), findsOneWidget);
    expect(find.textContaining('Preview:'), findsOneWidget);
  });

  testWidgets('personnel mode creates a registered Cataloger when none exist', (
    tester,
  ) async {
    await pumpWizard(tester);
    await goToFieldId(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Create a Cataloger'), findsOneWidget);
    expect(find.text('Specimen care role: Cataloger'), findsOneWidget);
    expect(
      find.text('Personal field-number registration enabled'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Name*'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Initials*'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Current field number*'),
      findsOneWidget,
    );
  });
}

class _TestCatalogFormat extends CatalogFmtNotifier {
  @override
  Future<CatalogFmt> build() async => CatalogFmt.mammals;
}

class _TestFieldIdMode extends FieldIdModeNotifier {
  @override
  Future<FieldIdMode> build() async => FieldIdMode.personnel;
}

class _TestAutoIncrement extends ProjectFieldIdAutoIncrementNotifier {
  @override
  Future<bool> build() async => false;
}
