import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/file_export_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:path/path.dart' as path;

/// Exercises the archive the explorer writes when a user moves files out of
/// the app folder. The safety property under test is that the originals are
/// never the caller's problem: the service only ever writes.
void main() {
  late Directory root;
  late Directory destination;

  // The archive writers live in Rust, so the bridge has to be up before any
  // export runs.
  setUpAll(() async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final dylibPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust/target/debug/rust_lib_nahpu.dll'
          : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    } else {
      await RustLib.init();
    }
  });

  setUp(() {
    root = Directory.systemTemp.createTempSync('nahpu-export-root');
    destination = Directory.systemTemp.createTempSync('nahpu-export-dest');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
    if (destination.existsSync()) destination.deleteSync(recursive: true);
  });

  File writeFile(List<String> segments, {String content = 'payload'}) {
    final file = File(path.join(root.path, path.joinAll(segments)));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    return file;
  }

  for (final format in DbArchiveFormat.values) {
    test(
      'writes a ${format.extension} archive and keeps the originals',
      () async {
        final first = writeFile(['project-a', 'media', 'specimen', 'one.jpg']);
        final second = writeFile(['backup', 'old.sqlite3']);

        final result = await const SelectionExportService().export(
          root: root.path,
          paths: [first.path, second.path],
          destination: destination,
          format: format,
        );

        expect(result.archive.existsSync(), isTrue);
        expect(path.basename(result.archive.path), endsWith(format.extension));
        expect(result.fileCount, 2);
        expect(result.sizeBytes, greaterThan(0));
        expect(result.exportedPaths, containsAll([first.path, second.path]));

        // Export writes; removal is a separate, later decision.
        expect(first.existsSync(), isTrue);
        expect(second.existsSync(), isTrue);
      },
    );
  }

  test('refuses a file outside the application folder', () async {
    final outside = File(path.join(destination.path, 'stray.jpg'))
      ..writeAsStringSync('x');

    await expectLater(
      const SelectionExportService().export(
        root: root.path,
        paths: [outside.path],
        destination: destination,
        format: DbArchiveFormat.zip,
      ),
      throwsFormatException,
    );
    expect(outside.existsSync(), isTrue);
  });

  test('refuses an empty selection', () async {
    await expectLater(
      const SelectionExportService().export(
        root: root.path,
        paths: const [],
        destination: destination,
        format: DbArchiveFormat.zip,
      ),
      throwsFormatException,
    );
  });

  test('refuses when every selected file has already gone', () async {
    final missing = path.join(root.path, 'project-a', 'gone.jpg');

    await expectLater(
      const SelectionExportService().export(
        root: root.path,
        paths: [missing],
        destination: destination,
        format: DbArchiveFormat.zip,
      ),
      throwsFormatException,
    );
    // Nothing half-written is left for the user to find.
    expect(destination.listSync(), isEmpty);
  });

  test('a second export does not overwrite the first', () async {
    final file = writeFile(['project-a', 'media', 'site', 'one.jpg']);
    const service = SelectionExportService();

    final first = await service.export(
      root: root.path,
      paths: [file.path],
      destination: destination,
      format: DbArchiveFormat.zip,
    );
    final second = await service.export(
      root: root.path,
      paths: [file.path],
      destination: destination,
      format: DbArchiveFormat.zip,
    );

    expect(first.archive.path, isNot(second.archive.path));
    expect(first.archive.existsSync(), isTrue);
    expect(second.archive.existsSync(), isTrue);
  });

  test('uses a caller-provided filename stem', () async {
    final file = writeFile(['project-a', 'media', 'site', 'one.jpg']);

    final result = await const SelectionExportService().export(
      root: root.path,
      paths: [file.path],
      destination: destination,
      format: DbArchiveFormat.tarGzip,
      fileStem: 'selected-media-2026-08-29',
    );

    expect(
      path.basename(result.archive.path),
      'selected-media-2026-08-29.tar.gz',
    );
  });
}
