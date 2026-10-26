import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/media/media_preview.dart';
import 'package:nahpu/services/media/media_thumbnail_services.dart';
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

final allRecordMediaProvider = FutureProvider.autoDispose<List<MediaData>>((
  ref,
) {
  return MediaDbQuery(ref.read(databaseProvider)).getAllRecordMedia();
});

/// The NAHPU documents directory; resolved once instead of per media card.
final nahpuDocumentDirProvider = FutureProvider<Directory>(
  (ref) => nahpuDocumentDir,
);

final mediaThumbnailServicesProvider = Provider<MediaThumbnailServices>(
  (ref) => MediaThumbnailServices(),
);

const _recordMediaCategories = {'event', 'narrative', 'site', 'specimen'};

/// Resolves a media card's file and thumbnail once, so grid rebuilds do not
/// repeat file-system work.
final mediaPreviewProvider = FutureProvider.autoDispose
    .family<MediaPreview, MediaPreviewKey>((ref, key) async {
      final kind = matchMediaKindFromPath(key.fileName);
      final projectUuid = key.projectUuid.isEmpty
          ? ref.watch(projectUuidProvider)
          : key.projectUuid;
      final documentDir = await ref.watch(nahpuDocumentDirProvider.future);
      final file = File(
        path.join(
          documentDir.path,
          projectUuid,
          mediaDir,
          key.category,
          key.fileName,
        ),
      );
      final exists =
          _recordMediaCategories.contains(key.category) &&
          key.fileName.isNotEmpty &&
          path.basename(key.fileName) == key.fileName &&
          await file.exists();
      if (!exists || kind != MediaKind.image) {
        return MediaPreview(file: file, kind: kind, exists: exists);
      }
      final thumbnail = await ref
          .read(mediaThumbnailServicesProvider)
          .thumbnailFor(file, projectUuid: projectUuid, category: key.category);
      return MediaPreview(
        file: file,
        kind: kind,
        exists: true,
        thumbnail: thumbnail,
      );
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
