import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';

void main() {
  late Database database;
  late WidgetRef widgetRef;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('creates project and new Cataloger in one setup operation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) {
              widgetRef = ref;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await ProjectServices(ref: widgetRef).createProjectSetup(
      project: const ProjectCompanion(
        uuid: Value('project-uuid'),
        name: Value('Field Project'),
        accession: Value('ACC-1'),
        catalogNumberPrefix: Value('FP-'),
        currentCatalogNumber: Value(10),
      ),
      newCataloger: const PersonnelCompanion(
        uuid: Value('cataloger-uuid'),
        name: Value('Field Cataloger'),
        initial: Value('FC'),
        role: Value('Cataloger'),
        currentFieldNumber: Value(50),
        isRegisterField: Value(true),
      ),
      catalogerUuid: 'cataloger-uuid',
    );

    final project = await ProjectQuery(
      database,
    ).getProjectByUuid('project-uuid');
    final cataloger = await PersonnelQuery(
      database,
    ).getPersonnelByUuid('cataloger-uuid');
    final links = await PersonnelQuery(
      database,
    ).getProjectPersonnelLinks('project-uuid');

    expect(project.accession, 'ACC-1');
    expect(project.catalogNumberPrefix, 'FP-');
    expect(project.currentCatalogNumber, 10);
    expect(cataloger.role, 'Cataloger');
    expect(cataloger.isRegisterField, isTrue);
    expect(links.single.personnelUuid, 'cataloger-uuid');
    expect(widgetRef.read(projectUuidProvider), 'project-uuid');
  });
}
