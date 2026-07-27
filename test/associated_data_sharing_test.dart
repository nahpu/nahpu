import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';

void main() {
  late Database db;
  late AssociatedDataQuery query;

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    query = AssociatedDataQuery(db);
    await db
        .into(db.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-a'),
            name: Value('Project A'),
          ),
        );
    await db
        .into(db.project)
        .insert(
          const ProjectCompanion(
            uuid: Value('project-b'),
            name: Value('Project B'),
          ),
        );
    await db
        .into(db.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen-a'),
            projectUuid: Value('project-a'),
          ),
        );
    await db
        .into(db.specimen)
        .insert(
          const SpecimenCompanion(
            uuid: Value('specimen-b'),
            projectUuid: Value('project-a'),
          ),
        );
  });

  tearDown(() => db.close());

  test('one project record can be shared by specimens and sites', () async {
    final siteId = await db
        .into(db.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
    final id = await query.createSpecimenDataAssociation(
      const AssociatedDataCompanion(
        specimenUuid: Value('specimen-a'),
        name: Value('Recording'),
      ),
    );

    await query.linkToSpecimen(id, 'specimen-b');
    await query.linkToSite(id, siteId);

    expect(await query.getAllAssociatedData('specimen-a'), hasLength(1));
    expect(await query.getAllAssociatedData('specimen-b'), hasLength(1));
    expect(await query.getAssociatedDataForSite(siteId), hasLength(1));
    expect(await query.getAssociatedDataForProject('project-a'), hasLength(1));
  });

  test('detaching a specimen preserves the shared project record', () async {
    final siteId = await db
        .into(db.site)
        .insert(const SiteCompanion(projectUuid: Value('project-a')));
    final id = await query.createSpecimenDataAssociation(
      const AssociatedDataCompanion(
        specimenUuid: Value('specimen-a'),
        name: Value('Recording'),
      ),
    );
    await query.linkToSpecimen(id, 'specimen-b');
    await query.linkToSite(id, siteId);

    await query.deleteAllAssociatedData('specimen-a');

    expect(await query.getAllAssociatedData('specimen-a'), isEmpty);
    expect(await query.getAllAssociatedData('specimen-b'), hasLength(1));
    expect(await query.getAssociatedDataForSite(siteId), hasLength(1));
    final data = await (db.select(
      db.associatedData,
    )..where((row) => row.primaryId.equals(id))).getSingle();
    expect(data.specimenUuid, isNull);
  });

  test('site links cannot cross project boundaries', () async {
    final siteId = await db
        .into(db.site)
        .insert(const SiteCompanion(projectUuid: Value('project-b')));
    final id = await query.createSpecimenDataAssociation(
      const AssociatedDataCompanion(specimenUuid: Value('specimen-a')),
    );

    await expectLater(query.linkToSite(id, siteId), throwsA(anything));
  });
}
