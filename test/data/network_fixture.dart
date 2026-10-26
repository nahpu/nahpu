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
    required this.flea,
  });

  final int myotis;
  final int eptesicus;
  final int firstSite;
  final int secondSite;
  final int siteMedia;
  final int specimenMedia;

  /// Parasite taxon found on the first and fourth specimens.
  final int flea;
}

/// Seeds two projects for the statistics network.
///
/// Project A has five specimens: three on site HHA-1 (two Myotis and one
/// Eptesicus, collected by Ana Lee) and two on HHA-2 (one of each, collected
/// by Bo Smith). A site photo of HHA-1 and a specimen photo of the first
/// specimen document them. The first specimen keeps a liver and a skin, the
/// second a liver, and the fourth a skin. A flea was found on the first and
/// fourth specimens and an unidentified parasite on the second. Project B
/// has one Myotis collected by Ana Lee.
///
/// HHA-1 is in Indonesia, in forest, with one coordinate. The first
/// specimen (museum ID MUS-1, in good condition) is an adult male and the
/// second a female; the rest have no sex recorded. Both livers are in
/// ethanol and the fourth specimen's skin is dried. The flea is an
/// ectoparasite.
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
  final indonesia = await db
      .into(db.geography)
      .insert(
        const GeographyCompanion(
          country: Value('Indonesia'),
          stateProvince: Value('Sulawesi Selatan'),
          matchKey: Value('indonesia|sulawesi selatan'),
        ),
      );
  await (db.update(db.site)..where((t) => t.id.equals(firstSite))).write(
    SiteCompanion(siteType: const Value('Camp'), geographyId: Value(indonesia)),
  );
  await db
      .into(db.siteAttribute)
      .insert(
        SiteAttributeCompanion(
          siteID: Value(firstSite),
          habitatType: const Value('Forest'),
        ),
      );
  await db
      .into(db.coordinate)
      .insert(
        CoordinateCompanion(
          siteID: Value(firstSite),
          decimalLatitude: const Value(-5.25),
          decimalLongitude: const Value(119.5),
          elevationInMeter: const Value(120),
        ),
      );
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
    batch.insertAll(db.mammalAttribute, const [
      MammalAttributeCompanion(
        specimenUuid: Value('sp1'),
        sex: Value(0),
        lifeStage: Value('Adult'),
      ),
      MammalAttributeCompanion(specimenUuid: Value('sp2'), sex: Value(1)),
    ]);
  });
  await (db.update(db.specimen)..where((t) => t.uuid.equals('sp1'))).write(
    const SpecimenCompanion(museumID: Value('MUS-1'), condition: Value('Good')),
  );
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
  final flea = await db
      .into(db.taxonomy)
      .insert(
        const TaxonomyCompanion(
          genus: Value('Ctenophthalmus'),
          specificEpithet: Value('agyrtes'),
        ),
      );
  await db.batch((batch) {
    batch.insertAll(db.specimenPart, const [
      SpecimenPartCompanion(
        specimenUuid: Value('sp1'),
        type: Value('Liver'),
        treatment: Value('Ethanol'),
      ),
      SpecimenPartCompanion(specimenUuid: Value('sp1'), type: Value('Skin')),
      SpecimenPartCompanion(
        specimenUuid: Value('sp2'),
        type: Value('liver '),
        treatment: Value('ethanol'),
      ),
      SpecimenPartCompanion(
        specimenUuid: Value('sp4'),
        type: Value('Skin'),
        treatment: Value('Dried'),
      ),
    ]);
    batch.insertAll(db.parasite, [
      ParasiteCompanion(
        specimenUuid: const Value('sp1'),
        speciesID: Value(flea),
        parasiteUuid: const Value('pa1'),
        category: const Value('Ectoparasite'),
      ),
      ParasiteCompanion(
        specimenUuid: const Value('sp4'),
        speciesID: Value(flea),
        parasiteUuid: const Value('pa2'),
        category: const Value('ectoparasite '),
      ),
      const ParasiteCompanion(
        specimenUuid: Value('sp2'),
        parasiteUuid: Value('pa3'),
      ),
    ]);
  });
  return NetworkFixture(
    myotis: myotis,
    eptesicus: eptesicus,
    firstSite: firstSite,
    secondSite: secondSite,
    siteMedia: siteMedia,
    specimenMedia: specimenMedia,
    flea: flea,
  );
}
