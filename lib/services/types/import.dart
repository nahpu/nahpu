enum TaxonEntryHeader {
  taxonRank,
  kingdom,
  phylum,
  taxonClass,
  taxonOrder,
  taxonFamily,
  genus,
  specificEpithet,
  subspecificEpithet,
  authors,
  commonName,
  redListCategory,
  citesStatus,
  countryStatus,
  sortingOrder,
  notes,
  ignore,
}

String matchTaxonEntryHeader(TaxonEntryHeader headerEnum) {
  switch (headerEnum) {
    case TaxonEntryHeader.taxonRank:
      return 'Taxon rank';
    case TaxonEntryHeader.kingdom:
      return 'Kingdom';
    case TaxonEntryHeader.phylum:
      return 'Phylum';
    case TaxonEntryHeader.taxonClass:
      return 'Class';
    case TaxonEntryHeader.taxonOrder:
      return 'Order';
    case TaxonEntryHeader.taxonFamily:
      return 'Family';
    case TaxonEntryHeader.genus:
      return 'Genus';
    case TaxonEntryHeader.specificEpithet:
      return 'Specific epithet';
    case TaxonEntryHeader.subspecificEpithet:
      return 'Subspecific epithet';
    case TaxonEntryHeader.authors:
      return 'Authors';
    case TaxonEntryHeader.commonName:
      return 'Common name';
    case TaxonEntryHeader.redListCategory:
      return 'IUCN Category';
    case TaxonEntryHeader.citesStatus:
      return 'CITES status';
    case TaxonEntryHeader.countryStatus:
      return 'Country status';
    case TaxonEntryHeader.sortingOrder:
      return 'Sorting order';
    case TaxonEntryHeader.notes:
      return 'Notes';
    case TaxonEntryHeader.ignore:
      return 'Ignore';
  }
}

const Map<String, TaxonEntryHeader> knownTaxonHeader = {
  'taxonrank': TaxonEntryHeader.taxonRank,
  'rank': TaxonEntryHeader.taxonRank,
  'kingdom': TaxonEntryHeader.kingdom,
  'phylum': TaxonEntryHeader.phylum,
  'taxonclass': TaxonEntryHeader.taxonClass,
  'class': TaxonEntryHeader.taxonClass,
  'taxonorder': TaxonEntryHeader.taxonOrder,
  'order': TaxonEntryHeader.taxonOrder,
  'taxonfamily': TaxonEntryHeader.taxonFamily,
  'family': TaxonEntryHeader.taxonFamily,
  'genus': TaxonEntryHeader.genus,
  'specificepithet': TaxonEntryHeader.specificEpithet,
  'epithet': TaxonEntryHeader.specificEpithet,
  'species': TaxonEntryHeader.specificEpithet,
  'subspecificepithet': TaxonEntryHeader.subspecificEpithet,
  'infraspecificepithet': TaxonEntryHeader.subspecificEpithet,
  'subspecies': TaxonEntryHeader.subspecificEpithet,
  'author': TaxonEntryHeader.authors,
  'authors': TaxonEntryHeader.authors,
  'commonname': TaxonEntryHeader.commonName,
  'vernacularname': TaxonEntryHeader.commonName,
  'englishname': TaxonEntryHeader.commonName,
  'citesstatus': TaxonEntryHeader.citesStatus,
  'appendixstatus': TaxonEntryHeader.citesStatus,
  'redlistcategory': TaxonEntryHeader.redListCategory,
  'iucncategory': TaxonEntryHeader.redListCategory,
  'iucnstatus': TaxonEntryHeader.redListCategory,
  'redliststatus': TaxonEntryHeader.redListCategory,
  'countrystatus': TaxonEntryHeader.countryStatus,
  'sortingorder': TaxonEntryHeader.sortingOrder,
  'notes': TaxonEntryHeader.notes,
  'note': TaxonEntryHeader.notes,
};

const List<TaxonEntryHeader> requiredTaxonImportHeaders = [
  TaxonEntryHeader.taxonClass,
  TaxonEntryHeader.taxonOrder,
  TaxonEntryHeader.taxonFamily,
  TaxonEntryHeader.genus,
  TaxonEntryHeader.specificEpithet,
];

const List<TaxonEntryHeader> taxonImportRankHeaders = [
  TaxonEntryHeader.taxonClass,
  TaxonEntryHeader.taxonOrder,
  TaxonEntryHeader.taxonFamily,
  TaxonEntryHeader.genus,
  TaxonEntryHeader.specificEpithet,
  TaxonEntryHeader.subspecificEpithet,
];

/// Classes whose higher classification NAHPU can supply during an import.
/// Keep this explicit: an unrecognized class must never default to Chordata.
enum InferableTaxonClass {
  mammalia('Mammalia', 'Chordata'),
  aves('Aves', 'Chordata'),
  reptilia('Reptilia', 'Chordata'),
  amphibia('Amphibia', 'Chordata'),
  osteichthyes('Osteichthyes', 'Chordata'),
  chondrichthyes('Chondrichthyes', 'Chordata'),
  agnatha('Agnatha', 'Chordata'),
  insecta('Insecta', 'Arthropoda'),
  arachnida('Arachnida', 'Arthropoda'),
  chilopoda('Chilopoda', 'Arthropoda'),
  diplopoda('Diplopoda', 'Arthropoda'),
  gastropoda('Gastropoda', 'Mollusca'),
  bivalvia('Bivalvia', 'Mollusca'),
  cephalopoda('Cephalopoda', 'Mollusca');

  const InferableTaxonClass(this.label, this.phylum);

  final String label;
  final String phylum;

  String get kingdom => 'Animalia';

  static InferableTaxonClass? fromString(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final taxonClass in values) {
      if (taxonClass.label.toLowerCase() == normalized) return taxonClass;
    }
    return null;
  }
}

const taxonImportRequiredColumnsGuidance =
    'If your class is not listed or the file contains multiple classes, '
    'include Taxon rank, Kingdom, Phylum, Class, and every classification '
    'column through the selected rank (Order, Family, Genus, Specific epithet, '
    'and Subspecific epithet as applicable), with values in every required cell.';

enum MediaCategory { site, event, narrative, specimen, personnel, all }

/// Returns the string representation of the media category
String matchMediaCategory(MediaCategory category) {
  switch (category) {
    case MediaCategory.site:
      return 'site';
    case MediaCategory.event:
      return 'event';
    case MediaCategory.narrative:
      return 'narrative';
    case MediaCategory.specimen:
      return 'specimen';
    case MediaCategory.personnel:
      return 'personnel';
    default:
      return 'site';
  }
}

MediaCategory matchMediaCategoryString(String category) {
  switch (category) {
    case 'site':
      return MediaCategory.site;
    case 'event':
      return MediaCategory.event;
    case 'narrative':
      return MediaCategory.narrative;
    case 'specimen':
      return MediaCategory.specimen;
    case 'personnel':
      return MediaCategory.personnel;
    case 'all':
      return MediaCategory.all;
    default:
      return MediaCategory.site;
  }
}

const List<String> mediaCategory = [
  'event',
  'narrative',
  'site',
  'specimen',
  'personnel',
];

const List<String> mediaSiteSubcategory = [
  'camp',
  'habitat',
  'people',
  'other',
];
