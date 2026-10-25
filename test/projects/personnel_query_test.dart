import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';

void main() {
  late Database db;

  setUp(() async {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    Future<void> run(String sql, List<Object?> values) =>
        db.customStatement(sql, values);

    await run('INSERT INTO project (uuid, name) VALUES (?, ?)', ['p1', 'One']);
    await run('INSERT INTO project (uuid, name) VALUES (?, ?)', ['p2', 'Two']);
    // Inserted alphabetically so the project order below differs from it.
    for (final (uuid, name) in [
      ('ana', 'Ana Vale'),
      ('ben', 'Ben Oru'),
      ('cara', 'Cara Lim'),
      ('dian', 'Dian Sari'),
    ]) {
      await run('INSERT INTO personnel (uuid, name) VALUES (?, ?)', [
        uuid,
        name,
      ]);
    }
    for (final (project, person) in [
      ('p1', 'cara'),
      ('p2', 'dian'),
      ('p1', 'ana'),
      ('p2', 'ana'),
      ('p1', 'ben'),
    ]) {
      await run(
        'INSERT INTO personnelList (projectUuid, personnelUuid) VALUES (?, ?)',
        [project, person],
      );
    }
  });

  tearDown(() => db.close());

  test('project personnel come back in the order they were added', () async {
    final people = await PersonnelQuery(db).getPersonnelByProjectUuid('p1');

    expect(people.map((e) => e.uuid), ['cara', 'ana', 'ben']);
    expect(people.map((e) => e.name), ['Cara Lim', 'Ana Vale', 'Ben Oru']);
  });

  test('project personnel exclude people from other projects', () async {
    final people = await PersonnelQuery(db).getPersonnelByProjectUuid('p2');

    expect(people.map((e) => e.uuid), ['dian', 'ana']);
    expect(await PersonnelQuery(db).getPersonnelByProjectUuid('none'), isEmpty);
  });
}
