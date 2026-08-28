import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/events/event_view.dart';
import 'package:nahpu/screens/narrative/narrative_view.dart';
import 'package:nahpu/screens/projects/components/menu_drawer.dart';
import 'package:nahpu/screens/projects/dashboard.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/layout/navigation.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/styles/design_tokens.dart';

const double _projectMenuPanelWidth = 360;

/// The top-level project pages, in [ProjectBottomNavbar] destination order.
const List<Widget> defaultProjectPages = [
  Dashboard(),
  SiteViewer(),
  CollEventViewer(),
  SpecimenViewer(),
  NarrativeViewer(),
];

/// Hosts the five top-level project screens and swaps between them in place
/// via an [IndexedStack] driven by [projectNavbarIndexProvider] — no route
/// push, so screens keep their state across tab switches. [pages] is
/// injectable so widget tests can supply lightweight stand-ins.
class ProjectShell extends ConsumerStatefulWidget {
  const ProjectShell({super.key, this.pages = defaultProjectPages});

  final List<Widget> pages;

  /// Lets [popToShell] find the shell under any number of stacked routes.
  static const String routeName = 'project_shell';

  /// The route used to open a project; carries [routeName] for [popToShell].
  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const ProjectShell(),
    );
  }

  /// Pops every route stacked above the shell, returning to it in place.
  static void popToShell(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.settings.name == routeName);
  }

  /// Selects [index] on the shell's navbar and returns to the shell.
  static void returnToTab(BuildContext context, WidgetRef ref, int index) {
    ref.read(projectNavbarIndexProvider.notifier).updateState(index);
    popToShell(context);
  }

  @override
  ConsumerState<ProjectShell> createState() => _ProjectShellState();
}

class _ProjectShellState extends ConsumerState<ProjectShell> {
  bool _isProjectMenuOpen = false;
  bool _isCoveredByRoute = false;

  /// Keeps the page stack's element — and every screen's [State] under it —
  /// alive when the rail breakpoint swaps the body between a bare stack and a
  /// [Row]. Without it the whole subtree is rebuilt from scratch on resize,
  /// resetting record navigation, search, and scroll state.
  final GlobalKey _pageStackKey = GlobalKey();

  /// Whether the shell itself is the visible route. A dialog opened from the
  /// menu takes focus and swallows taps that land outside the panel; neither is
  /// the user dismissing the menu. Closing it there unmounts the panel — and
  /// the tile whose `ref` and `context` the running action still depends on.
  bool get _isShellRouteCurrent => ModalRoute.isCurrentOf(context) ?? true;

  void _closeProjectMenu() {
    if (_isProjectMenuOpen && _isShellRouteCurrent) {
      setState(() => _isProjectMenuOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(projectNavbarIndexProvider);
    final isShellRouteCurrent = _isShellRouteCurrent;
    if (isShellRouteCurrent && _isCoveredByRoute) {
      // Whatever the menu opened — its confirmation dialog, or a page it
      // pushed — is gone, so the menu has served its purpose and closes
      // behind it. Holding it open only spans the covering route's lifetime.
      _isProjectMenuOpen = false;
    }
    _isCoveredByRoute = !isShellRouteCurrent;
    return FalseWillPop(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useProjectRail =
              constraints.maxWidth >= NahpuBreakpoints.desktop;
          return Scaffold(
            body: _buildBody(useProjectRail, index),
            bottomNavigationBar: useProjectRail
                ? null
                : const ProjectBottomNavbar(),
          );
        },
      ),
    );
  }

  Widget _buildBody(bool useProjectRail, int index) {
    final pageStack = IndexedStack(
      key: _pageStackKey,
      index: index,
      children: widget.pages,
    );
    if (!useProjectRail) return pageStack;
    return Row(
      children: [
        ProjectNavigationRail(
          isMenuOpen: _isProjectMenuOpen,
          onMenuVisibilityChanged: (isOpen) {
            if (_isProjectMenuOpen != isOpen) {
              setState(() => _isProjectMenuOpen = isOpen);
            }
          },
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: pageStack),
              if (_isProjectMenuOpen)
                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  start: 0,
                  width: _projectMenuPanelWidth,
                  child: TapRegion(
                    groupId: projectMenuTapRegionGroupId,
                    onTapOutside: (_) => _closeProjectMenu(),
                    child: FocusScope(
                      autofocus: true,
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) _closeProjectMenu();
                      },
                      child: const ProjectMenuDrawer(showCloseProject: false),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
