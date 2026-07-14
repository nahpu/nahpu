import 'dart:convert';

/// The comparison used by a conditional bracket rule.
enum ConditionalComparisonOperator { equals, notEquals }

/// How a group of conditional bracket rules is combined.
enum ConditionalMatchMode { any, all }

/// A single field comparison used to decide whether a value is bracketed.
///
/// Values are compared after trimming but remain case-sensitive. A blank
/// controlling value never matches, including for [ConditionalComparisonOperator.notEquals].
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
      sourceField: json['sourceField'] as String? ?? '',
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

/// A parsed inline template bracket expression.
///
/// Templates store expressions as `[[target][field=="value"]]`. The target
/// is bracketed only when [conditions] match using [matchMode].
class ConditionalBracketExpression {
  const ConditionalBracketExpression({
    required this.targetField,
    required this.conditions,
    required this.matchMode,
    required this.start,
    required this.end,
  });

  final String targetField;
  final List<ConditionalBracketCondition> conditions;
  final ConditionalMatchMode matchMode;

  /// Inclusive start offset in the containing text.
  final int start;

  /// Exclusive end offset in the containing text.
  final int end;

  /// Serializes this expression using the canonical inline template syntax.
  String toTemplateSyntax() {
    final joiner = matchMode == ConditionalMatchMode.any ? '||' : '&&';
    final conditionsText = conditions.map((condition) {
      final operator =
          condition.operator == ConditionalComparisonOperator.equals
              ? '=='
              : '!=';
      return '${condition.sourceField}$operator${jsonEncode(condition.comparisonValue)}';
    }).join(joiner);
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
    if (actual == null || actual.isEmpty || expected.isEmpty) return false;
    return switch (condition.operator) {
      ConditionalComparisonOperator.equals => actual == expected,
      ConditionalComparisonOperator.notEquals => actual != expected,
    };
  });
  return mode == ConditionalMatchMode.any
      ? results.any((value) => value)
      : results.every((value) => value);
}

/// Wraps [value] in square brackets unless it is empty or already bracketed.
String addConditionalBrackets(String value) {
  if (value.isEmpty) return value;
  final trimmed = value.trim();
  if (trimmed.startsWith('[') && trimmed.endsWith(']')) return value;
  return '[$value]';
}

/// Parses a conditional expression beginning at [start] in [text].
///
/// Returns `null` for malformed text. The parser is quote-aware so `]` inside
/// a JSON string comparison value does not terminate the expression.
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

  final conditionText = text.substring(divider + 2, end - 2);
  final parsed = _parseConditionGroup(conditionText);
  if (parsed == null) return null;
  return ConditionalBracketExpression(
    targetField: target,
    conditions: parsed.conditions,
    matchMode: parsed.mode,
    start: start,
    end: end,
  );
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
        !input.startsWith('!=', index)) {
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
    index++;
    var escaped = false;
    while (index < input.length) {
      final char = input[index];
      if (escaped) {
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char == '"') {
        index++;
        break;
      }
      index++;
    }
    if (index > input.length || input[index - 1] != '"') return null;
    final jsonValue = input.substring(valueStart, index);
    String value;
    try {
      value = jsonDecode(jsonValue) as String;
    } on Object {
      return null;
    }
    if (value.trim().isEmpty) return null;
    conditions.add(ConditionalBracketCondition(
      sourceField: field,
      operator: operatorText == '=='
          ? ConditionalComparisonOperator.equals
          : ConditionalComparisonOperator.notEquals,
      comparisonValue: value,
    ));

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
