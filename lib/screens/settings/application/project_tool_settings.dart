import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/components/tool_dock.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/project_tools.dart';

/// Chooses the tools shown in the project dashboard dock, grouped by the
/// categories the dock separates with dividers.
class ProjectToolSettings extends ConsumerWidget {
  const ProjectToolSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(projectToolsProvider);
    final notifier = ref.read(projectToolsProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
        actions: [
          TextButton(onPressed: notifier.reset, child: const Text('Reset')),
        ],
      ),
      body: CommonSettingList(
        sections: [
          for (final category in ProjectToolCategory.values)
            CommonSettingSection(
              title: category.label,
              isDivided: true,
              children: [
                for (final tool in ProjectTool.values)
                  if (tool.category == category)
                    CommonSettingTile(
                      icon: tool.icon,
                      title: tool.label,
                      label: tool.description,
                      trailing: Switch(
                        value: enabled.contains(tool),
                        onChanged: (value) => notifier.setEnabled(tool, value),
                      ),
                      onTap: () =>
                          notifier.setEnabled(tool, !enabled.contains(tool)),
                    ),
              ],
            ),
        ],
      ),
    );
  }
}
