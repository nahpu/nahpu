import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/export.dart';

/// Returns the database fields available to a template for [recordType].
Map<String, List<String>> availableTemplateFieldGroups(
  Database db,
  RecordType recordType, {
  String selectedTaxon = 'All Taxa',
}) {
  final groups = <String, List<String>>{};
  final Set<String> allowedTables;
  switch (recordType) {
    case RecordType.none:
      allowedTables = {'personnel', 'project'};
      break;
    case RecordType.narrative:
      allowedTables = {'narrative', 'site', 'personnel'};
      break;
    case RecordType.site:
      allowedTables = {'site', 'personnel', 'coordinate'};
      break;
    case RecordType.collEvent:
      allowedTables = {
        'collEvent',
        'site',
        'weather',
        'coordinate',
        'collEffort',
        'collPersonnel',
      };
      break;
    case RecordType.specimenRecord:
    case RecordType.specimenParts:
      allowedTables = {
        'specimen',
        'taxonomy',
        'personnel',
        'project',
        'collEvent',
        'site',
        'coordinate',
        'weather',
        'mammalAttribute',
        'birdAttribute',
        'herpAttribute',
        'specimenPart',
      };
      if (selectedTaxon == 'Mammals') {
        allowedTables.remove('birdAttribute');
        allowedTables.remove('herpAttribute');
      } else if (selectedTaxon == 'Birds') {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('herpAttribute');
      } else if (selectedTaxon == 'Herpetofauna') {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('birdAttribute');
      }
      break;
  }

  for (final table in db.allTables) {
    final tableName = table.actualTableName;
    if (allowedTables.contains(tableName)) {
      groups[tableName] = table.$columns
          .map((column) => '$tableName::${column.name}')
          .toList(growable: false);
    }
  }
  return groups;
}
