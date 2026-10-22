import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_link_service.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/data_table/data_table_query.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/import/batch/batch_import_index.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_planner.dart';
import 'package:nahpu/services/narrative/narrative_services.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';

/// Reviews and writes a batch import into the open project.
///
/// Every row is written in its own transaction through the services the
/// record forms and data table use, so a bad row never leaves a half-made
/// record and never stops the rows after it.
class BatchImportService extends AppServices {
  const BatchImportService({required super.ref});

  Future<BatchImportReview> review({
    required BatchImportTable table,
    required DataTableRecordType type,
    required BatchImportMode mode,
    required List<BatchColumnMatch> matches,
    BatchImportKey? key,
  }) async {
    final index = await BatchImportIndex.load(dbAccess, currentProjectUuid);
    return BatchImportPlanner(
      type: type,
      mode: mode,
      index: index,
      key: key,
    ).review(table, matches);
  }

  Future<BatchImportResult> apply(
    BatchImportReview review, {
    bool includeMissingLinks = true,
    void Function(int done, int total)? onProgress,
  }) async {
    final rows = review.importable(includeMissingLinks: includeMissingLinks);
    final errors = <int, String>{};
    var written = 0;
    final geography = review.mode == BatchImportMode.update
        ? await _currentGeography(review.type, rows)
        : const <Object, Map<String, String>>{};
    for (final (index, row) in rows.indexed) {
      try {
        await dbAccess.transaction(() async {
          final key = review.mode == BatchImportMode.update
              ? row.recordKey!
              : await _create(review.type, row);
          await _write(review.type, key, row, geography[key] ?? const {});
        });
        written++;
      } catch (e) {
        errors[row.rowNumber] = e is _RowError ? e.message : '$e';
      }
      onProgress?.call(index + 1, rows.length);
    }
    _invalidate();
    return BatchImportResult(
      type: review.type,
      mode: review.mode,
      written: written,
      skipped: review.rows.length - rows.length,
      errors: errors,
    );
  }

  /// Creates an empty record for [row] and returns its key.
  Future<Object> _create(DataTableRecordType type, BatchRowPlan row) async {
    switch (type) {
      case DataTableRecordType.specimenRecords:
        final specimens = SpecimenServices(ref: ref);
        final uuid = await specimens.createSpecimen();
        final cataloger = row.links[DataTableLink.cataloger] as String?;
        if (cataloger != null && row.fieldNumber != null) {
          // The file's number, not the cataloger's next one.
          await specimens.updateSpecimen(
            uuid,
            SpecimenCompanion(
              catalogerID: db.Value(cataloger),
              determinerID: db.Value(cataloger),
              preparatorID: db.Value(cataloger),
            ),
          );
          await specimens.setPersonnelFieldIdentifier(
            specimenUuid: uuid,
            catalogerUuid: cataloger,
            fieldNumber: row.fieldNumber!,
          );
        } else if (cataloger != null) {
          await specimens.reassignCataloger(uuid, cataloger);
        }
        return uuid;
      case DataTableRecordType.specimenParts:
        return SpecimenPartQuery(dbAccess).createSpecimenPart(
          SpecimenPartCompanion(specimenUuid: db.Value(row.parentSpecimenUuid)),
        );
      case DataTableRecordType.sites:
        final id = await SiteServices(ref: ref).createNewSite();
        if (row.siteName != null) {
          await SiteQuery(
            dbAccess,
          ).updateSiteEntry(id, SiteCompanion(siteID: db.Value(row.siteName)));
        }
        return id;
      case DataTableRecordType.events:
        return CollEventServices(ref: ref).createNewCollEvents();
      case DataTableRecordType.narrative:
        return NarrativeServices(ref: ref).createNewNarrative();
    }
  }

  Future<void> _write(
    DataTableRecordType type,
    Object key,
    BatchRowPlan row,
    Map<String, String> currentRow,
  ) async {
    if (row.values.isNotEmpty) {
      final edits = [
        for (final entry in row.values.entries)
          DataTableEdit(
            cell: DataTableCellId(key, entry.key),
            field: dataTableField(entry.key),
            value: entry.value,
            row: currentRow,
          ),
      ];
      final result = await DataTableSaveService(dbAccess).save(type, edits);
      if (result.errors.isNotEmpty) {
        final (cell, message) = result.errors.entries
            .map((e) => (e.key, e.value))
            .first;
        throw _RowError('${cell.fieldKey.split('::').last}: $message');
      }
    }
    final links = DataTableLinkService(ref: ref);
    final record = DataTableRecordRow(key: key, values: const {});
    for (final entry in row.links.entries) {
      // A new specimen's cataloger is set with its field number.
      if (entry.key == DataTableLink.cataloger &&
          row.recordKey == null &&
          type == DataTableRecordType.specimenRecords) {
        continue;
      }
      await links.relink(type, record, entry.key, entry.value);
    }
  }

  /// Stored locality values of the sites an update touches: a locality
  /// edit rebuilds the whole locality from them.
  Future<Map<Object, Map<String, String>>> _currentGeography(
    DataTableRecordType type,
    List<BatchRowPlan> rows,
  ) async {
    if (type != DataTableRecordType.sites) return const {};
    final touches = rows.any(
      (row) => row.values.keys.any((key) => key.startsWith('geography::')),
    );
    if (!touches) return const {};
    final fields = [
      for (final key in const [
        'geography::country',
        'geography::islandGroup',
        'geography::stateProvince',
        'geography::county',
        'geography::municipality',
        'geography::specificLocality',
      ])
        dataTableField(key),
    ];
    final raw = await DataTablePageQuery(
      dbAccess,
    ).rawValues(type, [for (final row in rows) row.recordKey!], fields);
    return raw.values;
  }

  void _invalidate() {
    ref
      ..invalidate(specimenEntryProvider)
      ..invalidate(specimenPartEntryProvider)
      ..invalidate(siteEntryProvider)
      ..invalidate(collEventEntryProvider)
      ..invalidate(narrativeEntryProvider);
  }
}

class _RowError implements Exception {
  const _RowError(this.message);

  final String message;

  @override
  String toString() => message;
}
