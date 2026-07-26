import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:nahpu/src/rust/frb_generated.dart';

void main() {
  late Directory tempDir;

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
    tempDir = Directory.systemTemp.createTempSync(
      'nahpu-project-transfer-archive-test-',
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('Rust gzip bridge round-trips a project manifest', () async {
    final input = File('${tempDir.path}/nahpu-project.json')
      ..writeAsStringSync('{"nahpu_project":"project"}');
    final compressed = File('${tempDir.path}/project.json.gz');
    final output = File('${tempDir.path}/restored.json');

    final writer = await GzipWriter.newInstance(
      inputPath: input.path,
      outputPath: compressed.path,
    );
    await writer.write();

    final extractor = await GzipExtractor.newInstance(
      archivePath: compressed.path,
      outputPath: output.path,
    );
    await extractor.extract();

    expect(compressed.existsSync(), isTrue);
    expect(output.readAsStringSync(), input.readAsStringSync());
  });
}
