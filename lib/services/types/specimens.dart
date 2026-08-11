import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/types/export.dart';
import 'nahpu_icons.dart';

enum CatalogFmt { mammals, birds, herpetofauna, arthropods }

// Database read through index.
// and stored as integer.
// DON'T CHANGE ORDER!
enum SpecimenSex { male, female, unknown }

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

const List<String> specimenSexList = ['Male', 'Female', 'Unknown'];

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

SpecimenSex? getSpecimenSex(int? sex) {
  if (sex != null) {
    return SpecimenSex.values[sex];
  }
  return null;
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
    case 'Arthropoda':
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
    case 'Arthropoda':
    case 'Arthropods':
      return SpecimenRecordType.arthropods;
    default:
      return SpecimenRecordType.generalMammals;
  }
}

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

IconData matchCatFmtToIcon(CatalogFmt catalogFmt, {bool isFilledIcon = false}) {
  switch (catalogFmt) {
    case CatalogFmt.birds:
      return isFilledIcon ? NahpuIcons.birdFilled : NahpuIcons.birdOutlined;
    case CatalogFmt.mammals:
      return isFilledIcon ? NahpuIcons.ratFilled : NahpuIcons.ratOutlined;
    case CatalogFmt.herpetofauna:
      return isFilledIcon
          ? NahpuIcons.amphibianFilled
          : NahpuIcons.amphibianOutlined;
    case CatalogFmt.arthropods:
      return isFilledIcon ? NahpuIcons.miteFilled : NahpuIcons.miteOutlined;
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
      return 'assets/icons/amphibian_outlined.svg';
    case CatalogFmt.arthropods:
      return 'assets/icons/mite.svg';
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
