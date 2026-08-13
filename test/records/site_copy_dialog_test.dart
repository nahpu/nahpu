import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/sites/components/copy_from_project_dialog.dart';

void main() {
  late Database database;
  ProviderContainer? container;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    container?.dispose();
    await database.close();
  });

  Future<void> pumpDialog(WidgetTester tester, int targetSiteId) async {
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    container!
        .read(projectUuidProvider.notifier)
        .updateProjectUuid('target-project');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container!,
        child: MaterialApp(home: SiteCopyDialog(targetSiteId: targetSiteId)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the multiple-project message when no source exists', (
    tester,
  ) async {
    await ProjectQuery(database).createProject(
      const ProjectCompanion(
        uuid: Value('target-project'),
        name: Value('Target'),
      ),
    );
    final targetId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('target-project')));

    await pumpDialog(tester, targetId);

    expect(
      find.textContaining('Create or import another project'),
      findsOneWidget,
    );
    expect(find.text('Multiple projects required'), findsOneWidget);
  });

  testWidgets('walks from project selection to site and field selection', (
    tester,
  ) async {
    await ProjectQuery(database).createProject(
      const ProjectCompanion(
        uuid: Value('target-project'),
        name: Value('Target'),
      ),
    );
    await ProjectQuery(database).createProject(
      const ProjectCompanion(
        uuid: Value('source-project'),
        name: Value('Source'),
      ),
    );
    final targetId = await database
        .into(database.site)
        .insert(const SiteCompanion(projectUuid: Value('target-project')));
    final sourceId = await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            projectUuid: Value('source-project'),
            siteID: Value('SOURCE-1'),
            country: Value('Canada'),
          ),
        );
    await CoordinateQuery(database).createCoordinate(
      CoordinateCompanion(
        decimalLatitude: const Value(1.0),
        decimalLongitude: const Value(2.0),
        siteID: Value(sourceId),
      ),
    );

    await pumpDialog(tester, targetId);

    expect(find.text('Source'), findsOneWidget);
    await tester.tap(find.byType(RadioListTile<String>));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('SOURCE-1'), findsOneWidget);
    expect(
      find.byKey(ValueKey('copy-source-site-tile-$sourceId')),
      findsOneWidget,
    );
    expect(find.byTooltip('Show QR code'), findsNothing);

    await tester.tap(find.byKey(ValueKey('copy-source-site-tile-$sourceId')));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Country'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    }
    await tester.pump();
    expect(find.text('Coordinates'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('copy-field-tile-coordinates')),
      findsOneWidget,
    );
    expect(find.text('1 coordinate'), findsOneWidget);
  });
}
