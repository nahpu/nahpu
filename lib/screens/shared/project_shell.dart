import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/events/event_view.dart';
import 'package:nahpu/screens/narrative/narrative_view.dart';
import 'package:nahpu/screens/projects/dashboard.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/shared/navigation.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/providers/projects.dart';

/// The top-level project pages, in the same order as the destinations in
/// [ProjectBottomNavbar]. The index into this list is driven by
/// [projectNavbarIndexProvider].
const List<Widget> defaultProjectPages = [
  Dashboard(),
  SiteViewer(),
  CollEventViewer(),
  SpecimenViewer(),
  NarrativeViewer(),
];

/// Hosts the five top-level project screens in a single [Scaffold] and swaps
/// between them in place via an [IndexedStack].
///
/// Selecting a tab in [ProjectBottomNavbar] only updates
/// [projectNavbarIndexProvider]; it no longer pushes a new route, so there is
/// no page-transition animation and each screen keeps its state across
/// switches. [pages] is injectable so widget tests can supply lightweight
/// stand-ins for the real screens.
class ProjectShell extends ConsumerWidget {
  const ProjectShell({super.key, this.pages = defaultProjectPages});

  final List<Widget> pages;

  /// Route name used so screens pushed on top of the shell (forms, imports,
  /// fullscreen views) can return to it with [popToShell] regardless of how
  /// many routes are stacked above it.
  static const String routeName = 'project_shell';

  /// The route used to open a project. Always carries [routeName] so
  /// [popToShell] can find it.
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
    ref.read(projectNavbarIndexProvider.notifier).state = index;
    popToShell(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(projectNavbarIndexProvider);
    return FalseWillPop(
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: pages,
        ),
        bottomNavigationBar: const ProjectBottomNavbar(),
      ),
    );
  }
}
