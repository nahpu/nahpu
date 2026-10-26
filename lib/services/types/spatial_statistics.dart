import 'dart:math' as math;

enum SpatialStatisticKind { specimens, species, family, coordinatesBySpecies }

extension SpatialStatisticKindLabels on SpatialStatisticKind {
  String get label => switch (this) {
    SpatialStatisticKind.specimens => 'Specimens',
    SpatialStatisticKind.species => 'Species',
    SpatialStatisticKind.family => 'Family',
    SpatialStatisticKind.coordinatesBySpecies => 'Coordinates by species',
  };

  String get title => switch (this) {
    SpatialStatisticKind.specimens => 'Specimens counts by site coordinates',
    SpatialStatisticKind.species => 'Species counts by site coordinates',
    SpatialStatisticKind.family => 'Families counts by site coordinates',
    SpatialStatisticKind.coordinatesBySpecies =>
      'Selected species counts by coordinates',
  };

  String get fileSlug => switch (this) {
    SpatialStatisticKind.specimens => 'spatial-specimens',
    SpatialStatisticKind.species => 'spatial-species',
    SpatialStatisticKind.family => 'spatial-families',
    SpatialStatisticKind.coordinatesBySpecies =>
      'spatial-coordinates-by-species',
  };

  bool get hasCounts => true;

  /// Whether each count is specimens, so counts add up across coordinates.
  bool get countsSpecimens => switch (this) {
    SpatialStatisticKind.specimens ||
    SpatialStatisticKind.coordinatesBySpecies => true,
    SpatialStatisticKind.species || SpatialStatisticKind.family => false,
  };

  bool get needsSpecies => this == SpatialStatisticKind.coordinatesBySpecies;

  String get countLabel => switch (this) {
    SpatialStatisticKind.specimens ||
    SpatialStatisticKind.coordinatesBySpecies => 'specimens',
    SpatialStatisticKind.species => 'species',
    SpatialStatisticKind.family => 'families',
  };
}

class SpatialStatisticRequest {
  const SpatialStatisticRequest({
    required this.projectUuid,
    required this.kind,
    this.speciesId,
  });

  /// Project the statistics cover, or null for every project in the database.
  final String? projectUuid;
  final SpatialStatisticKind kind;
  final int? speciesId;

  bool get isReady => !kind.needsSpecies || speciesId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpatialStatisticRequest &&
          other.projectUuid == projectUuid &&
          other.kind == kind &&
          other.speciesId == speciesId;

  @override
  int get hashCode => Object.hash(projectUuid, kind, speciesId);
}

class SpatialStatisticDatum {
  const SpatialStatisticDatum({
    required this.coordinateId,
    required this.name,
    required this.decimalLatitude,
    required this.decimalLongitude,
    required this.elevationInMeter,
    required this.datum,
    required this.uncertaintyInMeters,
    required this.gpsUnit,
    required this.notes,
    this.locality,
    this.count,
  });

  final int coordinateId;
  final String? name;
  final double? decimalLatitude;
  final double? decimalLongitude;
  final double? elevationInMeter;
  final String? datum;
  final int? uncertaintyInMeters;
  final String? gpsUnit;
  final String? notes;
  final String? locality;
  final int? count;

  String get displayName {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Unnamed coordinate ($coordinateId)';
    }
    return trimmed;
  }

  bool get hasValidPosition {
    final latitude = decimalLatitude;
    final longitude = decimalLongitude;
    return latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}

int spatialStatisticTotal(List<SpatialStatisticDatum> data) =>
    data.fold(0, (sum, datum) => sum + (datum.count ?? 0));

double spatialStatisticPercent(SpatialStatisticDatum datum, int total) {
  if (total == 0) return 0;
  return (datum.count ?? 0) * 100 / total;
}

List<SpatialStatisticDatum> mappableSpatialStatistics(
  List<SpatialStatisticDatum> data,
) => data.where((datum) => datum.hasValidPosition).toList(growable: false);

double spatialMarkerRadius({
  required SpatialStatisticKind kind,
  required int count,
  required int maximumCount,
}) {
  if (maximumCount <= 0 || count <= 0) return 8;
  return math.max(8, 32 * math.sqrt(count / maximumCount));
}

/// Largest radius for a bubble that groups overlapping coordinates.
const double spatialClusterMaxRadius = 44;

/// Radius for a bubble grouping coordinates whose counts add up to [count].
///
/// Follows [spatialMarkerRadius] up to the largest single coordinate, then
/// keeps growing, more slowly, so a group still reads as bigger.
double spatialClusterRadius({required int count, required int maximumCount}) {
  if (maximumCount <= 0 || count <= 0) return 8;
  return math
      .max(8.0, 32 * math.sqrt(count / maximumCount))
      .clamp(8.0, spatialClusterMaxRadius)
      .toDouble();
}

/// Smallest drawn radius for a grouped bubble, so its count stays legible.
const double spatialClusterMinimumDisplayRadius = 14;

/// Drawn radius for a grouped bubble. Grouping itself uses
/// [spatialClusterRadius]; the bubble is only drawn larger to fit its count.
double spatialClusterDisplayRadius({
  required int count,
  required int maximumCount,
}) => math.max(
  spatialClusterRadius(count: count, maximumCount: maximumCount),
  spatialClusterMinimumDisplayRadius,
);

/// Members listed by name in a grouped bubble's details before summarizing.
const int spatialClusterDetailLimit = 5;

/// Accessible label and tooltip for one coordinate circle.
String spatialRowLabel(
  SpatialStatisticKind kind,
  SpatialStatisticDatum row,
  int total,
) {
  if (!kind.hasCounts) return row.displayName;
  return '${row.displayName}, ${row.count} ${kind.countLabel} '
      '(${spatialStatisticPercent(row, total).toStringAsFixed(1)}%)';
}

/// Heading for a bubble grouping [members] whose counts add up to [count].
String spatialClusterTitle(
  SpatialStatisticKind kind,
  List<SpatialStatisticDatum> members,
  int count,
) => '${members.length} coordinates · $count ${kind.countLabel}';

/// Detail lines for a grouped bubble: its largest members, then a zoom hint.
List<String> spatialClusterDetails(
  List<SpatialStatisticDatum> members, {
  required bool canZoomIn,
}) => [
  for (final row in members.take(spatialClusterDetailLimit))
    '${row.displayName}: ${row.count ?? 0}',
  if (members.length > spatialClusterDetailLimit)
    '+${members.length - spatialClusterDetailLimit} more',
  if (canZoomIn) 'Tap to zoom in',
];

/// Headline numbers for the spatial statistics card.
class SpatialStatisticSummary {
  const SpatialStatisticSummary({
    required this.coordinateCount,
    required this.total,
    required this.top,
    required this.minimumElevation,
    required this.maximumElevation,
  });

  factory SpatialStatisticSummary.fromRows(List<SpatialStatisticDatum> rows) {
    SpatialStatisticDatum? top;
    double? minimumElevation;
    double? maximumElevation;
    for (final row in rows) {
      if ((row.count ?? 0) > (top?.count ?? 0)) top = row;
      final elevation = row.elevationInMeter;
      if (elevation == null) continue;
      if (minimumElevation == null || elevation < minimumElevation) {
        minimumElevation = elevation;
      }
      if (maximumElevation == null || elevation > maximumElevation) {
        maximumElevation = elevation;
      }
    }
    return SpatialStatisticSummary(
      coordinateCount: rows.length,
      total: spatialStatisticTotal(rows),
      top: top,
      minimumElevation: minimumElevation,
      maximumElevation: maximumElevation,
    );
  }

  final int coordinateCount;

  /// Sum of the per-coordinate counts.
  final int total;

  /// Coordinate with the highest count, or null when every count is zero.
  final SpatialStatisticDatum? top;
  final double? minimumElevation;
  final double? maximumElevation;

  /// Mean count per coordinate.
  double get average => coordinateCount == 0 ? 0 : total / coordinateCount;
}

List<int> spatialLegendCounts(List<SpatialStatisticDatum> data) {
  final counts =
      data
          .map((datum) => datum.count ?? 0)
          .where((count) => count > 0)
          .toSet()
          .toList()
        ..sort();
  if (counts.length <= 2) return counts;
  return [counts.first, counts[counts.length ~/ 2], counts.last];
}
