import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/statistics/statistics.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/projects/components/menu_drawer.dart';
import 'package:nahpu/screens/projects/components/overview.dart';
import 'package:nahpu/screens/projects/personnel/personnel.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_registry.dart';
import 'package:nahpu/screens/projects/edit_project.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/styles/catalog_pages.dart';
import 'package:nahpu/styles/design_tokens.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends ConsumerState<Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useProjectRail = getScreenType(context) == ScreenType.desktop;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Dashboard"),
        automaticallyImplyLeading: !useProjectRail,
      ),
      drawer: useProjectRail ? null : const ProjectMenuDrawer(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          bool useHorizontalLayout = c.maxWidth > NahpuBreakpoints.compact;
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TopPanel(useHorizontalLayout: useHorizontalLayout),
                  BottomPanel(useHorizontalLayout: useHorizontalLayout),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TopPanel extends ConsumerWidget {
  const TopPanel({super.key, required this.useHorizontalLayout});

  final bool useHorizontalLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectUuid = ref.watch(projectUuidProvider);
    return AdaptiveMainLayout(
      useHorizontalLayout: useHorizontalLayout,
      height: topDashboardHeight,
      children: [
        ProjectOverview(
          projectUuid: projectUuid,
          useHorizontalLayout: useHorizontalLayout,
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditProject(projectUuid: projectUuid),
              ),
            );
          },
        ),
        const PersonnelViewer(),
      ],
    );
  }
}

class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key, required this.useHorizontalLayout});

  final bool useHorizontalLayout;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMainLayout(
      useHorizontalLayout: useHorizontalLayout,
      height: bottomDashboardHeight,
      children: const [TaxonRegistryViewer(), StatisticViewer()],
    );
  }
}
