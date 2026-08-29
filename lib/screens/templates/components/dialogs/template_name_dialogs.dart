import 'package:material_ui/material_ui.dart';

class SaveTemplateDialog extends StatefulWidget {
  const SaveTemplateDialog({super.key, required this.initialName});

  final String initialName;

  @override
  State<SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState extends State<SaveTemplateDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save template'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Template name',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter a name';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text.trim());
  }
}

class ImportTemplateNameDialog extends StatefulWidget {
  const ImportTemplateNameDialog({
    super.key,
    required this.conflictingName,
    required this.takenNames,
  });

  final String conflictingName;
  final Set<String> takenNames;

  @override
  State<ImportTemplateNameDialog> createState() =>
      _ImportTemplateNameDialogState();
}

class _ImportTemplateNameDialogState extends State<ImportTemplateNameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save imported template as'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Template name',
            hintText: 'Must differ from "${widget.conflictingName}"',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            final name = value?.trim() ?? '';
            if (name.isEmpty) return 'Enter a name';
            if (widget.takenNames.contains(name)) {
              return 'A template with this name already exists';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text.trim());
  }
}
