part of '../document_writer.dart';

/// Converts a measurement in millimeters to its equivalent in typographical points.
/// A standard point is defined as 1/72 of an inch.
double documentPdfMmToPt(double mm) => mm * 72.0 / 25.4;

/// Replaces bracket placeholders in the provided [input] string with corresponding
/// values from the [data] map.
///
/// If a placeholder key (e.g. `[catalogNum]`) is found in [data], it is replaced
/// with the associated value. Matches are performed case-insensitively.
String substituteDocumentPlaceholders(
  String input,
  Map<String, String> data, {
  String nullFallbackOption = kTemplateNullFallbackBlank,
  String customNullFallbackText = '',
  String? textType,
  String? formatOption,
}) {
  if (isTemplateBracketSpecimenSexIconText(input)) return input;
  final isBlank = data['__blank__'] == 'true';
  return input.replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) {
    final placeholder = m.group(1)!.trim();
    final fallbackSplit = placeholder.split('??');
    final k = fallbackSplit.first.trim();
    final fallback = fallbackSplit.length > 1
        ? fallbackSplit.sublist(1).join('??').trim()
        : _nullFallbackForPlaceholder(
            k,
            nullFallbackOption,
            customNullFallbackText,
          );
    final lookup = _lookupDocumentPlaceholderValue(k, data);
    if (lookup != null) {
      var value = lookup.value;
      final resolvedKey = lookup.key;
      if (textType == 'encoded') {
        value = _mapEncodedValue(resolvedKey, value, formatOption);
      }
      return value.isEmpty && fallback != null ? fallback : value;
    }
    if (fallback != null) return fallback;
    return isBlank ? '' : m.group(0)!;
  });
}

String? _nullFallbackForPlaceholder(
  String key,
  String option,
  String customText,
) {
  if (key.endsWith('-img')) return null;
  return switch (option) {
    kTemplateNullFallbackField => key,
    kTemplateNullFallbackNa => 'N/A',
    kTemplateNullFallbackNone => 'None',
    kTemplateNullFallbackCustom =>
      customText.trim().isEmpty ? null : customText.trim(),
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

  if (data.containsKey(key)) {
    add(data[key], key);
  }

  final lower = key.toLowerCase();
  for (final e in data.entries) {
    if (e.key.toLowerCase() == lower) {
      add(e.value, e.key);
    }
  }

  final shortKey = key.contains('::') ? key.split('::').last : key;
  final shortLower = shortKey.toLowerCase();
  for (final e in data.entries) {
    if (e.key.split('::').last.toLowerCase() == shortLower) {
      add(e.value, e.key);
    }
  }

  if (matches.isEmpty) return null;
  for (final item in matches) {
    if (item.value.isNotEmpty) return item;
  }
  return matches.first;
}

String _mapEncodedValue(String key, String value, String? formatOption) {
  if (formatOption != null && formatOption.startsWith('custom_map:')) {
    final mapStr = formatOption.substring(11);
    final map = <String, String>{};
    for (final pair in mapStr.split(',')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        map[parts[0].trim()] = parts[1].trim();
      }
    }
    return map[value.trim()] ?? value;
  }
  return getEncodedDefaultValue(key, value) ?? value;
}
