import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/media/media_export_service.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/src/rust/api/images.dart' as rust_images;
import 'package:path/path.dart' as path;

const _projectUuid = 'media-export-project';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory appDirectory;
  late Directory exportDirectory;

  setUp(() {
    appDirectory = Directory.systemTemp.createTempSync('nahpu-media-export-');
    exportDirectory = Directory.systemTemp.createTempSync(
      'nahpu-media-export-output-',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async {
          return appDirectory.path;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (appDirectory.existsSync()) {
      await appDirectory.delete(recursive: true);
    }
    if (exportDirectory.existsSync()) {
      await exportDirectory.delete(recursive: true);
    }
  });

  test('linked dimensions preserve aspect ratio without upscaling', () {
    expect(
      dimensionsForWidth(originalWidth: 800, originalHeight: 400, width: 200),
      isA<ImagePixelDimensions>()
          .having((value) => value.width, 'width', 200)
          .having((value) => value.height, 'height', 100),
    );
    expect(
      dimensionsForHeight(originalWidth: 800, originalHeight: 400, height: 900),
      isA<ImagePixelDimensions>()
          .having((value) => value.width, 'width', 800)
          .having((value) => value.height, 'height', 400),
    );
  });

  testWidgets(
    'prepares supported images and keeps unsupported images original-only',
    (tester) async {
      final ref = await _widgetRef(tester);
      final jpeg = _writeProjectMedia(appDirectory, 'photo.jpg', [1, 2, 3]);
      final gif = _writeProjectMedia(appDirectory, 'animation.gif', [4, 5, 6]);
      final webp = _writeProjectMedia(appDirectory, 'broken.webp', [7, 8, 9]);
      var inspections = 0;
      final service = MediaExportService(
        ref: ref,
        inspectImage: ({required inputPath}) async {
          inspections++;
          if (inputPath == webp.path) {
            throw const FormatException('animated or malformed WebP');
          }
          expect(inputPath, jpeg.path);
          return const rust_images.ImageSourceInfo(
            format: rust_images.ImageExportFormat.jpeg,
            width: 1200,
            height: 800,
          );
        },
      );

      final sources = await tester.runAsync(() async {
        return (
          jpeg: await service.prepare(_media('photo.jpg')),
          gif: await service.prepare(_media('animation.gif')),
          webp: await service.prepare(_media('broken.webp')),
        );
      });
      final jpegSource = sources!.jpeg;
      final gifSource = sources.gif;
      final webpSource = sources.webp;

      expect(inspections, 2);
      expect(jpegSource.availableFormats, MediaExportFormat.values);
      expect(jpegSource.imageInfo?.width, 1200);
      expect(gifSource.availableFormats, [MediaExportFormat.original]);
      expect(gifSource.conversionUnavailableReason, contains('GIF'));
      expect(gifSource.file.path, gif.path);
      expect(webpSource.availableFormats, [MediaExportFormat.original]);
      expect(webpSource.conversionUnavailableReason, contains('original'));
    },
  );

  testWidgets('copies originals byte-for-byte and avoids collisions', (
    tester,
  ) async {
    final ref = await _widgetRef(tester);
    final sourceFile = File(path.join(appDirectory.path, 'sound.mp3'))
      ..writeAsBytesSync([9, 8, 7, 6]);
    final source = MediaExportSource(
      file: sourceFile,
      kind: MediaKind.audio,
      originalExtension: 'mp3',
    );
    final service = MediaExportService(ref: ref);

    final outputs = await tester.runAsync(() async {
      return (
        first: await service.export(
          source: source,
          format: MediaExportFormat.original,
          fileStem: 'field-sound',
          destinationDirectory: exportDirectory,
        ),
        second: await service.export(
          source: source,
          format: MediaExportFormat.original,
          fileStem: 'field-sound',
          destinationDirectory: exportDirectory,
        ),
      );
    });
    final first = outputs!.first;
    final second = outputs.second;

    expect(first.file.readAsBytesSync(), [9, 8, 7, 6]);
    expect(first.file.path, endsWith('field-sound.mp3'));
    expect(second.file.path, endsWith('field-sound(1).mp3'));
    expect(first.resized, isFalse);
  });

  testWidgets('passes conversion settings to the Rust bridge callback', (
    tester,
  ) async {
    final ref = await _widgetRef(tester);
    final sourceFile = File(path.join(appDirectory.path, 'photo.png'))
      ..writeAsBytesSync([1, 2, 3]);
    final source = MediaExportSource(
      file: sourceFile,
      kind: MediaKind.image,
      originalExtension: 'png',
      imageInfo: const rust_images.ImageSourceInfo(
        format: rust_images.ImageExportFormat.png,
        width: 800,
        height: 400,
      ),
    );
    String? capturedOutputPath;
    rust_images.ImageExportFormat? capturedOutputFormat;
    int? requestedWidth;
    int? requestedHeight;
    int? requestedQuality;
    final service = MediaExportService(
      ref: ref,
      convertImage:
          ({
            required inputPath,
            required String outputPath,
            required rust_images.ImageExportFormat outputFormat,
            resizeWidth,
            resizeHeight,
            required jpegQuality,
          }) async {
            expect(inputPath, sourceFile.path);
            capturedOutputPath = outputPath;
            capturedOutputFormat = outputFormat;
            requestedWidth = resizeWidth;
            requestedHeight = resizeHeight;
            requestedQuality = jpegQuality;
            await File(outputPath).writeAsBytes([7, 7]);
            return rust_images.ImageExportResult(
              width: resizeWidth!,
              height: resizeHeight!,
              bytes: BigInt.from(2),
              resized: true,
            );
          },
    );

    final result = await tester.runAsync(
      () => service.export(
        source: source,
        format: MediaExportFormat.jpeg,
        fileStem: 'resized',
        destinationDirectory: exportDirectory,
        width: 400,
        height: 200,
        jpegQuality: 92,
      ),
    );

    expect(capturedOutputPath, endsWith('resized.jpg'));
    expect(capturedOutputFormat, rust_images.ImageExportFormat.jpeg);
    expect(requestedWidth, 400);
    expect(requestedHeight, 200);
    expect(requestedQuality, 92);
    expect(result!.bytes, 2);
    expect(result.resized, isTrue);
  });

  testWidgets('rejects resize dimensions larger than the source', (
    tester,
  ) async {
    final ref = await _widgetRef(tester);
    final sourceFile = File(path.join(appDirectory.path, 'photo.png'))
      ..writeAsBytesSync([1]);
    final source = MediaExportSource(
      file: sourceFile,
      kind: MediaKind.image,
      originalExtension: 'png',
      imageInfo: const rust_images.ImageSourceInfo(
        format: rust_images.ImageExportFormat.png,
        width: 800,
        height: 400,
      ),
    );

    final error = await tester.runAsync(() async {
      try {
        await MediaExportService(ref: ref).export(
          source: source,
          format: MediaExportFormat.png,
          fileStem: 'too-large',
          destinationDirectory: exportDirectory,
          width: 801,
          height: 401,
        );
      } catch (error) {
        return error;
      }
      return null;
    });
    expect(error, isA<FormatException>());
  });
}

File _writeProjectMedia(Directory appDirectory, String name, List<int> bytes) {
  final file = File(
    path.join(
      appDirectory.path,
      nahpuAppDir,
      _projectUuid,
      mediaDir,
      'site',
      name,
    ),
  );
  file.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  return file;
}

MediaData _media(String fileName) => MediaData(
  primaryId: 1,
  projectUuid: _projectUuid,
  category: 'site',
  fileName: fileName,
);

Future<WidgetRef> _widgetRef(WidgetTester tester) async {
  WidgetRef? widgetRef;
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, child) {
            widgetRef = ref;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return widgetRef!;
}
