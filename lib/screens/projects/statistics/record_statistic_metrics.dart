import 'package:material_ui/material_ui.dart';

/// Shared descriptors for the record statistics shown on the project dashboard
/// and on the full-screen statistics summary.
///
/// Both surfaces read labels, icons, and widget keys from here so they cannot
/// drift apart.
enum RecordMetricKind {
  specimens(label: 'Specimens', slug: 'specimens'),
  classes(label: 'Classes', slug: 'classes'),
  orders(label: 'Orders', slug: 'orders'),
  families(label: 'Families', slug: 'families'),
  genera(label: 'Genera', slug: 'genera'),
  species(label: 'Species', slug: 'species'),
  recordedSites(
    label: 'Recorded sites',
    slug: 'recorded-sites',
    icon: Icons.place_outlined,
  ),
  sampledSites(
    label: 'Sampled sites',
    slug: 'sampled-sites',
    icon: Icons.pin_drop_outlined,
  ),
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
  recordedElevation(
    label: 'Recorded elevation',
    slug: 'recorded-elevation',
    icon: Icons.terrain_outlined,
  ),
  sampledElevation(
    label: 'Sampled elevation',
    slug: 'sampled-elevation',
    icon: Icons.landscape_outlined,
  );

  const RecordMetricKind({required this.label, required this.slug, this.icon});

  final String label;
  final String slug;

  /// Icon for this metric, or null when it is rendered without one.
  ///
  /// The specimen headline and the taxonomic rank counts lean on type scale and
  /// fill for emphasis, and the rank counts read as one ladder, so they stay
  /// iconless on both the dashboard panel and the full-screen summary.
  final IconData? icon;

  /// Whether this metric is rendered with its [icon].
  bool get hasIcon => icon != null;

  ValueKey<String> get dashboardKey => ValueKey('record-stat-$slug');

  ValueKey<String> get fullScreenKey =>
      ValueKey('full-screen-record-stat-$slug');
}
