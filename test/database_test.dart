import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';

void main() {
  late Database db;

  setUp(() {
    final inMemory = DatabaseConnection(NativeDatabase.memory());
    db = Database.forTesting(inMemory);
  });

  tearDown(() async {
    await db.close();
  });

  test('test db version', () async {
    final QueryRow result = await db.customSelect(
      'PRAGMA user_version;',
      readsFrom: const {}, // No tables are read, so the stream doesn't emit updates.
    ).getSingle();

    final int userVersion = result.data['user_version'] as int;

    expect(userVersion, db.schemaVersion);
  });
}
