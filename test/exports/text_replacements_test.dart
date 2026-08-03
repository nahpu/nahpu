import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/text_replacements.dart';

void main() {
  group('text replacements', () {
    test('exact matching replaces every literal occurrence', () {
      expect(
        applyTextReplacementRules('A.a A.a', const [
          TextReplacementRule(pattern: 'A.a', replacement: 'X'),
        ]),
        'X X',
      );
    });

    test('exact matching can ignore case without treating text as regex', () {
      expect(
        applyTextReplacementRules('Cat cAt C.t', const [
          TextReplacementRule(
            pattern: 'cat',
            replacement: 'dog',
            caseSensitive: false,
          ),
        ]),
        'dog dog C.t',
      );
    });

    test('regex supports captures, whole matches, and literal dollars', () {
      expect(
        applyTextReplacementRules('AB-12 CD-34', const [
          TextReplacementRule(
            pattern: r'([A-Z]+)-(\d+)',
            replacement: r'$2/$1 [$0] $$',
            matchType: TextReplacementMatchType.regex,
          ),
        ]),
        r'12/AB [AB-12] $ 34/CD [CD-34] $',
      );
    });

    test('rules run sequentially and may replace with blank text', () {
      expect(
        applyTextReplacementRules('red red', const [
          TextReplacementRule(pattern: 'red', replacement: 'blue'),
          TextReplacementRule(pattern: 'blue ', replacement: ''),
        ]),
        'blue',
      );
    });

    test('invalid imported rules are skipped safely', () {
      expect(
        applyTextReplacementRules('abc', const [
          TextReplacementRule(
            pattern: '(',
            replacement: 'invalid',
            matchType: TextReplacementMatchType.regex,
          ),
          TextReplacementRule(pattern: 'a', replacement: 'A'),
        ]),
        'Abc',
      );
      expect(
        validateTextReplacementRule(
          const TextReplacementRule(
            pattern: '(',
            replacement: '',
            matchType: TextReplacementMatchType.regex,
          ),
        ),
        contains('Invalid regular expression'),
      );
    });

    test('unavailable capture references stay literal', () {
      expect(
        applyTextReplacementRules('A', const [
          TextReplacementRule(
            pattern: r'(A)',
            replacement: r'$2',
            matchType: TextReplacementMatchType.regex,
          ),
        ]),
        r'$2',
      );
    });
  });
}
