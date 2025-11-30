import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/validation/mandatory_fields.dart';
import 'package:nahpu/services/validation/models.dart';
import 'package:nahpu/services/validation/validation_utils.dart';

class MammalValidation extends AppServices {
  const MammalValidation({
    required super.ref,
    required this.specimens,
    required this.detectOutliers,
    required this.findMissingFields,
  });

  final List<SpecimenData> specimens;
  final bool detectOutliers;
  final bool findMissingFields;

  Future<List<ValidationResult>> validate() async {
    final results = <ValidationResult>[];
    if (specimens.isEmpty) return results;

    final mammalMeasurements = await Future.wait(specimens
        .map((s) => SpecimenServices(ref: ref).getMammalMeasurementData(s.uuid))
        .toList());

    if (detectOutliers) {
      results.addAll(_findQuantitativeOutliers(mammalMeasurements));
    }
    if (findMissingFields) {
      results.addAll(_findMissingFields(mammalMeasurements));
    }
    return results;
  }

  List<ValidationResult> _findQuantitativeOutliers(
      List<MammalMeasurementData> measurements) {
    final outlierResults = <ValidationResult>[];
    if (measurements.length < 3) return outlierResults;

    final fields = _getMammalQuantitativeFields();

    for (var field in fields.keys) {
      final values =
          measurements.map((m) => fields[field]!(m)).whereType<num>().toList();
      if (values.length < 3) continue;

      values.sort();
      final q1 = _getPercentile(values, 25);
      final q3 = _getPercentile(values, 75);
      final iqr = q3 - q1;
      final lowerBound = q1 - 1.5 * iqr;
      final upperBound = q3 + 1.5 * iqr;

      for (int i = 0; i < measurements.length; i++) {
        final value = fields[field]!(measurements[i]);
        if (value != null && (value < lowerBound || value > upperBound)) {
          final specimen = specimens[i];
          outlierResults.add(
            ValidationResult(
              specimen: specimen,
              issues: ['Outlier: $field'],
            ),
          );
        }
      }
    }
    return outlierResults;
  }

  List<ValidationResult> _findMissingFields(
      List<MammalMeasurementData> measurements) {
    final missingFieldsResults = <ValidationResult>[];
    for (int i = 0; i < specimens.length; i++) {
      final specimen = specimens[i];
      final measurement = measurements[i];
      final issues = <String>[];

      // Check fields from SpecimenData
      issues.addAll(ValidationUtils.checkMissingFields(
        specimen.toJson(),
        [
          ...MandatoryFieldService.specimenGeneral,
          ...MandatoryFieldService.specimenCapture
        ],
      ));

      // Check fields from MammalMeasurementData
      issues.addAll(ValidationUtils.checkMissingFields(
        measurement.toJson(),
        [
          ...MandatoryFieldService.mammalDropdowns,
          ...MandatoryFieldService.mammalMeasurements
        ],
      ));

      if (issues.isNotEmpty) {
        missingFieldsResults.add(
          ValidationResult(specimen: specimen, issues: issues),
        );
      }
    }
    return missingFieldsResults;
  }

  double _getPercentile(List<num> sortedData, int percentile) {
    if (sortedData.isEmpty) return 0.0;
    final index = (percentile / 100) * (sortedData.length - 1);
    if (index == index.floor()) {
      return sortedData[index.toInt()].toDouble();
    } else {
      final lower = sortedData[index.floor()].toDouble();
      final upper = sortedData[index.ceil()].toDouble();
      return lower + (index - index.floor()) * (upper - lower);
    }
  }

  Map<String, num? Function(MammalMeasurementData)>
      _getMammalQuantitativeFields() {
    return {
      'Total Length': (m) => m.totalLength,
      'Tail Length': (m) => m.tailLength,
      'Hind Foot': (m) => m.hindFootLength,
      'Ear': (m) => m.earLength,
      'Weight': (m) => m.weight,
      'Forearm': (m) => m.forearm,
      'Testis Length': (m) => m.testisLength,
      'Testis Width': (m) => m.testisWidth,
    };
  }
}