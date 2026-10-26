import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_export.dart';
import 'package:nahpu/services/export/export_destination.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Writes the export with the chosen settings and returns the file.
typedef DataTableExportWriter =
    Future<File> Function({
      required ExportFmt format,
      required DataTableExportHeader header,
      required bool mappedOnly,
      required String fileStem,
      required Directory? directory,
      required void Function(int done, int total) onProgress,
    });

/// Exports the records the table matches, with its visible columns, to a
/// tabular file.
class DataTableExportDialog extends StatefulWidget {
  const DataTableExportDialog({
    super.key,
    required this.recordCount,
    required this.columnCount,
    required this.defaultFileStem,
    required this.onExport,
    this.showCloseButton = true,
  });

  final int recordCount;
  final int columnCount;
  final String defaultFileStem;
  final DataTableExportWriter onExport;
  final bool showCloseButton;

  @override
  State<DataTableExportDialog> createState() => _DataTableExportDialogState();
}

class _DataTableExportDialogState extends State<DataTableExportDialog> {
  final _exportCtr = FileOpCtrModel.empty();
  final _destination = ExportDestinationService();
  DataTableExportHeader _header = DataTableExportHeader.nahpuKey;
  bool _mappedOnly = false;
  bool _appendDate = false;
  Directory? _selectedDir;
  File? _output;
  bool _isRunning = false;
  (int, int)? _progress;

  @override
  void initState() {
    super.initState();
    _exportCtr.fileNameCtr.text = widget.defaultFileStem;
  }

  @override
  void dispose() {
    _exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final records = context.l10n.dataTableRecordCount(widget.recordCount);
    final columns = context.l10n.dataTableColumnCount(widget.columnCount);
    final progress = _progress;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        NahpuSpacing.xl,
        NahpuSpacing.md,
        NahpuSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + NahpuSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.projectStatsExportTable,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (widget.showCloseButton)
                IconButton(
                  tooltip: context.l10n.commonClose,
                  icon: const Icon(Icons.close),
                  onPressed: _isRunning
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Text(
            context.l10n.dataTableExportSummary(records, columns),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: NahpuSpacing.lg),
          GenericFileSettingsCard<ExportFmt>(
            exportCtr: _exportCtr,
            selectedDir: _selectedDir,
            format: _exportCtr.exportFmtCtr,
            formats: dataTableExportFormats,
            formatLabel: dataTableExportFormatLabel,
            extensionForFormat: dataTableExportExtension,
            onFormatChanged: (value) => _reset(() {
              _exportCtr.exportFmtCtr = value;
            }),
            onFileNameChanged: (_) => _reset(() {}),
            appendDate: _appendDate,
            onAppendDateChanged: (value) => _reset(() => _appendDate = value),
            onSelectDir: _selectDirectory,
            onClearDir: () => _reset(() => _selectedDir = null),
            enabled: !_isRunning,
          ),
          const SizedBox(height: NahpuSpacing.lg),
          NahpuPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.dataTableColumnHeaders,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: NahpuSpacing.lg),
                SegmentedButton<DataTableExportHeader>(
                  segments: [
                    for (final value in DataTableExportHeader.values)
                      ButtonSegment(value: value, label: Text(value.label)),
                  ],
                  selected: {_header},
                  showSelectedIcon: false,
                  onSelectionChanged: _isRunning
                      ? null
                      : (value) => _reset(() => _header = value.single),
                ),
                if (_header == DataTableExportHeader.darwinCore)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.dataTableDwcOnly),
                    subtitle: Text(context.l10n.dataTableDwcOnlyBody),
                    value: _mappedOnly,
                    onChanged: _isRunning
                        ? null
                        : (value) => _reset(() => _mappedOnly = value),
                  ),
              ],
            ),
          ),
          if (_isRunning && progress != null) ...[
            const SizedBox(height: NahpuSpacing.lg),
            LinearProgressIndicator(
              value: progress.$2 == 0 ? null : progress.$1 / progress.$2,
            ),
            const SizedBox(height: NahpuSpacing.xs),
            Text(
              context.l10n.dataTableReadProgress(progress.$1, progress.$2),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: NahpuSpacing.xl),
          ExportShareButton(
            hasExported: _output != null,
            isRunning: _isRunning,
            onExport: _exportCtr.isValid && widget.recordCount > 0
                ? _export
                : null,
            onShare: _share,
            output: _output,
            onRevealFile: _openFolder,
            onSaveCopy: _saveCopy,
          ),
        ],
      ),
    );
  }

  /// Applies a settings change; the last file no longer matches them.
  void _reset(VoidCallback change) => setState(() {
    change();
    _output = null;
  });

  Future<void> _selectDirectory() async {
    if (!_destination.canChooseDirectory) return;
    final directory = await FilePickerServices().selectDir();
    if (directory != null && mounted) {
      _reset(() => _selectedDir = directory);
    }
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isRunning = true;
      _progress = null;
    });
    try {
      final output = await widget.onExport(
        format: _exportCtr.exportFmtCtr,
        header: _header,
        mappedOnly: _header == DataTableExportHeader.darwinCore && _mappedOnly,
        fileStem: _appendDate
            ? appendDateToFileStem(_exportCtr.fileNameCtr.text, DateTime.now())
            : _exportCtr.fileNameCtr.text,
        directory: await _destination.resolve(_selectedDir),
        onProgress: (done, total) {
          if (mounted) setState(() => _progress = (done, total));
        },
      );
      if (!mounted) return;
      setState(() => _output = output);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _selectedDir != null
                ? context.l10n.sharedExportedTo(output.path)
                : context.l10n.sharedExportComplete,
          ),
        ),
      );
    } on FormatException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.sharedExportFailedError('$error'))),
      );
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().shareFile(context, output);
    } on Object catch (error) {
      _reportActionFailure(error);
    }
  }

  Future<void> _openFolder() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().openContainingDirectory(output);
    } on Object catch (error) {
      _reportActionFailure(error);
    }
  }

  Future<void> _saveCopy() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().saveCopyToDevice(output);
    } on Object catch (error) {
      _reportActionFailure(error);
    }
  }

  void _reportActionFailure(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
