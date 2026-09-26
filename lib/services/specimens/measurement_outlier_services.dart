import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/common/io_services.dart';

const int measurementOutlierMinSampleSize = 10;

abstract interface class MeasurementOutlierFieldInfo {
  String get label;
  String get unit;
}

enum MammalMeasurementOutlierField implements MeasurementOutlierFieldInfo {
  totalLength,
  tailLength,
  hindFootLength,
  earLength,
  weight;

  @override
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

  @override
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

  double? readValue(MammalAttributeData data) {
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
        return _weightInGrams(data.weight, data.weightUnit);
    }
  }
}

enum AvianMeasurementOutlierField implements MeasurementOutlierFieldInfo {
  weight,
  wingspan;

  @override
  String get label {
    switch (this) {
      case AvianMeasurementOutlierField.weight:
        return 'weight';
      case AvianMeasurementOutlierField.wingspan:
        return 'wingspan';
    }
  }

  @override
  String get unit {
    switch (this) {
      case AvianMeasurementOutlierField.weight:
        return 'g';
      case AvianMeasurementOutlierField.wingspan:
        return 'mm';
    }
  }

  double? readValue(BirdAttributeData data) {
    switch (this) {
      case AvianMeasurementOutlierField.weight:
        return _weightInGrams(data.weight, data.weightUnit);
      case AvianMeasurementOutlierField.wingspan:
        return data.wingspan;
    }
  }
}

enum HerpMeasurementOutlierField implements MeasurementOutlierFieldInfo {
  weight,
  svl;

  @override
  String get label {
    switch (this) {
      case HerpMeasurementOutlierField.weight:
        return 'weight';
      case HerpMeasurementOutlierField.svl:
        return 'snout-vent length';
    }
  }

  @override
  String get unit {
    switch (this) {
      case HerpMeasurementOutlierField.weight:
        return 'g';
      case HerpMeasurementOutlierField.svl:
        return 'cm';
    }
  }

  double? readValue(HerpAttributeData data) {
    switch (this) {
      case HerpMeasurementOutlierField.weight:
        return _weightInGrams(data.weight, data.weightUnit);
      case HerpMeasurementOutlierField.svl:
        return data.svl;
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
    required this.unit,
    required this.comparisonName,
    required this.comparisonLevel,
    required this.sampleSize,
    required this.inlierCount,
  });

  final MeasurementOutlierFieldInfo field;
  final double value;
  final double lowerBound;
  final double upperBound;
  final String unit;
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

  String get rangeText {
    final fractionDigits = unit == 'kg' || unit == 'lbs' ? 6 : 2;
    return '${_formatNumber(lowerBound, fractionDigits: fractionDigits)}-'
        '${_formatNumber(upperBound, fractionDigits: fractionDigits)} $unit';
  }

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

abstract class SpecimenMeasurementOutlierServices<
  TData,
  TField extends MeasurementOutlierFieldInfo
>
    extends AppServices {
  const SpecimenMeasurementOutlierServices({required super.ref});

  Future<List<TData>> getMeasurements(List<String> specimenUuids);

  String getSpecimenUuid(TData measurement);

  double? readValue(TField field, TData measurement);

  Future<MeasurementOutlierResult?> checkValue({
    required String specimenUuid,
    required TField field,
    required double value,
    String weightUnit = 'g',
  }) async {
    // Compare weights in grams and convert only the displayed range.
    final unit = field.unit == 'g' ? weightUnit : field.unit;
    final valueScale = field.unit == 'g' ? _gramsPerUnit(weightUnit) : 1.0;
    if (valueScale == null) return null;

    final specimenData = await SpecimenQuery(
      dbAccess,
    ).getSpecimenByUuid(specimenUuid);
    final speciesId = specimenData.speciesID;
    if (speciesId == null) return null;

    final currentTaxon = await TaxonomyQuery(dbAccess).getTaxonById(speciesId);
    final specimens = await SpecimenQuery(
      dbAccess,
    ).getAllSpecimens(currentProjectUuid);
    final specimenUuids = specimens.map((specimen) => specimen.uuid).toList();
    final measurements = await getMeasurements(specimenUuids);
    final measurementByUuid = {
      for (final measurement in measurements)
        getSpecimenUuid(measurement): measurement,
    };
    final taxonById = {
      for (final taxon in await TaxonomyQuery(dbAccess).getTaxonList())
        taxon.id: taxon,
    };

    final speciesValues = _valuesForSpecimens(
      specimens.where(
        (specimen) =>
            specimen.uuid != specimenUuid && specimen.speciesID == speciesId,
      ),
      measurementByUuid,
      field,
    );

    final speciesResult = _buildResult(
      values: speciesValues,
      value: value,
      field: field,
      unit: unit,
      valueScale: valueScale,
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
      unit: unit,
      valueScale: valueScale,
      comparisonName: genus,
      comparisonLevel: MeasurementComparisonLevel.genus,
    );
  }

  List<double> _valuesForSpecimens(
    Iterable<SpecimenData> specimens,
    Map<String, TData> measurementByUuid,
    TField field,
  ) {
    final values = <double>[];

    for (final specimen in specimens) {
      final measurement = measurementByUuid[specimen.uuid];
      if (measurement == null) continue;

      final value = readValue(field, measurement);
      if (value != null && value > 0) {
        values.add(value);
      }
    }

    return values;
  }

  MeasurementOutlierResult? _buildResult({
    required List<double> values,
    required double value,
    required TField field,
    required String unit,
    required double valueScale,
    required String comparisonName,
    required MeasurementComparisonLevel comparisonLevel,
  }) {
    if (values.length < measurementOutlierMinSampleSize) return null;

    final range = IqrOutlierRange.fromValues(values);
    if (range == null || range.contains(value * valueScale)) return null;

    return MeasurementOutlierResult(
      field: field,
      value: value,
      lowerBound: range.inlierMin / valueScale,
      upperBound: range.inlierMax / valueScale,
      unit: unit,
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

class MammalMeasurementOutlierServices
    extends
        SpecimenMeasurementOutlierServices<
          MammalAttributeData,
          MammalMeasurementOutlierField
        > {
  const MammalMeasurementOutlierServices({required super.ref});

  @override
  Future<List<MammalAttributeData>> getMeasurements(
    List<String> specimenUuids,
  ) => MammalSpecimenQuery(
    dbAccess,
  ).getMammalAttributesBySpecimenUuids(specimenUuids);

  @override
  String getSpecimenUuid(MammalAttributeData measurement) =>
      measurement.specimenUuid;

  @override
  double? readValue(
    MammalMeasurementOutlierField field,
    MammalAttributeData data,
  ) => field.readValue(data);
}

class AvianMeasurementOutlierServices
    extends
        SpecimenMeasurementOutlierServices<
          BirdAttributeData,
          AvianMeasurementOutlierField
        > {
  const AvianMeasurementOutlierServices({required super.ref});

  @override
  Future<List<BirdAttributeData>> getMeasurements(List<String> specimenUuids) =>
      BirdSpecimenQuery(
        dbAccess,
      ).getBirdAttributesBySpecimenUuids(specimenUuids);

  @override
  String getSpecimenUuid(BirdAttributeData measurement) =>
      measurement.specimenUuid;

  @override
  double? readValue(
    AvianMeasurementOutlierField field,
    BirdAttributeData data,
  ) => field.readValue(data);
}

class HerpMeasurementOutlierServices
    extends
        SpecimenMeasurementOutlierServices<
          HerpAttributeData,
          HerpMeasurementOutlierField
        > {
  const HerpMeasurementOutlierServices({required super.ref});

  @override
  Future<List<HerpAttributeData>> getMeasurements(List<String> specimenUuids) =>
      HerpSpecimenQuery(
        dbAccess,
      ).getHerpAttributesBySpecimenUuids(specimenUuids);

  @override
  String getSpecimenUuid(HerpAttributeData measurement) =>
      measurement.specimenUuid;

  @override
  double? readValue(
    HerpMeasurementOutlierField field,
    HerpAttributeData data,
  ) => field.readValue(data);
}

double? _gramsPerUnit(String? unit) => switch (unit?.trim().toLowerCase()) {
  null || '' || 'g' => 1.0,
  'kg' => 1000.0,
  'lbs' => 453.59237,
  _ => null,
};

double? _weightInGrams(double? value, String? unit) {
  final scale = _gramsPerUnit(unit);
  if (value == null || scale == null) return null;
  return value * scale;
}

String _formatNumber(double value, {int fractionDigits = 2}) {
  return value
      .toStringAsFixed(fractionDigits)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
