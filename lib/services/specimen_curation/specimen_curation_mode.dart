/// A kind of curation the specimen curation tool runs.
enum SpecimenCurationMode {
  tissue('Tissue');

  const SpecimenCurationMode(this.label);

  final String label;
}
