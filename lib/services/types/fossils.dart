/// Types shared by the fossil (paleontology) catalog format.
///
/// These lists back the site sedimentology form, and are also used by
/// data import and export. Keep them here rather than in the UI so that
/// every consumer validates against the same vocabulary.
library;

// Database read through index.
// and stored as integer.
// DON'T CHANGE ORDER!
enum DepositionalEnvironmentType {
  continental,
  marine,
  mixed,
  unknown,
  notApplicable,
}

/// Labels for [DepositionalEnvironmentType], in enum order.
const List<String> depositionalEnvironmentTypeList = [
  'Continental',
  'Marine',
  'Mixed',
  'Unknown',
  'Not Applicable',
];

DepositionalEnvironmentType? getDepositionalEnvironmentType(int? type) {
  if (type != null &&
      type >= 0 &&
      type < DepositionalEnvironmentType.values.length) {
    return DepositionalEnvironmentType.values[type];
  }
  return null;
}

/// Sub-environments shown when the type is
/// [DepositionalEnvironmentType.continental].
const List<String> continentalSubEnvironmentList = [
  'Aeolian',
  'Alluvial',
  'Colluvial (landslide, etc)',
  'Deltaic',
  'Estuarine',
  'Evaporitic',
  'Fluvial',
  'Glacial',
  'Lacustrine',
  'Peat Swamp',
  'Coal Mire',
  'Tidal',
  'Volcaniclastic',
  'Other',
  'Varied',
  'Unknown',
  'Not Applicable',
];

/// Sub-environments shown when the type is
/// [DepositionalEnvironmentType.marine].
const List<String> marineSubEnvironmentList = [
  'Shallow-Marine',
  'Carbonate',
  'Continental Margin',
  'Deep-Marine / Pelagic',
  'Other',
  'Varied',
  'Unknown',
  'Not Applicable',
];

const List<String> standardPreservationTypeList = [
  'Amber',
  'Carbonization',
  'Concretion',
  'Desiccation',
  'Fluvial Accumulation',
  'Mummification',
  'Phosphatization',
  'Pyritization',
  'Rapid Burial',
  'Silicification',
  'Tar Pit',
  'Tidal Accumulation',
  'Varied',
  'Other',
  'Unknown',
  'Not Applicable',
];

const List<String> defaultFossilSiteTypes = [
  'Badlands',
  'Hot desert flats',
  'Mining outcrop',
  'Polar desert',
  'Shrubland',
  'Tidal / Coastal',
  'Tar pit',
  'Urban',
  'Volcanic',
  'Wetland',
  'Woodland',
  'Other',
];
