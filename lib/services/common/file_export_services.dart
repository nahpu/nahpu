/// Writes files chosen in the app-directory explorer to a single archive.
///
/// The point is to let a user reclaim space without losing anything: media and
/// documents leave the app folder as one compressed file they keep, instead of
/// being deleted outright. Because the archive preserves each file's path
/// relative to the app directory, its contents can be read — or restored by
/// hand — without NAHPU.
library;

import 'dart:io';

import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:path/path.dart' as path;

/// Stem of the archive the explorer writes.
const String selectionExportStem = 'nahpu_export';

/// Result of a selection export.
class SelectionExport {
  const SelectionExport({
    required this.archive,
    required this.fileCount,
    required this.sizeBytes,
    required this.exportedPaths,
  });

  final File archive;
  final int fileCount;

  /// Size of the archive on disk, which is what the user is about to keep.
  final int sizeBytes;

  /// The source files that went in, in the order they were written.
  ///
  /// The caller removes these only after the archive is verified, so a failed
  /// export can never take the originals with it.
  final List<String> exportedPaths;
}

/// Writes [paths] to one archive under [destination].
///
/// [root] is the canonical app directory; every path must sit inside it, and
/// the archive reproduces that layout. Throws [FormatException] when [paths] is
/// empty or strays outside [root], and deletes any half-written archive if the
/// write fails or is cancelled.
class SelectionExportService {
  const SelectionExportService();

  Future<SelectionExport> export({
    required String root,
    required List<String> paths,
    required Directory destination,
    required DbArchiveFormat format,
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    if (paths.isEmpty) {
      throw const FormatException('Select at least one file to export.');
    }

    final sources = <String>[];
    for (final candidate in paths) {
      final normalized = path.normalize(candidate);
      if (!path.isWithin(root, normalized)) {
        throw FormatException(
          'Cannot export a file outside the application folder: $candidate',
        );
      }
      if (!File(normalized).existsSync()) continue;
      sources.add(normalized);
    }
    if (sources.isEmpty) {
      throw const FormatException(
        'None of the selected files are still on disk.',
      );
    }

    final output = await _outputFile(destination, format);
    try {
      progress?.beginPhase(ExportPhase.compressing, totalUnits: sources.length);
      cancel?.throwIfCancelled();
      // No staging copy: the files already sit under `root`, so handing the
      // writer that root reproduces the `nahpu/` layout inside the archive.
      await _writeArchive(
        format: format,
        parentDir: root,
        files: sources,
        outputPath: output.path,
        progress: progress,
        cancel: cancel,
      );
      cancel?.throwIfCancelled();

      // An archive that is missing or empty must never lead to a delete.
      if (!output.existsSync()) {
        throw const FormatException('The archive was not written.');
      }
      final size = output.lengthSync();
      if (size <= 0) {
        throw const FormatException('The archive was written empty.');
      }

      progress?.complete();
      return SelectionExport(
        archive: output,
        fileCount: sources.length,
        sizeBytes: size,
        exportedPaths: sources,
      );
    } catch (_) {
      await _deleteIncompleteOutput(output);
      rethrow;
    }
  }

  Future<void> _writeArchive({
    required DbArchiveFormat format,
    required String parentDir,
    required List<String> files,
    required String outputPath,
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    switch (format) {
      case DbArchiveFormat.zip:
        final writer = await ZipWriter.newInstance(
          parentDir: parentDir,
          files: files,
          outputPath: outputPath,
        );
        await followArchiveProgress(
          writer.writeWithProgress(),
          progress: progress,
          cancel: cancel,
        );
      case DbArchiveFormat.tarGzip:
        final writer = await TarGzipWriter.newInstance(
          parentDir: parentDir,
          files: files,
          outputPath: outputPath,
        );
        await followArchiveProgress(
          writer.writeWithProgress(),
          progress: progress,
          cancel: cancel,
        );
    }
  }

  /// Picks a free filename, so a second export never overwrites the first.
  Future<File> _outputFile(
    Directory destination,
    DbArchiveFormat format,
  ) async {
    if (!destination.existsSync()) {
      await destination.create(recursive: true);
    }
    final stem = '$selectionExportStem-$dateStamp';
    var candidate = File(
      path.join(destination.path, '$stem.${format.extension}'),
    );
    var index = 1;
    while (candidate.existsSync()) {
      candidate = File(
        path.join(destination.path, '$stem($index).${format.extension}'),
      );
      index += 1;
    }
    return candidate;
  }

  Future<void> _deleteIncompleteOutput(File output) async {
    try {
      if (output.existsSync()) await output.delete();
    } on FileSystemException {
      return;
    }
  }
}

/// `2026-08-23`, for the archive name.
String get dateStamp {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}
