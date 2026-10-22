import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_export.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/export/export_header_resolver.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:path/path.dart' as p;

void main() {
  final columns = dataTableColumnsFromHeader(const [
    'specimen::fieldNumber',
    'mammalAttribute::hindFootLength',
    'specimen::remark',
    'part::remark',
  ]);
  final rows = [
    const DataTableRecordRow(
      key: 'r1',
      values: {
        'specimen::fieldNumber': 'F-1',
        'mammalAttribute::hindFootLength': '20',
        'specimen::remark': 'ok',
        'part::remark': 'frozen',
        'mammalAttribute::unit': 'cm',
      },
    ),
    const DataTableRecordRow(
      key: 'r2',
      values: {'specimen::fieldNumber': 'F-2'},
    ),
  ];
  const dwc = {
    'specimen::fieldNumber': DwcSourceMapping(headers: ['recordNumber']),
    'mammalAttribute::hindFootLength': DwcSourceMapping(
      headers: ['measurementType', 'measurementValue', 'measurementUnit'],
      measurementType: 'hind foot length',
      measurementUnit: 'mm',
      measurementUnitSource: 'mammalAttribute::unit',
    ),
  };

  test('NAHPU keys and field names follow the visible columns', () {
    final keys = buildDataTableExport(
      columns: columns,
      rows: rows,
      header: DataTableExportHeader.nahpuKey,
    );
    expect(keys.headers, columns.map((column) => column.key));
    expect(keys.rows.first, ['F-1', '20', 'ok', 'frozen']);
    expect(keys.rows.last, ['F-2', '', '', '']);

    final names = buildDataTableExport(
      columns: columns,
      rows: rows,
      header: DataTableExportHeader.fieldName,
    );
    expect(names.headers, [
      'fieldNumber',
      'hindFootLength',
      'remark',
      'remark (part)',
    ]);
  });

  test('Darwin Core spreads measurements and keeps unmapped keys', () {
    final table = buildDataTableExport(
      columns: columns,
      rows: rows,
      header: DataTableExportHeader.darwinCore,
      dwc: dwc,
    );
    expect(table.headers, [
      'recordNumber',
      'measurementType',
      'measurementValue',
      'measurementUnit',
      'specimen::remark',
      'part::remark',
    ]);
    expect(table.rows.first, [
      'F-1',
      'hind foot length',
      '20',
      'cm',
      'ok',
      'frozen',
    ]);
    expect(table.rows.last, ['F-2', '', '', '', '', '']);
  });

  test('mapped-only leaves out columns without a Darwin Core term', () {
    final table = buildDataTableExport(
      columns: columns,
      rows: rows,
      header: DataTableExportHeader.darwinCore,
      mappedOnly: true,
      dwc: dwc,
    );
    expect(table.headers, [
      'recordNumber',
      'measurementType',
      'measurementValue',
      'measurementUnit',
    ]);
    expect(table.rows.last, hasLength(4));
  });

  test('the service reads every page and writes the table', () async {
    final dir = await Directory.systemTemp.createTemp('data_table_export');
    addTearDown(() => dir.delete(recursive: true));
    final pages = <int>[];
    (List<String>, List<List<String>>, String, String)? written;
    final service = DataTableExportService(
      loadPage: (query) async {
        pages.add(query.page);
        return DataTablePageData(
          columns: columns,
          rows: [rows[query.page]],
          totalRows: 2,
          page: query.page,
          pageCount: 2,
          rowsPerPage: query.rowsPerPage,
        );
      },
      resolveDwc: (keys) async => dwc,
      writer:
          ({
            required headers,
            required rows,
            required outputPath,
            required exportFormat,
          }) async {
            written = (headers, rows, outputPath, exportFormat);
          },
    );
    final file = await service.write(
      query: const DataTableQuery(),
      columns: columns,
      format: ExportFmt.excel,
      header: DataTableExportHeader.darwinCore,
      mappedOnly: true,
      fileStem: 'my table',
      directory: dir,
    );
    expect(pages, [0, 1]);
    expect(p.basename(file.path), 'my-table.xlsx');
    expect(written!.$2, hasLength(2));
    expect(written!.$3, file.path);
    expect(written!.$4, 'excel');
  });

  test('columns resolve through the tables their values are stored in', () {
    final columns = dataTableColumnsFromHeader(const [
      'specimen::genus',
      'part::tissueID',
      'measurement::lifeStage',
      'specimen::cataloger',
    ]);
    expect(dataTableDwcSourceKeys(columns[0]), contains('taxonomy::genus'));
    expect(
      dataTableDwcSourceKeys(columns[1]),
      contains('specimenPart::tissueID'),
    );
    expect(
      dataTableDwcSourceKeys(columns[2]),
      contains('birdAttribute::lifeStage'),
    );

    const genus = DwcSourceMapping(headers: ['dwc:genus']);
    const sample = DwcSourceMapping(headers: ['dwc:materialSampleID']);
    const stage = DwcSourceMapping(headers: ['dwc:lifeStage']);
    final picked = pickDataTableDwcMappings(columns, const {
      'taxonomy::genus': genus,
      'specimenPart::tissueID': sample,
      'mammalAttribute::lifeStage': stage,
      'birdAttribute::lifeStage': DwcSourceMapping(headers: ['other']),
    });
    expect(picked['specimen::genus'], same(genus));
    expect(picked['part::tissueID'], same(sample));
    // The first table that maps wins.
    expect(picked['measurement::lifeStage'], same(stage));
    expect(picked.containsKey('specimen::cataloger'), isFalse);
  });
}
