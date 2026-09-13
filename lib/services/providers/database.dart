import 'package:nahpu/services/database/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<Database>((ref) {
  final db = Database();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

final databaseReadyProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);
  await db.customSelect('SELECT 1', readsFrom: const {}).getSingle();
});

/// The live database's schema version, which Drift keeps in SQLite
/// `user_version`.
final databaseSchemaVersionProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final row = await db.customSelect('PRAGMA user_version').getSingle();
  return row.read<int>('user_version');
});
