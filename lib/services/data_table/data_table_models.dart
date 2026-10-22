import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Record types the project data table can show. Each matches a tabular
/// record export, and its columns are that export's fields.
enum DataTableRecordType {
  specimenRecords('Specimen records'),
  specimenParts('Specimen parts'),
  sites('Sites'),
  events('Events'),
  narrative('Narrative');

  const DataTableRecordType(this.label);

  final String label;

  /// Export fields shown before the user picks columns.
  List<String> get defaultColumnKeys => switch (this) {
    DataTableRecordType.specimenRecords => const [
      'specimen::cataloger',
      'specimen::fieldNumber',
      'specimen::family',
      'specimen::genus',
      'specimen::specificEpithet',
      'specimen::condition',
      'measurement::sex',
      'site::site',
      'event::collEventID',
      'specimen::preparationDate',
    ],
    DataTableRecordType.specimenParts => const [
      'part::tissueID',
      'part::barcodeID',
      'part::type',
      'part::count',
      'part::treatment',
      'specimen::cataloger',
      'specimen::fieldNumber',
      'specimen::genus',
      'specimen::specificEpithet',
    ],
    DataTableRecordType.sites => const [
      'site::site',
      'siteAttribute::habitatType',
      'geography::country',
      'geography::stateProvince',
      'geography::county',
      'geography::specificLocality',
      'site::coordinates',
    ],
    DataTableRecordType.events => const [
      'event::collEventID',
      'site::site',
      'event::startDate',
      'event::endDate',
      'event::methods',
      'event::personnel',
    ],
    DataTableRecordType.narrative => narrativeExportList,
  };

  /// Tables this record type owns, so its rows may edit them. Fields from
  /// linked records, such as a specimen's site, stay read-only here.
  Set<DataTableWriteTarget> get writeTargets => switch (this) {
    DataTableRecordType.specimenRecords => const {
      DataTableWriteTarget.specimen,
      DataTableWriteTarget.attribute,
    },
    DataTableRecordType.specimenParts => const {DataTableWriteTarget.part},
    DataTableRecordType.sites => const {
      DataTableWriteTarget.site,
      DataTableWriteTarget.siteAttribute,
      DataTableWriteTarget.geography,
    },
    DataTableRecordType.events => const {
      DataTableWriteTarget.event,
      DataTableWriteTarget.environment,
    },
    DataTableRecordType.narrative => const {DataTableWriteTarget.narrative},
  };

  List<DataTableQuickFilter> get quickFilters => [
    for (final filter in DataTableQuickFilter.values)
      if (filter.recordType == this) filter,
  ];
}

/// Taxon groups the specimen record export can be limited to.
extension DataTableSpecimenRecordTypeLabel on SpecimenRecordType {
  String get dataTableLabel => switch (this) {
    SpecimenRecordType.allTaxa => 'All taxa',
    SpecimenRecordType.birds => 'Birds',
    SpecimenRecordType.generalMammals => 'Mammals without bats',
    SpecimenRecordType.bats => 'Bats',
    SpecimenRecordType.allMammals => 'All mammals',
    SpecimenRecordType.herpetofauna => 'Herpetofauna',
    SpecimenRecordType.invertebrates => 'Invertebrates',
    SpecimenRecordType.fishes => 'Fishes',
  };
}

/// The catalog format whose icon stands for [type]; null for all taxa,
/// which uses the project's own catalog format.
CatalogFmt? dataTableCatalogFmt(SpecimenRecordType type) => switch (type) {
  SpecimenRecordType.allTaxa => null,
  SpecimenRecordType.birds => CatalogFmt.ornithology,
  SpecimenRecordType.generalMammals ||
  SpecimenRecordType.bats ||
  SpecimenRecordType.allMammals => CatalogFmt.mammalogy,
  SpecimenRecordType.herpetofauna => CatalogFmt.herpetology,
  SpecimenRecordType.invertebrates => CatalogFmt.invertebrateZoology,
  SpecimenRecordType.fishes => CatalogFmt.ichthyology,
};

/// Fields shown in italics, such as names that make up a scientific name.
const dataTableItalicColumnKeys = {
  'specimen::genus',
  'specimen::specificEpithet',
  'parasite::scientificName',
};

class DataTableColumn {
  DataTableColumn({required this.key, required this.label, required this.group})
    : field = dataTableField(key);

  /// Export header key, such as `specimen::fieldNumber`.
  final String key;

  /// Export field name, with its group added when another group shares it.
  final String label;

  /// Export table the field belongs to, such as `specimen`.
  final String group;
  final DataTableField field;

  /// How this column is changed from a dialog in [type], if it is linked
  /// data rather than a plain field.
  DataTableLink? linkIn(DataTableRecordType type) =>
      dataTableLinkFor(type, key);

  bool isEditableIn(DataTableRecordType type) =>
      field.writeTarget != null &&
      type.writeTargets.contains(field.writeTarget);
}

/// Builds columns from export header keys.
///
/// Labels are the export field names, as in a field-names-only export. The
/// first field with a name keeps it plain; a later one from another group,
/// such as a parasite's `remark` after the specimen's, gets its group
/// appended so the headers stay distinct.
List<DataTableColumn> dataTableColumnsFromHeader(List<String> header) {
  final keys = <String>{...header};
  String group(String key) {
    final separator = key.indexOf('::');
    return separator == -1 ? 'other' : key.substring(0, separator);
  }

  String field(String key) => key.split('::').last;
  final seen = <String>{};
  return [
    for (final key in keys)
      DataTableColumn(
        key: key,
        group: group(key),
        label: seen.add(field(key))
            ? field(key)
            : '${field(key)} (${group(key)})',
      ),
  ];
}

/// Default visible columns for [type], limited to those in [columns]. Falls
/// back to every column when none of the defaults exist.
Set<String> defaultDataTableColumnKeys(
  DataTableRecordType type,
  List<DataTableColumn> columns,
) {
  final available = columns.map((column) => column.key).toSet();
  final defaults = type.defaultColumnKeys.where(available.contains).toSet();
  return defaults.isEmpty ? available : defaults;
}

/// Linked data, edited in a dialog because a change reaches beyond the
/// cell: another record is chosen, or a shared record is changed.
enum DataTableLink {
  /// Choose a different record.
  cataloger,
  preparator,
  taxon,
  event,
  site,

  /// Edit the site or event this record is linked to.
  linkedSite,
  linkedEvent;

  bool get isRelink => this != linkedSite && this != linkedEvent;
}

DataTableLink? dataTableLinkFor(DataTableRecordType type, String key) {
  final group = key.split('::').first;
  switch (type) {
    case DataTableRecordType.specimenRecords:
      return switch (key) {
        'specimen::cataloger' => DataTableLink.cataloger,
        'specimen::preparator' => DataTableLink.preparator,
        'specimen::order' ||
        'specimen::family' ||
        'specimen::genus' ||
        'specimen::specificEpithet' => DataTableLink.taxon,
        'event::collEventID' => DataTableLink.event,
        _ => switch (group) {
          'site' || 'siteAttribute' || 'geography' => DataTableLink.linkedSite,
          'event' || 'environment' => DataTableLink.linkedEvent,
          _ => null,
        },
      };
    case DataTableRecordType.events:
      if (key == 'site::site') return DataTableLink.site;
      return switch (group) {
        'site' || 'siteAttribute' || 'geography' => DataTableLink.linkedSite,
        _ => null,
      };
    case DataTableRecordType.narrative:
      return key == 'narrative::verbatimLocality' ? DataTableLink.site : null;
    case DataTableRecordType.specimenParts:
    case DataTableRecordType.sites:
      return null;
  }
}

class DataTableSort {
  const DataTableSort({required this.columnKey, this.ascending = true});

  final String columnKey;
  final bool ascending;
}

const dataTableRowsPerPageOptions = [25, 50, 100];

enum DataTableFilterOp {
  equals('is'),
  contains('contains'),
  startsWith('starts with'),
  greaterThan('greater than'),
  lessThan('less than'),
  between('between'),
  isEmpty('is empty'),
  isNotEmpty('is not empty');

  const DataTableFilterOp(this.label);

  final String label;

  /// Operators that compare against no value.
  bool get takesValue => this != isEmpty && this != isNotEmpty;

  static List<DataTableFilterOp> forType(DataTableValueType type) =>
      switch (type) {
        DataTableValueType.text => const [
          equals,
          contains,
          startsWith,
          isEmpty,
          isNotEmpty,
        ],
        DataTableValueType.coded => const [equals, isEmpty, isNotEmpty],
        _ => const [
          equals,
          greaterThan,
          lessThan,
          between,
          isEmpty,
          isNotEmpty,
        ],
      };
}

/// One field rule. Rules combine with AND.
class DataTableFilterRule {
  const DataTableFilterRule({
    required this.fieldKey,
    required this.op,
    this.value = '',
    this.value2 = '',
  });

  final String fieldKey;
  final DataTableFilterOp op;
  final String value;

  /// Upper bound for [DataTableFilterOp.between].
  final String value2;
}

/// Preset filters, one row of chips per record type. Each is a fixed SQL
/// condition over the page query's aliases.
enum DataTableQuickFilter {
  missingTaxon(
    DataTableRecordType.specimenRecords,
    'Missing taxon',
    's.speciesID IS NULL',
  ),
  noFieldNumber(
    DataTableRecordType.specimenRecords,
    'No field number',
    's.fieldNumber IS NULL',
  ),
  noEvent(
    DataTableRecordType.specimenRecords,
    'No event',
    's.collEventID IS NULL',
  ),
  hasParts(
    DataTableRecordType.specimenRecords,
    'Has parts',
    'EXISTS (SELECT 1 FROM specimenPart sp WHERE sp.specimenUuid = s.uuid)',
  ),
  noTissueId(
    DataTableRecordType.specimenParts,
    'No tissue ID',
    "(p.tissueID IS NULL OR TRIM(p.tissueID) = '')",
  ),
  noCoordinates(
    DataTableRecordType.sites,
    'No coordinates',
    'NOT EXISTS (SELECT 1 FROM coordinate c WHERE c.siteID = st.id)',
  ),
  noLocality(
    DataTableRecordType.sites,
    'No locality',
    'st.geographyId IS NULL',
  ),
  noSpecimens(
    DataTableRecordType.events,
    'No specimens',
    'NOT EXISTS (SELECT 1 FROM specimen x WHERE x.collEventID = ce.id)',
  ),
  noEndDate(
    DataTableRecordType.events,
    'No end date',
    "(ce.endDate IS NULL OR TRIM(ce.endDate) = '')",
  ),
  noSite(DataTableRecordType.narrative, 'No site', 'n.siteID IS NULL');

  const DataTableQuickFilter(this.recordType, this.label, this.sql);

  final DataTableRecordType recordType;
  final String label;
  final String sql;
}

/// Limits the table to a fixed set of records, such as the records behind one
/// statistics bar.
class DataTableKeyScope {
  const DataTableKeyScope({required this.keys, required this.label});

  /// Record keys as the table reads them: specimen UUIDs or row ids.
  final Set<Object> keys;

  /// What the scope shows, for the filter chip.
  final String label;
}

/// What the user asked to see.
class DataTableQuery {
  const DataTableQuery({
    this.search = '',
    this.searchField,
    this.searchKeys = const [],
    this.rules = const [],
    this.quickFilters = const {},
    this.sort,
    this.page = 0,
    this.rowsPerPage = 50,
    this.scope,
    this.allProjects = false,
  });

  final String search;

  /// Limits the search to one field; null searches [searchKeys].
  final String? searchField;

  /// Fields an all-fields search covers: the visible columns.
  final List<String> searchKeys;
  final List<DataTableFilterRule> rules;
  final Set<DataTableQuickFilter> quickFilters;
  final DataTableSort? sort;
  final int page;
  final int rowsPerPage;

  /// Limits the table to these records; null shows every record.
  final DataTableKeyScope? scope;

  /// Reads records from every project instead of the open one.
  final bool allProjects;
}

/// One record on the current page.
class DataTableRecordRow {
  const DataTableRecordRow({
    required this.key,
    required this.values,
    this.raw = const {},
    this.attributeTable,
    this.siteId,
    this.eventId,
    this.specimenUuid,
    this.projectUuid,
    this.mediaKinds = const {},
  });

  /// The record's primary key: a specimen UUID or a row id.
  final Object key;

  /// Display text by export header key, as the export writes it.
  final Map<String, String> values;

  /// Stored values of editable fields, which can differ from the display
  /// text (number formatting, "Unknown" placeholders).
  final Map<String, String> raw;

  /// For specimens: the attribute table holding this specimen's row, if any.
  final String? attributeTable;

  /// The site and event this record is linked to, if any.
  final int? siteId;
  final int? eventId;

  /// The specimen this record belongs to: the key itself for specimens, the
  /// parent specimen for parts.
  final String? specimenUuid;

  /// The project this record belongs to.
  final String? projectUuid;

  /// Kinds of media linked to this record. Parts show their specimen's media.
  final Set<MediaKind> mediaKinds;
}

class DataTablePageData {
  const DataTablePageData({
    required this.columns,
    required this.rows,
    required this.totalRows,
    required this.page,
    required this.pageCount,
    required this.rowsPerPage,
  });

  final List<DataTableColumn> columns;
  final List<DataTableRecordRow> rows;

  /// Records matching the search and filters, across every page.
  final int totalRows;

  /// Zero-based page shown, clamped to the pages that exist.
  final int page;
  final int pageCount;
  final int rowsPerPage;

  int get firstRowIndex => page * rowsPerPage;
}
