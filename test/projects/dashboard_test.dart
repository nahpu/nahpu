import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/menu_drawer.dart';
import 'package:nahpu/screens/projects/dashboard.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';

void main() {
  testWidgets('project dashboard has no create speed dial', (tester) async {
    await _pumpDashboard(tester, const Size(1600, 1400));

    final dashboardScaffold = tester.widget<Scaffold>(
      find.byType(Scaffold).first,
    );
    final appBar = dashboardScaffold.appBar! as AppBar;
    expect(dashboardScaffold.floatingActionButton, isNull);
    expect(dashboardScaffold.drawer, isNull);
    expect(appBar.automaticallyImplyLeading, isFalse);
  });

  testWidgets('project dashboard owns the drawer below the rail breakpoint', (
    tester,
  ) async {
    await _pumpDashboard(tester, const Size(599, 1400));

    final dashboardScaffold = tester.widget<Scaffold>(
      find.byType(Scaffold).first,
    );
    final appBar = dashboardScaffold.appBar! as AppBar;
    expect(dashboardScaffold.drawer, isA<ProjectMenuDrawer>());
    expect(appBar.automaticallyImplyLeading, isTrue);
  });
}

Future<void> _pumpDashboard(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final database = Database.forTesting(
    DatabaseConnection(NativeDatabase.memory()),
  );
  addTearDown(database.close);
  const projectUuid = 'project-dashboard';
  await database
      .into(database.project)
      .insert(
        const ProjectCompanion(
          uuid: Value(projectUuid),
          name: Value('Dashboard project'),
        ),
      );
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(database)],
  );
  addTearDown(container.dispose);
  container.read(projectUuidProvider.notifier).updateProjectUuid(projectUuid);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Dashboard()),
    ),
  );
}
