import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/data_table/data_table_query.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/export/coll_event_writer.dart';
import 'package:nahpu/services/export/collecting_records.dart';
import 'package:nahpu/services/export/narrative_writer.dart';
import 'package:nahpu/services/export/parasite_records.dart';
import 'package:nahpu/services/export/record_writer.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/services/export/specimen_part_records.dart';
import 'package:nahpu/services/narrative/narrative_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/file_format.dart';

export 'package:nahpu/services/data_table/data_table_models.dart';

/// Loads one page of current-project records, or of every project's when the
/// query asks for all projects, as the tabular exports write them.
///
/// Filtering, sorting, and paging happen in SQL; only the page's records
/// are then built through the export writers.
class DataTableService extends AppServices {
  const DataTableService({required super.ref});

  Future<DataTablePageData> fetchPage(
    DataTableRecordType type,
    DataTableQuery query, {
    SpecimenRecordType specimenType = SpecimenRecordType.allTaxa,
  }) async {
    final projectUuid = query.allProjects ? null : currentProjectUuid;
    // Bat columns only when a mammal in scope has bat data.
    final includeBatFields =
        type == DataTableRecordType.specimenRecords &&
        (specimenType == SpecimenRecordType.mammals ||
            specimenType == SpecimenRecordType.allTaxa) &&
        await SpecimenQuery(dbAccess).hasBatMeasurements(
          projectUuid: projectUuid,
          projectUuids: query.projectUuids,
        );
    final header = _header(type, specimenType, includeBatFields);
    final columns = dataTableColumnsFromHeader(header);
    final pageQuery = DataTablePageQuery(dbAccess);
    final keys = await pageQuery.run(
      type,
      query,
      projectUuid: projectUuid,
      taxa: specimenType,
    );
    final editable = [
      for (final column in columns)
        if (column.isEditableIn(type)) column.field,
    ];
    final raw = await pageQuery.rawValues(type, keys.keys, editable);
    final media = await pageQuery.mediaFiles(type, keys.keys);
    final rows = <DataTableRecordRow>[];
    for (final key in keys.keys) {
      final values = await _rowValues(
        type,
        key,
        specimenType,
        includeBatFields,
      );
      rows.add(
        DataTableRecordRow(
          key: key,
          values: dataTableRowFromValues(header, values),
          raw: raw.values[key] ?? const {},
          attributeTable: raw.attributes[key],
          siteId: raw.siteIds[key],
          eventId: raw.eventIds[key],
          specimenUuid: raw.specimenUuids[key],
          projectUuid: raw.projectUuids[key],
          mediaKinds: dataTableMediaKinds(media[key] ?? const []),
        ),
      );
    }
    return DataTablePageData(
      columns: columns,
      rows: rows,
      totalRows: keys.totalRows,
      page: keys.page,
      pageCount: keys.pageCount,
      rowsPerPage: query.rowsPerPage,
    );
  }

  /// Stored values of every record the query matches, across all pages, for
  /// a replace that reaches past the page on screen. Rows hold only their
  /// key, stored values, and attribute table.
  Future<List<DataTableRecordRow>> fetchRawRows(
    DataTableRecordType type,
    DataTableQuery query, {
    required List<DataTableColumn> columns,
    SpecimenRecordType specimenType = SpecimenRecordType.allTaxa,
  }) async {
    final projectUuid = query.allProjects ? null : currentProjectUuid;
    final pageQuery = DataTablePageQuery(dbAccess);
    final editable = [
      for (final column in columns)
        if (column.isEditableIn(type)) column.field,
    ];
    final rows = <DataTableRecordRow>[];
    for (var page = 0; ; page++) {
      final keys = await pageQuery.run(
        type,
        query.copyWith(page: page, rowsPerPage: dataTableRawRowBatch),
        projectUuid: projectUuid,
        taxa: specimenType,
      );
      final raw = await pageQuery.rawValues(type, keys.keys, editable);
      for (final key in keys.keys) {
        rows.add(
          DataTableRecordRow(
            key: key,
            values: const {},
            raw: raw.values[key] ?? const {},
            attributeTable: raw.attributes[key],
          ),
        );
      }
      if (page + 1 >= keys.pageCount) break;
    }
    return rows;
  }

  List<String> _header(
    DataTableRecordType type,
    SpecimenRecordType taxa,
    bool includeBatFields,
  ) => switch (type) {
    DataTableRecordType.specimenRecords => SpecimenRecordWriter(
      ref: ref,
      recordType: taxa,
      includeBatFields: includeBatFields,
    ).header,
    DataTableRecordType.specimenParts => SpecimenPartWriter.header,
    DataTableRecordType.parasites => ParasiteWriter.header,
    DataTableRecordType.sites => SiteWriterServices.header,
    DataTableRecordType.events => CollEventRecordWriter.header,
    DataTableRecordType.narrative => narrativeExportList,
  };

  Future<List<String>> _rowValues(
    DataTableRecordType type,
    Object key,
    SpecimenRecordType taxa,
    bool includeBatFields,
  ) async {
    switch (type) {
      case DataTableRecordType.specimenRecords:
        final specimen = await SpecimenServices(
          ref: ref,
        ).getSpecimen(key as String);
        final rows = await SpecimenRecordWriter(
          ref: ref,
          recordType: taxa,
          includeBatFields: includeBatFields,
        ).getRowsForSpecimen(specimen);
        return rows.isEmpty ? const [] : rows.first;
      case DataTableRecordType.specimenParts:
        final part = await (dbAccess.select(
          dbAccess.specimenPart,
        )..where((t) => t.id.equals(key as int))).getSingle();
        final partValues = await SpecimenPartWriterServices(
          ref: ref,
          isWithLabel: false,
        ).getPart(part, true);
        final specimen = await SpecimenServices(
          ref: ref,
        ).getSpecimen(part.specimenUuid!);
        final collecting = await CollectingRecordWriterServices(
          ref: ref,
        ).getRecord(specimen);
        return [...partValues, ...collecting];
      case DataTableRecordType.parasites:
        final parasite = await (dbAccess.select(
          dbAccess.parasite,
        )..where((t) => t.id.equals(key as int))).getSingle();
        final specimen = await SpecimenServices(
          ref: ref,
        ).getSpecimen(parasite.specimenUuid!);
        return ParasiteWriter(ref: ref).getRow(parasite, specimen);
      case DataTableRecordType.sites:
        return SiteWriterServices(ref: ref).getSiteRow(key as int);
      case DataTableRecordType.events:
        return CollEventRecordWriter(
          ref: ref,
        ).getCOllEventSiteDetails(key as int);
      case DataTableRecordType.narrative:
        final NarrativeData narrative = await NarrativeServices(
          ref: ref,
        ).getNarrative(key as int);
        return NarrativeRecordWriter(ref: ref).getNarrative(narrative);
    }
  }
}

/// Records read per query by [DataTableService.fetchRawRows].
const int dataTableRawRowBatch = 500;

/// The image, audio, and video kinds among [files].
Set<MediaKind> dataTableMediaKinds(Iterable<String> files) =>
    {for (final file in files) matchMediaKindFromPath(file)}
      ..remove(MediaKind.other);

/// Pairs export [values] with their [header] keys.
Map<String, String> dataTableRowFromValues(
  List<String> header,
  List<String> values,
) {
  return {
    for (var i = 0; i < header.length; i++)
      header[i]: i < values.length ? values[i].trim() : '',
  };
}
