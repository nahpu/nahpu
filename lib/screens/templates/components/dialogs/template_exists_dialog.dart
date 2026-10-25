import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';

class TemplateExistsDialog extends StatelessWidget {
  const TemplateExistsDialog({super.key, required this.templateName});

  final String templateName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.templateExistsTitle),
      content: Text(context.l10n.templateExistsBody(templateName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.templateNewName),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.databaseReplace),
        ),
      ],
    );
  }
}
