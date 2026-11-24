import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:path/path.dart' as p;

/// Where a `media` row's file is stored under [documentRoot].
///
/// Returns null when the row lacks the file name or category needed to find
/// the file. A row without a project belongs to [fallbackProjectUuid].
File? projectMediaFile(
  Directory documentRoot,
  Map<String, dynamic> row, {
  required String fallbackProjectUuid,
}) {
  final fileName = row['fileName'] as String?;
  final category = row['category'] as String?;
  if (fileName == null || category == null) return null;
  final projectUuid = row['projectUuid'] as String? ?? fallbackProjectUuid;
  return File(
    p.join(documentRoot.path, projectUuid, mediaDir, category, fileName),
  );
}

/// Where a personnel photo is stored under [documentRoot].
///
/// Returns null when there is no photo or it is one bundled with the app.
File? personnelPhotoFile(Directory documentRoot, String? photoPath) {
  if (photoPath == null || photoPath.startsWith('assets/')) return null;
  return File(
    p.join(documentRoot.path, appMediaDirName, 'personnel', photoPath),
  );
}
