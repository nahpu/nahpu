import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/mammals.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/utility_services.dart';

class MammalianMeasurements extends AppServices {
  MammalianMeasurements({
    required super.ref,
    required this.specimenUuid,
    required this.isBatRecord,
    required this.isInaccurateInBrackets,
  });

  final String specimenUuid;
  final bool isBatRecord;
  late MammalMeasurementData data;
  final bool isInaccurateInBrackets;

  Future<List<String>> getMeasurements() async {
    data =
        await SpecimenServices(ref: ref).getMammalMeasurementData(specimenUuid);

    MeasurementAccuracy accuracyEnum = matchAccuracy(data.accuracy);
    
    List<String> coreMeasurements = [
      _getTotalLength(data.totalLength, accuracyEnum),
      _getTailLength(data.tailLength, accuracyEnum),
      _getHindFootLength(data.hindFootLength, accuracyEnum),
      _getEarLength(data.earLength, accuracyEnum),
    ];

    List<String> batMeasurements = isBatRecord
        ? [
            data.forearm?.toString() ?? '',
            data.tibia?.toString() ?? '',
            data.echolocation != null ? echolocationList[data.echolocation!] : '',
            data.frequencyMax?.toString() ?? '',
            data.frequencyMin?.toString() ?? '',
            data.frequencyAtMaxEnergy?.toString() ?? '',
            data.duration?.toString() ?? '',
          ]
        : [];

    List<String> remainingMeasurements = [
      _getWeight(data.weight, accuracyEnum),
      data.accuracy ?? '',
      data.accuracySpecify ?? '',
      data.sex != null ? specimenSexList[data.sex!] : '',
      data.age != null ? specimenAgeList[data.age!] : '',
      ..._getSexData(), // 16 items
      data.remark ?? '',
    ];

    return [
      ...coreMeasurements,
      ...batMeasurements,
      ...remainingMeasurements,
    ];
  }



  String _getTotalLength(double? length, MeasurementAccuracy accuracy) {
    if (length == null) return '';

    String lengthStr = length.truncateZero();

    if (!isInaccurateInBrackets) {
      return lengthStr;
    }

    switch (accuracy) {
      case MeasurementAccuracy.partiallyEaten:
        return '[$lengthStr]';
      case MeasurementAccuracy.tailCropped:
        return '[$lengthStr]';
      case MeasurementAccuracy.allMeasurementsInaccurate:
        return '[$lengthStr]';
      default:
        return lengthStr;
    }
  }

  String _getTailLength(double? length, MeasurementAccuracy accuracy) {
    if (length == null) return '';

    String lengthStr = length.truncateZero();

    if (!isInaccurateInBrackets) {
      return lengthStr;
    }

    switch (accuracy) {
      case MeasurementAccuracy.partiallyEaten:
        return '[$lengthStr]';
      case MeasurementAccuracy.tailCropped:
        return '[$lengthStr]';
      case MeasurementAccuracy.allMeasurementsInaccurate:
        return '[$lengthStr]';
      default:
        return lengthStr;
    }
  }

  String _getHindFootLength(double? length, MeasurementAccuracy accuracy) {
    if (length == null) return '';

    String lengthStr = length.truncateZero();

    if (!isInaccurateInBrackets) {
      return lengthStr;
    }

    switch (accuracy) {
      case MeasurementAccuracy.partiallyEaten:
        return '[$lengthStr]';
      case MeasurementAccuracy.hindLengthInaccurate:
        return '[$lengthStr]';
      case MeasurementAccuracy.allMeasurementsInaccurate:
        return '[$lengthStr]';
      default:
        return lengthStr;
    }
  }

  String _getEarLength(double? length, MeasurementAccuracy accuracy) {
    if (length == null) return '';

    String lengthStr = length.truncateZero();

    if (!isInaccurateInBrackets) {
      return lengthStr;
    }

    switch (accuracy) {
      case MeasurementAccuracy.partiallyEaten:
        return '[$lengthStr]';
      case MeasurementAccuracy.earLengthInaccurate:
        return '[$lengthStr]';
      case MeasurementAccuracy.allMeasurementsInaccurate:
        return '[$lengthStr]';
      default:
        return lengthStr;
    }
  }

  String _getWeight(double? weight, MeasurementAccuracy accuracy) {
    if (weight == null) return '';

    String weightStr = weight.truncateZero();

    if (!isInaccurateInBrackets) {
      return weightStr;
    }

    switch (accuracy) {
      case MeasurementAccuracy.partiallyEaten:
        return '[$weightStr]';
      case MeasurementAccuracy.allMeasurementsInaccurate:
        return '[$weightStr]';
      default:
        return weightStr;
    }
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
      data.reproductiveStage != null ? reproductiveStageList[data.reproductiveStage!] : '',
      data.leftPlacentalScars?.toString() ?? '',
      data.rightPlacentalScars?.toString() ?? '',
      data.mammaeCondition != null ? mammaeConditionList[data.mammaeCondition!] : '',
      data.mammaeInguinalCount?.toString() ?? '',
      data.mammaeAxillaryCount?.toString() ?? '',
      data.mammaeAbdominalCount?.toString() ?? '',
      data.vaginaOpening != null ? vaginaOpeningList[data.vaginaOpening!] : '',
      data.pubicSymphysis != null ? pubicSymphysisList[data.pubicSymphysis!] : '',
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
      data.epididymisAppearance != null ? epididymisAppearanceList[data.epididymisAppearance!] : '',
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
