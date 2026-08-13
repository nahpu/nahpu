import 'package:material_ui/material_ui.dart';

class TemplateExistsDialog extends StatelessWidget {
  const TemplateExistsDialog({
    super.key,
    required this.templateName,
  });

  final String templateName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Template exists'),
      content: Text(
        'A template named "$templateName" already exists. Replace the saved copy?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('New name'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Replace'),
        ),
      ],
    );
  }
}
