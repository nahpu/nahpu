import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/common/utility_services.dart';

/// Formats herpetofauna attribute records for specimen exports.
class HerpAttributes extends AppServices {
  HerpAttributes({required super.ref, required this.specimenUuid});

  final String specimenUuid;
  late HerpAttributeData data;

  Future<List<String>> getAttributes() async {
    data = await SpecimenServices(ref: ref).getHerpAttributeData(specimenUuid);
    List<String> sexData = _getSexData();
    String lifeStage = data.lifeStage ?? '';
    List<String> measurement = _getStdMeasurement();
    String remarks = data.remark ?? '';
    return [...sexData, lifeStage, ...measurement, remarks];
  }

  List<String> _getStdMeasurement() {
    String weight = _getWeight(data.weight);
    String svl = _getSVL(data.svl);

    List<String> measurements = [weight, svl];

    return measurements;
  }

  String _getWeight(double? weight) {
    return weight == null ? '' : weight.truncateZero();
  }

  String _getSVL(double? svl) {
    return svl == null ? '' : svl.truncateZero();
  }

  List<String> _getSexData() {
    String sex = getSpecimenSexLabel(data.sex) ?? '';
    return [sex];
  }
}
