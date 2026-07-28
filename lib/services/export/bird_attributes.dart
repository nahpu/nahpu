import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/birds.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_services.dart';

/// Formats bird attribute records for specimen exports.
class BirdAttributes {
  BirdAttributes({required this.ref, required this.specimenUuid});

  final WidgetRef ref;
  final String specimenUuid;
  late BirdAttributeData data;

  Future<List<String>> getAttributes() async {
    data = await SpecimenServices(ref: ref).getBirdAttributeData(specimenUuid);

    return [
      data.weight?.toString() ?? '',
      data.wingspan?.toString() ?? '',
      data.irisColor ?? '',
      data.irisHex ?? '',
      data.billColor ?? '',
      data.billHex ?? '',
      data.maxillaColor ?? '',
      data.maxillaHex ?? '',
      data.mandibleColor ?? '',
      data.mandibleHex ?? '',
      data.toeColor ?? '',
      data.toeHex ?? '',
      data.tarsusColor ?? '',
      data.tarsusHex ?? '',
      data.sex != null ? specimenSexList[data.sex!] : '',
      _getBroodPatch(),
      data.skullOssification?.toString() ?? '',
      _getHasBursa(),
      data.bursaWidth?.toString() ?? '',
      data.bursaLength?.toString() ?? '',
      _getFat(),
      data.stomachContent ?? '',
      ..._getGonadData(), // 12 elements
      _getWingIsMolt(),
      data.wingMolt ?? '',
      _getTailIsMolt(),
      data.tailMolt ?? '',
      _getBodyMolt(),
      data.moltRemark ?? '',
      data.specimenRemark ?? '',
      data.habitatRemark ?? '',
    ];
  }

  String _getBroodPatch() {
    if (data.broodPatch == null) {
      return '';
    } else {
      return data.broodPatch == 1 ? 'Yes' : 'No';
    }
  }

  String _getHasBursa() {
    if (data.hasBursa == null) return '';
    return data.hasBursa == 1 ? 'Yes' : 'No';
  }

  String _getFat() {
    if (data.fat == null) {
      return '';
    } else {
      return birdLabelForCode(fatCategoryList, data.fat!);
    }
  }

  List<String> _getGonadData() {
    SpecimenSex? sexEnum = getSpecimenSex(data.sex);
    List<String> emptyMale = List.filled(3, '');
    List<String> emptyFemale = List.filled(9, '');

    switch (sexEnum) {
      case SpecimenSex.male:
        return [..._getMaleGonad(), ...emptyFemale];
      case SpecimenSex.female:
        return [...emptyMale, ..._getFemaleGonad()];
      case SpecimenSex.unknown:
      default:
        return [...emptyMale, ...emptyFemale];
    }
  }

  List<String> _getMaleGonad() {
    return [
      data.testisLength?.toString() ?? '',
      data.testisWidth?.toString() ?? '',
      data.testisRemark ?? '',
    ];
  }

  List<String> _getFemaleGonad() {
    return [
      data.ovaryLength?.toString() ?? '',
      data.ovaryWidth?.toString() ?? '',
      data.oviductWidth?.toString() ?? '',
      _getOvaryAppearance(),
      data.firstOvaSize?.toString() ?? '',
      data.secondOvaSize?.toString() ?? '',
      data.thirdOvaSize?.toString() ?? '',
      _getOviductAppearance(),
      data.ovaryRemark ?? '',
    ];
  }

  String _getOvaryAppearance() {
    if (data.ovaryAppearance == null) {
      return '';
    } else {
      return birdLabelForCode(ovaryAppearanceList, data.ovaryAppearance!);
    }
  }

  String _getOviductAppearance() {
    if (data.oviductAppearance == null) {
      return '';
    } else {
      return birdLabelForCode(oviductAppearanceList, data.oviductAppearance!);
    }
  }

  String _getBodyMolt() {
    if (data.bodyMolt == null) {
      return '';
    } else {
      return birdLabelForCode(bodyMoltList, data.bodyMolt!);
    }
  }

  String _getWingIsMolt() {
    if (data.wingIsMolt == null) return '';
    return data.wingIsMolt == 1 ? 'Yes' : 'No';
  }

  String _getTailIsMolt() {
    if (data.tailIsMolt == null) return '';
    return data.tailIsMolt == 1 ? 'Yes' : 'No';
  }
}
