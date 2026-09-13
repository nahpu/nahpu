import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/presets/template_preset_deletion.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';
import 'package:nahpu/screens/shared/dialogs/preset_export_dialog.dart';
import 'package:nahpu/screens/templates/components/dialogs/missing_font_dialog.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/settings/preset_transfer_service.dart';
import 'package:nahpu/services/templates/template_preset_management_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/templates/template_transfer_service.dart';
import 'package:nahpu/services/types/export.dart';

enum _TemplateTileAction { export, delete }

class TemplatePresetManager extends ConsumerStatefulWidget {
  const TemplatePresetManager({
    super.key,
    required this.onOpenTemplateEditor,
    required this.onLoadDefaults,
  });

  final Future<void> Function([String? templateName]) onOpenTemplateEditor;

  /// Adds the bundled generic templates.
  final Future<void> Function() onLoadDefaults;

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
              : _summaries.isEmpty
              ? PresetEmptyState(
                  message:
                      'No templates yet. Templates define the content placed '
                      'in print-layout blocks.',
                  onLoadDefaults: _loadDefaults,
                )
              : visible.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No templates match your search.',
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
                  AdaptiveMenuButton<_TemplateTileAction>(
                    tooltip: 'Template options',
                    onSelected: (action) {
                      switch (action) {
                        case _TemplateTileAction.export:
                          _exportTemplate(template);
                        case _TemplateTileAction.delete:
                          _delete(summary);
                      }
                    },
                    itemBuilder: () => const [
                      AdaptiveMenuItem(
                        value: _TemplateTileAction.export,
                        icon: Icons.file_upload_outlined,
                        label: 'Export',
                      ),
                      AdaptiveMenuItem(
                        value: _TemplateTileAction.delete,
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        hasDividerBefore: true,
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
          onImport: _importTemplates,
          onExportAll: _exportAllTemplates,
          onLoadDefaults: _loadDefaults,
        ),
      ],
    );
  }

  Future<void> _loadDefaults() async {
    await widget.onLoadDefaults();
    await _load();
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

  /// Opens the export dialog for [templates], suggesting [fileName].
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
    await showPresetExportDialog(
      context: context,
      request: PresetExportRequest(
        title: 'Export templates',
        summary: templates.length == 1
            ? templates.single.name
            : '${templates.length} templates',
        defaultFileStem: PresetTransferService.safeFileStem(fileName),
        imageNote: PresetTransferService.imageNote(templates),
        encode: ({required includeLinkedTemplates}) async =>
            _transfer.encode(templates),
      ),
    );
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
