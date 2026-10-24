import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_link_service.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_service.dart';
import 'package:nahpu/services/import/batch/batch_linked_grouper.dart';
import 'package:nahpu/services/import/batch/batch_linked_models.dart';
import 'package:nahpu/services/sites/site_services.dart';

class BatchLinkedResult {
  const BatchLinkedResult({
    required this.newSites,
    required this.linkedSites,
    required this.newEvents,
    required this.linkedEvents,
    required this.specimens,
    required this.parts,
    this.parasites = 0,
    required this.errors,
  });

  final int newSites;
  final int linkedSites;
  final int newEvents;
  final int linkedEvents;
  final int specimens;
  final int parts;
  final int parasites;

  /// Messages by file row number for rows that failed to write.
  final Map<int, String> errors;
}

/// Groups and writes a linked import into the open project: sites first,
/// then events at them, then specimens at those events, then their parts
/// and parasites.
///
/// Each record is written in its own transaction. When a record fails,
/// records that depend on it are skipped and reported, and the rest go on.
class BatchLinkedService extends AppServices {
  const BatchLinkedService({required super.ref});

  Future<BatchLinkedPlan> group(
    BatchImportTable table,
    List<BatchColumnMatch> matches,
  ) async {
    final index = await BatchImportIndex.load(dbAccess, currentProjectUuid);
    return BatchLinkedGrouper(index: index).group(table, matches);
  }

  Future<BatchLinkedResult> apply(
    BatchLinkedPlan plan, {
    bool includeMissingLinks = true,
    void Function(int done, int total)? onProgress,
  }) async {
    final usedSites = plan.usedSites(includeMissingLinks: includeMissingLinks);
    final usedEvents = plan.usedEvents(
      includeMissingLinks: includeMissingLinks,
    );
    final specimens = plan.writableSpecimens(
      includeMissingLinks: includeMissingLinks,
    );
    final sites = [
      for (final site in plan.sites)
        if (usedSites.contains(site.id)) site,
    ];
    final events = [
      for (final event in plan.events)
        if (usedEvents.contains(event.id)) event,
    ];
    final total =
        sites.length +
        events.length +
        specimens.fold<int>(
          0,
          (n, s) =>
              n +
              1 +
              plan.writableParts(s).length +
              plan.writableParasites(s).length,
        );
    var done = 0;
    void step() => onProgress?.call(++done, total);

    final errors = <int, String>{};
    void fail(List<int> rows, String message) {
      for (final row in rows) {
        if (plan.isRowIncluded(row)) {
          errors.putIfAbsent(plan.rowNumbers[row], () => message);
        }
      }
    }

    final siteIds = <String, int>{};
    var newSites = 0;
    for (final site in sites) {
      if (site.action == BatchGroupAction.linkExisting) {
        siteIds[site.id] = site.existingId!;
      } else {
        try {
          siteIds[site.id] = await dbAccess.transaction(
            () => _createSite(site),
          );
          newSites++;
        } catch (e) {
          fail(site.rows, 'Site ${site.label}: ${_message(e)}');
        }
      }
      step();
    }

    final eventIds = <String, int>{};
    var newEvents = 0;
    for (final event in events) {
      if (event.action == BatchGroupAction.linkExisting) {
        eventIds[event.id] = event.existingId!;
      } else if (event.siteGroupId != null &&
          !siteIds.containsKey(event.siteGroupId)) {
        fail(event.rows, 'Skipped: its site couldn\'t be written.');
      } else {
        try {
          eventIds[event.id] = await dbAccess.transaction(
            () => _createEvent(event, siteIds[event.siteGroupId]),
          );
          newEvents++;
        } catch (e) {
          fail(event.rows, 'Event: ${_message(e)}');
        }
      }
      step();
    }

    final records = BatchImportService(ref: ref);
    var written = 0;
    var parts = 0;
    var parasites = 0;
    for (final specimen in specimens) {
      final eventGroup = specimen.eventGroupId;
      final partsToWrite = plan.writableParts(specimen);
      final parasitesToWrite = plan.writableParasites(specimen);
      if (eventGroup != null && !eventIds.containsKey(eventGroup)) {
        fail(specimen.rows, 'Skipped: its event couldn\'t be written.');
        done += partsToWrite.length + parasitesToWrite.length;
        step();
        continue;
      }
      final String uuid;
      try {
        final links = {
          ...specimen.plan.links,
          if (eventGroup != null) DataTableLink.event: eventIds[eventGroup]!,
        };
        uuid =
            await dbAccess.transaction(
                  () => records.createRecord(
                    DataTableRecordType.specimenRecords,
                    specimen.plan.copyWith(links: links),
                  ),
                )
                as String;
        written++;
      } catch (e) {
        fail(specimen.rows, 'Specimen: ${_message(e)}');
        done += partsToWrite.length + parasitesToWrite.length;
        step();
        continue;
      }
      step();
      for (final part in partsToWrite) {
        try {
          await dbAccess.transaction(
            () => records.createRecord(
              DataTableRecordType.specimenParts,
              part.plan.copyWith(parentSpecimenUuid: uuid),
            ),
          );
          parts++;
        } catch (e) {
          fail([part.row], 'Part: ${_message(e)}');
        }
        step();
      }
      for (final parasite in parasitesToWrite) {
        try {
          await dbAccess.transaction(
            () => records.createRecord(
              DataTableRecordType.parasites,
              parasite.plan.copyWith(parentSpecimenUuid: uuid),
            ),
          );
          parasites++;
        } catch (e) {
          fail([parasite.row], 'Parasite: ${_message(e)}');
        }
        step();
      }
    }

    records.invalidateRecordLists();
    return BatchLinkedResult(
      newSites: newSites,
      linkedSites: sites
          .where((s) => s.action == BatchGroupAction.linkExisting)
          .length,
      newEvents: newEvents,
      linkedEvents: events
          .where((e) => e.action == BatchGroupAction.linkExisting)
          .length,
      specimens: written,
      parts: parts,
      parasites: parasites,
      errors: errors,
    );
  }

  String _message(Object error) =>
      error is FormatException ? error.message : '$error';

  Future<int> _createSite(BatchSiteGroup site) async {
    final id = await SiteServices(ref: ref).createNewSite();
    if (site.siteName != null) {
      await SiteQuery(
        dbAccess,
      ).updateSiteEntry(id, SiteCompanion(siteID: db.Value(site.siteName)));
    }
    await _save(DataTableRecordType.sites, id, site.values);
    if (site.coordinate.isNotEmpty) {
      final c = site.coordinate;
      double? real(String key) => double.tryParse(c['coordinate::$key'] ?? '');
      await CoordinateServices(ref: ref).createCoordinate(
        CoordinateCompanion(
          siteID: db.Value(id),
          nameId: db.Value(c['coordinate::nameId']),
          decimalLatitude: db.Value(real('decimalLatitude')),
          decimalLongitude: db.Value(real('decimalLongitude')),
          elevationInMeter: db.Value(real('elevationInMeter')),
          uncertaintyInMeters: db.Value(
            int.tryParse(c['coordinate::uncertaintyInMeters'] ?? ''),
          ),
          datum: db.Value(c['coordinate::datum']),
        ),
      );
    }
    return id;
  }

  Future<int> _createEvent(BatchEventGroup event, int? siteId) async {
    final id = await CollEventServices(ref: ref).createNewCollEvents();
    if (siteId != null) {
      await DataTableLinkService(ref: ref).relink(
        DataTableRecordType.events,
        DataTableRecordRow(key: id, values: const {}),
        DataTableLink.site,
        siteId,
      );
    }
    if (event.idSuffix != null) {
      await CollEventQuery(dbAccess).updateCollEventEntry(
        id,
        CollEventCompanion(idSuffix: db.Value(event.idSuffix)),
      );
    }
    await _save(DataTableRecordType.events, id, event.values);
    return id;
  }

  Future<void> _save(
    DataTableRecordType type,
    Object key,
    Map<String, String> values,
  ) async {
    if (values.isEmpty) return;
    final result = await DataTableSaveService(dbAccess).save(type, [
      for (final entry in values.entries)
        DataTableEdit(
          cell: DataTableCellId(key, entry.key),
          field: dataTableField(entry.key),
          value: entry.value,
        ),
    ]);
    if (result.errors.isNotEmpty) {
      final entry = result.errors.entries.first;
      throw FormatException(
        '${entry.key.fieldKey.split('::').last}: ${entry.value}',
      );
    }
  }
}
