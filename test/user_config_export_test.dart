import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

void main() {
  late Directory tempDir;

  setUpAll(() async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final String dylibPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
              ? 'rust/target/debug/rust_lib_nahpu.dll'
              : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(
        externalLibrary: ExternalLibrary.open(dylibPath),
      );
    } else {
      await RustLib.init();
    }
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('nahpu_config_export_test_');
    // Initialize config db in a temp file
    final configDbPath = '${tempDir.path}/nahpu_configs.db';
    await rust_config.initConfigDb(path: configDbPath);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Config export and import roundtrip (JSON)', () async {
    // 1. Populate some configs
    const testKey = 'siteTypes';
    final testVal = ['Forest', 'Stream', 'Desert'];
    await rust_config.setUserConfigList(key: testKey, value: testVal);

    // 2. Export to file
    final exportPath = '${tempDir.path}/configs.json';
    await rust_config.exportConfigToFile(filePath: exportPath, isJson: true);
    expect(File(exportPath).existsSync(), true);

    // Verify it is JSON
    final content = File(exportPath).readAsStringSync();
    expect(content.startsWith('{'), true);

    // 3. Clear/change the values
    await rust_config.setUserConfigList(key: testKey, value: ['Ocean']);

    // 4. Import from file
    await rust_config.importConfigFromFile(filePath: exportPath);

    // 5. Verify restored
    final restoredVal = await rust_config.getUserConfigList(key: testKey);
    expect(restoredVal, testVal);
  });

  test('Config export and import roundtrip (KDL)', () async {
    // 1. Populate some configs
    const testKey = 'siteTypeFmt';
    const testVal = 'anyCase';
    await rust_config.setUserConfigString(key: testKey, value: testVal);

    // 2. Export to file
    final exportPath = '${tempDir.path}/configs.kdl';
    await rust_config.exportConfigToFile(filePath: exportPath, isJson: false);
    expect(File(exportPath).existsSync(), true);

    // 3. Clear/change the values
    await rust_config.setUserConfigString(key: testKey, value: 'otherCase');

    // 4. Import from file
    await rust_config.importConfigFromFile(filePath: exportPath);

    // 5. Verify restored
    final restoredVal = await rust_config.getUserConfigString(key: testKey);
    expect(restoredVal, testVal);
  });
}
