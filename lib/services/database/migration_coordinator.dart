part of 'database.dart';

typedef _MigrationStep = Future<void> Function(Migrator migrator);

/// Coordinates upgrades through the canonical v11 schema before applying
/// release-specific migrations.
class _MigrationCoordinator {
  const _MigrationCoordinator(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator, int from, int to) async {
    await db.customStatement('PRAGMA foreign_keys = OFF');

    var currentVersion = from;
    if (currentVersion < 11) {
      await _LegacyMigration(db).upgradeToV11(migrator, currentVersion);
      currentVersion = 11;
    }

    final releaseSteps = <int, _MigrationStep>{
      11: (m) => _Version12Migration(db).upgrade(m),
    };
    while (currentVersion < to) {
      final step = releaseSteps[currentVersion];
      if (step == null) {
        throw StateError(
          'No database migration from v$currentVersion to '
          'v${currentVersion + 1}.',
        );
      }
      await step(migrator);
      currentVersion++;
    }
  }
}

/// Preserves the historical migration order while keeping it out of the main
/// database upgrade callback.
class _LegacyMigration {
  const _LegacyMigration(this.db);

  final Database db;

  Future<void> upgradeToV11(Migrator migrator, int from) async {
    await db._renameSpecimenAttributeTables(from);

    final steps = <int, _MigrationStep>{
      1: (m) => m.addColumn(db.specimen, db.specimen.taxonGroup),
      2: db._migrateFromVersion2,
      3: (m) async {
        await db._migrateV3only(m);
        await db._migrateFromVersion3(m);
      },
      4: db._migrateFromVersion4,
      5: db._migrateFromVersion5,
      6: db._migrateFromVersion6,
      7: db._migrateFromVersion7,
      8: db._migrateFromVersion8,
      9: db._migrateFromVersion9,
      10: (_) => db._validateSpecimenAttributeTables(),
    };

    for (var version = from; version < 11; version++) {
      final step = steps[version];
      if (step == null) {
        throw StateError(
          'No legacy database migration from v$version to v${version + 1}.',
        );
      }
      await step(migrator);
    }
  }
}

class _Version12Migration {
  const _Version12Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
    await migrator.addColumn(db.taxonomy, db.taxonomy.taxonRank);
    await migrator.addColumn(db.taxonomy, db.taxonomy.subspecificEpithet);
    await migrator.addColumn(db.specimen, db.specimen.identifierID);
    await migrator.addColumn(db.specimenPart, db.specimenPart.storage);
    await migrator.addColumn(db.associatedData, db.associatedData.projectUuid);

    await migrator.createTable(db.paleontologySite);
    await migrator.createTable(db.arthropodAttribute);
    await migrator.createTable(db.fossilAttribute);
    await migrator.createTable(db.parasiteDetection);
    await migrator.createTable(db.parasite);
    await migrator.createTable(db.customFieldDefinition);
    await migrator.createTable(db.customFieldValue);
    await migrator.createTable(db.specimenAssociatedData);
    await migrator.createTable(db.siteAssociatedData);

    await db.customStatement('''
      UPDATE associatedData
      SET projectUuid = (
        SELECT specimen.projectUuid
        FROM specimen
        WHERE specimen.uuid = associatedData.specimenUuid
      )
      WHERE projectUuid IS NULL
        AND specimenUuid IS NOT NULL
        AND EXISTS (
          SELECT 1
          FROM specimen
          WHERE specimen.uuid = associatedData.specimenUuid
            AND specimen.projectUuid IS NOT NULL
        )
    ''');
    await db.customStatement('''
      INSERT OR IGNORE INTO specimenAssociatedData (
        specimenUuid,
        associatedDataId
      )
      SELECT associatedData.specimenUuid, associatedData.primaryId
      FROM associatedData
      INNER JOIN specimen
        ON specimen.uuid = associatedData.specimenUuid
       AND specimen.projectUuid = associatedData.projectUuid
      WHERE associatedData.specimenUuid IS NOT NULL
        AND associatedData.projectUuid IS NOT NULL
    ''');

    await migrator.create(db.specimenAssociatedDataSameProject);
    await migrator.create(db.siteAssociatedDataSameProject);
    await migrator.createIndex(db.associatedDataProjectIdx);
    await migrator.createIndex(db.specimenAssociatedDataDataIdx);
    await migrator.createIndex(db.siteAssociatedDataDataIdx);
    await _validate();
  }

  Future<void> _validate() async {
    for (final table in const [
      'paleontologySite',
      'arthropodAttribute',
      'fossilAttribute',
      'parasiteDetection',
      'parasite',
      'customFieldDefinition',
      'customFieldValue',
      'specimenAssociatedData',
      'siteAssociatedData',
    ]) {
      await db._requireTable(table);
    }

    final missingLinks = await db.customSelect('''
        SELECT COUNT(*) AS count
        FROM associatedData
        INNER JOIN specimen
          ON specimen.uuid = associatedData.specimenUuid
         AND specimen.projectUuid = associatedData.projectUuid
        LEFT JOIN specimenAssociatedData AS link
          ON link.specimenUuid = associatedData.specimenUuid
         AND link.associatedDataId = associatedData.primaryId
        WHERE associatedData.projectUuid IS NOT NULL
          AND link.associatedDataId IS NULL
      ''', readsFrom: const {}).getSingle();
    if (missingLinks.read<int>('count') != 0) {
      throw StateError('Database migration did not preserve specimen data.');
    }

    final violations = await db
        .customSelect('PRAGMA foreign_key_check', readsFrom: const {})
        .get();
    if (violations.isNotEmpty) {
      throw StateError(
        'Database migration introduced ${violations.length} foreign-key '
        'violation(s).',
      );
    }

    final integrity = await db
        .customSelect('PRAGMA integrity_check', readsFrom: const {})
        .getSingle();
    if (integrity.data.values.single != 'ok') {
      throw StateError('Database integrity check failed after v12 migration.');
    }
  }
}
