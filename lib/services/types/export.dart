import 'package:nahpu/services/conditional_brackets.dart';
import 'package:nahpu/services/specimen_attribute_names.dart';

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

enum DbArchiveFormat { zip, tarGzip }

extension DbArchiveFormatLabel on DbArchiveFormat {
  String get label => switch (this) {
    DbArchiveFormat.zip => 'ZIP (.zip)',
    DbArchiveFormat.tarGzip => 'TAR.GZ (.tar.gz)',
  };

  String get extension => switch (this) {
    DbArchiveFormat.zip => 'zip',
    DbArchiveFormat.tarGzip => 'tar.gz',
  };
}

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

enum SpecimenExportFmt { standard, allFields, selectFields }

const List<String> specimenExportFmtList = [
  'Standard',
  'All fields',
  'Custom fields',
];

enum TaxonRecordType { birds, mammals, herps }

const List<String> taxonRecordTypeList = ['Birds', 'Mammals', 'Herpetofauna'];

enum MammalRecordType { excludeBats, onlyBats, allMammals }

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
  none,
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

const mammalAttributeExportList = [
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

const batAttributeExportList = [
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

const birdAttributeExportList = [
  'measurement::weight',
  'measurement::wingspan',
  'measurement::irisColor',
  'measurement::irisHex',
  'measurement::billColor',
  'measurement::billHex',
  'measurement::maxillaColor',
  'measurement::maxillaHex',
  'measurement::mandibleColor',
  'measurement::mandibleHex',
  'measurement::toeColor',
  'measurement::toeHex',
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

const herpAttributeExportList = [
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
enum ExportHeaderFormat {
  tableFieldName,
  fieldName,
  darwinCore,
  nahpuNamespace,
}

/// The way a related, repeated record is represented in a flat export.
enum NestedExportMode { concatenate, spreadColumns, expandRows }

/// How a scalar field containing repeated values is flattened for export.
enum ListExportMode { concatenate, spreadColumns }

/// How a one-based index is added to an exported column name.
enum IndexedHeaderStyle { underscore, compact, brackets }

const int recordExportPresetSchemaVersion = 8;
const Set<int> _supportedRecordExportPresetSchemaVersions = {
  2,
  3,
  4,
  5,
  6,
  7,
  8,
};

/// Scalar export format that conditionally wraps a populated value in brackets.
const String kConditionalBracketExportTextType = 'conditionalBrackets';

/// One visual segment of a scalar export expression.
///
/// The persisted representation remains the established template expression,
/// such as `[personnel::initial]-[specimen::fieldNumber]`. Segments exist only
/// to make that expression editable without requiring users to type brackets.
class ExportExpressionSegment {
  const ExportExpressionSegment.field(this.value) : isField = true;
  const ExportExpressionSegment.text(this.value) : isField = false;

  final String value;
  final bool isField;
}

/// Splits an export expression into ordered field and literal-text segments.
///
/// An unmatched `[` is treated as literal text so existing advanced
/// expressions are not discarded by the visual composer.
List<ExportExpressionSegment> parseExportExpression(String expression) {
  final segments = <ExportExpressionSegment>[];
  var cursor = 0;
  while (cursor < expression.length) {
    final start = expression.indexOf('[', cursor);
    if (start == -1) {
      if (cursor < expression.length) {
        segments.add(
          ExportExpressionSegment.text(expression.substring(cursor)),
        );
      }
      break;
    }
    if (start > cursor) {
      segments.add(
        ExportExpressionSegment.text(expression.substring(cursor, start)),
      );
    }
    final end = expression.indexOf(']', start + 1);
    if (end == -1) {
      segments.add(ExportExpressionSegment.text(expression.substring(start)));
      break;
    }
    final field = expression.substring(start + 1, end).trim();
    if (field.isEmpty) {
      segments.add(
        ExportExpressionSegment.text(expression.substring(start, end + 1)),
      );
    } else {
      segments.add(ExportExpressionSegment.field(field));
    }
    cursor = end + 1;
  }
  return segments;
}

/// Serializes visual expression segments into the backwards-compatible
/// template expression used by the exporter.
String serializeExportExpression(Iterable<ExportExpressionSegment> segments) =>
    segments
        .map(
          (segment) => segment.isField ? '[${segment.value}]' : segment.value,
        )
        .join();

bool isDirectExportSourceExpression(String expression) {
  return RegExp(r'^\s*\[[^\]]+\]\s*$').hasMatch(expression);
}

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
    this.bracketConditions = const [],
    this.bracketConditionMode = ConditionalMatchMode.any,
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

  /// Conditions used when [textType] is [kConditionalBracketExportTextType].
  final List<ConditionalBracketCondition> bracketConditions;

  /// Whether [bracketConditions] are combined with OR or AND semantics.
  final ConditionalMatchMode bracketConditionMode;

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
    List<ConditionalBracketCondition>? bracketConditions,
    ConditionalMatchMode? bracketConditionMode,
  }) {
    return ExportFieldMapping(
      expression: expression ?? this.expression,
      headerOverride: clearHeaderOverride
          ? null
          : (headerOverride ?? this.headerOverride),
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
      bracketConditions: bracketConditions ?? this.bracketConditions,
      bracketConditionMode: bracketConditionMode ?? this.bracketConditionMode,
    );
  }

  factory ExportFieldMapping.fromJson(Map<String, dynamic> json) {
    return ExportFieldMapping(
      expression: canonicalizeSpecimenAttributeExpression(
        json['expression'] as String? ?? '',
      ),
      headerOverride: json['headerOverride'] as String?,
      textType: json['textType'] as String? ?? 'normal',
      formatOption: json['formatOption'] as String? ?? 'normal',
      caseFormat: json['caseFormat'] as String? ?? 'normal',
      nullFallbackOption: json['nullFallbackOption'] as String? ?? 'blank',
      customNullFallbackText: json['customNullFallbackText'] as String? ?? '',
      nestedNamespace: switch (json['nestedNamespace']) {
        final String value => canonicalizeSpecimenAttributeTableName(value),
        _ => null,
      },
      nestedFields: List<String>.from(
        json['nestedFields'] as List? ?? [],
      ).map(canonicalizeSpecimenAttributeSourceKey).toList(growable: false),
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
      bracketConditions: (json['bracketConditions'] as List? ?? [])
          .whereType<Map>()
          .map(
            (value) => ConditionalBracketCondition.fromJson(
              Map<String, dynamic>.from(value),
            ),
          )
          .toList(growable: false),
      bracketConditionMode: ConditionalMatchMode.values.byName(
        json['bracketConditionMode'] as String? ??
            ConditionalMatchMode.any.name,
      ),
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
    'bracketConditions': bracketConditions
        .map((condition) => condition.toJson())
        .toList(),
    'bracketConditionMode': bracketConditionMode.name,
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
    if (!_supportedRecordExportPresetSchemaVersions.contains(schemaVersion)) {
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
          .map(
            (value) => ExportFieldMapping.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
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
