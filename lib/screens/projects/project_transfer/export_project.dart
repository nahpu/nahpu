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
  ProjectTransferArchiveFormat _format = ProjectTransferArchiveFormat.zip;
  ProjectTransferPayload? _payload;
  Directory? _directory;
  File? _output;
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
              directory: _directory,
              enabled: !_isLoading && !_isSaving,
              onFormatChanged: (value) {
                setState(() {
                  _format = value;
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
        fileStem: _fileNameController.text,
        format: _format,
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
    required this.directory,
    required this.enabled,
    required this.onFormatChanged,
    required this.onSelectDirectory,
    required this.onClearDirectory,
  });

  final TextEditingController controller;
  final ProjectTransferArchiveFormat format;
  final Directory? directory;
  final bool enabled;
  final ValueChanged<ProjectTransferArchiveFormat> onFormatChanged;
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
              'Transfer archive',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this archive to add data from this project to the same '
              'project on another device.',
            ),
            const SizedBox(height: 20),
            SegmentedButton<ProjectTransferArchiveFormat>(
              segments: ProjectTransferArchiveFormat.values
                  .map(
                    (value) => ButtonSegment(
                      value: value,
                      label: Text(value.label),
                      icon: const Icon(Icons.folder_zip_outlined),
                    ),
                  )
                  .toList(),
              selected: {format},
              onSelectionChanged: enabled
                  ? (values) => onFormatChanged(values.single)
                  : null,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                labelText: 'File name',
                suffixText: '.${format.extension}',
                border: const OutlineInputBorder(),
              ),
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
  });

  final ProjectTransferPayload? payload;
  final bool isLoading;
  final String? error;

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
                    '${entry.value}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              if (payload!.warnings.isNotEmpty) ...[
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
