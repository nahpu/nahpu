import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/data_table/data_table_query.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/narrative/narrative_services.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/export.dart';

/// One record a linked cell can point at.
class DataTableLinkOption {
  const DataTableLinkOption({
    required this.id,
    required this.label,
    this.detail,
  });

  /// Null for "none", such as a specimen with no event.
  final Object? id;
  final String label;
  final String? detail;
}

/// Edits linked data from the data table: choosing another linked record,
/// or changing the site or event a record shares with others.
///
/// Re-linking goes through the same services the record forms use, so
/// field-number counters, coordinates, and event details stay consistent.
class DataTableLinkService extends AppServices {
  const DataTableLinkService({required super.ref});

  Future<List<DataTableLinkOption>> options(DataTableLink link) async {
    switch (link) {
      case DataTableLink.cataloger:
      case DataTableLink.preparator:
        final people = await PersonnelQuery(
          dbAccess,
        ).getPersonnelByProjectUuid(currentProjectUuid);
        // Same role filters as the specimen form.
        final roles = link == DataTableLink.cataloger
            ? const {'Cataloger'}
            : const {'Cataloger', 'Preparator only'};
        return [
          for (final person in people)
            if (roles.contains(person.role))
              DataTableLinkOption(
                id: person.uuid,
                label: person.name ?? person.uuid,
                detail: [
                  person.role,
                  person.affiliation,
                ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
              ),
        ];
      case DataTableLink.taxon:
        final taxa = await TaxonomyQuery(dbAccess).getTaxonList();
        return [
          for (final taxon in taxa)
            DataTableLinkOption(
              id: taxon.id,
              label: getTaxonDisplayName(taxon),
              detail: [
                taxon.taxonOrder,
                taxon.taxonFamily,
              ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
            ),
        ];
      case DataTableLink.event:
        final sites = {
          for (final site in await SiteQuery(
            dbAccess,
          ).getAllSites(currentProjectUuid))
            site.id: site,
        };
        final events = await CollEventQuery(
          dbAccess,
        ).getAllCollEvents(currentProjectUuid);
        return [
          const DataTableLinkOption(id: null, label: 'No event'),
          for (final event in events)
            DataTableLinkOption(
              id: event.id,
              label: formatCollEventId(event, sites[event.siteID]),
              detail: event.primaryCollMethod,
            ),
        ];
      case DataTableLink.site:
        final sites = await SiteQuery(dbAccess).getAllSites(currentProjectUuid);
        return [
          for (final site in sites)
            DataTableLinkOption(
              id: site.id,
              label: site.siteID ?? 'Site ${site.id}',
              detail: [
                site.geography?.locality,
                site.geography?.stateProvince,
                site.geography?.country,
              ].whereType<String>().where((s) => s.isNotEmpty).join(', '),
            ),
        ];
      case DataTableLink.linkedSite:
      case DataTableLink.linkedEvent:
        return const [];
    }
  }

  /// Points [row]'s [link] at the record with [id].
  Future<void> relink(
    DataTableRecordType type,
    DataTableRecordRow row,
    DataTableLink link,
    Object? id,
  ) async {
    final specimens = SpecimenServices(ref: ref);
    switch (link) {
      case DataTableLink.cataloger:
        await specimens.reassignCataloger(row.key as String, id as String);
      case DataTableLink.preparator:
        await specimens.updateSpecimen(
          row.key as String,
          SpecimenCompanion(preparatorID: db.Value(id as String?)),
        );
      case DataTableLink.taxon:
        await specimens.updateSpecimen(
          row.key as String,
          SpecimenCompanion(speciesID: db.Value(id as int?)),
        );
      case DataTableLink.event:
        // As the specimen form does: the event's method and personnel no
        // longer apply, and the coordinate follows the new event's site.
        final specimen = await specimens.getSpecimen(row.key as String);
        final coordinateId = await CoordinateServices(ref: ref)
            .coordinateIdForEvent(
              id as int?,
              currentCoordinateId: specimen.coordinateID,
            );
        await specimens.updateSpecimen(
          row.key as String,
          SpecimenCompanion(
            collEventID: db.Value(id),
            collMethodID: const db.Value(null),
            collPersonnelID: const db.Value(null),
            coordinateID: db.Value(coordinateId),
          ),
        );
      case DataTableLink.site:
        if (type == DataTableRecordType.events) {
          await CollEventQuery(dbAccess).updateCollEventEntry(
            row.key as int,
            CollEventCompanion(siteID: db.Value(id as int?)),
          );
        } else {
          await NarrativeServices(ref: ref).updateNarrative(
            row.key as int,
            NarrativeCompanion(siteID: db.Value(id as int?)),
          );
        }
      case DataTableLink.linkedSite:
      case DataTableLink.linkedEvent:
        throw ArgumentError.value(link, 'link', 'is not a re-link');
    }
  }

  /// Records in [type] that share the site or event [id]: every one of
  /// them shows an edit made in the linked-record dialog.
  Future<int> sharingCount(
    DataTableRecordType type,
    DataTableLink link,
    int id,
  ) async {
    final sql = switch ((type, link)) {
      (DataTableRecordType.specimenRecords, DataTableLink.linkedEvent) =>
        'SELECT COUNT(*) AS c FROM specimen WHERE collEventID = ?',
      (DataTableRecordType.specimenRecords, _) =>
        'SELECT COUNT(*) AS c FROM specimen s JOIN collEvent ce '
            'ON ce.id = s.collEventID WHERE ce.siteID = ?',
      (DataTableRecordType.events, _) =>
        'SELECT COUNT(*) AS c FROM collEvent WHERE siteID = ?',
      _ => 'SELECT COUNT(*) AS c FROM narrative WHERE siteID = ?',
    };
    final row = await dbAccess
        .customSelect(
          sql,
          variables: [db.Variable.withInt(id)],
          readsFrom: const {},
        )
        .getSingle();
    return row.read<int>('c');
  }

  /// The linked site's or event's own editable fields, with its stored
  /// values.
  Future<(DataTableRecordType, List<DataTableColumn>, Map<String, String>)>
  linkedRecord(DataTableLink link, int id) async {
    final linkedType = link == DataTableLink.linkedSite
        ? DataTableRecordType.sites
        : DataTableRecordType.events;
    final header = link == DataTableLink.linkedSite
        ? siteExportList
        : collEventExportList;
    final columns = [
      for (final column in dataTableColumnsFromHeader(header))
        if (column.isEditableIn(linkedType)) column,
    ];
    final raw = await DataTablePageQuery(
      dbAccess,
    ).rawValues(linkedType, [id], [for (final column in columns) column.field]);
    return (linkedType, columns, raw.values[id] ?? const <String, String>{});
  }

  Future<DataTableSaveResult> saveLinked(
    DataTableRecordType linkedType,
    List<DataTableEdit> edits,
  ) => DataTableSaveService(dbAccess).save(linkedType, edits);
}

/// Labels for [DataTableLink] dialogs.
String dataTableLinkTitle(DataTableLink link) => switch (link) {
  DataTableLink.cataloger => 'Choose cataloger',
  DataTableLink.preparator => 'Choose preparator',
  DataTableLink.taxon => 'Choose taxon',
  DataTableLink.event => 'Choose collecting event',
  DataTableLink.site => 'Choose site',
  DataTableLink.linkedSite => 'Edit site',
  DataTableLink.linkedEvent => 'Edit event',
};
