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
