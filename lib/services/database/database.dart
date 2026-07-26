//! A module to handle the database connection and migration.
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/database/migration_utilities.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

/// The database schema version.
/// Steps to update the schema:
/// 1. Write the new schema in the [tables.drift] file.
/// 2. Write comments on the new schema changes at the top of the [tables.drift] file.
/// 3. Dump the new schema by running the script in the [scripts/dump_schema.sh] file.
/// 4. Use the equivalent schema script if doing it on Windows.
/// 5. Copy the [tables.drift] to the [db_schemas/drift_tables] directory.
/// 6. Update the [kSchemaVersion] to the new version.
/// 7. Run the [scripts/codegen.sh] command to generate the new schema.
/// 8. Write the migration steps in the [migration] method.
/// 9. Run the app to update the database.
/// It is a good practice to test the migration steps on a test database before
/// updating the production database.
/// Learn more at https://drift.simonbinder.eu/docs/migrations/tests/
const int kSchemaVersion = 11;

@DriftDatabase(include: {'tables.drift'})
class Database extends _$Database {
  Database() : super(_openConnection());

  Database.forTesting(DatabaseConnection super.connection);

  Database.forMigrationTesting(super.e);

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        try {
          await customStatement('PRAGMA foreign_keys = OFF');
          if (from < 11) {
            await _renameSpecimenAttributeTables(from);
          }
          if (from < 2) {
            await m.addColumn(specimen, specimen.taxonGroup);
          }

          if (from < 3) {
            await _migrateFromVersion2(m);
          }

          if (from == 3) {
            await _migrateV3only(m);
          }

          if (from < 4) {
            await _migrateFromVersion3(m);
          }

          if (from < 5) {
            await _migrateFromVersion4(m);
          }

          if (from < 6) {
            await _migrateFromVersion5(m);
          }

          if (from < 7) {
            await _migrateFromVersion6(m);
          }
          if (from < 8) {
            await _migrateFromVersion7(m);
          }
          if (from < 9) {
            await _migrateFromVersion8(m);
          }
          if (from < 10) {
            await _migrateFromVersion9(m);
          }
          if (from < 11) {
            await _validateSpecimenAttributeTables();
          }
        } catch (error, stackTrace) {
          if (kDebugMode) {
            debugPrint('Database migration from v$from to v$to failed: $error');
            debugPrintStack(stackTrace: stackTrace);
          }
          rethrow;
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _renameSpecimenAttributeTables(int from) async {
    await _renameTableIfPresent('mammalMeasurement', 'mammalAttribute');
    await _renameTableIfPresent('avianMeasurement', 'birdAttribute');
    await _renameTableIfPresent('herpMeasurement', 'herpAttribute');

    if (from >= 7) {
      await _requireTable('herpAttribute');
    }
  }

  Future<void> _renameTableIfPresent(String legacyName, String name) async {
    final legacyExists = await _tableExists(legacyName);
    final canonicalExists = await _tableExists(name);
    if (legacyExists && canonicalExists) {
      throw StateError(
        'Cannot migrate both $legacyName and $name because both tables exist.',
      );
    }
    if (legacyExists) {
      await customStatement('ALTER TABLE "$legacyName" RENAME TO "$name"');
    }
  }

  Future<bool> _tableExists(String name) async {
    final result = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(name)],
      readsFrom: const {},
    ).getSingleOrNull();
    return result != null;
  }

  Future<void> _requireTable(String name) async {
    if (!await _tableExists(name)) {
      throw StateError('Database migration is missing the $name table.');
    }
  }

  Future<void> _validateSpecimenAttributeTables() async {
    for (final name in const [
      'mammalAttribute',
      'birdAttribute',
      'herpAttribute',
    ]) {
      await _requireTable(name);
    }
    for (final name in const [
      'mammalMeasurement',
      'avianMeasurement',
      'herpMeasurement',
    ]) {
      if (await _tableExists(name)) {
        throw StateError('Database migration retained the legacy $name table.');
      }
    }

    final violations = await customSelect(
      'PRAGMA foreign_key_check',
      readsFrom: const {},
    ).get();
    if (violations.isNotEmpty) {
      throw StateError(
        'Database migration introduced ${violations.length} foreign-key '
        'violation(s).',
      );
    }
  }

  Future<void> _migrateFromVersion7(Migrator m) async {
    await m.createIndex(specimenProjectSpeciesIdx);
    await m.createIndex(specimenProjectEventIdx);
    await m.createIndex(collEventProjectSiteIdx);
    await m.createIndex(specimenPartSpecimenIdx);
  }

  Future<void> _migrateFromVersion8(Migrator m) async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS site_project_idx ON site(projectUuid)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS coordinate_site_idx ON coordinate(siteID)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS specimen_project_coordinate_idx '
      'ON specimen(projectUuid, coordinateID)',
    );
  }

  Future<void> _migrateFromVersion9(Migrator m) async {
    await _recreateIndex(
      'specimen_project_species_idx',
      'CREATE INDEX specimen_project_species_idx '
          'ON specimen(projectUuid, speciesID)',
    );
    await _recreateIndex(
      'specimen_project_event_idx',
      'CREATE INDEX specimen_project_event_idx '
          'ON specimen(projectUuid, collEventID)',
    );
    await _recreateIndex(
      'site_project_idx',
      'CREATE INDEX site_project_idx ON site(projectUuid)',
    );
    await _recreateIndex(
      'coordinate_site_idx',
      'CREATE INDEX coordinate_site_idx ON coordinate(siteID)',
    );
    await _recreateIndex(
      'specimen_project_coordinate_idx',
      'CREATE INDEX specimen_project_coordinate_idx '
          'ON specimen(projectUuid, coordinateID)',
    );
    await _recreateIndex(
      'coll_event_project_site_idx',
      'CREATE INDEX coll_event_project_site_idx '
          'ON collEvent(projectUuid, siteID)',
    );
    await _recreateIndex(
      'specimen_part_specimen_idx',
      'CREATE INDEX specimen_part_specimen_idx '
          'ON specimenPart(specimenUuid)',
    );
  }

  Future<void> _recreateIndex(String name, String createStatement) async {
    await customStatement('DROP INDEX IF EXISTS $name');
    await customStatement(createStatement);
  }

  Future<void> _migrateFromVersion6(Migrator m) async {
    // v6: add writerId to narrative table. Best-effort: ignore if already present.
    try {
      await m.addColumn(narrative, narrative.writerId);
    } catch (e) {
      // ignore failures during migration; some older DBs may not need this
      if (kDebugMode) {
        print('Migration v7: failed to add narrative.writerId: $e');
      }
    }
    // Add time column to narrative table. Best-effort: ignore if already present.
    try {
      await m.addColumn(narrative, narrative.time);
    } catch (e) {
      if (kDebugMode) {
        print('Migration v7: failed to add narrative.time: $e');
      }
    }

    // Timezones
    await m.addColumn(project, project.timeZone);

    // Herpetofauna measurements
    await m.createTable(herpAttribute);

    // Boolean for showing bat-specific measurements
    await m.addColumn(mammalAttribute, mammalAttribute.showBatFields);
    await setShowBatFieldsBoolean(m);

    // New bat measurements
    await m.addColumn(mammalAttribute, mammalAttribute.tibia);
    await m.addColumn(mammalAttribute, mammalAttribute.showEchoFields);
    await m.addColumn(mammalAttribute, mammalAttribute.echolocation);
    await m.addColumn(mammalAttribute, mammalAttribute.frequencyMax);
    await m.addColumn(mammalAttribute, mammalAttribute.frequencyMin);
    await m.addColumn(mammalAttribute, mammalAttribute.frequencyAtMaxEnergy);
    await m.addColumn(mammalAttribute, mammalAttribute.duration);

    // Enhanced specimen ID options
    await m.addColumn(personnel, personnel.isRegisterField);
    await m.addColumn(specimen, specimen.projectFieldNumber);
  }

  Future<void> _migrateFromVersion5(Migrator m) async {
    // New specimen record columns
    await m.addColumn(specimen, specimen.collectionDate);
    await m.addColumn(specimen, specimen.relativeCaptureTime);

    // Migrate specimen relative capture times to new column
    await moveRelativeCaptureTimes(m);

    // Date and time format changes
    await migrateProjectDateTimeFormat(m);
    await migrateSpecimenDateTimeFormat(m);
    await migrateNarrativeDateTimeFormat(m);
    await migrateCollEventDateTimeFormat(m);
  }

  Future<void> _migrateFromVersion4(Migrator m) async {
    await m.deleteTable('projectPersonnel');

    // Specimen record tables
    await m.addColumn(specimen, specimen.iDConfidence);
    await m.addColumn(specimen, specimen.iDMethod);

    await m.addColumn(specimenPart, specimenPart.personnelId);
    await m.addColumn(specimenPart, specimenPart.pmi);

    // Taxon registry table
    await m.addColumn(taxonomy, taxonomy.authors);
    await m.addColumn(taxonomy, taxonomy.citesStatus);
    await m.addColumn(taxonomy, taxonomy.redListCategory);
    await m.addColumn(taxonomy, taxonomy.countryStatus);
    await m.addColumn(taxonomy, taxonomy.sortingOrder);

    // Associated data
    await m.addColumn(associatedData, associatedData.date);
    await m.addColumn(associatedData, associatedData.specimenUuid);
    await m.renameColumn(associatedData, 'secondaryId', associatedData.name);
    await m.renameColumn(associatedData, 'fileId', associatedData.url);

    // Remove secondaryIdRef
    await alterTableHelper(m, associatedData);

    // Sites
    await alterTableHelper(m, coordinate);
    await castColumnsIntToReal(m, coordinate, ['elevationInMeter']);
  }

  Future<void> _migrateFromVersion3(Migrator m) async {
    await m.addColumn(personnel, personnel.photoPath);
    await m.addColumn(specimen, specimen.collectionTime);
    await m.addColumn(media, media.projectUuid);
    await m.addColumn(media, media.category);
    await m.addColumn(media, media.caption);
    await m.addColumn(media, media.tag);
    await m.addColumn(media, media.additionalExif);

    await m.create(narrativeMedia);
    await m.create(siteMedia);
    await m.create(specimenMedia);

    await m.renameColumn(collEvent, 'eventID', collEvent.idSuffix);
    await m.renameColumn(collEffort, 'type', collEffort.method);

    await m.deleteTable('fileMetadata');
    await m.deleteTable('personnelPhoto');

    // delete column from media table and personnel tables
    await alterTableHelper(m, personnel);
    await alterTableHelper(m, media);
  }

  Future<void> _migrateV3only(Migrator m) async {
    try {
      await m.renameColumn(media, 'thumbnailPath', media.fileName);
    } catch (e) {
      await m.addColumn(media, media.fileName);
    }
  }

  Future<void> _migrateFromVersion2(Migrator m) async {
    // We remove expense table. NO NEED for the app.
    await m.deleteTable('expense');

    // We add missing columns in the specimen table.
    await m.addColumn(media, media.fileName);
    await m.addColumn(specimen, specimen.coordinateID);
    await m.addColumn(specimen, specimen.methodID);
    await m.addColumn(specimen, specimen.museumID);

    // We switch bird table to revised version
    await m.deleteTable('bird_measurement');
    await m.createTable(birdAttribute);

    await castMammalType(m);
  }

  Future<void> exportInto(File file) async {
    await file.parent.create(recursive: true);

    if (file.existsSync()) {
      file.deleteSync();
    }

    await customStatement('VACUUM INTO ?', [file.path]);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await dBPath;
    if (kDebugMode) {
      print('App database path: ${file.path}');
    }
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}

Future<File> get dBPath async {
  // We save database to the default document directory locations.
  final dbDir = await nahpuDocumentDir;
  return File(p.join(dbDir.path, 'nahpu.db'));
}
