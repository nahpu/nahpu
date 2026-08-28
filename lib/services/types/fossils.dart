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

// --- Stratigraphy vocabularies ---
//
// UI only for now: the stratigraphy form is not yet persisted, so these back
// the dropdowns but are not read through a database index. Kept here (like the
// sedimentology lists above) so a future data layer validates against the same
// vocabulary. Every stratigraphy dropdown also offers "Unknown" and
// "Not Applicable"; append them with [withStratigraphyFallback] rather than
// repeating them in each list.

const List<String> geologicEraList = [
  'Paleozoic',
  'Mesozoic',
  'Cenozoic',
  'Unknown',
  'Not Applicable',
];

/// Geologic periods shown for a selected [geologicEraList] value.
const Map<String, List<String>> geologicPeriodsByEra = {
  'Paleozoic': [
    'Cambrian',
    'Ordovician',
    'Silurian',
    'Devonian',
    'Carboniferous',
    'Permian',
  ],
  'Mesozoic': [
    'Triassic',
    'Jurassic',
    'Cretaceous',
  ],
  'Cenozoic': [
    'Paleogene',
    'Neogene',
    'Quaternary',
  ],
};

/// Geologic series (chronostratigraphic) shown for a selected period.
const Map<String, List<String>> geologicSeriesByPeriod = {
  'Cambrian': ['Terreneuvian', 'Cambrian Series 2', 'Miaolingian', 'Furongian'],
  'Ordovician': ['Lower Ordovician', 'Middle Ordovician', 'Upper Ordovician'],
  'Silurian': ['Llandovery', 'Wenlock', 'Ludlow', 'Pridoli'],
  'Devonian': ['Lower Devonian', 'Middle Devonian', 'Upper Devonian'],
  'Carboniferous': ['Mississippian', 'Pennsylvanian'],
  'Permian': ['Cisuralian', 'Guadalupian', 'Lopingian'],
  'Triassic': ['Lower Triassic', 'Middle Triassic', 'Upper Triassic'],
  'Jurassic': ['Lower Jurassic', 'Middle Jurassic', 'Upper Jurassic'],
  'Cretaceous': ['Lower Cretaceous', 'Upper Cretaceous'],
  'Paleogene': ['Paleocene', 'Eocene', 'Oligocene'],
  'Neogene': ['Miocene', 'Pliocene'],
  'Quaternary': ['Pleistocene', 'Holocene'],
};

/// Geologic epochs (geochronologic) shown for a selected period. Epoch depends
/// on the period, not the series.
const Map<String, List<String>> geologicEpochsByPeriod = {
  'Cambrian': ['Terreneuvian', 'Cambrian Epoch 2', 'Miaolingian', 'Furongian'],
  'Ordovician': ['Early Ordovician', 'Middle Ordovician', 'Late Ordovician'],
  'Silurian': ['Llandovery', 'Wenlock', 'Ludlow', 'Pridoli'],
  'Devonian': ['Early Devonian', 'Middle Devonian', 'Late Devonian'],
  'Carboniferous': ['Mississippian', 'Pennsylvanian'],
  'Permian': ['Cisuralian', 'Guadalupian', 'Lopingian'],
  'Triassic': ['Early Triassic', 'Middle Triassic', 'Late Triassic'],
  'Jurassic': ['Early Jurassic', 'Middle Jurassic', 'Late Jurassic'],
  'Cretaceous': ['Early Cretaceous', 'Late Cretaceous'],
  'Paleogene': ['Paleocene', 'Eocene', 'Oligocene'],
  'Neogene': ['Miocene', 'Pliocene'],
  'Quaternary': ['Pleistocene', 'Holocene'],
};

/// Appends the shared "Unknown" / "Not Applicable" options to a conditional
/// stratigraphy list so every dropdown offers them.
List<String> withStratigraphyFallback(List<String> options) => [
      ...options,
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
