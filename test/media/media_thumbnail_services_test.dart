import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/media/media_thumbnail_services.dart';
import 'package:path/path.dart' as p;

import '../helpers/rust_library.dart';

void main() {
  late Directory tempDir;
  late Directory cacheRoot;
  late File source;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nahpu-thumbnail-test');
    cacheRoot = Directory(p.join(tempDir.path, 'cache'));
    source = File(p.join(tempDir.path, 'bat-12.jpg'))
      ..writeAsBytesSync([1, 2, 3]);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  MediaThumbnailServices services({
    ThumbnailGenerator? generator,
    int maxConcurrent = 4,
  }) {
    return MediaThumbnailServices(
      cacheRoot: () async => cacheRoot,
      maxConcurrent: maxConcurrent,
      generator: generator ?? (source, target) => target.writeAsBytes([9, 9]),
    );
  }

  test('cache name changes with source modification time and size', () {
    final base = MediaThumbnailServices.cacheFileName(
      'bat.jpg',
      modifiedMs: 1,
      bytes: 10,
    );
    expect(base, 'bat_1_10.jpg');
    expect(
      MediaThumbnailServices.cacheFileName('bat.jpg', modifiedMs: 2, bytes: 10),
      isNot(base),
    );
    expect(
      MediaThumbnailServices.cacheFileName('bat.jpg', modifiedMs: 1, bytes: 11),
      isNot(base),
    );
  });

  test('generates once and reuses the cached thumbnail', () async {
    var calls = 0;
    final thumbnails = services(
      generator: (source, target) async {
        calls++;
        await target.writeAsBytes([9]);
      },
    );

    final results = await Future.wait([
      thumbnails.thumbnailFor(source, projectUuid: 'p1', category: 'site'),
      thumbnails.thumbnailFor(source, projectUuid: 'p1', category: 'site'),
    ]);
    final again = await thumbnails.thumbnailFor(
      source,
      projectUuid: 'p1',
      category: 'site',
    );

    expect(calls, 1);
    expect(results[0]!.path, results[1]!.path);
    expect(again!.path, results[0]!.path);
    expect(p.isWithin(cacheRoot.path, again.path), isTrue);
    expect(await again.exists(), isTrue);
  });

  test(
    'returns null and leaves no partial file when generation fails',
    () async {
      final thumbnails = services(
        generator: (source, target) async {
          await target.writeAsBytes([1]);
          throw Exception('unsupported image');
        },
      );

      final result = await thumbnails.thumbnailFor(
        source,
        projectUuid: 'p1',
        category: 'site',
      );

      expect(result, isNull);
      final dir = Directory(p.join(cacheRoot.path, 'p1', 'site'));
      expect(dir.listSync(), isEmpty);
    },
  );

  test('limits concurrent generation', () async {
    var running = 0;
    var peak = 0;
    final gate = Completer<void>();
    final thumbnails = services(
      maxConcurrent: 2,
      generator: (source, target) async {
        running++;
        peak = running > peak ? running : peak;
        await gate.future;
        await target.writeAsBytes([1]);
        running--;
      },
    );
    final sources = [
      for (var index = 0; index < 5; index++)
        File(p.join(tempDir.path, 'image$index.jpg'))
          ..writeAsBytesSync([index]),
    ];

    final pending = Future.wait([
      for (final file in sources)
        thumbnails.thumbnailFor(file, projectUuid: 'p1', category: 'site'),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    gate.complete();
    final results = await pending;

    expect(peak, 2);
    expect(results.whereType<File>(), hasLength(5));
  });

  test(
    'deleteFor removes only that file and deleteProject clears all',
    () async {
      final thumbnails = services();
      final other = File(p.join(tempDir.path, 'bat-12_extra.jpg'))
        ..writeAsBytesSync([4]);
      final bat = await thumbnails.thumbnailFor(
        source,
        projectUuid: 'p1',
        category: 'site',
      );
      final extra = await thumbnails.thumbnailFor(
        other,
        projectUuid: 'p1',
        category: 'site',
      );

      await thumbnails.deleteFor(
        projectUuid: 'p1',
        category: 'site',
        fileName: 'bat-12.jpg',
      );
      expect(await bat!.exists(), isFalse);
      expect(await extra!.exists(), isTrue);

      await thumbnails.deleteProject('p1');
      expect(await Directory(p.join(cacheRoot.path, 'p1')).exists(), isFalse);
    },
  );

  test('default generator writes a JPEG through the Rust bridge', () async {
    await initRustLibForTest();
    final png = File(p.join(tempDir.path, 'pixel.png'))
      ..writeAsBytesSync(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
          'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        ),
      );
    final thumbnails = MediaThumbnailServices(cacheRoot: () async => cacheRoot);

    final thumbnail = await thumbnails.thumbnailFor(
      png,
      projectUuid: 'p1',
      category: 'site',
    );

    expect(thumbnail, isNotNull);
    expect(thumbnail!.readAsBytesSync().take(2), [0xFF, 0xD8]);
  });
}
