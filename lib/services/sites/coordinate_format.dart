String formatCoordinate(double? value, {required int decimals}) {
  if (value == null) return '—';
  return value.toStringAsFixed(decimals).replaceFirst(RegExp(r'\.?0+$'), '');
}

String formatCoordinateText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '—' : trimmed;
}

String formatCoordinateInteger(int? value) => value?.toString() ?? '—';
