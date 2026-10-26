import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/home/home.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/database/database.dart' show kSchemaVersion;
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class DatabaseSettings extends ConsumerStatefulWidget {
  const DatabaseSettings({super.key});

  @override
  DatabaseSettingsState createState() => DatabaseSettingsState();
}

class DatabaseSettingsState extends ConsumerState<DatabaseSettings> {
  XFile? _dbPath;
  bool _isBackup = true;
  bool _hasSelected = false;
  bool _isArchived = false;
  bool _isLoading = false;
  bool _isSelectingFile = false;
  String? _databaseRelativePath;
  bool _isCancelling = false;
  ExportCancellation? _cancellation;
  StreamSubscription<ExportJobProgress>? _progressSubscription;
  ExportJobProgress? _jobProgress;
  DbBackupSummary? _summary;
  String? _summaryError;
  DbReplacementPreview? _replacementPreview;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSummary());
  }

  @override
  void dispose() {
    unawaited(_progressSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProgress = _jobProgress;
    return PopScope(
      // A restore rewrites the database in place; leaving part way through
      // would be worse than waiting, so the user has to decide deliberately.
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: _isLoading && jobProgress != null
          ? _RestoreProgressView(
              progress: jobProgress,
              isCancelling: _isCancelling,
              // Cancelling is only offered while the archive is being read.
              // Once files start landing in place, stopping half way would
              // leave the app in a state the user cannot reason about.
              onCancel: _canCancelRestore(jobProgress) ? _requestCancel : null,
            )
          : _ReplaceDatabaseForm(
              dbPath: _dbPath,
              isArchived: _isArchived,
              databaseRelativePath: _databaseRelativePath,
              isSelectingFile: _isSelectingFile,
              isBackup: _isBackup,
              summary: _summary,
              summaryError: _summaryError,
              replacement: _replacementPreview,
              onSelectFile: _selectFile,
              onClearFile: _clearFile,
              onBackupChanged: _setBackup,
              // A file that cannot be restored never gets as far as the
              // confirmation, so nothing is overwritten for it.
              onReplace: _hasSelected && _replacementPreview?.issue == null
                  ? _confirmReplace
                  : null,
            ),
    );
  }

  /// Reads the current database, which the comparison always shows.
  Future<void> _loadSummary() async {
    try {
      final summary = await DbExport(ref: ref, filePath: File('')).getSummary();
      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (error) {
      if (!mounted) return;
      setState(() => _summaryError = error.toString());
    }
  }

  void _setBackup(bool value) {
    setState(() => _isBackup = value);
  }

  Future<void> _selectFile() async {
    try {
      await _getDbPath();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.databaseSelectFileFailed)),
      );
    }
  }

  void _clearFile() {
    setState(() {
      _dbPath = null;
      _hasSelected = false;
      _isArchived = false;
      _databaseRelativePath = null;
      _replacementPreview = null;
    });
  }

  Future<void> _getDbPath() async {
    setState(() {
      _isSelectingFile = true;
    });
    try {
      final dbPath = await FilePickerServices().selectAnyFile();
      if (dbPath != null) {
        final lowerPath = dbPath.path.toLowerCase();
        final isArchived =
            lowerPath.endsWith('.zip') || lowerPath.endsWith('.tar.gz');
        String? databaseRelativePath;
        final DbReplacementPreview preview;
        if (isArchived) {
          final inspection = await DbWriter(
            ref: ref,
            filePath: File(dbPath.path),
          ).inspectArchive();
          if (inspection.databaseCandidates.isEmpty) {
            throw const FormatException(
              'The backup archive does not contain a database at its root.',
            );
          }
          if (inspection.databaseCandidates.length == 1) {
            databaseRelativePath =
                inspection.databaseCandidates.single.archivePath;
          } else if (mounted) {
            databaseRelativePath = await showDialog<String>(
              context: context,
              builder: (context) => DatabaseCandidateDialog(
                candidates: inspection.databaseCandidates,
              ),
            );
            if (databaseRelativePath == null) return;
          }
          preview =
              inspection.previews[databaseRelativePath] ??
              const DbReplacementPreview(
                contents: null,
                issue: DbReplacementIssue.unreadable,
              );
        } else {
          preview = await DbWriter(
            ref: ref,
            filePath: File(dbPath.path),
          ).inspectDatabaseFile();
        }
        if (!mounted) return;
        setState(() {
          _dbPath = dbPath;
          _hasSelected = true;
          _isArchived = isArchived;
          _databaseRelativePath = databaseRelativePath;
          _replacementPreview = preview;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingFile = false;
        });
      }
    }
  }

  Future<void> _confirmReplace() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.databaseReplaceConfirmTitle),
          content: DbWarningText(isBackup: _isBackup),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.databaseReplace),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) await _replaceDb();
  }

  Future<void> _replaceDb() async {
    final reporter = ExportProgressReporter(steps: DbWriter.restorePhases);
    final cancellation = ExportCancellation();
    setState(() {
      _isLoading = true;
      _isCancelling = false;
      _cancellation = cancellation;
      _jobProgress = ExportJobProgress.pending(reporter.steps);
    });
    _progressSubscription = reporter.stream.listen((progress) {
      if (mounted) setState(() => _jobProgress = progress);
    });
    try {
      final backupFile = await DbWriter(ref: ref, filePath: File(_dbPath!.path))
          .replace(
            _isBackup,
            _isArchived,
            databaseRelativePath: _databaseRelativePath,
            progress: reporter,
            cancel: cancellation,
          );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _navigate(backupFile);
    } on ExportCancelledException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.databaseRestoreCancelled)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    } finally {
      await _progressSubscription?.cancel();
      _progressSubscription = null;
      await reporter.dispose();
      if (mounted) {
        setState(() {
          _isCancelling = false;
          _cancellation = null;
        });
      }
    }
  }

  /// Whether stopping now would still leave the app exactly as it was.
  bool _canCancelRestore(ExportJobProgress progress) =>
      progress.activeStep?.phase == ExportPhase.extracting;

  void _requestCancel() {
    _cancellation?.cancel();
    setState(() => _isCancelling = true);
  }

  Future<void> _confirmLeave() async {
    final progress = _jobProgress;
    if (progress == null || !_canCancelRestore(progress)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.databaseRestoreCannotStop)),
      );
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.databaseCancelRestoreTitle),
        content: Text(context.l10n.databaseCancelRestoreBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.databaseKeepRestoring),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.databaseCancelRestore),
          ),
        ],
      ),
    );
    if (leave == true && mounted) _requestCancel();
  }

  void _navigate(File? backupFile) {
    ref.invalidate(databaseProvider);
    ref.invalidate(projectListProvider);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DBReplacedPage(dbBackupPath: backupFile),
      ),
    );
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.databaseReplaceFailed(errors)),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}

/// Laid out like the backup window: options on the left, the current database
/// beside the replacement on the right, and the action pinned below both.
class _ReplaceDatabaseForm extends StatelessWidget {
  const _ReplaceDatabaseForm({
    required this.dbPath,
    required this.isArchived,
    required this.databaseRelativePath,
    required this.isSelectingFile,
    required this.isBackup,
    required this.summary,
    required this.summaryError,
    required this.replacement,
    required this.onSelectFile,
    required this.onClearFile,
    required this.onBackupChanged,
    required this.onReplace,
  });

  final XFile? dbPath;
  final bool isArchived;
  final String? databaseRelativePath;
  final bool isSelectingFile;
  final bool isBackup;
  final DbBackupSummary? summary;
  final String? summaryError;
  final DbReplacementPreview? replacement;
  final VoidCallback onSelectFile;
  final VoidCallback onClearFile;
  final ValueChanged<bool> onBackupChanged;

  /// Null until a restorable file is selected.
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DatabaseSourceCard(
          dbPath: dbPath,
          isArchived: isArchived,
          databaseRelativePath: databaseRelativePath,
          isSelectingFile: isSelectingFile,
          isBlocked: replacement?.issue != null,
          onSelectFile: onSelectFile,
          onClearFile: onClearFile,
        ),
        const SizedBox(height: NahpuSpacing.xl),
        _SafetyBackupCard(isBackup: isBackup, onChanged: onBackupChanged),
      ],
    );
    final comparison = DatabaseComparisonPanel(
      current: summary,
      currentError: summaryError,
      replacement: replacement,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.databaseReplaceDatabase)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= NahpuBreakpoints.compact;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      NahpuSpacing.md,
                      NahpuSpacing.md,
                      NahpuSpacing.md,
                      NahpuSpacing.xl,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: NahpuContentWidth.settings,
                        ),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: options),
                                  const SizedBox(width: NahpuSpacing.xxl),
                                  Expanded(child: comparison),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  options,
                                  const SizedBox(height: NahpuSpacing.xl),
                                  comparison,
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Pinned below the scroll view, as in the backup window, so the
            // action stays in reach however long the comparison grows.
            ExportActionBar(
              label: l10n.databaseReplaceDatabase,
              repeatLabel: l10n.databaseReplaceDatabase,
              icon: Icons.restore_outlined,
              canExport: onReplace != null,
              isRunning: false,
              hasOutput: false,
              onExport: onReplace ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

/// Picks the database or backup archive to restore and says what it holds.
///
/// Styled after the backup window's save location row: a name on the left and
/// a Browse button on the right, rather than a large drop target.
class _DatabaseSourceCard extends StatelessWidget {
  const _DatabaseSourceCard({
    required this.dbPath,
    required this.isArchived,
    required this.databaseRelativePath,
    required this.isSelectingFile,
    required this.isBlocked,
    required this.onSelectFile,
    required this.onClearFile,
  });

  final XFile? dbPath;
  final bool isArchived;
  final String? databaseRelativePath;
  final bool isSelectingFile;

  /// Whether the chosen file cannot be restored.
  final bool isBlocked;
  final VoidCallback onSelectFile;
  final VoidCallback onClearFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final file = dbPath;
    final hasFile = file != null;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.databaseReplaceWith, style: theme.textTheme.titleLarge),
          const SizedBox(height: NahpuSpacing.md),
          Text(l10n.databaseSourceDescription),
          const SizedBox(height: NahpuSpacing.xl),
          Material(
            color: colors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NahpuRadius.md),
              side: BorderSide(
                color: !hasFile
                    ? colors.outlineVariant
                    : isBlocked
                    ? colors.error
                    : colors.primary,
                width: NahpuStroke.thin,
              ),
            ),
            child: InkWell(
              // The whole row opens the picker until a file is chosen.
              onTap: hasFile || isSelectingFile ? null : onSelectFile,
              child: Padding(
                padding: const EdgeInsets.all(NahpuSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: NahpuControlSize.touchTarget,
                      height: NahpuControlSize.touchTarget,
                      decoration: BoxDecoration(
                        color: hasFile
                            ? colors.primaryContainer
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(NahpuRadius.sm),
                      ),
                      child: Icon(
                        !hasFile
                            ? Icons.upload_file_outlined
                            : isArchived
                            ? Icons.folder_zip_outlined
                            : Icons.storage_outlined,
                        color: hasFile
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: NahpuSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasFile
                                ? p.basename(file.path)
                                : l10n.databaseNoFileSelected,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: NahpuSpacing.xxs),
                          Text(
                            _detail(l10n),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: hasFile && isBlocked
                                  ? colors.error
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: NahpuSpacing.md),
                    if (isSelectingFile)
                      const SizedBox.square(
                        dimension: NahpuControlSize.iconMedium,
                        child: CircularProgressIndicator(),
                      )
                    else if (!hasFile)
                      OutlinedButton.icon(
                        onPressed: onSelectFile,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: Text(l10n.databaseBrowse),
                      )
                    else ...[
                      TextButton(
                        onPressed: onSelectFile,
                        child: Text(l10n.databaseChangeFile),
                      ),
                      IconButton(
                        onPressed: onClearFile,
                        icon: const Icon(Icons.clear_rounded),
                        tooltip: l10n.databaseClearFile,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _detail(AppLocalizations l10n) {
    if (dbPath == null) return l10n.databaseSupportedFormats;
    if (isBlocked) return l10n.databaseCannotRestore;
    if (!isArchived) return l10n.databaseSqliteDatabase;
    final database = databaseRelativePath;
    return database == null
        ? l10n.databaseBackupArchive
        : l10n.databaseBackupArchiveRestores(database);
  }
}

class _SafetyBackupCard extends StatelessWidget {
  const _SafetyBackupCard({required this.isBackup, required this.onChanged});

  final bool isBackup;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.databaseBeforeReplacing, style: theme.textTheme.titleLarge),
          const SizedBox(height: NahpuSpacing.md),
          Text(
            l10n.databaseReplaceWarning,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NahpuSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.databaseBackupFirst),
            subtitle: Text(l10n.databaseBackupFirstSubtitle),
            value: isBackup,
            onChanged: onChanged,
          ),
          if (!isBackup) ...[
            const SizedBox(height: NahpuSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: NahpuControlSize.iconMedium,
                  color: colors.error,
                ),
                const SizedBox(width: NahpuSpacing.md),
                Expanded(
                  child: Text(
                    l10n.databaseNoSafetyBackup,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The current database beside the file chosen to replace it.
///
/// Read before anything is overwritten, so a wrong, damaged, or newer file is
/// caught while the current data is still in place.
class DatabaseComparisonPanel extends StatelessWidget {
  const DatabaseComparisonPanel({
    super.key,
    required this.current,
    required this.currentError,
    required this.replacement,
  });

  /// Null while the current database is still being read.
  final DbBackupSummary? current;
  final String? currentError;

  /// Null until a file is chosen.
  final DbReplacementPreview? replacement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final current = this.current;
    final currentError = this.currentError;
    final replacement = this.replacement;
    final issue = replacement?.issue;
    // A file that is not a NAHPU database, or could not be read, has nothing
    // worth comparing.
    final contents =
        issue == DbReplacementIssue.notNahpuDatabase ||
            issue == DbReplacementIssue.unreadable
        ? null
        : replacement?.contents;
    final hasReplacement = replacement != null;
    final l10n = context.l10n;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.databaseComparisonTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: NahpuSpacing.md),
          if (issue != null) ...[
            _ReplacementIssueNotice(issue: issue),
            const SizedBox(height: NahpuSpacing.lg),
          ],
          if (currentError != null)
            ErrorText(error: currentError)
          else if (current == null)
            const Padding(
              padding: EdgeInsets.all(NahpuSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                // Columns are as wide as their longest value, so a narrow
                // screen scrolls sideways instead of breaking a word.
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _ComparisonTable(
                    lines: _linesFor(l10n, current, contents),
                    hasReplacement: hasReplacement,
                  ),
                ),
              ),
            ),
            if (_schemaNote(l10n, contents?.schemaVersion)
                case final note?) ...[
              const SizedBox(height: NahpuSpacing.sm),
              Text(
                note,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: (contents?.schemaVersion ?? 0) > kSchemaVersion
                      ? colors.error
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
          if (!hasReplacement) ...[
            const SizedBox(height: NahpuSpacing.md),
            Text(
              l10n.databaseChooseFileToCompare,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (replacement?.includesSettings ?? false) ...[
            const SizedBox(height: NahpuSpacing.md),
            Text(
              l10n.databaseArchiveIncludesConfigs,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<_ComparisonLine> _linesFor(
    AppLocalizations l10n,
    DbBackupSummary current,
    DbContentsSummary? contents,
  ) {
    final replacementSchema = contents?.schemaVersion;
    return [
      _ComparisonLine(
        label: l10n.databaseSchemaVersion,
        current: 'v${current.schemaVersion}',
        replacement: replacementSchema == null ? null : 'v$replacementSchema',
        isReplacementWarning: (replacementSchema ?? 0) > kSchemaVersion,
      ),
      for (final MapEntry(key: label, value: table) in dbSummaryTables.entries)
        _ComparisonLine.count(
          label: _tableLabel(l10n, table) ?? label,
          current: current.entries[label] ?? 0,
          replacement: contents?.entries[label],
        ),
      _ComparisonLine.count(
        label: l10n.databaseAssociatedFiles,
        current: current.entries['Associated files'] ?? 0,
        replacement: contents?.associatedFiles,
      ),
      _ComparisonLine(
        label: l10n.databaseSize,
        current: formatByteSize(current.totalBytes),
        replacement: contents == null
            ? null
            : formatByteSize(contents.totalBytes),
        isEmphasized: true,
      ),
    ];
  }

  /// A sentence under the table rather than a cell note, so it never widens a
  /// column.
  String? _schemaNote(AppLocalizations l10n, int? version) {
    if (version == null || version == kSchemaVersion) return null;
    return version < kSchemaVersion
        ? l10n.databaseSchemaUpgraded(version, kSchemaVersion)
        : l10n.databaseSchemaNewer(version);
  }

  /// The display name of a [dbSummaryTables] table, whose English labels
  /// double as the summary's keys. Null for a table added there but not here.
  String? _tableLabel(AppLocalizations l10n, String table) => switch (table) {
    'project' => l10n.databaseTableProjects,
    'personnel' => l10n.databaseTablePersonnel,
    'taxonomy' => l10n.databaseTableTaxa,
    'site' => l10n.databaseTableSites,
    'collEvent' => l10n.databaseTableCollectionEvents,
    'specimen' => l10n.databaseTableSpecimens,
    'narrative' => l10n.databaseTableNarratives,
    'media' => l10n.databaseTableMediaRecords,
    _ => null,
  };
}

class _ReplacementIssueNotice extends StatelessWidget {
  const _ReplacementIssueNotice({required this.issue});

  final DbReplacementIssue issue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return NahpuPanel(
      borderColor: colors.error,
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error),
          const SizedBox(width: NahpuSpacing.md),
          Expanded(child: Text(_message(context.l10n))),
        ],
      ),
    );
  }

  String _message(AppLocalizations l10n) => switch (issue) {
    DbReplacementIssue.notNahpuDatabase => l10n.databaseIssueNotNahpu,
    DbReplacementIssue.newerSchema => l10n.databaseIssueNewerSchema,
    DbReplacementIssue.unreadable => l10n.databaseIssueUnreadable,
  };
}

/// One line of the comparison, before it is laid out.
class _ComparisonLine {
  const _ComparisonLine({
    required this.label,
    required this.current,
    required this.replacement,
    this.change = '',
    this.isLoss = false,
    this.isEmphasized = false,
    this.isReplacementWarning = false,
  });

  /// A count line. The change is blank when nothing differs or the replacement
  /// count is missing.
  factory _ComparisonLine.count({
    required String label,
    required int current,
    required int? replacement,
  }) {
    final difference = replacement == null ? 0 : replacement - current;
    return _ComparisonLine(
      label: label,
      current: '$current',
      replacement: replacement?.toString(),
      change: difference == 0
          ? ''
          : difference > 0
          ? '+$difference'
          : '$difference',
      isLoss: difference < 0,
    );
  }

  final String label;
  final String current;

  /// Null when the replacement has no value here, which shows as a dash.
  final String? replacement;
  final String change;

  /// Whether the replacement has fewer records than the current database.
  final bool isLoss;
  final bool isEmphasized;

  /// Whether the replacement value is a reason the file cannot be restored.
  final bool isReplacementWarning;
}

/// The comparison as a table whose columns fit their content.
///
/// The label column takes any spare width, so the table fills a wide panel; on
/// a narrow one the table is wider than the panel and scrolls instead.
class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.lines, required this.hasReplacement});

  final List<_ComparisonLine> lines;

  /// Whether a file is chosen, which adds the replacement and change columns.
  final bool hasReplacement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final rule = BorderSide(
      color: colors.outlineVariant,
      width: NahpuStroke.thin,
    );
    final l10n = context.l10n;
    final headerStyle = theme.textTheme.labelSmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {0: IntrinsicColumnWidth(flex: 1)},
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          decoration: BoxDecoration(border: Border(bottom: rule)),
          children: [
            const _ComparisonCell(text: '', isLabel: true),
            _ComparisonCell(
              text: l10n.databaseColumnCurrent,
              style: headerStyle,
            ),
            if (hasReplacement) ...[
              _ComparisonCell(
                text: l10n.databaseColumnReplacement,
                style: headerStyle,
              ),
              _ComparisonCell(
                text: l10n.databaseColumnChange,
                style: headerStyle,
              ),
            ],
          ],
        ),
        for (final line in lines)
          TableRow(
            decoration: line.isEmphasized
                ? BoxDecoration(border: Border(top: rule))
                : null,
            children: [
              _ComparisonCell(
                text: line.label,
                isLabel: true,
                style: line.isEmphasized
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.bodyMedium,
              ),
              _ComparisonCell(
                text: line.current,
                style: line.isEmphasized
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.bodyMedium,
              ),
              if (hasReplacement) ...[
                _ComparisonCell(
                  text: line.replacement ?? '—',
                  style:
                      (line.isEmphasized
                              ? theme.textTheme.titleSmall
                              : theme.textTheme.bodyMedium)
                          ?.copyWith(
                            color: line.isReplacementWarning
                                ? colors.error
                                : null,
                          ),
                ),
                _ComparisonCell(
                  text: line.change,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: line.isLoss ? colors.error : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

/// A single-line table cell. Values sit at the end of their column, with a
/// gap before them; the label starts flush with the panel.
class _ComparisonCell extends StatelessWidget {
  const _ComparisonCell({required this.text, this.style, this.isLabel = false});

  final String text;
  final TextStyle? style;
  final bool isLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isLabel ? 0 : NahpuSpacing.xl,
        top: NahpuSpacing.sm,
        bottom: NahpuSpacing.sm,
      ),
      child: Text(
        text,
        softWrap: false,
        textAlign: isLabel ? TextAlign.start : TextAlign.end,
        style: style,
      ),
    );
  }
}

class _RestoreProgressView extends StatelessWidget {
  const _RestoreProgressView({
    required this.progress,
    required this.isCancelling,
    required this.onCancel,
  });

  final ExportJobProgress progress;
  final bool isCancelling;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.databaseReplaceDatabase),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NahpuSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: NahpuContentWidth.form,
              ),
              child: ExportProgressPanel(
                title: l10n.databaseRestoring,
                progress: progress,
                hint: l10n.databaseRestoreHint,
                isCancelling: isCancelling,
                onCancel: onCancel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DatabaseCandidateDialog extends StatelessWidget {
  const DatabaseCandidateDialog({super.key, required this.candidates});

  final List<DbArchiveDatabaseCandidate> candidates;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.databaseChooseDatabase),
      content: Text(l10n.databaseChooseDatabaseBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        for (final candidate in candidates)
          TextButton(
            onPressed: () => Navigator.of(context).pop(candidate.archivePath),
            child: Text(candidate.displayName),
          ),
      ],
    );
  }
}

/// Confirmation text that only adds what the page does not already say:
/// whether a safety backup will be taken.
class DbWarningText extends StatelessWidget {
  const DbWarningText({super.key, required this.isBackup});

  final bool isBackup;

  @override
  Widget build(BuildContext context) {
    return Text(
      isBackup
          ? context.l10n.databaseConfirmWithBackup
          : context.l10n.databaseConfirmWithoutBackup,
    );
  }
}

class DBReplacedPage extends StatelessWidget {
  const DBReplacedPage({super.key, required this.dbBackupPath});

  final File? dbBackupPath;

  @override
  Widget build(BuildContext context) {
    final backupPath = dbBackupPath;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.databaseReplaceDatabase),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(NahpuSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FileFormatIcon(path: 'assets/icons/database.svg'),
                Text(
                  l10n.databaseReplaceSuccess,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  l10n.databaseReplaced,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (backupPath != null) ...[
                  const SizedBox(height: NahpuSpacing.md),
                  Text(
                    l10n.databaseBackupFilePath,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: NahpuContentWidth.form,
                    ),
                    child: Text(
                      Platform.isIOS ? _iOSPath(l10n) : backupPath.path,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: NahpuSpacing.xl),
                PrimaryButton(
                  label: l10n.databaseBackToHome,
                  icon: Icons.arrow_back,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _iOSPath(AppLocalizations l10n) {
    return l10n.databaseIosBackupPath(
      nahpuAppDir,
      nahpuBackupDir,
      p.basename(dbBackupPath != null ? dbBackupPath!.path : ''),
    );
  }
}
