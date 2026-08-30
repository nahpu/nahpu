import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/io_services.dart';

void main() {
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
