import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/menu_drawer.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';

void main() {
  testWidgets(
    'project actions are ordered and delete follows the final action group',
    (tester) async {
      await _pumpDrawer(tester);

      final closeTile = find.ancestor(
        of: find.text('Close project'),
        matching: find.byType(ListTile),
      );
      final mergeTile = find.ancestor(
        of: find.text('Merge project'),
        matching: find.byType(ListTile),
      );
      final deleteTile = find.ancestor(
        of: find.text('Delete project'),
        matching: find.byType(ListTile),
      );

      expect(
        tester.getTopLeft(closeTile).dy,
        lessThan(tester.getTopLeft(mergeTile).dy),
      );
      expect(
        _hasDividerBetween(
          tester,
          closeBottom: tester.getBottomRight(closeTile).dy,
          mergeTop: tester.getTopLeft(mergeTile).dy,
        ),
        isTrue,
      );

      final finalDivider = find.byType(Divider).last;
      expect(
        tester.getTopLeft(deleteTile).dy,
        greaterThanOrEqualTo(tester.getBottomRight(finalDivider).dy),
      );
    },
  );

  testWidgets('project drawer can hide close project', (tester) async {
    await _pumpDrawer(tester, showCloseProject: false);

    expect(find.text('Close project'), findsNothing);
    expect(find.text('Merge project'), findsOneWidget);
    expect(find.text('Delete project'), findsOneWidget);
  });
}

Future<void> _pumpDrawer(
  WidgetTester tester, {
  bool showCloseProject = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(500, 900);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  addTearDown(database.close);
  await database
      .into(database.project)
      .insert(
        const ProjectCompanion(
          uuid: Value('project-menu'),
          name: Value('Menu project'),
        ),
      );

  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(database)],
  );
  addTearDown(container.dispose);
  container
      .read(projectUuidProvider.notifier)
      .updateProjectUuid('project-menu');

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          drawer: ProjectMenuDrawer(showCloseProject: showCloseProject),
        ),
      ),
    ),
  );
  final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
  scaffold.openDrawer();
  await tester.pumpAndSettle();
}

bool _hasDividerBetween(
  WidgetTester tester, {
  required double closeBottom,
  required double mergeTop,
}) {
  final dividers = find.byType(Divider);
  for (var index = 0; index < dividers.evaluate().length; index++) {
    final dividerTop = tester.getTopLeft(dividers.at(index)).dy;
    final dividerBottom = tester.getBottomRight(dividers.at(index)).dy;
    if (dividerTop >= closeBottom && dividerBottom <= mergeTop) {
      return true;
    }
  }
  return false;
}
