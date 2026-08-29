import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/associated_data.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/sites/components/tab_bar.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/associated_data.dart';

void main() {
  late Database database;
  late int siteId;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('associated-ui-project'),
            name: Value('Associated UI'),
          ),
        );
    siteId = await database
        .into(database.site)
        .insert(
          const SiteCompanion(projectUuid: Value('associated-ui-project')),
        );
  });

  tearDown(() => database.close());

  testWidgets('site data card contains coordinates and associated data tabs', (
    tester,
  ) async {
    await _pump(tester, database, SiteDataTabBar(siteId: siteId));

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.tabs, hasLength(2));
    expect(find.text('Coordinates'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.storage_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(AssociatedDataViewer), findsOneWidget);
    expect(find.text('Associated Data'), findsOneWidget);
  });

  testWidgets('associated data list matches the shared selection controls', (
    tester,
  ) async {
    final dataId = await AssociatedDataQuery(database).createDataAssociation(
      AssociatedDataTarget.site(siteId),
      const AssociatedDataCompanion(
        name: Value('Field notes'),
        type: Value('Link'),
        uri: Value('https://example.org/notes'),
      ),
    );
    expect(dataId, isPositive);

    await _pump(
      tester,
      database,
      AssociatedDataViewer(target: AssociatedDataTarget.site(siteId)),
    );
    expect(find.text('Field notes'), findsOneWidget);
    expect(find.text('Link'), findsOneWidget);
    expect(find.text('example.org'), findsOneWidget);
    expect(find.byTooltip('https://example.org/notes'), findsOneWidget);
    final itemTile = tester.widget<ListTile>(find.byType(ListTile));
    expect(itemTile.title, isA<Text>());
    expect((itemTile.title! as Text).maxLines, 1);
    expect(itemTile.subtitle, isA<AssociatedDataSubtitle>());
    expect(find.byType(PopupMenuButton<AssociatedDataAction>), findsOneWidget);

    await tester.tap(find.text('Select'));
    await tester.pump();

    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.byType(ListCheckBox), findsOneWidget);
    expect(find.byType(DeleteItemsButton), findsOneWidget);
    final deleteButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byType(DeleteItemsButton),
        matching: find.byType(IconButton),
      ),
    );
    expect(deleteButton.onPressed, isNull);

    await tester.tap(find.byType(ListCheckBox));
    await tester.pump();
    final enabledDeleteButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byType(DeleteItemsButton),
        matching: find.byType(IconButton),
      ),
    );
    expect(enabledDeleteButton.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
    expect(find.byType(PopupMenuButton<AssociatedDataAction>), findsNothing);
  });

  testWidgets('associated data delete removes the selected current link', (
    tester,
  ) async {
    final dataId = await AssociatedDataQuery(database).createDataAssociation(
      AssociatedDataTarget.site(siteId),
      const AssociatedDataCompanion(
        name: Value('Removable notes'),
        type: Value('Link'),
        uri: Value('https://example.org/removable'),
      ),
    );

    await _pump(
      tester,
      database,
      AssociatedDataViewer(target: AssociatedDataTarget.site(siteId)),
    );
    await tester.tap(find.text('Select'));
    await tester.pump();
    await tester.tap(find.byType(ListCheckBox));
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(DeleteItemsButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Remove associated data'), findsOneWidget);

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(
      await AssociatedDataQuery(database).getAssociatedDataById(dataId),
      isNull,
    );
    expect(find.text('No associated data added'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('associated data editor uses details and resource sections', (
    tester,
  ) async {
    await _pump(
      tester,
      database,
      SizedBox(
        height: 800,
        child: AssociatedDataForm(target: AssociatedDataTarget.site(siteId)),
      ),
    );

    expect(find.byType(FormSection), findsNWidgets(2));
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Resource'), findsOneWidget);
    expect(find.byType(FormButton), findsOneWidget);
  });

  testWidgets('compact item actions open a bottom sheet', (tester) async {
    const data = AssociatedDataData(
      primaryId: 1,
      projectUuid: 'associated-ui-project',
      name: 'Link',
      type: 'Link',
      uri: 'https://example.org',
    );

    await _pump(
      tester,
      database,
      const AssociatedDataActions(
        target: AssociatedDataTarget.site(1),
        data: data,
      ),
      size: const Size(500, 800),
    );
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    await tester.tap(find.byTooltip('Associated data actions'));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Show info'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Open link'), findsOneWidget);
  });

  testWidgets('file row uses two lines and a tooltip warning when missing', (
    tester,
  ) async {
    const data = AssociatedDataData(
      primaryId: 1,
      projectUuid: 'associated-ui-project',
      name: 'Field document',
      type: 'File',
      date: '2026-08-13',
      description: 'A description that belongs in Show info only.',
      uri: 'file:///definitely/missing/report.pdf',
    );

    await _pump(
      tester,
      database,
      const AssociatedDataItem(
        target: AssociatedDataTarget.site(1),
        data: data,
        isSelecting: false,
        isSelected: false,
        onSelectionChanged: _ignoreSelection,
      ),
    );

    expect(find.text('Field document'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
    expect(find.text('report.pdf'), findsOneWidget);
    expect(find.byTooltip(data.uri!), findsOneWidget);
    expect(find.byTooltip('File unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AssociatedDataLeadingIcon),
        matching: find.byIcon(Icons.warning_amber_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AssociatedDataSubtitle),
        matching: find.byIcon(Icons.warning_amber_rounded),
      ),
      findsNothing,
    );
    final warningPosition = tester.widget<Positioned>(
      find.ancestor(
        of: find.byIcon(Icons.warning_amber_rounded),
        matching: find.byType(Positioned),
      ),
    );
    expect(warningPosition.right, 0);
    expect(warningPosition.bottom, 0);
    expect(find.text(data.description!), findsNothing);
    expect(find.text(data.date!), findsNothing);
    expect(find.text('File unavailable'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(AssociatedDataSubtitle),
        matching: find.byType(Row),
      ),
      findsOneWidget,
    );
  });

  testWidgets('wide actions use vertical dots and divide before Share', (
    tester,
  ) async {
    const data = AssociatedDataData(
      primaryId: 1,
      projectUuid: 'associated-ui-project',
      name: 'Link',
      type: 'Link',
      uri: 'https://example.org',
    );

    await _pump(
      tester,
      database,
      const AssociatedDataActions(
        target: AssociatedDataTarget.site(1),
        data: data,
      ),
    );

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    await tester.tap(find.byTooltip('Associated data actions'));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenuDivider), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Show info')).dy,
      lessThan(tester.getTopLeft(find.text('Share')).dy),
    );
  });

  testWidgets('associated data info uses sectioned complete metadata', (
    tester,
  ) async {
    const data = AssociatedDataData(
      primaryId: 7,
      projectUuid: 'associated-ui-project',
      name: 'Field document',
      type: 'File',
      date: '2026-08-13',
      description: 'Daily field notes',
      uri: 'file:///definitely/missing/report.pdf',
    );

    await _pump(
      tester,
      database,
      const SizedBox(height: 800, child: AssociatedDataDetails(data: data)),
    );

    expect(find.byType(FormSection), findsNWidgets(3));
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Resource'), findsOneWidget);
    expect(find.text('Identifiers'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Data type'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Origin storage path'), findsOneWidget);
    expect(find.text('Storage'), findsOneWidget);
    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('Associated data ID'), findsNothing);
    expect(find.text('Project UUID'), findsOneWidget);
    expect(find.text('Field document'), findsOneWidget);
    expect(find.text('Daily field notes'), findsOneWidget);
    expect(find.text('Linked original'), findsOneWidget);
    expect(find.text('File unavailable'), findsOneWidget);
    expect(find.text('7'), findsNothing);
  });
}

void _ignoreSelection(bool value) {}

Future<void> _pump(
  WidgetTester tester,
  Database database,
  Widget child, {
  Size size = const Size(1200, 1000),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}
