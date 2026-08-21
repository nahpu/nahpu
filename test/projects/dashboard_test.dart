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

  testWidgets('wide dashboard panels align content and actions', (
    tester,
  ) async {
    await _pumpDashboard(tester, const Size(1600, 1400), includeTaxon: true);

    final recordSecondary = tester.getRect(
      find.byKey(const ValueKey('record-stat-secondary')),
    );
    final registryActions = tester.getRect(
      find.byKey(const ValueKey('taxon-registry-actions')),
    );
    final recordActions = tester.getRect(
      find.byKey(const ValueKey('record-statistics-actions')),
    );

    expect(registryActions.bottom, closeTo(recordActions.bottom, 0.1));
    expect(recordActions.top - recordSecondary.bottom, closeTo(8, 0.1));
  });

  testWidgets('stacked dashboard panels keep content before actions', (
    tester,
  ) async {
    await _pumpDashboard(tester, const Size(599, 1400), includeTaxon: true);

    expect(tester.takeException(), isNull);
    expect(
      tester.getRect(find.byKey(const ValueKey('taxon-registry-actions'))).top,
      greaterThan(
        tester
            .getRect(find.byKey(const ValueKey('registry-stat-orders')))
            .bottom,
      ),
    );
    expect(
      tester
          .getRect(find.byKey(const ValueKey('record-statistics-actions')))
          .top,
      greaterThan(
        tester
            .getRect(find.byKey(const ValueKey('record-stat-secondary')))
            .bottom,
      ),
    );
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester,
  Size size, {
  bool includeTaxon = false,
}) async {
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
  if (includeTaxon) {
    await database
        .into(database.taxonomy)
        .insert(
          const TaxonomyCompanion(
            taxonRank: Value('species'),
            taxonOrder: Value('Chiroptera'),
            taxonFamily: Value('Vespertilionidae'),
            genus: Value('Myotis'),
            specificEpithet: Value('lucifugus'),
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
      child: const MaterialApp(home: Dashboard()),
    ),
  );
  await tester.pumpAndSettle();
}
