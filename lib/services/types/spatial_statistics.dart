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

  final String projectUuid;
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
