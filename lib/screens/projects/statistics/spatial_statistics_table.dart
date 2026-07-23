import 'package:flutter/material.dart';
import 'package:nahpu/services/statistics/spatial.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

class SpatialStatisticsTable extends StatefulWidget {
  const SpatialStatisticsTable({
    super.key,
    required this.kind,
    required this.rows,
    this.onExport,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final VoidCallback? onExport;

  @override
  State<SpatialStatisticsTable> createState() => _SpatialStatisticsTableState();
}

class _SpatialStatisticsTableState extends State<SpatialStatisticsTable> {
  int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final availableRows = <int>[10, 25, 50]
        .where((value) => value <= widget.rows.length || value == 10)
        .toList(growable: false);
    if (!availableRows.contains(_rowsPerPage)) {
      _rowsPerPage = availableRows.last;
    }

    final hasCounts = widget.kind.hasCounts;
    final total = spatialStatisticTotal(widget.rows);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: PaginatedDataTable(
        header: const SizedBox.shrink(),
        actions: [
          IconButton(
            tooltip: 'Export table',
            onPressed: widget.onExport,
            icon: const Icon(Icons.file_upload_outlined),
          ),
        ],
        showEmptyRows: false,
        rowsPerPage: _rowsPerPage,
        availableRowsPerPage: availableRows,
        onRowsPerPageChanged: (value) {
          if (value != null) setState(() => _rowsPerPage = value);
        },
        source: _SpatialStatisticsDataSource(
          rows: widget.rows,
          hasCounts: hasCounts,
          total: total,
        ),
        columns: hasCounts ? _metricColumns : _coordinateColumns,
      ),
    );
  }
}

const _coordinateColumns = [
  DataColumn(label: Text('Name')),
  DataColumn(label: Text('Locality')),
  DataColumn(label: Text('Decimal Latitude'), numeric: true),
  DataColumn(label: Text('Decimal Longitude'), numeric: true),
  DataColumn(label: Text('Elevation (m)'), numeric: true),
  DataColumn(label: Text('Datum')),
  DataColumn(label: Text('Uncertainty (m)'), numeric: true),
  DataColumn(label: Text('GPS Unit')),
  DataColumn(label: Text('Notes')),
];

const _metricColumns = [
  DataColumn(label: Text('Name')),
  DataColumn(label: Text('Locality')),
  DataColumn(label: Text('Latitude'), numeric: true),
  DataColumn(label: Text('Longitude'), numeric: true),
  DataColumn(label: Text('Elevation (m)'), numeric: true),
  DataColumn(label: Text('Count'), numeric: true),
  DataColumn(label: Text('Percent'), numeric: true),
];

class _SpatialStatisticsDataSource extends DataTableSource {
  _SpatialStatisticsDataSource({
    required this.rows,
    required this.hasCounts,
    required this.total,
  });

  final List<SpatialStatisticDatum> rows;
  final bool hasCounts;
  final int total;

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    final row = rows[index];
    return DataRow.byIndex(
      index: index,
      cells: hasCounts ? _metricCells(row) : _coordinateCells(row),
    );
  }

  List<DataCell> _coordinateCells(SpatialStatisticDatum row) => [
    DataCell(_constrainedText(row.displayName)),
    DataCell(_constrainedText(formatCoordinateText(row.locality))),
    DataCell(Text(formatCoordinate(row.decimalLatitude, decimals: 6))),
    DataCell(Text(formatCoordinate(row.decimalLongitude, decimals: 6))),
    DataCell(Text(formatCoordinate(row.elevationInMeter, decimals: 2))),
    DataCell(_constrainedText(formatCoordinateText(row.datum))),
    DataCell(Text(formatCoordinateInteger(row.uncertaintyInMeters))),
    DataCell(_constrainedText(formatCoordinateText(row.gpsUnit))),
    DataCell(_notesCell(row.notes)),
  ];

  List<DataCell> _metricCells(SpatialStatisticDatum row) => [
    DataCell(_constrainedText(row.displayName)),
    DataCell(_constrainedText(formatCoordinateText(row.locality))),
    DataCell(Text(formatCoordinate(row.decimalLatitude, decimals: 6))),
    DataCell(Text(formatCoordinate(row.decimalLongitude, decimals: 6))),
    DataCell(Text(formatCoordinate(row.elevationInMeter, decimals: 2))),
    DataCell(Text((row.count ?? 0).toString())),
    DataCell(
      Text('${spatialStatisticPercent(row, total).toStringAsFixed(1)}%'),
    ),
  ];

  Widget _notesCell(String? notes) {
    final text = formatCoordinateText(notes);
    return Tooltip(message: text, child: _constrainedText(text, maxWidth: 280));
  }

  Widget _constrainedText(String text, {double maxWidth = 220}) =>
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(text, overflow: TextOverflow.ellipsis),
      );

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}
