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
      15: (m) => _Version16Migration(db).upgrade(m),
      16: (m) => _Version17Migration(db).upgrade(m),
      17: (m) => _Version18Migration(db).upgrade(m),
      18: (m) => _Version19Migration(db).upgrade(m),
      19: (m) => _Version20Migration(db).upgrade(m),
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

class _Version20Migration {
  const _Version20Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
    for (final name in const [
      'custom_field_value_validate_insert',
      'custom_field_value_validate_update',
    ]) {
      await db.customStatement('DROP TRIGGER IF EXISTS $name');
    }
    for (final name in const [
      'custom_field_site_value_idx',
      'custom_field_specimen_value_idx',
      'custom_field_part_value_idx',
      'custom_field_parasite_value_idx',
    ]) {
      await db.customStatement('DROP INDEX IF EXISTS $name');
    }

    await db.customStatement(
      'ALTER TABLE customFieldValue RENAME TO customFieldValueV19',
    );
    await migrator.createTable(db.customFieldValue);
    await db.customStatement('''
      INSERT INTO customFieldValue (
        id,
        fieldDefinitionId,
        projectUuid,
        value,
        unit,
        siteId,
        specimenUuid,
        specimenPartId,
        parasiteId,
        isLegacy
      )
      SELECT
        id,
        fieldDefinitionId,
        projectUuid,
        value,
        unit,
        siteId,
        specimenUuid,
        specimenPartId,
        parasiteId,
        isLegacy
      FROM customFieldValueV19
    ''');
    await db.customStatement('DROP TABLE customFieldValueV19');

    for (final statement in const [
      'CREATE UNIQUE INDEX custom_field_event_value_idx '
          'ON customFieldValue(fieldDefinitionId, eventId) '
          'WHERE eventId IS NOT NULL',
      'CREATE UNIQUE INDEX custom_field_site_value_idx '
          'ON customFieldValue(fieldDefinitionId, siteId) '
          'WHERE siteId IS NOT NULL',
      'CREATE UNIQUE INDEX custom_field_specimen_value_idx '
          'ON customFieldValue(fieldDefinitionId, specimenUuid) '
          'WHERE specimenUuid IS NOT NULL',
      'CREATE UNIQUE INDEX custom_field_part_value_idx '
          'ON customFieldValue(fieldDefinitionId, specimenPartId) '
          'WHERE specimenPartId IS NOT NULL',
      'CREATE UNIQUE INDEX custom_field_parasite_value_idx '
          'ON customFieldValue(fieldDefinitionId, parasiteId) '
          'WHERE parasiteId IS NOT NULL',
    ]) {
      await db.customStatement(statement);
    }
    await migrator.create(db.customFieldValueValidateInsert);
    await migrator.create(db.customFieldValueValidateUpdate);
    await _validate();
  }

  Future<void> _validate() async {
    final columns = await db
        .customSelect(
          'PRAGMA table_info(customFieldValue)',
          readsFrom: const {},
        )
        .get();
    if (!columns.map((row) => row.read<String>('name')).contains('eventId')) {
      throw StateError(
        'Database migration did not add event custom-field ownership.',
      );
    }
    final violations = await db
        .customSelect('PRAGMA foreign_key_check', readsFrom: const {})
        .get();
    if (violations.isNotEmpty) {
      throw StateError('Database migration introduced foreign-key violations.');
    }
  }
}

class _Version19Migration {
  const _Version19Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
    await _migrateSite(migrator);
    await _migrateEnvironment();
    await _migrateMammalAttributes(migrator);
    await _migrateBirdAttributes(migrator);
    await _migrateHerpAttributes(migrator);
    await _migrateArthropodAttributes(migrator);
    await _migrateFossilAttributes(migrator);
    await _validate();
  }

  Future<void> _migrateSite(Migrator migrator) async {
    await db.customStatement('PRAGMA legacy_alter_table = ON');
    try {
      await db.customStatement('ALTER TABLE site RENAME TO siteV18');
      await migrator.createTable(db.site);
      await db.customStatement('''
        INSERT INTO site (
          id,
          siteID,
          projectUuid,
          leadStaffId,
          siteType,
          country,
          stateProvince,
          county,
          municipality,
          mediaID,
          locality,
          remark
        )
        SELECT
          id,
          siteID,
          projectUuid,
          leadStaffId,
          siteType,
          country,
          stateProvince,
          county,
          municipality,
          mediaID,
          locality,
          remark
        FROM siteV18
      ''');
      await migrator.createTable(db.siteAttribute);
      await db.customStatement('''
        INSERT INTO siteAttribute (
          siteID,
          habitatType,
          habitatCondition,
          habitatDescription,
          canopyCover
        )
        SELECT
          id,
          habitatType,
          habitatCondition,
          habitatDescription,
          NULL
        FROM siteV18
      ''');
      await db.customStatement('DROP TABLE siteV18');
      await db.customStatement(
        'CREATE INDEX IF NOT EXISTS site_project_idx ON site(projectUuid)',
      );
    } finally {
      await db.customStatement('PRAGMA legacy_alter_table = OFF');
    }
  }

  Future<void> _migrateEnvironment() async {
    if (await db._tableExists('weather')) {
      await db.customStatement('ALTER TABLE weather RENAME TO environment');
    } else {
      await db._requireTable('environment');
    }
    final columns = await _columnNames('environment');
    for (final definition in const [
      'cloudCover TEXT',
      'rainfallInMm REAL',
      'ambientTemperature REAL',
      'ambientHumidity REAL',
      'waterTemperature REAL',
      'pH REAL',
      'dissolvedOxygen REAL',
      'flowVelocity REAL',
    ]) {
      final name = definition.split(' ').first;
      if (!columns.contains(name)) {
        await db.customStatement(
          'ALTER TABLE environment ADD COLUMN $definition',
        );
      }
    }
  }

  Future<void> _migrateMammalAttributes(Migrator migrator) async {
    final columns = await _columnNames('mammalAttribute');
    final lifeStageExpression = columns.contains('age')
        ? '''CASE age
          WHEN 0 THEN 'Adult'
          WHEN 1 THEN 'Subadult'
          WHEN 2 THEN 'Juvenile'
          WHEN 3 THEN 'Unknown'
          ELSE NULL
        END'''
        : columns.contains('lifeStage')
        ? 'lifeStage'
        : 'NULL';
    await db.customStatement(
      'ALTER TABLE mammalAttribute RENAME TO mammalAttributeV18',
    );
    await migrator.createTable(db.mammalAttribute);
    await db.customStatement('''
      INSERT INTO mammalAttribute (
        specimenUuid,
        showBatFields,
        totalLength,
        tailLength,
        hindFootLength,
        earLength,
        forearm,
        tibia,
        showEchoFields,
        echolocation,
        frequencyMax,
        frequencyMin,
        frequencyAtMaxEnergy,
        duration,
        weight,
        weightUnit,
        accuracy,
        accuracySpecify,
        sex,
        lifeStage,
        testisPosition,
        testisLength,
        testisWidth,
        epididymisAppearance,
        reproductiveStage,
        leftPlacentalScars,
        rightPlacentalScars,
        mammaeCondition,
        mammaeInguinalCount,
        mammaeAxillaryCount,
        mammaeAbdominalCount,
        vaginaOpening,
        pubicSymphysis,
        embryoLeftCount,
        embryoRightCount,
        embryoCR,
        remark
      )
      SELECT
        specimenUuid,
        showBatFields,
        totalLength,
        tailLength,
        hindFootLength,
        earLength,
        forearm,
        tibia,
        showEchoFields,
        echolocation,
        frequencyMax,
        frequencyMin,
        frequencyAtMaxEnergy,
        duration,
        weight,
        weightUnit,
        accuracy,
        accuracySpecify,
        sex,
        $lifeStageExpression,
        testisPosition,
        testisLength,
        testisWidth,
        epididymisAppearance,
        reproductiveStage,
        leftPlacentalScars,
        rightPlacentalScars,
        mammaeCondition,
        mammaeInguinalCount,
        mammaeAxillaryCount,
        mammaeAbdominalCount,
        vaginaOpening,
        pubicSymphysis,
        embryoLeftCount,
        embryoRightCount,
        embryoCR,
        remark
      FROM mammalAttributeV18
    ''');
    await db.customStatement('DROP TABLE mammalAttributeV18');
  }

  Future<void> _migrateBirdAttributes(Migrator migrator) async {
    if (!(await _columnNames('birdAttribute')).contains('lifeStage')) {
      await migrator.addColumn(db.birdAttribute, db.birdAttribute.lifeStage);
    }
  }

  Future<void> _migrateHerpAttributes(Migrator migrator) async {
    final columns = await _columnNames('herpAttribute');
    final lifeStageExpression = columns.contains('age')
        ? '''CASE age
          WHEN 0 THEN 'Adult'
          WHEN 1 THEN 'Juvenile'
          WHEN 2 THEN 'Neonate'
          WHEN 3 THEN 'Metamorph'
          WHEN 4 THEN 'Unknown'
          ELSE NULL
        END'''
        : columns.contains('lifeStage')
        ? 'lifeStage'
        : 'NULL';
    await db.customStatement(
      'ALTER TABLE herpAttribute RENAME TO herpAttributeV18',
    );
    await migrator.createTable(db.herpAttribute);
    await db.customStatement('''
      INSERT INTO herpAttribute (
        specimenUuid,
        sex,
        lifeStage,
        weight,
        weightUnit,
        svl,
        remark
      )
      SELECT
        specimenUuid,
        sex,
        $lifeStageExpression,
        weight,
        weightUnit,
        svl,
        remark
      FROM herpAttributeV18
    ''');
    await db.customStatement('DROP TABLE herpAttributeV18');
  }

  Future<void> _migrateArthropodAttributes(Migrator migrator) async {
    final columns = await _columnNames('arthropodAttribute');
    final lifeStageExpression = columns.contains('lifeStage')
        ? 'lifeStage'
        : 'NULL';
    final casteExpression = columns.contains('caste') ? 'caste' : 'NULL';
    await db.customStatement(
      'ALTER TABLE arthropodAttribute RENAME TO arthropodAttributeV18',
    );
    await migrator.createTable(db.arthropodAttribute);
    await db.customStatement('''
      INSERT INTO arthropodAttribute (
        specimenUuid,
        headWidth,
        bodyLength,
        wingspanUpper,
        wingspanLower,
        sex,
        hostOrganism,
        hostPart,
        lifeStage,
        caste,
        remark
      )
      SELECT
        specimenUuid,
        headWidth,
        bodyLength,
        wingspanUpper,
        wingspanLower,
        sex,
        hostOrganism,
        hostPart,
        $lifeStageExpression,
        $casteExpression,
        remark
      FROM arthropodAttributeV18
    ''');
    await db.customStatement('DROP TABLE arthropodAttributeV18');
  }

  Future<void> _migrateFossilAttributes(Migrator migrator) async {
    final columns = await _columnNames('fossilAttribute');
    for (final column in [
      db.fossilAttribute.sex,
      db.fossilAttribute.ontogeneticStage,
      db.fossilAttribute.weight,
      db.fossilAttribute.weightUnit,
      db.fossilAttribute.remark,
    ]) {
      if (!columns.contains(column.name)) {
        await migrator.addColumn(db.fossilAttribute, column);
      }
    }
  }

  Future<Set<String>> _columnNames(String table) async {
    final columns = await db
        .customSelect('PRAGMA table_info($table)', readsFrom: const {})
        .get();
    return columns.map((row) => row.read<String>('name')).toSet();
  }

  Future<void> _validate() async {
    for (final table in const [
      'siteAttribute',
      'environment',
      'mammalAttribute',
      'birdAttribute',
      'herpAttribute',
      'arthropodAttribute',
      'fossilAttribute',
    ]) {
      await db._requireTable(table);
    }
    if (await db._tableExists('weather')) {
      throw StateError('Database migration retained the weather table.');
    }

    final expectedColumns = {
      'site': {'islandGroup'},
      'siteAttribute': {
        'siteID',
        'habitatType',
        'habitatCondition',
        'habitatDescription',
        'canopyCover',
      },
      'environment': {
        'cloudCover',
        'rainfallInMm',
        'ambientTemperature',
        'ambientHumidity',
        'waterTemperature',
        'pH',
        'dissolvedOxygen',
        'flowVelocity',
      },
      'mammalAttribute': {'lifeStage'},
      'birdAttribute': {'lifeStage'},
      'herpAttribute': {'lifeStage'},
      'arthropodAttribute': {'lifeStage', 'caste'},
      'fossilAttribute': {
        'sex',
        'ontogeneticStage',
        'weight',
        'weightUnit',
        'remark',
      },
    };
    for (final entry in expectedColumns.entries) {
      final columns = await db
          .customSelect('PRAGMA table_info(${entry.key})', readsFrom: const {})
          .get();
      final names = columns.map((row) => row.read<String>('name')).toSet();
      if (!names.containsAll(entry.value)) {
        throw StateError(
          'Database migration did not add the v19 columns to ${entry.key}.',
        );
      }
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
      throw StateError('Database integrity check failed after v19 migration.');
    }
  }
}

class _Version18Migration {
  const _Version18Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
    await db.customStatement(
      'ALTER TABLE customFieldValue RENAME TO customFieldValueV17',
    );
    await db.customStatement(
      'ALTER TABLE customFieldDefinition RENAME TO customFieldDefinitionV17',
    );
    await migrator.createTable(db.customFieldDefinition);
    await migrator.createTable(db.customFieldValue);

    final definitions = await db
        .customSelect(
          'SELECT * FROM customFieldDefinitionV17 ORDER BY id',
          readsFrom: const {},
        )
        .get();
    for (final row in definitions) {
      final id = row.read<int>('id');
      final hasLegacyValues = await db
          .customSelect(
            'SELECT 1 FROM customFieldValueV17 '
            'WHERE fieldDefinitionId = ? LIMIT 1',
            variables: [Variable.withInt(id)],
            readsFrom: const {},
          )
          .getSingleOrNull();
      final rawType = row.readNullable<String>('type') ?? 'text';
      final rawSection =
          row.readNullable<String>('uiSection') ?? 'specimenAttribute';
      await db
          .into(db.customFieldDefinition)
          .insert(
            CustomFieldDefinitionCompanion.insert(
              id: Value(id),
              uuid: const Uuid().v4(),
              name: row.readNullable<String>('name')?.trim().isNotEmpty == true
                  ? row.read<String>('name').trim()
                  : 'Legacy custom field $id',
              type: switch (rawType.split('.').last) {
                'numeric' => 'number',
                'boolean' => 'boolean',
                'dropdown' => 'dropdown',
                _ => 'text',
              },
              uiSection: switch (rawSection.split('.').last) {
                'siteHabitat' => 'siteAttribute',
                'siteAttribute' => 'siteAttribute',
                _ => 'specimenAttribute',
              },
              scope: 'global',
              options: Value(row.readNullable<String>('options')),
              isArchived: Value(hasLegacyValues != null ? 1 : 0),
              createdAt: Value(row.readNullable<String>('createdAt')),
              updatedAt: Value(row.readNullable<String>('updatedAt')),
            ),
          );
    }

    final values = await db
        .customSelect(
          'SELECT * FROM customFieldValueV17 ORDER BY id',
          readsFrom: const {},
        )
        .get();
    for (final row in values) {
      await db
          .into(db.customFieldValue)
          .insert(
            CustomFieldValueCompanion.insert(
              id: Value(row.read<int>('id')),
              fieldDefinitionId: row.read<int>('fieldDefinitionId'),
              projectUuid: Value(row.readNullable<String>('projectUuid')),
              value: row.readNullable<String>('value') ?? '',
              unit: Value(row.readNullable<String>('unit')),
              isLegacy: const Value(1),
            ),
          );
    }

    await db.customStatement('DROP TABLE customFieldValueV17');
    await db.customStatement('DROP TABLE customFieldDefinitionV17');
    await _createIndexesAndTriggers(migrator);
    await _validate();
  }

  Future<void> _createIndexesAndTriggers(Migrator migrator) async {
    for (final statement in const [
      'CREATE UNIQUE INDEX custom_field_site_value_idx '
          'ON customFieldValue(fieldDefinitionId, siteId) '
          'WHERE siteId IS NOT NULL',
      'CREATE UNIQUE INDEX custom_field_specimen_value_idx '
          'ON customFieldValue(fieldDefinitionId, specimenUuid) '
          'WHERE specimenUuid IS NOT NULL',
      'CREATE UNIQUE INDEX custom_field_part_value_idx '
          'ON customFieldValue(fieldDefinitionId, specimenPartId) '
          'WHERE specimenPartId IS NOT NULL',
      'CREATE UNIQUE INDEX custom_field_parasite_value_idx '
          'ON customFieldValue(fieldDefinitionId, parasiteId) '
          'WHERE parasiteId IS NOT NULL',
      'CREATE UNIQUE INDEX custom_field_template_target_idx '
          "ON customFieldDefinition(sourceTemplateUuid, scope, ifnull(projectUuid, '')) "
          'WHERE sourceTemplateUuid IS NOT NULL',
    ]) {
      await db.customStatement(statement);
    }

    // Use the canonical trigger entities so an upgrade matches a fresh v18
    // database exactly.
    await migrator.create(db.customFieldValueValidateInsert);
    await migrator.create(db.customFieldValueValidateUpdate);
  }

  Future<void> _validate() async {
    final definitionColumns = await _columnNames('customFieldDefinition');
    final valueColumns = await _columnNames('customFieldValue');
    if (!definitionColumns.containsAll({
          'uuid',
          'projectUuid',
          'catalogFormat',
          'isArchived',
          'dwcField',
        }) ||
        !valueColumns.containsAll({
          'siteId',
          'specimenUuid',
          'specimenPartId',
          'parasiteId',
          'isLegacy',
        })) {
      throw StateError(
        'Database migration did not create the v18 custom fields.',
      );
    }
    final integrity = await db
        .customSelect('PRAGMA integrity_check', readsFrom: const {})
        .getSingle();
    if (integrity.data.values.single != 'ok') {
      throw StateError('Database integrity check failed after v18 migration.');
    }
  }

  Future<Set<String>> _columnNames(String table) async {
    final columns = await db
        .customSelect('PRAGMA table_info($table)', readsFrom: const {})
        .get();
    return columns.map((row) => row.read<String>('name')).toSet();
  }
}

class _Version17Migration {
  const _Version17Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
    final specimenColumns = await _columnNames('specimen');
    final hasIdentifier = specimenColumns.contains('identifierID');
    final hasDeterminer = specimenColumns.contains('determinerID');
    if (hasIdentifier == hasDeterminer) {
      throw StateError(
        'Expected exactly one of specimen.identifierID or determinerID.',
      );
    }
    if (hasIdentifier) {
      await migrator.renameColumn(
        db.specimen,
        'identifierID',
        db.specimen.determinerID,
      );
    }

    await _addColumnIfMissing(
      migrator,
      'specimen',
      'coordinateExtentMeters',
      db.specimen.coordinateExtentMeters,
    );
    await _addColumnIfMissing(
      migrator,
      'personnel',
      'orcid',
      db.personnel.orcid,
    );
    await _addColumnIfMissing(
      migrator,
      'coordinate',
      'verbatimLatitude',
      db.coordinate.verbatimLatitude,
    );
    await _addColumnIfMissing(
      migrator,
      'coordinate',
      'verbatimLongitude',
      db.coordinate.verbatimLongitude,
    );
    await _addColumnIfMissing(
      migrator,
      'coordinate',
      'verbatimCoordinates',
      db.coordinate.verbatimCoordinates,
    );
    await _addColumnIfMissing(
      migrator,
      'coordinate',
      'verbatimCoordinateSystem',
      db.coordinate.verbatimCoordinateSystem,
    );

    for (final entry in [
      (table: 'mammalAttribute', column: db.mammalAttribute.weightUnit),
      (table: 'birdAttribute', column: db.birdAttribute.weightUnit),
      (table: 'herpAttribute', column: db.herpAttribute.weightUnit),
    ]) {
      await _addColumnIfMissing(
        migrator,
        entry.table,
        'weightUnit',
        entry.column,
      );
      await db.customStatement(
        'UPDATE ${entry.table} SET weightUnit = ? '
        "WHERE weight IS NOT NULL AND (weightUnit IS NULL OR TRIM(weightUnit) = '')",
        ['g'],
      );
    }

    await _validate();
  }

  Future<void> _addColumnIfMissing(
    Migrator migrator,
    String table,
    String name,
    GeneratedColumn<Object> column,
  ) async {
    if (!(await _columnNames(table)).contains(name)) {
      await migrator.addColumn(
        db.allTables.firstWhere((t) => t.actualTableName == table),
        column,
      );
    }
  }

  Future<Set<String>> _columnNames(String table) async {
    final columns = await db
        .customSelect('PRAGMA table_info($table)', readsFrom: const {})
        .get();
    return columns.map((row) => row.read<String>('name')).toSet();
  }

  Future<void> _validate() async {
    final expectedColumns = {
      'specimen': {'coordinateExtentMeters', 'determinerID'},
      'personnel': {'orcid'},
      'coordinate': {
        'verbatimLatitude',
        'verbatimLongitude',
        'verbatimCoordinates',
        'verbatimCoordinateSystem',
      },
      'mammalAttribute': {'weightUnit'},
      'birdAttribute': {'weightUnit'},
      'herpAttribute': {'weightUnit'},
    };
    for (final entry in expectedColumns.entries) {
      if (!(await _columnNames(entry.key)).containsAll(entry.value)) {
        throw StateError(
          'Database migration did not add the v17 columns to ${entry.key}.',
        );
      }
    }
    if ((await _columnNames('specimen')).contains('identifierID')) {
      throw StateError('Database migration retained specimen.identifierID.');
    }

    final violations = await db
        .customSelect('PRAGMA foreign_key_check', readsFrom: const {})
        .get();
    if (violations.isNotEmpty) {
      throw StateError('Database migration introduced foreign-key violations.');
    }
    final integrity = await db
        .customSelect('PRAGMA integrity_check', readsFrom: const {})
        .getSingle();
    if (integrity.data.values.single != 'ok') {
      throw StateError('Database integrity check failed after v17 migration.');
    }
  }
}

class _Version16Migration {
  const _Version16Migration(this.db);

  final Database db;

  Future<void> upgrade(Migrator migrator) async {
    final projectColumns = await _columnNames('project');
    if (!projectColumns.contains('currentCatalogNumber')) {
      await migrator.addColumn(db.project, db.project.currentCatalogNumber);
    }

    final parasiteColumns = await _columnNames('parasite');
    if (!parasiteColumns.contains('storageLocation')) {
      await migrator.addColumn(db.parasite, db.parasite.storageLocation);
    }

    final specimenPartColumns = await _columnNames('specimenPart');
    if (!specimenPartColumns.contains('storageLocation')) {
      await migrator.addColumn(
        db.specimenPart,
        db.specimenPart.storageLocation,
      );
    }

    await _validate();
  }

  Future<Set<String>> _columnNames(String table) async {
    final columns = await db
        .customSelect('PRAGMA table_info($table)', readsFrom: const {})
        .get();
    return columns.map((row) => row.read<String>('name')).toSet();
  }

  Future<void> _validate() async {
    final expectedColumns = {
      'project': {'currentCatalogNumber'},
      'parasite': {'storageLocation'},
      'specimenPart': {'storageLocation'},
    };
    for (final entry in expectedColumns.entries) {
      final columns = await db
          .customSelect('PRAGMA table_info(${entry.key})', readsFrom: const {})
          .get();
      final names = columns.map((row) => row.read<String>('name')).toSet();
      if (!names.containsAll(entry.value)) {
        throw StateError(
          'Database migration did not add the v16 columns to ${entry.key}.',
        );
      }
    }

    final integrity = await db
        .customSelect('PRAGMA integrity_check', readsFrom: const {})
        .getSingle();
    if (integrity.data.values.single != 'ok') {
      throw StateError('Database integrity check failed after v16 migration.');
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
    await db.customStatement(
      'ALTER TABLE specimen ADD COLUMN identifierID TEXT '
      'REFERENCES personnel(uuid)',
    );
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
