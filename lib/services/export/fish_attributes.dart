import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Formats fish attribute records, including lot individuals, for specimen
/// exports.
class FishAttributes extends AppServices {
  FishAttributes({required super.ref, required this.specimenUuid});

  final String specimenUuid;

  /// Values in [fishAttributeExportList] order.
  Future<List<String>> getAttributes() async {
    final data = await FishSpecimenQuery(
      dbAccess,
    ).getFishAttributeOrNull(specimenUuid);
    if (data == null) {
      return List.filled(_attributeFieldCount, '');
    }
    final type = fishSpecimenTypeFromCode(data.specimenType);
    final isLot = type == FishSpecimenType.lot;
    return [
      type.name,
      _int(isLot ? data.individualCount : 1),
      getSpecimenSexLabel(data.sex) ?? '',
      data.lifeStage ?? '',
      _number(isLot ? null : data.standardLength),
      _number(isLot ? null : data.totalLength),
      _number(isLot ? null : data.weight),
      data.weightUnit ?? '',
      _number(isLot ? data.minStandardLength : null),
      _number(isLot ? data.maxStandardLength : null),
      _number(isLot ? data.minTotalLength : null),
      _number(isLot ? data.maxTotalLength : null),
      _number(isLot ? data.minWeight : null),
      _number(isLot ? data.maxWeight : null),
      data.remark ?? '',
    ];
  }

  /// Individuals joined with `|`, each as `;`-separated labelled values.
  Future<String> getIndividuals() async {
    final individuals = await SpecimenIndividualQuery(
      dbAccess,
    ).getIndividuals(specimenUuid);
    return individuals.map(formatIndividual).join('|');
  }

  static String formatIndividual(SpecimenIndividualData data) {
    final weight = data.weight == null
        ? null
        : '${data.weight!.truncateZero()} ${data.weightUnit ?? 'g'}';
    return <String>[
      if (data.individualID?.isNotEmpty == true) 'ID: ${data.individualID}',
      if (data.standardLength != null)
        'SL: ${data.standardLength!.truncateZero()} mm',
      if (data.totalLength != null)
        'TL: ${data.totalLength!.truncateZero()} mm',
      if (weight != null) 'Weight: $weight',
      if (getSpecimenSexLabel(data.sex) != null)
        'Sex: ${getSpecimenSexLabel(data.sex)}',
      if (data.lifeStage?.isNotEmpty == true) 'Life stage: ${data.lifeStage}',
      if (data.remark?.isNotEmpty == true) 'Remark: ${data.remark}',
    ].join(';');
  }

  static const int _attributeFieldCount = 15;

  String _number(double? value) => value == null ? '' : value.truncateZero();

  String _int(int? value) => value == null ? '' : value.toString();
}
