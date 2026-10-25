import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_box_card.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_check_log.dart';
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
        partTypes: {'Muscle'},
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
      settings: const TissueCheckSettings(value: 'EXM', partTypes: {'Liver'}),
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

  testWidgets('marks the page as beta', (tester) async {
    await pumpScreen(tester, size: const Size(1280, 1600));
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Beta')),
      findsOneWidget,
    );
  });

  testWidgets('type filter keeps several checked values', (tester) async {
    await pumpScreen(
      tester,
      size: const Size(1280, 1600),
      settings: const TissueCheckSettings(
        value: 'EXM',
        partTypes: {'Liver', 'Muscle'},
      ),
    );
    expect(find.text('Liver, Muscle'), findsOneWidget);

    Future<TissueCheckSettings> saved() async {
      final prefs = await SharedPreferences.getInstance();
      return TissueCheckSettings.decode(prefs.getString(tissueCheckPrefKey));
    }

    await tester.tap(find.byKey(const ValueKey('tissue-type-filter')));
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('tissue-type-filter'));
    expect(
      tester.getSize(find.widgetWithText(CheckboxMenuButton, 'Muscle')).width,
      moreOrLessEquals(tester.getSize(field).width, epsilon: 1),
    );
    await tester.tap(find.widgetWithText(CheckboxMenuButton, 'Muscle'));
    await tester.pumpAndSettle();
    expect((await saved()).partTypes, {'Liver'});

    await tester.tap(find.widgetWithText(CheckboxMenuButton, 'Any'));
    await tester.pumpAndSettle();
    expect((await saved()).partTypes, isEmpty);
  });

  testWidgets('include parasites scans a parasite into the box', (
    tester,
  ) async {
    await database
        .into(database.parasite)
        .insert(
          const ParasiteCompanion(
            specimenUuid: Value('specimen-a'),
            parasiteID: Value('P-7'),
            parasiteUuid: Value('parasite-7'),
          ),
        );
    await pumpScreen(tester, size: const Size(1280, 1600));

    expect(
      find.byKey(const ValueKey('tissue-parasite-category-filter')),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey('tissue-include-parasites')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('tissue-parasite-category-filter')),
      findsOneWidget,
    );
    expect(find.text('Tissue ID, parasite ID, or barcode'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      'P-7',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final parasite = await database.select(database.parasite).getSingle();
    expect(parasite.museumPermanent, 'EXM');
    expect(parasite.storageLocation, 'Box 1: A1');
  });

  testWidgets('work list search places a tube out of order', (tester) async {
    await addFieldIdParts();
    await pumpScreen(
      tester,
      size: const Size(1280, 1600),
      settings: const TissueCheckSettings(value: 'EXM'),
    );

    await tester.tap(find.text('Work list'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('tissue-work-list-search')),
      'muscle',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ABC1 · Muscle · DMSO').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('tissue-work-list-current')))
          .data,
      'ABC1 · Muscle · DMSO',
    );

    await tester.tap(find.text('Place'));
    await tester.pumpAndSettle();
    final muscle = await (database.select(
      database.specimenPart,
    )..where((row) => row.type.equals('Muscle'))).getSingle();
    expect(muscle.storageLocation, 'Box 1: A1');
  });

  testWidgets('the field ID toggle sits above the scan field', (tester) async {
    await addFieldIdParts();
    await pumpScreen(
      tester,
      size: const Size(1280, 1600),
      settings: const TissueCheckSettings(value: 'EXM', partTypes: {'Muscle'}),
    );

    expect(find.byType(SegmentedButton<TissueIdentifyBy>), findsNothing);
    final toggle = find.byKey(const ValueKey('tissue-search-by-field-id'));
    final input = find.byKey(const ValueKey('tissue-scan-input'));
    expect(tester.getTopLeft(toggle).dy, lessThan(tester.getTopLeft(input).dy));
    expect(find.text('Tissue ID or barcode'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.text('Field ID'), findsOneWidget);

    await tester.enterText(input, 'abc 1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final muscle = await (database.select(
      database.specimenPart,
    )..where((row) => row.type.equals('Muscle'))).getSingle();
    expect(muscle.storageLocation, 'Box 1: A1');
  });

  testWidgets('typing shows code suggestions; picking one scans it', (
    tester,
  ) async {
    await database
        .into(database.specimenPart)
        .insert(
          const SpecimenPartCompanion(
            specimenUuid: Value('specimen-a'),
            tissueID: Value('T-1099'),
          ),
        );
    await pumpScreen(tester, size: const Size(1280, 1600));

    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      't10',
    );
    await tester.pumpAndSettle();
    final suggestions = find.byKey(const ValueKey('tissue-scan-suggestions'));
    expect(
      find.descendant(of: suggestions, matching: find.text('T-1043')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: suggestions, matching: find.text('T-1099')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: suggestions, matching: find.text('T-1099')),
    );
    await tester.pumpAndSettle();
    final part = await (database.select(
      database.specimenPart,
    )..where((row) => row.tissueID.equals('T-1099'))).getSingle();
    expect(part.storageLocation, 'Box 1: A1');
    expect(suggestions, findsNothing);
  });

  testWidgets('Enter scans the typed code, not a suggestion', (tester) async {
    await pumpScreen(tester, size: const Size(1280, 1600));
    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      'T-10',
    );
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('Not found: T-10'), findsOneWidget);
  });

  testWidgets('the log spans the page on wide screens and lists skips', (
    tester,
  ) async {
    await addFieldIdParts();
    await pumpScreen(tester, size: const Size(1400, 2000));
    final log = find.byType(TissueCheckLogCard);
    final box = find.byType(TissueBoxCard);
    expect(tester.getTopLeft(log).dx, tester.getTopLeft(box).dx);
    expect(
      tester.getSize(log).width,
      greaterThan(tester.getSize(box).width * 1.5),
    );
    // Checked and skipped sit side by side.
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('tissue-log-skipped'))).dy,
      tester.getTopLeft(find.byKey(const ValueKey('tissue-log-checked'))).dy,
    );

    await tester.tap(find.text('Work list'));
    await tester.pumpAndSettle();
    final first = tester
        .widget<Text>(find.byKey(const ValueKey('tissue-work-list-current')))
        .data!;
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Skipped (1)'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('tissue-log-skipped')),
        matching: find.text(first),
      ),
      findsOneWidget,
    );
  });

  for (final width in [420.0, 1400.0]) {
    testWidgets('text at 200% fits at ${width.toInt()} px wide', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(tester, size: Size(width, 4000));
      await tester.tap(find.text('Work list'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the pager steps between boxes', (tester) async {
    await pumpScreen(tester, size: const Size(1280, 1600));
    final previous = find.byKey(const ValueKey('tissue-previous-box'));
    final next = find.byKey(const ValueKey('tissue-next-box'));
    final pagerBox = find.byKey(const ValueKey('tissue-pager-box'));
    expect(tester.widget<Text>(pagerBox).data, 'Box 1');
    expect(tester.widget<IconButton>(previous).onPressed, isNull);

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(pagerBox).data, 'Box 2');
    expect(tester.widget<IconButton>(previous).onPressed, isNotNull);

    await tester.tap(previous);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(pagerBox).data, 'Box 1');
    final prefs = await SharedPreferences.getInstance();
    expect(
      TissueCheckSettings.decode(prefs.getString(tissueCheckPrefKey)).boxNumber,
      1,
    );
  });
}
