import 'package:nahpu/services/database/database.dart';

String formatCoordinate(double? value, {required int decimals}) {
  if (value == null) return '—';
  return value.toStringAsFixed(decimals).replaceFirst(RegExp(r'\.?0+$'), '');
}

String formatCoordinateText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '—' : trimmed;
}

String formatCoordinateInteger(int? value) => value?.toString() ?? '—';

/// Returns a readable dropdown label, even for unnamed coordinates.
String coordinateLabel(CoordinateData data) {
  final name = data.nameId?.trim() ?? '';
  if (name.isNotEmpty) return name;
  final latitude = data.decimalLatitude;
  final longitude = data.decimalLongitude;
  if (latitude == null || longitude == null) return 'Coordinate ${data.id}';
  final position =
      '${formatCoordinate(latitude, decimals: 6)}, '
      '${formatCoordinate(longitude, decimals: 6)}';
  final elevation = data.elevationInMeter;
  if (elevation == null) return position;
  return '$position · ${formatCoordinate(elevation, decimals: 1)} m';
}
