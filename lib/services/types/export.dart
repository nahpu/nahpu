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

enum ConfigExportFmt { json, jsonl }

const Map<ConfigExportFmt, String> configExportFmt = {
  ConfigExportFmt.json: 'JSON (.json)',
  ConfigExportFmt.jsonl: 'JSON Lines (.json.nl)',
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

enum PdfPageFormat { a3, a4, a5, a6, letter, legal }

Map<PdfPageFormat, String> pdfExportPageFormat = {
  PdfPageFormat.a3: 'A3 (29.7 x 42.0 cm)',
  PdfPageFormat.a4: 'A4 (21.0 x 29.7 cm)',
  PdfPageFormat.a5: 'A5 (14.8 x 21.0 cm)',
  PdfPageFormat.a6: 'A6 (10.5 x 14.8 cm)',
  PdfPageFormat.letter: 'Letter (8.5 x 11.0 in)',
  PdfPageFormat.legal: 'Legal (8.5 x 14.0 in)',
};

enum PageOrientation { landscape, portrait }

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
  allTaxa,
}

enum SpecimenExportFmt {
  standard,
  allFields,
  selectFields,
}

const List<String> specimenExportFmtList = [
  'Standard',
  'All fields',
  'Custom fields',
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

enum RecordType {
  narrative,
  site,
  collEvent,
  specimenRecord,
  specimenParts,
  none
}

const List<String> recordTypeList = [
  'Narrative',
  'Sites',
  'Events',
  'Specimen records',
  'Specimen parts',
  'None',
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

/// How automatically generated export headers identify a source field.
enum ExportHeaderFormat { tableFieldName, fieldName }

/// The way a related, repeated record is represented in a flat export.
enum NestedExportMode { concatenate, spreadColumns, expandRows }

/// How a scalar field containing repeated values is flattened for export.
enum ListExportMode { concatenate, spreadColumns }

/// How a one-based index is added to an exported column name.
enum IndexedHeaderStyle { underscore, compact, brackets }

const int recordExportPresetSchemaVersion = 3;
const int _previousRecordExportPresetSchemaVersion = 2;

/// A single ordered output mapping in a record export preset.
///
/// Scalar mappings use [expression] exactly like a document text element: it
/// can contain full or short bracket placeholders and literal text. Nested
/// mappings use [nestedNamespace] and [nestedFields] to map repeated child
/// records.
class ExportFieldMapping {
  const ExportFieldMapping({
    required this.expression,
    this.headerOverride,
    this.textType = 'normal',
    this.formatOption = 'normal',
    this.caseFormat = 'normal',
    this.nullFallbackOption = 'blank',
    this.customNullFallbackText = '',
    this.nestedNamespace,
    this.nestedFields = const [],
    this.nestedMode = NestedExportMode.concatenate,
    this.listMode = ListExportMode.concatenate,
    this.indexedHeaderStyle = IndexedHeaderStyle.underscore,
    this.fieldSeparator = '|',
    this.recordSeparator = ';',
  });

  final String expression;
  final String? headerOverride;
  final String textType;
  final String formatOption;
  final String caseFormat;
  final String nullFallbackOption;
  final String customNullFallbackText;
  final String? nestedNamespace;
  final List<String> nestedFields;
  final NestedExportMode nestedMode;
  final ListExportMode listMode;
  final IndexedHeaderStyle indexedHeaderStyle;
  final String fieldSeparator;
  final String recordSeparator;

  bool get isNested => nestedNamespace != null;

  ExportFieldMapping copyWith({
    String? expression,
    String? headerOverride,
    bool clearHeaderOverride = false,
    String? textType,
    String? formatOption,
    String? caseFormat,
    String? nullFallbackOption,
    String? customNullFallbackText,
    String? nestedNamespace,
    bool clearNestedNamespace = false,
    List<String>? nestedFields,
    NestedExportMode? nestedMode,
    ListExportMode? listMode,
    IndexedHeaderStyle? indexedHeaderStyle,
    String? fieldSeparator,
    String? recordSeparator,
  }) {
    return ExportFieldMapping(
      expression: expression ?? this.expression,
      headerOverride:
          clearHeaderOverride ? null : (headerOverride ?? this.headerOverride),
      textType: textType ?? this.textType,
      formatOption: formatOption ?? this.formatOption,
      caseFormat: caseFormat ?? this.caseFormat,
      nullFallbackOption: nullFallbackOption ?? this.nullFallbackOption,
      customNullFallbackText:
          customNullFallbackText ?? this.customNullFallbackText,
      nestedNamespace: clearNestedNamespace
          ? null
          : (nestedNamespace ?? this.nestedNamespace),
      nestedFields: nestedFields ?? this.nestedFields,
      nestedMode: nestedMode ?? this.nestedMode,
      listMode: listMode ?? this.listMode,
      indexedHeaderStyle: indexedHeaderStyle ?? this.indexedHeaderStyle,
      fieldSeparator: fieldSeparator ?? this.fieldSeparator,
      recordSeparator: recordSeparator ?? this.recordSeparator,
    );
  }

  factory ExportFieldMapping.fromJson(Map<String, dynamic> json) {
    return ExportFieldMapping(
      expression: json['expression'] as String? ?? '',
      headerOverride: json['headerOverride'] as String?,
      textType: json['textType'] as String? ?? 'normal',
      formatOption: json['formatOption'] as String? ?? 'normal',
      caseFormat: json['caseFormat'] as String? ?? 'normal',
      nullFallbackOption: json['nullFallbackOption'] as String? ?? 'blank',
      customNullFallbackText: json['customNullFallbackText'] as String? ?? '',
      nestedNamespace: json['nestedNamespace'] as String?,
      nestedFields: List<String>.from(json['nestedFields'] as List? ?? []),
      nestedMode: NestedExportMode.values.byName(
        json['nestedMode'] as String? ?? NestedExportMode.concatenate.name,
      ),
      listMode: ListExportMode.values.byName(
        json['listMode'] as String? ?? ListExportMode.concatenate.name,
      ),
      indexedHeaderStyle: IndexedHeaderStyle.values.byName(
        json['indexedHeaderStyle'] as String? ??
            IndexedHeaderStyle.underscore.name,
      ),
      fieldSeparator: json['fieldSeparator'] as String? ?? '|',
      recordSeparator: json['recordSeparator'] as String? ?? ';',
    );
  }

  Map<String, dynamic> toJson() => {
        'expression': expression,
        if (headerOverride != null) 'headerOverride': headerOverride,
        'textType': textType,
        'formatOption': formatOption,
        'caseFormat': caseFormat,
        'nullFallbackOption': nullFallbackOption,
        'customNullFallbackText': customNullFallbackText,
        if (nestedNamespace != null) 'nestedNamespace': nestedNamespace,
        'nestedFields': nestedFields,
        'nestedMode': nestedMode.name,
        'listMode': listMode.name,
        'indexedHeaderStyle': indexedHeaderStyle.name,
        'fieldSeparator': fieldSeparator,
        'recordSeparator': recordSeparator,
      };
}

/// A complete, versioned configuration for one record export.
class ExportPresetModel {
  const ExportPresetModel({
    required this.recordType,
    required this.specimenRecordType,
    required this.headerFormat,
    required this.mappings,
    this.schemaVersion = recordExportPresetSchemaVersion,
  });

  final int schemaVersion;
  final RecordType recordType;
  final SpecimenRecordType specimenRecordType;
  final ExportHeaderFormat headerFormat;
  final List<ExportFieldMapping> mappings;

  factory ExportPresetModel.empty() => const ExportPresetModel(
        recordType: RecordType.specimenRecord,
        specimenRecordType: SpecimenRecordType.allTaxa,
        headerFormat: ExportHeaderFormat.tableFieldName,
        mappings: [],
      );

  factory ExportPresetModel.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'] as int?;
    if (schemaVersion != recordExportPresetSchemaVersion &&
        schemaVersion != _previousRecordExportPresetSchemaVersion) {
      throw const FormatException('Unsupported record export preset schema.');
    }
    return ExportPresetModel(
      schemaVersion: recordExportPresetSchemaVersion,
      recordType: parseRecordType(json['recordType'] as String?),
      specimenRecordType: SpecimenRecordType.values.byName(
        json['specimenRecordType'] as String? ??
            SpecimenRecordType.allTaxa.name,
      ),
      headerFormat: ExportHeaderFormat.values.byName(
        json['headerFormat'] as String? ??
            ExportHeaderFormat.tableFieldName.name,
      ),
      mappings: (json['mappings'] as List? ?? [])
          .map((value) => ExportFieldMapping.fromJson(
              Map<String, dynamic>.from(value as Map)))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'recordType': recordTypeToString(recordType),
        'specimenRecordType': specimenRecordType.name,
        'headerFormat': headerFormat.name,
        'mappings': mappings.map((mapping) => mapping.toJson()).toList(),
      };
}

RecordType parseRecordType(String? value) {
  if (value == null) return RecordType.specimenRecord;
  if (value == 'specimen') return RecordType.specimenRecord;
  for (final val in RecordType.values) {
    if (val.name == value) return val;
  }
  return RecordType.specimenRecord;
}

String recordTypeToString(RecordType type) {
  if (type == RecordType.specimenRecord) {
    return 'specimen';
  }
  return type.name;
}
