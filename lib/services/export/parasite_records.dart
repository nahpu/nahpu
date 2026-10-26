import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/collecting_records.dart';
import 'package:nahpu/services/export/dynamic_record_exporter.dart';
import 'package:nahpu/services/types/export.dart';

/// Builds parasite rows: one row per parasite, followed by the collecting
/// record of the specimen it was found on.
class ParasiteWriter extends AppServices {
  const ParasiteWriter({required super.ref});

  /// Columns of a parasite row, in order.
  static const List<String> header = [
    ...parasiteExportList,
    ...collectingRecordExportList,
  ];

  /// The values of [parasite], aligned with [header].
  Future<List<String>> getRow(
    ParasiteData parasite,
    SpecimenData specimen,
  ) async {
    final values = await DynamicRecordExporter(
      ref: ref,
      expansion: MultiEntryExpansion.parasites,
    ).parasiteValues(parasite);
    final parasiteValues = [
      for (final key in parasiteExportList)
        values[key.split('::').last]?.toString() ?? '',
    ];
    final collecting = await CollectingRecordWriterServices(
      ref: ref,
    ).getRecord(specimen);
    return [...parasiteValues, ...collecting];
  }
}
