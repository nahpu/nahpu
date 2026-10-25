import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/screens/home/components/global_search.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/screens/projects/project_transfer/import_project.dart';
import 'package:nahpu/screens/projects/statistics/statistics.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/media/media_gallery.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// The actions offered on the home screen: the project actions, and the
/// gallery and statistics across every project.
enum HomeProjectAction {
  createProject(
    key: ValueKey('home-create-project'),
    iconPath: 'assets/icons/project_create.svg',
    menuIcon: Icons.create_outlined,
    isPrimary: true,
  ),
  mediaGallery(
    key: ValueKey('home-media-gallery'),
    iconPath: 'assets/icons/image-gallery.svg',
    menuIcon: Icons.photo_library_outlined,
    isPrimary: false,
  ),
  importProject(
    key: ValueKey('home-import-project'),
    iconPath: 'assets/icons/project_import.svg',
    menuIcon: Icons.download_outlined,
    isPrimary: false,
  ),
  databaseStatistics(
    key: ValueKey('home-database-statistics'),
    iconPath: 'assets/icons/database.svg',
    menuIcon: Icons.analytics_outlined,
    isPrimary: false,
  );

  const HomeProjectAction({
    required this.key,
    required this.iconPath,
    required this.menuIcon,
    required this.isPrimary,
  });

  final ValueKey<String> key;
  final String iconPath;

  /// Icon beside the title when the action sits in the More menu.
  final IconData menuIcon;
  final bool isPrimary;

  /// The actions in the pill row below the search bar, in the order they
  /// give way to the More menu from the end.
  static const List<HomeProjectAction> secondary = [
    mediaGallery,
    importProject,
    databaseStatistics,
  ];

  String title(AppLocalizations l10n) => switch (this) {
    HomeProjectAction.createProject => l10n.drawerCreateProject,
    HomeProjectAction.mediaGallery => l10n.homeGallery,
    HomeProjectAction.importProject => l10n.drawerImportProject,
    HomeProjectAction.databaseStatistics => l10n.homeStatistics,
  };

  Color containerOf(ColorScheme colors) {
    return isPrimary
        ? NahpuTheme.primaryAction
        : colors.surfaceContainerHighest.withValues(alpha: 0.4);
  }

  Color foregroundOf(ColorScheme colors) {
    return isPrimary ? NahpuTheme.onPrimaryAction : colors.onSurface;
  }
}

/// Opens the screen for [action].
Future<void> openHomeProjectAction(
  BuildContext context,
  HomeProjectAction action,
) {
  return switch (action) {
    HomeProjectAction.createProject => _push(
      context,
      const CreateProjectForm(),
    ),
    HomeProjectAction.mediaGallery => showGlobalMediaGallery(context),
    HomeProjectAction.importProject => _push(
      context,
      const ImportProjectScreen.newProject(),
    ),
    HomeProjectAction.databaseStatistics => _push(
      context,
      const StatisticFullScreen(allProjects: true),
    ),
  };
}

Future<void> _push(BuildContext context, Widget screen) {
  return Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => screen),
  );
}

/// How [HomeProjectActions] arranges its cards.
enum ProjectActionLayout {
  /// Search, create, and a row of the other actions pinned above the
  /// project list.
  compact,

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
        return const HomeActionBar();
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

/// The search bar and create action, with the other actions as pills
/// below. Pills that do not fit the width move into a More menu. Wide
/// screens put create beside the search bar; compact screens lead the pill
/// row with it.
class HomeActionBar extends StatelessWidget {
  const HomeActionBar({super.key});

  static const double _gap = NahpuSpacing.md;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < NahpuBreakpoints.compact) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeSearchBar(),
              SizedBox(height: _gap),
              HomeOverflowActions(
                leading: HomeProjectAction.createProject,
                actions: HomeProjectAction.secondary,
              ),
            ],
          );
        }
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: HomeSearchBar()),
                  SizedBox(width: _gap),
                  HomeActionPill(action: HomeProjectAction.createProject),
                ],
              ),
            ),
            SizedBox(height: _gap),
            HomeOverflowActions(actions: HomeProjectAction.secondary),
          ],
        );
      },
    );
  }
}

/// A row of [HomeActionPill]s that shows as many of [actions] as fit and
/// moves the rest, from the end, into a More menu. [leading] always shows.
class HomeOverflowActions extends StatelessWidget {
  const HomeOverflowActions({super.key, required this.actions, this.leading});

  final List<HomeProjectAction> actions;
  final HomeProjectAction? leading;

  static const double _gap = NahpuSpacing.md;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textStyle = HomeActionPill.labelStyle(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    double widthOf(String label) => HomeActionPill.widthFor(
      label,
      style: textStyle,
      textScaler: textScaler,
      textDirection: textDirection,
    );

    final leading = this.leading;
    final leadingWidth = leading == null ? 0.0 : widthOf(leading.title(l10n));
    final actionWidths = [for (final a in actions) widthOf(a.title(l10n))];
    final moreWidth = widthOf(l10n.homeMoreActions);
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = leading == null
            ? constraints.maxWidth
            : constraints.maxWidth - leadingWidth - _gap;
        final shown = visiblePillCount(
          widths: actionWidths,
          moreWidth: moreWidth,
          gap: _gap,
          maxWidth: available,
        );
        final hidden = actions.sublist(shown);
        return Row(
          children: [
            if (leading != null) ...[
              Flexible(child: HomeActionPill(action: leading)),
              const SizedBox(width: _gap),
            ],
            for (final action in actions.take(shown)) ...[
              HomeActionPill(action: action),
              if (action != actions.last) const SizedBox(width: _gap),
            ],
            if (hidden.isNotEmpty) HomeMoreActionsPill(actions: hidden),
          ],
        );
      },
    );
  }
}

/// How many pills of [widths], from the start, fit [maxWidth] with [gap]
/// between them. When not all fit, room is kept for a More pill of
/// [moreWidth].
int visiblePillCount({
  required List<double> widths,
  required double moreWidth,
  required double gap,
  required double maxWidth,
}) {
  var total = 0.0;
  for (final (index, width) in widths.indexed) {
    total += width + (index > 0 ? gap : 0);
  }
  if (total <= maxWidth) return widths.length;

  var used = moreWidth;
  var count = 0;
  for (final width in widths) {
    if (used + width + gap > maxWidth) break;
    used += width + gap;
    count++;
  }
  return count;
}

/// A home action as a rounded pill: filled for the primary action,
/// outlined otherwise.
class HomeActionPill extends StatelessWidget {
  const HomeActionPill({super.key, required this.action});

  final HomeProjectAction action;

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: NahpuSpacing.lg,
    vertical: NahpuSpacing.md,
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = action.foregroundOf(colors);
    return _PillFrame(
      materialKey: action.key,
      color: action.containerOf(colors),
      hasOutline: !action.isPrimary,
      onTap: () => openHomeProjectAction(context, action),
      icon: _ActionSvg(
        iconPath: action.iconPath,
        size: NahpuControlSize.iconMedium,
        color: action.isPrimary ? foreground : colors.primary,
      ),
      label: action.title(context.l10n),
      foreground: foreground,
    );
  }

  static TextStyle labelStyle(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge ?? const TextStyle();
    return style.copyWith(fontWeight: FontWeight.w600);
  }

  /// Width of a pill showing [label], matching its laid-out size.
  static double widthFor(
    String label, {
    required TextStyle style,
    required TextScaler textScaler,
    required TextDirection textDirection,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final textWidth = painter.width.ceilToDouble();
    painter.dispose();
    return _padding.horizontal +
        NahpuControlSize.iconMedium +
        NahpuSpacing.md +
        textWidth;
  }
}

/// The pill that opens the actions without room in the row.
class HomeMoreActionsPill extends StatelessWidget {
  const HomeMoreActionsPill({super.key, required this.actions});

  final List<HomeProjectAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _PillFrame(
      materialKey: const ValueKey('home-more-actions'),
      color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
      hasOutline: true,
      onTap: () => _showMenu(context),
      icon: Icon(
        Icons.more_horiz,
        size: NahpuControlSize.iconMedium,
        color: colors.primary,
      ),
      label: context.l10n.homeMoreActions,
      foreground: colors.onSurface,
    );
  }

  Future<void> _showMenu(BuildContext context) async {
    final l10n = context.l10n;
    final action = await showAdaptiveMenu<HomeProjectAction>(
      context: context,
      items: [
        for (final action in actions)
          AdaptiveMenuItem(
            value: action,
            label: action.title(l10n),
            icon: action.menuIcon,
          ),
      ],
    );
    if (action == null || !context.mounted) return;
    await openHomeProjectAction(context, action);
  }
}

class _PillFrame extends StatelessWidget {
  const _PillFrame({
    required this.materialKey,
    required this.color,
    required this.hasOutline,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.foreground,
  });

  final Key materialKey;
  final Color color;
  final bool hasOutline;
  final VoidCallback onTap;
  final Widget icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          key: materialKey,
          color: color,
          shape: StadiumBorder(
            side: hasOutline
                ? BorderSide(
                    color: colors.outlineVariant,
                    width: NahpuStroke.thin,
                  )
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: NahpuControlSize.control,
              ),
              child: Padding(
                padding: HomeActionPill._padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: NahpuSpacing.md),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: HomeActionPill.labelStyle(
                          context,
                        ).copyWith(color: foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
            onTap: () => openHomeProjectAction(context, action),
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
            action.title(context.l10n),
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
          action.title(context.l10n),
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
