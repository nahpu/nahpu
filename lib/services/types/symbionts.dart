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

/// List icon for each default interaction type, keyed by lowercase name.
const Map<String, String> symbiontInteractionIconPath = {
  'parasitic': 'assets/icons/symbiont_parasitic.svg',
  'parasitoid': 'assets/icons/symbiont_parasitoid.svg',
  'mutualistic': 'assets/icons/symbiont_mutualistic.svg',
  'commensal': 'assets/icons/symbiont_commensal.svg',
  'phoretic': 'assets/icons/symbiont_phoretic.svg',
  'unknown': 'assets/icons/symbiont_unknown.svg',
};

/// Shown when a symbiont has no interaction type or a user-defined one.
const String symbiontFallbackIconPath = 'assets/icons/mite.svg';

/// Noun forms of the default interaction types, keyed by lowercase name.
const Map<String, String> _symbiontInteractionAliases = {
  'parasitism': 'parasitic',
  'parasite': 'parasitic',
  'parasitoidism': 'parasitoid',
  'mutualism': 'mutualistic',
  'commensalism': 'commensal',
  'phoresy': 'phoretic',
  'phoresis': 'phoretic',
};

/// Maps an `organismInteractionType` value to its default lowercase name,
/// accepting noun forms such as `Parasitism`. Null for empty or custom values.
String? resolveSymbiontInteraction(String? interactionType) {
  final key = interactionType?.trim().toLowerCase() ?? '';
  final resolved = _symbiontInteractionAliases[key] ?? key;
  return symbiontInteractionIconPath.containsKey(resolved) ? resolved : null;
}

/// Resolves the list icon for an `organismInteractionType` value. Accepts
/// the noun forms too, e.g. `Parasitism` for `Parasitic`.
String matchSymbiontInteractionIcon(String? interactionType) {
  return symbiontInteractionIconPath[resolveSymbiontInteraction(
        interactionType,
      )] ??
      symbiontFallbackIconPath;
}

/// Interactions where the host is harmed, the only ones with a category.
const Set<String> parasiticInteractionTypes = {'parasitic', 'parasitoid'};

/// Whether a symbiont with [interactionType] records a category.
bool interactionHasCategory(String? interactionType) =>
    parasiticInteractionTypes.contains(
      resolveSymbiontInteraction(interactionType),
    );

/// The category to save. Records without an interaction keep theirs, since
/// older and imported records may carry a category alone.
String? categoryForInteraction(String? interactionType, String? category) {
  if (interactionType?.trim().isNotEmpty != true) return category;
  return interactionHasCategory(interactionType) ? category : null;
}
