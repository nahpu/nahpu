import 'package:nahpu/services/types/specimens.dart';

const parasiteLifeStages = [
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

const List<String> defaultParasiteCategories = [
  'Ectoparasite',
  'Endoparasite',
  'Mesoparasite',
  'Parasitoid',
];

const List<String> defaultParasiteDetectionMethods = [
  'Visual inspection',
  'Combing',
  'Brushing',
  'Ethanol wash',
  'Dissection',
  'Blood smear',
  'Fecal flotation',
  'Molecular screening',
];

const List<String> defaultParasitePreparationMethods = [
  'Whole specimen',
  'Fluid preserved',
  'Slide mounted',
  'Pinned',
  'Dried',
  'Frozen',
];

const List<String> defaultParasiteAnatomicalLocations = [
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

const List<String> defaultParasiteStorage = [
  'Vial',
  'Cryovial',
  'Slide',
  'Envelope',
  'Jar',
];

const List<String> defaultParasiteTreatments = [
  ...defaultTreatment,
  'RNAlater',
  'Glycerol',
];

/// Anatomical locations that fit each default parasite category, keyed by
/// lowercase category. Categories without an entry, such as parasitoids,
/// keep every location.
const Map<String, Set<String>> parasiteCategoryLocations = {
  'ectoparasite': {
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
  'endoparasite': {
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
  'mesoparasite': {'ear', 'nasal cavity', 'oral cavity', 'gill', 'skin'},
};

/// Narrows [options] to locations that fit [category]. Locations outside
/// every mapped category are user-defined and always kept.
List<String> filterAnatomicalLocations(
  Iterable<String> options,
  String? category,
) {
  final allowed = parasiteCategoryLocations[category?.trim().toLowerCase()];
  if (allowed == null) return List.unmodifiable(options);
  final mapped = parasiteCategoryLocations.values.expand((e) => e).toSet();
  return List.unmodifiable(
    options.where((option) {
      final key = option.trim().toLowerCase();
      return allowed.contains(key) || !mapped.contains(key);
    }),
  );
}

const parasiteAssociationStatuses = {1: 'Confirmed', 0: 'Suspected'};

const parasiteCatalogFormats = {
  CatalogFmt.mammalogy,
  CatalogFmt.ornithology,
  CatalogFmt.herpetology,
  CatalogFmt.ichthyology,
};

bool supportsParasites(CatalogFmt catalogFmt) =>
    parasiteCatalogFormats.contains(catalogFmt);
