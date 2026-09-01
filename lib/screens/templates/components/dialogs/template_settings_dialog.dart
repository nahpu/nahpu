import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/types/export.dart';

class TemplateSettingsResult {
  const TemplateSettingsResult({
    required this.name,
    required this.description,
    required this.isDuplex,
  });

  final String name;
  final String description;
  final bool isDuplex;
}

class TemplateSettingsDialog extends StatelessWidget {
  const TemplateSettingsDialog({
    super.key,
    required this.template,
    required this.isDuplex,
    this.takenNames = const {},
  });

  final Template template;
  final bool isDuplex;

  /// Names of the other saved templates, used to reject a duplicate rename.
  final Set<String> takenNames;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Template settings'),
      content: SizedBox(
        width: 440,
        child: TemplateSettingsForm(
          template: template,
          isDuplex: isDuplex,
          takenNames: takenNames,
          onCancel: () => Navigator.pop(context),
          onApply: (result) => Navigator.pop(context, result),
        ),
      ),
    );
  }
}

class TemplateSettingsBottomSheet extends StatelessWidget {
  const TemplateSettingsBottomSheet({
    super.key,
    required this.template,
    required this.isDuplex,
    this.takenNames = const {},
  });

  final Template template;
  final bool isDuplex;

  /// Names of the other saved templates, used to reject a duplicate rename.
  final Set<String> takenNames;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: TemplateSettingsForm(
              template: template,
              isDuplex: isDuplex,
              takenNames: takenNames,
              showTitle: true,
              onCancel: () => Navigator.pop(context),
              onApply: (result) => Navigator.pop(context, result),
            ),
          ),
        ),
      ),
    );
  }
}

class TemplateSettingsForm extends StatefulWidget {
  const TemplateSettingsForm({
    super.key,
    required this.template,
    required this.isDuplex,
    required this.onCancel,
    required this.onApply,
    this.takenNames = const {},
    this.showTitle = false,
  });

  final Template template;
  final bool isDuplex;
  final VoidCallback onCancel;
  final ValueChanged<TemplateSettingsResult> onApply;

  /// Names of the other saved templates, used to reject a duplicate rename.
  final Set<String> takenNames;
  final bool showTitle;

  @override
  State<TemplateSettingsForm> createState() => _TemplateSettingsFormState();
}

class _TemplateSettingsFormState extends State<TemplateSettingsForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late bool _isDuplex;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template.name);
    _descriptionController = TextEditingController(
      text: widget.template.description,
    );
    _isDuplex = widget.isDuplex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Returns the error for [value], or null when it is a usable name.
  String? _validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Enter a name';
    if (trimmed != widget.template.name &&
        widget.takenNames.contains(trimmed)) {
      return 'A template with this name already exists';
    }
    return null;
  }

  void _apply() {
    final error = _validateName(_nameController.text);
    if (error != null) {
      setState(() => _nameError = error);
      return;
    }
    widget.onApply(
      TemplateSettingsResult(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isDuplex: _isDuplex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showTitle) ...[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Template settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Template name',
            border: const OutlineInputBorder(),
            errorText: _nameError,
          ),
          onChanged: (value) {
            final error = _validateName(value);
            if (error != _nameError) setState(() => _nameError = error);
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Record type: ${_recordTypeLabel(widget.template.recordType)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Text('Sides', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _SideChoiceCard(
          title: '1 sided',
          description: 'Create a template with a Front side only.',
          selected: !_isDuplex,
          onTap: () => setState(() => _isDuplex = false),
        ),
        const SizedBox(height: 8),
        _SideChoiceCard(
          title: '2 sided',
          description: 'Create separate Front and Back designs.',
          selected: _isDuplex,
          onTap: () => setState(() => _isDuplex = true),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _nameError == null ? _apply : null,
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SideChoiceCard extends StatelessWidget {
  const _SideChoiceCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 4 : 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _recordTypeLabel(RecordType recordType) {
  switch (recordType) {
    case RecordType.specimenRecord:
      return 'Specimen';
    case RecordType.site:
      return 'Site';
    case RecordType.collEvent:
      return 'Collecting Event';
    case RecordType.narrative:
      return 'Narrative';
    case RecordType.specimenParts:
      return 'Specimen Parts';
    case RecordType.none:
      return 'None';
  }
}
