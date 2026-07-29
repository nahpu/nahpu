/// How a text replacement rule identifies matching content.
enum TextReplacementMatchType { exact, regex }

/// One ordered text replacement applied to a rendered or exported value.
class TextReplacementRule {
  const TextReplacementRule({
    required this.pattern,
    required this.replacement,
    this.matchType = TextReplacementMatchType.exact,
    this.caseSensitive = true,
  });

  final String pattern;
  final String replacement;
  final TextReplacementMatchType matchType;
  final bool caseSensitive;

  TextReplacementRule copyWith({
    String? pattern,
    String? replacement,
    TextReplacementMatchType? matchType,
    bool? caseSensitive,
  }) {
    return TextReplacementRule(
      pattern: pattern ?? this.pattern,
      replacement: replacement ?? this.replacement,
      matchType: matchType ?? this.matchType,
      caseSensitive: caseSensitive ?? this.caseSensitive,
    );
  }

  factory TextReplacementRule.fromJson(Map<String, dynamic> json) {
    return TextReplacementRule(
      pattern: json['pattern'] as String? ?? '',
      replacement: json['replacement'] as String? ?? '',
      matchType: TextReplacementMatchType.values.byName(
        json['matchType'] as String? ?? TextReplacementMatchType.exact.name,
      ),
      caseSensitive: json['caseSensitive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'pattern': pattern,
    'replacement': replacement,
    'matchType': matchType.name,
    'caseSensitive': caseSensitive,
  };
}

/// Returns a user-facing validation error, or `null` when [rule] is valid.
String? validateTextReplacementRule(TextReplacementRule rule) {
  if (rule.pattern.isEmpty) return 'Find text cannot be empty.';
  if (rule.matchType == TextReplacementMatchType.regex) {
    try {
      RegExp(rule.pattern, caseSensitive: rule.caseSensitive);
    } on FormatException catch (error) {
      return 'Invalid regular expression: ${error.message}';
    }
  }
  return null;
}

/// Applies [rules] in order, replacing every match in the evolving value.
///
/// Invalid imported rules are skipped so rendering remains safe. Regex
/// replacements support `$0`, `$1` through `$n`, and `$$` for a literal `$`.
String applyTextReplacementRules(
  String value,
  Iterable<TextReplacementRule> rules,
) {
  var result = value;
  for (final rule in rules) {
    if (validateTextReplacementRule(rule) != null) continue;
    if (rule.matchType == TextReplacementMatchType.exact) {
      if (rule.caseSensitive) {
        result = result.replaceAll(rule.pattern, rule.replacement);
      } else {
        result = result.replaceAllMapped(
          RegExp(RegExp.escape(rule.pattern), caseSensitive: false),
          (_) => rule.replacement,
        );
      }
      continue;
    }
    final expression = RegExp(rule.pattern, caseSensitive: rule.caseSensitive);
    result = result.replaceAllMapped(
      expression,
      (match) => _expandRegexReplacement(rule.replacement, match),
    );
  }
  return result;
}

String _expandRegexReplacement(String replacement, Match match) {
  final output = StringBuffer();
  var index = 0;
  while (index < replacement.length) {
    if (replacement[index] != r'$') {
      output.write(replacement[index]);
      index++;
      continue;
    }
    if (index + 1 < replacement.length && replacement[index + 1] == r'$') {
      output.write(r'$');
      index += 2;
      continue;
    }
    var digitEnd = index + 1;
    while (digitEnd < replacement.length &&
        _isAsciiDigit(replacement.codeUnitAt(digitEnd))) {
      digitEnd++;
    }
    if (digitEnd == index + 1) {
      output.write(r'$');
      index++;
      continue;
    }
    final token = replacement.substring(index + 1, digitEnd);
    final group = int.parse(token);
    if (group <= match.groupCount) {
      output.write(match.group(group) ?? '');
    } else {
      output.write(r'$');
      output.write(token);
    }
    index = digitEnd;
  }
  return output.toString();
}

bool _isAsciiDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;
