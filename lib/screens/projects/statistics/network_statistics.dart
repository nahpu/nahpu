import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/network_workspace.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Explore card for the statistics network: the section switch, then the
/// network in a fixed-height card with a button to open it full screen.
class NetworkStatisticsPanel extends StatelessWidget {
  const NetworkStatisticsPanel({
    super.key,
    required this.projectUuid,
    required this.projectName,
    required this.height,
    required this.sectionSwitch,
  });

  /// Share of the screen height the card may take on narrow screens, so its
  /// bottom sheet stays in sight while the card is scrolled into view.
  static const _narrowHeightShare = 0.8;

  /// Project the network covers, or null for every project.
  final String? projectUuid;
  final String projectName;

  /// Fixed card height, shared with the other Explore cards.
  final double height;

  /// Counts/Spatial/Network switch shown above the card.
  final Widget sectionSwitch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxWidth >= NahpuBreakpoints.desktop
            ? height
            : math.min(
                height,
                MediaQuery.sizeOf(context).height * _narrowHeightShare,
              );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              // Matches the default Card margin so the switch lines up with
              // the card below it.
              padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xs),
              child: Align(
                alignment: Alignment.centerLeft,
                child: sectionSwitch,
              ),
            ),
            const SizedBox(height: NahpuSpacing.lg),
            Card(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                key: const ValueKey('statistics-network-content'),
                height: cardHeight,
                child: NetworkWorkspace(
                  projectUuid: projectUuid,
                  onFullScreen: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NetworkStatisticsFullScreen(
                        projectUuid: projectUuid,
                        projectName: projectName,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Full-screen statistics network: the canvas fills the screen with its
/// controls laid over it. Shares its view state with the Explore card, so
/// expanded records and the selection carry over both ways.
class NetworkStatisticsFullScreen extends StatelessWidget {
  const NetworkStatisticsFullScreen({
    super.key,
    required this.projectUuid,
    required this.projectName,
  });

  final String? projectUuid;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The network runs under the home indicator; the workspace keeps its
      // controls clear of it.
      body: SafeArea(
        bottom: false,
        child: NetworkWorkspace(
          projectUuid: projectUuid,
          title: '${context.l10n.projectStatsNetwork} · $projectName',
          onExitFullScreen: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
