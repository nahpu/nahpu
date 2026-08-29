import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Formats fossil attribute records for the all-taxa standard export.
class FossilAttributes {
  const FossilAttributes({required this.ref, required this.specimenUuid});

  final WidgetRef ref;
  final String specimenUuid;

  Future<List<String>> getAttributes() async {
    final database = ref.read(databaseProvider);
    final data = await (database.select(
      database.fossilAttribute,
    )..where((row) => row.specimenUuid.equals(specimenUuid))).getSingle();
    return [
      data.fossilType ?? '',
      data.specimenDescription ?? '',
      getSpecimenSexLabel(data.sex) ?? '',
      data.ontogeneticStage ?? '',
      data.weight?.truncateZero() ?? '',
      data.weightUnit ?? '',
      data.remark ?? '',
    ];
  }
}
