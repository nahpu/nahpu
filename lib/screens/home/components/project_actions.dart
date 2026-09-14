import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/screens/projects/project_transfer/import_project.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// The project actions offered on the home screen.
enum HomeProjectAction {
  createProject(
    key: ValueKey('home-create-project'),
    title: 'Create project',
    iconPath: 'assets/icons/project_create.svg',
    isPrimary: true,
  ),
  importProject(
    key: ValueKey('home-import-project'),
    title: 'Import project',
    iconPath: 'assets/icons/project_import.svg',
    isPrimary: false,
  );

  const HomeProjectAction({
    required this.key,
    required this.title,
    required this.iconPath,
    required this.isPrimary,
  });

  final ValueKey<String> key;
  final String title;
  final String iconPath;
  final bool isPrimary;

  Color containerOf(ColorScheme colors) {
    return isPrimary
        ? NahpuTheme.primaryAction
        : colors.surfaceContainerHighest.withValues(alpha: 0.4);
  }

  Color foregroundOf(ColorScheme colors) {
    return isPrimary ? NahpuTheme.onPrimaryAction : colors.onSurface;
  }
}

/// How [HomeProjectActions] arranges its cards.
enum ProjectActionLayout {
  /// One row pinned above the project list on narrow screens.
  compact,

  /// Square cards stacked beside the project list on wide screens.
  side,

  /// Cards in the middle of the screen when there are no projects yet.
  centered,
}

/// How a [ProjectActionCard] places its icon.
enum ProjectActionCardStyle {
  /// Icon beside the title.
  row,

  /// Icon above the title, with an arrow.
  tall,
}

class HomeProjectActions extends StatelessWidget {
  const HomeProjectActions({super.key, required this.layout});

  final ProjectActionLayout layout;

  /// Narrowest tall card that still fits its title, used to decide whether
  /// the empty-state cards sit side by side.
  static const double _minTallCardWidth = 200;

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case ProjectActionLayout.compact:
        return const ProjectActionRow(
          style: ProjectActionCardStyle.row,
          gap: NahpuSpacing.md,
        );
      case ProjectActionLayout.side:
        return const ProjectActionColumn(
          style: ProjectActionCardStyle.tall,
          gap: NahpuSpacing.lg,
        );
      case ProjectActionLayout.centered:
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: NahpuContentWidth.form),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSideBySide =
                  constraints.maxWidth >=
                  _minTallCardWidth * 2 + NahpuSpacing.lg;
              if (isSideBySide) {
                return const ProjectActionRow(
                  style: ProjectActionCardStyle.tall,
                  gap: NahpuSpacing.lg,
                );
              }
              return const ProjectActionColumn(
                style: ProjectActionCardStyle.row,
                gap: NahpuSpacing.md,
              );
            },
          ),
        );
    }
  }
}

/// Create and import cards side by side at equal width and height.
class ProjectActionRow extends StatelessWidget {
  const ProjectActionRow({super.key, required this.style, required this.gap});

  final ProjectActionCardStyle style;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ProjectActionCard(
              action: HomeProjectAction.createProject,
              style: style,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: ProjectActionCard(
              action: HomeProjectAction.importProject,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

/// Create above import, both at the full available width.
class ProjectActionColumn extends StatelessWidget {
  const ProjectActionColumn({
    super.key,
    required this.style,
    required this.gap,
  });

  final ProjectActionCardStyle style;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectActionCard(
          action: HomeProjectAction.createProject,
          style: style,
        ),
        SizedBox(height: gap),
        ProjectActionCard(
          action: HomeProjectAction.importProject,
          style: style,
        ),
      ],
    );
  }
}

class ProjectActionCard extends StatelessWidget {
  const ProjectActionCard({
    super.key,
    required this.action,
    required this.style,
  });

  final HomeProjectAction action;
  final ProjectActionCardStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isTall = style == ProjectActionCardStyle.tall;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          key: action.key,
          color: action.containerOf(colors),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NahpuRadius.lg),
            side: action.isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: colors.outlineVariant,
                    width: NahpuStroke.thin,
                  ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _open(context),
            child: Padding(
              padding: EdgeInsets.all(
                isTall ? NahpuSpacing.xl : NahpuSpacing.lg,
              ),
              child: isTall
                  ? _TallActionContent(action: action)
                  : _RowActionContent(action: action),
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => switch (action) {
          HomeProjectAction.createProject => const CreateProjectForm(),
          HomeProjectAction.importProject =>
            const ImportProjectScreen.newProject(),
        },
      ),
    );
  }
}

/// The action's icon inside a square of [size]. The secondary action sits
/// its icon on a tinted container; the primary action shows the icon alone,
/// since its filled card already sets it apart.
class ProjectActionIcon extends StatelessWidget {
  const ProjectActionIcon({
    super.key,
    required this.action,
    required this.size,
    required this.iconSize,
  });

  final HomeProjectAction action;
  final double size;

  /// Icon size inside the secondary action's container. The bare primary icon
  /// is drawn [NahpuSpacing.md] larger so both icons carry similar weight.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (action.isPrimary) {
      return SizedBox.square(
        dimension: size,
        child: Align(
          alignment: Alignment.topLeft,
          child: _ActionSvg(
            iconPath: action.iconPath,
            size: iconSize + NahpuSpacing.md,
            color: NahpuTheme.onPrimaryAction,
          ),
        ),
      );
    }
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(
          size < NahpuControlSize.prominent ? NahpuRadius.sm : NahpuRadius.md,
        ),
      ),
      child: _ActionSvg(
        iconPath: action.iconPath,
        size: iconSize,
        color: colors.onPrimaryContainer,
      ),
    );
  }
}

class _ActionSvg extends StatelessWidget {
  const _ActionSvg({
    required this.iconPath,
    required this.size,
    required this.color,
  });

  final String iconPath;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class _RowActionContent extends StatelessWidget {
  const _RowActionContent({required this.action});

  final HomeProjectAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ProjectActionIcon(
          action: action,
          size: NahpuControlSize.control,
          iconSize: NahpuControlSize.iconLarge,
        ),
        const SizedBox(width: NahpuSpacing.md),
        Expanded(
          child: Text(
            action.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: action.foregroundOf(theme.colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TallActionContent extends StatelessWidget {
  const _TallActionContent({required this.action});

  final HomeProjectAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = action.foregroundOf(theme.colorScheme);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectActionIcon(
              action: action,
              size: NahpuControlSize.prominent,
              iconSize: NahpuControlSize.control,
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_rounded,
              size: NahpuControlSize.iconMedium,
              color: foreground,
            ),
          ],
        ),
        const SizedBox(height: NahpuSpacing.lg),
        Text(
          action.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
