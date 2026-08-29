import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/projects/project_transfer_models.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:path/path.dart' as path;

class ProjectTransferArchiveFile {
  const ProjectTransferArchiveFile({
    required this.payload,
    required this.extractedDirectory,
  });

  final ProjectTransferPayload payload;
  final Directory extractedDirectory;

  Future<void> dispose() async {
    if (extractedDirectory.existsSync()) {
      await extractedDirectory.delete(recursive: true);
    }
  }
}

class ProjectTransferArchiveService extends AppServices {
  const ProjectTransferArchiveService({required super.ref});

  /// Describes the stages of a project export, weighted by the bytes each moves.
  ///
  /// A light export carries no media, so it skips the copy stage rather than
  /// showing the user a step that completes instantly and means nothing.
  static List<ExportPhaseStep> exportPhases(
    ProjectTransferPayload payload,
    ProjectTransferArchiveFormat format,
  ) {
    if (format == ProjectTransferArchiveFormat.jsonGzip) {
      return const [
        ExportPhaseStep(phase: ExportPhase.preparing, label: 'Write records'),
        ExportPhaseStep(
          phase: ExportPhase.compressing,
          label: 'Compress archive',
        ),
      ];
    }
    final mediaBytes = payload.mediaBytes.toDouble();
    final hasSizes = mediaBytes > 0;
    return [
      const ExportPhaseStep(
        phase: ExportPhase.preparing,
        label: 'Write records',
      ),
      ExportPhaseStep(
        phase: ExportPhase.copyingFiles,
        label: 'Copy media',
        weight: hasSizes ? mediaBytes : 1,
      ),
      ExportPhaseStep(
        phase: ExportPhase.compressing,
        label: 'Compress archive',
        weight: hasSizes ? mediaBytes : 1,
      ),
    ];
  }

  /// Describes the stages of reading a project archive back in.
  static const List<ExportPhaseStep> importPhases = [
    ExportPhaseStep(phase: ExportPhase.extracting, label: 'Extract archive'),
    ExportPhaseStep(phase: ExportPhase.verifying, label: 'Check contents'),
  ];

  /// Writes the transfer archive, reporting to [progress] as each stage runs.
  Future<File> save(
    ProjectTransferPayload payload, {
    required String fileStem,
    required ProjectTransferArchiveFormat format,
    Directory? destinationDirectory,
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final tempRoot = await tempDirectory;
    final staging = Directory(
      path.join(
        tempRoot.path,
        'project-transfer-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await staging.create(recursive: true);
    File? output;
    try {
      progress?.beginPhase(ExportPhase.preparing);
      cancel?.throwIfCancelled();
      final manifest = File(
        path.join(staging.path, projectTransferManifestName),
      );
      progress?.setCurrentItem(projectTransferManifestName);
      await manifest.writeAsString(
        format == ProjectTransferArchiveFormat.jsonGzip
            ? payload.encodedWithoutMedia
            : payload.encoded,
      );
      output = await AppIOServices(
        dir: destinationDirectory,
        fileStem: _safeFileStem(fileStem),
        ext: format.extension,
      ).getSavePath();
      cancel?.throwIfCancelled();
      if (format == ProjectTransferArchiveFormat.jsonGzip) {
        progress?.beginPhase(ExportPhase.compressing, totalUnits: 1);
        final writer = await GzipWriter.newInstance(
          inputPath: manifest.path,
          outputPath: output.path,
        );
        await followArchiveProgress(
          writer.writeWithProgress(),
          progress: progress,
          cancel: cancel,
        );
        progress?.complete();
        return output;
      }
      final archiveFiles = <String>[manifest.path];
      progress?.beginPhase(
        ExportPhase.copyingFiles,
        totalUnits: payload.mediaFiles.length,
        totalBytes: payload.mediaBytes,
      );
      for (final media in payload.mediaFiles) {
        cancel?.throwIfCancelled();
        final sourcePath = media.sourcePath;
        if (sourcePath == null) {
          throw const FormatException(
            'The export media manifest is missing a source file.',
          );
        }
        ProjectTransferPayload.validateArchivePath(media.archivePath);
        final target = File(path.join(staging.path, media.archivePath));
        await target.parent.create(recursive: true);
        progress?.setCurrentItem(media.originalFileName);
        await File(sourcePath).copy(target.path);
        progress?.advanceItem(bytes: media.sizeBytes);
        archiveFiles.add(target.path);
      }
      cancel?.throwIfCancelled();
      progress?.beginPhase(
        ExportPhase.compressing,
        totalUnits: archiveFiles.length,
      );
      if (format == ProjectTransferArchiveFormat.zip) {
        final writer = await ZipWriter.newInstance(
          parentDir: staging.path,
          files: archiveFiles,
          outputPath: output.path,
        );
        await followArchiveProgress(
          writer.writeWithProgress(),
          progress: progress,
          cancel: cancel,
        );
      } else {
        final writer = await TarGzipWriter.newInstance(
          parentDir: staging.path,
          files: archiveFiles,
          outputPath: output.path,
        );
        await followArchiveProgress(
          writer.writeWithProgress(),
          progress: progress,
          cancel: cancel,
        );
      }
      cancel?.throwIfCancelled();
      progress?.complete();
      return output;
    } catch (_) {
      await _deleteIncompleteOutput(output);
      rethrow;
    } finally {
      if (staging.existsSync()) await staging.delete(recursive: true);
    }
  }

  Future<ProjectTransferArchiveFile> read(
    XFile input, {
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final lowerPath = input.path.toLowerCase();
    if (!lowerPath.endsWith('.json.gz') &&
        !lowerPath.endsWith('.zip') &&
        !lowerPath.endsWith('.tar.gz')) {
      throw const FormatException(
        'Choose a NAHPU project transfer JSON.GZ, ZIP, or TAR.GZ archive.',
      );
    }
    final root = await tempDirectory;
    final extraction = Directory(
      path.join(
        root.path,
        'project-import-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await extraction.create(recursive: true);
    try {
      progress?.beginPhase(ExportPhase.extracting);
      if (lowerPath.endsWith('.json.gz')) {
        final manifest = File(
          path.join(extraction.path, projectTransferManifestName),
        );
        final extractor = await GzipExtractor.newInstance(
          archivePath: input.path,
          outputPath: manifest.path,
        );
        await followArchiveProgress(
          extractor.extractWithProgress(),
          progress: progress,
          cancel: cancel,
        );
      } else if (lowerPath.endsWith('.zip')) {
        final extractor = await ZipExtractor.newInstance(
          archivePath: input.path,
          outputDir: extraction.path,
        );
        await followArchiveProgress(
          extractor.extractWithProgress(),
          progress: progress,
          cancel: cancel,
        );
      } else {
        final extractor = await TarGzipExtractor.newInstance(
          archivePath: input.path,
          outputDir: extraction.path,
        );
        await followArchiveProgress(
          extractor.extractWithProgress(),
          progress: progress,
          cancel: cancel,
        );
      }
      progress?.beginPhase(ExportPhase.verifying);
      await _validateExtraction(extraction);
      final manifest = File(
        path.join(extraction.path, projectTransferManifestName),
      );
      if (!manifest.existsSync()) {
        throw const FormatException(
          'The archive does not contain nahpu-project.json. '
          'Choose a project export or NAHPU Data Package.',
        );
      }
      final payload = ProjectTransferPayload.parse(
        await manifest.readAsString(),
      );
      progress?.reportDetail(
        ExportPhaseDetail(totalUnits: payload.mediaFiles.length),
      );
      for (final media in payload.mediaFiles) {
        cancel?.throwIfCancelled();
        final file = File(path.join(extraction.path, media.archivePath));
        if (!file.existsSync()) {
          throw FormatException(
            'The archive is missing media/${media.originalFileName}.',
          );
        }
        progress?.advanceItem(currentItem: media.originalFileName);
      }
      progress?.complete();
      return ProjectTransferArchiveFile(
        payload: payload,
        extractedDirectory: extraction,
      );
    } catch (_) {
      if (extraction.existsSync()) await extraction.delete(recursive: true);
      rethrow;
    }
  }

  /// Rejects an archive whose entries escape the extraction directory.
  ///
  /// The walk is asynchronous so a large import does not block the frame that
  /// draws the progress panel.
  Future<void> _validateExtraction(Directory extraction) async {
    final root = path.canonicalize(extraction.path);
    await for (final entity in extraction.list(
      recursive: true,
      followLinks: false,
    )) {
      final candidate = path.canonicalize(entity.path);
      if (!path.isWithin(root, candidate) || entity is Link) {
        throw const FormatException(
          'The project transfer contains an unsafe path.',
        );
      }
    }
  }

  /// Removes a partially written archive so a failed export leaves no broken file.
  Future<void> _deleteIncompleteOutput(File? output) async {
    if (output == null) return;
    try {
      if (output.existsSync()) await output.delete();
    } on FileSystemException {
      // The destination is already unusable; the original error matters more.
    }
  }

  String _safeFileStem(String value) {
    final withoutExtension = value.trim().replaceFirst(
      RegExp(r'\.(json\.gz|zip|tar\.gz)$', caseSensitive: false),
      '',
    );
    final cleaned = withoutExtension
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'nahpu-project-transfer' : cleaned;
  }
}
