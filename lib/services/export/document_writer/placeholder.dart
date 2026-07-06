part of '../document_writer.dart';

/// Converts a measurement in millimeters to its equivalent in typographical points.
/// A standard point is defined as 1/72 of an inch.
double documentPdfMmToPt(double mm) => mm * 72.0 / 25.4;

/// Replaces bracket placeholders in the provided [input] string with corresponding
/// values from the [data] map.
///
/// If a placeholder key (e.g. `[catalogNum]`) is found in [data], it is replaced
/// with the associated value. Matches are performed case-insensitively.
String substituteDocumentPlaceholders(String input, Map<String, String> data) {
  if (isTemplateBracketGenderIconText(input)) return input;
  final isBlank = data['__blank__'] == 'true';
  return input.replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) {
    final k = m.group(1)!.trim();
    if (data.containsKey(k)) return data[k]!;
    final lower = k.toLowerCase();
    for (final e in data.entries) {
      if (e.key.toLowerCase() == lower) return e.value;
    }
    return isBlank ? '' : m.group(0)!;
  });
}
