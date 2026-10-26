import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Asks for a new preset name, rejecting a blank name or one already in use.
///
/// Returns the trimmed name, or null when cancelled. [initialValue] only
/// prefills the field; it is validated like any typed name.
class PresetNameDialog extends StatefulWidget {
  const PresetNameDialog({
    super.key,
    required this.title,
    required this.existingNames,
    this.initialValue,
  });

  final String title;
  final String? initialValue;
  final Iterable<String> existingNames;

  @override
  State<PresetNameDialog> createState() => _PresetNameDialogState();
}

class _PresetNameDialogState extends State<PresetNameDialog> {
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.formsPresetName,
          errorText: _errorText,
        ),
        onChanged: _validate,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonSave)),
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
    final l10n = context.l10n;
    String? error;
    if (name.isEmpty) {
      error = l10n.presetsNameEmpty;
    } else if (widget.existingNames.contains(name)) {
      error = l10n.presetsNameExists;
    }
    setState(() => _errorText = error);
  }
}
