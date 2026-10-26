import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_marker_visuals.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/sites/coordinate_map_point.dart';
import 'package:nahpu/services/statistics/spatial_marker_clusters.dart';
import 'package:nahpu/styles/themes.dart';

/// Members named in a grouped bubble's tooltip before summarizing the rest.
const int coordinateClusterDetailLimit = 5;

/// How a coordinate marker or group is drawn, shared by every map renderer so
/// `flutter_map` and MapLibre show the same markers.
class CoordinateMarkerVisual extends StatelessWidget {
  const CoordinateMarkerVisual({
    super.key,
    required this.cluster,
    required this.selectedPointIds,
    required this.focusedPointId,
  });

  final MarkerCluster<CoordinateMapPoint> cluster;
  final Set<int> selectedPointIds;
  final int? focusedPointId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (cluster.isSingle) {
      final point = cluster.members.single;
      return CoordinatePointDot(
        selected: selectedPointIds.contains(point.id),
        focused: point.id == focusedPointId,
      );
    }
    final selected = cluster.members.any(
      (point) => selectedPointIds.contains(point.id),
    );
    return SpatialClusterBubble(
      diameter: coordinateClusterDiameter(cluster),
      countLabel: '${cluster.members.length}',
      color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      foregroundColor: selected ? colorScheme.onPrimary : colorScheme.surface,
    );
  }
}

/// One coordinate's dot: muted when unselected, primary when selected, and
/// larger in the focus color for the coordinate being worked on.
class CoordinatePointDot extends StatelessWidget {
  const CoordinatePointDot({
    super.key,
    required this.selected,
    required this.focused,
  });

  final bool selected;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = focused
        ? NahpuTheme.focusedMapMarker(colorScheme)
        : selected
        ? colorScheme.primary
        : colorScheme.outline;
    return SizedBox.square(
      dimension: coordinateDotDiameter(selected: selected, focused: focused),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: colorScheme.surface, width: 2),
        ),
      ),
    );
  }
}

/// Outer size of a [CoordinatePointDot], its outline included.
double coordinateDotDiameter({required bool selected, required bool focused}) =>
    (coordinateMarkerRadius(selected: selected, focused: focused) + 2) * 2;

/// Outer size of a grouped bubble or single dot drawn for [cluster].
double coordinateClusterDiameter(
  MarkerCluster<CoordinateMapPoint> cluster, {
  Set<int> selectedPointIds = const {},
  int? focusedPointId,
}) {
  if (!cluster.isSingle) {
    return coordinateClusterRadius(cluster.members.length) * 2 + 3;
  }
  final point = cluster.members.single;
  return coordinateDotDiameter(
    selected: selectedPointIds.contains(point.id),
    focused: point.id == focusedPointId,
  );
}

/// Draw order for markers: unselected dots first, then selected dots, then
/// groups, with the focused coordinate on top.
List<MarkerCluster<CoordinateMapPoint>> coordinateMarkerPaintOrder(
  List<MarkerCluster<CoordinateMapPoint>> clusters, {
  required Set<int> selectedPointIds,
  required int? focusedPointId,
}) {
  int rank(MarkerCluster<CoordinateMapPoint> cluster) {
    if (!cluster.isSingle) return 2;
    final id = cluster.members.single.id;
    if (id == focusedPointId) return 3;
    return selectedPointIds.contains(id) ? 1 : 0;
  }

  return [...clusters]..sort((a, b) => rank(a).compareTo(rank(b)));
}

/// Tooltip heading for a grouped bubble.
String coordinateClusterTitle(
  BuildContext context,
  MarkerCluster<CoordinateMapPoint> cluster,
) => context.l10n.projectStatsSiteCount(cluster.members.length);

/// Tooltip lines for a grouped bubble: its first members, then a zoom hint.
List<String> coordinateClusterDetails(
  AppLocalizations l10n,
  MarkerCluster<CoordinateMapPoint> cluster, {
  required bool canZoomIn,
}) {
  final members = [...cluster.members]
    ..sort((a, b) => a.name.compareTo(b.name));
  return [
    for (final point in members.take(coordinateClusterDetailLimit)) point.name,
    if (members.length > coordinateClusterDetailLimit)
      l10n.mapMoreCount(members.length - coordinateClusterDetailLimit),
    if (canZoomIn) l10n.mapTapToZoomIn,
  ];
}
