import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/export/export_destination.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory systemTemp;

  setUp(() {
    systemTemp = Directory.systemTemp.createTempSync('nahpu-export-dest-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getTemporaryDirectory') return systemTemp.path;
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    if (systemTemp.existsSync()) await systemTemp.delete(recursive: true);
  });

  Directory exportDir() =>
      Directory(p.join(systemTemp.path, nahpuTempDir, nahpuTempExportDirName));

  test('choosing a directory keeps whatever the user picked', () async {
    final service = ExportDestinationService(
      mode: ExportDestinationMode.chooseDirectory,
    );
    final picked = Directory(p.join(systemTemp.path, 'picked'))..createSync();

    expect(service.canChooseDirectory, isTrue);
    expect((await service.resolve(picked))?.path, picked.path);
  });

  test(
    'choosing a directory but picking none defers to the app fallback',
    () async {
      final service = ExportDestinationService(
        mode: ExportDestinationMode.chooseDirectory,
      );

      // Null is the contract that keeps AppIOServices' application-documents
      // fallback in play; resolving it to a directory here would bypass it.
      expect(await service.resolve(null), isNull);
    },
  );

  test('the temporary mode ignores a directory and offers no picker', () async {
    final service = ExportDestinationService(
      mode: ExportDestinationMode.temporary,
    );
    final ignored = Directory(p.join(systemTemp.path, 'ignored'))..createSync();

    final resolved = await service.resolve(ignored);

    expect(service.canChooseDirectory, isFalse);
    expect(resolved?.path, exportDir().path);
    expect(resolved?.existsSync(), isTrue);
  });

  test(
    'preparing the temporary directory clears the previous export',
    () async {
      final exports = exportDir()..createSync(recursive: true);
      File(p.join(exports.path, 'stale.csv')).writeAsStringSync('old');
      final staleDir = Directory(p.join(exports.path, 'stale-media'))
        ..createSync();
      File(p.join(staleDir.path, 'photo.jpg')).writeAsStringSync('old');

      final prepared = await prepareTemporaryExportDir();

      expect(prepared.listSync(), isEmpty);
    },
  );

  test('preparing the temporary directory spares sibling staging', () async {
    final staging = Directory(
      p.join(systemTemp.path, nahpuTempDir, 'db-backup-1'),
    )..createSync(recursive: true);
    final inFlight = File(p.join(staging.path, 'nahpu.sqlite3'))
      ..writeAsStringSync('live');

    await prepareTemporaryExportDir();

    expect(inFlight.existsSync(), isTrue);
  });
}
