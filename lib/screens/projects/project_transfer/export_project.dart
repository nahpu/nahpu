import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/project_transfer/project_transfer_service.dart';

class ExportProjectScreen extends ConsumerStatefulWidget {
  const ExportProjectScreen({super.key});

  @override
  ConsumerState<ExportProjectScreen> createState() =>
      _ExportProjectScreenState();
}

class _ExportProjectScreenState extends ConsumerState<ExportProjectScreen> {
  final _fileNameController = TextEditingController();
  ProjectTransferArchiveFormat _format = ProjectTransferArchiveFormat.tarGzip;
  bool _lightExport = false;
  ProjectTransferPayload? _payload;
  Directory? _directory;
  File? _output;
  bool _appendDate = false;
  String? _error;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export project')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final settings = _SettingsCard(
              controller: _fileNameController,
              format: _format,
              lightExport: _lightExport,
              directory: _directory,
              appendDate: _appendDate,
              enabled: !_isLoading && !_isSaving,
              onFormatChanged: (value) {
                setState(() {
                  _format = value;
                  _output = null;
                });
              },
              onAppendDateChanged: (value) {
                setState(() {
                  _appendDate = value;
                  _output = null;
                });
              },
              onLightExportChanged: (value) {
                setState(() {
                  _lightExport = value;
                  _output = null;
                });
              },
              onSelectDirectory: _selectDirectory,
              onClearDirectory: () => setState(() {
                _directory = null;
                _output = null;
              }),
            );
            final summary = _SummaryCard(
              payload: _payload,
              isLoading: _isLoading,
              error: _error,
              includeMedia: !_lightExport,
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
                _ExportActionBar(
                  isSaving: _isSaving,
                  canExport: _payload != null && _error == null,
                  hasOutput: _output != null,
                  onExport: _save,
                  onShare: _share,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _load() async {
    try {
      final payload = await ProjectTransferService(ref: ref).buildExport();
      if (!mounted) return;
      setState(() {
        _payload = payload;
        _fileNameController.text =
            '${_safeStem(payload.projectName)}-nahpu-transfer';
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDirectory() async {
    final selected = await FilePickerServices().selectDir();
    if (selected == null || !mounted) return;
    setState(() {
      _directory = selected;
      _output = null;
    });
  }

  Future<void> _save() async {
    final payload = _payload;
    if (payload == null) return;
    setState(() => _isSaving = true);
    try {
      final output = await ProjectTransferService(ref: ref).archive.save(
        payload,
        fileStem: _appendDate
            ? appendDateToFileStem(_fileNameController.text, DateTime.now())
            : _fileNameController.text,
        format: _lightExport ? ProjectTransferArchiveFormat.jsonGzip : _format,
        destinationDirectory: _directory,
      );
      if (!mounted) return;
      setState(() => _output = output);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project transfer saved as ${output.path}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ErrorText(error: error.toString()),
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _share() async {
    final output = _output;
    if (output == null) return;
    await FilePickerServices().shareFile(context, output);
  }

  String _safeStem(String value) {
    final cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'project' : cleaned;
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.controller,
    required this.format,
    required this.lightExport,
    required this.directory,
    required this.appendDate,
    required this.enabled,
    required this.onFormatChanged,
    required this.onAppendDateChanged,
    required this.onLightExportChanged,
    required this.onSelectDirectory,
    required this.onClearDirectory,
  });

  final TextEditingController controller;
  final ProjectTransferArchiveFormat format;
  final bool lightExport;
  final Directory? directory;
  final bool appendDate;
  final bool enabled;
  final ValueChanged<ProjectTransferArchiveFormat> onFormatChanged;
  final ValueChanged<bool> onAppendDateChanged;
  final ValueChanged<bool> onLightExportChanged;
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
              'Backup and transfer archive',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this archive to create a project backup, '
              'transfer, or merge this project data to another device.',
            ),
            const SizedBox(height: 20),
            if (!lightExport)
              SegmentedButton<ProjectTransferArchiveFormat>(
                segments: const [
                  ButtonSegment(
                    value: ProjectTransferArchiveFormat.tarGzip,
                    label: Text('TAR.GZ'),
                    icon: Icon(Icons.folder_zip_outlined),
                  ),
                  ButtonSegment(
                    value: ProjectTransferArchiveFormat.zip,
                    label: Text('ZIP'),
                    icon: Icon(Icons.folder_zip_outlined),
                  ),
                ],
                selected: {format},
                onSelectionChanged: enabled
                    ? (values) => onFormatChanged(values.single)
                    : null,
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Light export'),
              subtitle: lightExport
                  ? const Text(
                      'Export the project without media files for limited-internet uploads. '
                      'Use TAR.GZ or ZIP for a full project backup.',
                    )
                  : null,
              value: lightExport,
              onChanged: enabled ? onLightExportChanged : null,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                labelText: 'File name',
                suffixText:
                    '.${lightExport ? ProjectTransferArchiveFormat.jsonGzip.extension : format.extension}',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.payload,
    required this.isLoading,
    required this.error,
    required this.includeMedia,
  });

  final ProjectTransferPayload? payload;
  final bool isLoading;
  final String? error;
  final bool includeMedia;

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
              'Archive contents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              ErrorText(error: error!)
            else ...[
              for (final entry in payload!.summary.entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline_rounded),
                  title: Text(entry.key),
                  trailing: Text(
                    entry.key == 'Media' && !includeMedia
                        ? 'Excluded'
                        : '${entry.value}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              if (includeMedia && payload!.warnings.isNotEmpty) ...[
                const Divider(),
                Text(
                  '${payload!.warnings.length} warning(s)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final warning in payload!.warnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $warning'),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ExportActionBar extends StatelessWidget {
  const _ExportActionBar({
    required this.isSaving,
    required this.canExport,
    required this.hasOutput,
    required this.onExport,
    required this.onShare,
  });

  final bool isSaving;
  final bool canExport;
  final bool hasOutput;
  final VoidCallback onExport;
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
              if (hasOutput)
                OutlinedButton.icon(
                  onPressed: onShare,
                  icon: Icon(Icons.adaptive.share_rounded),
                  label: const Text('Share'),
                ),
              if (hasOutput) const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: canExport && !isSaving ? onExport : null,
                icon: isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.archive_outlined),
                label: Text(hasOutput ? 'Export another' : 'Export project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
