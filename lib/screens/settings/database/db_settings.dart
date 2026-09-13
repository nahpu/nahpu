import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/home/home.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/screens/shared/file/db_backup_summary_panel.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
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
  bool _isLoadingSummary = false;

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
              onSelectFile: _selectFile,
              onClearFile: _clearFile,
              onBackupChanged: _setBackup,
              onReplace: _hasSelected ? _confirmReplace : null,
            ),
    );
  }

  /// Reads what the safety backup will copy, the first time it is turned on.
  Future<void> _loadSummary() async {
    if (_summary != null || _isLoadingSummary) return;
    _isLoadingSummary = true;
    _summaryError = null;
    try {
      final summary = await DbExport(ref: ref, filePath: File('')).getSummary();
      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (error) {
      if (!mounted) return;
      setState(() => _summaryError = error.toString());
    } finally {
      _isLoadingSummary = false;
    }
  }

  void _setBackup(bool value) {
    setState(() => _isBackup = value);
    if (value) unawaited(_loadSummary());
  }

  Future<void> _selectFile() async {
    try {
      await _getDbPath();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to select file!')));
    }
  }

  void _clearFile() {
    setState(() {
      _dbPath = null;
      _hasSelected = false;
      _isArchived = false;
      _databaseRelativePath = null;
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
        }
        setState(() {
          _dbPath = dbPath;
          _hasSelected = true;
          _isArchived = isArchived;
          _databaseRelativePath = databaseRelativePath;
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
        return AlertDialog(
          title: const Text('Replace database?'),
          content: DbWarningText(isBackup: _isBackup),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Replace'),
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
        const SnackBar(
          content: Text('Restore cancelled. The database was not replaced.'),
        ),
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
        const SnackBar(
          content: Text(
            'The restore is replacing your data and cannot be stopped now.',
          ),
        ),
      );
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel the restore?'),
        content: const Text(
          'The archive is still being read. Leaving now cancels the restore '
          'and your current data is left untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep restoring'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel restore'),
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
        content: Text('Failed to replace database!: $errors'),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}

/// Laid out like the backup window: options on the left, what the safety
/// backup copies on the right, and the action pinned below both.
class _ReplaceDatabaseForm extends StatelessWidget {
  const _ReplaceDatabaseForm({
    required this.dbPath,
    required this.isArchived,
    required this.databaseRelativePath,
    required this.isSelectingFile,
    required this.isBackup,
    required this.summary,
    required this.summaryError,
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
  final VoidCallback onSelectFile;
  final VoidCallback onClearFile;
  final ValueChanged<bool> onBackupChanged;

  /// Null until a database file is selected.
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final options = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DatabaseSourceCard(
          dbPath: dbPath,
          isArchived: isArchived,
          databaseRelativePath: databaseRelativePath,
          isSelectingFile: isSelectingFile,
          onSelectFile: onSelectFile,
          onClearFile: onClearFile,
        ),
        const SizedBox(height: NahpuSpacing.xl),
        _SafetyBackupCard(isBackup: isBackup, onChanged: onBackupChanged),
      ],
    );
    // The same contents list as the backup window, so the user sees how
    // large the safety backup is before starting.
    final contents = isBackup
        ? DbBackupSummaryPanel(summary: summary, error: summaryError)
        : const _NoBackupNotice();
    return Scaffold(
      appBar: AppBar(title: const Text('Replace database')),
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
                                  Expanded(child: contents),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  options,
                                  const SizedBox(height: NahpuSpacing.xl),
                                  contents,
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Pinned below the scroll view, as in the backup window, so the
            // action stays in reach however long the contents list grows.
            ExportActionBar(
              label: 'Replace database',
              repeatLabel: 'Replace database',
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
    required this.onSelectFile,
    required this.onClearFile,
  });

  final XFile? dbPath;
  final bool isArchived;
  final String? databaseRelativePath;
  final bool isSelectingFile;
  final VoidCallback onSelectFile;
  final VoidCallback onClearFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final file = dbPath;
    final hasFile = file != null;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Replace with', style: theme.textTheme.titleLarge),
          const SizedBox(height: NahpuSpacing.md),
          const Text('A NAHPU backup archive or a SQLite database file.'),
          const SizedBox(height: NahpuSpacing.xl),
          Material(
            color: colors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NahpuRadius.md),
              side: BorderSide(
                color: hasFile ? colors.primary : colors.outlineVariant,
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
                                : 'No file selected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: NahpuSpacing.xxs),
                          Text(
                            _detail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
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
                        label: const Text('Browse'),
                      )
                    else ...[
                      TextButton(
                        onPressed: onSelectFile,
                        child: const Text('Change'),
                      ),
                      IconButton(
                        onPressed: onClearFile,
                        icon: const Icon(Icons.clear_rounded),
                        tooltip: 'Clear file',
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

  String get _detail {
    if (dbPath == null) return 'ZIP, TAR.GZ, or SQLITE3';
    if (!isArchived) return 'SQLite database';
    final database = databaseRelativePath;
    return database == null
        ? 'NAHPU backup archive'
        : 'NAHPU backup archive · restores $database';
  }
}

class _SafetyBackupCard extends StatelessWidget {
  const _SafetyBackupCard({required this.isBackup, required this.onChanged});

  final bool isBackup;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Before replacing', style: theme.textTheme.titleLarge),
          const SizedBox(height: NahpuSpacing.md),
          Text(
            'Every record in NAHPU is replaced, and media or config files that '
            'match the archive are overwritten in place. This cannot be '
            'undone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NahpuSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Back up current data first'),
            subtitle: const Text(
              'Saves a full archive, including media, to the NAHPU backup '
              'folder',
            ),
            value: isBackup,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Takes the contents list's place when the safety backup is off, so the risk
/// is stated where the numbers would have been.
class _NoBackupNotice extends StatelessWidget {
  const _NoBackupNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NahpuPanel(
      borderColor: theme.colorScheme.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: NahpuSpacing.md),
              Expanded(
                child: Text(
                  'No safety backup',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.md),
          const Text(
            'Your current records and media are not saved before they are '
            'replaced. Turn on Back up current data first, or save one from '
            'Backup database.',
          ),
        ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replace database'),
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
                title: 'Restoring database',
                progress: progress,
                hint:
                    'Restoring a backup with many photos can take several '
                    'minutes. Keep NAHPU open until this finishes.',
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
    return AlertDialog(
      title: const Text('Choose database'),
      content: const Text(
        'This archive contains multiple database files at its root. '
        'Choose the database to restore.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
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
          ? 'A full backup of your current data is saved first. Continue?'
          : 'No backup will be made, so your current data cannot be '
                'recovered. Continue?',
    );
  }
}

class DBReplacedPage extends StatelessWidget {
  const DBReplacedPage({super.key, required this.dbBackupPath});

  final File? dbBackupPath;

  @override
  Widget build(BuildContext context) {
    final backupPath = dbBackupPath;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replace database'),
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
                  'Success 🎉',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Database has been replaced!',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (backupPath != null) ...[
                  const SizedBox(height: NahpuSpacing.md),
                  Text(
                    'Backup file path:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: NahpuContentWidth.form,
                    ),
                    child: Text(
                      Platform.isIOS ? _iOSPath : backupPath.path,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: NahpuSpacing.xl),
                PrimaryButton(
                  label: 'Back to Home',
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

  String get _iOSPath {
    return 'Files app/On my Devices/$nahpuAppDir/$nahpuBackupDir/'
        '${p.basename(dbBackupPath != null ? dbBackupPath!.path : '')}';
  }
}
