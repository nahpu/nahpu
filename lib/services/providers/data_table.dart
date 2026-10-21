import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';

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

/// One choice of a dropdown field: the stored value and the label shown.
class DataTableChoice {
  const DataTableChoice(this.value, this.label);

  final String value;
  final String label;
}

/// Whether [field] is edited with a dropdown, as in the record forms.
bool dataTableHasChoices(DataTableField field) =>
    field.optionKey != null || field.valueType == DataTableValueType.coded;

/// Dropdown choices for a field, from the same sources the record forms
/// use: the controlled vocabulary for text fields, the configured sexes for
/// sex, and the fixed label lists for other coded fields.
final dataTableChoicesProvider = FutureProvider.autoDispose
    .family<List<DataTableChoice>, String>((ref, fieldKey) async {
      final field = dataTableField(fieldKey);
      final optionKey = field.optionKey;
      if (optionKey != null) {
        final options = await ref.watch(
          effectiveUserDefinedFieldProvider(optionKey).future,
        );
        return [for (final option in options) DataTableChoice(option, option)];
      }
      if (field.column == 'sex') {
        final sexes = await ref.watch(specimenSexVocabularyProvider.future);
        return [
          for (final sex in sexes)
            DataTableChoice('${specimenSexCode[sex]}', specimenSexLabel[sex]!),
        ];
      }
      return [
        for (final (code, label) in field.codes)
          DataTableChoice('$code', label),
      ];
    });

/// [choices] plus the stored [current] value when the list no longer has
/// it, so editing never silently drops a value, as in the forms.
List<DataTableChoice> dataTableChoicesWithCurrent(
  DataTableField field,
  List<DataTableChoice> choices,
  String current,
) {
  final value = current.trim();
  if (value.isEmpty || choices.any((choice) => choice.value == value)) {
    return choices;
  }
  return [...choices, DataTableChoice(value, field.labelFor(value))];
}
