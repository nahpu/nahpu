import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// First step: update or import, and which records.
class BatchModeStep extends StatelessWidget {
  const BatchModeStep({
    super.key,
    required this.mode,
    required this.type,
    required this.linked,
    required this.onModeChanged,
    required this.onTypeChanged,
    required this.onLinkedSelected,
  });

  final BatchImportMode mode;
  final DataTableRecordType type;

  /// Rows hold sites, events, specimens, and parts together.
  final bool linked;
  final ValueChanged<BatchImportMode> onModeChanged;
  final ValueChanged<DataTableRecordType> onTypeChanged;
  final VoidCallback onLinkedSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NahpuStepHeading(
          title: 'What do you want to do?',
          message:
              'Bring records in from a CSV, TSV, or Excel file. Columns can '
              'use Darwin Core terms or your own names.',
        ),
        const SizedBox(height: NahpuSpacing.xl),
        BatchModeCard(
          icon: Icons.download_rounded,
          title: BatchImportMode.create.label,
          message:
              'Add one record per row. Taxa, personnel, sites, and events '
              'are linked when they are already in the project.',
          selected: mode == BatchImportMode.create,
          onTap: () => onModeChanged(BatchImportMode.create),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        BatchModeCard(
          icon: Icons.edit_note_rounded,
          title: BatchImportMode.update.label,
          message:
              'Match each row to a record by a key column, such as a catalog '
              'number, and write the other columns. Blank cells are left '
              'unchanged.',
          selected: mode == BatchImportMode.update,
          onTap: () => onModeChanged(BatchImportMode.update),
        ),
        const SizedBox(height: NahpuSpacing.xxl),
        Text('Records', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: NahpuSpacing.md),
        Wrap(
          spacing: NahpuSpacing.md,
          runSpacing: NahpuSpacing.md,
          children: [
            for (final value in DataTableRecordType.values)
              ChoiceChip(
                label: Text(value.label),
                selected: !linked && value == type,
                onSelected: (_) => onTypeChanged(value),
              ),
            if (mode == BatchImportMode.create)
              ChoiceChip(
                avatar: const Icon(Icons.account_tree_outlined),
                label: const Text('Linked records'),
                selected: linked,
                onSelected: (_) => onLinkedSelected(),
              ),
          ],
        ),
        if (linked) ...[
          const SizedBox(height: NahpuSpacing.md),
          Text(
            'Each row can describe a site, its collecting event, a specimen, '
            'and a part. Rows are grouped into sites and events, which you '
            'can check before importing.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class BatchModeCard extends StatelessWidget {
  const BatchModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
        onTap: onTap,
        child: NahpuPanel(
          color: selected ? colors.primaryContainer : null,
          borderColor: selected ? colors.primary : null,
          child: Row(
            children: [
              Icon(
                icon,
                size: NahpuControlSize.iconLarge,
                color: selected ? colors.onPrimaryContainer : colors.primary,
              ),
              const SizedBox(width: NahpuSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: NahpuSpacing.xs),
                    Text(message, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
