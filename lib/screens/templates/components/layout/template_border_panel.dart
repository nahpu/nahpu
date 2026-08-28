import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/properties/template_border_sheet.dart';
import 'package:nahpu/screens/templates/template_model.dart';

class TemplateBorderPanel extends StatelessWidget {
  const TemplateBorderPanel({
    super.key,
    required this.session,
    required this.outline,
    required this.onOutlineChanged,
    required this.onDismiss,
  });

  final int session;
  final TemplateOutline? outline;
  final ValueChanged<TemplateOutline?> onOutlineChanged;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return TemplateBorderEditorSheet(
      key: ValueKey<int>(session),
      initialOutline: outline,
      inToolbar: true,
      onOutlineChanged: onOutlineChanged,
      onDismiss: onDismiss,
    );
  }
}
