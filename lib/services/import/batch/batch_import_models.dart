import 'package:nahpu/services/data_table/data_table_models.dart';

/// What a batch import does with each file row.
enum BatchImportMode {
  update('Update existing records'),
  create('Import new records');

  const BatchImportMode(this.label);

  final String label;
}

/// How file columns are matched to NAHPU fields.
enum BatchImportHeaderMode {
  /// Darwin Core terms first, then column names.
  auto('Auto'),

  /// Darwin Core terms only, such as `catalogNumber` or `decimalLatitude`.
  darwinCore('Darwin Core'),

  /// Column names only, matched loosely.
  names('Column names');

  const BatchImportHeaderMode(this.label);

  final String label;
}

/// A table read from a CSV, TSV, or Excel file.
class BatchImportTable {
  const BatchImportTable({
    required this.fileName,
    required this.headers,
    required this.rows,
    required this.rowNumbers,
    this.sheetName,
    this.sheetNames = const [],
  });

  final String fileName;
  final List<String> headers;

  /// Data rows, each as long as [headers].
  final List<List<String>> rows;

  /// The file's line or sheet row number of each row in [rows], for messages.
  final List<int> rowNumbers;

  /// The worksheet read, for Excel files.
  final String? sheetName;
  final List<String> sheetNames;

  /// Up to [count] values of [column], skipping blanks.
  List<String> samples(int column, {int count = 3}) => [
    for (final row in rows)
      if (row[column].isNotEmpty) row[column],
  ].take(count).toList();
}

/// Why a column maps to the field it does.
enum BatchMatchOrigin {
  darwinCore,
  exactName,
  fuzzyName,

  /// A choice the user made for this header set before.
  saved,
  user,
  none,
}

/// The field one file column maps to.
class BatchColumnMatch {
  const BatchColumnMatch({
    required this.column,
    required this.header,
    this.fieldKey,
    this.origin = BatchMatchOrigin.none,
    this.score = 0,
  });

  final int column;
  final String header;

  /// The target field, or null when the column is skipped.
  final String? fieldKey;
  final BatchMatchOrigin origin;

  /// How closely a fuzzy name matched, from 0 to 1.
  final double score;

  BatchColumnMatch withField(String? fieldKey) => BatchColumnMatch(
    column: column,
    header: header,
    fieldKey: fieldKey,
    origin: BatchMatchOrigin.user,
    score: 1,
  );
}

/// What identifies an existing record in a file row.
enum BatchImportKey {
  specimenUuid(DataTableRecordType.specimenRecords, 'Specimen UUID', [
    'specimen::specimenUUID',
  ]),
  catalogNumber(DataTableRecordType.specimenRecords, 'Catalog number', [
    batchCatalogNumberKey,
  ]),
  catalogerFieldNumber(
    DataTableRecordType.specimenRecords,
    'Cataloger and field number',
    ['specimen::cataloger', 'specimen::fieldNumber'],
  ),
  tissueId(DataTableRecordType.specimenParts, 'Tissue ID', ['part::tissueID']),
  barcodeId(DataTableRecordType.specimenParts, 'Barcode ID', [
    'part::barcodeID',
  ]),
  siteId(DataTableRecordType.sites, 'Site ID', ['site::site']),
  eventId(DataTableRecordType.events, 'Event ID', ['event::collEventID']),
  narrativeDate(DataTableRecordType.narrative, 'Narrative date', [
    'narrative::date',
  ]);

  const BatchImportKey(this.recordType, this.label, this.fieldKeys);

  final DataTableRecordType recordType;
  final String label;

  /// Fields that must all be mapped for this key to be usable.
  final List<String> fieldKeys;

  static List<BatchImportKey> forType(DataTableRecordType type) => [
    for (final key in values)
      if (key.recordType == type) key,
  ];

  /// Keys of [type] whose fields are all mapped.
  static List<BatchImportKey> available(
    DataTableRecordType type,
    Iterable<String?> mappedKeys,
  ) {
    final mapped = mappedKeys.whereType<String>().toSet();
    return [
      for (final key in forType(type))
        if (key.fieldKeys.every(mapped.contains)) key,
    ];
  }
}

/// A full catalog number, as printed on labels and exported to Darwin Core.
const batchCatalogNumberKey = 'batch::catalogNumber';

/// A binomial, split into genus and specific epithet to find the taxon.
const batchScientificNameKey = 'batch::scientificName';

enum BatchRowStatus {
  ready('Ready'),

  /// Imports, but a taxon, person, site, or event it names isn't in the
  /// project, so that link stays empty.
  missingLink('Missing link'),
  noMatch('No match'),
  ambiguous('Several matches'),
  exists('Already in project'),
  duplicateInFile('Repeated in file'),
  invalid('Invalid values');

  const BatchRowStatus(this.label);

  final String label;

  bool get isImportable => this == ready || this == missingLink;
}

/// What a batch import will do with one file row.
class BatchRowPlan {
  const BatchRowPlan({
    required this.rowNumber,
    required this.status,
    this.messages = const [],
    this.recordKey,
    this.values = const {},
    this.links = const {},
    this.fieldNumber,
    this.siteName,
    this.parentSpecimenUuid,
  });

  final int rowNumber;
  final BatchRowStatus status;
  final List<String> messages;

  /// The record an update writes to: a specimen UUID or a row id.
  final Object? recordKey;

  /// Text to store by field key, checked against each field's type. Blank
  /// cells are left out, so an update never clears a value.
  final Map<String, String> values;

  /// Linked records by link: a person UUID, taxon id, site id, or event id.
  final Map<DataTableLink, Object> links;

  /// A new specimen's field number, set with its cataloger.
  final int? fieldNumber;

  /// A new site's site ID.
  final String? siteName;

  /// The specimen a new part belongs to.
  final String? parentSpecimenUuid;

  BatchRowPlan copyWith({
    BatchRowStatus? status,
    List<String>? messages,
    Map<DataTableLink, Object>? links,
    String? parentSpecimenUuid,
  }) => BatchRowPlan(
    rowNumber: rowNumber,
    status: status ?? this.status,
    messages: messages ?? this.messages,
    recordKey: recordKey,
    values: values,
    links: links ?? this.links,
    fieldNumber: fieldNumber,
    siteName: siteName,
    parentSpecimenUuid: parentSpecimenUuid ?? this.parentSpecimenUuid,
  );
}

class BatchImportReview {
  const BatchImportReview({
    required this.type,
    required this.mode,
    required this.rows,
    this.key,
  });

  final DataTableRecordType type;
  final BatchImportMode mode;
  final BatchImportKey? key;
  final List<BatchRowPlan> rows;

  int count(BatchRowStatus status) =>
      rows.where((row) => row.status == status).length;

  /// Rows to write; [includeMissingLinks] decides rows with a missing link.
  List<BatchRowPlan> importable({bool includeMissingLinks = true}) => [
    for (final row in rows)
      if (row.status == BatchRowStatus.ready ||
          (includeMissingLinks && row.status == BatchRowStatus.missingLink))
        row,
  ];
}

class BatchImportResult {
  const BatchImportResult({
    required this.type,
    required this.mode,
    required this.written,
    required this.skipped,
    required this.errors,
  });

  final DataTableRecordType type;
  final BatchImportMode mode;

  /// Records created or updated.
  final int written;
  final int skipped;

  /// Messages by file row number for rows that failed to write.
  final Map<int, String> errors;
}
