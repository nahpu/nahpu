import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/conditional_brackets.dart';
import 'package:nahpu/services/export/document_writer.dart';

void main() {
  group('conditional brackets', () {
    test('matches trimmed, case-sensitive conditions', () {
      const condition = ConditionalBracketCondition(
        sourceField: 'mammalAttribute::accuracy',
        operator: ConditionalComparisonOperator.equals,
        comparisonValue: 'Tail cropped',
      );

      expect(
        conditionalBracketConditionsMatch(
          [condition],
          ConditionalMatchMode.any,
          (_) => ' Tail cropped ',
        ),
        isTrue,
      );
      expect(
        conditionalBracketConditionsMatch(
          [condition],
          ConditionalMatchMode.any,
          (_) => 'tail cropped',
        ),
        isFalse,
      );
    });

    test('does not match missing fields for not-equals', () {
      const condition = ConditionalBracketCondition(
        sourceField: 'accuracy',
        operator: ConditionalComparisonOperator.notEquals,
        comparisonValue: 'Accurate',
      );

      expect(
        conditionalBracketConditionsMatch(
          [condition],
          ConditionalMatchMode.any,
          (_) => '',
        ),
        isFalse,
      );
    });

    test('parses and serializes inline template expressions', () {
      const text =
          '[[totalLength][accuracy=="Tail cropped"||accuracy=="Partially eaten"]]';
      final expression = parseConditionalBracketExpression(text, 0);

      expect(expression, isNotNull);
      expect(expression!.targetField, 'totalLength');
      expect(expression.matchMode, ConditionalMatchMode.any);
      expect(expression.conditions, hasLength(2));
      expect(expression.toTemplateSyntax(), text);
    });

    test('rejects mixed AND and OR inline conditions', () {
      const text =
          '[[totalLength][accuracy=="Tail cropped"&&sex=="0"||age=="1"]]';
      expect(parseConditionalBracketExpression(text, 0), isNull);
    });

    test('does not double bracket values', () {
      expect(addConditionalBrackets('12'), '[12]');
      expect(addConditionalBrackets('[12]'), '[12]');
      expect(addConditionalBrackets(''), '');
    });

    test(
        'substitutes an inline conditional placeholder without wrapping labels',
        () {
      const text = 'TTL: [[totalLength][accuracy=="Tail cropped"]] mm';
      final value = substituteDocumentPlaceholders(text, {
        'mammalAttribute::totalLength': '123',
        'mammalAttribute::accuracy': 'Tail cropped',
      });

      expect(value, 'TTL: [123] mm');
    });

    test('renders an unmatched inline conditional placeholder normally', () {
      const text = '[[totalLength][accuracy=="Tail cropped"]]';
      final value = substituteDocumentPlaceholders(text, {
        'mammalAttribute::totalLength': '123',
        'mammalAttribute::accuracy': 'Accurate',
      });

      expect(value, '123');
    });
  });
}
