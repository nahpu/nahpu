import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/dashboard.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';

void main() {
  testWidgets('project dashboard has no create speed dial', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1400);
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

    final dashboardScaffold = tester.widget<Scaffold>(
      find.byType(Scaffold).first,
    );
    expect(dashboardScaffold.floatingActionButton, isNull);
  });
}
