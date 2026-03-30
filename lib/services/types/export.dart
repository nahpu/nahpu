import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

enum PdfExportType { narrative, specimen }

enum ExportFmt { csv, tsv }

const List<String> supportedTaxonClass = [
  'Mammalia',
  'Aves',
  'Reptilia',
  'Amphibia',
  // Bony fishes
  'Osteichthyes',
  // Cartilaginous fishes
  'Chondrichthyes',
  // Jawless fishes
  'Agnatha',
];

const Map<PdfExportType, String> pdfExport = {
  PdfExportType.narrative: 'Narrative',
  PdfExportType.specimen: 'Specimen records',
};

const List<String> exportFormats = [
  'Comma-separated (.csv)',
  'Tab-separated (.tsv)',
];

enum DbExportFmt { sqlite3 }

const Map<DbExportFmt, String> dbExportFmt = {
  DbExportFmt.sqlite3: 'Database (.sqlite3)',
};

enum ReportFmt { csv, kml }

const List<String> reportFmtList = [
  'Comma-separated (.csv)',
  'Keyhole Markup Language (.kml)',
];

enum ReportType { speciesCount, mediaData, coordinate }

const List<String> reportTypeList = [
  'Species count ',
  'Media data',
  'Coordinates',
];

enum ArchiveFmt { zip }

Map<PdfPageFormat, String> pdfExportPageFormat = {
  PdfPageFormat.a3: 'A3 (29.7 x 42.0 cm)',
  PdfPageFormat.a4: 'A4 (21.0 x 29.7 cm)',
  PdfPageFormat.a5: 'A5 (14.8 x 21.0 cm)',
  PdfPageFormat.a6: 'A6 (10.5 x 14.8 cm)',
  PdfPageFormat.letter: 'Letter (8.5 x 11.0 in)',
  PdfPageFormat.legal: 'Legal (8.5 x 14.0 in)',
};

Map<PageOrientation, String> pdfExportOrientation = {
  PageOrientation.landscape: 'Landscape',
  PageOrientation.portrait: 'Portrait',
};

enum SpecimenRecordType {
  birds,
  generalMammals,
  bats,
  allMammals,
  herpetofauna,
}

enum TaxonRecordType {
  birds,
  mammals,
  herps,
}

const List<String> taxonRecordTypeList = [
  'Birds',
  'Mammals',
  'Herpetofauna',
];

enum MammalRecordType {
  excludeBats,
  onlyBats,
  allMammals,
}

const List<String> mammalGroupList = [
  'Exclude bats',
  'Only bats',
  'All mammals',
];

enum ExportRecordType {
  narrative,
  site,
  collEvent,
  specimenRecord,
  specimenParts
}

const List<String> recordTypeList = [
  'Narrative',
  'Sites',
  'Events',
  'Specimen records',
  'Specimen parts',
];

const collectingRecordExportList = [
  'specimenUUID',
  'cataloger',
  'fieldNumber',
  'preparator',
  'order',
  'family',
  'genus',
  'specificEpithet',
  'condition',
  'collectionTime',
  'preparationDate',
  'preparationTime',
  'specimenCoordinates',
];

const String partExportSimple = 'preparation';

const List<String> partExportListDelimited = [
  'tissueID',
  'barcodeID',
  'type',
  'count',
  'treatment',
  'additionalTreatment',
  'dateTaken',
  'timeTaken',
  'museumPermanent',
  'museumLoan',
  'remark',
];

const siteExportList = [
  'site',
  'habitatType',
  'country',
  'stateProvince',
  'county',
  'municipality',
  'specificLocality',
  'siteNotes',
  'verbatimLocality',
  'coordinates',
];

const mammalMeasurementExportList = [
  'totalLength',
  'tailLength',
  'hindFootLength',
  'earLength',
  'weight',
  'accuracy',
  'age',
  'sex',
  'testisPos',
  'testisSize',
  'ovaryOpening',
  'mammaeCondition',
  'mammaeFormula',
  'remark',
];

const batMeasurementExportList = [
  'totalLength',
  'tailLength',
  'hindFootLength',
  'earLength',
  'weight',
  'accuracy',
  'forearmLength',
  'age',
  'sex',
  'testisPos',
  'testisSize',
  'ovaryOpening',
  'mammaeCondition',
  'mammaeFormula',
  'remark',
];

const avianMeasurementExportList = [
  'weight',
  'wingspan',
  'irisColor',
  'billColor',
  'footColor',
  'tarsusColor',
  'sex',
  // Male gonad
  'testisSize',
  'testisRemark',
  // Female gonad
  'ovarySize',
  'ovaryAppearance',
  'oviductWidth',
  'ovaSize',
  'oviductAppearance',
  'ovaryRemark',
  // End gonad data
  'broodPatch',
  'percentSkullOssification',
  'bursaLength',
  'fat',
  'stomachContent',
  // Molt
  'wingIsMolt',
  'wingMolt',
  'tailIsMolt',
  'tailMolt',
  'bodyMolt',
  'moltRemark',
  // Notes
  'specimenRemark',
  'habitatRemark',
];

const herpMeasurementExportList = [
  'sex',
  'age',
  'weight',
  'svl',
  'remark',
];

const narrativeExportList = [
  'date',
  'verbatimLocality',
  'narrative',
  'media',
];

const collEventExportList = [
  'collEventID',
  'Activity',
  'startDate',
  'endDate',
  'startTime',
  'endTime',
  'methods',
  'personnel',
];

const allMediaExportList = [
  'category',
  'linkedData',
  'caption',
  'photographer',
  'tag',
  'dateTaken',
  'camera',
  'lenseModel',
  'additionalExifData',
  'fileName',
];
