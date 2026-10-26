import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// One entry of an [AdaptiveMenuButton].
@immutable
class AdaptiveMenuItem<T> {
  const AdaptiveMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.isDestructive = false,
    this.hasDividerBefore = false,
    this.checked,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;

  /// Paints the icon and label with the error color.
  final bool isDestructive;

  /// Starts a new group. Ignored for the first item.
  final bool hasDividerBefore;

  /// Marks a choice item when not null, such as the current sort order.
  final bool? checked;
}

/// An action menu that shows a popup on wide screens and a bottom sheet on
/// compact screens, where a popup is small and hard to tap.
class AdaptiveMenuButton<T> extends StatelessWidget {
  const AdaptiveMenuButton({
    super.key,
    required this.itemBuilder,
    required this.onSelected,
    this.tooltip,
    this.icon,
    this.initialValue,
  });

  /// Builds the entries each time the menu opens, so they reflect the
  /// current state.
  final ValueGetter<List<AdaptiveMenuItem<T>>> itemBuilder;

  /// Runs after the menu closes with the chosen value.
  final ValueChanged<T> onSelected;
  final String? tooltip;
  final Widget? icon;
  final T? initialValue;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon ?? Icon(Icons.adaptive.more);
    if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
      return IconButton(
        tooltip: tooltip,
        icon: icon,
        onPressed: () => _showSheet(context),
      );
    }
    return PopupMenuButton<T>(
      tooltip: tooltip,
      icon: icon,
      initialValue: initialValue,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final (index, item) in itemBuilder().indexed) ...[
          if (index > 0 && item.hasDividerBefore) const PopupMenuDivider(),
          if (item.checked != null)
            CheckedPopupMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              checked: item.checked!,
              child: Text(item.label),
            )
          else
            PopupMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: _AdaptiveMenuTile<T>(item: item),
            ),
        ],
      ],
    );
  }

  Future<void> _showSheet(BuildContext context) async {
    final value = await showAdaptiveMenuSheet<T>(
      context: context,
      items: itemBuilder(),
    );
    if (value != null && context.mounted) onSelected(value);
  }
}

/// Opens [items] as a popup below the widget at [context] on wide screens
/// and as a bottom sheet on compact screens. Closes with the chosen value.
Future<T?> showAdaptiveMenu<T>({
  required BuildContext context,
  required List<AdaptiveMenuItem<T>> items,
}) {
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    return showAdaptiveMenuSheet<T>(context: context, items: items);
  }
  final anchor = context.findRenderObject()! as RenderBox;
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  final topLeft = anchor.localToGlobal(
    anchor.size.bottomLeft(Offset.zero),
    ancestor: overlay,
  );
  final bottomRight = anchor.localToGlobal(
    anchor.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(topLeft, bottomRight),
      Offset.zero & overlay.size,
    ),
    items: [
      for (final (index, item) in items.indexed) ...[
        if (index > 0 && item.hasDividerBefore) const PopupMenuDivider(),
        PopupMenuItem<T>(
          value: item.value,
          enabled: item.enabled,
          child: _AdaptiveMenuTile<T>(item: item),
        ),
      ],
    ],
  );
}

/// Opens [items] as a bottom sheet. Closes with the chosen value.
Future<T?> showAdaptiveMenuSheet<T>({
  required BuildContext context,
  required List<AdaptiveMenuItem<T>> items,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, item) in items.indexed) ...[
              if (index > 0 && item.hasDividerBefore) const Divider(),
              _AdaptiveMenuTile<T>(
                item: item,
                onTap: item.enabled
                    ? () => Navigator.of(sheetContext).pop(item.value)
                    : null,
              ),
            ],
            const SizedBox(height: NahpuSpacing.md),
          ],
        ),
      ),
    ),
  );
}

class _AdaptiveMenuTile<T> extends StatelessWidget {
  const _AdaptiveMenuTile({required this.item, this.onTap});

  final AdaptiveMenuItem<T> item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive && item.enabled
        ? Theme.of(context).colorScheme.error
        : null;
    final checked = item.checked ?? false;
    return ListTile(
      enabled: item.enabled,
      selected: checked,
      onTap: onTap,
      leading: item.icon == null ? null : Icon(item.icon, color: color),
      title: Text(item.label, style: TextStyle(color: color)),
      trailing: checked ? const Icon(Icons.check) : null,
    );
  }
}
