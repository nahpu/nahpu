import 'package:material_ui/material_ui.dart';

/// Shared descriptors for the record statistics shown on the project dashboard
/// and on the full-screen statistics summary.
///
/// Both surfaces read labels, icons, and widget keys from here so they cannot
/// drift apart.
enum RecordMetricKind {
  specimens(
    label: 'Specimens',
    slug: 'specimens',
    icon: Icons.inventory_2_outlined,
  ),
  species(label: 'Species', slug: 'species', icon: Icons.category_outlined),
  families(
    label: 'Families',
    slug: 'families',
    icon: Icons.account_tree_outlined,
  ),
  sites(label: 'Sites', slug: 'sites', icon: Icons.place_outlined),
  events(label: 'Events', slug: 'events', icon: Icons.event_outlined),
  narratives(
    label: 'Narratives',
    slug: 'narratives',
    icon: Icons.notes_outlined,
  ),
  captureDays(
    label: 'Capture days',
    slug: 'capture-days',
    icon: Icons.timelapse_outlined,
  ),
  projectDays(
    label: 'Project days',
    slug: 'total-days',
    icon: Icons.date_range_outlined,
  ),
  elevation(
    label: 'Site elevation',
    slug: 'elevation',
    icon: Icons.terrain_outlined,
  );

  const RecordMetricKind({
    required this.label,
    required this.slug,
    required this.icon,
  });

  final String label;
  final String slug;
  final IconData icon;

  /// Whether this metric is rendered with its icon.
  ///
  /// The headline record counts lean on type scale and fill for emphasis, so
  /// they stay iconless on both the dashboard panel and the full-screen
  /// summary. Every other metric carries [icon].
  bool get hasIcon => switch (this) {
    RecordMetricKind.specimens ||
    RecordMetricKind.species ||
    RecordMetricKind.families => false,
    _ => true,
  };

  ValueKey<String> get dashboardKey => ValueKey('record-stat-$slug');

  ValueKey<String> get fullScreenKey =>
      ValueKey('full-screen-record-stat-$slug');
}
