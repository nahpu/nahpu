enum TaxonEntryHeader {
  taxonClass,
  taxonOrder,
  taxonFamily,
  genus,
  specificEpithet,
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

enum MediaCategory { site, narrative, specimen, personnel, all }

/// Returns the string representation of the media category
String matchMediaCategory(MediaCategory category) {
  switch (category) {
    case MediaCategory.site:
      return 'site';
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
    case 'narrative':
      return MediaCategory.narrative;
    case 'specimen':
      return MediaCategory.specimen;
    default:
      return MediaCategory.site;
  }
}

const List<String> mediaCategory = [
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
