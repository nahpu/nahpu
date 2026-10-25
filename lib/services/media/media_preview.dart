import 'dart:io';

import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/file_format.dart';

/// Identifies the file behind a media card.
class MediaPreviewKey {
  const MediaPreviewKey({
    required this.projectUuid,
    required this.category,
    required this.fileName,
  });

  MediaPreviewKey.fromMedia(MediaData media)
    : projectUuid = media.projectUuid ?? '',
      category = media.category ?? '',
      fileName = media.fileName ?? '';

  /// Empty for media that should resolve against the open project.
  final String projectUuid;
  final String category;
  final String fileName;

  @override
  bool operator ==(Object other) =>
      other is MediaPreviewKey &&
      other.projectUuid == projectUuid &&
      other.category == category &&
      other.fileName == fileName;

  @override
  int get hashCode => Object.hash(projectUuid, category, fileName);
}

/// Resolved media file plus an optional cached thumbnail.
class MediaPreview {
  const MediaPreview({
    required this.file,
    required this.kind,
    required this.exists,
    this.thumbnail,
  });

  final File file;
  final MediaKind kind;
  final bool exists;
  final File? thumbnail;

  /// The smallest file that can stand in for the image, if any.
  File? get displayImage =>
      exists && kind == MediaKind.image ? thumbnail ?? file : null;
}
