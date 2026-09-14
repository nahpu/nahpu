import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/template_element_list_service.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Lists the elements on one template side, front-most first.
///
/// Returns the selection key of the tapped element, or null when the sheet is
/// dismissed.
Future<String?> showTemplateElementsSheet({
  required BuildContext context,
  required TemplatePage page,
  required bool page1,
  String? sideLabel,
  String? selectedElement,
}) {
  final entries = const TemplateElementListService().entries(
    page,
    page1: page1,
  );
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    // useSafeArea only covers the top; keep the list above the navigation bar.
    builder: (context) => SafeArea(
      top: false,
      child: TemplateElementsSheet(
        entries: entries,
        sideLabel: sideLabel,
        selectedElement: selectedElement,
      ),
    ),
  );
}

class TemplateElementsSheet extends StatelessWidget {
  const TemplateElementsSheet({
    super.key,
    required this.entries,
    this.sideLabel,
    this.selectedElement,
  });

  final List<TemplateElementEntry> entries;

  /// Front or Back on a duplex template; null for a single side.
  final String? sideLabel;
  final String? selectedElement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NahpuSpacing.xl,
              0,
              NahpuSpacing.xl,
              NahpuSpacing.md,
            ),
            child: Text(
              sideLabel == null ? 'Elements' : 'Elements · $sideLabel',
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(NahpuSpacing.xl),
              child: Text(
                'No elements on this side yet. Add one from the Add tools.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: NahpuSpacing.xl),
                itemCount: entries.length,
                itemBuilder: (context, index) => _ElementTile(
                  entry: entries[index],
                  isSelected: entries[index].selection == selectedElement,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ElementTile extends StatelessWidget {
  const _ElementTile({required this.entry, required this.isSelected});

  final TemplateElementEntry entry;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return OutlinedListTile(
      isFocused: isSelected,
      leading: Icon(switch (entry.type) {
        TemplateElementType.text => Icons.text_fields,
        TemplateElementType.image => Icons.image_outlined,
        TemplateElementType.line => Icons.horizontal_rule,
        TemplateElementType.shape => Icons.crop_square,
      }),
      title: Text(entry.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        entry.detail,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: entry.isLocked || !entry.isVisible
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!entry.isVisible)
                  Tooltip(
                    message: 'Hidden',
                    child: Icon(
                      Icons.visibility_off_outlined,
                      size: NahpuControlSize.iconMedium,
                      color: muted,
                    ),
                  ),
                if (entry.isLocked) ...[
                  if (!entry.isVisible) const SizedBox(width: NahpuSpacing.md),
                  Tooltip(
                    message: 'Locked',
                    child: Icon(
                      Icons.lock_outline,
                      size: NahpuControlSize.iconMedium,
                      color: muted,
                    ),
                  ),
                ],
              ],
            )
          : null,
      onTap: () => Navigator.of(context).pop(entry.selection),
    );
  }
}
