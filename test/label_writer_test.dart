import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/label_writer.dart';

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
}
