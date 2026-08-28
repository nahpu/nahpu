import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/mammals.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/common/utility_services.dart';

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
      getSpecimenSexLabel(data.sex) ?? '',
      data.lifeStage ?? '',
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

    final male = sexEnum?.supportsMaleAttributes == true
        ? _getMaleGonad()
        : emptyMale;
    final female = sexEnum?.supportsFemaleAttributes == true
        ? _getFemaleGonad()
        : emptyFemale;
    return [...male, ...female];
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
