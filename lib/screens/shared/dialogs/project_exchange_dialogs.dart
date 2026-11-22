import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/export/export_destination.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/record_exchange/personnel_exchange_service.dart';
import 'package:nahpu/services/record_exchange/project_exchange_service.dart';
import 'package:nahpu/services/types/controllers.dart';

enum _JsonExportFormat { json }

/// Writes a JSON file named [fileStem] into [destinationDirectory], or the
/// default export folder when it is null.
typedef SaveJsonCallback =
    Future<File> Function({
      required String fileStem,
      Directory? destinationDirectory,
    });

Future<void> showProjectExportDialog({
  required BuildContext context,
  required ProjectData projectData,
}) {
  return _showJsonExportSheet(
    context: context,
    content: ProjectExportDialog(projectData: projectData),
  );
}

Future<void> showPersonnelExportDialog({
  required BuildContext context,
  required PersonnelData personnel,
}) {
  return _showJsonExportSheet(
    context: context,
    content: JsonExportDialog(
      title: context.l10n.personnelShareExportJson,
      description: context.l10n.personnelShareExportJsonDescription,
      initialFileStem: personnel.name ?? 'personnel',
      onSave: ({required fileStem, destinationDirectory}) =>
          const PersonnelExchangeService().save(
            personnel,
            fileStem: fileStem,
            destinationDirectory: destinationDirectory,
          ),
    ),
  );
}

Future<void> _showJsonExportSheet({
  required BuildContext context,
  required Widget content,
}) async {
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

class ProjectExportDialog extends StatelessWidget {
  const ProjectExportDialog({super.key, required this.projectData});

  final ProjectData projectData;

  @override
  Widget build(BuildContext context) {
    return JsonExportDialog(
      title: context.l10n.sharedExportProjectInfo,
      description: context.l10n.sharedExportProjectInfoDescription,
      initialFileStem: projectData.name,
      onSave: ({required fileStem, destinationDirectory}) =>
          ProjectExchangeService().save(
            projectData,
            fileStem: fileStem,
            destinationDirectory: destinationDirectory,
          ),
    );
  }
}

/// Saves one JSON record, then offers to share, reveal, or copy the file.
class JsonExportDialog extends StatefulWidget {
  const JsonExportDialog({
    super.key,
    required this.title,
    required this.description,
    required this.initialFileStem,
    required this.onSave,
  });

  final String title;
  final String description;
  final String initialFileStem;
  final SaveJsonCallback onSave;

  @override
  State<JsonExportDialog> createState() => _JsonExportDialogState();
}

class _JsonExportDialogState extends State<JsonExportDialog> {
  late final FileOpCtrModel _exportCtr;
  final ExportDestinationService _destination = ExportDestinationService();
  Directory? _selectedDir;
  File? _outputFile;
  bool _isRunning = false;
  bool _appendDate = false;

  @override
  void initState() {
    super.initState();
    _exportCtr = FileOpCtrModel.empty();
    _exportCtr.fileNameCtr.text = widget.initialFileStem;
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
          Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(widget.description),
          const SizedBox(height: 16),
          GenericFileSettingsCard<_JsonExportFormat>(
            exportCtr: _exportCtr,
            selectedDir: _selectedDir,
            format: _JsonExportFormat.json,
            formats: const [_JsonExportFormat.json],
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
            output: _outputFile,
            onRevealFile: _openFolder,
            onSaveCopy: _saveCopy,
          ),
        ],
      ),
    );
  }

  void _resetExport() {
    if (mounted) setState(() => _outputFile = null);
  }

  Future<void> _selectDirectory() async {
    if (!_destination.canChooseDirectory) return;
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
      final output = await widget.onSave(
        fileStem: _appendDate
            ? appendDateToFileStem(_exportCtr.fileNameCtr.text, DateTime.now())
            : _exportCtr.fileNameCtr.text.trim(),
        destinationDirectory: await _destination.resolve(_selectedDir),
      );
      if (!mounted) return;
      setState(() => _outputFile = output);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            // Only a folder the user chose is worth naming; the fallback is
            // a path they cannot act on.
            _selectedDir != null
                ? context.l10n.sharedExportedTo(output.path)
                : context.l10n.sharedExportComplete,
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
      _reportActionFailure(error);
    }
  }

  Future<void> _openFolder() async {
    final file = _outputFile;
    if (file == null) return;
    try {
      await FilePickerServices().openContainingDirectory(file);
    } catch (error) {
      _reportActionFailure(error);
    }
  }

  /// Hands the finished file to the system "Save to..." dialog.
  ///
  /// How Android reaches the Files app: its share sheet only lists apps that
  /// accept a file, never a folder to drop one into.
  Future<void> _saveCopy() async {
    final file = _outputFile;
    if (file == null) return;
    try {
      await FilePickerServices().saveCopyToDevice(file);
    } catch (error) {
      _reportActionFailure(error);
    }
  }

  void _reportActionFailure(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
