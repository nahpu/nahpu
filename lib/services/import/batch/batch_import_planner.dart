import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Decides what a batch import does with each file row, before anything is
/// written: which record it updates or what it creates, which values are
/// valid, and which linked records exist.
class BatchImportPlanner {
  BatchImportPlanner({
    required this.type,
    required this.mode,
    required this.index,
    this.key,
  }) : _targets = {
         for (final target in batchImportTargets(type)) target.key: target,
       };

  final DataTableRecordType type;
  final BatchImportMode mode;
  final BatchImportIndex index;

  /// How rows find their record; required to update.
  final BatchImportKey? key;
  final Map<String, BatchImportTarget> _targets;

  BatchImportReview review(
    BatchImportTable table,
    List<BatchColumnMatch> matches,
  ) {
    final columns = {
      for (final match in matches)
        if (match.fieldKey != null && _targets.containsKey(match.fieldKey))
          match.fieldKey!: match.column,
    };
    final seenKeys = <String>{};
    final rows = <BatchRowPlan>[];
    for (final (index, cells) in table.rows.indexed) {
      final values = {
        for (final entry in columns.entries)
          if (cells[entry.value].trim().isNotEmpty)
            entry.key: cells[entry.value].trim(),
      };
      rows.add(planCells(table.rowNumbers[index], values, seenKeys));
    }
    return BatchImportReview(type: type, mode: mode, key: key, rows: rows);
  }

  /// Plans one row from its non-blank [cells] by field key. [seenKeys]
  /// collects the identities of rows planned so far, to find repeats.
  ///
  /// [allowEmpty] keeps a row that writes nothing of its own, such as a
  /// linked import's specimen that only joins an event and holds parts.
  BatchRowPlan planCells(
    int rowNumber,
    Map<String, String> cells,
    Set<String> seenKeys, {
    bool allowEmpty = false,
  }) {
    final messages = <String>[];
    final values = <String, String>{};
    final links = <DataTableLink, Object>{};
    var invalid = false;
    var missingLink = false;

    // Key columns only find the record in an update; they aren't written.
    final keyFields = mode == BatchImportMode.update
        ? {...?key?.fieldKeys}
        : const <String>{};

    for (final entry in cells.entries) {
      final target = _targets[entry.key]!;
      if (target.kind != BatchTargetKind.field ||
          keyFields.contains(entry.key)) {
        continue;
      }
      final (stored, error) = batchStoredText(target.field, entry.value);
      if (error != null) {
        invalid = true;
        messages.add('${target.label}: $error ("${entry.value}")');
      } else {
        values[entry.key] = stored!;
      }
    }

    for (final link in {
      for (final entry in cells.keys) ?_targets[entry]!.link,
    }) {
      if (link == DataTableLink.cataloger &&
          keyFields.contains('specimen::cataloger')) {
        continue;
      }
      final (id, problem) = _resolveLink(link, cells);
      if (id != null) {
        links[link] = id;
      } else if (problem != null) {
        missingLink = true;
        messages.add(problem);
      }
    }

    int? fieldNumber;
    String? siteName;
    String? parent;
    Object? recordKey;
    BatchRowStatus? blocking;

    if (mode == BatchImportMode.update) {
      final (found, status, message, identity) = _findRecord(cells);
      if (status != null) {
        blocking = status;
        messages.insert(0, message!);
      } else if (!seenKeys.add('$found')) {
        blocking = BatchRowStatus.duplicateInFile;
        messages.insert(0, 'Another row updates the same record ($identity).');
      }
      recordKey = found;
      if (type == DataTableRecordType.specimenRecords && found != null) {
        invalid |= _dropUnrecorded(found as String, values, messages);
      }
    } else {
      switch (type) {
        case DataTableRecordType.specimenRecords:
          final number = cells['specimen::fieldNumber'];
          if (number != null) {
            fieldNumber = int.tryParse(number);
            if (fieldNumber == null) {
              invalid = true;
              messages.add('Field number: Enter a whole number ("$number")');
            } else if (!links.containsKey(DataTableLink.cataloger)) {
              messages.add('Field number is set only with a cataloger.');
            }
          }
          final existing = _existingSpecimen(
            cells,
            links[DataTableLink.cataloger] as String?,
            fieldNumber,
          );
          if (existing != null) {
            blocking = BatchRowStatus.exists;
            messages.insert(0, 'Specimen $existing is already in the project.');
          } else if (_specimenIdentity(cells, links, fieldNumber)
              case final identity? when !seenKeys.add(identity)) {
            blocking = BatchRowStatus.duplicateInFile;
            messages.insert(0, 'Another row adds the same specimen.');
          }
        case DataTableRecordType.specimenParts:
          final (found, status, message) = _findSpecimen(cells);
          if (status != null) {
            blocking = status;
            messages.insert(0, 'Parent specimen: $message');
          }
          parent = found;
          final tissue = cells['part::tissueID'];
          if (tissue != null) {
            final id = normalizeBatchId(tissue);
            if (index.tissueIds.containsKey(id)) {
              blocking ??= BatchRowStatus.exists;
              messages.insert(0, 'Tissue ID $tissue is already in use.');
            } else if (!seenKeys.add(id)) {
              blocking ??= BatchRowStatus.duplicateInFile;
              messages.insert(0, 'Another row adds tissue ID $tissue.');
            }
          }
        case DataTableRecordType.sites:
          siteName = cells['site::site'];
          if (siteName != null) {
            final id = normalizeBatchId(siteName);
            if (index.sites.containsKey(id)) {
              blocking = BatchRowStatus.exists;
              messages.insert(0, 'Site $siteName is already in the project.');
            } else if (!seenKeys.add(id)) {
              blocking = BatchRowStatus.duplicateInFile;
              messages.insert(0, 'Another row adds site $siteName.');
            }
          }
        case DataTableRecordType.events:
          final eventId = cells['event::collEventID'];
          if (eventId != null &&
              index.events.containsKey(normalizeBatchId(eventId))) {
            blocking = BatchRowStatus.exists;
            messages.insert(0, 'Event $eventId is already in the project.');
          }
        case DataTableRecordType.narrative:
          break;
      }
    }

    final status =
        blocking ??
        (invalid
            ? BatchRowStatus.invalid
            : missingLink
            ? BatchRowStatus.missingLink
            : BatchRowStatus.ready);
    final nothingToWrite =
        values.isEmpty &&
        links.isEmpty &&
        fieldNumber == null &&
        siteName == null &&
        parent == null;
    if (status.isImportable && nothingToWrite && !allowEmpty) {
      return BatchRowPlan(
        rowNumber: rowNumber,
        status: BatchRowStatus.invalid,
        messages: [...messages, 'No values to write.'],
      );
    }
    return BatchRowPlan(
      rowNumber: rowNumber,
      status: status,
      messages: messages,
      recordKey: recordKey,
      values: values,
      links: links,
      fieldNumber: fieldNumber,
      siteName: siteName,
      parentSpecimenUuid: parent,
    );
  }

  /// Removes measurements [values] has that the specimen's taxon group
  /// doesn't record, such as a bird's total length. True when any were.
  bool _dropUnrecorded(
    String uuid,
    Map<String, String> values,
    List<String> messages,
  ) {
    final table = index.specimens
        .firstWhere((s) => s.uuid == uuid)
        .attributeTable;
    final unrecorded = [
      for (final key in values.keys)
        if (key.startsWith('measurement::') &&
            !dataTableField(key).attributeTables.any((t) => t.table == table))
          key,
    ];
    for (final key in unrecorded) {
      values.remove(key);
      messages.add(
        '${_targets[key]!.label} isn\'t recorded for this specimen\'s taxon '
        'group.',
      );
    }
    return unrecorded.isNotEmpty;
  }

  /// The record an update row names: (record key, failure status, message,
  /// identity shown to the user).
  (Object?, BatchRowStatus?, String?, String) _findRecord(
    Map<String, String> cells,
  ) {
    final key = this.key;
    if (key == null) {
      return (null, BatchRowStatus.noMatch, 'Choose a key column.', '');
    }
    final identity = key.fieldKeys.map((k) => cells[k] ?? '').join(' ');
    if (key.fieldKeys.any((k) => cells[k] == null)) {
      return (
        null,
        BatchRowStatus.noMatch,
        'The ${key.label.toLowerCase()} is blank.',
        identity,
      );
    }
    List<Object> found;
    switch (key) {
      case BatchImportKey.specimenUuid:
      case BatchImportKey.catalogNumber:
      case BatchImportKey.catalogerFieldNumber:
        found = _specimensBy(key, cells);
      case BatchImportKey.tissueId:
        found =
            index.tissueIds[normalizeBatchId(cells['part::tissueID']!)] ??
            const [];
      case BatchImportKey.barcodeId:
        found =
            index.barcodeIds[normalizeBatchId(cells['part::barcodeID']!)] ??
            const [];
      case BatchImportKey.siteId:
        found = index.sites[normalizeBatchId(cells['site::site']!)] ?? const [];
      case BatchImportKey.eventId:
        found =
            index.events[normalizeBatchId(cells['event::collEventID']!)] ??
            const [];
      case BatchImportKey.narrativeDate:
        found =
            index.narrativeDates[normalizeBatchId(cells['narrative::date']!)] ??
            const [];
    }
    if (found.isEmpty) {
      return (
        null,
        BatchRowStatus.noMatch,
        'No record has ${key.label.toLowerCase()} $identity.',
        identity,
      );
    }
    if (found.length > 1) {
      return (
        null,
        BatchRowStatus.ambiguous,
        '${found.length} records have ${key.label.toLowerCase()} $identity.',
        identity,
      );
    }
    return (found.single, null, null, identity);
  }

  List<Object> _specimensBy(BatchImportKey key, Map<String, String> cells) {
    switch (key) {
      case BatchImportKey.specimenUuid:
        final uuid = cells['specimen::specimenUUID']!.toLowerCase();
        return [
          for (final s in index.specimens)
            if (s.uuid.toLowerCase() == uuid) s.uuid,
        ];
      case BatchImportKey.catalogNumber:
        final number = normalizeBatchId(cells[batchCatalogNumberKey]!);
        return [
          for (final s in index.specimens)
            if (s.catalogNumber.isNotEmpty && s.catalogNumber == number) s.uuid,
        ];
      case BatchImportKey.catalogerFieldNumber:
        final people = _people(cells['specimen::cataloger']!);
        final number = int.tryParse(cells['specimen::fieldNumber']!);
        return [
          for (final s in index.specimens)
            if (number != null &&
                s.fieldNumber == number &&
                people.contains(s.catalogerUuid))
              s.uuid,
        ];
      default:
        return const [];
    }
  }

  /// A part's parent specimen, by whichever specimen key the file has.
  (String?, BatchRowStatus?, String?) _findSpecimen(Map<String, String> cells) {
    final keys = [
      BatchImportKey.specimenUuid,
      BatchImportKey.catalogNumber,
      BatchImportKey.catalogerFieldNumber,
    ].where((k) => k.fieldKeys.every(cells.containsKey));
    if (keys.isEmpty) {
      return (null, BatchRowStatus.noMatch, 'no specimen UUID or number.');
    }
    final found = _specimensBy(keys.first, cells);
    if (found.isEmpty) {
      return (null, BatchRowStatus.noMatch, 'no specimen matches.');
    }
    if (found.length > 1) {
      return (
        null,
        BatchRowStatus.ambiguous,
        '${found.length} specimens match.',
      );
    }
    return (found.single as String, null, null);
  }

  /// The catalog number of a specimen already in the project that a new
  /// row repeats, if any.
  String? _existingSpecimen(
    Map<String, String> cells,
    String? catalogerUuid,
    int? fieldNumber,
  ) {
    final uuid = cells['specimen::specimenUUID']?.toLowerCase();
    final number = cells[batchCatalogNumberKey];
    for (final s in index.specimens) {
      if (uuid != null && s.uuid.toLowerCase() == uuid) return s.uuid;
      if (number != null &&
          s.catalogNumber.isNotEmpty &&
          s.catalogNumber == normalizeBatchId(number)) {
        return number;
      }
      if (catalogerUuid != null &&
          fieldNumber != null &&
          s.catalogerUuid == catalogerUuid &&
          s.fieldNumber == fieldNumber) {
        return '${cells['specimen::cataloger']} $fieldNumber';
      }
    }
    return null;
  }

  String? _specimenIdentity(
    Map<String, String> cells,
    Map<DataTableLink, Object> links,
    int? fieldNumber,
  ) {
    if (cells['specimen::specimenUUID'] case final uuid?) {
      return 'uuid:${uuid.toLowerCase()}';
    }
    if (cells[batchCatalogNumberKey] case final number?) {
      return 'cat:${normalizeBatchId(number)}';
    }
    final cataloger = links[DataTableLink.cataloger];
    if (cataloger != null && fieldNumber != null) {
      return 'field:$cataloger:$fieldNumber';
    }
    return null;
  }

  /// The id a link resolves to, or a message when it names a record the
  /// project doesn't have. Both null when the row doesn't set the link.
  (Object?, String?) _resolveLink(
    DataTableLink link,
    Map<String, String> cells,
  ) {
    switch (link) {
      case DataTableLink.cataloger:
      case DataTableLink.preparator:
        final key = link == DataTableLink.cataloger
            ? 'specimen::cataloger'
            : 'specimen::preparator';
        final name = cells[key];
        if (name == null) return (null, null);
        final people = _people(name);
        if (people.length == 1) return (people.single, null);
        final role = link == DataTableLink.cataloger
            ? 'Cataloger'
            : 'Preparator';
        return (
          null,
          people.isEmpty
              ? '$role $name isn\'t in the project personnel.'
              : '$role $name matches ${people.length} people.',
        );
      case DataTableLink.taxon:
        return _resolveTaxon(cells);
      case DataTableLink.event:
        final id = cells['event::collEventID'];
        if (id == null) return (null, null);
        final events = index.events[normalizeBatchId(id)] ?? const [];
        if (events.length == 1) return (events.single, null);
        return (
          null,
          events.isEmpty
              ? 'Event $id isn\'t in the project.'
              : 'Event $id matches ${events.length} events.',
        );
      case DataTableLink.site:
        final id = cells['site::site'] ?? cells['narrative::verbatimLocality'];
        if (id == null) return (null, null);
        final sites = index.sites[normalizeBatchId(id)] ?? const [];
        if (sites.length == 1) return (sites.single, null);
        return (
          null,
          sites.isEmpty
              ? 'Site $id isn\'t in the project.'
              : 'Site $id matches ${sites.length} sites.',
        );
      case DataTableLink.linkedSite:
      case DataTableLink.linkedEvent:
        return (null, null);
    }
  }

  (Object?, String?) _resolveTaxon(Map<String, String> cells) {
    var genus = cells['specimen::genus'];
    var epithet = cells['specimen::specificEpithet'];
    final scientificName = cells[batchScientificNameKey];
    if (scientificName != null) {
      final words = scientificName.split(RegExp(r'\s+'));
      genus ??= words.first;
      if (words.length > 1 && words[1] == words[1].toLowerCase()) {
        epithet ??= words[1];
      }
    }
    final family = cells['specimen::family'];
    final order = cells['specimen::order'];
    if (genus == null) {
      if (family == null && order == null) return (null, null);
      return (null, 'Taxon needs a genus to be found.');
    }
    bool same(String? stored, String? given) =>
        given == null ||
        stored == null ||
        stored.trim().toLowerCase() == given.toLowerCase();
    final matches = <TaxonomyData>[
      for (final taxon in index.taxa)
        if (taxon.genus?.trim().toLowerCase() == genus.toLowerCase() &&
            (epithet == null
                ? (taxon.specificEpithet ?? '').trim().isEmpty
                : taxon.specificEpithet?.trim().toLowerCase() ==
                      epithet.toLowerCase()) &&
            same(taxon.taxonFamily, family) &&
            same(taxon.taxonOrder, order))
          taxon,
    ];
    final name = [genus, ?epithet].join(' ');
    if (matches.length == 1) return (matches.single.id, null);
    return (
      null,
      matches.isEmpty
          ? 'Taxon $name isn\'t in the taxonomy list.'
          : 'Taxon $name matches ${matches.length} taxa.',
    );
  }

  /// People whose name or initials match [text].
  List<String> _people(String text) {
    final query = text.trim().toLowerCase();
    final byName = [
      for (final person in index.people)
        if (person.name?.trim().toLowerCase() == query) person.uuid,
    ];
    if (byName.isNotEmpty) return byName;
    return [
      for (final person in index.people)
        if (person.initial?.trim().toLowerCase() == query) person.uuid,
    ];
  }
}

/// The text to store for [raw] in [field], or the reason it doesn't fit.
/// Coded fields take a label ("Male") as well as a code.
(String?, String?) batchStoredText(DataTableField field, String raw) {
  var value = raw.trim();
  if (field.valueType == DataTableValueType.coded) {
    final code = field.codeForInput(value) ?? _sexLetterCode(field, value);
    if (code == null) {
      final labels = field.codes.map((c) => c.$2).take(6).join(', ');
      return (null, 'Choose one of $labels');
    }
    value = '$code';
  } else if (field.valueType == DataTableValueType.date) {
    value = _isoDate(value) ?? value;
  }
  try {
    dataTableStoredValue(field, value);
    return (value, null);
  } on FormatException catch (e) {
    return (null, e.message);
  }
}

/// The sex for a letter such as "M" or "F?", as labels print it.
int? _sexLetterCode(DataTableField field, String text) {
  if (field.column != 'sex') return null;
  final letter = text.toUpperCase();
  for (final entry in specimenSexLetter.entries) {
    if (entry.value == letter) return specimenSexCode[entry.key];
  }
  return null;
}

/// Reads dates written with slashes or dots, or with a time, as
/// YYYY-MM-DD.
String? _isoDate(String text) {
  final match = RegExp(
    r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})',
  ).firstMatch(text);
  if (match == null) return null;
  final month = match[2]!.padLeft(2, '0');
  final day = match[3]!.padLeft(2, '0');
  return '${match[1]}-$month-$day';
}
