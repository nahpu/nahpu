import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/record_exchange/project_exchange_service.dart';
import 'package:nahpu/services/types/controllers.dart';

enum _ProjectExportFormat { json }

Future<void> showProjectExportDialog({
  required BuildContext context,
  required ProjectData projectData,
}) async {
  final content = ProjectExportDialog(projectData: projectData);
  if (MediaQuery.sizeOf(context).width > 600) {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: content,
        ),
      ),
    );
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: content,
      ),
    ),
  );
}

class ProjectExportDialog extends StatefulWidget {
  const ProjectExportDialog({super.key, required this.projectData});

  final ProjectData projectData;

  @override
  State<ProjectExportDialog> createState() => _ProjectExportDialogState();
}

class _ProjectExportDialogState extends State<ProjectExportDialog> {
  late final FileOpCtrModel _exportCtr;
  Directory? _selectedDir;
  File? _outputFile;
  bool _isRunning = false;
  bool _appendDate = false;

  @override
  void initState() {
    super.initState();
    _exportCtr = FileOpCtrModel.empty();
    _exportCtr.fileNameCtr.text = widget.projectData.name;
  }

  @override
  void dispose() {
    _exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Export project info',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Export this project information as JSON.'),
          const SizedBox(height: 16),
          GenericFileSettingsCard<_ProjectExportFormat>(
            exportCtr: _exportCtr,
            selectedDir: _selectedDir,
            format: _ProjectExportFormat.json,
            formats: const [_ProjectExportFormat.json],
            formatLabel: (_) => 'JSON (.json)',
            extensionForFormat: (_) => 'json',
            onFormatChanged: (_) {},
            onFileNameChanged: (_) => _resetExport(),
            appendDate: _appendDate,
            onAppendDateChanged: (value) => setState(() {
              _appendDate = value;
              _outputFile = null;
            }),
            onSelectDir: _selectDirectory,
            onClearDir: () => setState(() {
              _selectedDir = null;
              _outputFile = null;
            }),
          ),
          const SizedBox(height: 20),
          ExportShareButton(
            hasExported: _outputFile != null,
            isRunning: _isRunning,
            onExport: _exportCtr.isValid ? _export : null,
            onShare: _share,
          ),
        ],
      ),
    );
  }

  void _resetExport() {
    if (mounted) setState(() => _outputFile = null);
  }

  Future<void> _selectDirectory() async {
    final directory = await FilePickerServices().selectDir();
    if (directory != null && mounted) {
      setState(() {
        _selectedDir = directory;
        _outputFile = null;
      });
    }
  }

  Future<void> _export() async {
    setState(() => _isRunning = true);
    try {
      final output = await ProjectExchangeService().save(
        widget.projectData,
        fileStem: _appendDate
            ? appendDateToFileStem(_exportCtr.fileNameCtr.text, DateTime.now())
            : _exportCtr.fileNameCtr.text.trim(),
        destinationDirectory: _selectedDir,
      );
      if (!mounted) return;
      setState(() => _outputFile = output);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            systemPlatform == PlatformType.desktop
                ? 'Exported to ${output.path}'
                : 'Export complete!',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final file = _outputFile;
    if (file == null) return;
    try {
      await FilePickerServices().shareFile(context, file);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
