import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:nahpu/services/database/database.dart';

/// An in-memory database with two projects of data table records.
///
/// Project p1 has three specimens (one mammal with measurements, one bird,
/// one with no taxon), a part, two parasites (one identified, one without
/// an ID or taxon), one site with a locality, one event with an environment
/// row, and two narratives. Project p2 has one specimen with a parasite
/// that must never show up in p1's pages.
Future<Database> seededDataTableDb() async {
  final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  Future<void> run(String sql, List<Object?> values) =>
      db.customStatement(sql, values);

  await run('INSERT INTO project (uuid, name) VALUES (?, ?)', ['p1', 'One']);
  await run('INSERT INTO project (uuid, name) VALUES (?, ?)', ['p2', 'Two']);
  for (final (uuid, name, role, next) in [
    ('ana', 'Ana Vale', 'Cataloger', 30),
    ('ben', 'Ben Oru', 'Cataloger', 5),
    ('cara', 'Cara Lim', 'Preparator only', null),
  ]) {
    await run(
      'INSERT INTO personnel (uuid, name, role, currentFieldNumber) '
      'VALUES (?, ?, ?, ?)',
      [uuid, name, role, next],
    );
    await run(
      'INSERT INTO personnelList (projectUuid, personnelUuid) VALUES (?, ?)',
      ['p1', uuid],
    );
  }
  await run(
    'INSERT INTO taxonomy (id, taxonOrder, taxonFamily, genus, '
    'specificEpithet) VALUES (?, ?, ?, ?, ?)',
    [1, 'Rodentia', 'Muridae', 'Rattus', 'tiomanicus'],
  );
  await run(
    'INSERT INTO taxonomy (id, genus, specificEpithet) VALUES (?, ?, ?)',
    [2, 'Pycnonotus', 'goiavier'],
  );
  await run(
    'INSERT INTO geography (id, country, stateProvince, locality, matchKey) '
    'VALUES (?, ?, ?, ?, ?)',
    [1, 'Indonesia', 'Aceh', 'Camp 1', 'shared-key'],
  );
  await run(
    'INSERT INTO site (id, siteID, projectUuid, geographyId) '
    'VALUES (?, ?, ?, ?)',
    [1, 'BK-1', 'p1', 1],
  );
  // A second site pointing at the same locality row.
  await run(
    'INSERT INTO site (id, siteID, projectUuid, geographyId) '
    'VALUES (?, ?, ?, ?)',
    [2, 'BK-2', 'p1', 1],
  );
  await run(
    'INSERT INTO collEvent (id, projectUuid, siteID, startDate) '
    'VALUES (?, ?, ?, ?)',
    [1, 'p1', 1, '2026-03-14'],
  );
  await run('INSERT INTO environment (eventID, lowestDayTempC) VALUES (?, ?)', [
    1,
    21.5,
  ]);
  await run(
    'INSERT INTO specimen (uuid, projectUuid, speciesID, taxonGroup, '
    'catalogerID, fieldNumber, condition, prepDate, collEventID) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    ['s1', 'p1', 1, 'General Mammals', 'ana', 10, 'Good', '2026-03-15', 1],
  );
  await run(
    'INSERT INTO specimen (uuid, projectUuid, speciesID, taxonGroup, '
    'catalogerID, fieldNumber, condition, prepDate) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    ['s2', 'p1', 2, 'Birds', 'ana', 9, '50%_off', '2026-03-20'],
  );
  await run(
    'INSERT INTO specimen (uuid, projectUuid, taxonGroup, fieldNumber) '
    'VALUES (?, ?, ?, ?)',
    ['s3', 'p1', 'General Mammals', null],
  );
  await run(
    'INSERT INTO specimen (uuid, projectUuid, taxonGroup, condition) '
    'VALUES (?, ?, ?, ?)',
    ['other', 'p2', 'General Mammals', 'Good'],
  );
  await run(
    'INSERT INTO mammalAttribute (specimenUuid, weight, remark, sex, '
    'testisLength) VALUES (?, ?, ?, ?, ?)',
    ['s1', 42.0, 'adult', 0, 12.0],
  );
  await run(
    'INSERT INTO specimenPart (id, specimenUuid, tissueID, type) '
    'VALUES (?, ?, ?, ?)',
    [1, 's1', 'T-1', 'Liver'],
  );
  await run(
    'INSERT INTO taxonomy (id, taxonRank, genus, specificEpithet) '
    'VALUES (?, ?, ?, ?)',
    [3, 'species', 'Hymenolepis', 'diminuta'],
  );
  for (final (id, specimen, uuid, parasiteId, species, identifier, count) in [
    (1, 's2', 'pu-1', 'P-1', 3, 'ben', 3),
    (2, 's1', 'pu-2', null, null, null, 1),
    (3, 'other', 'pu-3', 'P-9', null, null, 2),
  ]) {
    await run(
      'INSERT INTO parasite (id, specimenUuid, parasiteUuid, parasiteID, '
      'speciesID, determinerID, count, associationStatus, category) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        specimen,
        uuid,
        parasiteId,
        species,
        identifier,
        count,
        1,
        'Cestode',
      ],
    );
  }
  await run(
    'INSERT INTO narrative (id, projectUuid, date, siteID, narrative) '
    'VALUES (?, ?, ?, ?, ?)',
    [1, 'p1', '2026-03-14', 1, 'Rain all night'],
  );
  await run(
    'INSERT INTO narrative (id, projectUuid, date, narrative) '
    'VALUES (?, ?, ?, ?)',
    [2, 'p1', '2026-03-16', 'Moved camp'],
  );
  return db;
}
