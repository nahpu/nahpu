import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/templates/document_layout_service.dart';

void main() {
  setUpAll(() async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final String dylibPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust/target/debug/rust_lib_nahpu.dll'
          : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    } else {
      await RustLib.init();
    }
  });

  group('DocumentLayoutPreset copyWith', () {
    test('copyWith copies and changes specified fields', () {
      final block = rust_config.DocumentLayoutBlock(
        templateName: 'TemplateA',
        templateCount: 2,
        rows: 4,
        cols: 3,
        templatePadTopMm: 1.5,
        templatePadLeftMm: 1.5,
        templatePadRightMm: 1.5,
        templatePadBottomMm: 1.5,
        pageBreakAfter: true,
        sortField: 'specimen::fieldNumber',
        sortDirection: rust_config.DocumentSortDirection.descending,
      );

      final updatedBlock = block.copyWith(
        templateName: 'TemplateB',
        templateCount: 5,
        pageBreakAfter: false,
      );

      expect(updatedBlock.templateName, 'TemplateB');
      expect(updatedBlock.templateCount, 5);
      expect(updatedBlock.rows, 4);
      expect(updatedBlock.cols, 3);
      expect(updatedBlock.templatePadTopMm, 1.5);
      expect(updatedBlock.pageBreakAfter, false);
      expect(updatedBlock.sortField, 'specimen::fieldNumber');
      expect(
        updatedBlock.sortDirection,
        rust_config.DocumentSortDirection.descending,
      );

      final autoFillBlock = block.copyWithAutoFill(true);
      expect(autoFillBlock.autoFillPage, isTrue);
      expect(autoFillBlock.fixedRows, 4);
      expect(autoFillBlock.copyWithAutoFill(false).rows, 4);

      final layout = rust_config.DocumentLayoutPreset(
        name: 'LayoutA',
        layoutType: 'WholePage',
        pageSizeKey: 'A4',
        pageOrientation: 'portrait',
        customPageWidthMm: null,
        customPageHeightMm: null,
        pagePadTopMm: 5.0,
        pagePadLeftMm: 5.0,
        pagePadRightMm: 5.0,
        pagePadBottomMm: 5.0,
        blocks: [block],
        fillPage: false,
        multiBlockMode: 'Continuous',
      );

      final updatedLayout = layout.copyWith(
        name: 'LayoutB',
        pageSizeKey: 'Letter',
        blocks: [updatedBlock],
      );

      expect(updatedLayout.name, 'LayoutB');
      expect(updatedLayout.layoutType, 'WholePage');
      expect(updatedLayout.pageSizeKey, 'Letter');
      expect(updatedLayout.pageOrientation, 'portrait');
      expect(updatedLayout.pagePadTopMm, 5.0);
      expect(updatedLayout.blocks.length, 1);
      expect(updatedLayout.blocks.first.templateName, 'TemplateB');
    });
  });

  group('DocumentLayoutPreset JSON Serialization', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'nahpu_document_layout_test_',
      );
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('roundtrip serialization matches exactly', () async {
      final block = rust_config.DocumentLayoutBlock(
        templateName: 'Mammal Skin',
        templateCount: 1,
        rows: 8,
        cols: 4,
        templatePadTopMm: 1.0,
        templatePadLeftMm: 1.0,
        templatePadRightMm: 1.0,
        templatePadBottomMm: 1.0,
        pageBreakAfter: false,
        sortField: 'taxonomy::species',
        sortDirection: rust_config.DocumentSortDirection.ascending,
      );

      final layout = rust_config.DocumentLayoutPreset(
        name: 'Standard Letter Layout',
        layoutType: 'WholePage',
        pageSizeKey: 'Letter',
        pageOrientation: 'portrait',
        customPageWidthMm: 215.9,
        customPageHeightMm: 279.4,
        pagePadTopMm: 8.0,
        pagePadLeftMm: 8.0,
        pagePadRightMm: 8.0,
        pagePadBottomMm: 8.0,
        blocks: [block],
        fillPage: true,
        multiBlockMode: 'Continuous',
      );

      final filePath = '${tempDir.path}/layout.json';
      await rust_config.exportDocumentLayoutToFile(
        layout: layout,
        filePath: filePath,
      );
      final deserialized = await rust_config.importDocumentLayoutFromFile(
        filePath: filePath,
      );

      expect(deserialized.name, layout.name);
      expect(deserialized.layoutType, layout.layoutType);
      expect(deserialized.pageSizeKey, layout.pageSizeKey);
      expect(deserialized.pageOrientation, layout.pageOrientation);
      expect(deserialized.customPageWidthMm, layout.customPageWidthMm);
      expect(deserialized.customPageHeightMm, layout.customPageHeightMm);
      expect(deserialized.pagePadTopMm, layout.pagePadTopMm);
      expect(deserialized.pagePadLeftMm, layout.pagePadLeftMm);
      expect(deserialized.pagePadRightMm, layout.pagePadRightMm);
      expect(deserialized.pagePadBottomMm, layout.pagePadBottomMm);
      expect(deserialized.fillPage, true);

      expect(deserialized.blocks.length, 1);
      final deserializedBlock = deserialized.blocks.first;
      expect(deserializedBlock.templateName, block.templateName);
      expect(deserializedBlock.templateCount, block.templateCount);
      expect(deserializedBlock.rows, block.rows);
      expect(deserializedBlock.cols, block.cols);
      expect(deserializedBlock.templatePadTopMm, block.templatePadTopMm);
      expect(deserializedBlock.templatePadLeftMm, block.templatePadLeftMm);
      expect(deserializedBlock.templatePadRightMm, block.templatePadRightMm);
      expect(deserializedBlock.templatePadBottomMm, block.templatePadBottomMm);
      expect(deserializedBlock.pageBreakAfter, block.pageBreakAfter);
      expect(deserializedBlock.sortField, block.sortField);
      expect(deserializedBlock.sortDirection, block.sortDirection);
    });

    test('backward compatibility for legacy camelCase JSON fields', () async {
      final legacyJson = '''
      {
        "name": "Legacy Layout",
        "layoutType": "WholePage",
        "pageSizeKey": "Letter",
        "pageOrientation": "portrait",
        "customPageWidthMm": 215.9,
        "customPageHeightMm": 279.4,
        "pagePadTopMm": 8.0,
        "pagePadLeftMm": 8.0,
        "pagePadRightMm": 8.0,
        "pagePadBottomMm": 8.0,
        "blocks": [
          {
            "templateName": "Mammal Skin",
            "templateCount": 1,
            "rows": 8,
            "cols": 4,
            "templatePadTopMm": 1.0,
            "templatePadLeftMm": 1.0,
            "templatePadRightMm": 1.0,
            "templatePadBottomMm": 1.0,
            "pageBreakAfter": false
          }
        ]
      }
      ''';

      final filePath = '${tempDir.path}/legacy_layout.json';
      await File(filePath).writeAsString(legacyJson);
      final deserialized = await rust_config.importDocumentLayoutFromFile(
        filePath: filePath,
      );

      expect(deserialized.name, 'Legacy Layout');
      expect(deserialized.layoutType, 'WholePage');
      expect(deserialized.pageSizeKey, 'Letter');
      expect(deserialized.pageOrientation, 'portrait');
      expect(deserialized.customPageWidthMm, 215.9);
      expect(deserialized.customPageHeightMm, 279.4);
      expect(deserialized.pagePadTopMm, 8.0);
      expect(deserialized.pagePadLeftMm, 8.0);
      expect(deserialized.pagePadRightMm, 8.0);
      expect(deserialized.pagePadBottomMm, 8.0);
      expect(deserialized.fillPage, false);

      expect(deserialized.blocks.length, 1);
      final block = deserialized.blocks.first;
      expect(block.templateName, 'Mammal Skin');
      expect(block.templateCount, 1);
      expect(block.rows, 8);
      expect(block.cols, 4);
      expect(block.templatePadTopMm, 1.0);
      expect(block.templatePadLeftMm, 1.0);
      expect(block.templatePadRightMm, 1.0);
      expect(block.templatePadBottomMm, 1.0);
      expect(block.pageBreakAfter, false);
      expect(block.sortField, isNull);
      expect(block.sortDirection, rust_config.DocumentSortDirection.ascending);
    });
  });
}
