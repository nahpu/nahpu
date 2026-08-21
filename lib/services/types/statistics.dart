enum StatisticMeasure { specimens, species, partQuantity }

enum StatisticGroup {
  species,
  family,
  site,
  date,
  method,
  sex,
  lifeStage,
  partType,
  partTreatment,
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
      StatisticGroup.family,
      StatisticGroup.site,
      StatisticGroup.date,
      StatisticGroup.method,
      StatisticGroup.sex,
      if (hasLifeStage) StatisticGroup.lifeStage,
    ],
    StatisticMeasure.species => [
      StatisticGroup.family,
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
    StatisticGroup.family => 'Family',
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
    StatisticGroup.family => 'family',
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
    this.breakdown,
  });

  final StatisticMeasure measure;
  final StatisticGroup group;
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
    this.breakdown,
    this.siteId,
    this.speciesId,
    this.limit,
  });

  final String projectUuid;
  final StatisticMeasure measure;
  final StatisticGroup group;
  final StatisticBreakdown? breakdown;
  final int? siteId;
  final int? speciesId;
  final int? limit;

  String title({String? siteLabel, String? speciesLabel}) {
    if (measure == StatisticMeasure.partQuantity) {
      final suffix = speciesLabel == null ? '' : ' for $speciesLabel';
      return 'Part quantity by ${group.label.toLowerCase()}$suffix';
    }
    final breakdownSuffix = breakdown == null
        ? ''
        : ' and ${breakdown!.label.toLowerCase()}';
    final siteSuffix = siteLabel == null ? '' : ' at $siteLabel';
    return '${measure.label} by ${group.label.toLowerCase()}'
        '$breakdownSuffix$siteSuffix';
  }

  String get fileSlug {
    final breakdownSlug = breakdown == null
        ? ''
        : '-by-${breakdown!.name.replaceAll('lifeStage', 'life-stage')}';
    return '${measure.fileSlug}-by-${group.fileSlug}$breakdownSlug';
  }

  String? get seriesLabel => breakdown?.label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticRequest &&
          other.projectUuid == projectUuid &&
          other.measure == measure &&
          other.group == group &&
          other.breakdown == breakdown &&
          other.siteId == siteId &&
          other.speciesId == speciesId &&
          other.limit == limit;

  @override
  int get hashCode => Object.hash(
    projectUuid,
    measure,
    group,
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
    required this.siteCount,
    required this.eventCount,
    required this.specimenCount,
    required this.speciesCount,
    required this.familyCount,
    required this.narrativeCount,
    this.minimumElevationInMeter,
    this.maximumElevationInMeter,
    this.totalDays,
    this.totalCaptureDays = 0,
  });

  final int siteCount;
  final int eventCount;
  final int specimenCount;
  final int speciesCount;
  final int familyCount;
  final int narrativeCount;
  final double? minimumElevationInMeter;
  final double? maximumElevationInMeter;
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
