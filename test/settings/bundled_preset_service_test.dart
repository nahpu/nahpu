import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:path/path.dart' as p;

void main() {
  /// The bundled config files, keyed the way the asset manifest lists them.
  final bundled = {
    for (final file in Directory(
      p.joinAll(p.url.split(BundledPresetService.configsDir)),
    ).listSync(recursive: true).whereType<File>())
      p.url.joinAll(p.split(p.relative(file.path))): file.readAsStringSync(),
  };
  final service = BundledPresetService(
    bundle: _MapAssetBundle(bundled),
    assetPathsLoader: () async => [
      ...bundled.keys,
      'assets/icons/catalog.svg',
      'assets/configs/README.md',
      'assets/configs/birds/document-unknown-folder.json',
    ],
  );

  test('lists presets by prefix and folder, generic ones first', () async {
    final presets = await service.list();

    expect(presets, hasLength(bundled.length));
    final firstSpecific = presets.indexWhere((preset) => !preset.isGeneric);
    expect(presets.skip(firstSpecific).every((p) => !p.isGeneric), isTrue);

    final tissue = presets.singleWhere((p) => p.name == 'Tissue labels');
    expect(tissue.kind, BundledPresetKind.document);
    expect(tissue.catalogFmt, isNull);

    final booklet = presets.singleWhere(
      (p) => p.name == 'Mammal field booklet',
    );
    expect(booklet.kind, BundledPresetKind.document);
    expect(booklet.catalogFmt, CatalogFmt.mammalogy);
    expect(booklet.description, isNotEmpty);
  });

  test('defaults hold only generic presets', () async {
    final defaults = await service.defaults();

    expect(defaults, isNotEmpty);
    expect(defaults.every((preset) => preset.isGeneric), isTrue);
    expect(defaults.map((preset) => preset.name), contains('Tissue labels'));
    expect(
      defaults.map((preset) => preset.name),
      isNot(contains('Mammal field booklet')),
    );
    expect(
      (await service.defaults(
        kinds: {BundledPresetKind.document},
      )).every((preset) => preset.kind == BundledPresetKind.document),
      isTrue,
    );
  });

  test(
    'a layout brings the templates it prints with, across folders',
    () async {
      final presets = await service.list();
      final booklet = presets.singleWhere(
        (p) => p.name == 'Mammal field booklet',
      );

      final queue = await service.withTemplates([booklet]);

      expect(queue.last.name, booklet.name);
      expect(
        queue.take(queue.length - 1).map((preset) => preset.name).toSet(),
        {'Cover', 'Site', 'Events', 'Mammal catalog', 'Narrative'},
      );
      expect(
        queue.singleWhere((preset) => preset.name == 'Cover').catalogFmt,
        isNull,
      );
      expect(
        queue
            .singleWhere((preset) => preset.name == 'Mammal catalog')
            .catalogFmt,
        CatalogFmt.mammalogy,
      );
    },
  );

  test('recognises preset files only in configs and format folders', () {
    const configs = BundledPresetService.configsDir;
    expect(
      BundledPresetService.isPresetAsset(
        '$configs/document-tissue-labels.json',
      ),
      isTrue,
    );
    expect(
      BundledPresetService.isPresetAsset(
        '$configs/mammalogy/template-mammal-skull-tag.json',
      ),
      isTrue,
    );
    expect(BundledPresetService.isPresetAsset('$configs/basic.json'), isFalse);
    expect(
      BundledPresetService.isPresetAsset('$configs/document-tags.txt'),
      isFalse,
    );
    expect(
      BundledPresetService.isPresetAsset('$configs/birds/document-tags.json'),
      isFalse,
    );
    expect(
      BundledPresetService.isPresetAsset(
        '$configs/mammalogy/nested/document-tags.json',
      ),
      isFalse,
    );
    expect(
      BundledPresetService.catalogFmtFor('$configs/mammalogy/record-x.json'),
      CatalogFmt.mammalogy,
    );
  });

  test('describes what a load did', () {
    const preset = BundledPreset(
      kind: BundledPresetKind.document,
      name: 'Tissue labels',
      description: 'Basic vial labels for tissue collection.',
      assetPath: 'assets/configs/document-tissue-labels.json',
    );
    expect(
      const BundledPresetLoadResult(added: [preset], skippedCount: 0).message,
      'Added 1 preset',
    );
    expect(
      const BundledPresetLoadResult(added: [], skippedCount: 2).message,
      'Default presets are already loaded',
    );
    expect(
      const BundledPresetLoadResult(added: [], skippedCount: 0).message,
      'No default presets of this type',
    );
  });
}

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) throw StateError('Missing asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}
