enum CoordinateImportField {
  nameId('Name / ID', isRequired: false),
  decimalLatitude('Latitude', isRequired: true),
  decimalLongitude('Longitude', isRequired: true),
  elevationInMeter('Elevation (m)', isRequired: false),
  gpsUnit('GPS unit', isRequired: false),
  notes('Notes', isRequired: false);

  const CoordinateImportField(this.label, {required this.isRequired});

  final String label;
  final bool isRequired;
}

class CoordinateImportRecord {
  const CoordinateImportRecord({
    required this.nameId,
    required this.decimalLatitude,
    required this.decimalLongitude,
    this.elevationInMeter,
    this.gpsUnit,
    this.notes,
  });

  final String nameId;
  final double decimalLatitude;
  final double decimalLongitude;
  final double? elevationInMeter;
  final String? gpsUnit;
  final String? notes;
}
