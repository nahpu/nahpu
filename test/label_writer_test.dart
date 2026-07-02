import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/screens/templates/template_model.dart';

void main() {
  group('LabelWriter text substitutions', () {
    test('substituteLabelPlaceholders replaces keys exactly', () {
      final text = 'Specimen: [catalogNum] ([tissueId])';
      final data = {
        'catalogNum': '1234',
        'tissueId': 'T-100',
      };

      final result = substituteLabelPlaceholders(text, data);
      expect(result, 'Specimen: 1234 (T-100)');
    });

    test('substituteLabelPlaceholders replaces keys case-insensitively', () {
      final text = 'Sex: [SEX] - Locality: [Locality]';
      final data = {
        'sex': 'Male',
        'locality': 'Forest edge',
      };

      final result = substituteLabelPlaceholders(text, data);
      expect(result, 'Sex: Male - Locality: Forest edge');
    });

    test('substituteLabelPlaceholders handles missing keys gracefully', () {
      final text = 'Age: [age] - Weight: [weight]';
      final data = {
        'age': 'Adult',
      };

      final result = substituteLabelPlaceholders(text, data);
      expect(result, 'Age: Adult - Weight: [weight]');
    });
  });

  group('LabelWriter z-index tests', () {
    test('Elements are correctly sorted by zIndex', () {
      final page = TemplatePage(customImages: [
        CustomImageElement(
            id: 'img1',
            imagePath: 'path1.png',
            xMm: 0,
            yMm: 0,
            widthMm: 10,
            heightMm: 10,
            zIndex: 10),
      ], customTexts: [
        CustomTextElement(
            id: 'txt1', text: 'Top text', xMm: 0, yMm: 0, zIndex: 20),
        CustomTextElement(
            id: 'txt2', text: 'Bottom text', xMm: 0, yMm: 0, zIndex: -10),
      ], customLines: [
        CustomLineElement(id: 'line1', xMm: 0, yMm: 0, lengthMm: 10, zIndex: 5),
      ], customShapes: [
        CustomShapeElement(
            id: 'shape1',
            shapeType: 'rect',
            xMm: 0,
            yMm: 0,
            widthMm: 10,
            heightMm: 10,
            zIndex: 0),
      ]);

      final sortedElements = LabelWriter.sortElementsForTesting(page);

      expect(sortedElements.length, 5);

      expect(sortedElements[0] is CustomTextElement, isTrue);
      expect((sortedElements[0] as CustomTextElement).id, 'txt2');

      expect(sortedElements[1] is CustomShapeElement, isTrue);
      expect((sortedElements[1] as CustomShapeElement).id, 'shape1');

      expect(sortedElements[2] is CustomLineElement, isTrue);
      expect((sortedElements[2] as CustomLineElement).id, 'line1');

      expect(sortedElements[3] is CustomImageElement, isTrue);
      expect((sortedElements[3] as CustomImageElement).id, 'img1');

      expect(sortedElements[4] is CustomTextElement, isTrue);
      expect((sortedElements[4] as CustomTextElement).id, 'txt1');
    });
  });

  group('Label text formatting tests', () {
    test('formatTextWithCase applies correct capitalization styles', () {
      const text = 'hello world test';
      expect(formatTextWithCase(text, 'uppercase'), 'HELLO WORLD TEST');
      expect(formatTextWithCase(text, 'lowercase'), 'hello world test');
      expect(formatTextWithCase(text, 'capitalize'), 'Hello World Test');
      expect(formatTextWithCase(text, 'normal'), 'hello world test');
    });

    test(
        'CustomTextElement JSON serialization retains textAlign and caseFormat',
        () {
      final ct = CustomTextElement(
        id: 'txt1',
        text: 'hello',
        xMm: 10,
        yMm: 20,
        textAlign: 'center',
        caseFormat: 'uppercase',
      );
      final json = ct.toJson();
      expect(json['textAlign'], 'center');
      expect(json['caseFormat'], 'uppercase');

      final deserialized = CustomTextElement.fromJson(json);
      expect(deserialized.textAlign, 'center');
      expect(deserialized.caseFormat, 'uppercase');
    });

    test(
        'CustomTextElement defaults textAlign and caseFormat on missing json keys',
        () {
      final json = {
        'id': 'txt1',
        'text': 'hello',
        'xMm': 10,
        'yMm': 20,
      };
      final deserialized = CustomTextElement.fromJson(json);
      expect(deserialized.textAlign, 'left');
      expect(deserialized.caseFormat, 'normal');
      expect(deserialized.textType, 'normal');
      expect(deserialized.formatOption, 'normal');
    });

    test(
        'CustomTextElement JSON serialization retains textType and formatOption',
        () {
      final ct = CustomTextElement(
        id: 'txt1',
        text: 'hello',
        xMm: 10,
        yMm: 20,
        textType: 'coordinates',
        formatOption: 'dms',
      );
      final json = ct.toJson();
      expect(json['textType'], 'coordinates');
      expect(json['formatOption'], 'dms');

      final deserialized = CustomTextElement.fromJson(json);
      expect(deserialized.textType, 'coordinates');
      expect(deserialized.formatOption, 'dms');
    });

    test('Coordinates formatting handles DMS and cardinal directions correctly',
        () {
      const text = '45.12345, -122.54321';
      final dms = formatTemplateText(text, 'coordinates', 'dms');
      expect(dms, '45° 7\' 24.4" N, 122° 32\' 35.6" W');

      final ddm = formatTemplateText(text, 'coordinates', 'ddm');
      expect(ddm, '45° 7.407\' N, 122° 32.593\' W');

      final cardinal =
          formatTemplateText(text, 'coordinates', 'cardinalDecimal');
      expect(cardinal, '45.12345° N, 122.54321° W');
    });

    test('List formatting handles normal separators and custom separators', () {
      const listText = 'mammal | bird | reptile';
      final commaList = formatTemplateText(listText, 'list', 'comma');
      expect(commaList, 'mammal, bird, reptile');

      final customList = formatTemplateText(listText, 'list', 'custom: - ');
      expect(customList, 'mammal - bird - reptile');
    });

    test('Date formatting parses and formats ISO dates correctly', () {
      const dateText = '2026-06-28';
      final formatted = formatTemplateText(dateText, 'date', 'month-dd-yyyy');
      expect(formatted, 'June 28, 2026');

      final abbr = formatTemplateText(dateText, 'date', 'dd-month-abbr-yyyy');
      expect(abbr, '28 Jun 2026');
    });

    test('Sex formatting parses Male/Female/Unknown indices and text', () {
      expect(formatTemplateText('0', 'sex', 'symbol:unknown'), '\u2642');
      expect(formatTemplateText('Male', 'sex', 'letter:na'), 'M');
      expect(formatTemplateText('m', 'sex', 'text:none'), 'Male');

      expect(formatTemplateText('1', 'sex', 'symbol:unknown'), '\u2640');
      expect(formatTemplateText('Female', 'sex', 'letter:na'), 'F');
      expect(formatTemplateText('f', 'sex', 'text:none'), 'Female');

      expect(formatTemplateText('2', 'sex', 'symbol:unknown'), '?');
      expect(formatTemplateText('', 'sex', 'letter:na'), 'N/A');
      expect(formatTemplateText('Unknown', 'sex', 'text:none'), '');
    });

    test('Field display formatting displays full/field-only placeholders', () {
      const text = '[specimen::catalogNum] [site::locality]';
      expect(
        formatFieldPlaceholderText(text, false),
        '[specimen::catalogNum] [site::locality]',
      );
      expect(
        formatFieldPlaceholderText(text, true),
        '[catalogNum] [locality]',
      );
    });

    test('Number formatting formats double values to specified decimals', () {
      const pureFloat = '12.3456';
      expect(formatTemplateText(pureFloat, 'number', 'original'), '12.3456');
      expect(formatTemplateText(pureFloat, 'number', '0'), '12');
      expect(formatTemplateText(pureFloat, 'number', '1'), '12.3');
      expect(formatTemplateText(pureFloat, 'number', '2'), '12.35');
      expect(formatTemplateText(pureFloat, 'number', '3'), '12.346');

      const integerText = '12';
      expect(formatTemplateText(integerText, 'number', '1'), '12.0');

      const textWithUnits = 'Weight: 12.34 g';
      expect(
          formatTemplateText(textWithUnits, 'number', '1'), 'Weight: 12.3 g');
    });

    group('Integrated Text-to-QR tests', () {
      test(
          'CustomTextElement JSON serialization retains isQrCode, qrSizeMm, qrBgColorArgb, and qrShape',
          () {
        final ct = CustomTextElement(
          id: 'ct_1',
          text: '[catalogNum]',
          xMm: 10,
          yMm: 20,
          isQrCode: true,
          qrSizeMm: 18.5,
          qrBgColorArgb: 0xFF000000,
          qrShape: 'circle',
        );
        final json = ct.toJson();
        expect(json['id'], 'ct_1');
        expect(json['text'], '[catalogNum]');
        expect(json['isQrCode'], true);
        expect(json['qrSizeMm'], 18.5);
        expect(json['qrBgColorArgb'], 0xFF000000);
        expect(json['qrShape'], 'circle');

        final deserialized = CustomTextElement.fromJson(json);
        expect(deserialized.id, 'ct_1');
        expect(deserialized.text, '[catalogNum]');
        expect(deserialized.isQrCode, true);
        expect(deserialized.qrSizeMm, 18.5);
        expect(deserialized.qrBgColorArgb, 0xFF000000);
        expect(deserialized.qrShape, 'circle');
      });

      test('CustomTextElement default properties on missing json keys', () {
        final ct = CustomTextElement.fromJson({
          'id': 'ct_2',
          'text': 'Hello',
          'xMm': 0,
          'yMm': 0,
        });
        expect(ct.isQrCode, false);
        expect(ct.qrSizeMm, 15.0);
        expect(ct.qrBgColorArgb, 0xFFFFFFFF);
        expect(ct.qrShape, 'square');
      });
    });
  });
}
