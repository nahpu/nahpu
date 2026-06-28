import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/screens/export/labels/label_template_model.dart';

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
      final page = LabelPageTemplate(
        customImages: [
          CustomImageElement(id: 'img1', imagePath: 'path1.png', xMm: 0, yMm: 0, widthMm: 10, heightMm: 10, zIndex: 10),
        ],
        customTexts: [
          CustomTextElement(id: 'txt1', text: 'Top text', xMm: 0, yMm: 0, zIndex: 20),
          CustomTextElement(id: 'txt2', text: 'Bottom text', xMm: 0, yMm: 0, zIndex: -10),
        ],
        customLines: [
          CustomLineElement(id: 'line1', xMm: 0, yMm: 0, lengthMm: 10, zIndex: 5),
        ],
        customShapes: [
          CustomShapeElement(id: 'shape1', shapeType: 'rect', xMm: 0, yMm: 0, widthMm: 10, heightMm: 10, zIndex: 0),
        ]
      );
      
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

    test('CustomTextElement JSON serialization retains textAlign and caseFormat', () {
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

    test('CustomTextElement defaults textAlign and caseFormat on missing json keys', () {
      final json = {
        'id': 'txt1',
        'text': 'hello',
        'xMm': 10,
        'yMm': 20,
      };
      final deserialized = CustomTextElement.fromJson(json);
      expect(deserialized.textAlign, 'left');
      expect(deserialized.caseFormat, 'normal');
    });
  });
}
