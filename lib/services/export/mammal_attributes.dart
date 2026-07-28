import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/mammals.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/utility_services.dart';

/// Formats mammal attribute records for specimen exports.
class MammalAttributes extends AppServices {
  MammalAttributes({
    required super.ref,
    required this.specimenUuid,
    required this.isBatRecord,
  });

  final String specimenUuid;
  final bool isBatRecord;
  late MammalAttributeData data;

  Future<List<String>> getAttributes() async {
    data = await SpecimenServices(
      ref: ref,
    ).getMammalAttributeData(specimenUuid);

    List<String> coreMeasurements = [
      data.totalLength?.truncateZero() ?? '',
      data.tailLength?.truncateZero() ?? '',
      data.hindFootLength?.truncateZero() ?? '',
      data.earLength?.truncateZero() ?? '',
    ];

    List<String> batMeasurements = isBatRecord
        ? [
            data.forearm?.truncateZero() ?? '',
            data.tibia?.truncateZero() ?? '',
            data.echolocation != null
                ? echolocationList[data.echolocation!]
                : '',
            data.frequencyMax?.truncateZero() ?? '',
            data.frequencyMin?.truncateZero() ?? '',
            data.frequencyAtMaxEnergy?.truncateZero() ?? '',
            data.duration?.truncateZero() ?? '',
          ]
        : [];

    List<String> remainingMeasurements = [
      data.weight?.truncateZero() ?? '',
      data.accuracy ?? '',
      data.accuracySpecify ?? '',
      data.sex != null ? specimenSexList[data.sex!] : '',
      data.age != null ? specimenAgeList[data.age!] : '',
      ..._getSexData(), // 16 items
      data.remark ?? '',
    ];

    return [...coreMeasurements, ...batMeasurements, ...remainingMeasurements];
  }

  /// Sex data contains 16 items:
  /// testisPosition, testisLength, testisWidth, epididymisAppearance,
  /// reproductiveStage, leftPlacentalScars, rightPlacentalScars, mammaeCondition,
  /// mammaeInguinalCount, mammaeAxillaryCount, mammaeAbdominalCount, vaginaOpening,
  /// pubicSymphysis, embryoLeftCount, embryoRightCount, embryoCR
  List<String> _getSexData() {
    SpecimenSex? sexEnum = getSpecimenSex(data.sex);
    List<String> emptyMale = List.filled(4, '');
    List<String> emptyFemale = List.filled(12, '');

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

  List<String> _getFemaleGonad() {
    return [
      data.reproductiveStage != null
          ? reproductiveStageList[data.reproductiveStage!]
          : '',
      data.leftPlacentalScars?.toString() ?? '',
      data.rightPlacentalScars?.toString() ?? '',
      data.mammaeCondition != null
          ? mammaeConditionList[data.mammaeCondition!]
          : '',
      data.mammaeInguinalCount?.toString() ?? '',
      data.mammaeAxillaryCount?.toString() ?? '',
      data.mammaeAbdominalCount?.toString() ?? '',
      data.vaginaOpening != null ? vaginaOpeningList[data.vaginaOpening!] : '',
      data.pubicSymphysis != null
          ? pubicSymphysisList[data.pubicSymphysis!]
          : '',
      data.embryoLeftCount?.toString() ?? '',
      data.embryoRightCount?.toString() ?? '',
      data.embryoCR?.toString() ?? '',
    ];
  }

  List<String> _getMaleGonad() {
    return [
      _matchTestisPos(data.testisPosition),
      data.testisLength?.toString() ?? '',
      data.testisWidth?.toString() ?? '',
      data.epididymisAppearance != null
          ? epididymisAppearanceList[data.epididymisAppearance!]
          : '',
    ];
  }

  String _matchTestisPos(int? testisPos) {
    if (testisPos == null) {
      return '';
    } else {
      return testisPositionList[testisPos];
    }
  }
}
