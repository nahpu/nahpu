import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/arthropods.dart';

/// Formats arthropod attribute records for specimen exports.
class ArthropodAttributes {
  ArthropodAttributes({required this.ref, required this.specimenUuid});

  final WidgetRef ref;
  final String specimenUuid;

  Future<List<String>> getAttributes() async {
    final ArthropodAttributeData data = await SpecimenServices(
      ref: ref,
    ).getArthropodAttributeData(specimenUuid);

    return [
      _number(data.headWidth),
      _number(data.bodyLength),
      _number(data.wingspanUpper),
      _number(data.wingspanLower),
      getSpecimenSexLabel(data.sex) ?? '',
      data.lifeStage ?? '',
      data.caste == null ||
              data.caste! < 0 ||
              data.caste! >= arthropodCasteList.length
          ? ''
          : arthropodCasteList[data.caste!],
      data.hostOrganism ?? '',
      data.hostPart ?? '',
      data.remark ?? '',
    ];
  }

  String _number(double? value) => value?.truncateZero() ?? '';
}
