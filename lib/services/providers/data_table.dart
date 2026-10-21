import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/types/export.dart';

typedef DataTablePageLoader =
    Future<DataTablePageData> Function(
      WidgetRef ref,
      DataTableRecordType type,
      DataTableQuery query,
      SpecimenRecordType specimenType,
    );

/// Loads one page of data table records. The export writers it reads
/// through take a [WidgetRef], so the screen calls this with its own ref;
/// tests override it with fixed data.
final dataTablePageLoaderProvider = Provider<DataTablePageLoader>(
  (ref) =>
      (widgetRef, type, query, specimenType) => DataTableService(
        ref: widgetRef,
      ).fetchPage(type, query, specimenType: specimenType),
);

typedef DataTableEditSaver =
    Future<DataTableSaveResult> Function(
      WidgetRef ref,
      DataTableRecordType type,
      List<DataTableEdit> edits,
    );

/// Saves data table edits, then refreshes the record lists other screens
/// show. Tests override it.
final dataTableEditSaverProvider = Provider<DataTableEditSaver>(
  (ref) => (widgetRef, type, edits) async {
    final result = await DataTableSaveService(
      widgetRef.read(databaseProvider),
    ).save(type, edits);
    if (result.saved.isNotEmpty) {
      widgetRef
        ..invalidate(specimenEntryProvider)
        ..invalidate(specimenPartEntryProvider)
        ..invalidate(siteEntryProvider)
        ..invalidate(collEventEntryProvider)
        ..invalidate(narrativeEntryProvider);
    }
    return result;
  },
);
