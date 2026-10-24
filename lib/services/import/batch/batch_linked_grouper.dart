import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_planner.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/import/batch/batch_linked_models.dart';

/// Sorts the rows of a linked import into sites, events, specimens, parts,
/// and parasites.
///
/// Rows that name the same site ID are one site; without an ID, rows with
/// the same locality and coordinates are. Events group the same way, by
/// event ID or by site, dates, and method. Rows with the same catalog
/// number, UUID, or cataloger and field number are one specimen, each row
/// adding its part and parasite. Sites and events that match the project's own start
/// linked to them.
class BatchLinkedGrouper {
  BatchLinkedGrouper({required this.index});

  final BatchImportIndex index;

  late final _targets = {
    for (final target in batchLinkedTargets()) target.key: target,
  };
  late final _specimenKeys = {
    for (final target in batchImportTargets(
      DataTableRecordType.specimenRecords,
    ))
      if (target.key != 'event::collEventID') target.key,
  };

  BatchLinkedPlan group(
    BatchImportTable table,
    List<BatchColumnMatch> matches,
  ) {
    final columns = {
      for (final match in matches)
        if (match.fieldKey != null && _targets.containsKey(match.fieldKey))
          match.fieldKey!: match.column,
    };
    final cells = [
      for (final row in table.rows)
        {
          for (final entry in columns.entries)
            if (row[entry.value].trim().isNotEmpty)
              entry.key: row[entry.value].trim(),
        },
    ];

    final siteRows = <String, List<int>>{};
    final eventRows = <String, List<int>>{};
    final eventSite = <String, String?>{};
    final specimenRows = <String, List<int>>{};
    for (final (row, values) in cells.indexed) {
      final siteKey = _siteKey(values);
      if (siteKey != null) siteRows.putIfAbsent(siteKey, () => []).add(row);
      final eventKey = _eventKey(values, siteKey);
      if (eventKey != null) {
        eventRows.putIfAbsent(eventKey, () => []).add(row);
        eventSite.putIfAbsent(eventKey, () => siteKey);
      }
      final hasSpecimen = values.keys.any(
        (key) =>
            _specimenKeys.contains(key) ||
            batchLinkedSection(key) == BatchLinkedSection.part ||
            batchLinkedSection(key) == BatchLinkedSection.parasite,
      );
      if (hasSpecimen) {
        specimenRows.putIfAbsent(_specimenKey(values, row), () => []).add(row);
      }
    }

    final siteIds = <String, String>{};
    final sites = <BatchSiteGroup>[];
    for (final (n, entry) in siteRows.entries.indexed) {
      final id = 'site-${n + 1}';
      siteIds[entry.key] = id;
      sites.add(_site(id, entry.value, cells));
    }
    final eventIds = <String, String>{};
    final eventOfRow = <int, String>{};
    final events = <BatchEventGroup>[];
    for (final (n, entry) in eventRows.entries.indexed) {
      final id = 'event-${n + 1}';
      eventIds[entry.key] = id;
      for (final row in entry.value) {
        eventOfRow[row] = id;
      }
      final site = sites
          .where((s) => s.id == siteIds[eventSite[entry.key]])
          .firstOrNull;
      events.add(_event(id, entry.value, cells, site));
    }

    final planner = BatchImportPlanner(
      type: DataTableRecordType.specimenRecords,
      mode: BatchImportMode.create,
      index: index,
    );
    final seenSpecimens = <String>{};
    final seenTissues = <String>{};
    final seenParasites = <String>{};
    final specimens = <BatchLinkedSpecimen>[];
    for (final (n, rows) in specimenRows.values.indexed) {
      specimens.add(
        _specimen(
          'specimen-${n + 1}',
          rows,
          cells,
          table.rowNumbers,
          planner,
          eventOfRow,
          seenSpecimens,
          seenTissues,
          seenParasites,
        ),
      );
    }

    return BatchLinkedPlan(
      rowNumbers: table.rowNumbers,
      sites: sites,
      events: events,
      specimens: specimens,
    );
  }

  String? _siteKey(Map<String, String> values) {
    if (values['site::site'] case final siteId?) {
      return 'id:${normalizeBatchId(siteId)}';
    }
    final hasSite = values.keys.any(
      (key) => batchLinkedSection(key) == BatchLinkedSection.site,
    );
    if (!hasSite) return null;
    String coordinate(String key) {
      final number = double.tryParse(values[key] ?? '');
      return number?.toStringAsFixed(5) ?? '';
    }

    return [
      'c',
      for (final key in _localityKeys) normalizeBatchId(values[key] ?? ''),
      coordinate('coordinate::decimalLatitude'),
      coordinate('coordinate::decimalLongitude'),
    ].join('|');
  }

  String? _eventKey(Map<String, String> values, String? siteKey) {
    if (values['event::collEventID'] case final eventId?) {
      return 'id:${normalizeBatchId(eventId)}';
    }
    final hasEvent = values.keys.any(
      (key) => batchLinkedSection(key) == BatchLinkedSection.event,
    );
    if (!hasEvent && siteKey == null) return null;
    return [
      siteKey ?? '',
      _normalized('event::startDate', values),
      _normalized('event::endDate', values),
      _normalized('event::Activity', values),
    ].join('|');
  }

  String _specimenKey(Map<String, String> values, int row) {
    if (values['specimen::specimenUUID'] case final uuid?) {
      return 'uuid:${uuid.toLowerCase()}';
    }
    if (values[batchCatalogNumberKey] case final number?) {
      return 'cat:${normalizeBatchId(number)}';
    }
    final cataloger = values['specimen::cataloger'];
    final number = values['specimen::fieldNumber'];
    if (cataloger != null && number != null) {
      return 'field:${cataloger.toLowerCase()}:${number.trim()}';
    }
    return 'row:$row';
  }

  /// A cell as compared for grouping: dates as YYYY-MM-DD, text without
  /// case or punctuation.
  String _normalized(String key, Map<String, String> values) {
    final raw = values[key];
    if (raw == null) return '';
    final (stored, _) = batchStoredText(dataTableField(key), raw);
    return normalizeBatchId(stored ?? raw);
  }

  BatchSiteGroup _site(
    String id,
    List<int> rows,
    List<Map<String, String>> cells,
  ) {
    final (merged, conflicts) = _merge(
      rows,
      cells,
      (key) => batchLinkedSection(key) == BatchLinkedSection.site,
    );
    final values = <String, String>{};
    final coordinate = <String, String>{};
    final problems = <String>[];
    for (final entry in merged.entries) {
      final target = _targets[entry.key]!;
      if (target.kind == BatchTargetKind.identity) continue;
      final (stored, error) = target.kind == BatchTargetKind.coordinate
          ? batchCoordinateText(entry.key, entry.value)
          : batchStoredText(target.field, entry.value);
      if (error != null) {
        problems.add('${target.label}: $error ("${entry.value}")');
      } else if (target.kind == BatchTargetKind.coordinate) {
        coordinate[entry.key] = stored!;
      } else {
        values[entry.key] = stored!;
      }
    }
    final group = BatchSiteGroup(
      id: id,
      rows: rows,
      values: values,
      coordinate: coordinate,
      siteName: merged['site::site'],
      conflicts: conflicts,
      problems: problems,
    );
    final existing = _existingSite(group);
    if (existing == null) return group;
    return group.copyWith(
      action: BatchGroupAction.linkExisting,
      existingId: () => existing.id,
      existingLabel: () => existing.label,
    );
  }

  BatchSiteRef? _existingSite(BatchSiteGroup group) {
    final name = group.siteName;
    if (name != null) {
      final found = [
        for (final site in index.siteRefs)
          if (normalizeBatchId(site.siteId ?? '') == normalizeBatchId(name))
            site,
      ];
      return found.length == 1 ? found.single : null;
    }
    final locality = group.values['geography::specificLocality'];
    final country = group.values['geography::country'];
    if (locality == null || country == null) return null;
    final latitude = double.tryParse(
      group.coordinate['coordinate::decimalLatitude'] ?? '',
    );
    final longitude = double.tryParse(
      group.coordinate['coordinate::decimalLongitude'] ?? '',
    );
    bool near(double? a, double? b) =>
        (a == null && b == null) ||
        (a != null && b != null && (a - b).abs() < 0.0001);
    final found = [
      for (final site in index.siteRefs)
        if (normalizeBatchId(site.locality ?? '') ==
                normalizeBatchId(locality) &&
            normalizeBatchId(site.country ?? '') == normalizeBatchId(country) &&
            near(site.latitude, latitude) &&
            near(site.longitude, longitude))
          site,
    ];
    return found.length == 1 ? found.single : null;
  }

  BatchEventGroup _event(
    String id,
    List<int> rows,
    List<Map<String, String>> cells,
    BatchSiteGroup? site,
  ) {
    final (merged, conflicts) = _merge(
      rows,
      cells,
      (key) => batchLinkedSection(key) == BatchLinkedSection.event,
    );
    final values = <String, String>{};
    final problems = <String>[];
    for (final entry in merged.entries) {
      final target = _targets[entry.key]!;
      if (target.kind != BatchTargetKind.field) continue;
      final (stored, error) = batchStoredText(target.field, entry.value);
      if (error != null) {
        problems.add('${target.label}: $error ("${entry.value}")');
      } else {
        values[entry.key] = stored!;
      }
    }
    final group = BatchEventGroup(
      id: id,
      rows: rows,
      siteGroupId: site?.id,
      values: values,
      conflicts: conflicts,
      problems: problems,
    );
    final existing = _existingEvent(merged['event::collEventID'], group, site);
    if (existing == null) return group;
    return group.copyWith(
      action: BatchGroupAction.linkExisting,
      existingId: () => existing.id,
      existingLabel: () => existing.label,
    );
  }

  BatchEventRef? _existingEvent(
    String? eventId,
    BatchEventGroup group,
    BatchSiteGroup? site,
  ) {
    if (eventId != null) {
      final found = [
        for (final event in index.eventRefs)
          if (normalizeBatchId(event.label) == normalizeBatchId(eventId)) event,
      ];
      return found.length == 1 ? found.single : null;
    }
    if (site?.action != BatchGroupAction.linkExisting ||
        group.startDate.isEmpty) {
      return null;
    }
    final found = [
      for (final event in index.eventRefs)
        if (event.siteId == site!.existingId &&
            event.startDate == group.startDate &&
            (group.method.isEmpty ||
                normalizeBatchId(event.method ?? '') ==
                    normalizeBatchId(group.method)))
          event,
    ];
    return found.length == 1 ? found.single : null;
  }

  BatchLinkedSpecimen _specimen(
    String id,
    List<int> rows,
    List<Map<String, String>> cells,
    List<int> rowNumbers,
    BatchImportPlanner planner,
    Map<int, String> eventOfRow,
    Set<String> seenSpecimens,
    Set<String> seenTissues,
    Set<String> seenParasites,
  ) {
    final (merged, conflicts) = _merge(rows, cells, _specimenKeys.contains);
    var plan = planner.planCells(
      rowNumbers[rows.first],
      merged,
      seenSpecimens,
      allowEmpty: true,
    );
    final events = {for (final row in rows) eventOfRow[row]};
    final messages = [
      ...plan.messages,
      ...conflicts,
      if (events.length > 1)
        'Its rows name ${events.length} events; the first row\'s is used.',
    ];
    final parts = [
      for (final row in rows)
        if (cells[row].keys.any(
          (key) => batchLinkedSection(key) == BatchLinkedSection.part,
        ))
          BatchLinkedPart(
            row: row,
            plan: _part(rowNumbers[row], cells[row], seenTissues),
          ),
    ];
    final parasites = [
      for (final row in rows)
        if (cells[row].keys.any(
          (key) => batchLinkedSection(key) == BatchLinkedSection.parasite,
        ))
          BatchLinkedParasite(
            row: row,
            plan: _parasite(rowNumbers[row], cells[row], seenParasites),
          ),
    ];
    final eventGroupId = eventOfRow[rows.first];
    if (plan.status.isImportable &&
        plan.values.isEmpty &&
        plan.links.isEmpty &&
        parts.isEmpty &&
        parasites.isEmpty &&
        eventGroupId == null) {
      plan = plan.copyWith(
        status: BatchRowStatus.invalid,
        messages: [...messages, 'No specimen values to write.'],
      );
    } else {
      plan = plan.copyWith(messages: messages);
    }
    return BatchLinkedSpecimen(
      id: id,
      rows: rows,
      plan: plan,
      eventGroupId: eventGroupId,
      parts: parts,
      parasites: parasites,
    );
  }

  BatchRowPlan _part(
    int rowNumber,
    Map<String, String> cells,
    Set<String> seenTissues,
  ) => _child(
    rowNumber,
    cells,
    section: BatchLinkedSection.part,
    label: 'Part',
    idKey: 'part::tissueID',
    idLabel: 'tissue ID',
    existingIds: index.tissueIds,
    seenIds: seenTissues,
  );

  BatchRowPlan _parasite(
    int rowNumber,
    Map<String, String> cells,
    Set<String> seenParasites,
  ) => _child(
    rowNumber,
    cells,
    section: BatchLinkedSection.parasite,
    label: 'Parasite',
    idKey: 'parasite::parasiteID',
    idLabel: 'parasite ID',
    existingIds: index.parasiteIds,
    seenIds: seenParasites,
  );

  /// A record one row adds to its specimen, such as a part. Its ID must be
  /// new to the project and to the file.
  BatchRowPlan _child(
    int rowNumber,
    Map<String, String> cells, {
    required BatchLinkedSection section,
    required String label,
    required String idKey,
    required String idLabel,
    required Map<String, List<int>> existingIds,
    required Set<String> seenIds,
  }) {
    final values = <String, String>{};
    final messages = <String>[];
    var status = BatchRowStatus.ready;
    for (final entry in cells.entries) {
      if (batchLinkedSection(entry.key) != section) continue;
      final target = _targets[entry.key]!;
      if (target.kind != BatchTargetKind.field) continue;
      final (stored, error) = batchStoredText(target.field, entry.value);
      if (error != null) {
        status = BatchRowStatus.invalid;
        messages.add('$label ${target.label}: $error ("${entry.value}")');
      } else {
        values[entry.key] = stored!;
      }
    }
    if (values[idKey] case final value?) {
      final id = normalizeBatchId(value);
      final shown = idLabel[0].toUpperCase() + idLabel.substring(1);
      if (existingIds.containsKey(id)) {
        status = BatchRowStatus.exists;
        messages.insert(0, '$shown $value is already in use.');
      } else if (!seenIds.add(id)) {
        status = BatchRowStatus.duplicateInFile;
        messages.insert(0, 'Another row adds $idLabel $value.');
      }
    }
    return BatchRowPlan(
      rowNumber: rowNumber,
      status: status,
      messages: messages,
      values: values,
    );
  }

  /// One value per field across [rows]: the most common, or the first
  /// among equally common ones. Fields the rows disagree on are reported.
  (Map<String, String>, List<String>) _merge(
    List<int> rows,
    List<Map<String, String>> cells,
    bool Function(String key) includes,
  ) {
    final counts = <String, Map<String, (String, int)>>{};
    for (final row in rows) {
      for (final entry in cells[row].entries) {
        if (!includes(entry.key)) continue;
        final byValue = counts.putIfAbsent(entry.key, () => {});
        final normalized = entry.value.toLowerCase();
        final (raw, count) = byValue[normalized] ?? (entry.value, 0);
        byValue[normalized] = (raw, count + 1);
      }
    }
    final merged = <String, String>{};
    final conflicts = <String>[];
    for (final entry in counts.entries) {
      final choices = entry.value.values.toList();
      var best = choices.first;
      for (final choice in choices) {
        if (choice.$2 > best.$2) best = choice;
      }
      merged[entry.key] = best.$1;
      if (choices.length > 1) {
        final label = _targets[entry.key]?.label ?? entry.key;
        conflicts.add(
          '$label differs between rows: '
          '${choices.map((c) => '${c.$1} (${c.$2})').join(', ')}. '
          'Using ${best.$1}.',
        );
      }
    }
    return (merged, conflicts);
  }
}

const _localityKeys = [
  'geography::country',
  'geography::islandGroup',
  'geography::stateProvince',
  'geography::county',
  'geography::municipality',
  'geography::specificLocality',
];
