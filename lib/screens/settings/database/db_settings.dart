import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/home/home.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/actions/export_progress_panel.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
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

  @override
  void dispose() {
    unawaited(_progressSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // A restore rewrites the database in place; leaving part way through
      // would be worse than waiting, so the user has to decide deliberately.
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final jobProgress = _jobProgress;
    if (_isLoading && jobProgress != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Replace Database'),
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
                  progress: jobProgress,
                  hint:
                      'Restoring a backup with many photos can take several '
                      'minutes. Keep NAHPU open until this finishes.',
                  isCancelling: _isCancelling,
                  // Cancelling is only offered while the archive is being read.
                  // Once files start landing in place, stopping half way would
                  // leave the app in a state the user cannot reason about.
                  onCancel: _canCancelRestore(jobProgress)
                      ? _requestCancel
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Replace Database')),
      body: SafeArea(
        child: CommonSettingList(
          sections: [
            DbFileInputField(
              dbPath: _dbPath,
              isSelectingFile: _isSelectingFile,
              onPressed: () async {
                try {
                  await _getDbPath();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to select file!')),
                    );
                  }
                }
              },
              onCleared: () {
                setState(() {
                  _dbPath = null;
                  _hasSelected = false;
                  _isArchived = false;
                  _databaseRelativePath = null;
                });
              },
              isBackup: _isBackup,
              onBackupChosen: (bool value) async {
                _isBackup = value;

                setState(() {});
              },
              hasSelected: _hasSelected,
              isLoading: _isLoading,
              onReplaceDb: () => _replaceDb(),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _replaceDb() async {
    Navigator.of(context).pop();

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
      final backupPath = _isBackup
          ? await AppServices(ref: ref).backupDir
          : null;

      await DbWriter(ref: ref, filePath: File(_dbPath!.path)).replace(
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
      if (context.mounted) {
        _navigate(backupPath);
      }
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
      if (context.mounted) {
        _showError(e.toString());
      }
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

  void _navigate(File? backupPath) {
    ref.invalidate(databaseProvider);
    ref.invalidate(projectListProvider);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DBReplacedPage(dbBackupPath: backupPath),
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

class DbFileInputField extends StatelessWidget {
  const DbFileInputField({
    super.key,
    required this.dbPath,
    required this.isBackup,
    required this.onPressed,
    required this.onCleared,
    required this.onBackupChosen,
    required this.hasSelected,
    required this.isSelectingFile,
    required this.isLoading,
    required this.onReplaceDb,
  });

  final XFile? dbPath;
  final bool isBackup;
  final VoidCallback onPressed;
  final VoidCallback onCleared;
  final void Function(bool) onBackupChosen;
  final bool hasSelected;
  final bool isSelectingFile;
  final bool isLoading;
  final VoidCallback onReplaceDb;

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      children: [
        const SizedBox(height: 8),
        Center(
          child: SelectFileField(
            filePath: dbPath,
            width: 460,
            onPressed: onPressed,
            isLoading: isSelectingFile,
            onCleared: onCleared,
            supportedFormat: '.sqlite3, NAHPU archive (.zip/.tar.gz)',
            maxWidth: 460,
          ),
        ),
        const SizedBox(height: NahpuSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
            child: SwitchField(
              label: 'Back up current data first',
              value: isBackup,
              onPressed: onBackupChosen,
            ),
          ),
        ),
        const SizedBox(height: NahpuSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: NahpuSpacing.lg),
            child: Text(
              'Replacing overwrites every record and every media file in '
              'NAHPU. Backing up first writes a full archive of your current '
              'data, including all media, to the backup folder — it can take '
              'several minutes on a large library.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: NahpuSpacing.md),
        const _BackupWindowLink(),
        const SizedBox(height: NahpuSpacing.xl),
        DbReplaceButtons(
          hasSelected: hasSelected,
          isRunning: isLoading,
          onPressed: onReplaceDb,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Sends the user to the backup window before they overwrite anything.
///
/// The switch above takes a safety copy, but a user who came here to protect
/// their data wants the real backup screen, where they choose the destination
/// and keep the archive.
class _BackupWindowLink extends StatelessWidget {
  const _BackupWindowLink();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        icon: const Icon(Icons.backup_outlined),
        label: const Text('Open the backup window'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExportDbForm()),
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

class DbReplaceButtons extends StatelessWidget {
  const DbReplaceButtons({
    super.key,
    required this.hasSelected,
    required this.isRunning,
    required this.onPressed,
  });

  final bool hasSelected;
  final bool isRunning;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ProgressButton(
      label: 'Replace',
      icon: Icons.refresh,
      isRunning: isRunning,
      onPressed: !hasSelected
          ? null
          : () async {
              // Alert users before replacing database
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Replace Database'),
                  content: const DbWarningText(),
                  actions: [
                    PrimaryButton(
                      label: 'Cancel',
                      icon: Icons.cancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      onPressed: onPressed,
                      child: Text(
                        'Replace',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
    );
  }
}

class DbWarningText extends StatelessWidget {
  const DbWarningText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Replacing the database will delete all the current data. '
      'Remember to backup your data before proceeding. Continue?',
      textAlign: TextAlign.center,
    );
  }
}

class DBReplacedPage extends StatelessWidget {
  const DBReplacedPage({super.key, required this.dbBackupPath});

  final File? dbBackupPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Settings'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FileFormatIcon(path: 'assets/icons/database.svg'),
              Text(
                'Success 🎉',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Database has been replaced!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              dbBackupPath == null
                  ? const SizedBox.shrink()
                  : Text(
                      'Backup file path:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
              dbBackupPath == null
                  ? const SizedBox.shrink()
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Text(
                        Platform.isIOS ? _iOSPath : dbBackupPath!.path,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
              const SizedBox(height: 18),
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
    );
  }

  String get _iOSPath {
    return 'Files app/On my Devices/$nahpuAppDir/$nahpuBackupDir/'
        '${p.basename(dbBackupPath != null ? dbBackupPath!.path : '')}';
  }
}
