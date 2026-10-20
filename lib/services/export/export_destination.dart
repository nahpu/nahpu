import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:path/path.dart' as path;

/// Empties and returns `<system temp>/NahpuTemp/exports/`.
///
/// Pruning runs at the start of an export, never at the end. A share sheet
/// keeps reading the file after the export itself finishes — "Save to Files"
/// can complete minutes later — so deleting on the way out would hand the user
/// an empty file. Whatever is still here belongs to an earlier export that has
/// already been shared or abandoned.
///
/// Only this subdirectory is cleared. Its siblings under `NahpuTemp/` are live
/// staging directories for database backups, bundles and project transfers.
Future<Directory> prepareTemporaryExportDir() async {
  final root = await nahpuTemporaryDir;
  final exports = Directory(path.join(root.path, nahpuTempExportDirName));
  await exports.create(recursive: true);
  for (final entry in await exports.list().toList()) {
    try {
      await entry.delete(recursive: true);
    } on FileSystemException {
      // One leftover the system still holds must not abort a new export.
    }
  }
  return exports;
}

/// Where the next export should be written on this platform.
class ExportDestinationService {
  ExportDestinationService({ExportDestinationMode? mode})
    : mode = mode ?? platformExportDestination;

  final ExportDestinationMode mode;

  /// Whether the destination surfaces should offer a directory picker.
  bool get canChooseDirectory => mode == ExportDestinationMode.chooseDirectory;

  /// The directory this export should be written to.
  ///
  /// Returns null when the user can choose a folder but has not, so
  /// [AppIOServices] applies its application-documents fallback unchanged.
  /// Ignores [selectedDir] in [ExportDestinationMode.temporary], where there
  /// is no picker to have set it.
  Future<Directory?> resolve(Directory? selectedDir) async => switch (mode) {
    ExportDestinationMode.chooseDirectory => selectedDir,
    ExportDestinationMode.temporary => await prepareTemporaryExportDir(),
  };
}
