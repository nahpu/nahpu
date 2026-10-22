import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/export/export_header_resolver.dart';
import 'package:nahpu/services/settings/preset_transfer_service.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/dwc.dart' as rust_dwc;
import 'package:nahpu/src/rust/api/export.dart' as rust_export;

/// File formats the data table exports.
const List<ExportFmt> dataTableExportFormats = [
  ExportFmt.csv,
  ExportFmt.tsv,
  ExportFmt.excel,
];

/// Rows read per page while collecting records for an export.
const int dataTableExportBatch = 200;

String dataTableExportExtension(ExportFmt format) => switch (format) {
  ExportFmt.csv => 'csv',
  ExportFmt.tsv => 'tsv',
  ExportFmt.excel => 'xlsx',
  ExportFmt.json => 'json',
};

String dataTableExportFormatLabel(ExportFmt format) => switch (format) {
  ExportFmt.csv => 'Comma-separated (.csv)',
  ExportFmt.tsv => 'Tab-separated (.tsv)',
  ExportFmt.excel => 'Excel (.xlsx)',
  ExportFmt.json => 'JSON (.json)',
};

/// How exported columns are named.
enum DataTableExportHeader {
  /// The NAHPU export key, such as `specimen::fieldNumber`.
  nahpuKey('NAHPU keys'),

  /// The field name the table shows.
  fieldName('Field names'),

  /// Darwin Core terms for mapped fields; other fields keep their NAHPU key.
  darwinCore('Darwin Core');

  const DataTableExportHeader(this.label);

  final String label;
}

/// Headers and rows ready to write.
class DataTableExportTable {
  const DataTableExportTable({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;
}

/// Lays out [rows] for export with the [columns] shown, in their order.
///
/// With [DataTableExportHeader.darwinCore], a mapped field takes its terms
/// from [dwc]; a measurement spreads over `measurementType`,
/// `measurementValue`, and `measurementUnit`. Unmapped fields keep their
/// NAHPU key, or are left out when [mappedOnly] is set.
DataTableExportTable buildDataTableExport({
  required List<DataTableColumn> columns,
  required List<DataTableRecordRow> rows,
  required DataTableExportHeader header,
  bool mappedOnly = false,
  Map<String, DwcSourceMapping> dwc = const {},
}) {
  if (header != DataTableExportHeader.darwinCore) {
    return DataTableExportTable(
      headers: [
        for (final column in columns)
          header == DataTableExportHeader.fieldName ? column.label : column.key,
      ],
      rows: [
        for (final row in rows)
          [for (final column in columns) row.values[column.key] ?? ''],
      ],
    );
  }
  final included = [
    for (final column in columns)
      if (!mappedOnly || dwc.containsKey(column.key)) column,
  ];
  return DataTableExportTable(
    headers: [
      for (final column in included)
        ...dwc[column.key]?.headers ?? [column.key],
    ],
    rows: [
      for (final row in rows)
        [
          for (final column in included)
            ..._darwinCoreValues(row, column, dwc[column.key]),
        ],
    ],
  );
}

List<String> _darwinCoreValues(
  DataTableRecordRow row,
  DataTableColumn column,
  DwcSourceMapping? mapping,
) {
  final value = row.values[column.key] ?? '';
  if (mapping == null) return [value];
  if (!mapping.isMeasurement) {
    return List<String>.filled(mapping.headers.length, value);
  }
  if (value.trim().isEmpty) return const ['', '', ''];
  final unitSource = mapping.measurementUnitSource;
  final unit = unitSource == null ? null : row.values[unitSource]?.trim();
  return [
    mapping.measurementType!,
    value,
    unit != null && unit.isNotEmpty ? unit : mapping.measurementUnit ?? '',
  ];
}

/// Data table keys the Darwin Core mapper knows by another name: the
/// tables the values are stored in rather than their export headers.
const Map<String, List<String>> _dwcSourceAliases = {
  'specimen::specimenUUID': ['specimen::uuid'],
  'specimen::order': ['taxonomy::taxonOrder'],
  'specimen::family': ['taxonomy::taxonFamily'],
  'specimen::genus': ['taxonomy::genus'],
  'specimen::specificEpithet': ['taxonomy::specificEpithet'],
  'site::site': ['site::siteID'],
  'geography::specificLocality': ['geography::locality'],
  'event::collEventID': ['event::id'],
};

/// Keys the Darwin Core mapper may know [column] by, best first: its own
/// key, then the table its value is stored in. A `measurement::` field
/// tries each taxon's attribute table.
List<String> dataTableDwcSourceKeys(DataTableColumn column) {
  final name = column.key.split('::').last;
  final tables = column.field.attributeTables.isNotEmpty
      ? column.field.attributeTables
      : dataTableAttributeTables;
  return [
    column.key,
    ...?_dwcSourceAliases[column.key],
    if (column.group == 'part') 'specimenPart::$name',
    if (column.group == 'event') 'collEvent::$name',
    if (column.group == 'measurement')
      for (final table in tables) '${table.table}::$name',
  ];
}

/// Picks each column's mapping from [resolved], which is keyed by mapper
/// source key, and keys it by the column instead.
Map<String, DwcSourceMapping> pickDataTableDwcMappings(
  List<DataTableColumn> columns,
  Map<String, DwcSourceMapping> resolved,
) {
  final picked = <String, DwcSourceMapping>{};
  for (final column in columns) {
    for (final key in dataTableDwcSourceKeys(column)) {
      final mapping = resolved[key];
      if (mapping == null) continue;
      picked[column.key] = mapping;
      break;
    }
  }
  return picked;
}

/// Darwin Core mappings for [keys], through the published `nahpu_dwc`
/// mapper. Unmapped keys are left out.
Future<Map<String, DwcSourceMapping>> resolveDataTableDwcMappings(
  List<String> keys,
) async {
  final resolved = await rust_dwc.getDwcHeaders(sourceKeys: keys);
  return {
    for (final entry in resolved)
      entry.sourceKey: DwcSourceMapping(
        headers: entry.headers,
        measurementType: entry.measurementType,
        measurementUnit: entry.measurementUnit,
        measurementUnitSource: entry.measurementUnitSource,
      ),
  };
}

typedef DataTableExportPageLoader =
    Future<DataTablePageData> Function(DataTableQuery query);
typedef DataTableDwcResolver =
    Future<Map<String, DwcSourceMapping>> Function(List<String> keys);
typedef DataTableTabularWriter =
    Future<void> Function({
      required List<String> headers,
      required List<List<String>> rows,
      required String outputPath,
      required String exportFormat,
    });

/// Writes every record a data table query matches, with its visible
/// columns, to a tabular file.
class DataTableExportService {
  const DataTableExportService({
    required this.loadPage,
    this.resolveDwc = resolveDataTableDwcMappings,
    this.writer = rust_export.writeTabularRecords,
  });

  final DataTableExportPageLoader loadPage;
  final DataTableDwcResolver resolveDwc;
  final DataTableTabularWriter writer;

  /// Reads every page of [query], in its sort order. [onProgress] gets the
  /// records read so far and the total.
  Future<List<DataTableRecordRow>> collectRows(
    DataTableQuery query, {
    void Function(int done, int total)? onProgress,
  }) async {
    final rows = <DataTableRecordRow>[];
    for (var page = 0; ; page++) {
      final data = await loadPage(
        query.copyWith(page: page, rowsPerPage: dataTableExportBatch),
      );
      rows.addAll(data.rows);
      onProgress?.call(rows.length, data.totalRows);
      if (page + 1 >= data.pageCount || data.rows.isEmpty) break;
    }
    return rows;
  }

  /// Writes the export into [directory] (the app documents folder when
  /// null) and returns the file.
  Future<File> write({
    required DataTableQuery query,
    required List<DataTableColumn> columns,
    required ExportFmt format,
    required DataTableExportHeader header,
    required String fileStem,
    bool mappedOnly = false,
    Directory? directory,
    void Function(int done, int total)? onProgress,
  }) async {
    final rows = await collectRows(query, onProgress: onProgress);
    final dwc = header == DataTableExportHeader.darwinCore
        ? pickDataTableDwcMappings(
            columns,
            await resolveDwc([
              for (final column in columns) ...dataTableDwcSourceKeys(column),
            ]),
          )
        : const <String, DwcSourceMapping>{};
    final table = buildDataTableExport(
      columns: columns,
      rows: rows,
      header: header,
      mappedOnly: mappedOnly,
      dwc: dwc,
    );
    if (table.headers.isEmpty) {
      throw const FormatException(
        'None of the visible columns map to Darwin Core.',
      );
    }
    final output = await AppIOServices(
      dir: directory,
      fileStem: PresetTransferService.safeFileStem(fileStem, 'data_table'),
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
