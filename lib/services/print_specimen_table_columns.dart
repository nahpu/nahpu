import 'package:nahpu/services/database/database.dart';

/// Column names on [Database.specimen] suitable for `[placeholder]` labels.
List<String> printSpecimenTableCatalog(Database db) {
  return db.specimen.$columns.map((c) => c.name).toList();
}

const _measurementLabelSkipColumns = {'specimenUuid'};

/// Placeholder ids for mammal / avian / herp measurement columns (`mammal.totalLength`, etc.).
List<String> measurementLabelFieldIds(Database db) {
  final out = <String>{};
  for (final c in db.mammalMeasurement.$columns) {
    if (!_measurementLabelSkipColumns.contains(c.name)) {
      out.add('mammal.${c.name}');
    }
  }
  for (final c in db.avianMeasurement.$columns) {
    if (!_measurementLabelSkipColumns.contains(c.name)) {
      out.add('avian.${c.name}');
    }
  }
  for (final c in db.herpMeasurement.$columns) {
    if (!_measurementLabelSkipColumns.contains(c.name)) {
      out.add('herp.${c.name}');
    }
  }
  final list = out.toList()..sort();
  return list;
}

/// Human-readable title for a specimen column id (e.g. for UI).
String specimenColumnDisplayTitle(String columnId) {
  const measurementGroup = {
    'mammal': 'Mammal',
    'avian': 'Avian',
    'herp': 'Herp',
  };
  final dot = columnId.indexOf('.');
  if (dot > 0) {
    final prefix = columnId.substring(0, dot);
    if (measurementGroup.containsKey(prefix)) {
      final rest = columnId.substring(dot + 1);
      return '${measurementGroup[prefix]} · ${specimenColumnDisplayTitle(rest)}';
    }
  }
  const special = {
    'uuid': 'Specimen UUID',
    'taxonClass': 'Class',
    'taxonOrder': 'Order',
    'taxonFamily': 'Family',
    'commonName': 'Common name',
    'speciesID': 'Species (taxonomy id)',
    'collEventID': 'Collecting event',
    'coordinateID': 'Coordinates',
    'catalogerID': 'Cataloger',
    'preparatorID': 'Preparator',
    'collPersonnelID': 'Collector personnel',
    'collMethodID': 'Collecting method',
    'iDConfidence': 'ID confidence',
    'iDMethod': 'ID method',
    'isRelativeTime': 'Relative capture time flag',
    'isMultipleCollector': 'Multiple collectors flag',
  };
  if (special.containsKey(columnId)) return special[columnId]!;
  return columnId
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
      .trim()
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// PDF/template-only placeholders beyond raw specimen columns.
const List<String> kLabelBracketFieldsBeyondSpecimenColumns = [
  'fieldId',
  'catalogNum',
  'species',
  'genus',
  'specificEpithet',
  'taxonClass',
  'taxonOrder',
  'taxonFamily',
  'commonName',
  'locality',
  'site',
  'coordinates',
  'collector',
  'preparator',
  'cataloger',
  'backOfTag',
  'tissueId',
];

/// Default columns for the print-labels specimen table (field ids from
/// [labelTemplateAvailableFieldIds]).
const List<String> kDefaultPrintSpecimenTableColumnIds = [
  'fieldNumber',
  'taxonGroup',
  'taxonClass',
  'species',
  'captureDate',
];

/// All `[id]` values offered in the template editor sidebar.
List<String> labelTemplateAvailableFieldIds(Database db) {
  final fromTable = printSpecimenTableCatalog(db);
  final set = {
    ...fromTable,
    ...kLabelBracketFieldsBeyondSpecimenColumns,
    ...measurementLabelFieldIds(db),
  };
  final out = set.toList()..sort();
  return out;
}

/// Keeps saved field-id lists aligned with the current catalog.
List<String> normalizePrintSpecimenTableColumnIds(
  List<String> ids,
  Database db,
) {
  final allowed =
      labelTemplateAvailableFieldIds(db).map((e) => e.toLowerCase()).toSet();
  return ids.where((id) => allowed.contains(id.toLowerCase())).toList();
}
