import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Source fields a [recordType] export can use, grouped by table name and
/// keyed `table::column`. Custom fields join under their namespace, such as
/// `customSpecimenPart`, keyed by definition uuid.
Map<String, List<String>> exportFieldGroups(
  Database db,
  RecordType recordType,
  SpecimenRecordType specimenRecordType, [
  List<CustomFieldDefinitionData> customDefinitions = const [],
]) {
  final Map<String, List<String>> groups = {};
  final Set<String> allowedTables;
  switch (recordType) {
    case RecordType.none:
      allowedTables = {'personnel', 'project'};
      break;
    case RecordType.narrative:
      allowedTables = {'narrative', 'site', 'geography', 'personnel'};
      break;
    case RecordType.site:
      allowedTables = {
        'site',
        'geography',
        'siteAttribute',
        'personnel',
        'coordinate',
      };
      break;
    case RecordType.collEvent:
      allowedTables = {
        'collEvent',
        'site',
        'geography',
        'siteAttribute',
        'environment',
        'coordinate',
        'collMethod',
        'collPersonnel',
      };
      break;
    case RecordType.specimenRecord:
    case RecordType.specimenParts:
    case RecordType.parasites:
      allowedTables = {
        'specimen',
        'taxonomy',
        'personnel',
        'project',
        'collEvent',
        'collMethod',
        'collPersonnel',
        'site',
        'geography',
        'siteAttribute',
        'coordinate',
        'environment',
        'mammalAttribute',
        'birdAttribute',
        'herpAttribute',
        'invertebrateAttribute',
        'fishAttribute',
        'fossilAttribute',
        'specimenPart',
      };
      if (recordType == RecordType.parasites) {
        allowedTables
          ..remove('specimenPart')
          ..addAll({'parasite', 'parasiteDetection'});
      }
      if (specimenRecordType == SpecimenRecordType.mammals) {
        allowedTables.remove('birdAttribute');
        allowedTables.remove('herpAttribute');
        allowedTables.remove('invertebrateAttribute');
        allowedTables.remove('fishAttribute');
      } else if (specimenRecordType == SpecimenRecordType.birds) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('herpAttribute');
        allowedTables.remove('invertebrateAttribute');
        allowedTables.remove('fishAttribute');
      } else if (specimenRecordType == SpecimenRecordType.herpetofauna) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('birdAttribute');
        allowedTables.remove('invertebrateAttribute');
        allowedTables.remove('fishAttribute');
      } else if (specimenRecordType == SpecimenRecordType.invertebrates) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('birdAttribute');
        allowedTables.remove('herpAttribute');
        allowedTables.remove('fishAttribute');
      } else if (specimenRecordType == SpecimenRecordType.fishes) {
        allowedTables.remove('mammalAttribute');
        allowedTables.remove('birdAttribute');
        allowedTables.remove('herpAttribute');
        allowedTables.remove('invertebrateAttribute');
      }
      break;
  }

  for (var table in db.allTables) {
    final tableName = table.actualTableName;
    if (allowedTables.contains(tableName)) {
      groups[tableName] = table.$columns
          .map<String>((c) => '$tableName::${c.name}')
          .toList();
    }
  }
  for (final definition in customDefinitions) {
    final namespace = switch (definition.placement) {
      FieldUISection.siteAttribute => 'customSite',
      FieldUISection.environmentalData => 'customEnvironment',
      FieldUISection.specimenAttribute => 'customSpecimen',
      FieldUISection.specimenPart => 'customSpecimenPart',
      FieldUISection.parasite => 'customParasite',
    };
    final isAvailable = switch (recordType) {
      RecordType.site || RecordType.narrative => namespace == 'customSite',
      RecordType.collEvent =>
        namespace == 'customSite' || namespace == 'customEnvironment',
      RecordType.specimenRecord ||
      RecordType.specimenParts ||
      RecordType.parasites => true,
      RecordType.none => false,
    };
    if (!isAvailable ||
        !_matchesSpecimenRecordType(definition, specimenRecordType)) {
      continue;
    }
    groups
        .putIfAbsent(namespace, () => <String>[])
        .add('$namespace::${definition.uuid}');
  }
  return groups;
}

bool _matchesSpecimenRecordType(
  CustomFieldDefinitionData definition,
  SpecimenRecordType recordType,
) {
  final catalog = definition.applicableCatalog;
  if (catalog == null || !definition.placement.isSpecimenRelated) {
    return true;
  }
  return switch (recordType) {
    SpecimenRecordType.birds => catalog == CatalogFmt.ornithology,
    SpecimenRecordType.mammals => catalog == CatalogFmt.mammalogy,
    SpecimenRecordType.herpetofauna => catalog == CatalogFmt.herpetology,
    SpecimenRecordType.invertebrates =>
      catalog == CatalogFmt.invertebrateZoology,
    SpecimenRecordType.fishes => catalog == CatalogFmt.ichthyology,
    SpecimenRecordType.allTaxa => true,
  };
}

/// The name of the custom field [key] names, or null for a table field.
String? exportCustomFieldLabel(
  String key,
  List<CustomFieldDefinitionData> definitions,
) {
  if (!key.startsWith('custom')) return null;
  final uuid = key.split('::').last;
  return definitions
      .where((definition) => definition.uuid == uuid)
      .map((definition) => definition.name)
      .firstOrNull;
}
