import 'dart:math';

import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/specimen_services.dart';

class OutlierDetectionServices extends AppServices {
  const OutlierDetectionServices({required super.ref});

  Future<List<SpecimenData>> findOutliers(List<int> taxonIds) async {
    final outlierSpecimens = <SpecimenData>{};

    for (final taxonId in taxonIds) {
      final specimens =
          await SpecimenServices(ref: ref).getSpecimensByTaxonId(taxonId);
      if (specimens.isEmpty) {
        continue;
      }

      final taxonGroup = specimens.first.taxonGroup;

      if (taxonGroup == 'General Mammals' || taxonGroup == 'Bats') {
        // Find outliers in mammal measurements
        final mammalMeasurements = await Future.wait(specimens
            .map((s) =>
                SpecimenServices(ref: ref).getMammalMeasurementData(s.uuid))
            .toList());
        _findQuantitativeOutliers(
            specimens, mammalMeasurements, outlierSpecimens);
      } else if (taxonGroup == 'Birds') {
        // Find outliers in avian measurements
        final avianMeasurements = await Future.wait(specimens
            .map((s) =>
                SpecimenServices(ref: ref).getAvianMeasurementData(s.uuid))
            .toList());
        _findQuantitativeOutliers(
            specimens, avianMeasurements, outlierSpecimens);
      }

      // Find outliers in qualitative/categorical data
      _findQualitativeOutliers(specimens, outlierSpecimens);
    }
    return outlierSpecimens.toList();
  }

  void _findQuantitativeOutliers<T>(List<SpecimenData> specimens,
      List<T> measurements, Set<SpecimenData> outliers) {
    if (measurements.isEmpty) {
      return;
    }

    final Map<String, num? Function(dynamic)> fields;
    if (T == MammalMeasurementData) {
      fields = _getMammalQuantitativeFields();
    } else if (T == AvianMeasurementData) {
      fields = _getAvianQuantitativeFields();
    } else {
      return;
    }

    for (var field in fields.keys) {
      final values = measurements
          .map((m) => fields[field]!(m))
          .whereType<num>()
          .toList();
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
          outliers.add(specimens[i]);
        }
      }
    }
  }

  void _findQualitativeOutliers(
      List<SpecimenData> specimens, Set<SpecimenData> outliers) async {
    if (specimens.length < 3) return;

    // final qualitativeFields = {
    //   'condition': (SpecimenData s) => s.condition,
    // };

    // We need to fetch measurement data again for qualitative fields there
    final taxonGroup = specimens.first.taxonGroup;
    List<dynamic> measurements = [];
    Map<String, String? Function(dynamic)> qualitativeFields;

    if (taxonGroup == 'General Mammals' || taxonGroup == 'Bats') {
      measurements = await Future.wait(specimens
          .map(
              (s) => SpecimenServices(ref: ref).getMammalMeasurementData(s.uuid))
          .toList());
      qualitativeFields = _getMammalQualitativeFields();
    } else if (taxonGroup == 'Birds') {
      measurements = await Future.wait(specimens
          .map(
              (s) => SpecimenServices(ref: ref).getAvianMeasurementData(s.uuid))
          .toList());
      qualitativeFields = _getAvianQualitativeFields();
    } else {
      return;
    }

    // Add common fields from SpecimenData
    qualitativeFields['condition'] = (s) => (s as SpecimenData).condition;

    for (var fieldName in qualitativeFields.keys) {
      final values = <String>[];
      for (int i = 0; i < specimens.length; i++) {
        // The callback might operate on SpecimenData or a measurement type
        final dataObject =
            fieldName == 'condition' ? specimens[i] : measurements[i];
        final value = qualitativeFields[fieldName]!(dataObject);
        if (value != null && value.isNotEmpty) {
          values.add(value);
        }
      }
      final frequencies = <String, int>{};
      for (var value in values) {
        frequencies[value] = (frequencies[value] ?? 0) + 1;
      }

      for (int i = 0; i < specimens.length; i++) {
        final dataObject =
            fieldName == 'condition' ? specimens[i] : measurements[i];
        final value = qualitativeFields[fieldName]!(dataObject);
        if (value != null && value.isNotEmpty) {
          final freq = frequencies[value]!;
          // Flag if frequency is <10% OR count is 1 and total is > 5
          if ((freq / specimens.length < 0.1) ||
              (freq == 1 && specimens.length > 2)) {
            outliers.add(specimens[i]);
          }
        }
      }
    }
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

  Map<String, num? Function(dynamic)> _getMammalQuantitativeFields() {
    return {
      'totalLength': (m) => (m as MammalMeasurementData).totalLength,
      'tailLength': (m) => (m as MammalMeasurementData).tailLength,
      'hindFootLength': (m) => (m as MammalMeasurementData).hindFootLength,
      'earLength': (m) => (m as MammalMeasurementData).earLength,
      'weight': (m) => (m as MammalMeasurementData).weight,
      'forearm': (m) => (m as MammalMeasurementData).forearm,
      'testisLength': (m) => (m as MammalMeasurementData).testisLength,
      'testisWidth': (m) => (m as MammalMeasurementData).testisWidth,
    };
  }

  Map<String, String? Function(dynamic)> _getMammalQualitativeFields() {
    return {
      'sex': (m) => (m as MammalMeasurementData).sex?.toString(),
      'age': (m) => (m as MammalMeasurementData).age?.toString(),
      'testisPosition': (m) =>
          (m as MammalMeasurementData).testisPosition?.toString(),
      'mammaeCondition': (m) =>
          (m as MammalMeasurementData).mammaeCondition?.toString(),
      'vaginaOpening': (m) =>
          (m as MammalMeasurementData).vaginaOpening?.toString(),
      'pubicSymphysis': (m) =>
          (m as MammalMeasurementData).pubicSymphysis?.toString(),
    };
  }

  Map<String, num? Function(dynamic)> _getAvianQuantitativeFields() {
     return {
       'weight': (m) => (m as AvianMeasurementData).weight,
       'wingspan': (m) => (m as AvianMeasurementData).wingspan,
       'bursaLength': (m) => (m as AvianMeasurementData).bursaLength,
       'bursaWidth': (m) => (m as AvianMeasurementData).bursaWidth,
      'testisLength': (m) => (m as AvianMeasurementData).testisLength,
      'testisWidth': (m) => (m as AvianMeasurementData).testisWidth,
      'ovaryLength': (m) => (m as AvianMeasurementData).ovaryLength,
      'ovaryWidth': (m) => (m as AvianMeasurementData).ovaryWidth,
    };
  }

  Map<String, String? Function(dynamic)> _getAvianQualitativeFields() {
    return {
      'sex': (m) => (m as AvianMeasurementData).sex?.toString(),
      'broodPatch': (m) => (m as AvianMeasurementData).broodPatch?.toString(),
      'fat': (m) => (m as AvianMeasurementData).fat?.toString(),
      'bodyMolt': (m) => (m as AvianMeasurementData).bodyMolt?.toString(),
      'irisColor': (m) => (m as AvianMeasurementData).irisColor,
      'billColor': (m) => (m as AvianMeasurementData).billColor,
      'footColor': (m) => (m as AvianMeasurementData).footColor,
      'tarsusColor': (m) => (m as AvianMeasurementData).tarsusColor,
     };
  }
}