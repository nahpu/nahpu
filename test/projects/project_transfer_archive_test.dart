import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/services/project_transfer/project_transfer_service.dart';
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tempDir.path,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
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

  testWidgets('project importer accepts a NAHPU Data Package', (tester) async {
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
    final staging = Directory('${tempDir.path}/package')..createSync();
    final project = File('${staging.path}/nahpu-project.json')
      ..writeAsStringSync(
        ProjectTransferPayload(
          exportedAt: '2026-01-01T00:00:00Z',
          appVersion: '1.0.0+1',
          databaseVersion: 14,
          project: const {'uuid': 'project-a', 'name': 'Project A'},
          records: const {},
        ).encoded,
      );
    final descriptor = File('${staging.path}/datapackage.json')
      ..writeAsStringSync('{"profile":"data-package"}');
    final archive = File('${tempDir.path}/project.nahpu-dp.zip');
    final opened = (await tester.runAsync(() async {
      final writer = await ZipWriter.newInstance(
        parentDir: staging.path,
        files: [project.path, descriptor.path],
        outputPath: archive.path,
      );
      await writer.write();
      return ProjectTransferArchiveService(
        ref: widgetRef!,
      ).read(XFile(archive.path));
    }))!;
    addTearDown(opened.dispose);

    expect(opened.payload.sourceProjectUuid, 'project-a');
    expect(opened.payload.projectName, 'Project A');
  });
}
