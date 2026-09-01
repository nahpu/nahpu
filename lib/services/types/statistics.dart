enum StatisticMeasure { specimens, species, partQuantity }

enum StatisticGroup {
  species,
  taxonRank,
  site,
  date,
  method,
  sex,
  lifeStage,
  partType,
  partTreatment,
}

/// Taxonomic ranks reported by the record summary and by the taxon rank
/// grouping, declared from the highest rank to the lowest.
///
/// This mirrors `TaxonRank` in `services/projects/taxonomy_services.dart`, but
/// stays separate so this types library keeps its database and provider
/// imports out.
enum StatisticTaxonRank {
  taxonClass(label: 'Class', pluralLabel: 'Classes', column: 'taxonClass'),
  order(label: 'Order', pluralLabel: 'Orders', column: 'taxonOrder'),
  family(label: 'Family', pluralLabel: 'Families', column: 'taxonFamily'),
  genus(label: 'Genus', pluralLabel: 'Genera', column: 'genus'),
  species(label: 'Species', pluralLabel: 'Species');

  const StatisticTaxonRank({
    required this.label,
    required this.pluralLabel,
    this.column,
  });

  final String label;
  final String pluralLabel;

  /// Column in the `taxonomy` table that stores this rank.
  ///
  /// Species has none: it is derived from genus plus specific epithet, so the
  /// queries build it from both columns instead.
  final String? column;

  String get fileSlug => label.toLowerCase();

  /// Ranks offered by the taxon rank picker.
  ///
  /// Species is left out because [StatisticGroup.species] already covers it and
  /// is the only group that carries the site filter and the breakdowns.
  static const List<StatisticTaxonRank> groupable = [
    taxonClass,
    order,
    family,
    genus,
  ];

  static const StatisticTaxonRank defaultGroupable = family;
}

enum StatisticBreakdown { sex, lifeStage }

enum StatisticFilterKind { site, species }

extension StatisticMeasureLabels on StatisticMeasure {
  String get label => switch (this) {
    StatisticMeasure.specimens => 'Specimens',
    StatisticMeasure.species => 'Species',
    StatisticMeasure.partQuantity => 'Part quantity',
  };

  String get countLabel => switch (this) {
    StatisticMeasure.specimens => 'Specimens',
    StatisticMeasure.species => 'Species',
    StatisticMeasure.partQuantity => 'Quantity',
  };

  String get fileSlug => switch (this) {
    StatisticMeasure.specimens => 'specimens',
    StatisticMeasure.species => 'species',
    StatisticMeasure.partQuantity => 'part-quantity',
  };

  List<StatisticGroup> groups({required bool hasLifeStage}) => switch (this) {
    StatisticMeasure.specimens => [
      StatisticGroup.species,
      StatisticGroup.taxonRank,
      StatisticGroup.site,
      StatisticGroup.date,
      StatisticGroup.method,
      StatisticGroup.sex,
      if (hasLifeStage) StatisticGroup.lifeStage,
    ],
    StatisticMeasure.species => [
      StatisticGroup.taxonRank,
      StatisticGroup.site,
      StatisticGroup.date,
      StatisticGroup.method,
      StatisticGroup.sex,
      if (hasLifeStage) StatisticGroup.lifeStage,
    ],
    StatisticMeasure.partQuantity => [
      StatisticGroup.partType,
      StatisticGroup.partTreatment,
    ],
  };
}

extension StatisticGroupLabels on StatisticGroup {
  String get label => switch (this) {
    StatisticGroup.species => 'Species',
    StatisticGroup.taxonRank => 'Taxon rank',
    StatisticGroup.site => 'Site',
    StatisticGroup.date => 'Date',
    StatisticGroup.method => 'Method',
    StatisticGroup.sex => 'Sex',
    StatisticGroup.lifeStage => 'Life stage',
    StatisticGroup.partType => 'Part type',
    StatisticGroup.partTreatment => 'Treatment',
  };

  String get fileSlug => switch (this) {
    StatisticGroup.species => 'species',
    StatisticGroup.taxonRank => 'taxon-rank',
    StatisticGroup.site => 'site',
    StatisticGroup.date => 'date',
    StatisticGroup.method => 'method',
    StatisticGroup.sex => 'sex',
    StatisticGroup.lifeStage => 'life-stage',
    StatisticGroup.partType => 'part-type',
    StatisticGroup.partTreatment => 'treatment',
  };

  bool get displaysSpeciesCategories => this == StatisticGroup.species;
}

/// Whether category labels for [group] and [rank] are scientific names, and so
/// are rendered in italics.
bool italicizesCategories(StatisticGroup? group, StatisticTaxonRank? rank) =>
    (group?.displaysSpeciesCategories ?? false) ||
    rank == StatisticTaxonRank.genus ||
    rank == StatisticTaxonRank.species;

extension StatisticBreakdownLabels on StatisticBreakdown {
  String get label => switch (this) {
    StatisticBreakdown.sex => 'Sex',
    StatisticBreakdown.lifeStage => 'Life stage',
  };
}

class StatisticSelection {
  const StatisticSelection({
    required this.measure,
    required this.group,
    this.rank,
    this.breakdown,
  });

  final StatisticMeasure measure;
  final StatisticGroup group;

  /// Rank to group by when [group] is [StatisticGroup.taxonRank].
  final StatisticTaxonRank? rank;
  final StatisticBreakdown? breakdown;
}

class StatisticDatum {
  const StatisticDatum({
    required this.label,
    required this.count,
    this.seriesLabel,
  });

  final String label;
  final int count;
  final String? seriesLabel;
}

class StatisticFilterOption {
  const StatisticFilterOption({required this.id, required this.label});

  final int id;
  final String label;
}

class StatisticRequest {
  const StatisticRequest({
    required this.projectUuid,
    required this.measure,
    required this.group,
    this.rank,
    this.breakdown,
    this.siteId,
    this.speciesId,
    this.limit,
  });

  final String projectUuid;
  final StatisticMeasure measure;
  final StatisticGroup group;

  /// Rank to group by when [group] is [StatisticGroup.taxonRank].
  final StatisticTaxonRank? rank;
  final StatisticBreakdown? breakdown;
  final int? siteId;
  final int? speciesId;
  final int? limit;

  /// Rank the request groups by, falling back to the picker default.
  StatisticTaxonRank get resolvedRank =>
      rank ?? StatisticTaxonRank.defaultGroupable;

  /// Label for the grouped dimension.
  ///
  /// Taxon rank groupings read as the rank itself, so a chart title, a table
  /// header, and an export file name all say `Family` rather than `Taxon rank`.
  String get categoryLabel =>
      group == StatisticGroup.taxonRank ? resolvedRank.label : group.label;

  String get _categorySlug => group == StatisticGroup.taxonRank
      ? resolvedRank.fileSlug
      : group.fileSlug;

  String title({String? siteLabel, String? speciesLabel}) {
    if (measure == StatisticMeasure.partQuantity) {
      final suffix = speciesLabel == null ? '' : ' for $speciesLabel';
      return 'Part quantity by ${categoryLabel.toLowerCase()}$suffix';
    }
    final breakdownSuffix = breakdown == null
        ? ''
        : ' and ${breakdown!.label.toLowerCase()}';
    final siteSuffix = siteLabel == null ? '' : ' at $siteLabel';
    return '${measure.label} by ${categoryLabel.toLowerCase()}'
        '$breakdownSuffix$siteSuffix';
  }

  String get fileSlug {
    final breakdownSlug = breakdown == null
        ? ''
        : '-by-${breakdown!.name.replaceAll('lifeStage', 'life-stage')}';
    return '${measure.fileSlug}-by-$_categorySlug$breakdownSlug';
  }

  String? get seriesLabel => breakdown?.label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticRequest &&
          other.projectUuid == projectUuid &&
          other.measure == measure &&
          other.group == group &&
          other.rank == rank &&
          other.breakdown == breakdown &&
          other.siteId == siteId &&
          other.speciesId == speciesId &&
          other.limit == limit;

  @override
  int get hashCode => Object.hash(
    projectUuid,
    measure,
    group,
    rank,
    breakdown,
    siteId,
    speciesId,
    limit,
  );
}

class StatisticAvailability {
  const StatisticAvailability({
    required this.hasSex,
    required this.hasLifeStage,
  });

  final bool hasSex;
  final bool hasLifeStage;
}

class RecordStatisticTotals {
  const RecordStatisticTotals({
    required this.recordedSiteCount,
    required this.sampledSiteCount,
    required this.eventCount,
    required this.specimenCount,
    required this.classCount,
    required this.orderCount,
    required this.familyCount,
    required this.genusCount,
    required this.speciesCount,
    required this.narrativeCount,
    this.minimumRecordedElevationInMeter,
    this.maximumRecordedElevationInMeter,
    this.minimumSampledElevationInMeter,
    this.maximumSampledElevationInMeter,
    this.totalDays,
    this.totalCaptureDays = 0,
  });

  /// Sites recorded in the project.
  final int recordedSiteCount;

  /// Sites that yielded specimen records.
  final int sampledSiteCount;

  final int eventCount;
  final int specimenCount;

  /// Distinct taxa at each rank across the specimens recorded in the project.
  final int classCount;
  final int orderCount;
  final int familyCount;
  final int genusCount;
  final int speciesCount;

  final int narrativeCount;

  /// Elevation range across every site recorded in the project.
  final double? minimumRecordedElevationInMeter;
  final double? maximumRecordedElevationInMeter;

  /// Elevation range limited to sites that yielded specimen records.
  final double? minimumSampledElevationInMeter;
  final double? maximumSampledElevationInMeter;
  final int? totalDays;
  final int totalCaptureDays;
}

class StatisticTableRow {
  const StatisticTableRow({
    required this.rank,
    required this.category,
    required this.count,
    required this.percent,
    this.series,
  });

  final int rank;
  final String category;
  final String? series;
  final int count;
  final double percent;
}

List<StatisticTableRow> buildStatisticTableRows(List<StatisticDatum> data) {
  final total = data.fold<int>(0, (sum, datum) => sum + datum.count);
  final rows = <StatisticTableRow>[];
  var rank = 0;
  String? previousCategory;
  for (final datum in data) {
    if (datum.label != previousCategory) {
      rank += 1;
      previousCategory = datum.label;
    }
    rows.add(
      StatisticTableRow(
        rank: rank,
        category: datum.label,
        series: datum.seriesLabel,
        count: datum.count,
        percent: total == 0 ? 0 : datum.count * 100 / total,
      ),
    );
  }
  return rows;
}
