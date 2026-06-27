import 'package:flutter/material.dart';
import 'package:nahpu/screens/export/labels/components/end_sidebar_panel_icon.dart';

class FieldsPanelToggleButton extends StatelessWidget {
  const FieldsPanelToggleButton({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isExpanded) {
      return IconButton.filledTonal(
        tooltip: 'Hide available fields',
        style: IconButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
        ),
        onPressed: onToggle,
        icon: EndSidebarPanelIcon(
          size: 22,
          color: scheme.onPrimaryContainer,
        ),
      );
    }
    return IconButton(
      tooltip: 'Show available fields',
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
      ),
      onPressed: onToggle,
      icon: EndSidebarPanelIcon(
        size: 22,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
