import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/components/properties/property_panel_shell.dart';

class ImagePropertiesPanel extends StatelessWidget {
  const ImagePropertiesPanel({
    super.key,
    required this.page1,
    required this.id,
    required this.zIndexControls,
    required this.onDelete,
    required this.inToolbar,
    this.onDismiss,
  });

  final bool page1;
  final String id;
  final Widget zIndexControls;
  final void Function(bool page1, String id) onDelete;
  final bool inToolbar;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TemplatePropertyPanelShell(
      inToolbar: inToolbar,
      onDismiss: onDismiss,
      child: Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            zIndexControls,
            const Spacer(),
            IconButton(
              icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
              tooltip: 'Delete image',
              onPressed: () => onDelete(page1, id),
            ),
          ],
        ),
      ),
    );
  }
}
