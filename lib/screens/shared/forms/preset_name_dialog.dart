import 'package:material_ui/material_ui.dart';

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
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
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
    } else if (widget.existingNames.contains(name)) {
      error = 'A preset with this name already exists';
    }
    setState(() => _errorText = error);
  }
}
