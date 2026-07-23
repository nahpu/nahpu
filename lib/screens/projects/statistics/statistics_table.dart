import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/services/export/statistics_exporter.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/types/controllers.dart';
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
  final isSmallScreen = MediaQuery.sizeOf(context).width < 600;
  final exportSurface = _TabularExportDialog(
    title: title,
    defaultFileName: defaultFileName,
    headers: headers,
    rows: rows,
    isSheet: isSmallScreen,
  );
  if (isSmallScreen) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => exportSurface,
    );
  }
  return showDialog<void>(
    context: context,
    builder: (context) => exportSurface,
  );
}

class _TabularExportDialog extends StatefulWidget {
  const _TabularExportDialog({
    required this.title,
    required this.defaultFileName,
    required this.headers,
    required this.rows,
    required this.isSheet,
  });

  final String title;
  final String defaultFileName;
  final List<String> headers;
  final List<List<String>> rows;
  final bool isSheet;

  @override
  State<_TabularExportDialog> createState() => _TabularExportDialogState();
}

class _TabularExportDialogState extends State<_TabularExportDialog> {
  late final FileOpCtrModel _exportCtr;
  Directory? _directory;
  File? _exportedFile;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _exportCtr = FileOpCtrModel.empty()
      ..fileNameCtr.text = widget.defaultFileName;
  }

  @override
  void dispose() {
    _exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = FileSettingsCard(
      exportCtr: _exportCtr,
      selectedDir: _directory,
      onExportFmtChanged: (value) {
        if (value == null) return;
        setState(() {
          _exportCtr.exportFmtCtr = value;
          _exportedFile = null;
        });
      },
      onFileNameChanged: (_) => _resetExport(),
      onSelectDir: _selectDirectory,
      onClearDir: () => setState(() {
        _directory = null;
        _exportedFile = null;
      }),
    );
    final exportAction = ExportShareButton(
      hasExported: _exportedFile != null,
      isRunning: _isRunning,
      onExport: _canExport ? _export : null,
      onShare: _share,
    );
    if (widget.isSheet) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              settings,
              const SizedBox(height: 8),
              exportAction,
            ],
          ),
        ),
      );
    }
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(child: settings),
      ),
      actions: [
        TextButton(
          onPressed: _isRunning ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        exportAction,
      ],
    );
  }

  bool get _canExport =>
      !_isRunning && widget.rows.isNotEmpty && _exportCtr.isValid;

  void _resetExport() {
    if (mounted) setState(() => _exportedFile = null);
  }

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
      final format = _exportCtr.exportFmtCtr;
      final extension = switch (format) {
        ExportFmt.excel => 'xlsx',
        _ => format.name,
      };
      final file = await AppIOServices(
        dir: _directory,
        fileStem: _exportCtr.fileNameCtr.text.trim(),
        ext: extension,
      ).getSavePath();
      await const StatisticsTableExporter().writeRows(
        file,
        format,
        headers: widget.headers,
        rows: widget.rows,
      );
      if (mounted) {
        setState(() => _exportedFile = file);
        _showSavedPath(file);
      }
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

  void _showSavedPath(File file) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          systemPlatform == PlatformType.desktop
              ? 'Exported to $file'
              : 'Export complete!',
        ),
      ),
    );
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
