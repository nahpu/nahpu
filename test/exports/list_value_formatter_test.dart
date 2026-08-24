import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/list_value_formatter.dart';

void main() {
  group('splitNahpuRepeatedValue', () {
    test('accepts compact and spaced pipes while preserving blank slots', () {
      expect(splitNahpuRepeatedValue('A| B | |C'), ['A', 'B', '', 'C']);
      expect(splitNahpuRepeatedValue(''), isEmpty);
    });
  });

  group('formatTemplateListValue', () {
    const compact = 'A|B|C';

    test('formats every built-in separator', () {
      expect(formatTemplateListValue(compact, 'pipe'), 'A | B | C');
      expect(formatTemplateListValue(compact, 'comma'), 'A, B, C');
      expect(formatTemplateListValue(compact, 'semicolon'), 'A; B; C');
      expect(formatTemplateListValue(compact, 'slash'), 'A / B / C');
      expect(formatTemplateListValue(compact, 'newline'), 'A\nB\nC');
      expect(formatTemplateListValue(compact, 'bullet'), '• A\n• B\n• C');
    });

    test('preserves exact custom separators, including empty and pipes', () {
      expect(formatTemplateListValue(compact, 'custom: - '), 'A - B - C');
      expect(formatTemplateListValue(compact, 'custom: '), 'A B C');
      expect(formatTemplateListValue(compact, 'custom:'), 'ABC');
      expect(formatTemplateListValue(compact, 'custom:|;'), 'A|;B|;C');
    });

    test('drops blank values from concatenated output', () {
      expect(formatTemplateListValue(' A | | B | ', 'comma'), 'A, B');
      expect(formatTemplateListItems(['', ' A ', '', 'B'], 'pipe'), 'A | B');
    });

    test('supports legacy semicolon-space values', () {
      expect(formatTemplateListValue('A; B; C', 'slash'), 'A / B / C');
    });

    test('normalizes missing and unsupported legacy options to pipe', () {
      expect(normalizeTemplateListFormatOption('normal'), 'pipe');
      expect(normalizeTemplateListFormatOption(''), 'pipe');
      expect(formatTemplateListValue(compact, 'legacy'), 'A | B | C');
    });
  });
}
