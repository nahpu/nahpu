/// Text type used to render grouped template fields as rich Markdown content.
const String kTemplateNestedListTextType = 'nestedList';

/// Formats grouped fields as a Markdown table.
const String kTemplateNestedListTableFormat = 'table';

/// Formats grouped fields as a sequence of Markdown cards.
const String kTemplateNestedListCardListFormat = 'cardList';

/// Whether [textType] renders rich Markdown instead of plain text.
bool isTemplateRichTextType(String textType) {
  return textType == 'markdown' || textType == kTemplateNestedListTextType;
}

/// Expands nested-list placeholders only when [textType] is Nested List.
///
/// This prevents ordinary text fields with the same placeholders from being
/// converted into Markdown tables or card lists.
String expandNestedListTextIfEnabled({
  required String text,
  required String textType,
  required Map<String, String> fieldValues,
  required String formatOption,
  String? caseFormat,
}) {
  if (textType != kTemplateNestedListTextType) return text;
  return expandNestedListPlaceholders(
      text, fieldValues, formatOption, caseFormat);
}

/// Expands `[namespace::*]` placeholders into a Markdown table or card list.
///
/// Each key in [fieldValues] with the matching `namespace::` prefix becomes a
/// column. Pipe-delimited values form rows, making this work for any record
/// type that exposes repeated related data through the standard field map.
String expandNestedListPlaceholders(
  String template,
  Map<String, String> fieldValues,
  String formatOption, [
  String? caseFormat,
]) {
  final wildcardExpanded = template.replaceAllMapped(
    RegExp(r'\[([A-Za-z0-9_-]+)::\*\]'),
    (match) => _formatNamespace(
      namespace: match.group(1)!,
      fieldValues: fieldValues,
      formatOption: formatOption,
      caseFormat: caseFormat,
    ),
  );
  if (wildcardExpanded != template) return wildcardExpanded;

  final placeholders = RegExp(
    r'\[([A-Za-z0-9_-]+)::([A-Za-z0-9_-]+)(?:\?\?[^\]]*)?\]',
  )
      .allMatches(template)
      .map(
        (match) => (
          namespace: match.group(1)!,
          field: match.group(2)!,
        ),
      )
      .toList(growable: false);
  if (placeholders.isNotEmpty) {
    final namespace = placeholders.first.namespace;
    if (placeholders.any((placeholder) => placeholder.namespace != namespace)) {
      return template;
    }
    return _formatNamespace(
      namespace: namespace,
      fieldValues: fieldValues,
      formatOption: formatOption,
      fields: placeholders.map((placeholder) => placeholder.field).toList(),
      caseFormat: caseFormat,
    );
  }

  final shortFields = RegExp(r'\[([A-Za-z0-9_-]+)(?:\?\?[^\]]*)?\]')
      .allMatches(template)
      .map((match) => match.group(1)!)
      .toSet()
      .toList(growable: false);
  if (shortFields.isEmpty) return template;
  return _formatFields(
    shortFields
        .map((field) => MapEntry(field, _lookupShortField(field, fieldValues)))
        .toList(growable: false),
    formatOption,
    caseFormat,
  );
}

String _formatNamespace({
  required String namespace,
  required Map<String, String> fieldValues,
  required String formatOption,
  List<String>? fields,
  String? caseFormat,
}) {
  final prefix = '${namespace.toLowerCase()}::';
  final fieldEntries = fields == null
      ? (fieldValues.entries
          .where((entry) => entry.key.toLowerCase().startsWith(prefix))
          .map(
            (entry) =>
                MapEntry(entry.key.substring(prefix.length), entry.value),
          )
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key)))
      : fields.toSet().map((field) {
          final key = '$namespace::$field';
          String? value;
          for (final entry in fieldValues.entries) {
            if (entry.key.toLowerCase() == key.toLowerCase()) {
              value = entry.value;
              break;
            }
          }
          return MapEntry(field, value ?? '');
        }).toList(growable: false);
  if (fieldEntries.isEmpty) return '';

  return _formatFields(fieldEntries, formatOption, caseFormat);
}

String _formatFields(
  List<MapEntry<String, String>> fields,
  String formatOption, [
  String? caseFormat,
]) {
  final values = fields
      .map((field) =>
          field.value.split('|').map((value) => value.trim()).toList())
      .toList(growable: false);
  final rowCount = values.fold<int>(
      0, (count, field) => field.length > count ? field.length : count);
  if (rowCount == 0) return '';

  final rows = List.generate(
    rowCount,
    (row) => List.generate(
      fields.length,
      (column) => row < values[column].length ? values[column][row] : '',
    ),
    growable: false,
  );
  return formatOption == kTemplateNestedListCardListFormat
      ? _formatCards(fields, rows, caseFormat)
      : _formatTable(fields, rows, caseFormat);
}

String _lookupShortField(String field, Map<String, String> values) {
  final lowerField = field.toLowerCase();
  String? emptyMatch;
  for (final entry in values.entries) {
    final key = entry.key.toLowerCase();
    if (key != lowerField && key.split('::').last != lowerField) continue;
    if (entry.value.isNotEmpty) return entry.value;
    emptyMatch ??= entry.value;
  }
  return emptyMatch ?? '';
}

String _formatTable(
  List<MapEntry<String, String>> fields,
  List<List<String>> rows, [
  String? caseFormat,
]) {
  final headers = fields
      .map((field) => _displayFieldName(field.key, caseFormat))
      .join(' | ');
  final divider = List.filled(fields.length, '---').join(' | ');
  final body = rows
      .map((row) => '| ${row.map(_escapeTableCell).join(' | ')} |')
      .join('\n');
  return '| $headers |\n| $divider |\n$body';
}

String _formatCards(
  List<MapEntry<String, String>> fields,
  List<List<String>> rows, [
  String? caseFormat,
]) {
  return rows.asMap().entries.map((entry) {
    final details = List.generate(
      fields.length,
      (column) {
        final value = entry.value[column];
        if (value.isEmpty) return null;
        return '- **${_displayFieldName(fields[column].key, caseFormat)}:** $value';
      },
    ).whereType<String>().join('\n');
    return '**${entry.key + 1}**${details.isEmpty ? '' : '\n$details'}';
  }).join('\n\n');
}

String _displayFieldName(String field, [String? caseFormat]) {
  final spaced = field.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  final result = spaced.replaceAll('_', ' ').trim();
  if (result.isEmpty) return result;

  final cf =
      (caseFormat == null || caseFormat == 'normal') ? 'title' : caseFormat;
  switch (cf) {
    case 'uppercase':
      return result.toUpperCase();
    case 'lowercase':
      return result.toLowerCase();
    case 'sentence':
      final lower = result.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    case 'title':
    default:
      return result.split(' ').map((word) {
        if (word.isEmpty) return word;
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }).join(' ');
  }
}

String _escapeTableCell(String value) {
  return value.replaceAll('|', r'\|').replaceAll('\n', '<br>');
}
