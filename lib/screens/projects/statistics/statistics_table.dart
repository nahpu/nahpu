import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/services/export/statistics_exporter.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/types/statistics.dart';

class StatisticDataTable extends StatefulWidget {
  const StatisticDataTable({
    super.key,
    required this.rows,
    required this.onExport,
  });

  final List<StatisticTableRow> rows;
  final VoidCallback? onExport;

  @override
  State<StatisticDataTable> createState() => _StatisticDataTableState();
}

class _StatisticDataTableState extends State<StatisticDataTable> {
  int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final availableRows = <int>[10, 25, 50]
        .where((value) => value <= widget.rows.length || value == 10)
        .toList(growable: false);
    if (!availableRows.contains(_rowsPerPage)) {
      _rowsPerPage = availableRows.last;
    }

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
        source: _StatisticDataSource(widget.rows),
        columns: const [
          DataColumn(label: Text('Rank'), numeric: true),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Count'), numeric: true),
          DataColumn(label: Text('Percent'), numeric: true),
        ],
      ),
    );
  }
}

class _StatisticDataSource extends DataTableSource {
  _StatisticDataSource(this.rows);

  final List<StatisticTableRow> rows;

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    final row = rows[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(row.rank.toString())),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(row.category, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(Text(row.count.toString())),
        DataCell(Text('${row.percent.toStringAsFixed(1)}%')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}

Future<void> showStatisticExportDialog({
  required BuildContext context,
  required String defaultFileName,
  required List<StatisticTableRow> rows,
}) {
  return showTabularExportDialog(
    context: context,
    title: 'Export statistics table',
    defaultFileName: defaultFileName,
    headers: const ['Rank', 'Category', 'Count', 'Percent (%)'],
    rows: [
      for (final row in rows)
        [
          row.rank.toString(),
          row.category,
          row.count.toString(),
          row.percent.toStringAsFixed(2),
        ],
    ],
  );
}

Future<void> showSpatialStatisticExportDialog({
  required BuildContext context,
  required String defaultFileName,
  required SpatialStatisticKind kind,
  required List<SpatialStatisticDatum> rows,
}) {
  return showTabularExportDialog(
    context: context,
    title: 'Export spatial statistics table',
    defaultFileName: defaultFileName,
    headers: spatialStatisticExportHeaders(kind),
    rows: buildSpatialStatisticExportRows(kind, rows),
  );
}

Future<void> showTabularExportDialog({
  required BuildContext context,
  required String title,
  required String defaultFileName,
  required List<String> headers,
  required List<List<String>> rows,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _TabularExportDialog(
      title: title,
      defaultFileName: defaultFileName,
      headers: headers,
      rows: rows,
    ),
  );
}

class _TabularExportDialog extends StatefulWidget {
  const _TabularExportDialog({
    required this.title,
    required this.defaultFileName,
    required this.headers,
    required this.rows,
  });

  final String title;
  final String defaultFileName;
  final List<String> headers;
  final List<List<String>> rows;

  @override
  State<_TabularExportDialog> createState() => _TabularExportDialogState();
}

class _TabularExportDialogState extends State<_TabularExportDialog> {
  late final TextEditingController _fileNameController;
  ExportFmt _format = ExportFmt.csv;
  Directory? _directory;
  File? _exportedFile;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: widget.defaultFileName);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<ExportFmt>(
                segments: const [
                  ButtonSegment(value: ExportFmt.csv, label: Text('CSV')),
                  ButtonSegment(value: ExportFmt.tsv, label: Text('TSV')),
                  ButtonSegment(value: ExportFmt.excel, label: Text('Excel')),
                ],
                selected: {_format},
                onSelectionChanged: (selection) {
                  setState(() {
                    _format = selection.single;
                    _exportedFile = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _fileNameController,
                decoration: const InputDecoration(labelText: 'File name'),
                onChanged: (_) => setState(() => _exportedFile = null),
              ),
              const SizedBox(height: 12),
              SelectDirField(
                dirPath: _directory,
                onPressed: _selectDirectory,
                onCanceled: () => setState(() {
                  _directory = null;
                  _exportedFile = null;
                }),
              ),
              if (_exportedFile != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Exported to ${_exportedFile!.path}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isRunning ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (_exportedFile == null)
          ProgressButton(
            label: 'Export',
            icon: Icons.file_upload_outlined,
            isRunning: _isRunning,
            onPressed: _canExport ? _export : null,
          )
        else
          ShareButton(onPressed: _share),
      ],
    );
  }

  bool get _canExport =>
      !_isRunning &&
      widget.rows.isNotEmpty &&
      _fileNameController.text.trim().isNotEmpty;

  Future<void> _selectDirectory() async {
    final directory = await FilePickerServices().selectDir();
    if (directory != null && mounted) {
      setState(() {
        _directory = directory;
        _exportedFile = null;
      });
    }
  }

  Future<void> _export() async {
    setState(() => _isRunning = true);
    try {
      final extension = switch (_format) {
        ExportFmt.excel => 'xlsx',
        _ => _format.name,
      };
      final file = await AppIOServices(
        dir: _directory,
        fileStem: _fileNameController.text.trim(),
        ext: extension,
      ).getSavePath();
      await const StatisticsTableExporter().writeRows(
        file,
        _format,
        headers: widget.headers,
        rows: widget.rows,
      );
      if (mounted) setState(() => _exportedFile = file);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to export statistics: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final file = _exportedFile;
    if (file == null) return;
    try {
      await FilePickerServices().shareFile(context, file);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to share statistics: $error')),
        );
      }
    }
  }
}
