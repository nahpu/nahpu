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
    final exporter = DynamicRecordExporter(
      ref: ref,
      expansion: MultiEntryExpansion.concatenate,
    );
    final records = await exporter.getRecord(s);
    if (records.isNotEmpty) {
      m.addAll(records.first);
    }
  } catch (_) {}

  final links = await SpecimenServices(ref: ref).getSpecimenMedia(s.uuid);
  await _addDocumentMediaValues(
    m,
    links.map((link) => link.mediaId).whereType<int>(),
    ref,
  );

  return m;
}

/// Extracts values for exactly one specimen part while retaining the complete
/// parent-specimen context. Sibling part values are never concatenated.
Future<Map<String, String>> documentFieldValuesForSpecimenPart(
  Database db,
  SpecimenPartProjectRecord record,
  WidgetRef ref,
) async {
  final records = await DynamicRecordExporter(
    ref: ref,
    expansion: MultiEntryExpansion.specimenParts,
  ).getRecord(record.specimen);
  final partId = record.part.id?.toString();
  for (final fields in records) {
    if (fields['specimenPart::id'] == partId) {
      final links = await SpecimenServices(
        ref: ref,
      ).getSpecimenMedia(record.specimen.uuid);
      await _addDocumentMediaValues(
        fields,
        links.map((link) => link.mediaId).whereType<int>(),
        ref,
      );
      return fields;
    }
  }
  return const <String, String>{};
}

/// Builds template field values for a site document record.
///
/// The returned map includes `site::` and `geography::` values, derived
/// locality/coordinate fields, and lead personnel fields when a lead staff
/// member is set.
Future<Map<String, String>> documentFieldValuesForSite(
  Database db,
  SiteRecord s,
  WidgetRef ref,
) async {
  final m = <String, String>{};
  final writer = SiteWriterServices(ref: ref);

  for (var entry in s.site.toJson().entries) {
    m['site::${entry.key}'] = entry.value?.toString() ?? '';
  }
  // Geography moved to its own table, so its keys come from the joined row.
  for (var entry in s.draft.toJson().entries) {
    m['geography::${entry.key}'] = entry.value?.toString() ?? '';
  }
  final attribute = await SiteServices(ref: ref).getSiteAttribute(s.id);
  final fossil = await FossilSiteServices(ref: ref).getFossilSite(s.id);
  if (fossil != null) {
    for (final entry in fossil.toJson().entries) {
      m['fossilSite::${entry.key}'] = entry.value?.toString() ?? '';
    }
  }
  if (attribute != null) {
    for (final entry in attribute.toJson().entries) {
      if (entry.key == 'siteID') continue;
      m['siteAttribute::${entry.key}'] = entry.value?.toString() ?? '';
    }
  }

  m['site::site'] = s.siteID ?? '';
  m['siteAttribute::habitatType'] = attribute?.habitatType ?? '';
  m['site::habitatType'] = attribute?.habitatType ?? '';
  m['geography::country'] = s.country ?? '';
  m['geography::islandGroup'] = s.islandGroup ?? '';
  m['geography::stateProvince'] = s.stateProvince ?? '';
  m['geography::county'] = s.county ?? '';
  m['geography::municipality'] = s.municipality ?? '';
  m['geography::specificLocality'] = s.locality ?? '';
  m['site::siteNotes'] = s.remark ?? '';
  m['geography::verbatimLocality'] = await writer.getVerbatimLocality(s.id);
  m['site::coordinates'] = await writer.getCoordinates(s.id);

  final customEntries = await CustomFieldService(
    db,
  ).getExportEntries(CustomFieldOwner.site(s.id));
  for (final entry in customEntries) {
    m['customSite::${entry.definition.uuid}'] = entry.value == null
        ? ''
        : entry.definition.displayValue(entry.value!.value);
  }

  final coordinates = await CoordinateServices(
    ref: ref,
  ).getCoordinatesBySiteID(s.id);
  m.addAll(buildCoordinateFieldValues(coordinates));

  if (s.leadStaffId != null) {
    try {
      final p = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(s.leadStaffId!);
      for (var entry in p.toJson().entries) {
        m['personnel::${entry.key}'] = entry.value?.toString() ?? '';
      }
    } catch (_) {}
  }
  final links = await SiteServices(ref: ref).getSiteMedia(s.id);
  await _addDocumentMediaValues(
    m,
    links.map((link) => link.mediaId).whereType<int>(),
    ref,
  );
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
    'notes',
  ];
  for (var col in effortColumns) {
    m['collEffort::$col'] = '';
  }

  for (var entry in s.toJson().entries) {
    m['collEvent::${entry.key}'] = entry.value?.toString() ?? '';
    m['event::${entry.key}'] = entry.value?.toString() ?? '';
  }

  // Site details
  final siteDetails = await SiteWriterServices(
    ref: ref,
  ).getSiteDetails(s.siteID);
  for (var i = 0; i < siteExportList.length; i++) {
    m[siteExportList[i]] = siteDetails[i];
  }

  if (s.siteID != null) {
    final site = await SiteServices(ref: ref).getSite(s.siteID!);
    if (site != null) {
      final siteVals = await documentFieldValuesForSite(db, site, ref);
      // A collecting event owns personnel through collPersonnel. Site lead
      // staff remains a site concern and must not leak into the event template
      // as a second, unrelated personnel table.
      m.addEntries(
        siteVals.entries.where(
          (entry) => !entry.key.toLowerCase().startsWith('personnel::'),
        ),
      );
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
  final collectingPersonnel = await CollEventServices(
    ref: ref,
  ).getAllCollPersonnel(s.id);
  final resolvedCollectingPersonnel = await _resolveCollPersonnelNames(
    ref,
    collectingPersonnel,
  );
  final personnel = buildCollPersonnelSummary(resolvedCollectingPersonnel);
  m['collEvent::methods'] = methods;
  m['event::methods'] = methods;
  m['collEvent::personnel'] = personnel;
  m['event::personnel'] = personnel;

  // Add collEffort records
  final efforts = await CollEventServices(ref: ref).getAllCollEffort(s.id);
  if (efforts.isNotEmpty) {
    final Set<String> effortKeys = {};
    final List<Map<String, dynamic>> effortJsons = efforts
        .map((e) => e.toJson())
        .toList();
    for (var effortJson in effortJsons) {
      effortKeys.addAll(effortJson.keys);
    }
    for (var key in effortKeys) {
      final combined = effortJsons
          .map((e) => e[key]?.toString() ?? '')
          .join(writerSeparator);
      m['collEffort::$key'] = combined;
    }
  }

  m.addAll(buildCollPersonnelFieldValues(resolvedCollectingPersonnel));

  try {
    final environment = await CollEventServices(
      ref: ref,
    ).getAllEnvironmentData(s.id);
    for (final entry in environment.toJson().entries) {
      m['environment::${entry.key}'] = entry.value?.toString() ?? '';
    }
  } catch (_) {}

  final customEnvironment = await CustomFieldService(
    db,
  ).getExportEntries(CustomFieldOwner.environment(s.id));
  for (final entry in customEnvironment) {
    m['customEnvironment::${entry.definition.uuid}'] = entry.value == null
        ? ''
        : entry.definition.displayValue(entry.value!.value);
  }

  final links = await CollEventQuery(db).getEventMedia(s.id);
  await _addDocumentMediaValues(
    m,
    links.map((link) => link.mediaId).whereType<int>(),
    ref,
  );

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
    values['collPersonnel::$column'] = rows
        .map((row) => row[column]?.toString() ?? '')
        .join(writerSeparator);
  }
  return values;
}

/// Builds the collecting-event personnel summary from the same event rows used
/// for `collPersonnel::*` template fields.
String buildCollPersonnelSummary(List<CollPersonnelData> personnel) {
  return personnel
      .map((entry) {
        final name = entry.name?.trim() ?? '';
        if (name.isEmpty) return '';
        final role = entry.role?.trim() ?? '';
        return role.isEmpty ? name : '$name;$role';
      })
      .where((value) => value.isNotEmpty)
      .join(writerSeparator);
}

/// Keeps collPersonnel as the event relationship while repairing legacy rows
/// whose cached name was never saved when a person was selected.
Future<List<CollPersonnelData>> _resolveCollPersonnelNames(
  WidgetRef ref,
  List<CollPersonnelData> personnel,
) async {
  return Future.wait(
    personnel.map((entry) async {
      if ((entry.name?.trim().isNotEmpty ?? false) ||
          entry.personnelId == null) {
        return entry;
      }
      try {
        final linked = await PersonnelServices(
          ref: ref,
        ).getPersonnelByUuid(entry.personnelId!);
        return CollPersonnelData(
          id: entry.id,
          eventID: entry.eventID,
          personnelId: entry.personnelId,
          name: linked.name,
          role: entry.role,
        );
      } catch (_) {
        return entry;
      }
    }),
  );
}

Future<String> _getEventEffort(WidgetRef ref, int id) async {
  List<CollEffortData> effort = await CollEventServices(
    ref: ref,
  ).getAllCollEffort(id);
  return effort.map((e) => '"${e.method}";${e.count}').join(writerSeparator);
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
      final p = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(s.writerId!);
      for (var entry in p.toJson().entries) {
        m['personnel::${entry.key}'] = entry.value?.toString() ?? '';
      }
    } catch (_) {}
  }

  final links = await NarrativeServices(ref: ref).getNarrativeMedia(s.id);
  await _addDocumentMediaValues(
    m,
    links.map((link) => link.mediaId).whereType<int>(),
    ref,
  );

  return m;
}

Future<void> _addDocumentMediaValues(
  Map<String, String> values,
  Iterable<int> mediaIds,
  WidgetRef ref,
) async {
  final query = MediaDbQuery(ref.read(databaseProvider));
  final rows = <MediaData>[];
  for (final id in mediaIds.toSet()) {
    try {
      rows.add(await query.getMedia(id));
    } catch (_) {
      // A stale relation must not prevent the rest of the document rendering.
    }
  }
  rows.sort((a, b) => a.primaryId.compareTo(b.primaryId));
  try {
    values[kTemplateMediaField] = await MediaWriterServices(
      ref: ref,
    ).formatMediaData(rows);
  } catch (_) {
    // Picture rendering is independent of optional descriptive metadata.
    values[kTemplateMediaField] = '';
  }

  final imagePaths = <String>[];
  for (final row in rows) {
    final fileName = row.fileName?.trim();
    final category = row.category?.trim();
    final projectUuid = row.projectUuid?.trim();
    if (fileName == null ||
        fileName.isEmpty ||
        category == null ||
        category.isEmpty ||
        projectUuid == null ||
        projectUuid.isEmpty) {
      continue;
    }
    try {
      final file = await MediaFinder(ref: ref).getPathForProjectMedia(
        fileName,
        projectUuid,
        matchMediaCategoryString(category),
      );
      if (!await file.exists()) continue;
      final header = await file
          .openRead(0, 64)
          .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
      final mimeType = lookupMimeType(file.path, headerBytes: header);
      if (mimeType?.startsWith('image/') ?? false) {
        imagePaths.add(file.path);
      }
    } catch (_) {
      // Unsupported categories, unreadable files, and unknown MIME types are
      // intentionally omitted from Picture output.
    }
  }
  values[kTemplatePicturePathsDataKey] = jsonEncode(imagePaths);
}
