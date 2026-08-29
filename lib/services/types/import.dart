enum TaxonEntryHeader {
  taxonRank,
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
