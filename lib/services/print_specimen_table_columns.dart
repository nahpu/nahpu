import 'package:nahpu/services/database/database.dart';

/// Default columns for the print-labels specimen table (field ids from
/// [labelTemplateAvailableFieldIds]).
const List<String> kDefaultPrintSpecimenTableColumnIds = [
  'specimen::fieldNumber',
  'specimen::taxonGroup',
  'taxonomy::taxonClass',
  'taxonomy::species',
  'specimen::captureDate',
];

/// Human-readable title for a specimen column id (e.g. for UI).
String specimenColumnDisplayTitle(String columnId) {
  if (columnId.contains('::')) {
    final parts = columnId.split('::');
    final col = parts[1];
    return _formatCamelCase(col);
  }

  return _formatCamelCase(columnId);
}

String _formatCamelCase(String text) {
  text = text.replaceAll('iD', 'Id');
  return text
      .replaceAllMapped(RegExp(r'(?<=[a-z])([A-Z])'), (m) => ' ${m[1]}')
      .trim()
      .split(' ')
      .map((w) {
    if (w.isEmpty) return w;
    if (w.toLowerCase() == 'id') return 'ID';
    return '${w[0].toUpperCase()}${w.substring(1)}';
  }).join(' ');
}

/// All `[id]` values offered in the template editor sidebar and table selector.
List<String> labelTemplateAvailableFieldIds(Database db) {
  final out = <String>[];
  for (final table in db.allTables) {
    final tableName = table.actualTableName;
    for (final c in table.$columns) {
      out.add('$tableName::${c.name}');
    }
  }
  out.sort();
  return out;
}

/// Keeps saved field-id lists aligned with the current catalog.
List<String> normalizePrintSpecimenTableColumnIds(
  List<String> ids,
  Database db,
) {
  final allowed =
      labelTemplateAvailableFieldIds(db).map((e) => e.toLowerCase()).toSet();
  return ids.where((id) => allowed.contains(id.toLowerCase())).toList();
}
