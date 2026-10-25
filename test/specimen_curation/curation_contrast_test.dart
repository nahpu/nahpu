import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/specimen_curation/specimen_curation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/text_contrast.dart';

/// Every text and icon on the specimen curation page meets WCAG 2.2 AA
/// contrast, in both themes and in each state that colors its text.
void main() {
  late Database database;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(uuid: Value('project-a'), name: Value('A')),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen-a'),
            projectUuid: Value('project-a'),
          ),
        );
    for (final (tissue, type) in [
      ('T-1043', 'Liver'),
      ('T-1044', 'Liver'),
      ('T-1045', 'Muscle'),
      ('T-DUP', 'Liver'),
      ('T-DUP', 'Heart'),
    ]) {
      await database
          .into(database.specimenPart)
          .insert(
            SpecimenPartCompanion(
              specimenUuid: const Value('specimen-a'),
              tissueID: Value(tissue),
              type: Value(type),
            ),
          );
    }
  });

  tearDown(() => database.close());

  Future<void> pumpScreen(WidgetTester tester, ThemeData theme) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      tissueCheckPrefKey: const TissueCheckSettings(
        value: 'EXM',
        partTypes: {'Liver'},
      ).encode(),
    });
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        settingProvider.overrideWithValue(preferences),
        databaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(container.dispose);
    container.read(projectUuidProvider.notifier).updateProjectUuid('project-a');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: theme,
          home: const SpecimenCurationScreen(cameraAvailable: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scan(WidgetTester tester, String code) async {
    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      code,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  void expectReadable(WidgetTester tester, String state) {
    expect(textContrastFailures(tester), isEmpty, reason: state);
  }

  for (final (name, theme) in [
    ('light', NahpuTheme.lightTheme()),
    ('dark', NahpuTheme.darkTheme()),
  ]) {
    testWidgets('scan states are readable in the $name theme', (tester) async {
      await pumpScreen(tester, theme);
      expectReadable(tester, 'ready');

      await scan(tester, 'T-1043');
      expectReadable(tester, 'checked');

      await scan(tester, 'T-1043');
      expectReadable(tester, 'duplicate warning');

      await scan(tester, 'NOPE');
      expectReadable(tester, 'not found error');

      await tester.enterText(
        find.byKey(const ValueKey('tissue-scan-input')),
        't10',
      );
      await tester.pumpAndSettle();
      expectReadable(tester, 'suggestions');
    });

    testWidgets('work list and log are readable in the $name theme', (
      tester,
    ) async {
      await pumpScreen(tester, theme);
      await tester.tap(find.text('Work list'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Place'));
      await tester.pumpAndSettle();
      expectReadable(tester, 'work list with log');

      await tester.enterText(
        find.byKey(const ValueKey('tissue-work-list-search')),
        't-10',
      );
      await tester.pumpAndSettle();
      expectReadable(tester, 'work list search');
    });

    testWidgets('inspector and details are readable in the $name theme', (
      tester,
    ) async {
      await (database.update(
        database.specimenPart,
      )..where((row) => row.tissueID.equals('T-1044'))).write(
        const SpecimenPartCompanion(storageLocation: Value('Box 1: A1')),
      );
      await (database.update(
        database.specimenPart,
      )..where((row) => row.tissueID.equals('T-1045'))).write(
        const SpecimenPartCompanion(storageLocation: Value('Box 1: A2')),
      );
      await (database.update(
        database.specimenPart,
      )..where((row) => row.tissueID.equals('T-DUP'))).write(
        const SpecimenPartCompanion(storageLocation: Value('Box 1: A2')),
      );
      await pumpScreen(tester, theme);
      await tester.tap(find.byKey(const ValueKey('tissue-cell-A2')));
      await tester.pumpAndSettle();
      expectReadable(tester, 'shared cell inspector');

      await tester.tap(find.text('Details').first);
      await tester.pumpAndSettle();
      expectReadable(tester, 'details sheet');
    });

    testWidgets('cell label options are readable in the $name theme', (
      tester,
    ) async {
      await pumpScreen(tester, theme);
      await tester.tap(find.byKey(const ValueKey('tissue-custom-labels')));
      await tester.pumpAndSettle();
      expectReadable(tester, 'custom cell labels');
    });

    testWidgets('filter menu is readable in the $name theme', (tester) async {
      await pumpScreen(tester, theme);
      await tester.tap(find.byKey(const ValueKey('tissue-type-filter')));
      await tester.pumpAndSettle();
      expectReadable(tester, 'filter menu');
    });
  }
}
