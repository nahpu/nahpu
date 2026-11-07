import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/collecting_records.dart';
import 'package:nahpu/services/export/dynamic_record_exporter.dart';
import 'package:nahpu/services/types/export.dart';

/// Builds symbiont rows: one row per symbiont, followed by the collecting
/// record of the specimen it was found on.
class SymbiontWriter extends AppServices {
  const SymbiontWriter({required super.ref});

  /// Columns of a symbiont row, in order.
  static const List<String> header = [
    ...symbiontExportList,
    ...collectingRecordExportList,
  ];

  /// The values of [symbiont], aligned with [header].
  Future<List<String>> getRow(
    SymbiontData symbiont,
    SpecimenData specimen,
  ) async {
    final values = await DynamicRecordExporter(
      ref: ref,
      expansion: MultiEntryExpansion.symbionts,
    ).symbiontValues(symbiont);
    final symbiontValues = [
      for (final key in symbiontExportList)
        values[key.split('::').last]?.toString() ?? '',
    ];
    final collecting = await CollectingRecordWriterServices(
      ref: ref,
    ).getRecord(specimen);
    return [...symbiontValues, ...collecting];
  }
}
