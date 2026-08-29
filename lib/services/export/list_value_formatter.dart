import 'package:nahpu/services/export/common.dart';

const Set<String> kTemplateListFormatOptions = {
  'pipe',
  'comma',
  'semicolon',
  'slash',
  'newline',
  'bullet',
};

bool isTemplateListFormatOption(String value) =>
    kTemplateListFormatOptions.contains(value) ||
    value == 'custom' ||
    value.startsWith('custom:');

/// Returns a supported persisted list format, repairing legacy values.
String normalizeTemplateListFormatOption(String value) {
  if (value == 'custom') return 'custom:';
  return isTemplateListFormatOption(value) ? value : 'pipe';
}

/// Splits NAHPU's canonical pipe-delimited repeated value.
///
/// Empty entries are retained so indexed and nested-record exports keep their
/// positional alignment.
List<String> splitNahpuRepeatedValue(String value) {
  if (value.isEmpty) return const [];
  return value
      .split(writerSeparator)
      .map((item) => item.trim())
      .toList(growable: false);
}

/// Formats already-separated list items using the selected presentation.
String formatTemplateListItems(Iterable<String> values, String formatOption) {
  final items = values
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  if (items.isEmpty) return '';

  final option = normalizeTemplateListFormatOption(formatOption);
  if (option.startsWith('custom:')) {
    return items.join(option.substring(7));
  }

  return switch (option) {
    'pipe' => items.join(' | '),
    'comma' => items.join(', '),
    'semicolon' => items.join('; '),
    'slash' => items.join(' / '),
    'newline' => items.join('\n'),
    'bullet' => items.map((item) => '• $item').join('\n'),
    _ => items.join(' | '),
  };
}

/// Formats a raw template value as a list.
///
/// Pipe is NAHPU's internal repeated-value delimiter. The semicolon-space
/// fallback preserves templates created before that contract was standardized.
String formatTemplateListValue(String value, String formatOption) {
  final items = value.contains(writerSeparator)
      ? splitNahpuRepeatedValue(value)
      : value.contains('; ')
      ? value.split('; ')
      : <String>[value];
  return formatTemplateListItems(items, formatOption);
}
