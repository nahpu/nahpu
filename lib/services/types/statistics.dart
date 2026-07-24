enum StatisticKind {
  species,
  families,
  speciesBySite,
  partTypes,
  partTypesBySpecies,
  partTreatments,
}

extension StatisticKindLabels on StatisticKind {
  String get label => switch (this) {
        StatisticKind.species => 'Species',
        StatisticKind.families => 'Families',
        StatisticKind.speciesBySite => 'Species by site',
        StatisticKind.partTypes => 'Part types',
        StatisticKind.partTypesBySpecies => 'Part types by species',
        StatisticKind.partTreatments => 'Part treatments',
      };

  String get title => switch (this) {
        StatisticKind.species => 'Species counts',
        StatisticKind.families => 'Family counts',
        StatisticKind.speciesBySite => 'Species counts by site',
        StatisticKind.partTypes => 'Specimen part quantities',
        StatisticKind.partTypesBySpecies => 'Part quantities by species',
        StatisticKind.partTreatments => 'Part treatment quantities',
      };

  String get fileSlug => switch (this) {
        StatisticKind.species => 'species',
        StatisticKind.families => 'families',
        StatisticKind.speciesBySite => 'species-by-site',
        StatisticKind.partTypes => 'part-types',
        StatisticKind.partTypesBySpecies => 'part-types-by-species',
        StatisticKind.partTreatments => 'part-treatments',
      };

  bool get needsSite => this == StatisticKind.speciesBySite;

  bool get needsTaxon => this == StatisticKind.partTypesBySpecies;

  bool get displaysSpeciesCategories =>
      this == StatisticKind.species || this == StatisticKind.speciesBySite;
}

const summaryStatisticKinds = [
  StatisticKind.species,
  StatisticKind.families,
  StatisticKind.partTypes,
  StatisticKind.partTreatments,
];

class StatisticDatum {
  const StatisticDatum({required this.label, required this.count});

  final String label;
  final int count;
}

class StatisticFilterOption {
  const StatisticFilterOption({required this.id, required this.label});

  final int id;
  final String label;
}

class StatisticRequest {
  const StatisticRequest({
    required this.projectUuid,
    required this.kind,
    this.filterId,
    this.limit,
  });

  final String projectUuid;
  final StatisticKind kind;
  final int? filterId;
  final int? limit;

  bool get isReady => (!kind.needsSite && !kind.needsTaxon) || filterId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticRequest &&
          other.projectUuid == projectUuid &&
          other.kind == kind &&
          other.filterId == filterId &&
          other.limit == limit;

  @override
  int get hashCode => Object.hash(projectUuid, kind, filterId, limit);
}

class RecordStatisticTotals {
  const RecordStatisticTotals({
    required this.specimenCount,
    required this.speciesCount,
    required this.familyCount,
  });

  final int specimenCount;
  final int speciesCount;
  final int familyCount;
}

class StatisticTableRow {
  const StatisticTableRow({
    required this.rank,
    required this.category,
    required this.count,
    required this.percent,
  });

  final int rank;
  final String category;
  final int count;
  final double percent;
}

List<StatisticTableRow> buildStatisticTableRows(List<StatisticDatum> data) {
  final total = data.fold<int>(0, (sum, datum) => sum + datum.count);
  return [
    for (var index = 0; index < data.length; index++)
      StatisticTableRow(
        rank: index + 1,
        category: data[index].label,
        count: data[index].count,
        percent: total == 0 ? 0 : data[index].count * 100 / total,
      ),
  ];
}
