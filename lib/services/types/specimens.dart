import 'package:material_ui/material_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/types/export.dart';
import 'nahpu_icons.dart';

enum CatalogFmt { mammals, birds, herpetofauna, arthropods }

enum SpecimenSex {
  male,
  female,
  unknown,
  gynandromorph,
  hermaphrodite,
  femaleUncertain,
  maleUncertain,
}

enum SpecimenSearchOption {
  all,
  fieldNumber,
  cataloger,
  preparator,
  collector,
  condition,
  prepDate,
  prepTime,
  taxa,
  prepType,
}

enum FieldIdMode { personnel, project }

const List<String> defaultIdMethods = [
  'morphology',
  'taxonomy',
  'genomics',
  'mtDNA',
  'unknown',
];

const List<String> defaultLifeStages = [
  'Egg',
  'Larva',
  'Nymph',
  'Pupa',
  'Neonate',
  'Juvenile',
  'Subadult',
  'Adult',
  'Metamorph',
  'Unknown',
];

/// Stable database codes for specimen sex.
///
/// DO NOT CHANGE THE KEYS.
/// The database uses these codes to store specimen sex, and changing them
/// would break existing records.
/// All reads and writes go through these maps rather than enum indexes.
const Map<int, SpecimenSex> specimenSexByCode = {
  0: SpecimenSex.male,
  1: SpecimenSex.female,
  2: SpecimenSex.unknown,
  3: SpecimenSex.gynandromorph,
  4: SpecimenSex.hermaphrodite,
  5: SpecimenSex.femaleUncertain,
  6: SpecimenSex.maleUncertain,
};

const Map<SpecimenSex, int> specimenSexCode = {
  SpecimenSex.male: 0,
  SpecimenSex.female: 1,
  SpecimenSex.unknown: 2,
  SpecimenSex.gynandromorph: 3,
  SpecimenSex.hermaphrodite: 4,
  SpecimenSex.femaleUncertain: 5,
  SpecimenSex.maleUncertain: 6,
};

const Map<SpecimenSex, String> specimenSexLabel = {
  SpecimenSex.male: 'Male',
  SpecimenSex.female: 'Female',
  SpecimenSex.unknown: 'Unknown',
  SpecimenSex.gynandromorph: 'Gynandromorph',
  SpecimenSex.hermaphrodite: 'Hermaphrodite',
  SpecimenSex.femaleUncertain: 'Female?',
  SpecimenSex.maleUncertain: 'Male?',
};

const Map<SpecimenSex, String> specimenSexLetter = {
  SpecimenSex.male: 'M',
  SpecimenSex.female: 'F',
  SpecimenSex.unknown: 'U',
  SpecimenSex.gynandromorph: 'G',
  SpecimenSex.hermaphrodite: 'H',
  SpecimenSex.femaleUncertain: 'F?',
  SpecimenSex.maleUncertain: 'M?',
};

const Map<SpecimenSex, String> specimenSexSymbol = {
  SpecimenSex.male: '\u2642',
  SpecimenSex.female: '\u2640',
  SpecimenSex.unknown: '?',
  SpecimenSex.gynandromorph: '\u2642/\u2640',
  SpecimenSex.hermaphrodite: '\u26A5',
  SpecimenSex.femaleUncertain: '\u2640?',
  SpecimenSex.maleUncertain: '\u2642?',
};

const List<SpecimenSex> defaultSpecimenSexes = [
  SpecimenSex.male,
  SpecimenSex.female,
  SpecimenSex.unknown,
];

const List<SpecimenSex> optionalSpecimenSexes = [
  SpecimenSex.gynandromorph,
  SpecimenSex.hermaphrodite,
  SpecimenSex.femaleUncertain,
  SpecimenSex.maleUncertain,
];

const List<SpecimenSex> allowedSpecimenSexes = [
  ...defaultSpecimenSexes,
  ...optionalSpecimenSexes,
];

List<String> get defaultSpecimenSexLabels => defaultSpecimenSexes
    .map((sex) => specimenSexLabel[sex]!)
    .toList(growable: false);

SpecimenSex? specimenSexFromConfigValue(String value) {
  final normalized = value.trim().toLowerCase();
  for (final sex in allowedSpecimenSexes) {
    if (sex.name.toLowerCase() == normalized ||
        specimenSexLabel[sex]!.toLowerCase() == normalized) {
      return sex;
    }
  }
  return null;
}

SpecimenSex? specimenSexFromDisplayValue(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  final code = int.tryParse(normalized);
  if (code != null) return specimenSexByCode[code];

  for (final sex in allowedSpecimenSexes) {
    if (sex.name.toLowerCase() == normalized ||
        specimenSexLabel[sex]!.toLowerCase() == normalized ||
        specimenSexLetter[sex]!.toLowerCase() == normalized ||
        specimenSexSymbol[sex]!.toLowerCase() == normalized) {
      return sex;
    }
  }
  return null;
}

List<SpecimenSex> normalizeSpecimenSexOptions(Iterable<String> values) {
  final configured = values
      .map(specimenSexFromConfigValue)
      .whereType<SpecimenSex>()
      .toSet();
  return [
    ...defaultSpecimenSexes,
    ...optionalSpecimenSexes.where(configured.contains),
  ];
}

String? canonicalizeCondition(String? value) {
  if (value == 'Freshly Euthanized') return 'Freshly euthanized';
  return value;
}

const List<String> defaultCondition = [
  'Freshly euthanized',
  'Good',
  'Fair',
  'Poor',
  'Rotten',
  'Released',
  'Unknown',
];

SpecimenSex? getSpecimenSex(int? sex) => specimenSexByCode[sex];

int getSpecimenSexCode(SpecimenSex sex) => specimenSexCode[sex]!;

String? getSpecimenSexLabel(int? code) {
  final sex = getSpecimenSex(code);
  return sex == null ? null : specimenSexLabel[sex];
}

extension SpecimenSexAttributes on SpecimenSex {
  bool get supportsMaleAttributes => switch (this) {
    SpecimenSex.male ||
    SpecimenSex.maleUncertain ||
    SpecimenSex.gynandromorph ||
    SpecimenSex.hermaphrodite => true,
    _ => false,
  };

  bool get supportsFemaleAttributes => switch (this) {
    SpecimenSex.female ||
    SpecimenSex.femaleUncertain ||
    SpecimenSex.gynandromorph ||
    SpecimenSex.hermaphrodite => true,
    _ => false,
  };
}

const List<String> defaultSpecimenType = [
  'Skin',
  'Skull',
  'Skeleton',
  'Liver',
  'Lung',
  'Heart',
  'Kidney',
];

const List<String> defaultTreatment = [
  'None',
  'ETOH',
  'Formalin',
  'LN2',
  'DMSO',
];

const List<String> priorityType = [
  'Alcohol',
  'Formalin',
  'Fluid',
  'Skin',
  'Skull',
  'Skeleton',
];

const List<String> priorityTreatment = [
  'None',
  'Formalin',
  'ETOH',
  'LN2',
  'DMSO',
];

const List<String> relativeTimeList = [
  'Dawn',
  'Morning',
  'Afternoon',
  'Dusk',
  'Night',
];

const List<String> idConfidenceList = ['Low', 'Medium', 'High'];

const List<String> taxonGroupList = [
  'Birds',
  'Mammals',
  'Herpetofauna',
  'Arthropods',
];

CatalogFmt matchTaxonGroupToCatFmt(String? taxonGroup) {
  switch (taxonGroup) {
    case 'Birds':
      return CatalogFmt.birds;
    case 'General Mammals':
    case 'Mammals':
      return CatalogFmt.mammals;
    case 'Herpetofauna':
      return CatalogFmt.herpetofauna;
    case 'Arthropods':
      return CatalogFmt.arthropods;
    default:
      return CatalogFmt.mammals;
  }
}

SpecimenRecordType matchCatalogFmtToRecordType(CatalogFmt catalogFmt) {
  switch (catalogFmt) {
    case CatalogFmt.birds:
      return SpecimenRecordType.birds;
    case CatalogFmt.mammals:
      return SpecimenRecordType.generalMammals;
    case CatalogFmt.herpetofauna:
      return SpecimenRecordType.herpetofauna;
    case CatalogFmt.arthropods:
      return SpecimenRecordType.arthropods;
  }
}

String matchRecordTypeToTaxonGroup(SpecimenRecordType recordType) {
  switch (recordType) {
    case SpecimenRecordType.birds:
      return 'Birds';
    case SpecimenRecordType.generalMammals:
      return 'General Mammals';
    case SpecimenRecordType.bats:
      return 'Bats';
    case SpecimenRecordType.herpetofauna:
      return 'Herpetofauna';
    case SpecimenRecordType.arthropods:
      return 'Arthropods';
    default:
      throw Exception('Invalid record type');
  }
}

SpecimenRecordType matchTaxonGroupToRecordType(String taxonGroup) {
  switch (taxonGroup) {
    case 'Birds':
      return SpecimenRecordType.birds;
    case 'General Mammals':
    case 'Mammals':
      return SpecimenRecordType.generalMammals;
    case 'Bats':
      return SpecimenRecordType.bats;
    case 'Herpetofauna':
      return SpecimenRecordType.herpetofauna;
    case 'Arthropods':
      return SpecimenRecordType.arthropods;
    default:
      return SpecimenRecordType.generalMammals;
  }
}

/// Persisted taxon-group value for [catalogFmt].
///
/// The result is written to `specimen.taxonGroup` and to the catalog-format
/// preference, and is matched by the custom-field triggers and the Darwin Core
/// bundle writer. Use [catalogFmtDisplayName] for anything shown to the user so
/// that renaming a format never rewrites stored records.
String matchCatFmtToTaxonGroup(CatalogFmt catalogFmt) {
  switch (catalogFmt) {
    case CatalogFmt.birds:
      return 'Birds';
    case CatalogFmt.mammals:
      return 'Mammals';
    case CatalogFmt.herpetofauna:
      return 'Herpetofauna';
    case CatalogFmt.arthropods:
      return 'Arthropods';
  }
}

/// User-facing name for [catalogFmt].
///
/// Deliberately separate from [matchCatFmtToTaxonGroup]: display names can
/// change with the terminology used in the documentation, while the persisted
/// value stays stable for existing projects and exports.
String catalogFmtDisplayName(CatalogFmt catalogFmt) {
  switch (catalogFmt) {
    case CatalogFmt.birds:
      return 'Birds';
    case CatalogFmt.mammals:
      return 'Mammals';
    case CatalogFmt.herpetofauna:
      return 'Herpetofauna';
    case CatalogFmt.arthropods:
      return 'Invertebrates';
  }
}

/// Whether [catalogFmt] is still in beta, and should be labelled as such in
/// the catalog-format pickers.
bool isCatalogFmtBeta(CatalogFmt catalogFmt) {
  switch (catalogFmt) {
    case CatalogFmt.birds:
    case CatalogFmt.mammals:
    case CatalogFmt.herpetofauna:
      return false;
    case CatalogFmt.arthropods:
      return true;
  }
}

IconData matchCatFmtToIcon(CatalogFmt catalogFmt, {bool isFilledIcon = false}) {
  switch (catalogFmt) {
    case CatalogFmt.birds:
      return isFilledIcon ? NahpuIcons.birdFilled : NahpuIcons.birdOutlined;
    case CatalogFmt.mammals:
      return isFilledIcon ? NahpuIcons.ratFilled : NahpuIcons.ratOutlined;
    case CatalogFmt.herpetofauna:
      return isFilledIcon ? NahpuIcons.frogFilled : NahpuIcons.frogOutlined;
    case CatalogFmt.arthropods:
      return isFilledIcon ? NahpuIcons.beetleFilled : NahpuIcons.beetleOutlined;
  }
}

const Map<String, String> partIconPath = {
  'cecum': 'assets/icons/cecum.svg',
  'feather': 'assets/icons/feather.svg',
  'feces': 'assets/icons/poo.svg',
  'liver': 'assets/icons/liver.svg',
  'lung': 'assets/icons/lungs.svg',
  'heart': 'assets/icons/heart.svg',
  'intestine': 'assets/icons/intestine.svg',
  'kidney': 'assets/icons/kidneys.svg',
  'muscle': 'assets/icons/muscles.svg',
  'swab': 'assets/icons/swab.svg',
  'stomach': 'assets/icons/stomach.svg',
  'parasite': 'assets/icons/mite.svg',
  'testis': 'assets/icons/testis.svg',
  'wing': 'assets/icons/wing.svg',
  'unknown': 'assets/icons/clue.svg',
};

String matchCatalogFmtToIconPath(CatalogFmt fmt) {
  switch (fmt) {
    case CatalogFmt.mammals:
      return 'assets/icons/mouse_outlined.svg';
    case CatalogFmt.birds:
      return 'assets/icons/bird_outlined.svg';
    case CatalogFmt.herpetofauna:
      return 'assets/icons/frog.svg';
    case CatalogFmt.arthropods:
      return 'assets/icons/beetle.svg';
  }
}

const List<String> specimenPartList = [
  'skin',
  'skull',
  'skeleton',
  'alcohol',
  'formalin',
  'whole-specimen',
];

/// Whole-specimen preparations that have their own icon per catalog format.
///
/// Checked before [specimenPartList], which otherwise collapses every
/// preparation onto the single whole-animal icon from
/// [matchCatalogFmtToIconPath]. A format missing an entry falls back to that
/// whole-animal icon rather than throwing, so partial coverage is safe.
const Map<CatalogFmt, Map<String, String>> preparationIconPath = {
  CatalogFmt.mammals: {
    'skin': 'assets/icons/mammal_skin.svg',
    'skull': 'assets/icons/mammal_skull.svg',
    'skeleton': 'assets/icons/mammal_skeleton.svg',
  },
  CatalogFmt.birds: {
    'skull': 'assets/icons/bird_skull.svg',
    'skeleton': 'assets/icons/bird_skeleton.svg',
  },
  CatalogFmt.herpetofauna: {
    'skull': 'assets/icons/herp_skull.svg',
    'skeleton': 'assets/icons/herp_skeleton.svg',
  },
};

class SpecimenPartIcon {
  const SpecimenPartIcon({required this.catalogFmt, required this.part});

  final String part;
  final CatalogFmt catalogFmt;

  String match() {
    final lowercased = _cleanPart();
    if (kDebugMode) print('Part: $part, Lowercased: $lowercased');
    final preparation = preparationIconPath[catalogFmt]?[lowercased];
    if (preparation != null) {
      return preparation;
    }
    bool isSpecimen = specimenPartList.contains(lowercased);
    if (isSpecimen) {
      return matchCatalogFmtToIconPath(catalogFmt);
    }

    return _matchTissues(lowercased);
  }

  String _matchTissues(String lowercased) {
    if (!lowercased.contains(' ')) {
      return partIconPath[lowercased] ?? partIconPath['unknown']!;
    }
    // Match possible keys with words separated by whitespace.
    List<String> availableKeys = partIconPath.keys.toList();
    List<String> words = lowercased.split(' ');

    List<String> matches = availableKeys
        .where((element) => words.contains(element))
        .toList();

    if (matches.isNotEmpty) {
      return partIconPath[matches.first] ?? partIconPath['unknown']!;
    } else {
      return partIconPath['unknown']!;
    }
  }

  String _cleanPart() {
    final lowercased = part.toLowerCase().trim();
    if (lowercased == 'testes' || lowercased == 'testis') {
      return 'testis';
    }
    if (lowercased.endsWith('s') || lowercased.endsWith('es')) {
      return lowercased.substring(0, lowercased.length - 1);
    }
    return lowercased;
  }
}
