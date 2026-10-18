import 'dart:math' as math;

import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimens/numbered_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double _gramsPerKilogram = 1000;
const double _gramsPerPound = 453.59237;

/// Converts [value] from the weight unit [from] to [to].
///
/// Units follow `specimenWeightUnits`. A missing unit is read as grams, the
/// default for every specimen weight. Returns null for an unknown unit so a
/// mismatched value never silently enters a summary.
double? convertSpecimenWeight(double value, String? from, String? to) {
  final grams = _toGrams(value, from ?? 'g');
  if (grams == null) return null;
  switch (to ?? 'g') {
    case 'g':
      return grams;
    case 'kg':
      return grams / _gramsPerKilogram;
    case 'lbs':
      return grams / _gramsPerPound;
    default:
      return null;
  }
}

double? _toGrams(double value, String unit) {
  switch (unit) {
    case 'g':
      return value;
    case 'kg':
      return value * _gramsPerKilogram;
    case 'lbs':
      return value * _gramsPerPound;
    default:
      return null;
  }
}

/// Parses a measurement field, returning null for an empty or invalid value.
double? parseMeasurement(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final parsed = double.tryParse(text);
  return parsed != null && parsed.isFinite ? parsed : null;
}

/// Short ID for an individual: its individual or tag ID, falling back to the
/// row ID.
String individualShortId(SpecimenIndividualData individual) {
  final id = individual.individualID?.trim();
  return id == null || id.isEmpty ? '#${individual.id}' : id;
}

/// Display name for an individual.
String individualLabel(SpecimenIndividualData individual) =>
    'Individual ${individualShortId(individual)}';

/// Summary statistics for one measurement across the individuals in a lot.
class MeasurementSummary {
  const MeasurementSummary({
    required this.count,
    required this.min,
    required this.max,
    required this.mean,
    this.standardDeviation,
  });

  /// Number of individuals with a recorded value.
  final int count;
  final double min;
  final double max;
  final double mean;

  /// Sample standard deviation, or null with fewer than two values.
  final double? standardDeviation;

  /// Returns null when no value is recorded.
  static MeasurementSummary? fromValues(Iterable<double?> values) {
    final recorded = values.whereType<double>().toList(growable: false);
    if (recorded.isEmpty) return null;
    final count = recorded.length;
    final mean = recorded.reduce((a, b) => a + b) / count;
    double? standardDeviation;
    if (count > 1) {
      final squares = recorded
          .map((value) => math.pow(value - mean, 2))
          .reduce((a, b) => a + b);
      standardDeviation = math.sqrt(squares / (count - 1));
    }
    return MeasurementSummary(
      count: count,
      min: recorded.reduce(math.min),
      max: recorded.reduce(math.max),
      mean: mean,
      standardDeviation: standardDeviation,
    );
  }
}

/// Lot statistics derived from its measured individuals.
class FishLotStats {
  const FishLotStats({
    required this.individualCount,
    this.standardLength,
    this.totalLength,
    this.weight,
  });

  factory FishLotStats.fromIndividuals(
    List<SpecimenIndividualData> individuals, {
    String? weightUnit,
  }) {
    return FishLotStats(
      individualCount: individuals.length,
      standardLength: MeasurementSummary.fromValues(
        individuals.map((e) => e.standardLength),
      ),
      totalLength: MeasurementSummary.fromValues(
        individuals.map((e) => e.totalLength),
      ),
      weight: MeasurementSummary.fromValues(
        individuals.map(
          (e) => e.weight == null
              ? null
              : convertSpecimenWeight(e.weight!, e.weightUnit, weightUnit),
        ),
      ),
    );
  }

  /// Number of individuals entered for the lot, measured or not.
  final int individualCount;

  /// Standard length in mm.
  final MeasurementSummary? standardLength;

  /// Total length in mm.
  final MeasurementSummary? totalLength;

  /// Weight in the lot's weight unit.
  final MeasurementSummary? weight;

  /// The lot range columns that follow these statistics.
  ///
  /// The individual count only grows: a lot can hold more fish than were
  /// measured, so a larger recorded count is kept.
  FishAttributeCompanion toAutoRange(int? currentIndividualCount) {
    return FishAttributeCompanion(
      minStandardLength: db.Value(standardLength?.min),
      maxStandardLength: db.Value(standardLength?.max),
      minTotalLength: db.Value(totalLength?.min),
      maxTotalLength: db.Value(totalLength?.max),
      minWeight: db.Value(weight?.min),
      maxWeight: db.Value(weight?.max),
      individualCount:
          currentIndividualCount == null ||
              currentIndividualCount < individualCount
          ? db.Value(individualCount)
          : const db.Value.absent(),
    );
  }
}

/// Persists fish lot records, their individuals, and the parts and parasites
/// linked to those individuals.
class FishLotServices extends AppServices {
  const FishLotServices({required super.ref});

  Future<FishAttributeData> getAttribute(String specimenUuid) {
    return FishSpecimenQuery(dbAccess).getFishAttributeByUuid(specimenUuid);
  }

  Future<void> updateAttribute(
    String specimenUuid,
    FishAttributeCompanion entries,
  ) async {
    await FishSpecimenQuery(
      dbAccess,
    ).updateFishAttributes(specimenUuid, entries);
  }

  /// Turns automatic lot ranges on or off and applies them when enabled.
  Future<void> setAutoRange(String specimenUuid, bool isAuto) async {
    await updateAttribute(
      specimenUuid,
      FishAttributeCompanion(isAutoRange: db.Value(isAuto ? 1 : 0)),
    );
    if (isAuto) await recomputeRange(specimenUuid);
  }

  /// Changes the lot weight unit, which individuals share.
  Future<void> updateWeightUnit(String specimenUuid, String unit) async {
    await dbAccess.transaction(() async {
      await updateAttribute(
        specimenUuid,
        FishAttributeCompanion(weightUnit: db.Value(unit)),
      );
      await SpecimenIndividualQuery(
        dbAccess,
      ).updateWeightUnit(specimenUuid, unit);
    });
    await recomputeRange(specimenUuid);
  }

  /// Writes the lot ranges from its individuals when automatic ranges are on.
  Future<void> recomputeRange(String specimenUuid) async {
    final attribute = await FishSpecimenQuery(
      dbAccess,
    ).getFishAttributeOrNull(specimenUuid);
    if (attribute == null || attribute.isAutoRange != 1) {
      _invalidate(specimenUuid);
      return;
    }
    final individuals = await SpecimenIndividualQuery(
      dbAccess,
    ).getIndividuals(specimenUuid);
    final stats = FishLotStats.fromIndividuals(
      individuals,
      weightUnit: attribute.weightUnit,
    );
    await updateAttribute(
      specimenUuid,
      stats.toAutoRange(attribute.individualCount),
    );
    _invalidate(specimenUuid);
  }

  Future<int> createIndividual(
    String specimenUuid,
    SpecimenIndividualCompanion form,
  ) async {
    final id = await SpecimenIndividualQuery(
      dbAccess,
    ).createIndividual(form.copyWith(specimenUuid: db.Value(specimenUuid)));
    await recomputeRange(specimenUuid);
    return id;
  }

  Future<void> updateIndividual(
    String specimenUuid,
    int id,
    SpecimenIndividualCompanion entries,
  ) async {
    await SpecimenIndividualQuery(dbAccess).updateIndividual(id, entries);
    await recomputeRange(specimenUuid);
  }

  Future<void> deleteIndividual(String specimenUuid, int id) async {
    await dbAccess.transaction(() async {
      await SpecimenPartIndividualQuery(dbAccess).deleteLinksForIndividual(id);
      await ParasiteIndividualQuery(dbAccess).deleteLinksForIndividual(id);
      await SpecimenIndividualQuery(dbAccess).deleteIndividual(id);
    });
    ref.invalidate(partBySpecimenProvider(specimenUuid));
    ref.invalidate(parasiteBySpecimenProvider(specimenUuid));
    await recomputeRange(specimenUuid);
  }

  void _invalidate(String specimenUuid) {
    ref.invalidate(individualBySpecimenProvider(specimenUuid));
    ref.invalidate(fishAttributeProvider(specimenUuid));
  }
}

const String individualTagPrefixKey = 'individualTagPrefix';
const String individualTagNumberKey = 'individualTagNumber';
const String individualTagSuffixKey = 'individualTagSuffix';

/// Auto-numbers individual tag IDs, the way `TissueIdServices` numbers
/// tissues, with a prefix, a zero-padded number, and a suffix.
///
/// A form shows [peekNextTag] without advancing the counter. The counter
/// only advances when a saved tag still matches it, so a tag the user types
/// over does not use up a number.
class IndividualTagIdServices extends AppServices implements NumberedIdStore {
  const IndividualTagIdServices({required super.ref});

  SharedPreferences get _prefs => ref.read(settingProvider);

  @override
  NumberedIdFormat get format => NumberedIdFormat(
    prefix: _prefs.getString(individualTagPrefixKey) ?? '',
    number: _prefs.getString(individualTagNumberKey) ?? '',
    suffix: _prefs.getString(individualTagSuffixKey) ?? '',
  );

  String? peekNextTag() => format.nextTag;

  /// Advances the counter when [savedTag] used the auto-numbered tag.
  Future<void> consumeIfMatches(String? savedTag) async {
    final current = format;
    final next = current.incrementedNumber;
    if (savedTag == null || savedTag != current.nextTag || next == null) {
      return;
    }
    await setNumber(next);
  }

  @override
  Future<void> setPrefix(String prefix) =>
      _prefs.setString(individualTagPrefixKey, prefix);

  @override
  Future<void> setNumber(String number) =>
      _prefs.setString(individualTagNumberKey, numberedIdDigits(number));

  @override
  Future<void> setSuffix(String suffix) =>
      _prefs.setString(individualTagSuffixKey, suffix);
}
