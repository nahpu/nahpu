import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'output paths create directories and avoid filename collisions',
    () async {
      final root = await Directory.systemTemp.createTemp('nahpu-output-test-');
      addTearDown(() => root.delete(recursive: true));
      final destination = Directory('${root.path}/new-directory');
      final io = AppIOServices(
        dir: destination,
        fileStem: 'coordinate',
        ext: 'geojson',
      );

      final first = await io.getSavePath();
      expect(destination.existsSync(), isTrue);
      expect(first.path, endsWith('coordinate.geojson'));
      await first.writeAsString('{}');

      final second = await io.getSavePath();
      expect(second.path, endsWith('coordinate(1).geojson'));
    },
  );

  test(
    'falls back to the application documents directory without a dir',
    () async {
      final documents = await Directory.systemTemp.createTemp('nahpu-docs-');
      addTearDown(() => documents.delete(recursive: true));
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => call.method == 'getApplicationDocumentsDirectory'
            ? documents.path
            : null,
      );
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      final io = AppIOServices(dir: null, fileStem: 'records', ext: 'csv');

      final first = await io.getSavePath();
      expect(p.dirname(first.path), documents.path);
      expect(p.basename(first.path), 'records.csv');
      await first.writeAsString('a');

      final second = await io.getSavePath();
      expect(p.basename(second.path), 'records(1).csv');
    },
  );

  test('supports original files without an extension', () async {
    final root = await Directory.systemTemp.createTemp('nahpu-output-test-');
    addTearDown(() => root.delete(recursive: true));
    final output = await AppIOServices(
      dir: root,
      fileStem: 'extensionless',
      ext: '',
    ).getSavePath();

    expect(output.path, endsWith('extensionless'));
  });
}
