import 'package:flutter/foundation.dart';
import 'package:nahpu/services/types/export.dart';

/// Fewest variables a principal component analysis accepts.
const int pcaMinVariables = 2;

/// Unit every specimen weight is converted to before an analysis.
const String analyticsWeightUnit = 'g';

/// A measurement column of a taxon attribute table.
///
/// Each value is named after its column, which several attribute tables can
/// share, such as `weight`.
enum MeasurementColumn {
  totalLength('mm'),
  tailLength('mm'),

  /// Head and body length of a mammal: total length minus tail length, as
  /// the specimen form computes it. It is not stored.
  headBodyLength('mm'),
  hindFootLength('mm'),
  earLength('mm'),
  forearm('mm'),
  tibia('mm'),
  weight(analyticsWeightUnit),
  testisLength('mm'),
  testisWidth('mm'),
  frequencyMax('kHz'),
  frequencyMin('kHz'),
  frequencyAtMaxEnergy('kHz'),
  duration('s'),
  wingspan('mm'),
  bursaLength('mm'),
  bursaWidth('mm'),
  ovaryLength('mm'),
  ovaryWidth('mm'),
  oviductWidth('mm'),
  firstOvaSize('mm'),
  secondOvaSize('mm'),
  thirdOvaSize('mm'),
  svl('cm'),
  headWidth('mm'),
  bodyLength('mm'),
  wingspanUpper('mm'),
  wingspanLower('mm'),
  standardLength('mm');

  const MeasurementColumn(this.unit);

  /// Unit the column is recorded in; weights are converted to it.
  final String unit;

  /// Whether the value carries a per-record unit that needs converting.
  bool get isWeight => this == MeasurementColumn.weight;
}

/// Taxon attribute table and the measurements it offers to an analysis.
class MeasurementTable {
  const MeasurementTable({
    required this.table,
    required this.columns,
    required this.defaults,
    this.hasWeightUnit = true,
  });

  /// Name of the attribute table.
  final String table;

  /// Every numeric measurement column, in the order the picker lists them.
  final List<MeasurementColumn> columns;

  /// Body measurements selected when the group is first opened.
  final Set<MeasurementColumn> defaults;

  /// Whether the table stores a `weightUnit` beside `weight`.
  final bool hasWeightUnit;

  /// The measurement table of [taxonGroup], or null for all taxa: variables
  /// differ between groups, so an analysis covers one group at a time.
  static MeasurementTable? of(SpecimenRecordType taxonGroup) =>
      switch (taxonGroup) {
        SpecimenRecordType.mammals => _mammals,
        SpecimenRecordType.birds => _birds,
        SpecimenRecordType.herpetofauna => _herps,
        SpecimenRecordType.invertebrates => _invertebrates,
        SpecimenRecordType.fishes => _fishes,
        SpecimenRecordType.allTaxa => null,
      };

  static const _mammals = MeasurementTable(
    table: 'mammalAttribute',
    columns: [
      MeasurementColumn.totalLength,
      MeasurementColumn.tailLength,
      MeasurementColumn.headBodyLength,
      MeasurementColumn.hindFootLength,
      MeasurementColumn.earLength,
      MeasurementColumn.weight,
      MeasurementColumn.forearm,
      MeasurementColumn.tibia,
      MeasurementColumn.testisLength,
      MeasurementColumn.testisWidth,
      MeasurementColumn.frequencyMax,
      MeasurementColumn.frequencyMin,
      MeasurementColumn.frequencyAtMaxEnergy,
      MeasurementColumn.duration,
    ],
    defaults: {
      MeasurementColumn.totalLength,
      MeasurementColumn.tailLength,
      MeasurementColumn.hindFootLength,
      MeasurementColumn.earLength,
      MeasurementColumn.weight,
    },
  );

  static const _birds = MeasurementTable(
    table: 'birdAttribute',
    columns: [
      MeasurementColumn.weight,
      MeasurementColumn.wingspan,
      MeasurementColumn.bursaLength,
      MeasurementColumn.bursaWidth,
      MeasurementColumn.testisLength,
      MeasurementColumn.testisWidth,
      MeasurementColumn.ovaryLength,
      MeasurementColumn.ovaryWidth,
      MeasurementColumn.oviductWidth,
      MeasurementColumn.firstOvaSize,
      MeasurementColumn.secondOvaSize,
      MeasurementColumn.thirdOvaSize,
    ],
    defaults: {MeasurementColumn.weight, MeasurementColumn.wingspan},
  );

  static const _herps = MeasurementTable(
    table: 'herpAttribute',
    columns: [MeasurementColumn.svl, MeasurementColumn.weight],
    defaults: {MeasurementColumn.svl, MeasurementColumn.weight},
  );

  static const _invertebrates = MeasurementTable(
    table: 'invertebrateAttribute',
    columns: [
      MeasurementColumn.bodyLength,
      MeasurementColumn.headWidth,
      MeasurementColumn.wingspanUpper,
      MeasurementColumn.wingspanLower,
    ],
    defaults: {
      MeasurementColumn.bodyLength,
      MeasurementColumn.headWidth,
      MeasurementColumn.wingspanUpper,
      MeasurementColumn.wingspanLower,
    },
    hasWeightUnit: false,
  );

  /// Lot ranges are left out: they summarize several animals, and the lot's
  /// individuals are analyzed instead.
  static const _fishes = MeasurementTable(
    table: 'fishAttribute',
    columns: [
      MeasurementColumn.standardLength,
      MeasurementColumn.totalLength,
      MeasurementColumn.weight,
    ],
    defaults: {
      MeasurementColumn.standardLength,
      MeasurementColumn.totalLength,
      MeasurementColumn.weight,
    },
  );
}

/// Taxon groups an analysis can cover, in the order the picker lists them.
const List<SpecimenRecordType> analyticsTaxonGroups = [
  SpecimenRecordType.mammals,
  SpecimenRecordType.birds,
  SpecimenRecordType.herpetofauna,
  SpecimenRecordType.invertebrates,
  SpecimenRecordType.fishes,
];

/// A numeric variable an analysis can use: a measurement column or a numeric
/// custom field.
@immutable
class AnalyticsVariable {
  const AnalyticsVariable.column(MeasurementColumn this.column)
    : customFieldId = null,
      customFieldName = null;

  const AnalyticsVariable.customField({required int id, required String name})
    : column = null,
      customFieldId = id,
      customFieldName = name;

  final MeasurementColumn? column;

  /// Row ID of the custom field definition.
  final int? customFieldId;
  final String? customFieldName;

  /// Stable identifier, also used in widget keys.
  String get id => column?.name ?? 'custom-$customFieldId';

  @override
  bool operator ==(Object other) =>
      other is AnalyticsVariable &&
      other.column == column &&
      other.customFieldId == customFieldId;

  @override
  int get hashCode => Object.hash(column, customFieldId);
}

/// A variable with the number of records that have a usable value for it.
class AnalyticsVariableOption {
  const AnalyticsVariableOption({required this.variable, required this.count});

  final AnalyticsVariable variable;
  final int count;
}

/// Matrix the principal components are extracted from.
enum PcaScalingMode {
  /// Standardizes every variable, so each contributes equally.
  correlation,

  /// Keeps the original variances, so large-valued variables dominate.
  covariance,
}

/// Plot the Analytics view draws.
enum AnalyticsMethod {
  /// Principal component analysis of several measurements.
  pca,

  /// One measurement against another.
  scatter,
}

/// Record attribute the score plot colors its points by.
enum AnalyticsColorBy {
  none,
  species,
  genus,
  family,
  sex,
  lifeStage,
  site,

  /// Offered only when the analysis covers every project.
  project,
}

/// What a principal component analysis covers.
@immutable
class PcaRequest {
  const PcaRequest({
    required this.projectUuid,
    required this.taxonGroup,
    required this.variables,
    this.scaling = PcaScalingMode.correlation,
    this.logTransform = false,
    this.siteIds = const {},
    this.speciesIds = const {},
  });

  /// Project the analysis covers, or null for every project in the database.
  final String? projectUuid;
  final SpecimenRecordType taxonGroup;
  final List<AnalyticsVariable> variables;
  final PcaScalingMode scaling;
  final bool logTransform;

  /// Sites the records come from; empty for every site.
  final Set<int> siteIds;

  /// Species the records belong to; empty for every species.
  final Set<int> speciesIds;

  @override
  bool operator ==(Object other) =>
      other is PcaRequest &&
      other.projectUuid == projectUuid &&
      other.taxonGroup == taxonGroup &&
      listEquals(other.variables, variables) &&
      other.scaling == scaling &&
      other.logTransform == logTransform &&
      setEquals(other.siteIds, siteIds) &&
      setEquals(other.speciesIds, speciesIds);

  @override
  int get hashCode => Object.hash(
    projectUuid,
    taxonGroup,
    Object.hashAll(variables),
    scaling,
    logTransform,
    Object.hashAllUnordered(siteIds),
    Object.hashAllUnordered(speciesIds),
  );
}

/// What a scatter plot of two variables covers.
@immutable
class ScatterRequest {
  const ScatterRequest({
    required this.projectUuid,
    required this.taxonGroup,
    required this.x,
    required this.y,
    this.logTransform = false,
    this.siteIds = const {},
    this.speciesIds = const {},
  });

  /// Project the plot covers, or null for every project in the database.
  final String? projectUuid;
  final SpecimenRecordType taxonGroup;
  final AnalyticsVariable x;
  final AnalyticsVariable y;
  final bool logTransform;

  /// Sites the records come from; empty for every site.
  final Set<int> siteIds;

  /// Species the records belong to; empty for every species.
  final Set<int> speciesIds;

  /// The record query of the two variables, in `x`, `y` order.
  PcaRequest get recordRequest => PcaRequest(
    projectUuid: projectUuid,
    taxonGroup: taxonGroup,
    variables: [x, y],
    siteIds: siteIds,
    speciesIds: speciesIds,
  );

  @override
  bool operator ==(Object other) =>
      other is ScatterRequest &&
      other.projectUuid == projectUuid &&
      other.taxonGroup == taxonGroup &&
      other.x == x &&
      other.y == y &&
      other.logTransform == logTransform &&
      setEquals(other.siteIds, siteIds) &&
      setEquals(other.speciesIds, speciesIds);

  @override
  int get hashCode => Object.hash(
    projectUuid,
    taxonGroup,
    x,
    y,
    logTransform,
    Object.hashAllUnordered(siteIds),
    Object.hashAllUnordered(speciesIds),
  );
}

/// Records of a scatter plot with their plotted values.
class ScatterResult {
  const ScatterResult({
    required this.request,
    required this.records,
    required this.points,
    required this.excludedCount,
    this.correlation,
  });

  final ScatterRequest request;

  /// Records with a usable value for both variables, in the order of
  /// [points].
  final List<AnalyticsRecord> records;

  /// Plotted `(x, y)` values, log-transformed when the request asks for it.
  final List<({double x, double y})> points;

  /// Records left out for a missing value.
  final int excludedCount;

  /// Pearson correlation of the plotted values, or null when it is
  /// undefined: fewer than two points, or a variable that does not vary.
  final double? correlation;
}

/// One measured animal: a specimen, or an individual of a fish lot.
class AnalyticsRecord {
  const AnalyticsRecord({
    required this.specimenUuid,
    required this.values,
    required this.species,
    required this.genus,
    required this.family,
    required this.sex,
    required this.lifeStage,
    required this.site,
    required this.project,
    this.fieldNumber,
  });

  final String specimenUuid;

  /// One value per requested variable, in request order; null when missing.
  final List<double?> values;
  final String species;
  final String genus;
  final String family;
  final String sex;
  final String lifeStage;
  final String site;
  final String project;
  final int? fieldNumber;

  /// The label [colorBy] groups this record under, or null for no grouping.
  String? group(AnalyticsColorBy colorBy) => switch (colorBy) {
    AnalyticsColorBy.none => null,
    AnalyticsColorBy.species => species,
    AnalyticsColorBy.genus => genus,
    AnalyticsColorBy.family => family,
    AnalyticsColorBy.sex => sex,
    AnalyticsColorBy.lifeStage => lifeStage,
    AnalyticsColorBy.site => site,
    AnalyticsColorBy.project => project,
  };
}

/// Descriptive statistics of one variable over its usable values.
class AnalyticsColumnSummary {
  const AnalyticsColumnSummary({
    required this.count,
    required this.missing,
    this.mean,
    this.standardDeviation,
    this.min,
    this.max,
    this.median,
  });

  final int count;
  final int missing;
  final double? mean;
  final double? standardDeviation;
  final double? min;
  final double? max;
  final double? median;
}

/// Outcome of a principal component analysis.
class PcaAnalysisResult {
  const PcaAnalysisResult({
    required this.variables,
    required this.records,
    required this.excludedCount,
    required this.summaries,
    required this.eigenvalues,
    required this.explainedVariance,
    required this.cumulativeVariance,
    required this.loadings,
    required this.scores,
    required this.correlations,
  });

  final List<AnalyticsVariable> variables;

  /// Records with a value for every variable, in the order of [scores].
  final List<AnalyticsRecord> records;

  /// Records left out for a missing value.
  final int excludedCount;

  /// One summary per variable, over every usable value before transformation.
  final List<AnalyticsColumnSummary> summaries;
  final List<double> eigenvalues;
  final List<double> explainedVariance;
  final List<double> cumulativeVariance;

  /// Loadings indexed `[variable][component]`.
  final List<List<double>> loadings;

  /// Scores indexed `[record][component]`.
  final List<List<double>> scores;

  /// Correlations indexed `[variable][variable]`.
  final List<List<double>> correlations;

  int get componentCount => eigenvalues.length;
}

/// Why a principal component analysis could not run.
enum PcaFailureKind { tooFewRecords, tooFewVariables, constantVariable, other }

/// A principal component analysis that could not run.
class PcaFailure implements Exception {
  const PcaFailure(
    this.kind, {
    this.completeCount,
    this.minimum,
    this.variable,
    this.message,
  });

  final PcaFailureKind kind;

  /// Records with a value for every variable, for [PcaFailureKind.tooFewRecords].
  final int? completeCount;

  /// Smallest count the analysis accepts.
  final int? minimum;

  /// The variable that does not vary, for [PcaFailureKind.constantVariable].
  final AnalyticsVariable? variable;
  final String? message;

  @override
  String toString() => message ?? 'PcaFailure(${kind.name})';
}
