import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
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

    test('not-equals matches a populated different value', () {
      const condition = ConditionalBracketCondition(
        sourceField: 'accuracy',
        operator: ConditionalComparisonOperator.notEquals,
        comparisonValue: 'Accurate',
      );

      expect(
        conditionalBracketConditionsMatch(
          [condition],
          ConditionalMatchMode.any,
          (_) => 'Tail cropped',
        ),
        isTrue,
      );
      expect(
        conditionalBracketConditionsMatch(
          [condition],
          ConditionalMatchMode.any,
          (_) => 'Accurate',
        ),
        isFalse,
      );
    });

    test('combines multiple conditions using any and all', () {
      const conditions = [
        ConditionalBracketCondition(
          sourceField: 'accuracy',
          operator: ConditionalComparisonOperator.equals,
          comparisonValue: 'Tail cropped',
        ),
        ConditionalBracketCondition(
          sourceField: 'remarks',
          operator: ConditionalComparisonOperator.contains,
          comparisonValue: 'damaged',
        ),
      ];
      const values = {
        'accuracy': 'Tail cropped',
        'remarks': 'No damage recorded',
      };

      expect(
        conditionalBracketConditionsMatch(
          conditions,
          ConditionalMatchMode.any,
          (field) => values[field],
        ),
        isTrue,
      );
      expect(
        conditionalBracketConditionsMatch(
          conditions,
          ConditionalMatchMode.all,
          (field) => values[field],
        ),
        isFalse,
      );
      expect(
        conditionalBracketConditionsMatch(
          conditions,
          ConditionalMatchMode.all,
          (field) => field == 'accuracy' ? 'Tail cropped' : 'Wing damaged',
        ),
        isTrue,
      );
    });

    test('contains uses trimmed, case-sensitive substring matching', () {
      const condition = ConditionalBracketCondition(
        sourceField: 'specimen::remarks',
        operator: ConditionalComparisonOperator.contains,
        comparisonValue: 'Tail',
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

    test('mammal accuracy contains matches current and legacy values', () {
      const tailCondition = ConditionalBracketCondition(
        sourceField: 'mammalAttribute::accuracy',
        operator: ConditionalComparisonOperator.contains,
        comparisonValue: 'tailLength',
      );
      const forearmCondition = ConditionalBracketCondition(
        sourceField: 'mammalMeasurement::accuracy',
        operator: ConditionalComparisonOperator.contains,
        comparisonValue: 'forearm',
      );
      const totalLengthCondition = ConditionalBracketCondition(
        sourceField: 'mammalAttribute::accuracy',
        operator: ConditionalComparisonOperator.contains,
        comparisonValue: 'totalLength',
      );

      bool matches(ConditionalBracketCondition condition, String value) =>
          conditionalBracketConditionsMatch(
            [condition],
            ConditionalMatchMode.any,
            (_) => value,
          );

      expect(matches(tailCondition, 'inaccurate:tailLength,weight'), isTrue);
      expect(matches(tailCondition, 'Tail cropped'), isTrue);
      expect(matches(tailCondition, 'Partially eaten'), isTrue);
      expect(matches(tailCondition, 'Other reason'), isTrue);
      expect(matches(tailCondition, 'Other'), isTrue);
      expect(matches(totalLengthCondition, 'Partially eaten'), isTrue);
      expect(matches(totalLengthCondition, 'Other reason'), isTrue);
      expect(matches(totalLengthCondition, 'Other'), isTrue);
      expect(matches(tailCondition, 'Ear damaged'), isFalse);
      expect(matches(tailCondition, 'accurate'), isFalse);
      expect(matches(forearmCondition, 'All measurements inaccurate'), isTrue);
    });

    test('auto-configures mammal accuracy for full and short targets', () {
      const condition = ConditionalBracketCondition(
        sourceField: '',
        operator: ConditionalComparisonOperator.equals,
        comparisonValue: '',
      );

      for (final target in [
        'mammalAttribute::tailLength',
        'mammalMeasurement::tailLength',
        'tailLength',
      ]) {
        final configured = conditionalBracketConditionForSource(
          condition,
          sourceField: 'mammalAttribute::accuracy',
          targetField: target,
        );
        expect(configured.operator, ConditionalComparisonOperator.contains);
        expect(configured.comparisonValue, 'tailLength');
      }
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

    test('parses and serializes contains inline expressions', () {
      const text = '[[tailLength][mammalAttribute::accuracy~="tailLength"]]';
      final expression = parseConditionalBracketExpression(text, 0);

      expect(expression, isNotNull);
      expect(
        expression!.conditions.single.operator,
        ConditionalComparisonOperator.contains,
      );
      expect(expression.toTemplateSyntax(), text);
    });

    test('parses and serializes literal replacement expressions', () {
      const text =
          '[[sex][specimen::type=="holotype"]=>'
          '"TYPE [literal] \\"quoted\\""]]';
      final expression = parseConditionalBracketExpression(text, 0);

      expect(expression, isNotNull);
      expect(expression!.outputAction, ConditionalOutputAction.replacement);
      expect(expression.replacementText, 'TYPE [literal] "quoted"');
      expect(expression.toTemplateSyntax(), text);
    });

    test('rejects mixed AND and OR inline conditions', () {
      const text =
          '[[totalLength][accuracy=="Tail cropped"&&sex=="0"||age=="1"]]';
      expect(parseConditionalBracketExpression(text, 0), isNull);
    });

    test('rejects incomplete and unterminated inline conditions', () {
      expect(
        parseConditionalBracketExpression('[[totalLength][accuracy==]]', 0),
        isNull,
      );
      expect(
        parseConditionalBracketExpression(
          '[[totalLength][accuracy=="Tail cropped]]',
          0,
        ),
        isNull,
      );
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
      },
    );

    test('renders an unmatched inline conditional placeholder normally', () {
      const text = '[[totalLength][accuracy=="Tail cropped"]]';
      final value = substituteDocumentPlaceholders(text, {
        'mammalAttribute::totalLength': '123',
        'mammalAttribute::accuracy': 'Accurate',
      });

      expect(value, '123');
    });

    test('replaces a populated target with literal text when matched', () {
      const text = '[[sex][specimen::type=="holotype"]=>"[catalogNumber]"]]';
      final value = substituteDocumentPlaceholders(text, {
        'sex': '0',
        'specimen::type': 'holotype',
        'catalogNumber': 'ABC-1',
      });

      expect(value, '[catalogNumber]');
    });

    test('keeps the original replacement target when unmatched', () {
      const text = '[[sex][sex=="0"]=>"Male"]]';

      expect(substituteDocumentPlaceholders(text, const {'sex': '1'}), '1');
    });

    test('keeps blank fallback behavior for matched replacements', () {
      const text = '[[sex][specimen::type=="holotype"]=>"TYPE"]]';

      expect(
        substituteDocumentPlaceholders(text, const {
          'specimen::type': 'holotype',
        }, nullFallbackOption: kTemplateNullFallbackNa),
        'N/A',
      );
    });

    test('uses blank fallback when a conditional target is missing', () {
      const text = 'Length: [[totalLength][accuracy=="Tail cropped"]]';

      expect(
        substituteDocumentPlaceholders(text, {
          'mammalAttribute::accuracy': 'Tail cropped',
        }),
        'Length: ',
      );
    });

    test('uses every configured fallback for missing conditional targets', () {
      const text = '[[totalLength][accuracy=="Tail cropped"]]';
      const options = {
        kTemplateNullFallbackBlank: '',
        kTemplateNullFallbackField: 'totalLength',
        kTemplateNullFallbackNa: 'N/A',
        kTemplateNullFallbackNone: 'None',
        kTemplateNullFallbackCustom: 'Not recorded',
      };

      for (final entry in options.entries) {
        expect(
          substituteDocumentPlaceholders(
            text,
            const {'accuracy': 'Tail cropped'},
            nullFallbackOption: entry.key,
            customNullFallbackText: 'Not recorded',
          ),
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('uses every configured fallback for empty conditional targets', () {
      const text = '[[totalLength][accuracy=="Tail cropped"]]';
      const options = {
        kTemplateNullFallbackBlank: '',
        kTemplateNullFallbackField: 'totalLength',
        kTemplateNullFallbackNa: 'N/A',
        kTemplateNullFallbackNone: 'None',
        kTemplateNullFallbackCustom: 'Not recorded',
      };

      for (final entry in options.entries) {
        expect(
          substituteDocumentPlaceholders(
            text,
            const {'totalLength': '', 'accuracy': 'Tail cropped'},
            nullFallbackOption: entry.key,
            customNullFallbackText: 'Not recorded',
          ),
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('an empty custom fallback behaves as blank', () {
      expect(
        substituteDocumentPlaceholders(
          '[[totalLength][accuracy=="Tail cropped"]]',
          const {'accuracy': 'Tail cropped'},
          nullFallbackOption: kTemplateNullFallbackCustom,
        ),
        '',
      );
    });

    test('missing controlling fields never bracket populated targets', () {
      expect(
        substituteDocumentPlaceholders(
          '[[totalLength][accuracy!="Accurate"]]',
          const {'totalLength': '123'},
        ),
        '123',
      );
    });

    test('resolves full, short, and case-insensitive conditional keys', () {
      expect(
        substituteDocumentPlaceholders(
          '[[MAMMALATTRIBUTE::TOTALLENGTH][ACCURACY=="Tail cropped"]]',
          const {
            'mammalAttribute::totalLength': '123',
            'mammalAttribute::accuracy': 'Tail cropped',
          },
        ),
        '[123]',
      );
    });

    test('substitutes any and all inline condition groups', () {
      const values = {
        'totalLength': '123',
        'accuracy': 'Tail cropped',
        'remarks': 'Wing damaged',
      };

      expect(
        substituteDocumentPlaceholders(
          '[[totalLength][accuracy=="Accurate"||remarks~="damaged"]]',
          values,
        ),
        '[123]',
      );
      expect(
        substituteDocumentPlaceholders(
          '[[totalLength][accuracy=="Tail cropped"&&remarks~="damaged"]]',
          values,
        ),
        '[123]',
      );
      expect(
        substituteDocumentPlaceholders(
          '[[totalLength][accuracy=="Tail cropped"&&remarks~="missing"]]',
          values,
        ),
        '123',
      );
    });

    test('resolves nested placeholders through the shared template helper', () {
      expect(
        resolveDocumentTemplatePlaceholders(
          text: 'Length: [[totalLength][accuracy=="Tail cropped"]]',
          data: const {
            'mammalAttribute::totalLength': '123',
            'mammalAttribute::accuracy': 'Tail cropped',
          },
          textType: 'normal',
          formatOption: 'normal',
        ),
        'Length: [123]',
      );
    });

    test('substitutes a contains placeholder using legacy mammal accuracy', () {
      const text =
          '[[mammalAttribute::tailLength]'
          '[mammalAttribute::accuracy~="tailLength"]]';
      final value = substituteDocumentPlaceholders(text, {
        'mammalAttribute::tailLength': '123',
        'mammalAttribute::accuracy': 'Tail cropped',
      });

      expect(value, '[123]');
    });
  });
}
