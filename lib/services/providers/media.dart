import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:path/path.dart' as path;

final projectMediaProvider = FutureProvider.autoDispose<List<MediaData>>((ref) {
  final projectUuid = ref.watch(projectUuidProvider);
  if (projectUuid.isEmpty) return Future.value(const <MediaData>[]);
  return MediaDbQuery(
    ref.read(databaseProvider),
  ).getRecordMediaByProject(projectUuid);
});

final projectPreviewImageFilesProvider = FutureProvider.autoDispose
    .family<List<File>, String>((ref, projectUuid) async {
      if (projectUuid.isEmpty) return const <File>[];

      final media = await MediaDbQuery(
        ref.read(databaseProvider),
      ).getRecordMediaByProject(projectUuid);
      final candidates = media.where((item) {
        final fileName = item.fileName;
        return fileName != null &&
            fileName.isNotEmpty &&
            path.basename(fileName) == fileName &&
            matchMediaKindFromPath(fileName) == MediaKind.image;
      }).toList()..shuffle();
      if (candidates.isEmpty) return const <File>[];

      final documentDir = await nahpuDocumentDir;
      final files = <File>[];
      final paths = <String>{};
      for (final item in candidates) {
        final file = File(
          path.join(
            documentDir.path,
            projectUuid,
            mediaDir,
            item.category!,
            item.fileName!,
          ),
        );
        if (!paths.add(file.path)) continue;
        try {
          if (!await file.exists()) continue;
        } on FileSystemException {
          continue;
        }
        files.add(file);
        if (files.length == 5) break;
      }

      return List.unmodifiable(files);
    });
