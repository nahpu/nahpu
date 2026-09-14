import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/records/specimen_settings.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  testWidgets('field ID settings use compact mode cards', (tester) async {
    final harness = await _FieldIdSettingsHarness.create();
    addTearDown(harness.dispose);

    await harness.pump(tester, isMobile: false);

    expect(find.byType(SegmentedButton<FieldIdMode>), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.byType(Radio<FieldIdMode>), findsNWidgets(2));
    expect(find.text('Personnel ID'), findsOneWidget);
    expect(find.text('Project ID'), findsOneWidget);
    expect(find.textContaining('running number'), findsNothing);
    expect(
      find.text('Personnel field IDs require a cataloger'),
      findsOneWidget,
    );

    await tester.tap(find.text('Project ID'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Prefix'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Current catalog number'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'Suffix'), findsOneWidget);
    expect(find.textContaining('Assign the current number'), findsNothing);
    final saveButton = find.widgetWithText(
      FilledButton,
      'Save field ID settings',
    );
    expect(
      tester.getCenter(saveButton).dx,
      closeTo(tester.getCenter(find.byType(FieldIDFields)).dx, 0.1),
    );

    await tester.tap(find.text('Personnel ID'));
    await tester.pumpAndSettle();
    expect(
      find.text('Personnel field IDs require a cataloger'),
      findsOneWidget,
    );
  });

  testWidgets('project ID without an open project shows a note', (
    tester,
  ) async {
    final harness = await _FieldIdSettingsHarness.create(hasProject: false);
    addTearDown(harness.dispose);

    await harness.pump(tester, isMobile: false);
    await tester.tap(find.text('Project ID'));
    await tester.pumpAndSettle();

    expect(
      find.text('Open a project to set project field IDs'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'Prefix'), findsNothing);
    expect(find.text('Save field ID settings'), findsNothing);
    expect(find.text('Auto-increment catalog number'), findsOneWidget);
  });

  testWidgets('used prefix change warns about exports and labels in a dialog', (
    tester,
  ) async {
    final harness = await _FieldIdSettingsHarness.create(
      hasProjectNumber: true,
    );
    addTearDown(harness.dispose);

    await harness.pump(tester, isMobile: false);
    await tester.tap(find.text('Project ID'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Prefix'), 'P-');
    await tester.tap(find.text('Save field ID settings'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('used in exports'), findsOneWidget);
    expect(find.textContaining('written on specimen labels'), findsOneWidget);
    expect(find.text('I understand'), findsOneWidget);
  });

  testWidgets('used prefix change uses a bottom sheet on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = await _FieldIdSettingsHarness.create(
      hasProjectNumber: true,
    );
    addTearDown(harness.dispose);

    await harness.pump(tester, isMobile: true);
    await tester.tap(find.text('Project ID'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Suffix'), '-M');
    await tester.tap(find.text('Save field ID settings'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.textContaining('used in exports'), findsOneWidget);
    expect(find.text('I understand'), findsOneWidget);
  });
}

class _FieldIdSettingsHarness {
  _FieldIdSettingsHarness(this.database, this.container);

  final Database database;
  final ProviderContainer container;

  static Future<_FieldIdSettingsHarness> create({
    bool hasProject = true,
    bool hasProjectNumber = false,
  }) async {
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        fieldIdModeNotifierProvider.overrideWith(_TestFieldIdMode.new),
        projectFieldIdAutoIncrementProvider.overrideWith(
          _TestAutoIncrement.new,
        ),
      ],
    );
    if (!hasProject) return _FieldIdSettingsHarness(database, container);
    container.read(projectUuidProvider.notifier).updateProjectUuid('project-a');
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
            currentCatalogNumber: Value(10),
          ),
        );
    if (hasProjectNumber) {
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('specimen-a'),
              projectUuid: Value('project-a'),
              projectFieldNumber: Value(9),
            ),
          );
    }
    return _FieldIdSettingsHarness(database, container);
  }

  Future<void> pump(WidgetTester tester, {required bool isMobile}) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: FieldIDFields(isMobile: isMobile)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

class _TestFieldIdMode extends FieldIdModeNotifier {
  @override
  Future<FieldIdMode> build() async => FieldIdMode.personnel;

  @override
  Future<void> set(FieldIdMode mode) async {
    state = AsyncValue.data(mode);
  }
}

class _TestAutoIncrement extends ProjectFieldIdAutoIncrementNotifier {
  @override
  Future<bool> build() async => false;

  @override
  Future<void> set(bool value) async {
    state = AsyncValue.data(value);
  }
}
