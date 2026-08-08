double? positiveCoordinateUncertainty(num? uncertainty, num? extent) {
  final base = uncertainty?.toDouble();
  final additional = extent?.toDouble();
  final validBase = base != null && base.isFinite && base > 0 ? base : null;
  final validExtent =
      additional != null && additional.isFinite && additional > 0
      ? additional
      : null;
  if (validBase == null) return validExtent;
  if (validExtent == null) return validBase;
  return validBase + validExtent;
}
