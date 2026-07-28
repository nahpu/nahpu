import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
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

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('nahpu_config_export_test_');
    await rust_config.initConfigDb(path: '${tempDir.path}/nahpu_configs.db');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('full JSON export and import roundtrip includes all sections', () async {
    const configKey = 'siteTypes';
    const templateName = 'Test Template';
    const presetName = 'Test Preset';
    final configValue = ['Forest', 'Stream', 'Desert'];
    await rust_config.setUserConfigList(key: configKey, value: configValue);
    await rust_config.setTemplatePreset(
      name: templateName,
      value: '{"name":"Test Template","page1":{},"page2":{}}',
    );
    await rust_config.setRecordExportPreset(
      name: presetName,
      preset: const rust_config.ConfigExportPreset(
        fields: {'catalogNum': 'Catalog Number'},
        combinedFields: [],
      ),
    );

    final exportPath = '${tempDir.path}/configs.json';
    await rust_config.exportConfigToFile(
      filePath: exportPath,
      sections: rust_config.UserConfigSection.values,
    );
    final exported =
        jsonDecode(File(exportPath).readAsStringSync()) as Map<String, dynamic>;
    expect(exported['schema_version'], 2);
    expect(exported['included_sections'], hasLength(4));

    await rust_config.setUserConfigList(key: configKey, value: ['Ocean']);
    await rust_config.deleteTemplatePreset(name: templateName);
    await rust_config.deleteRecordExportPreset(name: presetName);

    await rust_config.importConfigFromFile(
      filePath: exportPath,
      sections: rust_config.UserConfigSection.values,
    );

    expect(await rust_config.getUserConfigList(key: configKey), configValue);
    expect(await rust_config.listTemplatePresets(), contains(templateName));
    expect(
      (await rust_config.getAllRecordExportPresets()).any(
        (preset) => preset.name == presetName,
      ),
      isTrue,
    );
  });

  test('selective import preserves unselected sections', () async {
    const configKey = 'habitatTypes';
    const templateName = 'Selective Template';
    await rust_config.setUserConfigList(key: configKey, value: ['Forest']);
    await rust_config.setTemplatePreset(
      name: templateName,
      value: '{"name":"Selective Template","page1":{},"page2":{}}',
    );
    final exportPath = '${tempDir.path}/selective.json';
    await rust_config.exportConfigToFile(
      filePath: exportPath,
      sections: const [rust_config.UserConfigSection.userConfigs],
    );

    await rust_config.setUserConfigList(key: configKey, value: ['Ocean']);
    await rust_config.importConfigFromFile(
      filePath: exportPath,
      sections: const [rust_config.UserConfigSection.userConfigs],
    );

    expect(await rust_config.getUserConfigList(key: configKey), ['Forest']);
    expect(await rust_config.listTemplatePresets(), contains(templateName));
  });
}
