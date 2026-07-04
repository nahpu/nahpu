import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/document_layout_service.dart';

void main() {
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
    test('roundtrip serialization matches exactly', () {
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
      );

      final json = documentLayoutPresetToJson(layout);
      final deserialized = documentLayoutPresetFromJson(json);

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
    });
  });
}
