import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';

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
      data.hostOrganism ?? '',
      data.hostPart ?? '',
      data.canopyAffinity ?? '',
      data.canopyCover ?? '',
      _number(data.ambientTemperature),
      _number(data.ambientHumidity),
      _number(data.waterTemperature),
      _number(data.pH),
      _number(data.dissolvedOxygen),
      _number(data.flowVelocity),
      data.remark ?? '',
    ];
  }

  String _number(double? value) => value?.truncateZero() ?? '';
}
