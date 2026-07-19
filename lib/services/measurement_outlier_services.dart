import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/io_services.dart';

const int measurementOutlierMinSampleSize = 10;

enum MammalMeasurementOutlierField {
  totalLength,
  tailLength,
  hindFootLength,
  earLength,
  weight,
}

extension MammalMeasurementOutlierFieldInfo on MammalMeasurementOutlierField {
  String get label {
    switch (this) {
      case MammalMeasurementOutlierField.totalLength:
        return 'total length';
      case MammalMeasurementOutlierField.tailLength:
        return 'tail length';
      case MammalMeasurementOutlierField.hindFootLength:
        return 'hind foot length';
      case MammalMeasurementOutlierField.earLength:
        return 'ear length';
      case MammalMeasurementOutlierField.weight:
        return 'weight';
    }
  }

  String get unit {
    switch (this) {
      case MammalMeasurementOutlierField.weight:
        return 'g';
      case MammalMeasurementOutlierField.totalLength:
      case MammalMeasurementOutlierField.tailLength:
      case MammalMeasurementOutlierField.hindFootLength:
      case MammalMeasurementOutlierField.earLength:
        return 'mm';
    }
  }

  double? readValue(MammalMeasurementData data) {
    switch (this) {
      case MammalMeasurementOutlierField.totalLength:
        return data.totalLength;
      case MammalMeasurementOutlierField.tailLength:
        return data.tailLength;
      case MammalMeasurementOutlierField.hindFootLength:
        return data.hindFootLength;
      case MammalMeasurementOutlierField.earLength:
        return data.earLength;
      case MammalMeasurementOutlierField.weight:
        return data.weight;
    }
  }
}

enum MeasurementComparisonLevel { species, genus }

class MeasurementOutlierResult {
  const MeasurementOutlierResult({
    required this.field,
    required this.value,
    required this.lowerBound,
    required this.upperBound,
    required this.comparisonName,
    required this.comparisonLevel,
    required this.sampleSize,
    required this.inlierCount,
  });

  final MammalMeasurementOutlierField field;
  final double value;
  final double lowerBound;
  final double upperBound;
  final String comparisonName;
  final MeasurementComparisonLevel comparisonLevel;
  final int sampleSize;
  final int inlierCount;

  String get comparisonText {
    switch (comparisonLevel) {
      case MeasurementComparisonLevel.species:
        return 'same-species';
      case MeasurementComparisonLevel.genus:
        return 'same-genus';
    }
  }

  String get rangeText =>
      '${_formatNumber(lowerBound)}-${_formatNumber(upperBound)} ${field.unit}';

  String get message =>
      'This ${field.label} is outside the typical local range for '
      '$comparisonName: $rangeText, based on $inlierCount $comparisonText '
      'records after excluding outliers.';
}

class IqrOutlierRange {
  const IqrOutlierRange({
    required this.lowerFence,
    required this.upperFence,
    required this.inlierMin,
    required this.inlierMax,
    required this.sampleSize,
    required this.inlierCount,
  });

  final double lowerFence;
  final double upperFence;
  final double inlierMin;
  final double inlierMax;
  final int sampleSize;
  final int inlierCount;

  bool contains(double value) => value >= inlierMin && value <= inlierMax;

  static IqrOutlierRange? fromValues(List<double> values) {
    if (values.isEmpty) return null;

    final sorted = [...values]..sort();
    final q1 = _percentile(sorted, 0.25);
    final q3 = _percentile(sorted, 0.75);
    final iqr = q3 - q1;
    final lowerFence = q1 - 1.5 * iqr;
    final upperFence = q3 + 1.5 * iqr;
    final inliers = sorted
        .where((value) => value >= lowerFence && value <= upperFence)
        .toList();

    if (inliers.isEmpty) return null;

    return IqrOutlierRange(
      lowerFence: lowerFence,
      upperFence: upperFence,
      inlierMin: inliers.first,
      inlierMax: inliers.last,
      sampleSize: sorted.length,
      inlierCount: inliers.length,
    );
  }

  static double _percentile(List<double> sortedValues, double percentile) {
    if (sortedValues.length == 1) return sortedValues.first;

    final index = (sortedValues.length - 1) * percentile;
    final lowerIndex = index.floor();
    final upperIndex = index.ceil();

    if (lowerIndex == upperIndex) {
      return sortedValues[lowerIndex];
    }

    final lowerWeight = upperIndex - index;
    final upperWeight = index - lowerIndex;
    return sortedValues[lowerIndex] * lowerWeight +
        sortedValues[upperIndex] * upperWeight;
  }
}

class MammalMeasurementOutlierServices extends AppServices {
  const MammalMeasurementOutlierServices({required super.ref});

  Future<MeasurementOutlierResult?> checkValue({
    required String specimenUuid,
    required MammalMeasurementOutlierField field,
    required double value,
  }) async {
    final specimenData =
        await SpecimenQuery(dbAccess).getSpecimenByUuid(specimenUuid);
    final speciesId = specimenData.speciesID;
    if (speciesId == null) return null;

    final currentTaxon = await TaxonomyQuery(dbAccess).getTaxonById(speciesId);
    final specimens =
        await SpecimenQuery(dbAccess).getAllSpecimens(currentProjectUuid);
    final specimenUuids = specimens.map((specimen) => specimen.uuid).toList();
    final measurements = await MammalSpecimenQuery(dbAccess)
        .getMammalMeasurementsBySpecimenUuids(specimenUuids);
    final measurementByUuid = {
      for (final measurement in measurements)
        measurement.specimenUuid: measurement
    };
    final taxonById = {
      for (final taxon in await TaxonomyQuery(dbAccess).getTaxonList())
        taxon.id: taxon
    };

    final speciesValues = _valuesForSpecimens(
      specimens.where((specimen) =>
          specimen.uuid != specimenUuid && specimen.speciesID == speciesId),
      measurementByUuid,
      field,
    );

    final speciesResult = _buildResult(
      values: speciesValues,
      value: value,
      field: field,
      comparisonName: _formatTaxonName(currentTaxon),
      comparisonLevel: MeasurementComparisonLevel.species,
    );
    if (speciesResult != null) return speciesResult;

    final genus = currentTaxon.genus?.trim() ?? '';
    if (genus.isEmpty) return null;

    final genusValues = _valuesForSpecimens(
      specimens.where((specimen) {
        if (specimen.uuid == specimenUuid || specimen.speciesID == null) {
          return false;
        }
        return taxonById[specimen.speciesID]?.genus == genus;
      }),
      measurementByUuid,
      field,
    );

    return _buildResult(
      values: genusValues,
      value: value,
      field: field,
      comparisonName: genus,
      comparisonLevel: MeasurementComparisonLevel.genus,
    );
  }

  List<double> _valuesForSpecimens(
    Iterable<SpecimenData> specimens,
    Map<String, MammalMeasurementData> measurementByUuid,
    MammalMeasurementOutlierField field,
  ) {
    final values = <double>[];

    for (final specimen in specimens) {
      final measurement = measurementByUuid[specimen.uuid];
      if (measurement == null) continue;

      final value = field.readValue(measurement);
      if (value != null && value > 0) {
        values.add(value);
      }
    }

    return values;
  }

  MeasurementOutlierResult? _buildResult({
    required List<double> values,
    required double value,
    required MammalMeasurementOutlierField field,
    required String comparisonName,
    required MeasurementComparisonLevel comparisonLevel,
  }) {
    if (values.length < measurementOutlierMinSampleSize) return null;

    final range = IqrOutlierRange.fromValues(values);
    if (range == null || range.contains(value)) return null;

    return MeasurementOutlierResult(
      field: field,
      value: value,
      lowerBound: range.inlierMin,
      upperBound: range.inlierMax,
      comparisonName: comparisonName,
      comparisonLevel: comparisonLevel,
      sampleSize: range.sampleSize,
      inlierCount: range.inlierCount,
    );
  }

  String _formatTaxonName(TaxonomyData taxon) {
    final parts = [taxon.genus, taxon.specificEpithet]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim())
        .toList();

    if (parts.isEmpty) return 'this taxon';

    return parts.join(' ');
  }
}

String _formatNumber(double value) {
  final rounded = (value * 100).round() / 100;
  if (rounded == rounded.truncateToDouble()) {
    return rounded.toInt().toString();
  }
  return rounded
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
