import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.projectStatsNoRecordsInGroup)),
    );
    return;
  }
  final allProjects = request.projectUuid == null;
  final scopeLabel = [
    if (allProjects) context.l10n.projectTaxonAllProjects,
    '${request.localizedCategoryLabel(context.l10n)}: $label',
    if (request.breakdown != null && seriesLabel != null)
      '${request.breakdown!.localizedLabel(context.l10n)}: $seriesLabel',
  ].join(' · ');
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DataTableScreen(
        initialType: switch (request.measure) {
          StatisticMeasure.partQuantity => DataTableRecordType.specimenParts,
          StatisticMeasure.parasites => DataTableRecordType.parasites,
          _ => DataTableRecordType.specimenRecords,
        },
        initialScope: DataTableKeyScope(keys: keys.toSet(), label: scopeLabel),
        allProjects: allProjects,
      ),
    ),
  );
}
