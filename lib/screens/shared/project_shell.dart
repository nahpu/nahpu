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
