import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Second step: choose the file, and the sheet for a workbook.
class BatchFileStep extends StatelessWidget {
  const BatchFileStep({
    super.key,
    required this.file,
    required this.table,
    required this.isReading,
    required this.error,
    required this.onPick,
    required this.onClear,
    required this.onSheetChanged,
  });

  final XFile? file;
  final BatchImportTable? table;
  final bool isReading;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final ValueChanged<String> onSheetChanged;

  @override
  Widget build(BuildContext context) {
    final table = this.table;
    final error = this.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: context.l10n.projectBatchChooseFile,
          message: context.l10n.projectBatchChooseFileBody,
        ),
        const SizedBox(height: NahpuSpacing.xl),
        Center(
          child: SelectFileField(
            filePath: file,
            onPressed: onPick,
            onCleared: onClear,
            isLoading: isReading,
            width: double.infinity,
            maxWidth: NahpuContentWidth.form,
            supportedFormat: 'CSV, TSV, TXT, XLSX, XLS',
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: NahpuSpacing.lg),
          Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (table != null) ...[
          const SizedBox(height: NahpuSpacing.xl),
          if (table.sheetNames.length > 1) ...[
            DropdownButtonFormField<String>(
              initialValue: table.sheetName,
              decoration: InputDecoration(
                labelText: context.l10n.projectBatchSheet,
              ),
              items: [
                for (final sheet in table.sheetNames)
                  DropdownMenuItem(value: sheet, child: Text(sheet)),
              ],
              onChanged: isReading
                  ? null
                  : (sheet) {
                      if (sheet != null) onSheetChanged(sheet);
                    },
            ),
            const SizedBox(height: NahpuSpacing.lg),
          ],
          BatchTablePreview(table: table),
        ],
      ],
    );
  }
}

/// The first rows of the file, as read.
class BatchTablePreview extends StatelessWidget {
  const BatchTablePreview({super.key, required this.table});

  final BatchImportTable table;

  static const _previewRows = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NahpuPanel(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.projectBatchTableSize(
              table.rows.length,
              table.headers.length,
            ),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: NahpuSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: NahpuDataTable.rowHeight,
              dataRowMinHeight: NahpuDataTable.rowHeight,
              dataRowMaxHeight: NahpuDataTable.rowHeight,
              columns: [
                for (final header in table.headers)
                  DataColumn(label: Text(header)),
              ],
              rows: [
                for (final row in table.rows.take(_previewRows))
                  DataRow(
                    cells: [
                      for (final cell in row)
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: NahpuDataTable.maxCellWidth,
                            ),
                            child: Text(cell, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
