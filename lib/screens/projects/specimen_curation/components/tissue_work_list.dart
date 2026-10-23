import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Unplaced parts in field ID order, for boxing tubes without a scanner.
/// Place puts the current part in the next cell; Skip moves past it.
class TissueWorkListPanel extends StatelessWidget {
  const TissueWorkListPanel({
    super.key,
    required this.records,
    required this.index,
    required this.labelFor,
    required this.nextLocation,
    required this.isBusy,
    required this.onPlace,
    required this.onSkip,
    required this.onSelect,
  });

  /// Shown at most this many upcoming parts below the current one.
  static const int upcomingCount = 5;

  /// Null while the list loads.
  final List<SpecimenPartProjectRecord>? records;
  final int index;
  final String Function(SpecimenPartProjectRecord record) labelFor;
  final String? nextLocation;
  final bool isBusy;
  final VoidCallback onPlace;
  final VoidCallback onSkip;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final records = this.records;
    if (records == null) {
      return const Padding(
        padding: EdgeInsets.all(NahpuSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (records.isEmpty) {
      return Text(
        'No unplaced parts match the tissue type and preservation filters.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final current = records[index];
    final upcoming = [
      for (var offset = 1; offset <= upcomingCount; offset++)
        if (offset < records.length) (index + offset) % records.length,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Next · ${records.length} remaining',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NahpuSpacing.xs),
        Text(
          labelFor(current),
          key: const ValueKey('tissue-work-list-current'),
          style: theme.textTheme.titleMedium,
        ),
        if (nextLocation != null)
          Text(
            '→ $nextLocation',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        const SizedBox(height: NahpuSpacing.lg),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: isBusy ? null : onPlace,
                icon: const Icon(Icons.move_to_inbox_outlined),
                label: const Text('Place'),
              ),
            ),
            const SizedBox(width: NahpuSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBusy || records.length < 2 ? null : onSkip,
                icon: const Icon(Icons.skip_next_outlined),
                label: const Text('Skip'),
              ),
            ),
          ],
        ),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: NahpuSpacing.lg),
          const Divider(height: NahpuStroke.thin),
          for (final upcomingIndex in upcoming)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(labelFor(records[upcomingIndex])),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelect(upcomingIndex),
            ),
        ],
      ],
    );
  }
}
