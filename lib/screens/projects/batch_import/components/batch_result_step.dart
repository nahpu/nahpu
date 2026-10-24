import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

/// Last step: what was written.
class BatchResultStep extends StatelessWidget {
  const BatchResultStep({
    super.key,
    required this.result,
    required this.onOpenTable,
  });

  final BatchImportResult result;
  final VoidCallback onOpenTable;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final updated = result.mode == BatchImportMode.update;
    final records = result.type.localizedLabel(l10n).toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: result.errors.isEmpty
              ? l10n.commonDone
              : l10n.projectBatchDoneWithErrors,
          message: updated
              ? l10n.projectBatchUpdatedRecords(result.written, records)
              : l10n.projectBatchAddedRecords(result.written, records),
        ),
        const SizedBox(height: NahpuSpacing.xl),
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BatchResultLine(
                icon: Icons.check_circle_outline_rounded,
                color: colors.primary,
                text: updated
                    ? l10n.projectBatchUpdatedCount(result.written)
                    : l10n.projectBatchAddedCount(result.written),
              ),
              BatchResultLine(
                icon: Icons.skip_next_outlined,
                color: colors.outline,
                text: l10n.projectBatchSkippedInReview(result.skipped),
              ),
              BatchResultLine(
                icon: Icons.error_outline_rounded,
                color: colors.error,
                text: l10n.projectBatchFailedCount(result.errors.length),
              ),
            ],
          ),
        ),
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: NahpuSpacing.xl),
          NahpuPanel(
            borderColor: colors.error,
            padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in result.errors.entries)
                  ListTile(
                    dense: true,
                    title: Text(l10n.projectBatchRow('${entry.key}')),
                    subtitle: Text(entry.value),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: NahpuSpacing.xl),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onOpenTable,
            icon: const Icon(Icons.table_chart_outlined),
            label: Text(l10n.projectBatchOpenTable(records)),
          ),
        ),
      ],
    );
  }
}

class BatchResultLine extends StatelessWidget {
  const BatchResultLine({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: color, size: NahpuControlSize.iconMedium),
          const SizedBox(width: NahpuSpacing.md),
          Text(text),
        ],
      ),
    );
  }
}
