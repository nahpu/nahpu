import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_box_card.dart';
import 'package:nahpu/screens/projects/specimen_curation/specimen_curation.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
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

  /// Phones keep the setup in its own tab.
  Future<void> openPhoneSetup(WidgetTester tester) async {
    await tester.tap(find.text('Setup'));
    await tester.pumpAndSettle();
  }

  /// Laptops and phones keep the session log in a tab.
  Future<void> openLog(WidgetTester tester) async {
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tab && (widget.text?.startsWith('Log (') ?? false),
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
    await openLog(tester);
    expect(find.text('Box 1: A1'), findsOneWidget);
    expect(find.text('1043'), findsOneWidget);
    final part = await database.select(database.specimenPart).getSingle();
    expect(part.museumPermanent, 'EXM');
    expect(part.storageLocation, 'Box 1: A1');
  });

  testWidgets('switches to a 100-tube box', (tester) async {
    await pumpScreen(tester, size: const Size(600, 2400));
    await openPhoneSetup(tester);

    await tester.tap(find.text('100 (10×10)'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('tissue-phone-tabs')),
        matching: find.text('Box'),
      ),
    );
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

  const customLabels = TissueCheckSettings(value: 'EXM', customLabels: true);

  testWidgets('phones stack numbering above the box separator', (tester) async {
    await pumpScreen(
      tester,
      size: const Size(420, 2400),
      settings: customLabels,
    );
    await openPhoneSetup(tester);
    final numbering = tester.getTopLeft(find.text('Numbering'));
    final separator = tester.getTopLeft(find.text('Box separator'));
    expect(separator.dy, greaterThan(numbering.dy));
    expect(separator.dx, numbering.dx);
  });

  testWidgets('wider screens keep numbering and box separator on one row', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      size: const Size(1280, 1600),
      settings: customLabels,
    );
    final numbering = tester.getTopLeft(find.text('Numbering'));
    final separator = tester.getTopLeft(find.text('Box separator'));
    expect(separator.dy, numbering.dy);
    expect(separator.dx, greaterThan(numbering.dx));
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

    await openLog(tester);
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

  testWidgets('wide desktops give the log its own column and list skips', (
    tester,
  ) async {
    await addFieldIdParts();
    await pumpScreen(tester, size: const Size(1600, 1000));
    final column = find.byKey(const ValueKey('tissue-log-column'));
    final inspector = find.byKey(const ValueKey('tissue-inspector'));
    expect(
      tester.getTopLeft(column).dx,
      greaterThan(tester.getTopRight(inspector).dx),
    );
    expect(
      tester.getTopRight(inspector).dx,
      greaterThan(tester.getTopRight(find.byType(TissueBoxCard)).dx),
    );
    expect(find.text('Session log'), findsOneWidget);

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

  testWidgets('tall windows cut every column to the box height', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(1720, 1300));
    final boxBottom = tester.getBottomLeft(find.byType(TissueBoxCard)).dy;
    final inspector = find.byKey(const ValueKey('tissue-inspector'));
    final column = find.byKey(const ValueKey('tissue-log-column'));
    expect(tester.getBottomLeft(inspector).dy, boxBottom);
    expect(tester.getBottomLeft(column).dy, boxBottom);
    expect(boxBottom, lessThan(1300 - 100));
  });

  testWidgets('a filled cell can be replaced after confirming', (tester) async {
    await (database.update(
      database.specimenPart,
    )..where((row) => row.tissueID.equals('T-1043'))).write(
      const SpecimenPartCompanion(storageLocation: Value('Box 1: A1')),
    );
    await database
        .into(database.specimenPart)
        .insert(
          const SpecimenPartCompanion(
            specimenUuid: Value('specimen-a'),
            tissueID: Value('T-2000'),
          ),
        );
    await pumpScreen(tester, size: const Size(1600, 1100));
    Text nextCell() =>
        tester.widget<Text>(find.byKey(const ValueKey('tissue-next-cell')));
    expect(nextCell().data, 'A2');

    // Cancelling keeps the next cell.
    await tester.tap(find.byKey(const ValueKey('tissue-cell-A1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tissue-cell-replace')));
    await tester.pumpAndSettle();
    expect(find.text('Replace A1?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(nextCell().data, 'A2');

    await tester.tap(find.byKey(const ValueKey('tissue-cell-replace')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.text('Replace'),
      ),
    );
    await tester.pumpAndSettle();
    expect(nextCell().data, 'A1');
    expect(find.text('Replaces T-1043'), findsOneWidget);
    expect(find.byKey(const ValueKey('tissue-cell-inspector')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      'T-2000',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final parts = await database.select(database.specimenPart).get();
    String? locationOf(String tissue) =>
        parts.singleWhere((part) => part.tissueID == tissue).storageLocation;
    expect(locationOf('T-2000'), 'Box 1: A1');
    expect(locationOf('T-1043'), isNull);
    expect(find.byKey(const ValueKey('tissue-next-replacing')), findsNothing);
    expect(find.text('Replaced T-1043'), findsOneWidget);
  });

  testWidgets('the log exports once it has a tube', (tester) async {
    await pumpScreen(tester, size: const Size(1600, 1000));
    final export = find.byKey(const ValueKey('tissue-log-export'));
    expect(tester.widget<TextButton>(export).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      'T-1043',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(export).onPressed, isNotNull);

    await tester.tap(export);
    await tester.pumpAndSettle();
    expect(find.text('Export session log'), findsOneWidget);
    expect(find.text('1 checked, 0 skipped'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tissue-log-curation-columns')),
      findsOneWidget,
    );
  });

  testWidgets('laptops show the log as an inspector tab', (tester) async {
    await pumpScreen(tester, size: const Size(1280, 800));
    expect(find.byKey(const ValueKey('tissue-log-column')), findsNothing);
    expect(find.text('Checked (0)'), findsNothing);

    await openLog(tester);
    expect(find.text('Checked (0)'), findsOneWidget);
    expect(find.text('Skipped (0)'), findsOneWidget);
  });

  testWidgets('a growing setup scrolls inside the inspector', (tester) async {
    await pumpScreen(tester, size: const Size(1280, 800));
    final box = find.byType(TissueBoxCard);
    final inspector = find.byKey(const ValueKey('tissue-inspector'));
    final boxRect = tester.getRect(box);
    final inspectorRect = tester.getRect(inspector);

    final toggle = find.byKey(const ValueKey('tissue-custom-labels'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    final parasites = find.byKey(const ValueKey('tissue-include-parasites'));
    await tester.ensureVisible(parasites);
    await tester.pumpAndSettle();
    await tester.tap(parasites);
    await tester.pumpAndSettle();

    expect(tester.getRect(box), boxRect);
    expect(tester.getRect(inspector), inspectorRect);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phones pin the scan card below every tab', (tester) async {
    await pumpScreen(tester, size: const Size(420, 900));
    final dock = find.byKey(const ValueKey('tissue-scan-dock'));
    final scan = find.byKey(const ValueKey('tissue-scan-input'));
    expect(find.descendant(of: dock, matching: scan), findsOneWidget);
    expect(tester.getBottomLeft(dock).dy, 900);
    expect(find.byType(TissueBoxCell), findsWidgets);

    await openPhoneSetup(tester);
    expect(find.byKey(const ValueKey('tissue-setup-find')), findsOneWidget);
    expect(find.descendant(of: dock, matching: scan), findsOneWidget);

    await openLog(tester);
    expect(find.text('Checked (0)'), findsOneWidget);
    expect(find.descendant(of: dock, matching: scan), findsOneWidget);
  });

  for (final width in [420.0, 1400.0]) {
    testWidgets('text at 200% fits at ${width.toInt()} px wide', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await (database.update(
        database.specimenPart,
      )..where((row) => row.tissueID.equals('T-1043'))).write(
        const SpecimenPartCompanion(storageLocation: Value('Box 1: A1')),
      );
      await pumpScreen(tester, size: Size(width, 4000));
      await tester.tap(find.byKey(const ValueKey('tissue-cell-A1')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('tissue-cell-inspector')),
        findsOneWidget,
      );
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
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

  testWidgets('a filled cell names its tube and opens its details', (
    tester,
  ) async {
    await (database.update(
      database.specimenPart,
    )..where((row) => row.tissueID.equals('T-1043'))).write(
      const SpecimenPartCompanion(
        storageLocation: Value('Box 1: B2'),
        museumPermanent: Value('FMNH'),
        treatment: Value('ETOH'),
      ),
    );
    await pumpScreen(tester, size: const Size(1280, 1800));

    final cell = find.byKey(const ValueKey('tissue-cell-B2'));
    expect(
      find.descendant(of: cell, matching: find.text('1043')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('tissue-cell-inspector')), findsNothing);

    await tester.tap(cell);
    await tester.pumpAndSettle();
    final inspector = find.byKey(const ValueKey('tissue-cell-inspector'));
    expect(
      find.descendant(of: inspector, matching: find.text('T-1043')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: inspector, matching: find.text('Details')),
    );
    await tester.pumpAndSettle();
    final sheet = find.byKey(const ValueKey('tissue-item-details'));
    expect(
      find.descendant(of: sheet, matching: find.text('Box 1: B2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('FMNH')),
      findsOneWidget,
    );
    expect(find.text('Open record'), findsOneWidget);

    // Tapping the cell again closes the inspector.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    await tester.tap(cell);
    await tester.pumpAndSettle();
    expect(inspector, findsNothing);
  });

  testWidgets('switching boxes closes the inspector', (tester) async {
    await (database.update(
      database.specimenPart,
    )..where((row) => row.tissueID.equals('T-1043'))).write(
      const SpecimenPartCompanion(storageLocation: Value('Box 1: A1')),
    );
    await pumpScreen(tester, size: const Size(1280, 1800));
    await tester.tap(find.byKey(const ValueKey('tissue-cell-A1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tissue-cell-inspector')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tissue-next-box')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tissue-cell-inspector')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('tissue-previous-box')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tissue-cell-inspector')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('tissue-cell-A1')),
        matching: find.text('1043'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Open record shows the specimen of the tube', (tester) async {
    await (database.update(
      database.specimenPart,
    )..where((row) => row.tissueID.equals('T-1043'))).write(
      const SpecimenPartCompanion(storageLocation: Value('Box 1: A1')),
    );
    // The specimen form reads the mammal attributes it shows.
    await database
        .into(database.mammalAttribute)
        .insert(
          const MammalAttributeCompanion(specimenUuid: Value('specimen-a')),
        );
    await pumpScreen(tester, size: const Size(1280, 1800));
    await tester.tap(find.byKey(const ValueKey('tissue-cell-A1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open record'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final form = tester.widget<SpecimenFormView>(find.byType(SpecimenFormView));
    expect(form.specimenUuid, 'specimen-a');
  });

  testWidgets('the inspector sits between the grid and the box pager', (
    tester,
  ) async {
    await (database.update(
      database.specimenPart,
    )..where((row) => row.tissueID.equals('T-1043'))).write(
      const SpecimenPartCompanion(storageLocation: Value('Box 1: I9')),
    );
    await pumpScreen(tester, size: const Size(1280, 1800));
    final lastCell = find.byKey(const ValueKey('tissue-cell-I9'));
    final before = tester.getTopLeft(lastCell);
    await tester.tap(lastCell);
    await tester.pumpAndSettle();

    final inspector = find.byKey(const ValueKey('tissue-cell-inspector'));
    final pager = find.byKey(const ValueKey('tissue-pager-box'));
    expect(tester.getTopLeft(lastCell), before);
    expect(
      tester.getTopLeft(inspector).dy,
      greaterThan(tester.getBottomLeft(lastCell).dy),
    );
    expect(
      tester.getBottomLeft(inspector).dy,
      lessThan(tester.getTopLeft(pager).dy),
    );
  });

  for (final (name, size, isSheet) in [
    ('a bottom sheet on phones', const Size(420, 2400), true),
    ('a dialog on wide screens', const Size(1280, 1800), false),
  ]) {
    testWidgets('tube details show as $name', (tester) async {
      await (database.update(
        database.specimenPart,
      )..where((row) => row.tissueID.equals('T-1043'))).write(
        const SpecimenPartCompanion(storageLocation: Value('Box 1: A1')),
      );
      await pumpScreen(tester, size: size);
      await tester.tap(find.byKey(const ValueKey('tissue-cell-A1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      final details = find.byKey(const ValueKey('tissue-item-details'));
      expect(details, findsOneWidget);
      expect(
        find.ancestor(of: details, matching: find.byType(BottomSheet)),
        isSheet ? findsOneWidget : findsNothing,
      );
      expect(
        find.ancestor(of: details, matching: find.byType(Dialog)),
        isSheet ? findsNothing : findsOneWidget,
      );
    });
  }

  testWidgets('cell label options stay hidden until the toggle is on', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(1280, 2000));
    expect(find.text('Numbering'), findsNothing);
    expect(find.byKey(const ValueKey('tissue-label-example')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('tissue-next-cell'))).data,
      'A1',
    );

    // The setup scrolls inside the inspector, cut to the box's height.
    await tester.ensureVisible(
      find.byKey(const ValueKey('tissue-custom-labels')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tissue-custom-labels')));
    await tester.pumpAndSettle();
    final example = find.byKey(const ValueKey('tissue-label-example'));
    expect(tester.widget<Text>(example).data, 'Example: Box 1: A1 … Box 1: I9');

    await tester.enterText(
      find.byKey(const ValueKey('tissue-box-separator')),
      ' / ',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tissue-zero-pad')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(example).data,
      'Example: Box 1 / A01 … Box 1 / I09',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('tissue-next-cell'))).data,
      'A01',
    );
    expect(find.byKey(const ValueKey('tissue-cell-A01')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('tissue-scan-input')),
      'T-1043',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final part = await database.select(database.specimenPart).getSingle();
    expect(part.storageLocation, 'Box 1 / A01');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('tissue-cell-A01')),
        matching: find.text('1043'),
      ),
      findsOneWidget,
    );

    // Off again: standard labels, but the custom ones are kept.
    await tester.tap(find.byKey(const ValueKey('tissue-custom-labels')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tissue-cell-A1')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final saved = TissueCheckSettings.decode(
      prefs.getString(tissueCheckPrefKey),
    );
    expect(saved.customLabels, isFalse);
    expect(saved.layout.labelFormat.boxSeparator, ' / ');
    expect(saved.layout.labelFormat.zeroPad, isTrue);
  });

  testWidgets('cell label options fit at 200% text on a phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpScreen(
      tester,
      size: const Size(420, 5000),
      settings: const TissueCheckSettings(
        value: 'EXM',
        customLabels: true,
        layout: TissueBoxLayout(numbering: TissueCellNumbering.rowColumn),
      ),
    );
    await openPhoneSetup(tester);
    expect(
      find.byKey(const ValueKey('tissue-row-column-separator')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
