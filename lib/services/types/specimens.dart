import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nahpu/services/types/export.dart';

enum CatalogFmt { mammals, birds, herpetofauna, fossils }

enum ProjectType { extantTaxa, fossils }

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
  prepType
}

const List<String> specimenSexList = [
  'Male',
  'Female',
  'Unknown',
];

const List<String> conditionList = [
  'Freshly Euthanized',
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

const List<String> idConfidenceList = [
  'Low',
  'Medium',
  'High',
];

const List<String> extantTaxaGroupList = [
  'Birds',
  'Mammals',
  'Herpetofauna',
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
    case 'Fossils':
      return CatalogFmt.fossils;
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
    case CatalogFmt.fossils:
      return SpecimenRecordType.fossils;
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
    case CatalogFmt.fossils:
      return 'Fossils';
  }
}

IconData matchCatFmtToPartIcon(CatalogFmt catalogFmt) {
  switch (catalogFmt) {
    case CatalogFmt.birds:
      return MdiIcons.owl;
    case CatalogFmt.mammals:
      return MdiIcons.pawOutline;
    case CatalogFmt.herpetofauna:
      return MdiIcons.snake;
    case CatalogFmt.fossils:
      return MdiIcons.bone;
  }
}

IconData matchCatFmtToIcon(CatalogFmt catalogFmt, bool isSelected) {
  switch (catalogFmt) {
    case CatalogFmt.birds:
      return MdiIcons.owl;
    case CatalogFmt.mammals:
      return isSelected ? MdiIcons.paw : MdiIcons.pawOutline;
    case CatalogFmt.herpetofauna:
      return MdiIcons.snake;
    case CatalogFmt.fossils:
      return MdiIcons.bone;
  }
}

const Map<String, String> partIconPath = {
  'cecum': 'assets/icons/microbial-culture.svg',
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
      return 'assets/icons/mouse.svg';
    case CatalogFmt.birds:
      return 'assets/icons/bird.svg';
    case CatalogFmt.herpetofauna:
      return 'assets/icons/snake.svg';
    case CatalogFmt.fossils:
      return 'assets/icons/clue.svg'; // TODO: Placeholder
  }
}

const List<String> specimenPartList = [
  'skin',
  'skull',
  'skeleton',
  'alcohol',
  'formalin',
  'whole-specimen'
];

class SpecimenPartIcon {
  const SpecimenPartIcon({required this.catalogFmt, required this.part});

  final String part;
  final CatalogFmt catalogFmt;

  String match() {
    final lowercased = _cleanPart();
    if (kDebugMode) print('Part: $part, Lowercased: $lowercased');
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

    List<String> matches =
        availableKeys.where((element) => words.contains(element)).toList();

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
      return lowercased.substring(0, part.length - 1).toLowerCase();
    }
    return lowercased;
  }
}
