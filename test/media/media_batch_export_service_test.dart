import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/media/media_export_service.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:nahpu/src/rust/api/images.dart' as rust_images;
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:path/path.dart' as path;

const _projectUuid = 'batch-media-project';
final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
  'AAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory appDirectory;
  late Directory exportDirectory;

  setUpAll(() async {
    final dylibPath = Platform.isMacOS
        ? 'rust/target/debug/librust_lib_nahpu.dylib'
        : Platform.isWindows
        ? 'rust/target/debug/rust_lib_nahpu.dll'
        : 'rust/target/debug/librust_lib_nahpu.so';
    await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
  });

  setUp(() {
    appDirectory = Directory.systemTemp.createTempSync('nahpu-batch-media-');
    exportDirectory = Directory.systemTemp.createTempSync(
      'nahpu-batch-media-output-',
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

  testWidgets(
    'ZIP converts supported images, preserves other media, and reports progress',
    (tester) async {
      final ref = await _widgetRef(tester);
      final media = [
        _writeMedia(appDirectory, 1, 'site', 'photo.jpg', [1, 2]),
        _writeMedia(appDirectory, 2, 'site', 'photo.png', [3, 4]),
        _writeMedia(appDirectory, 3, 'event', 'sound.mp3', [9, 8]),
        _writeMedia(appDirectory, 4, 'specimen', 'clip.mp4', [7, 6]),
        _writeMedia(appDirectory, 5, 'narrative', 'legacy.gif', [5, 4]),
      ];
      final resizeBounds = <(int?, int?)>[];
      final qualities = <int>[];
      final completionOrder = <String>[];
      final service = MediaExportService(
        ref: ref,
        inspectImage: ({required inputPath}) async =>
            const rust_images.ImageSourceInfo(
              format: rust_images.ImageExportFormat.png,
              width: 800,
              height: 400,
            ),
        convertImages: ({required requests}) async* {
          for (final request in requests.reversed) {
            resizeBounds.add((request.resizeWidth, request.resizeHeight));
            qualities.add(request.jpegQuality);
            completionOrder.add(path.basename(request.outputPath));
            final bytes = utf8.encode(
              'converted:${path.basename(request.inputPath)}',
            );
            await File(request.outputPath).writeAsBytes(bytes);
            yield rust_images.BatchImageExportEvent(
              outputPath: request.outputPath,
              width: 320,
              height: 160,
              bytes: BigInt.from(bytes.length),
              resized: true,
            );
          }
        },
      );
      final batch = await tester.runAsync(() => service.prepareBatch(media));
      final reporter = ExportProgressReporter(
        steps: MediaExportService.batchExportPhases(batch!),
      );
      final phases = <ExportPhase>[];
      ExportJobProgress? last;
      reporter.stream.listen((progress) {
        last = progress;
        final phase = progress.activeStep?.phase;
        if (phase != null && (phases.isEmpty || phases.last != phase)) {
          phases.add(phase);
        }
      });

      final result = await tester.runAsync(() async {
        final result = await service.exportBatch(
          batch: batch,
          options: const MediaBatchExportOptions(
            archiveFormat: MediaBatchArchiveFormat.zip,
            imageFormat: MediaExportFormat.jpeg,
            maxLongSidePixels: 320,
            jpegQuality: 91,
          ),
          fileStem: 'selected-media',
          destinationDirectory: exportDirectory,
          progress: reporter,
        );
        await Future<void>.delayed(Duration.zero);
        return result;
      });
      await tester.runAsync(reporter.dispose);

      expect(result!.file.path, endsWith('selected-media.zip'));
      expect(result.exportedCount, 5);
      expect(result.skippedCount, 0);
      expect(resizeBounds, [(320, 320), (320, 320)]);
      expect(qualities, [91, 91]);
      expect(completionOrder, ['photo(1).jpg', 'photo.jpg']);
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.fileName, 'legacy.gif');
      expect(phases, [ExportPhase.processingFiles, ExportPhase.compressing]);
      expect(last!.overallFraction, 1);

      final extracted = (await tester.runAsync(
        () => _extract(result.file, MediaBatchArchiveFormat.zip),
      ))!;
      addTearDown(() => extracted.delete(recursive: true));
      expect(_relativeFiles(extracted), [
        'event/sound.mp3',
        'narrative/legacy.gif',
        'site/photo(1).jpg',
        'site/photo.jpg',
        'specimen/clip.mp4',
      ]);
      expect(
        File(path.join(extracted.path, 'event', 'sound.mp3')).readAsBytesSync(),
        [9, 8],
      );
      expect(
        File(
          path.join(extracted.path, 'specimen', 'clip.mp4'),
        ).readAsBytesSync(),
        [7, 6],
      );
      expect(
        File(
          path.join(extracted.path, 'narrative', 'legacy.gif'),
        ).readAsBytesSync(),
        [5, 4],
      );
      _expectNoStagingDirectories(appDirectory);
    },
  );

  testWidgets('TAR.GZ keeps Original images byte-for-byte', (tester) async {
    final ref = await _widgetRef(tester);
    final media = [
      _writeMedia(appDirectory, 1, 'site', 'photo.png', [1, 3, 5, 7]),
      _writeMedia(appDirectory, 2, 'event', 'sound.wav', [2, 4, 6]),
    ];
    final service = MediaExportService(
      ref: ref,
      inspectImage: ({required inputPath}) async =>
          throw StateError('Original export must not inspect images'),
      convertImage:
          ({
            required inputPath,
            required outputPath,
            required outputFormat,
            resizeWidth,
            resizeHeight,
            required jpegQuality,
          }) async => throw StateError('Original export must not convert'),
    );
    final batch = await tester.runAsync(() => service.prepareBatch(media));
    final result = await tester.runAsync(() async {
      final result = await service.exportBatch(
        batch: batch!,
        options: const MediaBatchExportOptions(
          archiveFormat: MediaBatchArchiveFormat.tarGzip,
          imageFormat: MediaExportFormat.original,
        ),
        fileStem: 'original-media',
        destinationDirectory: exportDirectory,
      );
      await Future<void>.delayed(Duration.zero);
      return result;
    });

    final extracted = (await tester.runAsync(
      () => _extract(result!.file, MediaBatchArchiveFormat.tarGzip),
    ))!;
    addTearDown(() => extracted.delete(recursive: true));
    expect(_relativeFiles(extracted), ['event/sound.wav', 'site/photo.png']);
    expect(
      File(path.join(extracted.path, 'site', 'photo.png')).readAsBytesSync(),
      [1, 3, 5, 7],
    );
    expect(result!.warnings, isEmpty);
  });

  testWidgets('WebP batch export writes decodable images through Rust batch', (
    tester,
  ) async {
    final ref = await _widgetRef(tester);
    final media = [
      for (var id = 1; id <= 3; id++)
        _writeMedia(appDirectory, id, 'site', 'photo$id.png', _pngBytes),
    ];
    final service = MediaExportService(ref: ref);
    final batch = await tester.runAsync(() => service.prepareBatch(media));
    final result = await tester.runAsync(
      () => service.exportBatch(
        batch: batch!,
        options: const MediaBatchExportOptions(
          archiveFormat: MediaBatchArchiveFormat.zip,
          imageFormat: MediaExportFormat.webp,
        ),
        fileStem: 'webp-media',
        destinationDirectory: exportDirectory,
      ),
    );

    final extracted = (await tester.runAsync(
      () => _extract(result!.file, MediaBatchArchiveFormat.zip),
    ))!;
    addTearDown(() => extracted.delete(recursive: true));
    expect(result!.exportedCount, 3);
    for (var id = 1; id <= 3; id++) {
      final webp = File(path.join(extracted.path, 'site', 'photo$id.webp'));
      expect(webp.existsSync(), isTrue);
      final info = await tester.runAsync(
        () => rust_images.inspectImage(inputPath: webp.path),
      );
      expect(info!.format, rust_images.ImageExportFormat.webP);
      expect((info.width, info.height), (1, 1));
    }
  });

  testWidgets(
    'best effort skips stale and failed files but archives successes',
    (tester) async {
      final ref = await _widgetRef(tester);
      final stale = _writeMedia(appDirectory, 1, 'site', 'stale.png', [1]);
      final broken = _writeMedia(appDirectory, 2, 'site', 'broken.jpg', [2]);
      final audio = _writeMedia(appDirectory, 3, 'event', 'sound.mp3', [3]);
      final service = MediaExportService(
        ref: ref,
        inspectImage: ({required inputPath}) async =>
            const rust_images.ImageSourceInfo(
              format: rust_images.ImageExportFormat.jpeg,
              width: 10,
              height: 10,
            ),
        convertImages: ({required requests}) async* {
          for (final request in requests) {
            yield rust_images.BatchImageExportEvent(
              outputPath: request.outputPath,
              resized: false,
              error: 'decode failed',
            );
          }
        },
      );
      final batch = await tester.runAsync(
        () => service.prepareBatch([stale, broken, audio]),
      );
      final preparedBatch = batch!;
      await tester.runAsync(
        () => File(
          preparedBatch.items
              .firstWhere((item) => item.media.primaryId == 1)
              .file
              .path,
        ).delete(),
      );

      final result = await tester.runAsync(() async {
        final result = await service.exportBatch(
          batch: preparedBatch,
          options: const MediaBatchExportOptions(
            archiveFormat: MediaBatchArchiveFormat.zip,
            imageFormat: MediaExportFormat.webp,
          ),
          fileStem: 'best-effort',
          destinationDirectory: exportDirectory,
        );
        await Future<void>.delayed(Duration.zero);
        return result;
      });

      expect(result!.exportedCount, 1);
      expect(result.skippedCount, 2);
      expect(result.warnings, hasLength(2));
      expect(
        result.warnings.map((warning) => warning.fileName),
        containsAll(['stale.png', 'broken.jpg']),
      );
      final extracted = (await tester.runAsync(
        () => _extract(result.file, MediaBatchArchiveFormat.zip),
      ))!;
      addTearDown(() => extracted.delete(recursive: true));
      expect(_relativeFiles(extracted), ['event/sound.mp3']);
    },
  );

  testWidgets('all failed files and cancellation leave no archive or staging', (
    tester,
  ) async {
    final ref = await _widgetRef(tester);
    final media = _writeMedia(appDirectory, 1, 'event', 'sound.mp3', [1]);
    final service = MediaExportService(ref: ref);
    final batch = await tester.runAsync(() => service.prepareBatch([media]));
    await tester.runAsync(batch!.items.single.file.delete);

    await tester.runAsync(() async {
      await expectLater(
        service.exportBatch(
          batch: batch,
          options: const MediaBatchExportOptions(
            archiveFormat: MediaBatchArchiveFormat.zip,
            imageFormat: MediaExportFormat.original,
          ),
          fileStem: 'all-failed',
          destinationDirectory: exportDirectory,
        ),
        throwsA(isA<MediaBatchExportAllFilesFailedException>()),
      );
    });
    expect(exportDirectory.listSync(), isEmpty);
    _expectNoStagingDirectories(appDirectory);

    final replacement = _writeMedia(
      appDirectory,
      2,
      'event',
      'replacement.mp3',
      [2],
    );
    final cancelBatch = await tester.runAsync(
      () => service.prepareBatch([replacement]),
    );
    final cancellation = ExportCancellation()..cancel();
    await tester.runAsync(() async {
      await expectLater(
        service.exportBatch(
          batch: cancelBatch!,
          options: const MediaBatchExportOptions(
            archiveFormat: MediaBatchArchiveFormat.tarGzip,
            imageFormat: MediaExportFormat.original,
          ),
          fileStem: 'cancelled',
          destinationDirectory: exportDirectory,
          cancel: cancellation,
        ),
        throwsA(isA<ExportCancelledException>()),
      );
    });
    expect(exportDirectory.listSync(), isEmpty);
    _expectNoStagingDirectories(appDirectory);
  });

  testWidgets('parallel cancellation waits for workers before cleanup', (
    tester,
  ) async {
    final ref = await _widgetRef(tester);
    final cancellation = ExportCancellation();
    var completions = 0;
    final service = MediaExportService(
      ref: ref,
      inspectImage: ({required inputPath}) async =>
          const rust_images.ImageSourceInfo(
            format: rust_images.ImageExportFormat.png,
            width: 10,
            height: 10,
          ),
      convertImages: ({required requests}) async* {
        for (final request in requests) {
          await File(request.outputPath).writeAsBytes([1, 2, 3]);
          completions++;
          if (completions == 1) cancellation.cancel();
          yield rust_images.BatchImageExportEvent(
            outputPath: request.outputPath,
            width: 10,
            height: 10,
            bytes: BigInt.from(3),
            resized: false,
          );
        }
      },
    );
    final media = [
      _writeMedia(appDirectory, 1, 'site', 'one.png', [1]),
      _writeMedia(appDirectory, 2, 'site', 'two.png', [2]),
    ];
    final batch = await tester.runAsync(() => service.prepareBatch(media));

    await tester.runAsync(() async {
      await expectLater(
        service.exportBatch(
          batch: batch!,
          options: const MediaBatchExportOptions(
            archiveFormat: MediaBatchArchiveFormat.zip,
            imageFormat: MediaExportFormat.webp,
          ),
          fileStem: 'cancel-parallel',
          destinationDirectory: exportDirectory,
          cancel: cancellation,
        ),
        throwsA(isA<ExportCancelledException>()),
      );
    });
    expect(completions, 2);
    expect(exportDirectory.listSync(), isEmpty);
    _expectNoStagingDirectories(appDirectory);
  });
}

MediaData _writeMedia(
  Directory appDirectory,
  int id,
  String category,
  String fileName,
  List<int> bytes,
) {
  final file = File(
    path.join(
      appDirectory.path,
      nahpuAppDir,
      _projectUuid,
      mediaDir,
      category,
      fileName,
    ),
  );
  file.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  return MediaData(
    primaryId: id,
    projectUuid: _projectUuid,
    category: category,
    fileName: fileName,
  );
}

Future<Directory> _extract(File archive, MediaBatchArchiveFormat format) async {
  final directory = Directory.systemTemp.createTempSync(
    'nahpu-batch-media-extracted-',
  );
  if (format == MediaBatchArchiveFormat.zip) {
    final extractor = await ZipExtractor.newInstance(
      archivePath: archive.path,
      outputDir: directory.path,
    );
    await extractor.extract();
  } else {
    final extractor = await TarGzipExtractor.newInstance(
      archivePath: archive.path,
      outputDir: directory.path,
    );
    await extractor.extract();
  }
  return directory;
}

List<String> _relativeFiles(Directory directory) {
  final files = directory
      .listSync(recursive: true)
      .whereType<File>()
      .map(
        (file) => path
            .relative(file.path, from: directory.path)
            .replaceAll('\\', '/'),
      )
      .toList();
  files.sort();
  return files;
}

void _expectNoStagingDirectories(Directory root) {
  expect(
    root
        .listSync(recursive: true)
        .whereType<Directory>()
        .where(
          (directory) =>
              path.basename(directory.path).startsWith('media-export-'),
        ),
    isEmpty,
  );
}

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
