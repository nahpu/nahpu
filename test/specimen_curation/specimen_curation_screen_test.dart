import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_box_card.dart';
import 'package:nahpu/screens/projects/specimen_curation/specimen_curation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await database
        .into(database.specimenPart)
        .insert(
          const SpecimenPartCompanion(
            specimenUuid: Value('specimen-a'),
            tissueID: Value('T-1043'),
          ),
        );
  });

  tearDown(() => database.close());

  Future<void> pumpScreen(
    WidgetTester tester, {
    Size? size,
    TissueCheckSettings settings = const TissueCheckSettings(value: 'EXM'),
  }) async {
    if (size != null) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    SharedPreferences.setMockInitialValues({
      tissueCheckPrefKey: settings.encode(),
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
        child: const MaterialApp(
          home: SpecimenCurationScreen(cameraAvailable: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a scanned tube fills the next cell and is logged', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(1280, 1600));

    expect(find.byType(TissueBoxCell), findsNWidgets(81));
    expect(find.text('0 / 81 filled'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      'T-1043',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('1 / 81 filled'), findsOneWidget);
    expect(find.text('Box 1: A1'), findsOneWidget);
    expect(find.text('1043'), findsOneWidget);
    final part = await database.select(database.specimenPart).getSingle();
    expect(part.museumPermanent, 'EXM');
    expect(part.storageLocation, 'Box 1: A1');
  });

  testWidgets('switches to a 100-tube box', (tester) async {
    await pumpScreen(tester, size: const Size(600, 2400));

    await tester.tap(find.text('100 (10×10)'));
    await tester.pumpAndSettle();

    expect(find.byType(TissueBoxCell), findsNWidgets(100));
    expect(find.text('0 / 100 filled'), findsOneWidget);
  });

  bool scanFieldHasFocus(WidgetTester tester) {
    return tester
        .widget<EditableText>(
          find.descendant(
            of: find.byKey(const ValueKey('tissue-scan-input')),
            matching: find.byType(EditableText),
          ),
        )
        .focusNode
        .hasFocus;
  }

  testWidgets('wide layouts focus the scan field on open', (tester) async {
    await pumpScreen(tester, size: const Size(1280, 1600));
    expect(scanFieldHasFocus(tester), isTrue);
  });

  testWidgets('phone layouts wait for a tap to focus the scan field', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(420, 2400));
    expect(scanFieldHasFocus(tester), isFalse);

    await tester.tap(find.byKey(const ValueKey('tissue-scan-input')));
    await tester.pumpAndSettle();
    expect(scanFieldHasFocus(tester), isTrue);
  });

  testWidgets('phones stack numbering above fill order', (tester) async {
    await pumpScreen(tester, size: const Size(420, 2400));
    final numbering = tester.getTopLeft(find.text('Numbering'));
    final fillOrder = tester.getTopLeft(find.text('Fill order'));
    expect(fillOrder.dy, greaterThan(numbering.dy));
    expect(fillOrder.dx, numbering.dx);
  });

  testWidgets('wider screens keep numbering and fill order on one row', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(1280, 1600));
    final numbering = tester.getTopLeft(find.text('Numbering'));
    final fillOrder = tester.getTopLeft(find.text('Fill order'));
    expect(fillOrder.dy, numbering.dy);
    expect(fillOrder.dx, greaterThan(numbering.dx));
  });

  Future<void> addFieldIdParts() async {
    await database
        .into(database.personnel)
        .insert(
          const PersonnelCompanion(uuid: Value('p-abc'), initial: Value('ABC')),
        );
    await database
        .into(database.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen-b'),
            projectUuid: Value('project-a'),
            catalogerID: Value('p-abc'),
            fieldNumber: Value(1),
          ),
        );
    for (final (type, treatment) in [('Liver', 'ETOH'), ('Muscle', 'DMSO')]) {
      await database
          .into(database.specimenPart)
          .insert(
            SpecimenPartCompanion(
              specimenUuid: const Value('specimen-b'),
              type: Value(type),
              treatment: Value(treatment),
            ),
          );
    }
  }

  testWidgets('field ID entry with a type places the right part', (
    tester,
  ) async {
    await addFieldIdParts();
    await pumpScreen(
      tester,
      size: const Size(1280, 1600),
      settings: const TissueCheckSettings(
        value: 'EXM',
        identifyBy: TissueIdentifyBy.fieldId,
        partType: 'Muscle',
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      'abc 1',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('ABC1 · Muscle · DMSO'), findsOneWidget);
    final muscle = await (database.select(
      database.specimenPart,
    )..where((row) => row.type.equals('Muscle'))).getSingle();
    expect(muscle.storageLocation, 'Box 1: A1');
  });

  testWidgets('the work list places parts into the next cell', (tester) async {
    await addFieldIdParts();
    await pumpScreen(
      tester,
      size: const Size(1280, 1600),
      settings: const TissueCheckSettings(value: 'EXM', partType: 'Liver'),
    );

    await tester.tap(find.text('Work list'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('tissue-work-list-current')),
      findsOneWidget,
    );
    expect(find.text('ABC1 · Liver · ETOH'), findsOneWidget);

    await tester.tap(find.text('Place'));
    await tester.pumpAndSettle();

    expect(find.text('1 / 81 filled'), findsOneWidget);
    expect(
      find.text(
        'No unplaced parts match the tissue type and preservation '
        'filters.',
      ),
      findsOneWidget,
    );
  });
}
