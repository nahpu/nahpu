import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/types/statistics.dart';

/// Opens the data table limited to the records behind one group of
/// [request], such as a tapped bar.
Future<void> openStatisticRecords(
  BuildContext context,
  WidgetRef ref,
  StatisticRequest request, {
  required String label,
  String? seriesLabel,
}) async {
  final keys = await ref.read(statisticRecordKeysLoaderProvider)(
    request,
    label: label,
    seriesLabel: seriesLabel,
  );
  if (!context.mounted) return;
  if (keys.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No records in this group.')));
    return;
  }
  final scopeLabel = [
    '${request.categoryLabel}: $label',
    if (request.breakdown != null && seriesLabel != null)
      '${request.breakdown!.label}: $seriesLabel',
  ].join(' · ');
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DataTableScreen(
        initialType: request.measure == StatisticMeasure.partQuantity
            ? DataTableRecordType.specimenParts
            : DataTableRecordType.specimenRecords,
        initialScope: DataTableKeyScope(keys: keys.toSet(), label: scopeLabel),
      ),
    ),
  );
}
