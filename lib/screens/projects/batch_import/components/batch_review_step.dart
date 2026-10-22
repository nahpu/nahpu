import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Fourth step: what will be written, and the rows that won't be.
class BatchReviewStep extends StatefulWidget {
  const BatchReviewStep({
    super.key,
    required this.review,
    required this.includeMissingLinks,
    required this.progress,
    required this.error,
    required this.onIncludeMissingLinksChanged,
  });

  final BatchImportReview review;
  final bool includeMissingLinks;

  /// Rows written so far and in all, while writing.
  final (int, int)? progress;
  final String? error;
  final ValueChanged<bool> onIncludeMissingLinksChanged;

  @override
  State<BatchReviewStep> createState() => _BatchReviewStepState();
}

class _BatchReviewStepState extends State<BatchReviewStep> {
  /// The status the row list shows; null shows every row with a problem.
  BatchRowStatus? _filter;

  static const _shownRows = 200;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final colors = Theme.of(context).colorScheme;
    final importable = review
        .importable(includeMissingLinks: widget.includeMissingLinks)
        .length;
    final verb = review.mode == BatchImportMode.update ? 'update' : 'add';
    final problems = [
      for (final row in review.rows)
        if (row.messages.isNotEmpty &&
            (_filter == null || row.status == _filter))
          row,
    ];
    final counts = {
      for (final status in BatchRowStatus.values)
        if (review.count(status) > 0) status: review.count(status),
    };
    final progress = widget.progress;
    final error = widget.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: 'Review',
          message:
              'This will $verb $importable of ${review.rows.length} '
              '${review.type.label.toLowerCase()}. Rows with problems are '
              'skipped.',
        ),
        const SizedBox(height: NahpuSpacing.xl),
        Wrap(
          spacing: NahpuSpacing.md,
          runSpacing: NahpuSpacing.md,
          children: [
            for (final entry in counts.entries)
              FilterChip(
                avatar: Icon(
                  entry.key.isImportable
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  size: NahpuControlSize.iconSmall,
                  color: entry.key == BatchRowStatus.ready
                      ? colors.primary
                      : entry.key.isImportable
                      ? colors.tertiary
                      : colors.error,
                ),
                label: Text('${entry.key.label}: ${entry.value}'),
                selected: _filter == entry.key,
                onSelected: (selected) =>
                    setState(() => _filter = selected ? entry.key : null),
              ),
          ],
        ),
        if (counts.containsKey(BatchRowStatus.missingLink)) ...[
          const SizedBox(height: NahpuSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Import rows with missing links'),
            subtitle: const Text(
              'The taxon, person, site, or event stays empty. Add it to the '
              'project first to link it.',
            ),
            value: widget.includeMissingLinks,
            onChanged: progress == null
                ? widget.onIncludeMissingLinksChanged
                : null,
          ),
        ],
        if (progress != null) ...[
          const SizedBox(height: NahpuSpacing.lg),
          LinearProgressIndicator(
            value: progress.$2 == 0 ? null : progress.$1 / progress.$2,
          ),
          const SizedBox(height: NahpuSpacing.sm),
          Text('Writing ${progress.$1} of ${progress.$2} rows'),
        ],
        if (error != null) ...[
          const SizedBox(height: NahpuSpacing.lg),
          Text(error, style: TextStyle(color: colors.error)),
        ],
        const SizedBox(height: NahpuSpacing.xl),
        if (problems.isEmpty)
          const NahpuPanel(child: Text('No problems found.'))
        else
          NahpuPanel(
            padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final row in problems.take(_shownRows))
                  BatchRowProblemTile(row: row),
                if (problems.length > _shownRows)
                  Padding(
                    padding: const EdgeInsets.all(NahpuSpacing.lg),
                    child: Text(
                      'And ${problems.length - _shownRows} more rows.',
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class BatchRowProblemTile extends StatelessWidget {
  const BatchRowProblemTile({super.key, required this.row});

  final BatchRowPlan row;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(
        row.status.isImportable
            ? Icons.info_outline_rounded
            : Icons.block_rounded,
        color: row.status.isImportable ? colors.tertiary : colors.error,
      ),
      title: Text('Row ${row.rowNumber} · ${row.status.label}'),
      subtitle: Text(row.messages.join('\n')),
    );
  }
}
