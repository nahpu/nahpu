import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/sites/site_copy_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/sites.dart';

void main() {
  late Database database;
  late WidgetRef widgetRef;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> mount(WidgetTester tester) async {
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
    widgetRef
        .read(projectUuidProvider.notifier)
        .updateProjectUuid('target-project');
  }

  Future<void> seedProjects() async {
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
  }

  testWidgets('copies selected fields and coordinates atomically', (
    tester,
  ) async {
    await mount(tester);
    await seedProjects();

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
            locality: Value('North field'),
            remark: Value('Keep this note'),
          ),
        );
    await CoordinateQuery(database).createCoordinate(
      CoordinateCompanion(
        nameId: const Value('A'),
        decimalLatitude: const Value(45.1),
        decimalLongitude: const Value(-93.2),
        datum: const Value('WGS84'),
        siteID: Value(sourceId),
      ),
    );

    final result = await SiteCopyServices(ref: widgetRef).copy(
      SiteCopyRequest(
        targetSiteId: targetId,
        sourceProjectUuid: 'source-project',
        sourceSiteId: sourceId,
        fields: const {SiteCopyField.siteId, SiteCopyField.coordinates},
      ),
    );

    final target = await (database.select(
      database.site,
    )..where((row) => row.id.equals(targetId))).getSingle();
    final coordinates = await CoordinateQuery(
      database,
    ).getCoordinatesBySiteID(targetId);

    expect(result.fieldCount, 1);
    expect(result.coordinateCount, 1);
    expect(target.siteID, 'SOURCE-1');
    expect(target.country, isNull);
    expect(target.locality, isNull);
    expect(coordinates, hasLength(1));
    expect(coordinates.single.siteID, targetId);
    expect(coordinates.single.id, isNot(1));
    expect(coordinates.single.decimalLatitude, 45.1);
  });

  testWidgets('rejects a target that is no longer empty', (tester) async {
    await mount(tester);
    await seedProjects();
    final targetId = await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            projectUuid: Value('target-project'),
            siteID: Value('ALREADY-FILLED'),
          ),
        );
    final sourceId = await database
        .into(database.site)
        .insert(
          const SiteCompanion(
            projectUuid: Value('source-project'),
            siteID: Value('SOURCE'),
          ),
        );

    expect(
      () => SiteCopyServices(ref: widgetRef).copy(
        SiteCopyRequest(
          targetSiteId: targetId,
          sourceProjectUuid: 'source-project',
          sourceSiteId: sourceId,
          fields: const {SiteCopyField.siteId},
        ),
      ),
      throwsA(isA<SiteCopyException>()),
    );
  });

  testWidgets('leader copy links the existing person to the target project', (
    tester,
  ) async {
    await mount(tester);
    await seedProjects();
    await PersonnelQuery(database).createPersonnel(
      const PersonnelCompanion(
        uuid: Value('person-1'),
        name: Value('Field Leader'),
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
            leadStaffId: Value('person-1'),
          ),
        );

    await SiteCopyServices(ref: widgetRef).copy(
      SiteCopyRequest(
        targetSiteId: targetId,
        sourceProjectUuid: 'source-project',
        sourceSiteId: sourceId,
        fields: const {SiteCopyField.leadStaff},
      ),
    );

    final target = await (database.select(
      database.site,
    )..where((row) => row.id.equals(targetId))).getSingle();
    final links = await PersonnelQuery(
      database,
    ).getProjectPersonnelLinks('target-project');
    expect(target.leadStaffId, 'person-1');
    expect(links.map((link) => link.personnelUuid), contains('person-1'));
  });
}
