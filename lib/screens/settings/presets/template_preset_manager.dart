import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/presets/template_preset_deletion.dart';
import 'package:nahpu/services/templates/template_preset_management_service.dart';
import 'package:nahpu/services/types/export.dart';

class TemplatePresetManager extends StatefulWidget {
  const TemplatePresetManager({
    super.key,
    required this.onOpenTemplateEditor,
    required this.onRestoreBundledTemplates,
  });

  final Future<void> Function([String? templateName]) onOpenTemplateEditor;
  final Future<void> Function() onRestoreBundledTemplates;

  @override
  State<TemplatePresetManager> createState() => _TemplatePresetManagerState();
}

class _TemplatePresetManagerState extends State<TemplatePresetManager> {
  final TemplatePresetManagementService _service =
      const TemplatePresetManagementService();
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
                  IconButton(
                    tooltip: 'Delete template',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(summary),
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
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            await widget.onOpenTemplateEditor();
            await _load();
          },
          icon: const Icon(Icons.add),
          label: const Text('Create or import'),
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
