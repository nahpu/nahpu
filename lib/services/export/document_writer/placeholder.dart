part of '../document_writer.dart';

/// Converts a measurement in millimeters to its equivalent in typographical points.
double documentPdfMmToPt(double mm) => mm * 72.0 / 25.4;

/// Expands nested values and resolves ordinary and conditional placeholders
/// using the same record data used by template and PDF rendering.
String resolveDocumentTemplatePlaceholders({
  required String text,
  required Map<String, String> data,
  required String textType,
  required String formatOption,
  String? caseFormat,
  String nullFallbackOption = kTemplateNullFallbackBlank,
  String customNullFallbackText = '',
}) {
  final expanded = expandNestedListTextIfEnabled(
    text: text,
    textType: textType,
    fieldValues: data,
    formatOption: formatOption,
    caseFormat: caseFormat,
  );
  return substituteDocumentPlaceholders(
    expanded,
    data,
    nullFallbackOption: nullFallbackOption,
    customNullFallbackText: customNullFallbackText,
    textType: textType,
    formatOption: formatOption,
  );
}

/// Replaces ordinary and conditional bracket placeholders with record values.
///
/// Conditional template placeholders use comparisons such as
/// `[[target][field=="value"]]` and `[[target][field~="value"]]`. They are
/// evaluated against the same raw values as ordinary placeholders. Conditional
/// text, `[[if][field!=""]=>"then"|"else"]]`, writes the chosen branch with its
/// ordinary placeholders substituted. A `#label` marker, as in `[field#label]`,
/// prints an encoded field's default label.
String substituteDocumentPlaceholders(
  String input,
  Map<String, String> data, {
  String nullFallbackOption = kTemplateNullFallbackBlank,
  String customNullFallbackText = '',
  String? textType,
  String? formatOption,
}) {
  if (isTemplateBracketSpecimenSexIconText(input)) return input;
  return _substitutePlaceholders(
    input,
    data,
    evaluateConditionals: true,
    nullFallbackOption: nullFallbackOption,
    customNullFallbackText: customNullFallbackText,
    textType: textType,
    formatOption: formatOption,
  );
}

/// Substitutes the placeholders in [input].
///
/// Conditional text branches pass [evaluateConditionals] as `false`, so a
/// branch substitutes ordinary placeholders only.
String _substitutePlaceholders(
  String input,
  Map<String, String> data, {
  required bool evaluateConditionals,
  required String nullFallbackOption,
  required String customNullFallbackText,
  required String? textType,
  required String? formatOption,
}) {
  final isBlank = data['__blank__'] == 'true';
  final result = StringBuffer();
  var index = 0;
  while (index < input.length) {
    if (evaluateConditionals && input.startsWith('[[', index)) {
      final expression = parseConditionalBracketExpression(input, index);
      if (expression != null) {
        result.write(
          _resolveConditionalExpression(
            expression,
            data,
            isBlank: isBlank,
            nullFallbackOption: nullFallbackOption,
            customNullFallbackText: customNullFallbackText,
            textType: textType,
            formatOption: formatOption,
            original: input.substring(expression.start, expression.end),
          ),
        );
        index = expression.end;
        continue;
      }
    }
    if (input[index] == '[') {
      final end = input.indexOf(']', index + 1);
      if (end >= 0) {
        result.write(
          _resolvePlaceholder(
            input.substring(index + 1, end),
            data,
            isBlank: isBlank,
            nullFallbackOption: nullFallbackOption,
            customNullFallbackText: customNullFallbackText,
            textType: textType,
            formatOption: formatOption,
            original: input.substring(index, end + 1),
          ),
        );
        index = end + 1;
        continue;
      }
    }
    result.write(input[index]);
    index++;
  }
  return result.toString();
}

String _resolveConditionalExpression(
  ConditionalBracketExpression expression,
  Map<String, String> data, {
  required bool isBlank,
  required String nullFallbackOption,
  required String customNullFallbackText,
  required String? textType,
  required String? formatOption,
  required String original,
}) {
  if (expression.isConditionalText) {
    final matches = conditionalBracketConditionsMatch(
      expression.conditions,
      expression.matchMode,
      (field) => _lookupDocumentPlaceholderValue(field, data)?.value,
    );
    return _substitutePlaceholders(
      matches ? expression.replacementText : expression.elseText ?? '',
      data,
      evaluateConditionals: false,
      nullFallbackOption: nullFallbackOption,
      customNullFallbackText: customNullFallbackText,
      textType: textType,
      formatOption: formatOption,
    );
  }
  final targetKey = parsePlaceholderKey(
    expression.targetField.split('??').first,
  ).key;
  final lookup = _lookupDocumentPlaceholderValue(targetKey, data);
  if (lookup == null || lookup.value.trim().isEmpty) {
    return _resolvePlaceholder(
      expression.targetField,
      data,
      isBlank: isBlank,
      nullFallbackOption: nullFallbackOption,
      customNullFallbackText: customNullFallbackText,
      textType: textType,
      formatOption: formatOption,
      original: original,
    );
  }
  final value = _resolvePlaceholder(
    expression.targetField,
    data,
    isBlank: isBlank,
    nullFallbackOption: nullFallbackOption,
    customNullFallbackText: customNullFallbackText,
    textType: textType,
    formatOption: formatOption,
    original: original,
  );
  final matches = conditionalBracketConditionsMatch(
    expression.conditions,
    expression.matchMode,
    (field) => _lookupDocumentPlaceholderValue(field, data)?.value,
  );
  if (!matches) return value;
  return switch (expression.outputAction) {
    ConditionalOutputAction.brackets => addConditionalBrackets(value),
    ConditionalOutputAction.replacement ||
    ConditionalOutputAction.text => expression.replacementText,
  };
}

String _resolvePlaceholder(
  String rawPlaceholder,
  Map<String, String> data, {
  required bool isBlank,
  required String nullFallbackOption,
  required String customNullFallbackText,
  required String? textType,
  required String? formatOption,
  required String original,
}) {
  final placeholder = rawPlaceholder.trim();
  final fallbackSplit = placeholder.split('??');
  final parsedKey = parsePlaceholderKey(fallbackSplit.first);
  final key = parsedKey.key;
  final fallback = fallbackSplit.length > 1
      ? fallbackSplit.sublist(1).join('??').trim()
      : _nullFallbackForPlaceholder(
          key,
          nullFallbackOption,
          customNullFallbackText,
        );
  final lookup = _lookupDocumentPlaceholderValue(key, data);
  if (lookup != null) {
    var value = lookup.value;
    if (parsedKey.decode) {
      value = getEncodedDefaultValue(lookup.key, value) ?? value;
    }
    if (textType == 'encoded') {
      value = _mapEncodedValue(lookup.key, value, formatOption);
    }
    return value.isEmpty && fallback != null ? fallback : value;
  }
  if (fallback != null) return fallback;
  return isBlank ? '' : original;
}

String? _nullFallbackForPlaceholder(
  String key,
  String option,
  String customText,
) {
  if (key.endsWith('-img')) return null;
  return switch (option) {
    kTemplateNullFallbackBlank => '',
    kTemplateNullFallbackField => key,
    kTemplateNullFallbackNa => 'N/A',
    kTemplateNullFallbackNone => 'None',
    kTemplateNullFallbackCustom =>
      customText.trim().isEmpty ? '' : customText.trim(),
    _ => null,
  };
}

({String value, String key})? _lookupDocumentPlaceholderValue(
  String key,
  Map<String, String> data,
) {
  final matches = <({String value, String key})>[];

  void add(String? value, String matchedKey) {
    if (value != null) matches.add((value: value, key: matchedKey));
  }

  if (data.containsKey(key)) add(data[key], key);
  final lower = key.toLowerCase();
  for (final entry in data.entries) {
    if (entry.key.toLowerCase() == lower) add(entry.value, entry.key);
  }
  final shortKey = key.contains('::') ? key.split('::').last : key;
  final shortLower = shortKey.toLowerCase();
  for (final entry in data.entries) {
    if (entry.key.split('::').last.toLowerCase() == shortLower) {
      add(entry.value, entry.key);
    }
  }
  if (matches.isEmpty) return null;
  return matches.firstWhere(
    (item) => item.value.isNotEmpty,
    orElse: () => matches.first,
  );
}

String _mapEncodedValue(String key, String value, String? formatOption) {
  if (formatOption != null && formatOption.startsWith('custom_map:')) {
    final map = <String, String>{};
    for (final pair in formatOption.substring(11).split(',')) {
      final parts = pair.split('=');
      if (parts.length == 2) map[parts[0].trim()] = parts[1].trim();
    }
    return map[value.trim()] ?? value;
  }
  return getEncodedDefaultValue(key, value) ?? value;
}
