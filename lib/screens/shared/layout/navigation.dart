import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/components/menu_drawer.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/navigation_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

const double _projectRailExtendedWidth = 256;

class ProjectBottomNavbar extends ConsumerStatefulWidget {
  const ProjectBottomNavbar({super.key});

  @override
  ProjectBottomNavbarState createState() => ProjectBottomNavbarState();
}

class ProjectBottomNavbarState extends ConsumerState<ProjectBottomNavbar> {
  @override
  Widget build(BuildContext context) {
    final isPhone = getScreenType(context) == ScreenType.phone;
    int selectedIndex = ref.watch(projectNavbarIndexProvider);
    return NavigationBar(
      labelBehavior: isPhone
          ? NavigationDestinationLabelBehavior.onlyShowSelected
          : NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      elevation: NahpuElevation.none,
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(Icons.dashboard_rounded),
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.place_rounded),
          icon: Icon(Icons.place_outlined),
          label: 'Sites',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.calendar_month_rounded),
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Events',
          tooltip: 'Events',
        ),
        NavigationDestination(
          selectedIcon: SpecimenIcons(isSelected: true),
          icon: SpecimenIcons(isSelected: false),
          label: 'Specimens',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.book_rounded),
          icon: Icon(Icons.book_outlined),
          label: 'Narrative',
        ),
      ],
      onDestinationSelected: (int index) {
        _selectProjectDestination(ref, index);
      },
    );
  }
}

class ProjectNavigationRail extends ConsumerStatefulWidget {
  const ProjectNavigationRail({
    super.key,
    required this.isMenuOpen,
    required this.onToggleMenu,
  });

  final bool isMenuOpen;
  final VoidCallback onToggleMenu;

  @override
  ConsumerState<ProjectNavigationRail> createState() =>
      _ProjectNavigationRailState();
}

class _ProjectNavigationRailState extends ConsumerState<ProjectNavigationRail> {
  bool _isExtended = false;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(projectNavbarIndexProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final standardForeground = colorScheme.onSurfaceVariant;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final toggleIcon = _isExtended
        ? (isRtl
              ? Icons.keyboard_double_arrow_right_rounded
              : Icons.keyboard_double_arrow_left_rounded)
        : (isRtl
              ? Icons.keyboard_double_arrow_left_rounded
              : Icons.keyboard_double_arrow_right_rounded);

    return Padding(
      padding: const EdgeInsets.all(NahpuSpacing.md),
      child: Material(
        elevation: NahpuElevation.none,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(NahpuRadius.large),
        ),
        clipBehavior: Clip.antiAlias,
        child: NavigationRail(
          extended: _isExtended,
          labelType: _isExtended
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
          indicatorColor: colorScheme.primaryContainer,
          selectedIconTheme: IconThemeData(color: colorScheme.primary),
          selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
          ),
          unselectedIconTheme: IconThemeData(color: standardForeground),
          unselectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
            color: standardForeground,
          ),
          groupAlignment: -1,
          scrollable: true,
          selectedIndex: selectedIndex,
          leading: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RailActionButton(
                icon: toggleIcon,
                collapsedLabel: _isExtended ? 'Collapse' : 'Expand',
                expandedLabel: _isExtended
                    ? 'Collapse navigation'
                    : 'Expand navigation',
                tooltip: _isExtended
                    ? 'Collapse navigation rail'
                    : 'Expand navigation rail',
                foregroundColor: standardForeground,
                isExtended: _isExtended,
                onPressed: () {
                  setState(() => _isExtended = !_isExtended);
                },
              ),
              _RailActionButton(
                icon: widget.isMenuOpen
                    ? Icons.menu_open_rounded
                    : Icons.menu_rounded,
                collapsedLabel: 'Menu',
                expandedLabel: widget.isMenuOpen ? 'Close menu' : 'Menu',
                tooltip: widget.isMenuOpen
                    ? 'Close project menu'
                    : 'Open project menu',
                foregroundColor: standardForeground,
                isExtended: _isExtended,
                onPressed: widget.onToggleMenu,
              ),
            ],
          ),
          destinations: const [
            NavigationRailDestination(
              selectedIcon: Icon(Icons.dashboard_rounded),
              icon: Icon(Icons.dashboard_outlined),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              selectedIcon: Icon(Icons.place_rounded),
              icon: Icon(Icons.place_outlined),
              label: Text('Sites'),
            ),
            NavigationRailDestination(
              selectedIcon: Icon(Icons.calendar_month_rounded),
              icon: Icon(Icons.calendar_month_outlined),
              label: Text('Events'),
            ),
            NavigationRailDestination(
              selectedIcon: SpecimenIcons(isSelected: true),
              icon: SpecimenIcons(isSelected: false),
              label: Text('Specimens'),
            ),
            NavigationRailDestination(
              selectedIcon: Icon(Icons.book_rounded),
              icon: Icon(Icons.book_outlined),
              label: Text('Narrative'),
            ),
          ],
          onDestinationSelected: (index) =>
              _selectProjectDestination(ref, index),
          trailingAtBottom: true,
          trailing: Padding(
            padding: const EdgeInsets.only(bottom: NahpuSpacing.lg),
            child: _RailActionButton(
              icon: Icons.exit_to_app_rounded,
              collapsedLabel: 'Close',
              expandedLabel: 'Close project',
              tooltip: 'Close project',
              foregroundColor: standardForeground,
              isExtended: _isExtended,
              onPressed: () =>
                  closeProject(context, ref, ref.read(projectUuidProvider)),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailActionButton extends StatelessWidget {
  const _RailActionButton({
    required this.icon,
    required this.collapsedLabel,
    required this.expandedLabel,
    required this.tooltip,
    required this.foregroundColor,
    required this.isExtended,
    required this.onPressed,
  });

  final IconData icon;
  final String collapsedLabel;
  final String expandedLabel;
  final String tooltip;
  final Color foregroundColor;
  final bool isExtended;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isExtended) {
      return SizedBox(
        width: _projectRailExtendedWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextButton.icon(
            style: TextButton.styleFrom(
              alignment: AlignmentDirectional.centerStart,
              minimumSize: const Size.fromHeight(56),
              foregroundColor: foregroundColor,
            ),
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(expandedLabel),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 64),
          padding: const EdgeInsets.symmetric(vertical: 6),
          foregroundColor: foregroundColor,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 2),
            Text(
              collapsedLabel,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

void _selectProjectDestination(WidgetRef ref, int index) {
  ref.read(projectNavbarIndexProvider.notifier).updateState(index);
  _invalidateProjectDestination(ref, index);
}

/// Re-fetches the destination tab's data. [ProjectShell]'s [IndexedStack]
/// keeps every screen's providers alive, so this explicit invalidation is
/// the only re-fetch on a tab switch.
void _invalidateProjectDestination(WidgetRef ref, int index) {
  switch (index) {
    case 0:
      ref.invalidate(siteEntryProvider);
      ref.invalidate(weatherDataProvider);
      ref.invalidate(collEventEntryProvider);
      ref.invalidate(specimenEntryProvider);
      ref.invalidate(narrativeEntryProvider);
      break;
    case 1:
      ref.invalidate(siteEntryProvider);
      break;
    case 2:
      ref.invalidate(siteEntryProvider);
      ref.invalidate(collEventEntryProvider);
      break;
    case 3:
      ref.invalidate(collEventEntryProvider);
      ref.invalidate(specimenEntryProvider);
      break;
    case 4:
      ref.invalidate(siteEntryProvider);
      ref.invalidate(narrativeEntryProvider);
      break;
  }
}

class PageNavButton extends ConsumerStatefulWidget {
  const PageNavButton({super.key, required this.pageNav});

  final PageNavigation pageNav;

  @override
  PageNavButtonState createState() => PageNavButtonState();
}

class PageNavButtonState extends ConsumerState<PageNavButton> {
  final Curve _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: widget.pageNav.isFirstPage
                ? null
                : () => widget.pageNav.jumpToPage(0),
            child: const Icon(Icons.keyboard_double_arrow_left),
          ),
          TextButton(
            onPressed: widget.pageNav.isFirstPage
                ? null
                : () {
                    if (widget.pageNav.pageController.hasClients) {
                      widget.pageNav.pageController.previousPage(
                        duration: kTabScrollDuration,
                        curve: _curve,
                      );
                    }
                  },
            child: const Icon(Icons.navigate_before),
          ),
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => NavSheet(pageNav: widget.pageNav),
                isScrollControlled: true,
              );
            },
            child: const Icon(Icons.circle_outlined),
          ),
          TextButton(
            onPressed: widget.pageNav.isLastPage
                ? null
                : () {
                    if (widget.pageNav.pageController.hasClients) {
                      widget.pageNav.pageController.nextPage(
                        duration: kTabScrollDuration,
                        curve: _curve,
                      );
                    }
                  },
            child: const Icon(Icons.navigate_next),
          ),
          TextButton(
            onPressed: widget.pageNav.isLastPage
                ? null
                : () =>
                      widget.pageNav.jumpToPage(widget.pageNav.pageCounts - 1),
            child: const Icon(Icons.keyboard_double_arrow_right),
          ),
        ],
      ),
    );
  }
}

class PageViewer extends StatefulWidget {
  const PageViewer({
    super.key,
    required this.pageNav,
    required this.child,
    required this.isNavButtonVisible,
  });

  final PageNavigation pageNav;
  final Widget child;
  final bool isNavButtonVisible;

  @override
  State<PageViewer> createState() => _PageViewerState();
}

class _PageViewerState extends State<PageViewer> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Visibility(
          visible: _visible,
          child: PageNumberViewer(
            pageNav: widget.pageNav,
            isNavButtonVisible: widget.isNavButtonVisible,
          ),
        ),
      ],
    );
  }
}

class PageNumberViewer extends StatelessWidget {
  const PageNumberViewer({
    super.key,
    required this.pageNav,
    required this.isNavButtonVisible,
  });

  final PageNavigation pageNav;
  final bool isNavButtonVisible;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: isNavButtonVisible ? 52 : 4,
      right: 0,
      left: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Color.lerp(
              Theme.of(context).colorScheme.secondaryContainer,
              Theme.of(context).colorScheme.surface,
              0.5,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(NahpuRadius.medium),
            ),
          ),
          height: 40,
          width: 120,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: PageInfo(pageNav: pageNav),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PageInfo extends StatelessWidget {
  const PageInfo({super.key, required this.pageNav});

  final PageNavigation pageNav;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Page ${pageNav.currentPage} of ${pageNav.pageCounts}',
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}

class NavSheet extends ConsumerStatefulWidget {
  const NavSheet({super.key, required this.pageNav});

  final PageNavigation pageNav;

  @override
  NavSheetState createState() => NavSheetState();
}

class NavSheetState extends ConsumerState<NavSheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).viewInsets.bottom == 0
          ? MediaQuery.of(context).size.height * 0.2
          : MediaQuery.of(context).viewInsets.bottom + 120,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 80, maxWidth: 160),
                child: GoToPageField(
                  onSubmitted: (String value) {
                    final pageNumber = int.tryParse(value);
                    if (pageNumber == null ||
                        !widget.pageNav.pageController.hasClients) {
                      return;
                    }
                    widget.pageNav.jumpToPage(pageNumber - 1);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: NahpuSpacing.md),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: PageInfo(pageNav: widget.pageNav),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoToPageField extends StatelessWidget {
  const GoToPageField({super.key, required this.onSubmitted});

  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        label: Center(child: Text('Go to page', textAlign: TextAlign.center)),
        hintText: 'Page number',
        isDense: true,
        floatingLabelAlignment: FloatingLabelAlignment.center,
      ),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      onSubmitted: onSubmitted,
    );
  }
}

class SpecimenIcons extends ConsumerWidget {
  const SpecimenIcons({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Icon(
      ref
          .watch(catalogFmtNotifierProvider)
          .when(
            data: (catalogFmt) {
              return matchCatFmtToIcon(catalogFmt, isFilledIcon: isSelected);
            },
            loading: () => Icons.circle_outlined,
            error: (e, s) => Icons.error_outline,
          ),
    );
  }
}
