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
}) {
  if (isTemplateBracketGenderIconText(input)) return input;
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
    final value = _lookupDocumentPlaceholderValue(k, data);
    if (value != null) {
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

String? _lookupDocumentPlaceholderValue(String key, Map<String, String> data) {
  final matches = <String>[];

  void add(String? value) {
    if (value != null) matches.add(value);
  }

  add(data[key]);

  final lower = key.toLowerCase();
  for (final e in data.entries) {
    if (e.key.toLowerCase() == lower) add(e.value);
  }

  final shortKey = key.contains('::') ? key.split('::').last : key;
  final shortLower = shortKey.toLowerCase();
  for (final e in data.entries) {
    if (e.key.split('::').last.toLowerCase() == shortLower) {
      add(e.value);
    }
  }

  if (matches.isEmpty) return null;
  for (final value in matches) {
    if (value.isNotEmpty) return value;
  }
  return matches.first;
}
