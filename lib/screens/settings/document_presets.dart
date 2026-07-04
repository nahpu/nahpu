import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/components/document_settings_pane.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/services/document_layout_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class DocumentPresetsScreen extends StatefulWidget {
  const DocumentPresetsScreen({super.key});

  @override
  State<DocumentPresetsScreen> createState() => _DocumentPresetsScreenState();
}

class _DocumentPresetsScreenState extends State<DocumentPresetsScreen> {
  final DocumentLayoutService _layoutService = const DocumentLayoutService();

  bool _loading = true;
  String? _error;
  rust_config.DocumentLayoutPreset? _layout;
  List<rust_config.DocumentLayoutStatus> _layoutStatuses = const [];
  List<String> _layoutNames = const [];
  List<String> _templateNames = const [];
  String _selectedLayoutName = 'Default';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document presets'),
        actions: [
          IconButton(
            tooltip: 'Add preset',
            onPressed: _loading ? null : _addPreset,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: _layout == null
                            ? _IncompatibleDocumentPreset(
                                statuses: _layoutStatuses,
                                selectedName: _selectedLayoutName,
                                onPresetSelected: _selectLayout,
                                onDeletePreset: _deletePreset,
                              )
                            : DocumentLayoutSection(
                                layout: _layout!,
                                setupNames: _layoutNames,
                                selectedSetupName: _selectedLayoutName,
                                templateNames: _templateNames,
                                onLayoutChanged: _layoutChanged,
                                onSetupSelected: _selectLayout,
                                onSaveSetupAs: _savePresetAs,
                                onDeleteSetup: _deletePreset,
                                onExportSetup: () {},
                                onImportSetup: () {},
                                onCreateTemplate: _openTemplateEditor,
                                showFileActions: false,
                                incompatibleSetupNames: _incompatibleNames,
                              ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Set<String> get _incompatibleNames => _layoutStatuses
      .where((status) => !status.isCompatible)
      .map((status) => status.name)
      .toSet();

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var statuses = await _layoutService.listLayoutStatuses();
      if (statuses.isEmpty) {
        final defaultLayout = await _layoutService.getDefaultLayout('Default');
        await _layoutService.saveLayout(defaultLayout);
        statuses = await _layoutService.listLayoutStatuses();
      }
      final names = statuses.map((status) => status.name).toList();
      final current = await _layoutService.getStoredCurrentLayoutName();
      final String selectedName =
          current != null && names.contains(current) ? current : names.first;
      final selectedStatus =
          statuses.firstWhere((status) => status.name == selectedName);
      final layout = selectedStatus.isCompatible
          ? await _layoutService.getLayout(selectedName)
          : null;
      final templates = await rust_config.listTemplatePresets();

      if (!mounted) return;
      setState(() {
        _layoutStatuses = statuses;
        _layoutNames = names;
        _selectedLayoutName = selectedName;
        _layout = layout;
        _templateNames = templates;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _layoutChanged(rust_config.DocumentLayoutPreset layout) async {
    setState(() {
      _layout = layout;
    });
    await _layoutService.saveLayout(layout);
  }

  Future<void> _selectLayout(String name) async {
    final status = _layoutStatuses.firstWhere((status) => status.name == name);
    final layout =
        status.isCompatible ? await _layoutService.getLayout(name) : null;
    if (status.isCompatible) {
      await _layoutService.setCurrentLayoutName(name);
    }
    setState(() {
      _selectedLayoutName = name;
      _layout = layout;
    });
  }

  Future<void> _addPreset() async {
    final name = await _promptPresetName(title: 'New document preset');
    if (name == null) return;

    final templateName =
        _templateNames.isNotEmpty ? _templateNames.first : 'Default';
    final layout = await _layoutService.getDefaultLayout(name);
    final blocks = layout.blocks.isEmpty
        ? [
            rust_config.DocumentLayoutBlock(
              templateName: templateName,
              templateCount: 1,
              rows: 8,
              cols: 4,
              templatePadTopMm: 1.0,
              templatePadLeftMm: 1.0,
              templatePadRightMm: 1.0,
              templatePadBottomMm: 1.0,
              pageBreakAfter: false,
            ),
          ]
        : layout.blocks;
    final nextLayout = layout.copyWith(name: name, blocks: blocks);

    await _layoutService.saveLayout(nextLayout);
    await _layoutService.setCurrentLayoutName(name);
    await _load();
  }

  Future<void> _savePresetAs() async {
    final layout = _layout;
    if (layout == null) return;

    final name = await _promptPresetName(
      title: 'Save document preset',
      initialValue: _selectedLayoutName,
    );
    if (name == null) return;

    final nextLayout = layout.copyWith(name: name);
    await _layoutService.saveLayout(nextLayout);
    await _layoutService.setCurrentLayoutName(name);
    await _load();
  }

  Future<void> _deletePreset() async {
    rust_config.DocumentLayoutStatus? selectedStatus;
    for (final status in _layoutStatuses) {
      if (status.name == _selectedLayoutName) {
        selectedStatus = status;
        break;
      }
    }
    if (_selectedLayoutName == 'Default' &&
        (selectedStatus?.isCompatible ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete Default preset')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document preset'),
        content: Text('Delete "$_selectedLayoutName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await _layoutService.deleteLayout(_selectedLayoutName);
    await _load();
  }

  Future<void> _openTemplateEditor() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const TemplateEditorScreen(),
      ),
    );
    await _load();
  }

  Future<String?> _promptPresetName({
    required String title,
    String? initialValue,
  }) async {
    final existingNames = (await _layoutService.listLayoutStatuses())
        .map((status) => status.name)
        .toList();
    if (!mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (context) => _DocumentPresetNameDialog(
        title: title,
        initialValue: initialValue,
        existingNames: existingNames,
      ),
    );
  }
}

class _IncompatibleDocumentPreset extends StatelessWidget {
  const _IncompatibleDocumentPreset({
    required this.statuses,
    required this.selectedName,
    required this.onPresetSelected,
    required this.onDeletePreset,
  });

  final List<rust_config.DocumentLayoutStatus> statuses;
  final String selectedName;
  final ValueChanged<String> onPresetSelected;
  final VoidCallback onDeletePreset;

  @override
  Widget build(BuildContext context) {
    final incompatibleNames = statuses
        .where((status) => !status.isCompatible)
        .map((status) => status.name)
        .toSet();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Layout',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedName,
                  decoration: const InputDecoration(
                    labelText: 'Layout profile',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: statuses
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status.name,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (incompatibleNames.contains(status.name)) ...[
                                Icon(
                                  Icons.warning_amber_outlined,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(child: Text(status.name)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onPresetSelected(value);
                  },
                ),
              ),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save As'),
              ),
              OutlinedButton.icon(
                onPressed: onDeletePreset,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Incompatible preset',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocumentPresetNameDialog extends StatefulWidget {
  const _DocumentPresetNameDialog({
    required this.title,
    required this.existingNames,
    this.initialValue,
  });

  final String title;
  final String? initialValue;
  final List<String> existingNames;

  @override
  State<_DocumentPresetNameDialog> createState() =>
      _DocumentPresetNameDialogState();
}

class _DocumentPresetNameDialogState extends State<_DocumentPresetNameDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Preset name',
          errorText: _errorText,
        ),
        onChanged: _validate,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    _validate(name);
    if (_errorText != null) return;
    Navigator.pop(context, name);
  }

  void _validate(String value) {
    final name = value.trim();
    String? error;
    if (name.isEmpty) {
      error = 'Name cannot be empty';
    } else if (widget.existingNames.contains(name) &&
        name != widget.initialValue) {
      error = 'A preset with this name already exists';
    }
    setState(() {
      _errorText = error;
    });
  }
}
