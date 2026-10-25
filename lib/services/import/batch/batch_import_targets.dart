import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/types/export.dart';

/// How a batch import uses a target field.
enum BatchTargetKind {
  /// Written through the data table's field catalog.
  field,

  /// Names another record: a person, taxon, site, or event.
  link,

  /// Identifies the record: a field number, site ID, UUID, or catalog
  /// number. Used to match rows, and set only on new records.
  identity,

  /// A site's coordinate, written to its coordinate row.
  coordinate,
}

/// A NAHPU field a file column can map to.
class BatchImportTarget {
  const BatchImportTarget({
    required this.key,
    required this.label,
    required this.group,
    required this.kind,
    this.link,
  });

  /// Export header key, such as `measurement::hindFootLength`.
  final String key;
  final String label;

  /// Section heading in the column picker, such as "Measurements".
  final String group;
  final BatchTargetKind kind;
  final DataTableLink? link;

  DataTableField get field => dataTableField(key);
}

/// Fields a file column can map to for [type], in picker order.
List<BatchImportTarget> batchImportTargets(DataTableRecordType type) {
  final keys = switch (type) {
    DataTableRecordType.specimenRecords => [
      ...collectingRecordExportList,
      batchCatalogNumberKey,
      batchScientificNameKey,
      'event::collEventID',
      ..._measurementKeys,
    ],
    DataTableRecordType.specimenParts => [
      ...partExportListDelimited,
      'specimen::specimenUUID',
      batchCatalogNumberKey,
      'specimen::cataloger',
      'specimen::fieldNumber',
    ],
    DataTableRecordType.parasites => [
      ...parasiteExportList,
      'specimen::specimenUUID',
      batchCatalogNumberKey,
      'specimen::cataloger',
      'specimen::fieldNumber',
    ],
    DataTableRecordType.sites => siteExportList,
    DataTableRecordType.events => [...collEventExportList, 'site::site'],
    DataTableRecordType.narrative => narrativeExportList,
  };
  return [
    for (final key in {...keys}) ?_target(type, key),
  ];
}

BatchImportTarget? _target(DataTableRecordType type, String key) {
  final kind = _kindOf(type, key);
  if (kind == null) return null;
  return BatchImportTarget(
    key: key,
    label: batchFieldLabel(key),
    group: _groupLabel(type, key),
    kind: kind,
    link: kind == BatchTargetKind.link ? _linkOf(type, key) : null,
  );
}

BatchTargetKind? _kindOf(DataTableRecordType type, String key) {
  if (_linkOf(type, key) != null) return BatchTargetKind.link;
  if (_identityKeys[type]!.contains(key)) return BatchTargetKind.identity;
  final field = dataTableField(key);
  final editable =
      field.writeTarget != null &&
      type.writeTargets.contains(field.writeTarget);
  return editable ? BatchTargetKind.field : null;
}

DataTableLink? _linkOf(DataTableRecordType type, String key) {
  if (type == DataTableRecordType.specimenRecords) {
    if (key == batchScientificNameKey) return DataTableLink.taxon;
    final link = dataTableLinkFor(type, key);
    return link != null && link.isRelink ? link : null;
  }
  if (type == DataTableRecordType.specimenParts ||
      type == DataTableRecordType.parasites) {
    return null;
  }
  final link = dataTableLinkFor(type, key);
  return link != null && link.isRelink ? link : null;
}

const _identityKeys = {
  DataTableRecordType.specimenRecords: {
    'specimen::specimenUUID',
    'specimen::fieldNumber',
    batchCatalogNumberKey,
  },
  // A part's parent specimen.
  DataTableRecordType.specimenParts: {
    'specimen::specimenUUID',
    'specimen::cataloger',
    'specimen::fieldNumber',
    batchCatalogNumberKey,
  },
  // A parasite's own UUID, and its parent specimen.
  DataTableRecordType.parasites: {
    'parasite::parasiteUuid',
    'specimen::specimenUUID',
    'specimen::cataloger',
    'specimen::fieldNumber',
    batchCatalogNumberKey,
  },
  DataTableRecordType.sites: {'site::site'},
  DataTableRecordType.events: {'event::collEventID'},
  DataTableRecordType.narrative: <String>{},
};

/// Every taxon group's measurements, without repeats.
final _measurementKeys = {
  ...mammalAttributeExportList,
  ...batAttributeExportList,
  ...birdAttributeExportList,
  ...herpAttributeExportList,
  ...invertebrateAttributeExportList,
  ...fishAttributeExportList,
  ...fossilAttributeExportList,
}.toList();

String _groupLabel(DataTableRecordType type, String key) {
  if (key == batchCatalogNumberKey || key == batchScientificNameKey) {
    return _hasParentSpecimen(type) ? 'Parent specimen' : 'Specimen';
  }
  final group = key.split('::').first;
  if (_hasParentSpecimen(type) && group == 'specimen') {
    return 'Parent specimen';
  }
  return switch (group) {
    'specimen' => 'Specimen',
    'measurement' => 'Measurements',
    'part' => 'Part',
    'parasite' => 'Parasite',
    'site' || 'siteAttribute' || 'geography' => 'Site',
    'event' || 'environment' => 'Event',
    'narrative' => 'Narrative',
    _ => 'Other',
  };
}

bool _hasParentSpecimen(DataTableRecordType type) =>
    type == DataTableRecordType.specimenParts ||
    type == DataTableRecordType.parasites;

/// A readable name for a field key: `measurement::hindFootLength` becomes
/// "Hind foot length".
String batchFieldLabel(String key) {
  final special = _labels[key];
  if (special != null) return special;
  final words = batchSplitWords(key.split('::').last);
  if (words.isEmpty) return key;
  final text = words.join(' ');
  return text[0].toUpperCase() + text.substring(1);
}

const _labels = {
  'coordinate::nameId': 'Coordinate name',
  'coordinate::decimalLatitude': 'Latitude',
  'coordinate::decimalLongitude': 'Longitude',
  'coordinate::elevationInMeter': 'Elevation (m)',
  'coordinate::uncertaintyInMeters': 'Uncertainty (m)',
  'coordinate::datum': 'Datum',
  batchCatalogNumberKey: 'Catalog number',
  batchScientificNameKey: 'Scientific name',
  'specimen::specimenUUID': 'Specimen UUID',
  'specimen::iDConfidence': 'ID confidence',
  'specimen::iDMethod': 'ID method',
  'part::tissueID': 'Tissue ID',
  'part::barcodeID': 'Barcode ID',
  'parasite::parasiteID': 'Parasite ID',
  'parasite::parasiteUuid': 'Parasite UUID',
  'parasite::collectorID': 'Collector',
  'parasite::determinerID': 'Determiner',
  'site::site': 'Site ID',
  'event::collEventID': 'Event ID',
  'event::Activity': 'Activity',
  'narrative::verbatimLocality': 'Site',
  'environment::pH': 'pH',
  'environment::lowestDayTempC': 'Lowest day temp (°C)',
  'environment::highestDayTempC': 'Highest day temp (°C)',
  'environment::lowestNightTempC': 'Lowest night temp (°C)',
  'environment::highestNightTempC': 'Highest night temp (°C)',
  'environment::rainfallInMm': 'Rainfall (mm)',
};

/// Lowercase words of a header or field name. Splits camelCase, digits,
/// and any punctuation or spacing.
List<String> batchSplitWords(String text) {
  final spaced = text
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAllMapped(
        RegExp(r'([A-Z]+)([A-Z][a-z])'),
        (m) => '${m[1]} ${m[2]}',
      )
      .replaceAllMapped(RegExp(r'([a-zA-Z])(\d)'), (m) => '${m[1]} ${m[2]}');
  return spaced
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toList();
}

/// The database `table::column` the Darwin Core mapping knows [key] by,
/// or null when the field isn't a stored column.
String? batchDwcSourceKey(String key) {
  if (batchCoordinateFields.containsKey(key)) return key;
  final special = _dwcSourceKeys[key];
  if (special != null) return special;
  final field = dataTableField(key);
  final column = field.column;
  if (column == null) return null;
  final table = switch (field.writeTarget) {
    DataTableWriteTarget.specimen => 'specimen',
    DataTableWriteTarget.attribute => field.attributeTables.firstOrNull?.table,
    DataTableWriteTarget.part => 'specimenPart',
    DataTableWriteTarget.parasite => 'parasite',
    DataTableWriteTarget.site => 'site',
    DataTableWriteTarget.siteAttribute => 'siteAttribute',
    DataTableWriteTarget.geography => 'geography',
    DataTableWriteTarget.event => 'collEvent',
    DataTableWriteTarget.environment => 'environment',
    DataTableWriteTarget.narrative => 'narrative',
    null => null,
  };
  return table == null ? null : '$table::$column';
}

const _dwcSourceKeys = {
  'specimen::specimenUUID': 'specimen::uuid',
  'specimen::fieldNumber': 'specimen::fieldNumber',
  'specimen::order': 'taxonomy::taxonOrder',
  'specimen::family': 'taxonomy::taxonFamily',
  'specimen::genus': 'taxonomy::genus',
  'specimen::specificEpithet': 'taxonomy::specificEpithet',
  'event::collEventID': 'collEvent::id',
  'site::site': 'site::siteID',
};

/// Darwin Core terms for fields the export builds rather than stores.
const batchExtraDwcTerms = {
  batchCatalogNumberKey: 'catalogNumber',
  batchScientificNameKey: 'scientificName',
  'specimen::cataloger': 'recordedBy',
};

/// The record a linked import's column belongs to.
enum BatchLinkedSection { site, event, specimen, part, parasite }

/// The section of a linked import [key] fills.
BatchLinkedSection batchLinkedSection(String key) {
  if (key == batchCatalogNumberKey || key == batchScientificNameKey) {
    return BatchLinkedSection.specimen;
  }
  return switch (key.split('::').first) {
    'site' ||
    'siteAttribute' ||
    'geography' ||
    'coordinate' => BatchLinkedSection.site,
    'event' || 'environment' => BatchLinkedSection.event,
    'part' => BatchLinkedSection.part,
    'parasite' => BatchLinkedSection.parasite,
    _ => BatchLinkedSection.specimen,
  };
}

/// Columns of a site's coordinate, and how each is stored.
const batchCoordinateFields = {
  'coordinate::nameId': DataTableValueType.text,
  'coordinate::decimalLatitude': DataTableValueType.real,
  'coordinate::decimalLongitude': DataTableValueType.real,
  'coordinate::elevationInMeter': DataTableValueType.real,
  'coordinate::uncertaintyInMeters': DataTableValueType.integer,
  'coordinate::datum': DataTableValueType.text,
};

/// Fields one row of a linked import can fill: its site and coordinate,
/// event, specimen, part, and parasite. The site ID and event ID name the row's
/// site and event, which the import groups rows into.
List<BatchImportTarget> batchLinkedTargets() {
  BatchImportTarget identity(BatchImportTarget target, String group) =>
      BatchImportTarget(
        key: target.key,
        label: target.label,
        group: group,
        kind: BatchTargetKind.identity,
      );
  final sites = batchImportTargets(DataTableRecordType.sites);
  final events = [
    for (final target in batchImportTargets(DataTableRecordType.events))
      if (target.key == 'event::collEventID')
        identity(target, 'Event')
      else if (target.key != 'site::site')
        target,
  ];
  final specimens = [
    for (final target in batchImportTargets(
      DataTableRecordType.specimenRecords,
    ))
      if (target.key != 'event::collEventID') target,
  ];
  final parts = [
    for (final target in batchImportTargets(DataTableRecordType.specimenParts))
      if (target.key.startsWith('part::'))
        BatchImportTarget(
          key: target.key,
          label: target.label,
          group: 'Part',
          kind: target.kind,
        ),
  ];
  final parasites = [
    for (final target in batchImportTargets(DataTableRecordType.parasites))
      if (target.key.startsWith('parasite::') &&
          target.kind == BatchTargetKind.field)
        BatchImportTarget(
          key: target.key,
          label: target.label,
          group: 'Parasite',
          kind: target.kind,
        ),
  ];
  return [
    ...sites,
    for (final key in batchCoordinateFields.keys)
      BatchImportTarget(
        key: key,
        label: batchFieldLabel(key),
        group: 'Coordinates',
        kind: BatchTargetKind.coordinate,
      ),
    ...events,
    ...specimens,
    ...parts,
    ...parasites,
  ];
}

/// The text to store for a coordinate [key], or the reason it doesn't fit.
(String?, String?) batchCoordinateText(String key, String raw) {
  final value = raw.trim();
  switch (batchCoordinateFields[key]) {
    case DataTableValueType.real:
      final number = double.tryParse(value);
      if (number == null) return (null, 'Enter a number');
      final limit = switch (key) {
        'coordinate::decimalLatitude' => 90,
        'coordinate::decimalLongitude' => 180,
        _ => null,
      };
      if (limit != null && number.abs() > limit) {
        return (null, 'Enter a value from -$limit to $limit');
      }
      return ('$number', null);
    case DataTableValueType.integer:
      final number = num.tryParse(value);
      if (number == null) return (null, 'Enter a whole number');
      return ('${number.round()}', null);
    default:
      return (value, null);
  }
}
