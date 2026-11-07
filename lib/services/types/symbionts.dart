import 'package:nahpu/services/types/specimens.dart';

const symbiontLifeStages = [
  'Egg',
  'Larva',
  'Nymph',
  'Pupa',
  'Juvenile',
  'Adult',
  'Cyst',
  'Oocyst',
  'Trophozoite',
  'Sporozoite',
  'Merozoite',
  'Gametocyte',
];

/// Where a symbiont lives on or in its host.
const List<String> defaultSymbiontCategories = [
  'Ectosymbiont',
  'Endosymbiont',
  'Mesosymbiont',
];

/// How a symbiont relates to its host. Exported as Darwin Core
/// `organismInteractionType`.
const List<String> defaultSymbiontInteractionTypes = [
  'Parasitic',
  'Parasitoid',
  'Mutualistic',
  'Commensal',
  'Phoretic',
  'Unknown',
];

const List<String> defaultSymbiontDetectionMethods = [
  'Visual inspection',
  'Combing',
  'Brushing',
  'Ethanol wash',
  'Dissection',
  'Blood smear',
  'Fecal flotation',
  'Molecular screening',
];

const List<String> defaultSymbiontPreparationMethods = [
  'Whole specimen',
  'Fluid preserved',
  'Slide mounted',
  'Pinned',
  'Dried',
  'Frozen',
];

const List<String> defaultSymbiontAnatomicalLocations = [
  'Head',
  'Ear',
  'Nasal cavity',
  'Oral cavity',
  'Body',
  'Dorsum',
  'Venter',
  'Limb',
  'Tail',
  'Skin',
  'Fur',
  'Feathers',
  'Gill',
  'Blood',
  'Stomach',
  'Small intestine',
  'Large intestine',
  'Cecum',
  'Liver',
  'Lung',
  'Heart',
  'Kidney',
  'Muscle',
  'Body cavity',
];

const List<String> defaultSymbiontStorage = [
  'Vial',
  'Cryovial',
  'Slide',
  'Envelope',
  'Jar',
];

const List<String> defaultSymbiontTreatments = [
  ...defaultTreatment,
  'RNAlater',
  'Glycerol',
];

/// Anatomical locations that fit each default symbiont category, keyed by
/// lowercase category. Categories without an entry keep every location.
const Map<String, Set<String>> symbiontCategoryLocations = {
  'ectosymbiont': {
    'head',
    'ear',
    'body',
    'dorsum',
    'venter',
    'limb',
    'tail',
    'skin',
    'fur',
    'feathers',
    'gill',
  },
  'endosymbiont': {
    'nasal cavity',
    'oral cavity',
    'blood',
    'stomach',
    'small intestine',
    'large intestine',
    'cecum',
    'liver',
    'lung',
    'heart',
    'kidney',
    'muscle',
    'body cavity',
  },
  'mesosymbiont': {'ear', 'nasal cavity', 'oral cavity', 'gill', 'skin'},
};

/// Categories stored before v26 named for parasites, keyed by lowercase name.
const Map<String, String> _legacySymbiontCategories = {
  'ectoparasite': 'ectosymbiont',
  'endoparasite': 'endosymbiont',
  'mesoparasite': 'mesosymbiont',
};

/// Narrows [options] to locations that fit [category]. Locations outside
/// every mapped category are user-defined and always kept.
List<String> filterAnatomicalLocations(
  Iterable<String> options,
  String? category,
) {
  final key = category?.trim().toLowerCase();
  final allowed =
      symbiontCategoryLocations[_legacySymbiontCategories[key] ?? key];
  if (allowed == null) return List.unmodifiable(options);
  final mapped = symbiontCategoryLocations.values.expand((e) => e).toSet();
  return List.unmodifiable(
    options.where((option) {
      final key = option.trim().toLowerCase();
      return allowed.contains(key) || !mapped.contains(key);
    }),
  );
}

const symbiontAssociationStatuses = {1: 'Confirmed', 0: 'Suspected'};

const symbiontCatalogFormats = {
  CatalogFmt.mammalogy,
  CatalogFmt.ornithology,
  CatalogFmt.herpetology,
  CatalogFmt.ichthyology,
};

bool supportsSymbionts(CatalogFmt catalogFmt) =>
    symbiontCatalogFormats.contains(catalogFmt);
