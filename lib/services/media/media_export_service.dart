import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:nahpu/src/rust/api/images.dart' as rust_images;
import 'package:path/path.dart' as path;

const Set<String> convertibleImageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

enum MediaExportFormat { original, jpeg, png, webp }

enum MediaBatchArchiveFormat { tarGzip, zip }

extension MediaBatchArchiveFormatDetails on MediaBatchArchiveFormat {
  String get label => switch (this) {
    MediaBatchArchiveFormat.tarGzip => 'TAR.GZ',
    MediaBatchArchiveFormat.zip => 'ZIP',
  };

  String get extension => switch (this) {
    MediaBatchArchiveFormat.tarGzip => 'tar.gz',
    MediaBatchArchiveFormat.zip => 'zip',
  };
}

extension MediaExportFormatDetails on MediaExportFormat {
  String label(String originalExtension) => switch (this) {
    MediaExportFormat.original =>
      originalExtension.isEmpty
          ? 'Original'
          : 'Original (.${originalExtension.toLowerCase()})',
    MediaExportFormat.jpeg => 'JPEG (.jpg)',
    MediaExportFormat.png => 'PNG (.png)',
    MediaExportFormat.webp => 'WebP (.webp)',
  };

  String extension(String originalExtension) => switch (this) {
    MediaExportFormat.original => originalExtension,
    MediaExportFormat.jpeg => 'jpg',
    MediaExportFormat.png => 'png',
    MediaExportFormat.webp => 'webp',
  };
}

class ImagePixelDimensions {
  const ImagePixelDimensions({required this.width, required this.height});

  final int width;
  final int height;
}

class MediaExportSource {
  const MediaExportSource({
    required this.file,
    required this.kind,
    required this.originalExtension,
    this.imageInfo,
    this.conversionUnavailableReason,
  });

  final File file;
  final MediaKind kind;
  final String originalExtension;
  final rust_images.ImageSourceInfo? imageInfo;
  final String? conversionUnavailableReason;

  String get defaultFileStem {
    final stem = path.basenameWithoutExtension(file.path).trim();
    return stem.isEmpty ? 'media' : stem;
  }

  bool get canConvertImage => imageInfo != null;

  List<MediaExportFormat> get availableFormats => [
    MediaExportFormat.original,
    if (canConvertImage) ...[
      MediaExportFormat.jpeg,
      MediaExportFormat.png,
      MediaExportFormat.webp,
    ],
  ];
}

class MediaExportResult {
  const MediaExportResult({
    required this.file,
    required this.bytes,
    required this.resized,
    this.width,
    this.height,
  });

  final File file;
  final int bytes;
  final bool resized;
  final int? width;
  final int? height;
}

class MediaBatchExportOptions {
  const MediaBatchExportOptions({
    required this.archiveFormat,
    required this.imageFormat,
    this.maxLongSidePixels,
    this.jpegQuality = 85,
  });

  final MediaBatchArchiveFormat archiveFormat;
  final MediaExportFormat imageFormat;
  final int? maxLongSidePixels;
  final int jpegQuality;
}

class MediaBatchWarning {
  const MediaBatchWarning({required this.fileName, required this.message});

  final String fileName;
  final String message;

  @override
  String toString() => '$fileName: $message';
}

class PreparedMediaBatchItem {
  const PreparedMediaBatchItem({
    required this.media,
    required this.file,
    required this.kind,
    required this.originalExtension,
    required this.categoryFolder,
    required this.sourceBytes,
  });

  final MediaData media;
  final File file;
  final MediaKind kind;
  final String originalExtension;
  final String categoryFolder;
  final int sourceBytes;

  String get fileName => path.basename(file.path);
  bool get canConvertImage =>
      kind == MediaKind.image &&
      convertibleImageExtensions.contains(originalExtension);
}

class PreparedMediaBatch {
  const PreparedMediaBatch({
    required this.requestedCount,
    required this.items,
    required this.warnings,
  });

  final int requestedCount;
  final List<PreparedMediaBatchItem> items;
  final List<MediaBatchWarning> warnings;

  int get sourceBytes =>
      items.fold(0, (total, item) => total + item.sourceBytes);

  int count(MediaKind kind) => items.where((item) => item.kind == kind).length;
}

class MediaBatchExportResult {
  const MediaBatchExportResult({
    required this.file,
    required this.requestedCount,
    required this.exportedCount,
    required this.bytes,
    required this.warnings,
  });

  final File file;
  final int requestedCount;
  final int exportedCount;
  final int bytes;
  final List<MediaBatchWarning> warnings;

  int get skippedCount => requestedCount - exportedCount;
}

class MediaBatchExportAllFilesFailedException implements Exception {
  const MediaBatchExportAllFilesFailedException(this.warnings);

  final List<MediaBatchWarning> warnings;

  @override
  String toString() => 'None of the selected media files could be exported.';
}

typedef InspectImageCallback =
    Future<rust_images.ImageSourceInfo> Function({required String inputPath});

typedef ConvertImageCallback =
    Future<rust_images.ImageExportResult> Function({
      required String inputPath,
      required String outputPath,
      required rust_images.ImageExportFormat outputFormat,
      int? resizeWidth,
      int? resizeHeight,
      required int jpegQuality,
    });

typedef ConvertImagesCallback =
    Stream<rust_images.BatchImageExportEvent> Function({
      required List<rust_images.BatchImageExportRequest> requests,
    });

class MediaExportService extends AppServices {
  MediaExportService({
    required super.ref,
    InspectImageCallback? inspectImage,
    ConvertImageCallback? convertImage,
    ConvertImagesCallback? convertImages,
  }) : _inspectImage = inspectImage ?? rust_images.inspectImage,
       _convertImage = convertImage ?? rust_images.exportImage,
       _convertImages =
           convertImages ??
           (convertImage == null ? rust_images.exportImagesBatch : null);

  final InspectImageCallback _inspectImage;
  final ConvertImageCallback _convertImage;
  final ConvertImagesCallback? _convertImages;

  static List<ExportPhaseStep> batchExportPhases(PreparedMediaBatch batch) {
    final weight = batch.sourceBytes > 0 ? batch.sourceBytes.toDouble() : 1.0;
    return [
      ExportPhaseStep(
        phase: ExportPhase.processingFiles,
        label: 'Process media',
        weight: weight,
      ),
      ExportPhaseStep(
        phase: ExportPhase.compressing,
        label: 'Compress archive',
        weight: weight,
      ),
    ];
  }

  Future<MediaExportSource> prepare(MediaData media) async {
    final fileName = media.fileName?.trim() ?? '';
    if (fileName.isEmpty) {
      throw const FormatException('This media item has no file name.');
    }
    final category = matchMediaCategoryString(media.category ?? '');
    final imageServices = ImageServices(ref: ref, category: category);
    final file = category == MediaCategory.personnel
        ? await imageServices.getPersonnelMediaPath(fileName)
        : await imageServices.getProjectMediaPath(
            fileName,
            media.projectUuid ?? '',
          );
    if (!await file.exists()) {
      throw FormatException('Media file not found: ${file.path}');
    }

    final extension = normalizeExtension(file.path);
    final kind = matchMediaKindFromPath(file.path);
    if (!convertibleImageExtensions.contains(extension)) {
      return MediaExportSource(
        file: file,
        kind: kind,
        originalExtension: extension,
        conversionUnavailableReason: kind == MediaKind.image
            ? '${extension.toUpperCase()} images can only be exported in '
                  'their original format.'
            : null,
      );
    }

    try {
      final info = await _inspectImage(inputPath: file.path);
      return MediaExportSource(
        file: file,
        kind: kind,
        originalExtension: extension,
        imageInfo: info,
      );
    } catch (error) {
      return MediaExportSource(
        file: file,
        kind: kind,
        originalExtension: extension,
        conversionUnavailableReason:
            'Image conversion is unavailable. The original file can still '
            'be exported. ${error.toString()}',
      );
    }
  }

  Future<PreparedMediaBatch> prepareBatch(Iterable<MediaData> media) async {
    final unique = <int, MediaData>{
      for (final item in media) item.primaryId: item,
    }.values.toList(growable: false)..sort(_compareMedia);
    final items = <PreparedMediaBatchItem>[];
    final warnings = <MediaBatchWarning>[];

    for (final item in unique) {
      final fileName = item.fileName?.trim() ?? '';
      if (fileName.isEmpty || path.basename(fileName) != fileName) {
        warnings.add(
          MediaBatchWarning(
            fileName: fileName.isEmpty ? 'Unnamed media' : fileName,
            message: 'The stored file name is invalid and will be skipped.',
          ),
        );
        continue;
      }
      try {
        final file = await _resolveMediaFile(item, fileName);
        if (!await file.exists()) {
          warnings.add(
            MediaBatchWarning(
              fileName: fileName,
              message: 'The file is missing and will be skipped.',
            ),
          );
          continue;
        }
        final extension = normalizeExtension(file.path);
        final kind = matchMediaKindFromPath(file.path);
        items.add(
          PreparedMediaBatchItem(
            media: item,
            file: file,
            kind: kind,
            originalExtension: extension,
            categoryFolder: _categoryFolder(item.category),
            sourceBytes: await file.length(),
          ),
        );
      } catch (error) {
        warnings.add(
          MediaBatchWarning(
            fileName: fileName,
            message:
                'Could not prepare this file and it will be skipped: '
                '$error',
          ),
        );
      }
    }

    return PreparedMediaBatch(
      requestedCount: unique.length,
      items: List.unmodifiable(items),
      warnings: List.unmodifiable(warnings),
    );
  }

  Future<MediaBatchExportResult> exportBatch({
    required PreparedMediaBatch batch,
    required MediaBatchExportOptions options,
    required String fileStem,
    Directory? destinationDirectory,
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    _validateBatchOptions(batch, options, fileStem);
    final tempRoot = await tempDirectory;
    final staging = Directory(
      path.join(
        tempRoot.path,
        'media-export-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await staging.create(recursive: true);
    File? output;
    final warnings = <MediaBatchWarning>[...batch.warnings];
    final archiveFiles = <String>[];
    final namesByCategory = <String, Set<String>>{};

    try {
      progress?.beginPhase(
        ExportPhase.processingFiles,
        totalUnits: batch.items.length,
        totalBytes: batch.sourceBytes,
      );
      if (_convertImages != null &&
          options.imageFormat != MediaExportFormat.original) {
        archiveFiles.addAll(
          (await _stageBatchItemsInParallel(
            items: batch.items,
            options: options,
            staging: staging,
            namesByCategory: namesByCategory,
            warnings: warnings,
            progress: progress,
            cancel: cancel,
          )).map((file) => file.path),
        );
      } else {
        for (final item in batch.items) {
          cancel?.throwIfCancelled();
          progress?.setCurrentItem(item.fileName);
          try {
            final staged = await _stageBatchItem(
              item: item,
              options: options,
              staging: staging,
              namesByCategory: namesByCategory,
              warnings: warnings,
            );
            if (staged != null) archiveFiles.add(staged.path);
            progress?.advanceItem(bytes: item.sourceBytes);
          } on ExportCancelledException {
            rethrow;
          } catch (error) {
            warnings.add(
              MediaBatchWarning(
                fileName: item.fileName,
                message: 'Skipped because processing failed: $error',
              ),
            );
            progress?.advanceItem(bytes: item.sourceBytes);
          }
        }
      }
      cancel?.throwIfCancelled();
      if (archiveFiles.isEmpty) {
        throw MediaBatchExportAllFilesFailedException(
          List.unmodifiable(warnings),
        );
      }

      output = await AppIOServices(
        dir: destinationDirectory,
        fileStem: _safeArchiveStem(fileStem),
        ext: options.archiveFormat.extension,
      ).getSavePath();
      progress?.beginPhase(
        ExportPhase.compressing,
        totalUnits: archiveFiles.length,
      );
      if (options.archiveFormat == MediaBatchArchiveFormat.zip) {
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
      final outputBytes = await output.length();
      return MediaBatchExportResult(
        file: output,
        requestedCount: batch.requestedCount,
        exportedCount: archiveFiles.length,
        bytes: outputBytes,
        warnings: List.unmodifiable(warnings),
      );
    } catch (_) {
      await _deleteIncompleteOutput(output);
      rethrow;
    } finally {
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  Future<MediaExportResult> export({
    required MediaExportSource source,
    required MediaExportFormat format,
    required String fileStem,
    Directory? destinationDirectory,
    int? width,
    int? height,
    int jpegQuality = 85,
  }) async {
    final stem = fileStem.trim();
    if (stem.isEmpty) {
      throw const FormatException('Enter a file name.');
    }
    if (!await source.file.exists()) {
      throw FormatException('Media file not found: ${source.file.path}');
    }
    if (!source.availableFormats.contains(format)) {
      throw const FormatException(
        'The selected export format is unavailable for this media file.',
      );
    }

    final dimensions = _validateDimensions(source, width, height);
    if (format == MediaExportFormat.jpeg &&
        (jpegQuality < 1 || jpegQuality > 100)) {
      throw const FormatException('JPEG quality must be between 1 and 100.');
    }
    final output = await AppIOServices(
      dir: destinationDirectory,
      fileStem: stem,
      ext: format.extension(source.originalExtension),
    ).getSavePath();

    if (format == MediaExportFormat.original) {
      final copied = await source.file.copy(output.path);
      return MediaExportResult(
        file: copied,
        bytes: await copied.length(),
        width: source.imageInfo?.width,
        height: source.imageInfo?.height,
        resized: false,
      );
    }

    final converted = await _convertImage(
      inputPath: source.file.path,
      outputPath: output.path,
      outputFormat: _rustFormat(format),
      resizeWidth: dimensions?.width,
      resizeHeight: dimensions?.height,
      jpegQuality: jpegQuality,
    );
    return MediaExportResult(
      file: output,
      bytes: converted.bytes.toInt(),
      width: converted.width,
      height: converted.height,
      resized: converted.resized,
    );
  }

  ImagePixelDimensions? _validateDimensions(
    MediaExportSource source,
    int? width,
    int? height,
  ) {
    if (width == null && height == null) return null;
    if (width == null || height == null) {
      throw const FormatException('Resize requires both width and height.');
    }
    final info = source.imageInfo;
    if (info == null) {
      throw const FormatException('This media file cannot be resized.');
    }
    if (width < 1 || height < 1) {
      throw const FormatException('Image dimensions must be positive.');
    }
    if (width > info.width || height > info.height) {
      throw const FormatException(
        'Image dimensions cannot exceed the original size.',
      );
    }
    return ImagePixelDimensions(width: width, height: height);
  }

  rust_images.ImageExportFormat _rustFormat(MediaExportFormat format) {
    return switch (format) {
      MediaExportFormat.jpeg => rust_images.ImageExportFormat.jpeg,
      MediaExportFormat.png => rust_images.ImageExportFormat.png,
      MediaExportFormat.webp => rust_images.ImageExportFormat.webP,
      MediaExportFormat.original => throw const FormatException(
        'Original files do not require image conversion.',
      ),
    };
  }

  Future<List<File>> _stageBatchItemsInParallel({
    required List<PreparedMediaBatchItem> items,
    required MediaBatchExportOptions options,
    required Directory staging,
    required Map<String, Set<String>> namesByCategory,
    required List<MediaBatchWarning> warnings,
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final stagedFiles = <File>[];
    final conversions = <String, _PendingImageConversion>{};
    for (final item in items) {
      cancel?.throwIfCancelled();
      progress?.setCurrentItem(item.fileName);
      try {
        if (!await item.file.exists()) {
          throw const FileSystemException('Source file no longer exists.');
        }
        final requestedConversion = item.kind == MediaKind.image;
        if (!item.canConvertImage || !requestedConversion) {
          if (requestedConversion) {
            warnings.add(
              MediaBatchWarning(
                fileName: item.fileName,
                message:
                    '${item.originalExtension.toUpperCase()} cannot be '
                    'converted and was exported in its original format.',
              ),
            );
          }
          stagedFiles.add(
            await _copyOriginalToStaging(
              item: item,
              staging: staging,
              namesByCategory: namesByCategory,
            ),
          );
          progress?.advanceItem(bytes: item.sourceBytes);
          continue;
        }

        try {
          await _inspectImage(inputPath: item.file.path);
        } catch (error) {
          warnings.add(
            MediaBatchWarning(
              fileName: item.fileName,
              message:
                  'This image cannot be converted and was exported in its '
                  'original format: $error',
            ),
          );
          stagedFiles.add(
            await _copyOriginalToStaging(
              item: item,
              staging: staging,
              namesByCategory: namesByCategory,
            ),
          );
          progress?.advanceItem(bytes: item.sourceBytes);
          continue;
        }

        final extension = options.imageFormat.extension(item.originalExtension);
        final target = _batchTarget(
          staging: staging,
          category: item.categoryFolder,
          requestedName:
              '${path.basenameWithoutExtension(item.fileName)}.$extension',
          namesByCategory: namesByCategory,
        );
        await target.parent.create(recursive: true);
        final maxPixels = options.maxLongSidePixels;
        conversions[target.path] = _PendingImageConversion(
          item: item,
          target: target,
          request: rust_images.BatchImageExportRequest(
            inputPath: item.file.path,
            outputPath: target.path,
            outputFormat: _rustFormat(options.imageFormat),
            resizeWidth: maxPixels,
            resizeHeight: maxPixels,
            jpegQuality: options.jpegQuality,
          ),
        );
      } on ExportCancelledException {
        rethrow;
      } catch (error) {
        warnings.add(
          MediaBatchWarning(
            fileName: item.fileName,
            message: 'Skipped because processing failed: $error',
          ),
        );
        progress?.advanceItem(bytes: item.sourceBytes);
      }
    }

    cancel?.throwIfCancelled();
    if (conversions.isEmpty) return stagedFiles;
    final completed = <String>{};
    await for (final event in _convertImages!(
      requests: conversions.values
          .map((conversion) => conversion.request)
          .toList(growable: false),
    )) {
      final conversion = conversions[event.outputPath];
      if (conversion == null || !completed.add(event.outputPath)) {
        throw StateError(
          'Parallel image conversion returned an unexpected output path.',
        );
      }
      progress?.setCurrentItem(conversion.item.fileName);
      if (event.error == null && await conversion.target.exists()) {
        stagedFiles.add(conversion.target);
      } else {
        if (await conversion.target.exists()) await conversion.target.delete();
        warnings.add(
          MediaBatchWarning(
            fileName: conversion.item.fileName,
            message:
                'Skipped because processing failed: '
                '${event.error ?? 'No converted file was created.'}',
          ),
        );
      }
      progress?.advanceItem(bytes: conversion.item.sourceBytes);
    }
    if (completed.length != conversions.length) {
      throw StateError(
        'Parallel image conversion stopped before every file completed.',
      );
    }
    cancel?.throwIfCancelled();
    return stagedFiles;
  }

  Future<File?> _stageBatchItem({
    required PreparedMediaBatchItem item,
    required MediaBatchExportOptions options,
    required Directory staging,
    required Map<String, Set<String>> namesByCategory,
    required List<MediaBatchWarning> warnings,
  }) async {
    if (!await item.file.exists()) {
      throw const FileSystemException('Source file no longer exists.');
    }
    final requestedConversion =
        item.kind == MediaKind.image &&
        options.imageFormat != MediaExportFormat.original;
    final shouldConvert = item.canConvertImage && requestedConversion;
    if (!shouldConvert) {
      if (requestedConversion) {
        warnings.add(
          MediaBatchWarning(
            fileName: item.fileName,
            message:
                '${item.originalExtension.toUpperCase()} cannot be converted '
                'and was exported in its original format.',
          ),
        );
      }
      return _copyOriginalToStaging(
        item: item,
        staging: staging,
        namesByCategory: namesByCategory,
      );
    }

    try {
      await _inspectImage(inputPath: item.file.path);
    } catch (error) {
      warnings.add(
        MediaBatchWarning(
          fileName: item.fileName,
          message:
              'This image cannot be converted and was exported in its '
              'original format: $error',
        ),
      );
      return _copyOriginalToStaging(
        item: item,
        staging: staging,
        namesByCategory: namesByCategory,
      );
    }

    final extension = options.imageFormat.extension(item.originalExtension);
    final target = _batchTarget(
      staging: staging,
      category: item.categoryFolder,
      requestedName:
          '${path.basenameWithoutExtension(item.fileName)}.$extension',
      namesByCategory: namesByCategory,
    );
    await target.parent.create(recursive: true);
    final maxPixels = options.maxLongSidePixels;
    try {
      await _convertImage(
        inputPath: item.file.path,
        outputPath: target.path,
        outputFormat: _rustFormat(options.imageFormat),
        resizeWidth: maxPixels,
        resizeHeight: maxPixels,
        jpegQuality: options.jpegQuality,
      );
      return target;
    } catch (_) {
      if (await target.exists()) await target.delete();
      rethrow;
    }
  }

  Future<File> _copyOriginalToStaging({
    required PreparedMediaBatchItem item,
    required Directory staging,
    required Map<String, Set<String>> namesByCategory,
  }) async {
    final target = _batchTarget(
      staging: staging,
      category: item.categoryFolder,
      requestedName: item.fileName,
      namesByCategory: namesByCategory,
    );
    await target.parent.create(recursive: true);
    try {
      return await item.file.copy(target.path);
    } catch (_) {
      if (await target.exists()) await target.delete();
      rethrow;
    }
  }

  File _batchTarget({
    required Directory staging,
    required String category,
    required String requestedName,
    required Map<String, Set<String>> namesByCategory,
  }) {
    final usedNames = namesByCategory.putIfAbsent(category, () => <String>{});
    final extension = path.extension(requestedName);
    final stem = path.basenameWithoutExtension(requestedName);
    var candidate = requestedName;
    var suffix = 1;
    while (!usedNames.add(candidate.toLowerCase())) {
      candidate = '$stem($suffix)$extension';
      suffix++;
    }
    return File(path.join(staging.path, category, candidate));
  }

  Future<File> _resolveMediaFile(MediaData media, String fileName) async {
    final category = matchMediaCategoryString(media.category ?? '');
    final imageServices = ImageServices(ref: ref, category: category);
    if (category == MediaCategory.personnel) {
      return imageServices.getPersonnelMediaPath(fileName);
    }
    return imageServices.getProjectMediaPath(fileName, media.projectUuid ?? '');
  }

  void _validateBatchOptions(
    PreparedMediaBatch batch,
    MediaBatchExportOptions options,
    String fileStem,
  ) {
    if (batch.items.isEmpty) {
      throw MediaBatchExportAllFilesFailedException(batch.warnings);
    }
    if (fileStem.trim().isEmpty) {
      throw const FormatException('Enter a file name.');
    }
    if (options.imageFormat == MediaExportFormat.original &&
        options.maxLongSidePixels != null) {
      throw const FormatException(
        'Original images cannot use a maximum pixel size.',
      );
    }
    final maxPixels = options.maxLongSidePixels;
    if (maxPixels != null && (maxPixels < 1 || maxPixels > 0xffffffff)) {
      throw const FormatException(
        'Maximum width or height must be a positive pixel value.',
      );
    }
    if (options.jpegQuality < 1 || options.jpegQuality > 100) {
      throw const FormatException('JPEG quality must be between 1 and 100.');
    }
  }

  Future<void> _deleteIncompleteOutput(File? output) async {
    if (output == null) return;
    try {
      if (await output.exists()) await output.delete();
    } on FileSystemException {
      // The primary export error is more useful than a cleanup failure.
    }
  }

  String _safeArchiveStem(String value) {
    final withoutExtension = value.trim().replaceFirst(
      RegExp(r'\.(zip|tar\.gz)$', caseSensitive: false),
      '',
    );
    final cleaned = path
        .basename(withoutExtension)
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'nahpu-media' : cleaned;
  }

  static int _compareMedia(MediaData first, MediaData second) {
    final category = _categoryFolder(
      first.category,
    ).compareTo(_categoryFolder(second.category));
    if (category != 0) return category;
    final fileName = (first.fileName ?? '').toLowerCase().compareTo(
      (second.fileName ?? '').toLowerCase(),
    );
    if (fileName != 0) return fileName;
    return first.primaryId.compareTo(second.primaryId);
  }

  static String _categoryFolder(String? category) => switch (category) {
    'site' => 'site',
    'event' => 'event',
    'specimen' => 'specimen',
    'narrative' => 'narrative',
    _ => 'other',
  };
}

class _PendingImageConversion {
  const _PendingImageConversion({
    required this.item,
    required this.target,
    required this.request,
  });

  final PreparedMediaBatchItem item;
  final File target;
  final rust_images.BatchImageExportRequest request;
}

ImagePixelDimensions dimensionsForWidth({
  required int originalWidth,
  required int originalHeight,
  required int width,
}) {
  final safeWidth = width.clamp(1, originalWidth);
  final height = (safeWidth * originalHeight / originalWidth).round().clamp(
    1,
    originalHeight,
  );
  return ImagePixelDimensions(width: safeWidth, height: height);
}

ImagePixelDimensions dimensionsForHeight({
  required int originalWidth,
  required int originalHeight,
  required int height,
}) {
  final safeHeight = height.clamp(1, originalHeight);
  final width = (safeHeight * originalWidth / originalHeight).round().clamp(
    1,
    originalWidth,
  );
  return ImagePixelDimensions(width: width, height: safeHeight);
}
