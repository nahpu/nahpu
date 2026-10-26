import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_export.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/export_field_catalog.dart';
import 'package:nahpu/services/settings/preset_transfer_service.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/export.dart' as rust_export;

/// The curation columns every log export starts with, in order.
enum TissueLogColumn {
  status,
  order,
  fieldId,
  tubeId,
  kind,
  type,
  treatment,
  field,
  value,
  location,
  box,
  cell,
  previousValue,
  previousLocation,
  replaced,
}

/// The columns a log export can add: those the specimen part export offers,
/// part fields first, plus the parasite table for parasite tubes.
Map<String, List<String>> tissueLogFieldGroups(
  Database db, [
  List<CustomFieldDefinitionData> customDefinitions = const [],
]) {
  final parts = exportFieldGroups(
    db,
    RecordType.specimenParts,
    SpecimenRecordType.allTaxa,
    customDefinitions,
  );
  final parasites = exportFieldGroups(
    db,
    RecordType.parasites,
    SpecimenRecordType.allTaxa,
  );
  const first = ['specimenPart', 'customSpecimenPart', 'parasite'];
  final all = {...parts, 'parasite': ?parasites['parasite']};
  return {
    for (final table in first)
      if (all.containsKey(table)) table: all[table]!,
    for (final entry in all.entries)
      if (!first.contains(entry.key)) entry.key: entry.value,
  };
}

/// The words an export writes in the user's language.
class TissueLogLabels {
  const TissueLogLabels({
    required this.column,
    required this.field,
    required this.checked,
    required this.skipped,
    required this.part,
    required this.parasite,
    this.customFieldName = _noCustomName,
  });

  final String Function(TissueLogColumn column) column;
  final String Function(TissueCheckField field) field;
  final String checked;
  final String skipped;
  final String part;
  final String parasite;

  /// The name of a custom field key, or null for a table field.
  final String? Function(String key) customFieldName;

  static String? _noCustomName(String key) => null;
}

/// One logged tube with what an export reads from it. A checked tube has
/// its [entry]; a skipped one only its [label].
class TissueLogRow {
  const TissueLogRow({
    required this.label,
    this.entry,
    this.record,
    this.fieldId = '',
    this.values = const {},
  });

  final String label;
  final TissueCheckEntry? entry;

  /// The tube as stored now, or null when it is gone or a skipped scan
  /// matched several.
  final TissueItemRecord? record;
  final String fieldId;

  /// The tube's values by export key, as the specimen part or parasite
  /// export reads them.
  final Map<String, String> values;

  bool get isChecked => entry != null;
}

/// Parasite columns that hold what a part column holds, by part column.
/// Columns not listed share their name.
const Map<String, String> _parasiteColumns = {
  'tissueID': 'parasiteID',
  'type': 'category',
};

/// Lays out [rows] for export: the curation columns, then
/// [customColumns], keys from the specimen part export catalog.
///
/// A parasite reads a `specimenPart::` key from the matching parasite
/// column, so its parasite ID fills the tissue ID column. Part keys a
/// parasite lacks, and parasite keys on a part, stay empty.
DataTableExportTable buildTissueLogTable({
  required List<TissueLogRow> rows,
  required TissueLogLabels labels,
  List<String> customColumns = const [],
  TissueLogHeader header = TissueLogHeader.fieldName,
}) {
  return DataTableExportTable(
    headers: [
      for (final column in TissueLogColumn.values) labels.column(column),
      ..._customHeaders(customColumns, header, labels),
    ],
    rows: [
      for (final (index, row) in rows.indexed)
        [
          for (final column in TissueLogColumn.values)
            _curationValue(row, index, column, labels),
          for (final key in customColumns) _customValue(row, key),
        ],
    ],
  );
}

/// Headers for [keys]. Field names repeat across tables, such as
/// `remark`; a repeat falls back to its key so every header stays unique.
List<String> _customHeaders(
  List<String> keys,
  TissueLogHeader header,
  TissueLogLabels labels,
) {
  final used = {
    for (final column in TissueLogColumn.values) labels.column(column),
  };
  return [
    for (final key in keys)
      switch (header) {
        TissueLogHeader.nahpuKey => key,
        TissueLogHeader.fieldName => _unique(
          labels.customFieldName(key) ?? key.split('::').last,
          key,
          used,
        ),
      },
  ];
}

String _unique(String name, String key, Set<String> used) {
  final header = used.contains(name) ? key : name;
  used.add(header);
  return header;
}

String _curationValue(
  TissueLogRow row,
  int index,
  TissueLogColumn column,
  TissueLogLabels labels,
) {
  final entry = row.entry;
  final record = row.record;
  return switch (column) {
    TissueLogColumn.status => row.isChecked ? labels.checked : labels.skipped,
    TissueLogColumn.order => '${index + 1}',
    TissueLogColumn.fieldId => row.fieldId,
    TissueLogColumn.tubeId => record?.code ?? (record == null ? row.label : ''),
    TissueLogColumn.kind => switch (record?.kind ?? entry?.kind) {
      TissueItemKind.part => labels.part,
      TissueItemKind.parasite => labels.parasite,
      null => '',
    },
    TissueLogColumn.type => record?.type ?? record?.category ?? '',
    TissueLogColumn.treatment => record?.treatment ?? '',
    TissueLogColumn.field => entry == null ? '' : labels.field(entry.field),
    TissueLogColumn.value => entry?.value ?? '',
    TissueLogColumn.location => entry?.location ?? '',
    TissueLogColumn.box => entry == null ? '' : '${entry.boxNumber}',
    TissueLogColumn.cell => entry == null ? '' : _cellName(entry.cell),
    TissueLogColumn.previousValue => entry?.previousValue ?? '',
    TissueLogColumn.previousLocation => entry?.previousLocation ?? '',
    TissueLogColumn.replaced =>
      entry?.displaced.map((tube) => tube.label).join(', ') ?? '',
  };
}

/// The cell as row letter and column number, such as B6, whatever the
/// box's custom labels.
String _cellName(TissueCell cell) {
  return '${String.fromCharCode(65 + cell.row)}${cell.column + 1}';
}

String _customValue(TissueLogRow row, String key) {
  final record = row.record;
  if (record == null) return '';
  final separator = key.indexOf('::');
  final table = separator == -1 ? '' : key.substring(0, separator);
  final column = key.substring(separator + 2);
  if (record.isParasite) {
    if (table == 'specimenPart') {
      return row.values['parasite::${_parasiteColumns[column] ?? column}'] ??
          '';
    }
    if (table == 'customSpecimenPart') return '';
  } else if (table == 'parasite' || table == 'customParasite') {
    return '';
  }
  return row.values[key] ?? '';
}

typedef TissueLogRecordLoader =
    Future<Map<(TissueItemKind, int), TissueItemRecord>> Function(
      Iterable<(TissueItemKind, int)> keys,
    );
typedef TissueLogValueLoader =
    Future<Map<String, String>> Function(TissueItemRecord record);

/// Writes a tissue check session log to a tabular file: checked tubes in
/// the order they were placed, then skipped ones.
class TissueLogExportService {
  const TissueLogExportService({
    required this.recordsFor,
    required this.valuesFor,
    required this.fieldIdOf,
    this.writer = rust_export.writeTabularRecords,
  });

  final TissueLogRecordLoader recordsFor;

  /// Read only when the export has added columns.
  final TissueLogValueLoader valuesFor;
  final String Function(String specimenUuid) fieldIdOf;
  final DataTableTabularWriter writer;

  /// Reads each logged tube fresh. [entries] and [skipped] come newest
  /// first, as the session lists them.
  Future<List<TissueLogRow>> collectRows({
    required List<TissueCheckEntry> entries,
    required List<TissueSkipEntry> skipped,
    bool withValues = false,
  }) async {
    final records = await recordsFor({
      for (final entry in entries) (entry.kind, entry.itemId),
      for (final entry in skipped) ?entry.key,
    });
    Future<TissueLogRow> row(
      String label,
      (TissueItemKind, int)? key, [
      TissueCheckEntry? entry,
    ]) async {
      final record = key == null ? null : records[key];
      return TissueLogRow(
        label: label,
        entry: entry,
        record: record,
        fieldId: record == null ? '' : fieldIdOf(record.specimen.uuid),
        values: withValues && record != null
            ? await valuesFor(record)
            : const {},
      );
    }

    return [
      for (final entry in entries.reversed)
        await row(entry.label, (entry.kind, entry.itemId), entry),
      for (final entry in skipped.reversed) await row(entry.label, entry.key),
    ];
  }

  /// Writes the log into [directory] (the app documents folder when null)
  /// and returns the file.
  Future<File> write({
    required List<TissueCheckEntry> entries,
    required List<TissueSkipEntry> skipped,
    required TissueLogLabels labels,
    required ExportFmt format,
    required String fileStem,
    List<String> customColumns = const [],
    TissueLogHeader header = TissueLogHeader.fieldName,
    Directory? directory,
  }) async {
    final rows = await collectRows(
      entries: entries,
      skipped: skipped,
      withValues: customColumns.isNotEmpty,
    );
    final table = buildTissueLogTable(
      rows: rows,
      labels: labels,
      customColumns: customColumns,
      header: header,
    );
    final output = await AppIOServices(
      dir: directory,
      fileStem: PresetTransferService.safeFileStem(fileStem, 'tissue_log'),
      ext: dataTableExportExtension(format),
    ).getSavePath();
    await writer(
      headers: table.headers,
      rows: table.rows,
      outputPath: output.path,
      exportFormat: format.name,
    );
    return output;
  }
}
