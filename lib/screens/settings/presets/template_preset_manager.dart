import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/presets/template_preset_deletion.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';
import 'package:nahpu/screens/shared/dialogs/preset_export_dialog.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/screens/templates/components/dialogs/missing_font_dialog.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/settings/preset_transfer_service.dart';
import 'package:nahpu/services/templates/template_preset_management_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/templates/template_transfer_service.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/styles/design_tokens.dart';

enum _TemplateTileAction { edit, export, delete }

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
        _TemplateListHeader(
          onQueryChanged: (value) => setState(() => _query = value),
          actions: PresetAppBarActions(
            itemName: 'template',
            onCreate: () async {
              await widget.onOpenTemplateEditor();
              await _load();
            },
            onImport: _importTemplates,
            onExportAll: _exportAllTemplates,
            onLoadDefaults: _loadDefaults,
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
                    padding: EdgeInsets.all(NahpuSpacing.xxl),
                    child: Text(
                      'No templates match your search.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: NahpuSpacing.xl),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final summary = visible[index];
                    return _TemplateTile(
                      key: ValueKey('template-${summary.template.name}'),
                      summary: summary,
                      icon: _recordTypeIcon(summary.template.recordType),
                      isDeleting: _deletingName == summary.template.name,
                      onOpen: () => _openTemplate(summary.template.name),
                      onExport: () => _exportTemplate(summary.template),
                      onDelete: () => _delete(summary),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openTemplate(String name) async {
    await widget.onOpenTemplateEditor(name);
    await _load();
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

/// Search field with the template actions beside it, on one row at every
/// width so the list starts at the same place on phones and desktops.
class _TemplateListHeader extends StatelessWidget {
  const _TemplateListHeader({
    required this.onQueryChanged,
    required this.actions,
  });

  final ValueChanged<String> onQueryChanged;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NahpuSpacing.md,
        NahpuSpacing.md,
        NahpuSpacing.xs,
        NahpuSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search templates',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NahpuRadius.xl),
                ),
              ),
              onChanged: onQueryChanged,
            ),
          ),
          const SizedBox(width: NahpuSpacing.xs),
          actions,
        ],
      ),
    );
  }
}

/// One saved template: its record type, size, and how many layouts use it.
/// Tapping the row opens the editor; everything else is in its menu.
class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    super.key,
    required this.summary,
    required this.icon,
    required this.isDeleting,
    required this.onOpen,
    required this.onExport,
    required this.onDelete,
  });

  final TemplatePresetSummary summary;
  final IconData icon;
  final bool isDeleting;
  final VoidCallback onOpen;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final template = summary.template;
    final description = template.description.trim();
    final layoutCount = summary.usages.length;
    // The icon shows the record type, so the detail line keeps to size and
    // usage and stays on one line.
    final details = [
      '${template.widthMm.toStringAsFixed(0)}×'
          '${template.heightMm.toStringAsFixed(0)} mm',
      layoutCount == 0
          ? 'Unused'
          : '$layoutCount layout${layoutCount == 1 ? '' : 's'}',
    ].join(' · ');
    return OutlinedListTile(
      leading: Tooltip(
        message: _recordTypeLabel(template.recordType),
        child: Icon(icon),
      ),
      title: Text(template.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty)
            Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(details, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: isDeleting
          ? const SizedBox.square(
              dimension: NahpuControlSize.icon,
              child: CircularProgressIndicator(
                strokeWidth: NahpuStroke.regular,
              ),
            )
          : AdaptiveMenuButton<_TemplateTileAction>(
              tooltip: 'Template options',
              onSelected: (action) {
                switch (action) {
                  case _TemplateTileAction.edit:
                    onOpen();
                  case _TemplateTileAction.export:
                    onExport();
                  case _TemplateTileAction.delete:
                    onDelete();
                }
              },
              itemBuilder: () => const [
                AdaptiveMenuItem(
                  value: _TemplateTileAction.edit,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                ),
                AdaptiveMenuItem(
                  value: _TemplateTileAction.export,
                  icon: Icons.file_upload_outlined,
                  label: 'Export',
                ),
                AdaptiveMenuItem(
                  value: _TemplateTileAction.delete,
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  isDestructive: true,
                  hasDividerBefore: true,
                ),
              ],
            ),
      onTap: isDeleting ? null : onOpen,
    );
  }
}

String _recordTypeLabel(RecordType recordType) {
  return switch (recordType) {
    RecordType.specimenRecord => 'Specimen',
    RecordType.site => 'Site',
    RecordType.collEvent => 'Collecting event',
    RecordType.narrative => 'Narrative',
    RecordType.specimenParts => 'Specimen parts',
    RecordType.none => 'No records',
  };
}
