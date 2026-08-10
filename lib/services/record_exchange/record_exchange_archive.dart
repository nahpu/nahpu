import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';
import 'package:nahpu/src/rust/api/archive.dart';

class RecordExchangeArchiveFile {
  const RecordExchangeArchiveFile({
    required this.payload,
    this.extractedMediaDirectory,
  });

  final RecordExchangePayload payload;
  final Directory? extractedMediaDirectory;
}

class RecordExchangeArchiveService extends AppServices {
  const RecordExchangeArchiveService({required super.ref});

  Future<File> save(
    RecordExchangePayload payload, {
    required String fileStem,
    RecordArchiveFormat? archiveFormat,
    Directory? destinationDirectory,
  }) async {
    if (archiveFormat == null) {
      if (payload.hasMedia) {
        throw const FormatException(
          'Linked media must be exported in a compressed archive.',
        );
      }
      final output = await AppIOServices(
        dir: destinationDirectory,
        fileStem: _safeFileStem(fileStem),
        ext: 'json',
      ).getSavePath();
      await output.writeAsString(payload.encoded);
      return output;
    }
    if (payload.hasMedia && payload.mediaFiles.length != payload.mediaCount) {
      throw const FormatException(
        'The media manifest does not contain every linked media file.',
      );
    }

    final tempRoot = await tempDirectory;
    final staging = Directory(
      path.join(
        tempRoot.path,
        'record-exchange-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await staging.create(recursive: true);
    try {
      final recordFile = File(path.join(staging.path, 'nahpu-record.json'));
      await recordFile.writeAsString(payload.encoded);
      final archiveFiles = <String>[recordFile.path];
      for (final media in payload.mediaFiles) {
        final target = File(
          path.joinAll([staging.path, ...path.posix.split(media.archivePath)]),
        );
        await target.parent.create(recursive: true);
        await File(media.sourcePath).copy(target.path);
        archiveFiles.add(target.path);
      }
      final output = await AppIOServices(
        dir: destinationDirectory,
        fileStem: _safeFileStem(fileStem),
        ext: archiveFormat.extension,
      ).getSavePath();
      if (archiveFormat == RecordArchiveFormat.zip) {
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
      if (staging.existsSync()) {
        await staging.delete(recursive: true);
      }
    }
  }

  Future<RecordExchangeArchiveFile> read(
    XFile input, {
    required RecordExchangeType expectedType,
  }) async {
    final inputFile = File(input.path);
    final extension = inputFile.path.toLowerCase();
    if (extension.endsWith('.json')) {
      return RecordExchangeArchiveFile(
        payload: RecordExchangePayload.parse(
          await inputFile.readAsString(),
          expectedType: expectedType.wireName,
        ),
      );
    }
    if (!extension.endsWith('.zip') && !extension.endsWith('.tar.gz')) {
      throw const FormatException(
        'Choose a NAHPU JSON, ZIP, or TAR.GZ record export.',
      );
    }

    final root = await tempDirectory;
    final extraction = Directory(
      path.join(
        root.path,
        'record-import-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await extraction.create(recursive: true);
    try {
      if (extension.endsWith('.zip')) {
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
      _validateExtractedFiles(extraction);
      final recordFile = File(path.join(extraction.path, 'nahpu-record.json'));
      if (!recordFile.existsSync()) {
        throw const FormatException(
          'The archive does not contain nahpu-record.json.',
        );
      }
      return RecordExchangeArchiveFile(
        payload: RecordExchangePayload.parse(
          await recordFile.readAsString(),
          expectedType: expectedType.wireName,
        ),
        extractedMediaDirectory: extraction,
      );
    } catch (_) {
      if (extraction.existsSync()) await extraction.delete(recursive: true);
      rethrow;
    }
  }

  void _validateExtractedFiles(Directory extraction) {
    for (final entity in extraction.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (!entity.path.startsWith('${extraction.path}${path.separator}')) {
        throw const FormatException('The archive contains an unsafe path.');
      }
    }
  }

  String _safeFileStem(String value) {
    final cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'nahpu-record' : 'nahpu-$cleaned';
  }
}
