import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_result_step.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_linked_models.dart';
import 'package:nahpu/services/import/batch/batch_linked_service.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// A linked import's review: what will be created or linked, and each row
/// with a problem, which can be left out or put back.
class BatchLinkedReviewStep extends StatelessWidget {
  const BatchLinkedReviewStep({
    super.key,
    required this.plan,
    required this.includeMissingLinks,
    required this.progress,
    required this.error,
    required this.onIncludeMissingLinksChanged,
    required this.onChanged,
  });

  final BatchLinkedPlan plan;
  final bool includeMissingLinks;
  final (int, int)? progress;
  final String? error;
  final ValueChanged<bool> onIncludeMissingLinksChanged;
  final ValueChanged<BatchLinkedPlan> onChanged;

  static const _shownRows = 200;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final counts = plan.counts(includeMissingLinks: includeMissingLinks);
    final problems = _problems();
    final hasMissingLinks = plan.specimens.any(
      (s) => s.plan.status == BatchRowStatus.missingLink,
    );
    final progress = this.progress;
    final error = this.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NahpuStepHeading(
          title: 'Review',
          message:
              'Sites are written first, then events at them, then specimens '
              'and their parts.',
        ),
        const SizedBox(height: NahpuSpacing.xl),
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BatchResultLine(
                icon: Icons.place_outlined,
                color: colors.primary,
                text:
                    'Sites: ${counts.newSites} new, '
                    '${counts.linkedSites} linked',
              ),
              BatchResultLine(
                icon: Icons.event_outlined,
                color: colors.primary,
                text:
                    'Events: ${counts.newEvents} new, '
                    '${counts.linkedEvents} linked',
              ),
              BatchResultLine(
                icon: Icons.pets_outlined,
                color: colors.primary,
                text: 'Specimens: ${counts.specimens}',
              ),
              BatchResultLine(
                icon: Icons.science_outlined,
                color: colors.primary,
                text: 'Parts: ${counts.parts}',
              ),
              BatchResultLine(
                icon: Icons.skip_next_outlined,
                color: colors.outline,
                text: 'Rows skipped: ${counts.skippedRows}',
              ),
            ],
          ),
        ),
        if (hasMissingLinks) ...[
          const SizedBox(height: NahpuSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Import specimens with missing links'),
            subtitle: const Text(
              'The taxon or person stays empty. Add it to the project first '
              'to link it.',
            ),
            value: includeMissingLinks,
            onChanged: progress == null ? onIncludeMissingLinksChanged : null,
          ),
        ],
        if (progress != null) ...[
          const SizedBox(height: NahpuSpacing.lg),
          LinearProgressIndicator(
            value: progress.$2 == 0 ? null : progress.$1 / progress.$2,
          ),
          const SizedBox(height: NahpuSpacing.sm),
          Text('Writing ${progress.$1} of ${progress.$2} records'),
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
                for (final entry in problems.entries.take(_shownRows))
                  SwitchListTile(
                    dense: true,
                    value: plan.isRowIncluded(entry.key),
                    title: Text('Row ${plan.rowNumbers[entry.key]}'),
                    subtitle: Text(entry.value.join('\n')),
                    onChanged: progress == null
                        ? (value) => onChanged(
                            value
                                ? plan.includeRow(entry.key)
                                : plan.excludeRow(entry.key),
                          )
                        : null,
                  ),
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

  /// Messages by table row, in row order.
  Map<int, List<String>> _problems() {
    final byRow = <int, List<String>>{};
    void add(int row, Iterable<String> messages) {
      if (messages.isEmpty) return;
      byRow.putIfAbsent(row, () => []).addAll(messages);
    }

    for (final site in plan.sites) {
      add(site.rows.first, [
        for (final message in [...site.problems, ...site.conflicts])
          'Site ${site.label}: $message',
      ]);
    }
    for (final event in plan.events) {
      add(event.rows.first, [
        for (final message in [...event.problems, ...event.conflicts])
          'Event: $message',
      ]);
    }
    for (final specimen in plan.specimens) {
      add(specimen.rows.first, [
        if (!specimen.plan.status.isImportable)
          'Specimen skipped: ${specimen.plan.status.label}.',
        ...specimen.plan.messages,
      ]);
      for (final part in specimen.parts) {
        add(part.row, part.plan.messages);
      }
    }
    for (final row in plan.excluded) {
      byRow.putIfAbsent(row, () => ['Excluded.']);
    }
    return Map.fromEntries(
      byRow.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}

/// The last step of a linked import: what was written.
class BatchLinkedResultStep extends StatelessWidget {
  const BatchLinkedResultStep({
    super.key,
    required this.result,
    required this.onOpenTable,
  });

  final BatchLinkedResult result;
  final VoidCallback onOpenTable;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: result.errors.isEmpty ? 'Done' : 'Done, with errors',
          message:
              'Added ${result.specimens} specimens and ${result.parts} parts.',
        ),
        const SizedBox(height: NahpuSpacing.xl),
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BatchResultLine(
                icon: Icons.place_outlined,
                color: colors.primary,
                text:
                    'Sites: ${result.newSites} new, '
                    '${result.linkedSites} linked',
              ),
              BatchResultLine(
                icon: Icons.event_outlined,
                color: colors.primary,
                text:
                    'Events: ${result.newEvents} new, '
                    '${result.linkedEvents} linked',
              ),
              BatchResultLine(
                icon: Icons.error_outline_rounded,
                color: colors.error,
                text: 'Rows with errors: ${result.errors.length}',
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
                    title: Text('Row ${entry.key}'),
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
            label: const Text('Open specimen records table'),
          ),
        ),
      ],
    );
  }
}
