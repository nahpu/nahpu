import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/personnel/add_personnel.dart';
import 'package:nahpu/screens/projects/personnel/manage_personnel.dart';
import 'package:nahpu/screens/projects/personnel/new_personnel.dart';
import 'package:nahpu/screens/projects/personnel/personnel_details.dart';
import 'package:nahpu/screens/projects/personnel/personnel_form.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
  testWidgets('wide selector waits for a tap before showing details', (
    tester,
  ) async {
    await _pumpAddPersonnel(
      tester,
      size: const Size(1000, 900),
      linkedPersonnelUuid: 'ada',
    );

    expect(find.byKey(const ValueKey('personnel-wide-layout')), findsOneWidget);
    expect(find.byType(PersonnelDetails), findsNothing);
    expect(find.text('Select personnel to view details'), findsOneWidget);
    expect(find.text('Added'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('personnel-list-region')))
          .height,
      greaterThan(450),
    );

    await tester.tap(find.byKey(const ValueKey('personnel-grace')));
    await tester.pump();

    final details = find.byType(PersonnelDetails);
    expect(details, findsOneWidget);
    expect(
      find.descendant(of: details, matching: find.text('Grace Hopper')),
      findsOneWidget,
    );
    final editButton = find.descendant(
      of: details,
      matching: find.text('Edit personnel'),
    );
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    expect(find.byType(EditPersonnelForm), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact selector separates checkbox selection from details', (
    tester,
  ) async {
    await _pumpAddPersonnel(
      tester,
      size: const Size(390, 844),
      linkedPersonnelUuid: 'ada',
    );

    expect(find.byKey(const ValueKey('personnel-wide-layout')), findsNothing);
    final graceTile = find.byKey(const ValueKey('personnel-grace'));
    final graceTileSize = tester.getSize(graceTile);
    await tester.tapAt(
      tester.getTopLeft(graceTile) + Offset(24, graceTileSize.height / 2),
    );
    await tester.pump();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.byType(PersonnelDetails), findsNothing);

    await tester.tap(graceTile);
    await tester.pumpAndSettle();

    final details = find.byType(PersonnelDetails);
    expect(details, findsOneWidget);
    expect(
      find.descendant(of: details, matching: find.text('Grace Hopper')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: details, matching: find.text('Edit personnel')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PersonnelDetails), findsNothing);
    expect(find.byType(EditPersonnelForm), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selection excludes added personnel and reports no search match',
    (tester) async {
      await _pumpAddPersonnel(
        tester,
        size: const Size(1000, 900),
        linkedPersonnelUuid: 'ada',
      );

      await tester.tap(find.text('Select all'));
      await tester.pump();
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('Add 1 personnel'), findsOneWidget);

      final searchField = find.descendant(
        of: find.byType(CommonSearchBar),
        matching: find.byType(TextField),
      );
      await tester.enterText(searchField, 'nobody');
      await tester.pump();

      expect(find.text('No personnel match “nobody”.'), findsOneWidget);
      expect(find.byKey(const ValueKey('personnel-ada')), findsNothing);
      expect(find.byKey(const ValueKey('personnel-grace')), findsNothing);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(find.byKey(const ValueKey('personnel-ada')), findsOneWidget);
      expect(find.byKey(const ValueKey('personnel-grace')), findsOneWidget);
    },
  );

  testWidgets('add personnel form keeps optional sections under show more', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(700, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = _personnelController();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonnelFormPage(
                ctr: controller,
                personnelUuid: 'ada',
                isEditing: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FormSection), findsNWidgets(2));
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Specimen care'), findsOneWidget);
    expect(find.text('Contact'), findsNothing);
    expect(find.text('Notes'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Email'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Phone'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'ORCID iD'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Initials*'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Cataloger number*'), findsOneWidget);

    await tester.tap(find.text('Show more'));
    await tester.pump();

    expect(find.byType(FormSection), findsNWidgets(4));
    expect(find.text('Contact'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Notes'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit personnel form keeps contact and notes sections', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(700, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonnelFormPage(
                ctr: _personnelController(),
                personnelUuid: 'ada',
                isEditing: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FormSection), findsNWidgets(4));
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Notes'), findsAtLeastNWidgets(1));
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'ORCID iD'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Notes'), findsOneWidget);

    await tester.tap(find.text('Show less'));
    await tester.pump();

    expect(find.byType(FormSection), findsNWidgets(2));
    expect(find.widgetWithText(TextFormField, 'ORCID iD'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsNothing);
    expect(find.widgetWithText(TextField, 'Notes'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manage personnel uses outlined tap-driven details', (
    tester,
  ) async {
    await _pumpPersonnelManager(tester, size: const Size(1000, 900));

    expect(
      find.byKey(const ValueKey('manage-personnel-wide-layout')),
      findsOneWidget,
    );
    expect(find.byType(PersonnelDetails), findsNothing);
    expect(find.text('Select personnel to view details'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('managed-personnel-grace')));
    await tester.pump();

    expect(find.byType(PersonnelDetails), findsOneWidget);
    expect(find.text('Grace Hopper'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Edit personnel'));
    await tester.pumpAndSettle();
    expect(find.byType(EditPersonnelForm), findsOneWidget);
  });

  testWidgets('compact manage personnel opens a detail sheet', (tester) async {
    await _pumpPersonnelManager(tester, size: const Size(390, 844));

    expect(
      find.byKey(const ValueKey('manage-personnel-wide-layout')),
      findsNothing,
    );
    expect(find.byType(PersonnelDetails), findsNothing);

    await tester.tap(find.byKey(const ValueKey('managed-personnel-grace')));
    await tester.pumpAndSettle();

    expect(find.byType(PersonnelDetails), findsOneWidget);
    expect(find.text('Edit personnel'), findsOneWidget);
  });

  testWidgets('manage personnel selection mode protects project personnel', (
    tester,
  ) async {
    await _pumpPersonnelManager(
      tester,
      size: const Size(1000, 900),
      linkedPersonnelUuid: 'ada',
    );

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    final adaTile = find.byKey(const ValueKey('managed-personnel-ada'));
    final graceTile = find.byKey(const ValueKey('managed-personnel-grace'));
    Checkbox checkboxFor(Finder tile) => tester.widget<Checkbox>(
      find.descendant(of: tile, matching: find.byType(Checkbox)),
    );

    expect(checkboxFor(adaTile).onChanged, isNull);
    await tester.tap(adaTile);
    await tester.pump();
    expect(checkboxFor(adaTile).value, isFalse);

    await tester.tap(graceTile);
    await tester.pump();
    expect(checkboxFor(graceTile).value, isTrue);
    expect(find.byType(PersonnelDetails), findsNothing);
  });

  testWidgets('manage personnel stays open after deletion', (tester) async {
    await _pumpPersonnelManager(tester, size: const Size(1000, 900));

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('managed-personnel-grace')));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(ManagePersonnel), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byKey(const ValueKey('managed-personnel-grace')), findsNothing);
    expect(find.byKey(const ValueKey('managed-personnel-ada')), findsOneWidget);
  });
}

PersonnelFormCtrModel _personnelController() {
  return PersonnelFormCtrModel(
    nameCtr: TextEditingController(text: 'Ada Lovelace'),
    initialCtr: TextEditingController(text: 'AL'),
    emailCtr: TextEditingController(text: 'ada@example.org'),
    phoneCtr: TextEditingController(text: '1234567890'),
    orcidCtr: TextEditingController(text: '0000-0002-1825-0097'),
    affiliationCtr: TextEditingController(text: 'Analytical Engine Lab'),
    roleCtr: 'Cataloger',
    collectorNumCtr: TextEditingController(text: '42'),
    photoPathCtr: TextEditingController(
      text: 'assets/avatars/handika_crocidura.png',
    ),
    noteCtr: TextEditingController(text: 'Lead cataloger'),
    isRegisterField: true,
  );
}

Future<void> _pumpAddPersonnel(
  WidgetTester tester, {
  required Size size,
  String? linkedPersonnelUuid,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  addTearDown(database.close);
  const projectUuid = 'personnel-project';
  await database
      .into(database.project)
      .insert(
        const ProjectCompanion(
          uuid: Value(projectUuid),
          name: Value('Personnel project'),
        ),
      );
  await database.batch(
    (batch) => batch.insertAll(database.personnel, const [
      PersonnelCompanion(
        uuid: Value('ada'),
        name: Value('Ada Lovelace'),
        initial: Value('AL'),
        email: Value('ada@example.org'),
        affiliation: Value('Analytical Engine Lab'),
        orcid: Value('0000-0002-1825-0097'),
        role: Value('Cataloger'),
        currentFieldNumber: Value(42),
        notes: Value('Lead cataloger'),
        isRegisterField: Value(true),
      ),
      PersonnelCompanion(
        uuid: Value('grace'),
        name: Value('Grace Hopper'),
        affiliation: Value('US Navy'),
        role: Value('Determiner only'),
        isRegisterField: Value(false),
      ),
    ]),
  );
  if (linkedPersonnelUuid != null) {
    await database
        .into(database.personnelList)
        .insert(
          PersonnelListCompanion(
            projectUuid: const Value(projectUuid),
            personnelUuid: Value(linkedPersonnelUuid),
          ),
        );
  }

  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(database)],
  );
  addTearDown(container.dispose);
  container.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AddPersonnel()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpPersonnelManager(
  WidgetTester tester, {
  required Size size,
  String? linkedPersonnelUuid,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  addTearDown(database.close);
  await database.batch(
    (batch) => batch.insertAll(database.personnel, const [
      PersonnelCompanion(
        uuid: Value('ada'),
        name: Value('Ada Lovelace'),
        affiliation: Value('Analytical Engine Lab'),
      ),
      PersonnelCompanion(
        uuid: Value('grace'),
        name: Value('Grace Hopper'),
        affiliation: Value('US Navy'),
      ),
    ]),
  );
  if (linkedPersonnelUuid != null) {
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('manager-project'),
            name: Value('Manager project'),
          ),
        );
    await database
        .into(database.personnelList)
        .insert(
          PersonnelListCompanion(
            projectUuid: const Value('manager-project'),
            personnelUuid: Value(linkedPersonnelUuid),
          ),
        );
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: ManagePersonnel()),
    ),
  );
  await tester.pumpAndSettle();
}
