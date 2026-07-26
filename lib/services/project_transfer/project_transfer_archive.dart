import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/project_transfer/project_transfer_models.dart';
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

  Future<File> save(
    ProjectTransferPayload payload, {
    required String fileStem,
    required ProjectTransferArchiveFormat format,
    Directory? destinationDirectory,
  }) async {
    final tempRoot = await tempDirectory;
    final staging = Directory(
      path.join(
        tempRoot.path,
        'project-transfer-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await staging.create(recursive: true);
    try {
      final manifest = File(
        path.join(staging.path, projectTransferManifestName),
      );
      await manifest.writeAsString(
        format == ProjectTransferArchiveFormat.jsonGzip
            ? payload.encodedWithoutMedia
            : payload.encoded,
      );
      final output = await AppIOServices(
        dir: destinationDirectory,
        fileStem: _safeFileStem(fileStem),
        ext: format.extension,
      ).getSavePath();
      if (format == ProjectTransferArchiveFormat.jsonGzip) {
        final writer = await GzipWriter.newInstance(
          inputPath: manifest.path,
          outputPath: output.path,
        );
        await writer.write();
        return output;
      }
      final archiveFiles = <String>[manifest.path];
      for (final media in payload.mediaFiles) {
        final sourcePath = media.sourcePath;
        if (sourcePath == null) {
          throw const FormatException(
            'The export media manifest is missing a source file.',
          );
        }
        ProjectTransferPayload.validateArchivePath(media.archivePath);
        final target = File(path.join(staging.path, media.archivePath));
        await target.parent.create(recursive: true);
        await File(sourcePath).copy(target.path);
        archiveFiles.add(target.path);
      }
      if (format == ProjectTransferArchiveFormat.zip) {
        final writer = await ZipWriter.newInstance(
          parentDir: staging.path,
          files: archiveFiles,
          outputPath: output.path,
        );
        await writer.write();
      } else {
        final writer = await TarGzipWriter.newInstance(
          parentDir: staging.path,
          files: archiveFiles,
          outputPath: output.path,
        );
        await writer.write();
      }
      return output;
    } finally {
      if (staging.existsSync()) await staging.delete(recursive: true);
    }
  }

  Future<ProjectTransferArchiveFile> read(XFile input) async {
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
      if (lowerPath.endsWith('.json.gz')) {
        final manifest = File(
          path.join(extraction.path, projectTransferManifestName),
        );
        final extractor = await GzipExtractor.newInstance(
          archivePath: input.path,
          outputPath: manifest.path,
        );
        await extractor.extract();
      } else if (lowerPath.endsWith('.zip')) {
        final extractor = await ZipExtractor.newInstance(
          archivePath: input.path,
          outputDir: extraction.path,
        );
        await extractor.extract();
      } else {
        final extractor = await TarGzipExtractor.newInstance(
          archivePath: input.path,
          outputDir: extraction.path,
        );
        await extractor.extract();
      }
      _validateExtraction(extraction);
      final manifest = File(
        path.join(extraction.path, projectTransferManifestName),
      );
      if (!manifest.existsSync()) {
        throw const FormatException(
          'The archive does not contain nahpu-project.json. '
          'Bundle records files are not project transfers.',
        );
      }
      final payload = ProjectTransferPayload.parse(
        await manifest.readAsString(),
      );
      for (final media in payload.mediaFiles) {
        final file = File(path.join(extraction.path, media.archivePath));
        if (!file.existsSync()) {
          throw FormatException(
            'The archive is missing media/${media.originalFileName}.',
          );
        }
      }
      return ProjectTransferArchiveFile(
        payload: payload,
        extractedDirectory: extraction,
      );
    } catch (_) {
      if (extraction.existsSync()) await extraction.delete(recursive: true);
      rethrow;
    }
  }

  void _validateExtraction(Directory extraction) {
    final root = path.canonicalize(extraction.path);
    for (final entity in extraction.listSync(
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
