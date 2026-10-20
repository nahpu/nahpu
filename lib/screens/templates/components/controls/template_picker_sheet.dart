import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Lets the user switch to another saved template.
///
/// Returns the chosen name, or null when the sheet is dismissed.
Future<String?> showTemplatePickerSheet({
  required BuildContext context,
  required List<String> savedNames,
  required String currentName,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    // useSafeArea only covers the top; keep the list above the navigation bar.
    builder: (context) => SafeArea(
      top: false,
      child: TemplatePickerSheet(
        savedNames: savedNames,
        currentName: currentName,
      ),
    ),
  );
}

class TemplatePickerSheet extends StatelessWidget {
  const TemplatePickerSheet({
    super.key,
    required this.savedNames,
    required this.currentName,
  });

  final List<String> savedNames;
  final String currentName;

  @override
  Widget build(BuildContext context) {
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
              'Templates',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (savedNames.isEmpty)
            const Padding(
              padding: EdgeInsets.all(NahpuSpacing.xl),
              child: Text(
                'No saved templates yet.',
                textAlign: TextAlign.center,
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: NahpuSpacing.xl),
                itemCount: savedNames.length,
                itemBuilder: (context, index) {
                  final name = savedNames[index];
                  final isCurrent = name == currentName;
                  return OutlinedListTile(
                    isFocused: isCurrent,
                    leading: const Icon(Icons.dashboard_customize_outlined),
                    title: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isCurrent ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(name),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
