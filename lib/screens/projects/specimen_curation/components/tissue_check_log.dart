import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// The tubes checked in this session, newest first.
class TissueCheckLogCard extends StatelessWidget {
  const TissueCheckLogCard({super.key, required this.entries});

  final List<TissueCheckEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entries.isEmpty
                  ? 'Session log'
                  : 'Session log (${entries.length})',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: NahpuSpacing.md),
            if (entries.isEmpty)
              Text(
                'Checked tubes appear here.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final (index, entry) in entries.indexed) ...[
                if (index > 0) const Divider(height: NahpuStroke.thin),
                TissueCheckLogRow(entry: entry),
              ],
          ],
        ),
      ),
    );
  }
}

class TissueCheckLogRow extends StatelessWidget {
  const TissueCheckLogRow({super.key, required this.entry});

  final TissueCheckEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: NahpuControlSize.iconSmall,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: NahpuSpacing.md),
          Expanded(
            child: Text(
              entry.label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: NahpuSpacing.md),
          Flexible(
            child: Text(
              entry.location,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: secondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lets the user pick a part when a code matches several.
class TissueMatchDialog extends StatelessWidget {
  const TissueMatchDialog({
    super.key,
    required this.code,
    required this.records,
  });

  final String code;
  final List<SpecimenPartProjectRecord> records;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Several parts match $code'),
      children: [
        for (final record in records)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, record),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                record.part.tissueID ?? record.part.barcodeID ?? code,
              ),
              subtitle: Text(
                [
                  if (record.specimen.fieldNumber != null)
                    'Field no. ${record.specimen.fieldNumber}',
                  if ((record.part.type ?? '').isNotEmpty) record.part.type!,
                  if ((record.part.storageLocation ?? '').isNotEmpty)
                    'At ${record.part.storageLocation}',
                ].join(' · '),
              ),
            ),
          ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: const Text('Skip'),
        ),
      ],
    );
  }
}
