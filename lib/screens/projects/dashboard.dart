import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/statistics/statistics.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/projects/components/menu_drawer.dart';
import 'package:nahpu/screens/projects/components/overview.dart';
import 'package:nahpu/screens/projects/components/tool_dock.dart';
import 'package:nahpu/screens/projects/personnel/personnel.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_registry.dart';
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
        title: Text(context.l10n.projectDashboard),
        automaticallyImplyLeading: !useProjectRail,
      ),
      drawer: useProjectRail ? null : const ProjectMenuDrawer(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          bool useHorizontalLayout = c.maxWidth > NahpuBreakpoints.compact;
          // Tall windows leave a gap above the tool dock; the top row takes
          // it up rather than leaving it empty. It never shrinks below its
          // usual height, so shorter windows scroll as before.
          final topHeight = useHorizontalLayout
              ? math.max(
                  topDashboardHeight,
                  c.maxHeight - bottomDashboardHeight,
                )
              : topDashboardHeight;
          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: NahpuPageMargin.horizontal,
              ),
              child: Column(
                children: [
                  TopPanel(
                    useHorizontalLayout: useHorizontalLayout,
                    height: topHeight,
                  ),
                  BottomPanel(useHorizontalLayout: useHorizontalLayout),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const ToolDock(),
    );
  }
}

class TopPanel extends ConsumerWidget {
  const TopPanel({super.key, required this.useHorizontalLayout, this.height});

  final bool useHorizontalLayout;

  /// Height of the row in the horizontal layout; defaults to
  /// [topDashboardHeight].
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectUuid = ref.watch(projectUuidProvider);
    return AdaptiveMainLayout(
      useHorizontalLayout: useHorizontalLayout,
      height: height ?? topDashboardHeight,
      // Both cards fill the row, so they grow together.
      stretchChildren: true,
      children: [
        ProjectOverview(
          projectUuid: projectUuid,
          useHorizontalLayout: useHorizontalLayout,
        ),
        PersonnelViewer(isExpanded: useHorizontalLayout),
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
      stretchChildren: true,
      children: const [TaxonRegistryViewer(), StatisticViewer()],
    );
  }
}
