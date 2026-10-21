import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Rounded card along the bottom of the dashboard that launches project
/// tools. Its outer padding matches the project navigation rail, so on large
/// screens the two cards end at the same distance from the window edge.
class ToolDock extends StatelessWidget {
  const ToolDock({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  const SizedBox(width: NahpuSpacing.md),
                  ToolDockLauncher(
                    icon: Icons.table_chart_outlined,
                    label: 'Data table',
                    tooltip: 'Browse, sort, and search project records',
                    onPressed: () => _open(context, const DataTableScreen()),
                  ),
                  ToolDockLauncher(
                    icon: Icons.edit_note_outlined,
                    label: 'Templates',
                    tooltip: 'Create and edit document templates',
                    onPressed: () =>
                        _open(context, const TemplateEditorScreen()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => screen));
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
  });

  final IconData icon;
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
                color: theme.colorScheme.primary,
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
