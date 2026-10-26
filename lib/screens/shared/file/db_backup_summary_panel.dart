import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// What a full database backup copies: record counts, files, and size.
///
/// Shared by the backup window and the safety backup taken before a database
/// replace, so both show the same numbers before a long job starts.
class DbBackupSummaryPanel extends StatelessWidget {
  const DbBackupSummaryPanel({
    super.key,
    required this.summary,
    required this.error,
  });

  final DbBackupSummary? summary;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sharedEntireDatabaseContents,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: NahpuSpacing.md),
          if (error != null)
            ErrorText(error: error!)
          else if (summary == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            for (final entry in summary!.entries.entries)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(_entryLabel(l10n, entry.key)),
                trailing: Text('${entry.value}'),
              ),
            const CommonDivider(),
            // Knowing the size before starting is what tells the user whether
            // this is a ten second job or a ten minute one.
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.sharedBackupSizeBeforeCompression,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: Text(
                formatByteSize(summary!.totalBytes),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The display name of a summary entry, whose English labels double as
  /// the summary's keys. Falls back to the key for an entry added there but
  /// not here.
  String _entryLabel(AppLocalizations l10n, String key) {
    if (key == 'Associated files') return l10n.databaseAssociatedFiles;
    return switch (dbSummaryTables[key]) {
      'project' => l10n.databaseTableProjects,
      'personnel' => l10n.databaseTablePersonnel,
      'taxonomy' => l10n.databaseTableTaxa,
      'site' => l10n.databaseTableSites,
      'collEvent' => l10n.databaseTableCollectionEvents,
      'specimen' => l10n.databaseTableSpecimens,
      'narrative' => l10n.databaseTableNarratives,
      'media' => l10n.databaseTableMediaRecords,
      _ => key,
    };
  }
}
