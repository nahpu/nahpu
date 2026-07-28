import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/home/home.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/io_services.dart';
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

  @override
  Widget build(BuildContext context) {
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

    try {
      setState(() {
        _isLoading = true;
      });

      final backupPath = _isBackup
          ? await AppServices(ref: ref).backupDir
          : null;

      await DbWriter(ref: ref, filePath: File(_dbPath!.path)).replace(
        _isBackup,
        _isArchived,
        databaseRelativePath: _databaseRelativePath,
      );
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        _navigate(backupPath);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        _showError(e.toString());
      }
    }
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
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SwitchField(
              label: 'Backup current database',
              value: isBackup,
              onPressed: onBackupChosen,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Database backup restores the entire NAHPU application. '
            'For a project-only backup, use Project export.',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
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
