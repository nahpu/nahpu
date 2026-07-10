part of '../document_writer.dart';

/// Extracts and aggregates a dictionary of all supported document variables
/// for a specific [s] SpecimenData record from the [db] database.
///
/// The returned map contains key-value pairs representing data fields (e.g.,
/// 'catalogNum', 'species', 'locality') ready to be injected into a template.
Future<Map<String, String>> documentFieldValuesForSpecimen(
  Database db,
  SpecimenData s,
  WidgetRef ref,
) async {
  final m = <String, String>{};

  try {
    final exporter =
        DynamicRecordExporter(ref: ref, concatenateMultiEntry: true);
    final records = await exporter.getRecord(s);
    if (records.isNotEmpty) {
      m.addAll(records.first);
    }
  } catch (_) {}

  return m;
}

/// Builds template field values for a site document record.
///
/// The returned map includes `site::` values, derived locality/coordinate
/// fields, and lead personnel fields when a lead staff member is set.
Future<Map<String, String>> documentFieldValuesForSite(
  Database db,
  SiteData s,
  WidgetRef ref,
) async {
  final m = <String, String>{};
  final writer = SiteWriterServices(ref: ref);

  for (var entry in s.toJson().entries) {
    m['site::${entry.key}'] = entry.value?.toString() ?? '';
  }

  m['site::site'] = s.siteID ?? '';
  m['site::habitatType'] = s.habitatType ?? '';
  m['site::country'] = s.country ?? '';
  m['site::stateProvince'] = s.stateProvince ?? '';
  m['site::county'] = s.county ?? '';
  m['site::municipality'] = s.municipality ?? '';
  m['site::specificLocality'] = s.locality ?? '';
  m['site::siteNotes'] = s.remark ?? '';
  m['site::verbatimLocality'] = await writer.getVerbatimLocality(s.id);
  m['site::coordinates'] = await writer.getCoordinates(s.id);

  final coordinates = await CoordinateServices(ref: ref).getCoordinatesBySiteID(
    s.id,
  );
  m.addAll(buildCoordinateFieldValues(coordinates));

  if (s.leadStaffId != null) {
    try {
      final p =
          await PersonnelServices(ref: ref).getPersonnelByUuid(s.leadStaffId!);
      for (var entry in p.toJson().entries) {
        m['personnel::${entry.key}'] = entry.value?.toString() ?? '';
      }
    } catch (_) {}
  }
  return m;
}

Map<String, String> buildCoordinateFieldValues(
  List<CoordinateData> coordinates,
) {
  final values = <String, String>{};
  const coordinateColumns = [
    'id',
    'nameId',
    'decimalLatitude',
    'decimalLongitude',
    'elevationInMeter',
    'datum',
    'uncertaintyInMeters',
    'gpsUnit',
    'notes',
    'siteID',
  ];
  for (final col in coordinateColumns) {
    values['coordinate::$col'] = '';
  }

  if (coordinates.isEmpty) {
    return values;
  }

  final coordinateJsonList = coordinates.map((c) => c.toJson()).toList();
  final keys = <String>{};
  for (final coordinateJson in coordinateJsonList) {
    keys.addAll(coordinateJson.keys);
  }

  for (final key in keys) {
    final combined = coordinateJsonList
        .map((coordinateJson) => coordinateJson[key]?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .join(writerSeparator);
    values['coordinate::$key'] = combined;
  }

  return values;
}

/// Builds template field values for a collecting event document record.
///
/// The returned map includes `collEvent::`, `event::`, related site fields,
/// effort summaries, and personnel summaries.
Future<Map<String, String>> documentFieldValuesForCollEvent(
  Database db,
  CollEventData s,
  WidgetRef ref,
) async {
  final m = <String, String>{};

  // Pre-populate collEffort keys to avoid unresolved placeholders
  final effortColumns = [
    'id',
    'eventID',
    'method',
    'brand',
    'count',
    'size',
    'notes'
  ];
  for (var col in effortColumns) {
    m['collEffort::$col'] = '';
  }

  for (var entry in s.toJson().entries) {
    m['collEvent::${entry.key}'] = entry.value?.toString() ?? '';
    m['event::${entry.key}'] = entry.value?.toString() ?? '';
  }

  // Site details
  final siteDetails =
      await SiteWriterServices(ref: ref).getSiteDetails(s.siteID);
  for (var i = 0; i < siteExportList.length; i++) {
    m[siteExportList[i]] = siteDetails[i];
  }

  if (s.siteID != null) {
    final site = await SiteServices(ref: ref).getSite(s.siteID!);
    if (site != null) {
      final siteVals = await documentFieldValuesForSite(db, site, ref);
      m.addAll(siteVals);
    }
  }

  // Event details
  final formattedEventID = await CollEventServices(ref: ref).getCollEventID(s);
  m['collEvent::collEventID'] = formattedEventID;
  m['collEvent::collEventId'] = formattedEventID;
  m['event::collEventID'] = formattedEventID;
  m['event::collEventId'] = formattedEventID;

  m['collEvent::Activity'] = s.primaryCollMethod ?? '';
  m['event::Activity'] = s.primaryCollMethod ?? '';

  m['collEvent::startDate'] = s.startDate ?? '';
  m['event::startDate'] = s.startDate ?? '';

  m['collEvent::endDate'] = s.endDate ?? '';
  m['event::endDate'] = s.endDate ?? '';

  m['collEvent::startTime'] = s.startTime ?? '';
  m['event::startTime'] = s.startTime ?? '';

  m['collEvent::endTime'] = s.endTime ?? '';
  m['event::endTime'] = s.endTime ?? '';

  final methods = await _getEventEffort(ref, s.id);
  final personnel = await _getEventPersonnel(ref, s.id);
  m['collEvent::methods'] = methods;
  m['event::methods'] = methods;
  m['collEvent::personnel'] = personnel;
  m['event::personnel'] = personnel;

  // Add collEffort records
  final efforts = await CollEventServices(ref: ref).getAllCollEffort(s.id);
  if (efforts.isNotEmpty) {
    final Set<String> effortKeys = {};
    final List<Map<String, dynamic>> effortJsons =
        efforts.map((e) => e.toJson()).toList();
    for (var effortJson in effortJsons) {
      effortKeys.addAll(effortJson.keys);
    }
    for (var key in effortKeys) {
      final combined =
          effortJsons.map((e) => e[key]?.toString() ?? '').join(' | ');
      m['collEffort::$key'] = combined;
    }
  }

  final collectingPersonnel =
      await CollEventServices(ref: ref).getAllCollPersonnel(s.id);
  m.addAll(buildCollPersonnelFieldValues(collectingPersonnel));

  return m;
}

/// Builds repeated `collPersonnel::` values from collecting-event personnel.
///
/// This deliberately reads [CollPersonnelData] rather than the project-wide
/// personnel table. Linked personnel UUIDs remain available as `personnelId`,
/// while the event-specific name and collecting role come from the join table.
Map<String, String> buildCollPersonnelFieldValues(
  List<CollPersonnelData> personnel,
) {
  const columns = ['id', 'eventID', 'personnelId', 'name', 'role'];
  final values = <String, String>{};
  final rows = personnel.map((entry) => entry.toJson()).toList();

  for (final column in columns) {
    values['collPersonnel::$column'] =
        rows.map((row) => row[column]?.toString() ?? '').join(writerSeparator);
  }
  return values;
}

Future<String> _getEventEffort(WidgetRef ref, int id) async {
  List<CollEffortData> effort =
      await CollEventServices(ref: ref).getAllCollEffort(id);
  return effort.map((e) => '"${e.method}";${e.count}').join(writerSeparator);
}

Future<String> _getEventPersonnel(WidgetRef ref, int id) async {
  List<CollPersonnelData> personnel =
      await CollEventServices(ref: ref).getAllCollPersonnel(id);

  String person = await Future.wait(personnel.map((e) async {
    if (e.personnelId == null) return '';
    final p =
        await PersonnelServices(ref: ref).getPersonnelByUuid(e.personnelId!);
    return '${p.name};${e.role}';
  })).then((value) => value.where((v) => v.isNotEmpty).join(writerSeparator));

  return person;
}

/// Builds template field values for a narrative document record.
///
/// The returned map includes `narrative::` fields, formatted narrative export
/// fields, related site values, and writer personnel fields when available.
Future<Map<String, String>> documentFieldValuesForNarrative(
  Database db,
  NarrativeData s,
  WidgetRef ref,
) async {
  final m = <String, String>{};

  for (var entry in s.toJson().entries) {
    m['narrative::${entry.key}'] = entry.value?.toString() ?? '';
  }

  final writer = NarrativeRecordWriter(ref: ref);
  final details = await writer.getNarrative(s);
  for (var i = 0; i < narrativeExportList.length; i++) {
    m[narrativeExportList[i]] = details[i];
  }

  if (s.siteID != null) {
    final site = await SiteServices(ref: ref).getSite(s.siteID!);
    if (site != null) {
      final siteVals = await documentFieldValuesForSite(db, site, ref);
      m.addAll(siteVals);
    }
  }

  if (s.writerId != null) {
    try {
      final p =
          await PersonnelServices(ref: ref).getPersonnelByUuid(s.writerId!);
      for (var entry in p.toJson().entries) {
        m['personnel::${entry.key}'] = entry.value?.toString() ?? '';
      }
    } catch (_) {}
  }

  return m;
}
