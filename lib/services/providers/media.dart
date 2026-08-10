import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';

final projectMediaProvider = FutureProvider.autoDispose<List<MediaData>>((ref) {
  final projectUuid = ref.watch(projectUuidProvider);
  if (projectUuid.isEmpty) return Future.value(const <MediaData>[]);
  return MediaDbQuery(
    ref.read(databaseProvider),
  ).getRecordMediaByProject(projectUuid);
});
