import 'dart:convert';

import 'package:nahpu/services/specimens/specimen_attribute_names.dart';
import 'package:nahpu/services/types/mammals.dart';

/// The comparison used by a conditional bracket rule.
///
/// [isEmpty] and [isNotEmpty] ignore their comparison value and test only
/// whether the source field holds anything. They are written as `==""` and
/// `!=""`, so a comparison against the empty string reads the way it looks.
enum ConditionalComparisonOperator {
  equals,
  notEquals,
  contains,
  isEmpty,
  isNotEmpty,
}

/// How a group of conditional bracket rules is combined.
enum ConditionalMatchMode { any, all }

/// The output produced when a conditional template expression matches.
///
/// [text] belongs to conditional text, `[[if][conditions]=>"then"|"else"]]`,
/// which has no target field and writes one of its branch texts.
enum ConditionalOutputAction { brackets, replacement, text }

/// The target-slot keyword that marks conditional text.
const String kConditionalTextKeyword = 'if';

/// Placeholder marker that prints an encoded field's default label, as in
/// `[mammalAttribute::testisPosition#label]`.
const String kPlaceholderLabelMarker = '#label';

/// A single field comparison used to decide whether a value is bracketed.
///
/// Values are compared after trimming but remain case-sensitive. A blank
/// controlling value never matches, including for
/// [ConditionalComparisonOperator.notEquals]. The two emptiness operators are
/// the exception: they exist precisely to test for a blank value.
class ConditionalBracketCondition {
  const ConditionalBracketCondition({
    required this.sourceField,
    required this.operator,
    required this.comparisonValue,
  });

  final String sourceField;
  final ConditionalComparisonOperator operator;
  final String comparisonValue;

  /// Returns a copy with selected condition values replaced.
  ConditionalBracketCondition copyWith({
    String? sourceField,
    ConditionalComparisonOperator? operator,
    String? comparisonValue,
  }) {
    return ConditionalBracketCondition(
      sourceField: sourceField ?? this.sourceField,
      operator: operator ?? this.operator,
      comparisonValue: comparisonValue ?? this.comparisonValue,
    );
  }

  /// Restores a condition persisted in an export preset.
  factory ConditionalBracketCondition.fromJson(Map<String, dynamic> json) {
    return ConditionalBracketCondition(
      sourceField: canonicalizeSpecimenAttributeSourceKey(
        json['sourceField'] as String? ?? '',
      ),
      operator: ConditionalComparisonOperator.values.byName(
        json['operator'] as String? ??
            ConditionalComparisonOperator.equals.name,
      ),
      comparisonValue: json['comparisonValue'] as String? ?? '',
    );
  }

  /// Serializes this condition for an export preset payload.
  Map<String, dynamic> toJson() => {
    'sourceField': sourceField,
    'operator': operator.name,
    'comparisonValue': comparisonValue,
  };
}

/// Updates a condition's source and applies known source-specific defaults.
///
/// Mammal accuracy conditions use `Contains` with the target measurement's
/// stored field label. Both export presets and templates use this helper so
/// their automatic configuration remains identical.
ConditionalBracketCondition conditionalBracketConditionForSource(
  ConditionalBracketCondition condition, {
  required String sourceField,
  required String? targetField,
}) {
  final measurementField = _mammalAccuracyFieldForTarget(targetField);
  if (canonicalizeSpecimenAttributeSourceKey(sourceField) ==
          'mammalAttribute::accuracy' &&
      measurementField != null) {
    return condition.copyWith(
      sourceField: sourceField,
      operator: ConditionalComparisonOperator.contains,
      comparisonValue: measurementField,
    );
  }
  return condition.copyWith(sourceField: sourceField);
}

String? _mammalAccuracyFieldForTarget(String? targetField) {
  final normalized = targetField?.trim() ?? '';
  if (normalized.isEmpty) return null;
  if (!normalized.contains('::')) {
    return mammalAccuracyFieldOrder.contains(normalized) ? normalized : null;
  }
  final canonical = canonicalizeSpecimenAttributeSourceKey(normalized);
  const prefix = 'mammalAttribute::';
  if (!canonical.startsWith(prefix)) return null;
  final field = canonical.substring(prefix.length);
  return mammalAccuracyFieldOrder.contains(field) ? field : null;
}

/// A parsed inline template bracket expression.
///
/// Templates store expressions such as `[[target][field=="value"]]` and
/// `[[target][field~="value"]]`. The target
/// is bracketed only when [conditions] match using [matchMode].
///
/// Conditional text, `[[if][field!=""]=>"then"|"else"]]`, has no target. It
/// writes [replacementText] when the conditions match and [elseText] otherwise.
class ConditionalBracketExpression {
  const ConditionalBracketExpression({
    required this.targetField,
    required this.conditions,
    required this.matchMode,
    required this.start,
    required this.end,
    this.outputAction = ConditionalOutputAction.brackets,
    this.replacementText = '',
    this.elseText,
  });

  final String targetField;
  final List<ConditionalBracketCondition> conditions;
  final ConditionalMatchMode matchMode;
  final ConditionalOutputAction outputAction;

  /// Literal text emitted by [ConditionalOutputAction.replacement], or the text
  /// conditional text writes when its conditions match.
  final String replacementText;

  /// Text conditional text writes when its conditions do not match; `null`
  /// writes nothing.
  final String? elseText;

  /// Inclusive start offset in the containing text.
  final int start;

  /// Exclusive end offset in the containing text.
  final int end;

  /// Whether this is target-free conditional text rather than a field transform.
  bool get isConditionalText => outputAction == ConditionalOutputAction.text;

  /// Serializes this expression using the canonical inline template syntax.
  String toTemplateSyntax() {
    final joiner = matchMode == ConditionalMatchMode.any ? '||' : '&&';
    final conditionsText = conditions
        .map((condition) {
          final operator = switch (condition.operator) {
            ConditionalComparisonOperator.equals => '==',
            ConditionalComparisonOperator.notEquals ||
            ConditionalComparisonOperator.isNotEmpty => '!=',
            ConditionalComparisonOperator.contains => '~=',
            ConditionalComparisonOperator.isEmpty => '==',
          };
          final value = switch (condition.operator) {
            ConditionalComparisonOperator.isEmpty ||
            ConditionalComparisonOperator.isNotEmpty => '',
            _ => condition.comparisonValue,
          };
          return '${condition.sourceField}$operator${jsonEncode(value)}';
        })
        .join(joiner);
    if (outputAction == ConditionalOutputAction.text) {
      final elseValue = elseText;
      final elseSyntax = elseValue == null ? '' : '|${jsonEncode(elseValue)}';
      return '[[$kConditionalTextKeyword][$conditionsText]=>'
          '${jsonEncode(replacementText)}$elseSyntax]]';
    }
    if (outputAction == ConditionalOutputAction.replacement) {
      return '[[$targetField][$conditionsText]=>'
          '${jsonEncode(replacementText)}]]';
    }
    return '[[$targetField][$conditionsText]]';
  }
}

/// Returns whether [conditions] match [values].
///
/// [resolve] should return the raw stored value for a field. It deliberately
/// receives the original key so callers can support full and short field names.
bool conditionalBracketConditionsMatch(
  List<ConditionalBracketCondition> conditions,
  ConditionalMatchMode mode,
  String? Function(String field) resolve,
) {
  if (conditions.isEmpty) return false;
  final results = conditions.map((condition) {
    final actual = resolve(condition.sourceField)?.trim();
    final expected = condition.comparisonValue.trim();
    final blank = actual == null || actual.isEmpty;
    // The emptiness operators are the only ones a blank value can satisfy, so
    // they are answered before the shared blank guard below.
    switch (condition.operator) {
      case ConditionalComparisonOperator.isEmpty:
        return blank;
      case ConditionalComparisonOperator.isNotEmpty:
        return !blank;
      default:
        break;
    }
    if (blank || expected.isEmpty) return false;
    return switch (condition.operator) {
      ConditionalComparisonOperator.isEmpty ||
      ConditionalComparisonOperator.isNotEmpty => false,
      ConditionalComparisonOperator.equals => actual == expected,
      ConditionalComparisonOperator.notEquals => actual != expected,
      ConditionalComparisonOperator.contains => _containsComparisonMatches(
        condition.sourceField,
        actual,
        expected,
      ),
    };
  });
  return mode == ConditionalMatchMode.any
      ? results.any((value) => value)
      : results.every((value) => value);
}

bool _containsComparisonMatches(
  String sourceField,
  String actual,
  String expected,
) {
  if (canonicalizeSpecimenAttributeSourceKey(sourceField) ==
          'mammalAttribute::accuracy' &&
      mammalAccuracyFieldOrder.contains(expected)) {
    return parseMammalAccuracy(
      actual,
      includeBatFields: true,
    ).inaccurateFields.contains(expected);
  }
  return actual.contains(expected);
}

/// Wraps [value] in square brackets unless it is empty or already bracketed.
String addConditionalBrackets(String value) {
  if (value.isEmpty) return value;
  final trimmed = value.trim();
  if (trimmed.startsWith('[') && trimmed.endsWith(']')) return value;
  return '[$value]';
}

/// Splits a placeholder key from its `#label` marker.
///
/// Pass the key without any `??` fallback. `testisPosition#label` returns
/// `testisPosition` with `decode` set, so the caller prints the stored code's
/// default label instead of the code.
({String key, bool decode}) parsePlaceholderKey(String placeholder) {
  final key = placeholder.trim();
  if (!key.endsWith(kPlaceholderLabelMarker)) return (key: key, decode: false);
  return (
    key: key.substring(0, key.length - kPlaceholderLabelMarker.length).trim(),
    decode: true,
  );
}

/// Parses a conditional expression beginning at [start] in [text].
///
/// Returns `null` for malformed text. The parser is quote-aware so `]` inside
/// a JSON string comparison value does not terminate the expression.
/// Conditional text (`[[if]…]]`) must end with `=>` and its text; only it may
/// add an else text after `|`.
ConditionalBracketExpression? parseConditionalBracketExpression(
  String text,
  int start,
) {
  if (start < 0 || start + 3 >= text.length || !text.startsWith('[[', start)) {
    return null;
  }
  final divider = text.indexOf('][', start + 2);
  if (divider < 0) return null;
  final target = text.substring(start + 2, divider).trim();
  if (target.isEmpty) return null;

  var index = divider + 2;
  var inString = false;
  var escaped = false;
  var end = -1;
  while (index < text.length - 1) {
    final char = text[index];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char == '"') {
        inString = false;
      }
    } else if (char == '"') {
      inString = true;
    } else if (char == ']' && text[index + 1] == ']') {
      end = index + 2;
      break;
    }
    index++;
  }
  if (end < 0 || inString) return null;

  final body = text.substring(divider + 2, end - 2);
  final isConditionalText = target == kConditionalTextKeyword;
  final split = _splitConditionalBody(body, allowElse: isConditionalText);
  if (split == null) return null;
  // Conditional text has no value to bracket, so it must name its output.
  if (isConditionalText &&
      split.outputAction != ConditionalOutputAction.replacement) {
    return null;
  }
  final parsed = _parseConditionGroup(split.conditions);
  if (parsed == null) return null;
  return ConditionalBracketExpression(
    targetField: target,
    conditions: parsed.conditions,
    matchMode: parsed.mode,
    start: start,
    end: end,
    outputAction: isConditionalText
        ? ConditionalOutputAction.text
        : split.outputAction,
    replacementText: split.replacementText,
    elseText: split.elseText,
  );
}

({
  String conditions,
  ConditionalOutputAction outputAction,
  String replacementText,
  String? elseText,
})?
_splitConditionalBody(String body, {required bool allowElse}) {
  var inString = false;
  var escaped = false;
  for (var index = 0; index < body.length - 2; index++) {
    final char = body[index];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char == '"') {
        inString = false;
      }
      continue;
    }
    if (char == '"') {
      inString = true;
      continue;
    }
    if (!body.startsWith(']=>', index)) continue;
    final texts = _parseOutputTexts(body.substring(index + 3));
    if (texts == null || texts.length > (allowElse ? 2 : 1)) return null;
    return (
      conditions: body.substring(0, index),
      outputAction: ConditionalOutputAction.replacement,
      replacementText: texts.first,
      elseText: texts.length > 1 ? texts[1] : null,
    );
  }
  return (
    conditions: body,
    outputAction: ConditionalOutputAction.brackets,
    replacementText: '',
    elseText: null,
  );
}

/// Reads `"text"` or `"text"|"else"` from [input], allowing whitespace around
/// each part. Returns `null` for anything else.
List<String>? _parseOutputTexts(String input) {
  final texts = <String>[];
  var index = 0;
  while (true) {
    index = _skipWhitespace(input, index);
    if (index >= input.length || input[index] != '"') return null;
    final end = _jsonStringEnd(input, index);
    if (end == null) return null;
    try {
      final decoded = jsonDecode(input.substring(index, end));
      if (decoded is! String) return null;
      texts.add(decoded);
    } on Object {
      return null;
    }
    index = _skipWhitespace(input, end);
    if (index == input.length) return texts;
    if (input[index] != '|') return null;
    index++;
  }
}

/// Returns the exclusive end of the JSON string whose opening quote is at
/// [start], or `null` when it is not terminated.
int? _jsonStringEnd(String input, int start) {
  var escaped = false;
  for (var index = start + 1; index < input.length; index++) {
    final char = input[index];
    if (escaped) {
      escaped = false;
    } else if (char == r'\') {
      escaped = true;
    } else if (char == '"') {
      return index + 1;
    }
  }
  return null;
}

int _skipWhitespace(String input, int index) {
  var next = index;
  while (next < input.length && input[next].trim().isEmpty) {
    next++;
  }
  return next;
}

/// Returns every valid conditional bracket expression embedded in [text].
///
/// Invalid `[[` sequences are skipped so callers can still inspect the valid
/// expressions in a partially edited template.
List<ConditionalBracketExpression> conditionalBracketExpressionsInText(
  String text,
) {
  final expressions = <ConditionalBracketExpression>[];
  var index = 0;
  while (index < text.length) {
    final start = text.indexOf('[[', index);
    if (start < 0) break;
    final expression = parseConditionalBracketExpression(text, start);
    if (expression == null) {
      index = start + 2;
    } else {
      expressions.add(expression);
      index = expression.end;
    }
  }
  return expressions;
}

/// Returns the first field key [expression] reads, without modifiers.
///
/// A targeted conditional contributes its target. Conditional text contributes
/// the first placeholder in its branch texts, then its first condition field;
/// the `if` keyword is never a field. Used to name composite export columns.
String? firstExpressionFieldKey(String expression) {
  var index = 0;
  while (index < expression.length) {
    final start = expression.indexOf('[', index);
    if (start < 0) return null;
    final conditional = parseConditionalBracketExpression(expression, start);
    if (conditional != null) {
      final key = _conditionalFieldKey(conditional);
      if (key != null) return key;
      index = conditional.end;
      continue;
    }
    final end = expression.indexOf(']', start + 1);
    if (end < 0) return null;
    final key = _placeholderFieldKey(expression.substring(start + 1, end));
    if (key != null) return key;
    index = start + 1;
  }
  return null;
}

String? _conditionalFieldKey(ConditionalBracketExpression expression) {
  if (!expression.isConditionalText) {
    return _placeholderFieldKey(expression.targetField);
  }
  final elseText = expression.elseText;
  for (final text in [expression.replacementText, ?elseText]) {
    final key = firstExpressionFieldKey(text);
    if (key != null) return key;
  }
  for (final condition in expression.conditions) {
    final key = _placeholderFieldKey(condition.sourceField);
    if (key != null) return key;
  }
  return null;
}

String? _placeholderFieldKey(String placeholder) {
  final key = parsePlaceholderKey(placeholder.split('??').first).key;
  if (key.isEmpty || key.contains(RegExp(r'[\s\[]'))) return null;
  return key;
}

({List<ConditionalBracketCondition> conditions, ConditionalMatchMode mode})?
_parseConditionGroup(String input) {
  var index = 0;
  final conditions = <ConditionalBracketCondition>[];
  ConditionalMatchMode? mode;

  void skipWhitespace() {
    while (index < input.length && input[index].trim().isEmpty) {
      index++;
    }
  }

  while (true) {
    skipWhitespace();
    final fieldStart = index;
    while (index < input.length &&
        !input.startsWith('==', index) &&
        !input.startsWith('!=', index) &&
        !input.startsWith('~=', index)) {
      if (input.startsWith('&&', index) || input.startsWith('||', index)) {
        return null;
      }
      index++;
    }
    if (index >= input.length) return null;
    final field = input.substring(fieldStart, index).trim();
    if (field.isEmpty) return null;
    final operatorText = input.substring(index, index + 2);
    index += 2;
    skipWhitespace();
    if (index >= input.length || input[index] != '"') return null;
    final valueStart = index;
    final valueEnd = _jsonStringEnd(input, valueStart);
    if (valueEnd == null) return null;
    index = valueEnd;
    final jsonValue = input.substring(valueStart, index);
    String value;
    try {
      value = jsonDecode(jsonValue) as String;
    } on Object {
      return null;
    }
    // An empty comparison value is only meaningful as an emptiness test, and
    // `~=` has no emptiness form, so it stays invalid there.
    final isEmptinessTest = value.trim().isEmpty;
    if (isEmptinessTest && operatorText == '~=') return null;
    conditions.add(
      ConditionalBracketCondition(
        sourceField: field,
        operator: switch (operatorText) {
          '==' when isEmptinessTest => ConditionalComparisonOperator.isEmpty,
          '!=' when isEmptinessTest => ConditionalComparisonOperator.isNotEmpty,
          '==' => ConditionalComparisonOperator.equals,
          '!=' => ConditionalComparisonOperator.notEquals,
          '~=' => ConditionalComparisonOperator.contains,
          _ => throw StateError('Unsupported conditional operator.'),
        },
        comparisonValue: value,
      ),
    );

    skipWhitespace();
    if (index == input.length) break;
    if (index + 2 > input.length) return null;
    final joiner = input.substring(index, index + 2);
    final nextMode = switch (joiner) {
      '||' => ConditionalMatchMode.any,
      '&&' => ConditionalMatchMode.all,
      _ => null,
    };
    if (nextMode == null || (mode != null && mode != nextMode)) return null;
    mode = nextMode;
    index += 2;
  }
  if (conditions.isEmpty) return null;
  return (conditions: conditions, mode: mode ?? ConditionalMatchMode.any);
}
