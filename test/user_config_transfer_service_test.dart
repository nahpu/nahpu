import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/services/parasite_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/user_config_transfer_service.dart';
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
    tempDir = Directory.systemTemp.createTempSync('nahpu_config_transfer_');
    await rust_config.initConfigDb(path: '${tempDir.path}/nahpu_configs.db');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('JSON.GZ transfer is inspected and imported as JSON', () async {
    const key = 'siteTypes';
    const section = rust_config.UserConfigSection.userConfigs;
    await rust_config.setUserConfigList(key: key, value: ['Forest']);
    final output = File('${tempDir.path}/configs.json.gz');
    const service = UserConfigTransferService();

    await service.export(
      output: output,
      format: UserConfigFileFormat.jsonGzip,
      sections: const {section},
    );
    final bytes = await output.readAsBytes();
    expect(bytes.take(2), [0x1f, 0x8b]);

    final source = await service.inspect(XFile(output.path));
    addTearDown(source.dispose);
    expect(source.preview.includedSections, contains(section));
    expect(
      source.preview.userConfigs.firstWhere((entry) => entry.key == key).values,
      ['Forest'],
    );

    await rust_config.setUserConfigList(key: key, value: ['Ocean']);
    await service.import(source, const {section});
    expect(await rust_config.getUserConfigList(key: key), ['Forest']);
  });

  test('parasite ID settings and vocabularies are redb-backed', () async {
    const service = ParasiteIdServices();
    await service.setPrefix('P-');
    await service.setNumber('7');
    expect(await service.getNewNumber(), 'P-7');
    expect(
      await rust_config.getUserConfigString(key: parasiteIdNumberPrefKey),
      '8',
    );

    await rust_config.setUserConfigList(
      key: parasiteCategoryPrefKey,
      value: ['Ectoparasite'],
    );
    final preview = await rust_config.getConfigExportPreview();
    final category = preview.userConfigs.firstWhere(
      (entry) => entry.key == parasiteCategoryPrefKey,
    );
    expect(category.label, 'Parasite categories');
    expect(category.values, ['Ectoparasite']);
    expect(category.isControlledVocabulary, isTrue);
  });
}
