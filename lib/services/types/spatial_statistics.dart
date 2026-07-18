import 'dart:math' as math;

enum SpatialStatisticKind { coordinate, specimens, species, family }

extension SpatialStatisticKindLabels on SpatialStatisticKind {
  String get label => switch (this) {
        SpatialStatisticKind.coordinate => 'Coordinate',
        SpatialStatisticKind.specimens => 'Specimens',
        SpatialStatisticKind.species => 'Species',
        SpatialStatisticKind.family => 'Family',
      };

  String get title => switch (this) {
        SpatialStatisticKind.coordinate => 'Project coordinates',
        SpatialStatisticKind.specimens => 'Specimens by coordinate',
        SpatialStatisticKind.species => 'Species by coordinate',
        SpatialStatisticKind.family => 'Families by coordinate',
      };

  bool get hasCounts => this != SpatialStatisticKind.coordinate;
}

class SpatialStatisticRequest {
  const SpatialStatisticRequest({
    required this.projectUuid,
    required this.kind,
  });

  final String projectUuid;
  final SpatialStatisticKind kind;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpatialStatisticRequest &&
          other.projectUuid == projectUuid &&
          other.kind == kind;

  @override
  int get hashCode => Object.hash(projectUuid, kind);
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
) =>
    data.where((datum) => datum.hasValidPosition).toList(growable: false);

double spatialMarkerRadius({
  required SpatialStatisticKind kind,
  required int count,
  required int maximumCount,
}) {
  if (!kind.hasCounts) return 9;
  if (maximumCount <= 0 || count <= 0) return 8;
  return math.max(8, 32 * math.sqrt(count / maximumCount));
}
