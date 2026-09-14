import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// A replacement file is read before anything is overwritten, so a wrong,
/// damaged, or newer database is caught while the current data is in place.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nahpu-replacement');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> writeNahpuDatabase() async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    try {
      await db
          .into(db.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project-a'),
              name: Value('Project A'),
            ),
          );
      for (final uuid in ['specimen-a', 'specimen-b']) {
        await db
            .into(db.specimen)
            .insert(
              SpecimenCompanion(
                uuid: Value(uuid),
                projectUuid: const Value('project-a'),
              ),
            );
      }
      final file = File(p.join(tempDir.path, 'nahpu.sqlite3'));
      await db.customStatement('VACUUM INTO ?', [file.path]);
      return file;
    } finally {
      await db.close();
    }
  }

  test('reads the counts and schema version of a NAHPU database', () async {
    final file = await writeNahpuDatabase();

    final contents = await readDatabaseContents(file.path);

    expect(contents.entries['Projects'], 1);
    expect(contents.entries['Specimens'], 2);
    expect(contents.entries.keys, dbSummaryTables.keys);
    expect(contents.schemaVersion, kSchemaVersion);
    expect(contents.associatedFiles, isNull);
    expect(contents.totalBytes, await file.length());
    expect(replacementIssueFor(contents), isNull);
  });

  test('a SQLite file without NAHPU tables is not a NAHPU database', () async {
    final path = p.join(tempDir.path, 'other.sqlite3');
    final other = sqlite3.sqlite3.open(path);
    other.execute('CREATE TABLE note (id INTEGER PRIMARY KEY)');
    other.close();

    final contents = await readDatabaseContents(path);

    expect(contents.entries['Projects'], isNull);
    expect(replacementIssueFor(contents), DbReplacementIssue.notNahpuDatabase);
  });

  test('a newer schema asks the user to update NAHPU', () async {
    final file = await writeNahpuDatabase();
    final database = sqlite3.sqlite3.open(file.path);
    database.userVersion = kSchemaVersion + 1;
    database.close();

    final preview = await DbReplacementPreview.read(file.path);

    expect(preview.issue, DbReplacementIssue.newerSchema);
    expect(preview.issue!.message, contains('Update NAHPU'));
    expect(preview.contents?.schemaVersion, kSchemaVersion + 1);
  });

  test('an older schema can still be restored', () async {
    final file = await writeNahpuDatabase();
    final database = sqlite3.sqlite3.open(file.path);
    database.userVersion = kSchemaVersion - 1;
    database.close();

    final preview = await DbReplacementPreview.read(file.path);

    expect(preview.issue, isNull);
  });

  test('a damaged file is reported rather than thrown', () async {
    final file = File(p.join(tempDir.path, 'broken.sqlite3'));
    await file.writeAsString('not a database');

    final preview = await DbReplacementPreview.read(file.path);

    expect(preview.issue, DbReplacementIssue.unreadable);
    expect(preview.contents, isNull);
  });

  test('archive files are added to the replacement contents', () async {
    final file = await writeNahpuDatabase();

    final preview = await DbReplacementPreview.read(
      file.path,
      associatedFiles: 3,
      associatedBytes: 100,
      includesSettings: true,
    );

    expect(preview.contents?.associatedFiles, 3);
    expect(preview.contents?.totalBytes, await file.length() + 100);
    expect(preview.includesSettings, isTrue);
  });

  test('the schema version provider reads the live database', () async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    expect(
      await container.read(databaseSchemaVersionProvider.future),
      kSchemaVersion,
    );
  });
}
