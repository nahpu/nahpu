import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// The tubes checked and skipped in this session, newest first. It has no
/// card of its own; wide panels show the two lists side by side.
class TissueCheckLogPanel extends StatelessWidget {
  const TissueCheckLogPanel({
    super.key,
    required this.entries,
    this.skipped = const [],
    this.showTitle = true,
    this.onExport,
  });

  final List<TissueCheckEntry> entries;
  final List<TissueSkipEntry> skipped;

  /// False drops the Session log heading, as under a tab that names it.
  final bool showTitle;

  /// Opens the export. Null disables the button, as while the log is empty.
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkedSection = TissueLogSection(
      key: const ValueKey('tissue-log-checked'),
      title: context.l10n.projectTissueLogChecked(entries.length),
      emptyText: context.l10n.projectTissueSessionLogEmpty,
      children: [for (final entry in entries) TissueCheckLogRow(entry: entry)],
    );
    final skippedSection = TissueLogSection(
      key: const ValueKey('tissue-log-skipped'),
      title: context.l10n.projectTissueLogSkipped(skipped.length),
      emptyText: context.l10n.projectTissueLogSkippedEmpty,
      children: [for (final entry in skipped) TissueSkipLogRow(entry: entry)],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: showTitle
                  ? Text(
                      context.l10n.projectTissueSessionLog,
                      style: theme.textTheme.titleSmall,
                    )
                  : const SizedBox.shrink(),
            ),
            TextButton.icon(
              key: const ValueKey('tissue-log-export'),
              onPressed: onExport,
              icon: const Icon(Icons.file_download_outlined),
              label: Text(context.l10n.projectTissueExportLog),
            ),
          ],
        ),
        const SizedBox(height: NahpuSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < NahpuBreakpoints.compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  checkedSection,
                  const SizedBox(height: NahpuSpacing.xl),
                  skippedSection,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: checkedSection),
                const SizedBox(width: NahpuSpacing.xxl),
                Expanded(child: skippedSection),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// A titled list in the session log, with a note while it is empty.
class TissueLogSection extends StatelessWidget {
  const TissueLogSection({
    super.key,
    required this.title,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NahpuSpacing.xs),
        if (children.isEmpty)
          Text(
            emptyText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Divider(height: NahpuStroke.thin),
            child,
          ],
      ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                if (entry.displaced.isNotEmpty)
                  Text(
                    context.l10n.projectTissueReplacedLog(
                      entry.displaced.map((e) => e.label).join(', '),
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: secondary,
                  ),
              ],
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

class TissueSkipLogRow extends StatelessWidget {
  const TissueSkipLogRow({super.key, required this.entry});

  final TissueSkipEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.skip_next_outlined,
            size: NahpuControlSize.iconSmall,
            color: NahpuTheme.warningText(theme.colorScheme),
          ),
          const SizedBox(width: NahpuSpacing.md),
          Expanded(
            child: Text(
              entry.label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lets the user pick a tube when a code matches several.
class TissueMatchDialog extends StatelessWidget {
  const TissueMatchDialog({
    super.key,
    required this.code,
    required this.records,
    required this.labelFor,
  });

  final String code;
  final List<TissueItemRecord> records;
  final String Function(TissueItemRecord record) labelFor;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(context.l10n.projectTissueSeveralMatches(code)),
      children: [
        for (final record in records)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, record),
            child: TissueMatchOption(record: record, label: labelFor(record)),
          ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.projectWizardSkip),
        ),
      ],
    );
  }
}

/// One tube in the match picker: its label, its type or Parasite, its
/// treatment and count, and where it is stored when already placed.
class TissueMatchOption extends StatelessWidget {
  const TissueMatchOption({
    super.key,
    required this.record,
    required this.label,
  });

  final TissueItemRecord record;
  final String label;

  @override
  Widget build(BuildContext context) {
    final location = record.storageLocation?.trim() ?? '';
    final type = record.isParasite
        ? context.l10n.projectTissueParasite
        : record.type?.trim() ?? '';
    final treatment = record.treatment?.trim() ?? '';
    final count = record.count?.trim() ?? '';
    final details = [
      if (type.isNotEmpty) type,
      if (treatment.isNotEmpty) treatment,
      if (count.isNotEmpty) context.l10n.projectTissueCount(count),
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: details.isEmpty ? null : Text(details),
      trailing: location.isEmpty
          ? null
          : Chip(
              avatar: const Icon(Icons.inventory_2_outlined),
              label: Text(context.l10n.projectTissueAt(location)),
              visualDensity: VisualDensity.compact,
            ),
    );
  }
}
