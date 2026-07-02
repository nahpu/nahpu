import 'package:flutter/material.dart';
import 'package:nahpu/screens/templates/template_border_sheet.dart';
import 'package:nahpu/screens/templates/template_model.dart';

class TemplateBorderPanel extends StatelessWidget {
  const TemplateBorderPanel({
    super.key,
    required this.session,
    required this.outline,
    required this.onOutlineChanged,
  });

  final int session;
  final TemplateOutline? outline;
  final ValueChanged<TemplateOutline?> onOutlineChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 3,
      surfaceTintColor: scheme.surfaceTint,
      color: scheme.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, color: scheme.outlineVariant),
          TemplateBorderEditorSheet(
            key: ValueKey<int>(session),
            initialOutline: outline,
            embeddedPanel: true,
            maxHeightFraction: 0.36,
            onOutlineChanged: onOutlineChanged,
          ),
        ],
      ),
    );
  }
}
