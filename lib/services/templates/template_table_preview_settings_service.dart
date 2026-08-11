import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class TemplateTablePreviewSettingsService {
  const TemplateTablePreviewSettingsService();

  Future<List<String>> getColumns(Database db) async {
    final stored = await rust_config.getTemplateTablePreviewColumns();
    final normalized = normalizePrintSpecimenTableColumnIds(
      stored ?? const [],
      db,
    );
    if (normalized.isNotEmpty) return normalized;
    return normalizePrintSpecimenTableColumnIds(
      List<String>.from(kDefaultPrintSpecimenTableColumnIds),
      db,
    );
  }

  Future<List<String>> saveColumns({
    required Database db,
    required List<String> previousOrder,
    required List<String> selectedColumns,
  }) async {
    final selected = selectedColumns.toSet();
    final merged = <String>[];
    for (final column in previousOrder) {
      if (selected.remove(column)) merged.add(column);
    }
    final remaining = selected.toList()
      ..sort(
        (left, right) => specimenColumnDisplayTitle(left)
            .toLowerCase()
            .compareTo(specimenColumnDisplayTitle(right).toLowerCase()),
      );
    merged.addAll(remaining);

    var normalized = normalizePrintSpecimenTableColumnIds(merged, db);
    if (normalized.isEmpty) {
      normalized = normalizePrintSpecimenTableColumnIds(
        List<String>.from(kDefaultPrintSpecimenTableColumnIds),
        db,
      );
    }
    await rust_config.setTemplateTablePreviewColumns(columns: normalized);
    return normalized;
  }
}
