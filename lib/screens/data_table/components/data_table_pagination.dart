import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

class DataTablePaginationBar extends StatelessWidget {
  const DataTablePaginationBar({
    super.key,
    required this.page,
    required this.rowsPerPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  /// Null before the first page loads.
  final DataTablePageData? page;
  final int rowsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = page;
    final format = NumberFormat.decimalPattern();
    final range = current == null || current.totalRows == 0
        ? context.l10n.dataTablePageRangeEmpty
        : context.l10n.dataTablePageRange(
            format.format(current.firstRowIndex + 1),
            format.format(current.firstRowIndex + current.rows.length),
            format.format(current.totalRows),
          );
    final canGoBack = current != null && current.page > 0;
    final canGoForward =
        current != null && current.page < current.pageCount - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: NahpuSpacing.lg,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.dataTableRowsPerPage,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: NahpuSpacing.md),
              DropdownButton<int>(
                value: rowsPerPage,
                underline: const SizedBox.shrink(),
                items: [
                  for (final option in dataTableRowsPerPageOptions)
                    DropdownMenuItem(value: option, child: Text('$option')),
                ],
                onChanged: (value) {
                  if (value != null) onRowsPerPageChanged(value);
                },
              ),
            ],
          ),
          Text(range, style: theme.textTheme.bodySmall),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: context.l10n.dataTableFirstPage,
                icon: const Icon(Icons.first_page),
                onPressed: canGoBack ? () => onPageChanged(0) : null,
              ),
              IconButton(
                tooltip: context.l10n.dataTablePreviousPage,
                icon: const Icon(Icons.chevron_left),
                onPressed: canGoBack
                    ? () => onPageChanged(current.page - 1)
                    : null,
              ),
              IconButton(
                tooltip: context.l10n.dataTableNextPage,
                icon: const Icon(Icons.chevron_right),
                onPressed: canGoForward
                    ? () => onPageChanged(current.page + 1)
                    : null,
              ),
              IconButton(
                tooltip: context.l10n.dataTableLastPage,
                icon: const Icon(Icons.last_page),
                onPressed: canGoForward
                    ? () => onPageChanged(current.pageCount - 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DataTableMessage extends StatelessWidget {
  const DataTableMessage({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: NahpuControlSize.iconLarge,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: NahpuSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: NahpuSpacing.md),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
