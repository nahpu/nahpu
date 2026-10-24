import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

/// IDs of the records [seedNetworkStatistics] inserts.
class NetworkFixture {
  const NetworkFixture({
    required this.myotis,
    required this.eptesicus,
    required this.firstSite,
    required this.secondSite,
    required this.siteMedia,
    required this.specimenMedia,
  });

  final int myotis;
  final int eptesicus;
  final int firstSite;
  final int secondSite;
  final int siteMedia;
  final int specimenMedia;
}

/// Seeds two projects for the statistics network.
///
/// Project A has five specimens: three on site HHA-1 (two Myotis and one
/// Eptesicus, collected by Ana Lee) and two on HHA-2 (one of each, collected
/// by Bo Smith). A site photo of HHA-1 and a specimen photo of the first
/// specimen document them. Project B has one Myotis collected by Ana Lee.
Future<NetworkFixture> seedNetworkStatistics(Database db) async {
  await db.batch((batch) {
    batch.insertAll(db.project, const [
      ProjectCompanion(uuid: Value('project-a'), name: Value('Project A')),
      ProjectCompanion(uuid: Value('project-b'), name: Value('Project B')),
    ]);
    batch.insertAll(db.personnel, const [
      PersonnelCompanion(
        uuid: Value('ana'),
        name: Value('Ana Lee'),
        initial: Value('AL'),
      ),
      PersonnelCompanion(
        uuid: Value('bo'),
        name: Value('Bo Smith'),
        initial: Value('BS'),
      ),
    ]);
  });
  final myotis = await db
      .into(db.taxonomy)
      .insert(
        const TaxonomyCompanion(
          genus: Value('Myotis'),
          specificEpithet: Value('lucifugus'),
        ),
      );
  final eptesicus = await db
      .into(db.taxonomy)
      .insert(
        const TaxonomyCompanion(
          genus: Value('Eptesicus'),
          specificEpithet: Value('fuscus'),
        ),
      );
  Future<int> site(String project, String id) => db
      .into(db.site)
      .insert(SiteCompanion(projectUuid: Value(project), siteID: Value(id)));
  final firstSite = await site('project-a', 'HHA-1');
  final secondSite = await site('project-a', 'HHA-2');
  final otherSite = await site('project-b', 'B-1');
  Future<int> event(String project, int siteId, String date) => db
      .into(db.collEvent)
      .insert(
        CollEventCompanion(
          projectUuid: Value(project),
          siteID: Value(siteId),
          startDate: Value(date),
        ),
      );
  final firstEvent = await event('project-a', firstSite, '2024-01-01');
  final secondEvent = await event('project-a', firstSite, '2024-01-02');
  final thirdEvent = await event('project-a', secondSite, '2024-02-01');
  final otherEvent = await event('project-b', otherSite, '2024-03-01');
  Future<int> collector(int eventId, String personnel) => db
      .into(db.collPersonnel)
      .insert(
        CollPersonnelCompanion(
          eventID: Value(eventId),
          personnelId: Value(personnel),
        ),
      );
  final anaFirst = await collector(firstEvent, 'ana');
  final anaSecond = await collector(secondEvent, 'ana');
  final boThird = await collector(thirdEvent, 'bo');
  final anaOther = await collector(otherEvent, 'ana');

  SpecimenCompanion specimen(
    String uuid,
    String project,
    int taxon,
    int eventId,
    int collectorId,
    int fieldNumber,
  ) => SpecimenCompanion(
    uuid: Value(uuid),
    projectUuid: Value(project),
    speciesID: Value(taxon),
    collEventID: Value(eventId),
    collPersonnelID: Value(collectorId),
    catalogerID: const Value('ana'),
    fieldNumber: Value(fieldNumber),
  );
  await db.batch((batch) {
    batch.insertAll(db.specimen, [
      specimen('sp1', 'project-a', myotis, firstEvent, anaFirst, 1),
      specimen('sp2', 'project-a', myotis, firstEvent, anaFirst, 2),
      specimen('sp3', 'project-a', eptesicus, secondEvent, anaSecond, 3),
      specimen('sp4', 'project-a', myotis, thirdEvent, boThird, 4),
      specimen('sp5', 'project-a', eptesicus, thirdEvent, boThird, 5),
      specimen('sp6', 'project-b', myotis, otherEvent, anaOther, 6),
    ]);
  });
  final siteMedia = await db
      .into(db.media)
      .insert(
        const MediaCompanion(
          projectUuid: Value('project-a'),
          caption: Value('Site photo'),
        ),
      );
  final specimenMedia = await db
      .into(db.media)
      .insert(
        const MediaCompanion(
          projectUuid: Value('project-a'),
          caption: Value('Specimen photo'),
        ),
      );
  await db
      .into(db.siteMedia)
      .insert(
        SiteMediaCompanion(siteId: Value(firstSite), mediaId: Value(siteMedia)),
      );
  await db
      .into(db.specimenMedia)
      .insert(
        SpecimenMediaCompanion(
          specimenUuid: const Value('sp1'),
          mediaId: Value(specimenMedia),
        ),
      );
  return NetworkFixture(
    myotis: myotis,
    eptesicus: eptesicus,
    firstSite: firstSite,
    secondSite: secondSite,
    siteMedia: siteMedia,
    specimenMedia: specimenMedia,
  );
}
