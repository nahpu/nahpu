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
      12: (m) => _Version13Migration(db).upgrade(m),
      13: (m) => _Version14Migration(db).upgrade(m),
      14: (m) => _Version15Migration(db).upgrade(m),
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

class _Version15Migration {
  const _Version15Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
    await migrator.addColumn(db.project, db.project.accession);
    await migrator.addColumn(db.project, db.project.catalogNumberPrefix);
    await migrator.addColumn(db.project, db.project.catalogNumberSuffix);
    await migrator.addColumn(db.taxonomy, db.taxonomy.kingdom);
    await migrator.addColumn(db.taxonomy, db.taxonomy.phylum);
    final detectionColumns = await _columnNames('parasiteDetection');
    if (detectionColumns.contains('parasiteRemark') &&
        !detectionColumns.contains('detectionRemark')) {
      await migrator.renameColumn(
        db.parasiteDetection,
        'parasiteRemark',
        db.parasiteDetection.detectionRemark,
      );
    }

    final parasiteColumns = await _columnNames('parasite');
    if (!parasiteColumns.contains('parasiteUuid')) {
      await db.customStatement(
        'ALTER TABLE parasite ADD COLUMN parasiteUuid TEXT NOT NULL',
      );
    }
    if (!parasiteColumns.contains('parasiteID')) {
      await migrator.addColumn(db.parasite, db.parasite.parasiteID);
    }
    if (!parasiteColumns.contains('identifierID')) {
      await migrator.addColumn(db.parasite, db.parasite.identifierID);
    }

    await migrator.createTable(db.eventMedia);
    await migrator.createTable(db.eventAssociatedData);
    await migrator.create(db.eventAssociatedDataSameProject);
    await migrator.createIndex(db.eventAssociatedDataDataIdx);
    await db.customStatement('''
      DELETE FROM parasiteDetection
      WHERE rowid NOT IN (
        SELECT max(rowid)
        FROM parasiteDetection
        GROUP BY specimenUuid
      )
    ''');
    await migrator.createIndex(db.parasiteDetectionSpecimenIdx);
    await migrator.createIndex(db.parasiteSpecimenIdx);
    await migrator.createIndex(db.parasiteUuidIdx);

    await _backfillTaxonomy();
    await _validate();
  }

  Future<void> _backfillTaxonomy() async {
    await db.customStatement('''
      UPDATE taxonomy
      SET kingdom = 'Animalia'
      WHERE kingdom IS NULL OR trim(kingdom) = ''
    ''');
    await db.customStatement('''
      UPDATE taxonomy
      SET phylum = CASE lower(coalesce(taxonClass, ''))
        WHEN 'insecta' THEN 'Arthropoda'
        WHEN 'arachnida' THEN 'Arthropoda'
        WHEN 'chilopoda' THEN 'Arthropoda'
        WHEN 'diplopoda' THEN 'Arthropoda'
        WHEN 'gastropoda' THEN 'Mollusca'
        WHEN 'bivalvia' THEN 'Mollusca'
        WHEN 'cephalopoda' THEN 'Mollusca'
        ELSE 'Chordata'
      END
      WHERE phylum IS NULL OR trim(phylum) = ''
    ''');
    await db.customStatement('''
      UPDATE taxonomy
      SET taxonRank = CASE
        WHEN coalesce(trim(subspecificEpithet), '') != '' THEN 'subspecies'
        WHEN coalesce(trim(specificEpithet), '') != '' THEN 'species'
        WHEN coalesce(trim(genus), '') != '' THEN 'genus'
        WHEN coalesce(trim(taxonFamily), '') != '' THEN 'family'
        WHEN coalesce(trim(taxonOrder), '') != '' THEN 'order'
        ELSE 'class'
      END
      WHERE taxonRank IS NULL OR trim(taxonRank) = ''
    ''');
  }

  Future<Set<String>> _columnNames(String table) async {
    final columns = await db
        .customSelect('PRAGMA table_info($table)', readsFrom: const {})
        .get();
    return columns.map((row) => row.read<String>('name')).toSet();
  }

  Future<void> _validate() async {
    for (final table in const ['eventMedia', 'eventAssociatedData']) {
      await db._requireTable(table);
    }
    final parasiteColumns = await db
        .customSelect('PRAGMA table_info(parasite)', readsFrom: const {})
        .get();
    final parasiteColumnNames = parasiteColumns
        .map((row) => row.read<String>('name'))
        .toSet();
    if (!parasiteColumnNames.containsAll({
      'parasiteID',
      'parasiteUuid',
      'identifierID',
    })) {
      throw StateError('Database migration did not add parasite identifiers.');
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
      throw StateError('Database integrity check failed after v15 migration.');
    }
  }
}

class _Version14Migration {
  const _Version14Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
    await migrator.renameColumn(
      db.birdAttribute,
      'footColor',
      db.birdAttribute.toeColor,
    );
    await migrator.renameColumn(
      db.birdAttribute,
      'footHex',
      db.birdAttribute.toeHex,
    );
    await migrator.addColumn(db.birdAttribute, db.birdAttribute.maxillaColor);
    await migrator.addColumn(db.birdAttribute, db.birdAttribute.maxillaHex);
    await migrator.addColumn(db.birdAttribute, db.birdAttribute.mandibleColor);
    await migrator.addColumn(db.birdAttribute, db.birdAttribute.mandibleHex);
    await db.customStatement('''
      UPDATE specimen
      SET condition = 'Freshly euthanized'
      WHERE condition = 'Freshly Euthanized'
    ''');
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

    await _createPaleontologySite();
    await migrator.createTable(db.arthropodAttribute);
    await migrator.createTable(db.fossilAttribute);
    await migrator.createTable(db.parasiteDetection);
    await migrator.createTable(db.parasite);
    await migrator.createTable(db.customFieldDefinition);
    await _createCustomFieldValue();
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

  Future<void> _createPaleontologySite() {
    return db.customStatement('''
      CREATE TABLE paleontologySite (
        siteID INT,
        formation TEXT,
        geologicEra INT,
        geologicPeriod INT,
        geologicSeries INT,
        geologicEpoch INT,
        narrowerGeologicStage TEXT,
        broaderGeologicStage TEXT,
        biozone TEXT,
        rockType TEXT,
        depositionalEnvironmentType INT,
        depositionalContinent TEXT,
        depositionalMarine TEXT,
        standardPreservationType TEXT,
        stratigraphyRemark TEXT,
        stratigraphicSource TEXT,
        sedimentologyRemark TEXT,
        FOREIGN KEY(siteID) REFERENCES site(id)
      )
    ''');
  }

  Future<void> _createCustomFieldValue() {
    return db.customStatement('''
      CREATE TABLE customFieldValue (
        id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT,
        fieldDefinitionId INT,
        projectUuid TEXT,
        value TEXT,
        FOREIGN KEY(fieldDefinitionId) REFERENCES customFieldDefinition(id),
        FOREIGN KEY(projectUuid) REFERENCES project(uuid)
      )
    ''');
  }
}

class _Version13Migration {
  const _Version13Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
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
    await _validateLegacySpecimenLinks();

    await migrator.alterTable(
      TableMigration(
        db.associatedData,
        columnTransformer: {
          db.associatedData.uri: const CustomExpression<String>('url'),
        },
      ),
    );
    await db._renameTableIfPresent('paleontologySite', 'fossilSite');
    await migrator.addColumn(db.media, db.media.uri);
    await migrator.addColumn(db.customFieldValue, db.customFieldValue.unit);

    await _validate();
  }

  Future<void> _validateLegacySpecimenLinks() async {
    final missingLinks = await db.customSelect('''
      SELECT COUNT(*) AS count
      FROM associatedData
      LEFT JOIN specimen
        ON specimen.uuid = associatedData.specimenUuid
       AND specimen.projectUuid = associatedData.projectUuid
      LEFT JOIN specimenAssociatedData AS link
        ON link.specimenUuid = associatedData.specimenUuid
       AND link.associatedDataId = associatedData.primaryId
      WHERE associatedData.specimenUuid IS NOT NULL
        AND (
          specimen.uuid IS NULL
          OR link.associatedDataId IS NULL
        )
    ''', readsFrom: const {}).getSingle();
    if (missingLinks.read<int>('count') != 0) {
      throw StateError(
        'Database migration cannot preserve a legacy specimen association.',
      );
    }
  }

  Future<void> _validate() async {
    await db._requireTable('fossilSite');
    if (await db._tableExists('paleontologySite')) {
      throw StateError('Database migration retained paleontologySite.');
    }

    final columns = await db
        .customSelect('PRAGMA table_info(associatedData)', readsFrom: const {})
        .get();
    final names = columns.map((row) => row.read<String>('name')).toSet();
    if (names.contains('specimenUuid') ||
        names.contains('url') ||
        !names.contains('uri')) {
      throw StateError('Database migration retained legacy associated data.');
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
      throw StateError('Database integrity check failed after v13 migration.');
    }
  }
}
