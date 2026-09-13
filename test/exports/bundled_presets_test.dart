import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';
import 'package:nahpu/services/templates/document_layout_service.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:path/path.dart' as p;

void main() {
  const service = BundledPresetService();
  final configsDir = Directory(
    p.joinAll(p.url.split(BundledPresetService.configsDir)),
  );
  final files = configsDir.listSync(recursive: true).whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  /// The manifest-style key Flutter bundles [file] under.
  String assetPathOf(File file) =>
      p.url.joinAll(p.split(p.relative(file.path)));

  String slug(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  final presets = [
    for (final file in files)
      if (BundledPresetService.isPresetAsset(assetPathOf(file)))
        service.describe(assetPathOf(file), file.readAsStringSync()),
  ];

  group('bundled presets', () {
    test('ships presets of every kind', () {
      expect(
        presets.map((preset) => preset.kind).toSet(),
        BundledPresetKind.values.toSet(),
      );
    });

    test('holds only preset files, in catalog-format folders', () {
      for (final entity in configsDir.listSync(recursive: true)) {
        final relative = p.relative(entity.path, from: configsDir.path);
        if (entity is Directory) {
          expect(p.split(relative), hasLength(1), reason: relative);
          expect(
            CatalogFmt.values.asNameMap().keys,
            contains(p.basename(relative)),
            reason: '$relative is not a catalog format',
          );
        } else {
          expect(
            BundledPresetService.isPresetAsset(assetPathOf(entity as File)),
            isTrue,
            reason: '$relative is not a bundled preset file',
          );
        }
      }
    });

    test('bundles every catalog-format folder in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- ${BundledPresetService.configsDir}/\n'));
      for (final folder in configsDir.listSync().whereType<Directory>()) {
        expect(
          pubspec,
          contains('- ${assetPathOf(File(folder.path))}/\n'),
          reason: '${folder.path} is not listed as an asset',
        );
      }
    });

    for (final file in files) {
      final assetPath = assetPathOf(file);
      test('$assetPath is named after the preset it holds', () {
        final preset = service.describe(assetPath, file.readAsStringSync());
        final decoded = jsonDecode(file.readAsStringSync()) as Map;

        expect(decoded.keys.single, preset.name);
        expect(
          p.url.basename(assetPath),
          '${preset.kind.prefix}-${slug(preset.name)}.json',
        );
        expect(
          preset.catalogFmt,
          BundledPresetService.catalogFmtFor(assetPath),
        );
        expect(preset.description, isNotEmpty);
        expect(preset.description, endsWith('.'));
        expect(
          preset.description.length,
          lessThanOrEqualTo(kDescriptionMaxLength),
        );
      });
    }

    test('names are unique within each kind', () {
      for (final kind in BundledPresetKind.values) {
        final names = presets
            .where((preset) => preset.kind == kind)
            .map((preset) => preset.name)
            .toList();
        expect(names.toSet(), hasLength(names.length), reason: kind.name);
      }
    });

    test('layouts use bundled templates, generic layouts generic ones', () {
      final templates = {
        for (final preset in presets)
          if (preset.kind == BundledPresetKind.template) preset.name: preset,
      };
      for (final preset in presets) {
        if (preset.kind != BundledPresetKind.document) continue;
        final decoded =
            jsonDecode(File(preset.assetPath).readAsStringSync()) as Map;
        final layout = DocumentLayoutPresetJson.fromJson(
          Map<String, dynamic>.from(decoded.values.single as Map),
        );
        expect(layout.blocks, isNotEmpty, reason: preset.name);
        for (final block in layout.blocks) {
          final template = templates[block.templateName];
          expect(template, isNotNull, reason: block.templateName);
          if (preset.isGeneric) {
            expect(
              template!.isGeneric,
              isTrue,
              reason:
                  '${preset.name} is loaded by Load defaults but uses '
                  '${block.templateName}',
            );
          } else {
            expect(
              template!.catalogFmt,
              anyOf(isNull, preset.catalogFmt),
              reason: block.templateName,
            );
          }
        }
      }
    });
  });
}
