import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/presets/template_preset_deletion.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/screens/templates/components/dialogs/missing_font_dialog.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/templates/template_preset_management_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/templates/template_transfer_service.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:path/path.dart' as path;

/// QR payload key for a single template, matching the layout and tabular
/// preset keys used by the other transfer screens.
const String kTemplateQrKey = 'nahpu_template_preset';

/// Largest payload a QR code can carry in practice. A template past this size
/// has to travel as a file.
const int _kMaxQrPayloadBytes = 2500;

enum _TemplateTileAction { export, showQr, delete }

class TemplatePresetManager extends ConsumerStatefulWidget {
  const TemplatePresetManager({
    super.key,
    required this.onOpenTemplateEditor,
    required this.onRestoreBundledTemplates,
  });

  final Future<void> Function([String? templateName]) onOpenTemplateEditor;
  final Future<void> Function() onRestoreBundledTemplates;

  @override
  ConsumerState<TemplatePresetManager> createState() =>
      _TemplatePresetManagerState();
}

class _TemplatePresetManagerState extends ConsumerState<TemplatePresetManager> {
  final TemplatePresetManagementService _service =
      const TemplatePresetManagementService();
  final TemplateTransferService _transfer = const TemplateTransferService();
  final TemplateService _templateService = const TemplateService();
  List<TemplatePresetSummary> _summaries = const [];
  bool _loading = true;
  String? _error;
  String _query = '';
  String? _deletingName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _summaries.where((summary) {
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          summary.template.name.toLowerCase().contains(query) ||
          summary.template.description.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth < 600
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _searchField(),
                      const SizedBox(height: 8),
                      _actionButtons(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _searchField()),
                      const SizedBox(width: 12),
                      _actionButtons(),
                    ],
                  ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : visible.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No templates found. Templates define the content placed in '
                      'print-layout blocks.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildTemplateTile(visible[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildTemplateTile(TemplatePresetSummary summary) {
    final template = summary.template;
    final usageLabel = summary.usages.isEmpty
        ? 'Unused'
        : 'Used by ${summary.usages.length} layout${summary.usages.length == 1 ? '' : 's'} '
              '· ${summary.blockCount} block${summary.blockCount == 1 ? '' : 's'}';
    final deleting = _deletingName == template.name;

    return Card(
      child: ListTile(
        onTap: deleting
            ? null
            : () async {
                await widget.onOpenTemplateEditor(template.name);
                await _load();
              },
        leading: Icon(_recordTypeIcon(template.recordType)),
        title: Text(template.name),
        subtitle: Text(
          [
            if (template.description.trim().isNotEmpty) template.description,
            '${recordTypeToString(template.recordType)} · '
                '${template.widthMm.toStringAsFixed(0)} × '
                '${template.heightMm.toStringAsFixed(0)} mm',
            usageLabel,
          ].join('\n'),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: deleting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit template',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      await widget.onOpenTemplateEditor(template.name);
                      await _load();
                    },
                  ),
                  PopupMenuButton<_TemplateTileAction>(
                    tooltip: 'Template options',
                    onSelected: (action) {
                      switch (action) {
                        case _TemplateTileAction.export:
                          _exportTemplate(template);
                        case _TemplateTileAction.showQr:
                          _showTemplateQr(template);
                        case _TemplateTileAction.delete:
                          _delete(summary);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _TemplateTileAction.export,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.file_upload_outlined),
                          title: Text('Export'),
                        ),
                      ),
                      PopupMenuItem(
                        value: _TemplateTileAction.showQr,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.qr_code),
                          title: Text('Show QR'),
                        ),
                      ),
                      PopupMenuDivider(height: 8),
                      PopupMenuItem(
                        value: _TemplateTileAction.delete,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.delete_outline),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        labelText: 'Search templates',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _query = value;
        });
      },
    );
  }

  Widget _actionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PresetAppBarActions(
          itemName: 'template',
          onCreate: () async {
            await widget.onOpenTemplateEditor();
            await _load();
          },
          onScanQr: _scanTemplateQr,
          onImport: _importTemplates,
          onExportAll: _exportAllTemplates,
        ),
        IconButton(
          tooltip: 'Restore bundled templates',
          icon: const Icon(Icons.restore_outlined),
          onPressed: () async {
            await widget.onRestoreBundledTemplates();
            await _load();
          },
        ),
      ],
    );
  }

  Future<void> _exportAllTemplates() async {
    final templates = _summaries
        .map((summary) => summary.template)
        .toList(growable: false);
    await _exportTemplates(templates, TemplateTransferService.bulkFileName);
  }

  Future<void> _exportTemplate(Template template) async {
    await _exportTemplates([template], _transfer.fileNameFor(template));
  }

  /// Writes [templates] to a file the user picks a directory for.
  ///
  /// One template and all templates use the same envelope, so a file exported
  /// either way imports through [_importTemplates].
  Future<void> _exportTemplates(
    List<Template> templates,
    String fileName,
  ) async {
    if (templates.isEmpty) {
      _showMessage('No templates to export');
      return;
    }
    if (!await _confirmImageWarning(templates)) return;
    try {
      final directory = await FilePickerServices().selectDir();
      if (directory == null) return;
      final target = File(path.join(directory.path, fileName));
      await _transfer.writeFile(target, templates);
      _showMessage(
        'Exported ${templates.length} template'
        '${templates.length == 1 ? '' : 's'} to ${target.path}',
      );
    } on Object catch (error) {
      _showMessage('Failed to export templates: $error');
    }
  }

  /// Warns that logo images are referenced by path and do not travel with the
  /// template file.
  Future<bool> _confirmImageWarning(List<Template> templates) async {
    final withImages = templates
        .where(
          (template) =>
              template.page1.customImages.isNotEmpty ||
              template.page2.customImages.isNotEmpty,
        )
        .toList();
    if (withImages.isEmpty) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Images are not included'),
        content: Text(
          '${withImages.length} template'
          '${withImages.length == 1 ? '' : 's'} '
          'use images, which are referenced by name rather than stored in the '
          'file. On another installation those images have to be added again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Export anyway'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _importTemplates() async {
    final selected = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final filePath = selected?.path;
    if (filePath == null) return;

    List<Template> templates;
    try {
      templates = await _transfer.readFile(File(filePath));
    } on Object catch (error) {
      _showMessage('Invalid template file: $error');
      return;
    }
    await _saveImportedTemplates(templates);
  }

  /// Resolves fonts once for the batch, then stores each template under a
  /// name that does not collide with an existing one.
  Future<void> _saveImportedTemplates(List<Template> templates) async {
    if (templates.isEmpty) return;
    final offered = templates.length;
    if (!mounted) return;
    final resolved = await resolveMissingTemplateFonts(context, ref, templates);
    if (resolved == null || !mounted) return;

    final taken = (await _templateService.listTemplateNames()).toSet();
    var imported = 0;
    try {
      for (final template in resolved) {
        if (taken.length >= TemplateTransferService.importLimit) break;
        final name = _transfer.uniqueName(template.name, taken);
        taken.add(name);
        await _templateService.saveTemplate(template.copyWith(name: name));
        imported++;
      }
    } on Object catch (error) {
      _showMessage('Failed to import templates: $error');
      return;
    }
    await _load();
    _showMessage(
      imported == offered
          ? 'Imported $imported template${imported == 1 ? '' : 's'}'
          : 'Imported $imported of $offered templates '
                '(limit ${TemplateTransferService.importLimit})',
    );
  }

  void _scanTemplateQr() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          onDetect: (barcode) {
            final rawValue = barcode.barcodes.first.rawValue;
            if (rawValue != null) _importTemplateFromQr(rawValue);
          },
        ),
      ),
    );
  }

  Future<void> _importTemplateFromQr(String rawValue) async {
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map ||
          !decoded.containsKey(kTemplateQrKey) ||
          !decoded.containsKey('data')) {
        throw const FormatException('Invalid QR code format for a template.');
      }
      final body = Map<String, dynamic>.from(decoded['data'] as Map);
      final template = Template.fromJson(body);
      await _saveImportedTemplates([
        template.name.trim().isEmpty
            ? template.copyWith(name: decoded[kTemplateQrKey] as String)
            : template,
      ]);
    } on Object {
      _showMessage('Invalid or unrecognized QR code.');
    }
  }

  Future<void> _showTemplateQr(Template template) async {
    final payload = jsonEncode({
      kTemplateQrKey: template.name,
      'data': template.toJson(),
    });
    if (!mounted) return;
    if (payload.length > _kMaxQrPayloadBytes) {
      _showMessage(
        'This template is too large for a QR code. Export it as a file '
        'instead.',
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: SizedBox(
          width: 300,
          height: 300,
          child: QrImageView(data: payload, backgroundColor: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summaries = await _service.loadSummaries();
      if (!mounted) return;
      setState(() {
        _summaries = summaries;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load templates: $error';
        _loading = false;
      });
    }
  }

  Future<void> _delete(TemplatePresetSummary summary) async {
    try {
      final usages = await _service.getUsages(summary.template.name);
      if (!mounted) return;
      final request = await showTemplatePresetDeletionDialog(
        context: context,
        target: summary.template,
        usages: usages,
        candidates: _summaries,
      );
      if (request == null || !mounted) return;

      setState(() {
        _deletingName = summary.template.name;
      });
      final result = await _service.deleteTemplate(
        name: request.name,
        replacementName: request.replacementName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.updatedBlockCount == 0
                ? 'Deleted "${summary.template.name}"'
                : 'Deleted "${summary.template.name}" and updated '
                      '${result.updatedBlockCount} block${result.updatedBlockCount == 1 ? '' : 's'}',
          ),
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete template: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingName = null;
        });
      }
    }
  }

  IconData _recordTypeIcon(RecordType recordType) {
    switch (recordType) {
      case RecordType.narrative:
        return Icons.menu_book_outlined;
      case RecordType.site:
        return Icons.place_outlined;
      case RecordType.collEvent:
        return Icons.event_outlined;
      case RecordType.specimenParts:
        return Icons.science_outlined;
      case RecordType.none:
        return Icons.folder_outlined;
      case RecordType.specimenRecord:
        return Icons.sell_outlined;
    }
  }
}
