import 'package:nahpu/services/data_table/data_table_grid_controller.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/providers/data_table.dart';

/// What the find bar looks for and what it puts in its place.
class DataTableFindOptions {
  const DataTableFindOptions({
    required this.text,
    this.replacement = '',
    this.columnKey,
    this.matchCase = false,
    this.wholeCell = false,
  });

  final String text;
  final String replacement;

  /// Limits the search to one column; null searches every visible column.
  final String? columnKey;
  final bool matchCase;

  /// Matches only a cell whose whole value is [text].
  final bool wholeCell;

  bool get isEmpty => text.isEmpty;

  RegExp get _pattern {
    final escaped = RegExp.escape(text);
    return RegExp(
      wholeCell ? '^$escaped\$' : escaped,
      caseSensitive: matchCase,
    );
  }

  bool includes(DataTableColumn column) =>
      columnKey == null || column.key == columnKey;

  bool matches(String value) => !isEmpty && _pattern.hasMatch(value);

  /// [value] with every match replaced. The replacement is used as typed.
  String replace(String value) =>
      isEmpty ? value : value.replaceAll(_pattern, replacement);
}

/// Text a cell shows: its pending edit, or the value as exported.
typedef DataTableCellText =
    String Function(DataTableRecordRow row, DataTableColumn column);

String dataTableShownText(DataTableRecordRow row, DataTableColumn column) =>
    row.values[column.key] ?? '';

/// Cells on the page whose shown text matches, row by row.
List<DataTableCellPos> findDataTableMatches(
  List<DataTableRecordRow> rows,
  List<DataTableColumn> columns,
  DataTableFindOptions options, {
  DataTableCellText textOf = dataTableShownText,
}) {
  if (options.isEmpty) return const [];
  return [
    for (var row = 0; row < rows.length; row++)
      for (var col = 0; col < columns.length; col++)
        if (options.includes(columns[col]) &&
            options.matches(textOf(rows[row], columns[col])))
          (row: row, col: col),
  ];
}

/// Edits a replace would make, with the cells it had to leave alone.
class DataTableReplacePlan {
  const DataTableReplacePlan({
    required this.edits,
    this.skippedChoices = 0,
    this.invalid = 0,
  });

  /// Each edit with the cell's stored value, as
  /// [DataTableEditController.commit] takes them.
  final List<(DataTableEdit, String)> edits;

  /// Matches in dropdown fields, which only take values from their list.
  final int skippedChoices;

  /// Replacements that don't fit their field, such as text in a number.
  final int invalid;

  int get recordCount =>
      {for (final (edit, _) in edits) edit.cell.recordKey}.length;
}

/// Plans replacing matches in the stored values of [rows].
///
/// Only plain editable fields change; read-only and linked columns are left
/// alone. [pendingOf] gives a cell's unsaved value, so a replace builds on
/// earlier edits.
DataTableReplacePlan planDataTableReplacements(
  DataTableRecordType type,
  List<DataTableRecordRow> rows,
  List<DataTableColumn> columns,
  DataTableFindOptions options, {
  String? Function(DataTableCellId cell)? pendingOf,
}) {
  if (options.isEmpty) return const DataTableReplacePlan(edits: []);
  final edits = <(DataTableEdit, String)>[];
  var skippedChoices = 0;
  var invalid = 0;
  for (final row in rows) {
    for (final column in columns) {
      if (!options.includes(column) ||
          !column.isEditableIn(type) ||
          column.linkIn(type) != null) {
        continue;
      }
      final cell = DataTableCellId(row.key, column.key);
      final stored = row.raw[column.key] ?? '';
      final current = pendingOf?.call(cell) ?? stored;
      if (!options.matches(current)) continue;
      if (dataTableHasChoices(column.field)) {
        skippedChoices++;
        continue;
      }
      final value = options.replace(current);
      if (value == current) continue;
      try {
        dataTableStoredValue(column.field, value);
      } on FormatException {
        invalid++;
        continue;
      }
      edits.add((
        DataTableEdit(
          cell: cell,
          field: column.field,
          value: value,
          row: row.raw,
          attributeTable: row.attributeTable,
        ),
        stored,
      ));
    }
  }
  return DataTableReplacePlan(
    edits: edits,
    skippedChoices: skippedChoices,
    invalid: invalid,
  );
}
