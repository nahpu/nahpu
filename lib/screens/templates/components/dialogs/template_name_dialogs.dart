import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';

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
      title: Text(context.l10n.templateSave),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: context.l10n.templateName,
            border: OutlineInputBorder(),
            isDense: true,
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.templateEnterName;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: Text(context.l10n.commonSave),
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
      title: Text(context.l10n.templateSaveImportedAs),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: context.l10n.templateName,
            hintText: context.l10n.templateMustDiffer(widget.conflictingName),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            final name = value?.trim() ?? '';
            if (name.isEmpty) return context.l10n.templateEnterName;
            if (widget.takenNames.contains(name)) {
              return context.l10n.templateNameExists;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: Text(context.l10n.commonSave),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text.trim());
  }
}
