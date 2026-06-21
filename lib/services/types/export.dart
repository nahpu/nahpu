import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

enum PdfExportType { narrative, specimen }

enum ExportFmt { csv, tsv, excel, json }

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
  'Excel (.xlsx)',
  'JSON (.json)',
];

enum DbExportFmt { sqlite3 }

const Map<DbExportFmt, String> dbExportFmt = {
  DbExportFmt.sqlite3: 'Database (.sqlite3)',
};

enum ReportFmt { csv, kml, geojson, topojson, shp }

const List<String> reportFmtList = [
  'Comma-separated (.csv)',
  'Keyhole Markup Language (.kml)',
  'GeoJSON (.geojson)',
  'TopoJSON (.topojson)',
  'Shapefile (.zip)',
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

enum SpecimenExportFmt {
  standard,
  allFields,
}

const List<String> specimenExportFmtList = [
  'Standard',
  'All fields',
];


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
  'specimen::specimenUUID',
  'specimen::cataloger',
  'specimen::fieldNumber',
  'specimen::preparator',
  'specimen::order',
  'specimen::family',
  'specimen::genus',
  'specimen::specificEpithet',
  'specimen::condition',
  'specimen::collectionTime',
  'specimen::preparationDate',
  'specimen::preparationTime',
  'specimen::specimenCoordinates',
];

const String partExportSimple = 'part::preparation';

const List<String> partExportListDelimited = [
  'part::tissueID',
  'part::barcodeID',
  'part::type',
  'part::count',
  'part::treatment',
  'part::additionalTreatment',
  'part::dateTaken',
  'part::timeTaken',
  'part::museumPermanent',
  'part::museumLoan',
  'part::remark',
];

const siteExportList = [
  'site::site',
  'site::habitatType',
  'site::country',
  'site::stateProvince',
  'site::county',
  'site::municipality',
  'site::specificLocality',
  'site::siteNotes',
  'site::verbatimLocality',
  'site::coordinates',
];

const mammalMeasurementExportList = [
  'measurement::totalLength',
  'measurement::tailLength',
  'measurement::hindFootLength',
  'measurement::earLength',
  'measurement::weight',
  'measurement::accuracy',
  'measurement::accuracySpecify',
  'measurement::sex',
  'measurement::age',
  'measurement::testisPosition',
  'measurement::testisLength',
  'measurement::testisWidth',
  'measurement::epididymisAppearance',
  'measurement::reproductiveStage',
  'measurement::leftPlacentalScars',
  'measurement::rightPlacentalScars',
  'measurement::mammaeCondition',
  'measurement::mammaeInguinalCount',
  'measurement::mammaeAxillaryCount',
  'measurement::mammaeAbdominalCount',
  'measurement::vaginaOpening',
  'measurement::pubicSymphysis',
  'measurement::embryoLeftCount',
  'measurement::embryoRightCount',
  'measurement::embryoCR',
  'measurement::remark',
];

const batMeasurementExportList = [
  'measurement::totalLength',
  'measurement::tailLength',
  'measurement::hindFootLength',
  'measurement::earLength',
  'measurement::forearm',
  'measurement::tibia',
  'measurement::echolocation',
  'measurement::frequencyMax',
  'measurement::frequencyMin',
  'measurement::frequencyAtMaxEnergy',
  'measurement::duration',
  'measurement::weight',
  'measurement::accuracy',
  'measurement::accuracySpecify',
  'measurement::sex',
  'measurement::age',
  'measurement::testisPosition',
  'measurement::testisLength',
  'measurement::testisWidth',
  'measurement::epididymisAppearance',
  'measurement::reproductiveStage',
  'measurement::leftPlacentalScars',
  'measurement::rightPlacentalScars',
  'measurement::mammaeCondition',
  'measurement::mammaeInguinalCount',
  'measurement::mammaeAxillaryCount',
  'measurement::mammaeAbdominalCount',
  'measurement::vaginaOpening',
  'measurement::pubicSymphysis',
  'measurement::embryoLeftCount',
  'measurement::embryoRightCount',
  'measurement::embryoCR',
  'measurement::remark',
];

const avianMeasurementExportList = [
  'measurement::weight',
  'measurement::wingspan',
  'measurement::irisColor',
  'measurement::irisHex',
  'measurement::billColor',
  'measurement::billHex',
  'measurement::footColor',
  'measurement::footHex',
  'measurement::tarsusColor',
  'measurement::tarsusHex',
  'measurement::sex',
  'measurement::broodPatch',
  'measurement::skullOssification',
  'measurement::hasBursa',
  'measurement::bursaWidth',
  'measurement::bursaLength',
  'measurement::fat',
  'measurement::stomachContent',
  'measurement::testisLength',
  'measurement::testisWidth',
  'measurement::testisRemark',
  'measurement::ovaryLength',
  'measurement::ovaryWidth',
  'measurement::oviductWidth',
  'measurement::ovaryAppearance',
  'measurement::firstOvaSize',
  'measurement::secondOvaSize',
  'measurement::thirdOvaSize',
  'measurement::oviductAppearance',
  'measurement::ovaryRemark',
  'measurement::wingIsMolt',
  'measurement::wingMolt',
  'measurement::tailIsMolt',
  'measurement::tailMolt',
  'measurement::bodyMolt',
  'measurement::moltRemark',
  'measurement::specimenRemark',
  'measurement::habitatRemark',
];

const herpMeasurementExportList = [
  'measurement::sex',
  'measurement::age',
  'measurement::weight',
  'measurement::svl',
  'measurement::remark',
];

const narrativeExportList = [
  'narrative::date',
  'narrative::verbatimLocality',
  'narrative::narrative',
  'media::media',
];

const collEventExportList = [
  'event::collEventID',
  'event::Activity',
  'event::startDate',
  'event::endDate',
  'event::startTime',
  'event::endTime',
  'event::methods',
  'event::personnel',
];

const allMediaExportList = [
  'media::category',
  'media::linkedData',
  'media::caption',
  'media::photographer',
  'media::tag',
  'media::dateTaken',
  'media::camera',
  'media::lenseModel',
  'media::additionalExifData',
  'media::fileName',
];
