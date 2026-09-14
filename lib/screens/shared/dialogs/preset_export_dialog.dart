import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/settings/preset_transfer_service.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Builds the file contents, leaving linked templates out when asked.
typedef PresetExportEncoder =
    Future<String> Function({required bool includeLinkedTemplates});

/// What a preset export writes and how the dialog describes it.
class PresetExportRequest {
  const PresetExportRequest({
    required this.title,
    required this.summary,
    required this.defaultFileStem,
    required this.encode,
    this.linkedTemplateNames = const [],
    this.imageNote,
  });

  final String title;
  final String summary;
  final String defaultFileStem;
  final PresetExportEncoder encode;

  /// Templates the exported layouts print with. The dialog offers to leave
  /// them out only when there are some.
  final List<String> linkedTemplateNames;

  /// Shown while templates that use images are part of the export.
  final String? imageNote;
}

enum _PresetFileFormat { json }

Future<void> showPresetExportDialog({
  required BuildContext context,
  required PresetExportRequest request,
  PresetTransferService service = const PresetTransferService(),
}) async {
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      // useSafeArea skips the bottom inset, so keep Export and Share above the
      // system navigation bar here.
      builder: (context) => SafeArea(
        top: false,
        child: PresetExportDialog(
          request: request,
          service: service,
          showCloseButton: false,
        ),
      ),
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: NahpuContentWidth.form,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: PresetExportDialog(request: request, service: service),
      ),
    ),
  );
}

/// File settings for a preset export, then Share once the file is written.
class PresetExportDialog extends StatefulWidget {
  const PresetExportDialog({
    super.key,
    required this.request,
    this.service = const PresetTransferService(),
    this.showCloseButton = true,
  });

  final PresetExportRequest request;
  final PresetTransferService service;

  /// The bottom sheet is dismissed with its drag handle instead.
  final bool showCloseButton;

  @override
  State<PresetExportDialog> createState() => _PresetExportDialogState();
}

class _PresetExportDialogState extends State<PresetExportDialog> {
  late final FileOpCtrModel _exportCtr;
  Directory? _selectedDir;
  File? _output;
  bool _appendDate = false;
  bool _includeLinkedTemplates = true;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _exportCtr = FileOpCtrModel.empty();
    _exportCtr.fileNameCtr.text = widget.request.defaultFileStem;
  }

  @override
  void dispose() {
    _exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final theme = Theme.of(context);
    final linkedNames = request.linkedTemplateNames;
    final imageNote = request.imageNote;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        NahpuSpacing.xl,
        NahpuSpacing.md,
        NahpuSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + NahpuSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (widget.showCloseButton)
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: _isRunning
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Text(request.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: NahpuSpacing.lg),
          GenericFileSettingsCard<_PresetFileFormat>(
            exportCtr: _exportCtr,
            selectedDir: _selectedDir,
            format: _PresetFileFormat.json,
            formats: const [_PresetFileFormat.json],
            formatLabel: (_) => 'JSON (.json)',
            extensionForFormat: (_) => 'json',
            onFormatChanged: (_) {},
            onFileNameChanged: (_) => _resetOutput(),
            appendDate: _appendDate,
            onAppendDateChanged: (value) => setState(() {
              _appendDate = value;
              _output = null;
            }),
            onSelectDir: _selectDirectory,
            onClearDir: () => setState(() {
              _selectedDir = null;
              _output = null;
            }),
            enabled: !_isRunning,
          ),
          if (linkedNames.isNotEmpty) ...[
            const SizedBox(height: NahpuSpacing.lg),
            NahpuPanel(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Include linked templates'),
                subtitle: Text(
                  '${linkedNames.length} template'
                  '${linkedNames.length == 1 ? '' : 's'}: '
                  '${linkedNames.join(', ')}',
                ),
                value: _includeLinkedTemplates,
                onChanged: _isRunning
                    ? null
                    : (value) => setState(() {
                        _includeLinkedTemplates = value;
                        _output = null;
                      }),
              ),
            ),
          ],
          if (imageNote != null &&
              (linkedNames.isEmpty || _includeLinkedTemplates)) ...[
            const SizedBox(height: NahpuSpacing.lg),
            Text(
              imageNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: NahpuSpacing.xl),
          ExportShareButton(
            hasExported: _output != null,
            isRunning: _isRunning,
            onExport: _exportCtr.isValid ? _export : null,
            onShare: _share,
          ),
        ],
      ),
    );
  }

  void _resetOutput() {
    if (mounted) setState(() => _output = null);
  }

  Future<void> _selectDirectory() async {
    final directory = await FilePickerServices().selectDir();
    if (directory != null && mounted) {
      setState(() {
        _selectedDir = directory;
        _output = null;
      });
    }
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isRunning = true);
    try {
      final content = await widget.request.encode(
        includeLinkedTemplates: _includeLinkedTemplates,
      );
      final output = await widget.service.save(
        content: content,
        fileStem: _appendDate
            ? appendDateToFileStem(_exportCtr.fileNameCtr.text, DateTime.now())
            : _exportCtr.fileNameCtr.text,
        directory: _selectedDir,
      );
      if (!mounted) return;
      setState(() => _output = output);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            systemPlatform == PlatformType.desktop
                ? 'Exported to ${output.path}'
                : 'Export complete!',
          ),
        ),
      );
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $error')));
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().shareFile(context, output);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
