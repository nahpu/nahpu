import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/src/rust/api/images.dart' as rust_images;
import 'package:path/path.dart' as path;

const Set<String> convertibleImageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

enum MediaExportFormat { original, jpeg, png, webp }

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

class MediaExportService extends AppServices {
  MediaExportService({
    required super.ref,
    InspectImageCallback? inspectImage,
    ConvertImageCallback? convertImage,
  }) : _inspectImage = inspectImage ?? rust_images.inspectImage,
       _convertImage = convertImage ?? rust_images.exportImage;

  final InspectImageCallback _inspectImage;
  final ConvertImageCallback _convertImage;

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
