import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/validation/models.dart';

class BirdValidation extends AppServices {
  const BirdValidation({
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

    final avianMeasurements = await Future.wait(specimens
        .map((s) => SpecimenServices(ref: ref).getAvianMeasurementData(s.uuid))
        .toList());

    if (detectOutliers) {
      results.addAll(_findQuantitativeOutliers(avianMeasurements));
      results.addAll(_findQualitativeOutliers(avianMeasurements));
    }
    if (findMissingFields) {
      results.addAll(_findMissingFields(avianMeasurements));
    }
    return results;
  }

  List<ValidationResult> _findQuantitativeOutliers(
      List<AvianMeasurementData> measurements) {
    final outlierResults = <ValidationResult>[];
    if (measurements.length < 3) return outlierResults;

    final fields = _getAvianQuantitativeFields();

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

  List<ValidationResult> _findQualitativeOutliers(
      List<AvianMeasurementData> measurements) {
    final outlierResults = <ValidationResult>[];
    if (measurements.length < 3) return outlierResults;

    final qualitativeFields = _getAvianQualitativeFields();

    for (var fieldName in qualitativeFields.keys) {
      final values = <String>[];
      for (int i = 0; i < specimens.length; i++) {
        final value = qualitativeFields[fieldName]!(measurements[i]);
        if (value != null && value.isNotEmpty) {
          values.add(value);
        }
      }
      final frequencies = <String, int>{};
      for (var value in values) {
        frequencies[value] = (frequencies[value] ?? 0) + 1;
      }

      for (int i = 0; i < specimens.length; i++) {
        final value = qualitativeFields[fieldName]!(measurements[i]);
        if (value != null && value.isNotEmpty) {
          final freq = frequencies[value]!;
          if ((freq / specimens.length < 0.1) ||
              (freq == 1 && specimens.length > 5)) {
            outlierResults.add(
              ValidationResult(
                specimen: specimens[i],
                issues: ['Outlier: $fieldName'],
              ),
            );
          }
        }
      }
    }
    return outlierResults;
  }

  List<ValidationResult> _findMissingFields(
      List<AvianMeasurementData> measurements) {
    final missingFieldsResults = <ValidationResult>[];
    for (int i = 0; i < specimens.length; i++) {
      final specimen = specimens[i];
      final issues = <String>[];

      // Shared fields from SpecimenData
      if (specimen.catalogerID == null) issues.add('Missing: Cataloger');
      if (specimen.fieldNumber == null) issues.add('Missing: Field Number');
      if (specimen.speciesID == null) issues.add('Missing: Species');
      if (specimen.prepDate == null || specimen.prepDate!.isEmpty) {
        issues.add('Missing: Prep Date');
      }
      if (specimen.prepTime == null || specimen.prepTime!.isEmpty) {
        issues.add('Missing: Prep Time');
      }
      if (specimen.collEventID == null) issues.add('Missing: Event ID');

      // Avian specific fields
      final measurement = measurements[i];
      if (measurement.sex == null) issues.add('Missing: Sex');
      if (measurement.weight == null) issues.add('Missing: Weight');
      if (measurement.wingspan == null) issues.add('Missing: Wingspan');

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

  Map<String, num? Function(AvianMeasurementData)>
      _getAvianQuantitativeFields() {
    return {
      'Weight': (m) => m.weight,
      'Wingspan': (m) => m.wingspan,
      'Bursa Length': (m) => m.bursaLength,
      'Bursa Width': (m) => m.bursaWidth,
      'Testis Length': (m) => m.testisLength,
      'Testis Width': (m) => m.testisWidth,
      'Ovary Length': (m) => m.ovaryLength,
      'Ovary Width': (m) => m.ovaryWidth,
    };
  }

  Map<String, String? Function(AvianMeasurementData)>
      _getAvianQualitativeFields() {
    return {
      'Sex': (m) => m.sex?.toString(),
      'Brood Patch': (m) => m.broodPatch?.toString(),
      'Fat': (m) => m.fat?.toString(),
      'Body Molt': (m) => m.bodyMolt?.toString(),
      'Iris Color': (m) => m.irisColor,
      'Bill Color': (m) => m.billColor,
      'Foot Color': (m) => m.footColor,
      'Tarsus Color': (m) => m.tarsusColor,
    };
  }
}