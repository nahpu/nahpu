import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/projects/project_transfer_service.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:path/path.dart' as path;

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

  testWidgets('project export reports its stages in order', (tester) async {
    final widgetRef = await _pumpRef(tester);
    final media = _writeMediaFiles(tempDir, 3);
    final payload = _payloadWithMedia(media);
    final reporter = ExportProgressReporter(
      steps: ProjectTransferArchiveService.exportPhases(
        payload,
        ProjectTransferArchiveFormat.zip,
      ),
    );
    final phases = <ExportPhase>[];
    final compressionSnapshots = <ExportPhaseDetail>[];
    ExportJobProgress? last;
    reporter.stream.listen((progress) {
      last = progress;
      final phase = progress.activeStep?.phase;
      if (phase != null && (phases.isEmpty || phases.last != phase)) {
        phases.add(phase);
      }
      if (phase == ExportPhase.compressing) {
        compressionSnapshots.add(progress.detail);
      }
    });

    final output = (await tester.runAsync(() async {
      final result = await ProjectTransferArchiveService(ref: widgetRef).save(
        payload,
        fileStem: 'progress-export',
        format: ProjectTransferArchiveFormat.zip,
        destinationDirectory: tempDir,
        progress: reporter,
      );
      await Future<void>.delayed(Duration.zero);
      return result;
    }))!;
    await reporter.dispose();

    expect(output.existsSync(), isTrue);
    expect(phases, [
      ExportPhase.preparing,
      ExportPhase.copyingFiles,
      ExportPhase.compressing,
    ]);
    expect(last!.outcome, ExportOutcome.succeeded);
    expect(last!.overallFraction, 1);

    // The compression stage is driven by the Rust stream, so a real byte count
    // arriving here is what proves the bridge is wired end to end.
    final compressed = compressionSnapshots.last;
    expect(compressed.totalUnits, greaterThan(0));
    expect(compressed.completedUnits, compressed.totalUnits);
    expect(compressed.bytesProcessed, greaterThan(0));
    expect(compressed.bytesProcessed, compressed.totalBytes);
  });

  testWidgets('a light export skips the media stage entirely', (tester) async {
    final widgetRef = await _pumpRef(tester);
    final payload = _payloadWithMedia(_writeMediaFiles(tempDir, 2));

    expect(
      ProjectTransferArchiveService.exportPhases(
        payload,
        ProjectTransferArchiveFormat.jsonGzip,
      ).map((step) => step.phase),
      [ExportPhase.preparing, ExportPhase.compressing],
    );

    final output = (await tester.runAsync(
      () => ProjectTransferArchiveService(ref: widgetRef).save(
        payload,
        fileStem: 'light-export',
        format: ProjectTransferArchiveFormat.jsonGzip,
        destinationDirectory: tempDir,
      ),
    ))!;
    expect(output.existsSync(), isTrue);
  });

  testWidgets('cancelling mid-copy leaves no archive and no staging', (
    tester,
  ) async {
    final widgetRef = await _pumpRef(tester);
    final payload = _payloadWithMedia(_writeMediaFiles(tempDir, 4));
    final reporter = ExportProgressReporter(
      steps: ProjectTransferArchiveService.exportPhases(
        payload,
        ProjectTransferArchiveFormat.zip,
      ),
    );
    final cancellation = ExportCancellation();
    // Pull the plug as soon as the media copy starts.
    reporter.stream.listen((progress) {
      if (progress.activeStep?.phase == ExportPhase.copyingFiles) {
        cancellation.cancel();
      }
    });

    await tester.runAsync(() async {
      await expectLater(
        ProjectTransferArchiveService(ref: widgetRef).save(
          payload,
          fileStem: 'cancelled-export',
          format: ProjectTransferArchiveFormat.zip,
          destinationDirectory: tempDir,
          progress: reporter,
          cancel: cancellation,
        ),
        throwsA(isA<ExportCancelledException>()),
      );
    });
    await reporter.dispose();

    expect(File('${tempDir.path}/cancelled-export.zip').existsSync(), isFalse);
    // The test's own temp directory shares the words, so match the staging
    // directory by its own name rather than by anything in the full path.
    expect(
      tempDir
          .listSync(recursive: true)
          .where(
            (entity) =>
                path.basename(entity.path).startsWith('project-transfer-'),
          ),
      isEmpty,
    );
  });
}

/// Pumps a bare widget tree and hands back a ref the services can read.
Future<WidgetRef> _pumpRef(WidgetTester tester) async {
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
  return widgetRef!;
}

List<ProjectTransferMediaFile> _writeMediaFiles(Directory root, int count) {
  final source = Directory('${root.path}/media-source')..createSync();
  return List.generate(count, (index) {
    final file = File('${source.path}/photo-$index.jpg')
      ..writeAsBytesSync(List.filled(2048, index));
    return ProjectTransferMediaFile(
      sourceId: 'media:$index',
      kind: 'specimen',
      archivePath: 'media/$index-photo-$index.jpg',
      originalFileName: 'photo-$index.jpg',
      sourcePath: file.path,
      sizeBytes: file.lengthSync(),
    );
  });
}

ProjectTransferPayload _payloadWithMedia(List<ProjectTransferMediaFile> media) {
  return ProjectTransferPayload(
    exportedAt: '2026-01-01T00:00:00Z',
    appVersion: '1.0.0+1',
    databaseVersion: 14,
    project: const {'uuid': 'project-a', 'name': 'Project A'},
    records: const {},
    mediaFiles: media,
  );
}
