import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/screens/exports/bundle_records.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/exports/export_documents.dart';
import 'package:nahpu/screens/exports/export_records.dart';
import 'package:nahpu/screens/exports/export_settings.dart';
import 'package:nahpu/screens/projects/project_transfer/export_project.dart';
import 'package:nahpu/screens/projects/project_transfer/import_project.dart';
import 'package:nahpu/screens/settings/settings.dart';
import 'package:nahpu/screens/settings/settings_destination.dart';
import 'package:nahpu/screens/settings/transfer/app_settings_import.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/project_tools.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Rounded card along the bottom of the dashboard that launches project
/// tools. Its outer padding matches the project navigation rail, so on large
/// screens the two cards end at the same distance from the window edge.
///
/// The tools come from the application settings; a divider separates tools of
/// different categories.
class ToolDock extends ConsumerWidget {
  const ToolDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final tools = ref.watch(projectToolsProvider);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NahpuPageMargin.horizontal,
          NahpuSpacing.md,
          NahpuPageMargin.horizontal,
          NahpuSpacing.md,
        ),
        child: Material(
          elevation: NahpuElevation.none,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(NahpuRadius.lg),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: NahpuToolDock.height,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: NahpuSpacing.lg,
                vertical: NahpuSpacing.md,
              ),
              child: Row(
                children: [
                  const ToolDockLabel(),
                  const SizedBox(width: NahpuSpacing.lg),
                  for (final (index, tool) in tools.indexed) ...[
                    if (index > 0)
                      tools[index - 1].category == tool.category
                          ? const SizedBox(width: NahpuToolDock.launcherGap)
                          : const ToolDockDivider(),
                    ToolDockLauncher(
                      icon: tool.icon,
                      label: tool.label,
                      tooltip: tool.description,
                      onPressed: () => openProjectTool(context, ref, tool),
                    ),
                  ],
                  if (tools.isNotEmpty) const ToolDockDivider(),
                  ToolDockLauncher(
                    icon: Icons.edit_outlined,
                    iconColor: colorScheme.outline,
                    label: 'Edit tools',
                    tooltip: 'Choose the tools shown here',
                    onPressed: () => openSettingsDestination(
                      context,
                      SettingsDestination.projectTools,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens [tool] from the project dashboard.
void openProjectTool(BuildContext context, WidgetRef ref, ProjectTool tool) {
  final projectUuid = ref.read(projectUuidProvider);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) =>
          ProjectToolScreen(tool: tool, projectUuid: projectUuid),
    ),
  );
}

/// The screen a project tool opens.
class ProjectToolScreen extends StatelessWidget {
  const ProjectToolScreen({
    super.key,
    required this.tool,
    required this.projectUuid,
  });

  final ProjectTool tool;
  final String projectUuid;

  @override
  Widget build(BuildContext context) {
    return switch (tool) {
      ProjectTool.dataTable => const DataTableScreen(),
      ProjectTool.templates => const TemplateEditorScreen(),
      ProjectTool.mergeProject => const ImportProjectScreen(),
      ProjectTool.exportProject => const ExportProjectScreen(),
      ProjectTool.bundleRecords => const BundleRecordsForm(),
      ProjectTool.exportRecords => const ExportForm(),
      ProjectTool.exportDocuments => const ExportDocumentsView(),
      ProjectTool.backupDatabase => const ExportDbForm(),
      ProjectTool.settings => AppSettings(projectUuid: projectUuid),
      ProjectTool.exportUserConfigs => const ExportSettingsForm(),
      ProjectTool.importUserConfigs => const AppSettingsImport(),
    };
  }
}

/// The icon for each project tool, matching the project menu drawer.
extension ProjectToolIcon on ProjectTool {
  IconData get icon => switch (this) {
    ProjectTool.dataTable => Icons.table_chart_outlined,
    ProjectTool.templates => Icons.edit_note_outlined,
    ProjectTool.mergeProject => Icons.move_to_inbox_outlined,
    ProjectTool.exportProject => Icons.outbox_outlined,
    ProjectTool.bundleRecords => Icons.archive_outlined,
    ProjectTool.exportRecords => Icons.adaptive.share_outlined,
    ProjectTool.exportDocuments => Icons.picture_as_pdf_outlined,
    ProjectTool.backupDatabase => Icons.storage_outlined,
    ProjectTool.settings => Icons.settings_outlined,
    ProjectTool.exportUserConfigs => Icons.adaptive.share_outlined,
    ProjectTool.importUserConfigs => Icons.download_outlined,
  };
}

/// Separates tool categories in the dock.
class ToolDockDivider extends StatelessWidget {
  const ToolDockDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: NahpuToolDock.dividerWidth,
      thickness: NahpuStroke.thin,
      indent: NahpuSpacing.sm,
      endIndent: NahpuSpacing.sm,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class ToolDockLabel extends StatelessWidget {
  const ToolDockLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(right: NahpuSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: NahpuStroke.thin,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tools', style: theme.textTheme.titleSmall),
          Text(
            'Project utilities',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class ToolDockLauncher extends StatelessWidget {
  const ToolDockLauncher({
    super.key,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;

  /// Defaults to the primary color.
  final Color? iconColor;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: NahpuToolDock.launcherWidth,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(NahpuRadius.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: NahpuControlSize.icon,
                color: iconColor ?? theme.colorScheme.primary,
              ),
              const SizedBox(height: NahpuSpacing.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
