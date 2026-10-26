/// A kind of curation the specimen curation tool runs.
enum SpecimenCurationMode {
  tissue('Tissue');

  const SpecimenCurationMode(this.label);

  final String label;
}

/// How tubes are chosen in tissue mode: scanned one by one, or taken in
/// field ID order from a work list.
enum TissueEntryMode {
  scan('Scan'),
  workList('Work list');

  const TissueEntryMode(this.label);

  final String label;
}
