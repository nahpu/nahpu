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
const int kSchemaVersion = 7;

@DriftDatabase(
  include: {'tables.drift'},
)
class Database extends _$Database {
  Database() : super(_openConnection());

  Database.forTesting(DatabaseConnection super.connection);

  Database.forMigrationTesting(super.e);

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(onCreate: (m) async {
      await m.createAll();
    }, onUpgrade: (Migrator m, int from, int to) async {
      await customStatement('PRAGMA foreign_keys = OFF');
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
    }, beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    });
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
    await m.createTable(herpMeasurement);

    // Boolean for showing bat-specific measurements
    await m.addColumn(mammalMeasurement, mammalMeasurement.showBatFields);
    await setShowBatFieldsBoolean(m);

    // New bat measurements
    await m.addColumn(mammalMeasurement, mammalMeasurement.tibia);
    await m.addColumn(mammalMeasurement, mammalMeasurement.showEchoFields);
    await m.addColumn(mammalMeasurement, mammalMeasurement.echolocation);
    await m.addColumn(mammalMeasurement, mammalMeasurement.frequencyMax);
    await m.addColumn(mammalMeasurement, mammalMeasurement.frequencyMin);
    await m.addColumn(
        mammalMeasurement, mammalMeasurement.frequencyAtMaxEnergy);
    await m.addColumn(mammalMeasurement, mammalMeasurement.duration);

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
    await m.createTable(avianMeasurement);

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
