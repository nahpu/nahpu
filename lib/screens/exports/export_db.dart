import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/services/export/db_writer.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/types/export.dart';

class ExportDbForm extends ConsumerStatefulWidget {
  const ExportDbForm({super.key});

  @override
  ExportDbFormState createState() => ExportDbFormState();
}

class ExportDbFormState extends ConsumerState<ExportDbForm> {
  DbArchiveFormat _format = DbArchiveFormat.tarGzip;
  final _fileNameController = TextEditingController(text: 'backup');
  String _fileStem = 'backup';
  Directory? _selectedDir;
  bool _appendDate = false;
  DbBackupSummary? _summary;
  File? _savePath;
  String? _summaryError;
  bool _hasSaved = false;
  bool _isLoading = true;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup database')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final settings = _BackupSettingsCard(
              controller: _fileNameController,
              format: _format,
              directory: _selectedDir,
              appendDate: _appendDate,
              enabled: !_isLoading && !_isRunning,
              onFormatChanged: (value) {
                setState(() {
                  _format = value;
                  _hasSaved = false;
                });
              },
              onFileNameChanged: (value) {
                setState(() {
                  _fileStem = value;
                  _hasSaved = false;
                });
              },
              onAppendDateChanged: (value) {
                setState(() {
                  _appendDate = value;
                  _hasSaved = false;
                });
              },
              onSelectDirectory: _getDir,
              onClearDirectory: () => setState(() {
                _selectedDir = null;
                _hasSaved = false;
              }),
            );
            final summary = _BackupSummary(
              summary: _summary,
              error: _summaryError,
            );
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: settings),
                                  const SizedBox(width: 20),
                                  Expanded(child: summary),
                                ],
                              )
                            : Column(
                                children: [
                                  settings,
                                  const SizedBox(height: 16),
                                  summary,
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                _BackupActionBar(
                  isRunning: _isRunning,
                  canSave:
                      !_isLoading &&
                      _summary != null &&
                      _summaryError == null &&
                      _fileNameController.text.trim().isNotEmpty,
                  hasSaved: _hasSaved,
                  onSave: _writeDb,
                  onShare: () => _shareFile(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await DbExport(ref: ref, filePath: File('')).getSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _summaryError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _writeDb() async {
    setState(() => _isRunning = true);
    try {
      final savePath = await AppIOServices(
        dir: _selectedDir,
        fileStem: _appendDate
            ? appendDateToFileStem(_fileStem, DateTime.now())
            : _fileStem.trim(),
        ext: _format.extension,
      ).getSavePath();
      final output = await DbExport(
        ref: ref,
        filePath: savePath,
      ).write(_format);
      if (!mounted) return;
      setState(() {
        _hasSaved = true;
        _savePath = output;
      });
      _showSuccess();
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('File saved as ${_savePath!.path}')));
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorText(error: error),
        duration: const Duration(seconds: 10),
      ),
    );
  }

  Future<void> _shareFile(BuildContext context) async {
    final savePath = _savePath;
    if (savePath == null) return;
    try {
      await FilePickerServices().shareFile(context, savePath);
    } catch (error) {
      if (mounted) _showError(error.toString());
    }
  }

  Future<void> _getDir() async {
    final selected = await FilePickerServices().selectDir();
    if (selected == null || !mounted) return;
    setState(() {
      _selectedDir = selected;
      _hasSaved = false;
    });
  }
}

class _BackupSettingsCard extends StatelessWidget {
  const _BackupSettingsCard({
    required this.controller,
    required this.format,
    required this.directory,
    required this.appendDate,
    required this.enabled,
    required this.onFormatChanged,
    required this.onFileNameChanged,
    required this.onAppendDateChanged,
    required this.onSelectDirectory,
    required this.onClearDirectory,
  });

  final TextEditingController controller;
  final DbArchiveFormat format;
  final Directory? directory;
  final bool appendDate;
  final bool enabled;
  final ValueChanged<DbArchiveFormat> onFormatChanged;
  final ValueChanged<String> onFileNameChanged;
  final ValueChanged<bool> onAppendDateChanged;
  final VoidCallback onSelectDirectory;
  final VoidCallback onClearDirectory;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup archive',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'This creates a full NAHPU backup, including all projects, '
              'records, media, and app settings. For a project-only backup, '
              'use Project export.',
            ),
            const SizedBox(height: 20),
            SegmentedButton<DbArchiveFormat>(
              segments: const [
                ButtonSegment(
                  value: DbArchiveFormat.tarGzip,
                  label: Text('TAR.GZ'),
                  icon: Icon(Icons.folder_zip_outlined),
                ),
                ButtonSegment(
                  value: DbArchiveFormat.zip,
                  label: Text('ZIP'),
                  icon: Icon(Icons.folder_zip_outlined),
                ),
              ],
              selected: {format},
              onSelectionChanged: enabled
                  ? (values) => onFormatChanged(values.single)
                  : null,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              enabled: enabled,
              onChanged: onFileNameChanged,
              decoration: InputDecoration(
                labelText: 'File name',
                suffixText: '.${format.extension}',
                border: const OutlineInputBorder(),
              ),
            ),
            AppendDateSwitch(
              value: appendDate,
              enabled: enabled,
              onChanged: onAppendDateChanged,
            ),
            const SizedBox(height: 16),
            if (systemPlatform == PlatformType.desktop)
              FileSettingsDirectoryPicker(
                selectedDir: directory,
                onSelectDir: enabled ? onSelectDirectory : () {},
                onClearDir: enabled ? onClearDirectory : () {},
              ),
          ],
        ),
      ),
    );
  }
}

class _BackupSummary extends StatelessWidget {
  const _BackupSummary({required this.summary, required this.error});

  final DbBackupSummary? summary;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entire database contents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (error != null)
              ErrorText(error: error!)
            else if (summary == null)
              const Center(child: CircularProgressIndicator())
            else
              for (final entry in summary!.entries.entries)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key),
                  trailing: Text('${entry.value}'),
                ),
          ],
        ),
      ),
    );
  }
}

class _BackupActionBar extends StatelessWidget {
  const _BackupActionBar({
    required this.isRunning,
    required this.canSave,
    required this.hasSaved,
    required this.onSave,
    required this.onShare,
  });

  final bool isRunning;
  final bool canSave;
  final bool hasSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasSaved)
                OutlinedButton.icon(
                  onPressed: onShare,
                  icon: Icon(Icons.adaptive.share_rounded),
                  label: const Text('Share'),
                ),
              if (hasSaved) const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: canSave && !isRunning ? onSave : null,
                icon: isRunning
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt_outlined),
                label: Text(hasSaved ? 'Save another' : 'Save backup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
