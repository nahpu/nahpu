import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/statistics.dart';

class StatisticsQuery extends DatabaseAccessor<Database> {
  StatisticsQuery(super.db);

  static const _speciesLabel = '''
    CASE
      WHEN taxonomy.id IS NULL
        OR trim(coalesce(taxonomy.genus, '')) = ''
        OR trim(coalesce(taxonomy.specificEpithet, '')) = ''
      THEN 'Unidentified species'
      ELSE trim(taxonomy.genus) || ' ' || trim(taxonomy.specificEpithet)
    END
  ''';

  static const _familyLabel = '''
    CASE
      WHEN trim(coalesce(taxonomy.taxonFamily, '')) = '' THEN 'No family'
      ELSE trim(taxonomy.taxonFamily)
    END
  ''';

  static const _partTypeLabel = '''
    CASE
      WHEN trim(coalesce(specimenPart.type, '')) = '' THEN 'No part type'
      ELSE trim(specimenPart.type)
    END
  ''';

  static const _treatmentLabel = '''
    CASE
      WHEN trim(coalesce(specimenPart.treatment, '')) = ''
        OR lower(trim(specimenPart.treatment)) = 'none'
      THEN 'No treatment'
      ELSE trim(specimenPart.treatment)
    END
  ''';

  static const _partQuantity = '''
    CASE
      WHEN trim(coalesce(specimenPart.count, '')) != ''
        AND trim(specimenPart.count) NOT GLOB '*[^0-9]*'
      THEN CAST(trim(specimenPart.count) AS INTEGER)
      ELSE 1
    END
  ''';

  Stream<List<StatisticDatum>> watchStatistics(StatisticRequest request) {
    if (!request.isReady) return Stream.value(const []);

    final query = _statisticsSql(request);
    return customSelect(
      query.sql,
      variables: query.variables,
      readsFrom: query.tables,
    ).watch().map(
          (rows) => rows
              .map(
                (row) => StatisticDatum(
                  label: row.read<String>('label'),
                  count: row.read<int>('count'),
                ),
              )
              .toList(growable: false),
        );
  }

  Stream<List<StatisticFilterOption>> watchFilterOptions(
    String projectUuid,
    StatisticKind kind,
  ) {
    if (kind.needsSite) {
      return customSelect(
        '''
          SELECT DISTINCT
            site.id AS id,
            CASE
              WHEN trim(coalesce(site.siteID, '')) = ''
              THEN 'Unnamed site (' || site.id || ')'
              ELSE trim(site.siteID)
            END AS label
          FROM site
          INNER JOIN collEvent ON collEvent.siteID = site.id
          WHERE collEvent.projectUuid = ?
          ORDER BY label COLLATE NOCASE ASC
        ''',
        variables: [Variable(projectUuid)],
        readsFrom: {db.site, db.collEvent},
      ).watch().map(_mapFilterOptions);
    }

    if (kind.needsTaxon) {
      return customSelect(
        '''
          SELECT DISTINCT
            taxonomy.id AS id,
            CASE
              WHEN trim(coalesce(taxonomy.genus, '')) = ''
                OR trim(coalesce(taxonomy.specificEpithet, '')) = ''
              THEN 'Unidentified taxon (' || taxonomy.id || ')'
              ELSE trim(taxonomy.genus) || ' ' || trim(taxonomy.specificEpithet)
            END AS label
          FROM taxonomy
          INNER JOIN specimen ON specimen.speciesID = taxonomy.id
          WHERE specimen.projectUuid = ?
          ORDER BY label COLLATE NOCASE ASC
        ''',
        variables: [Variable(projectUuid)],
        readsFrom: {db.taxonomy, db.specimen},
      ).watch().map(_mapFilterOptions);
    }

    return Stream.value(const []);
  }

  Stream<RecordStatisticTotals> watchRecordTotals(String projectUuid) {
    return customSelect(
      '''
        SELECT
          COUNT(*) AS specimen_count,
          COUNT(DISTINCT $_speciesLabel) AS species_count,
          COUNT(DISTINCT $_familyLabel) AS family_count
        FROM specimen
        LEFT JOIN taxonomy ON taxonomy.id = specimen.speciesID
        WHERE specimen.projectUuid = ?
      ''',
      variables: [Variable(projectUuid)],
      readsFrom: {db.specimen, db.taxonomy},
    ).watchSingle().map(
          (row) => RecordStatisticTotals(
            specimenCount: row.read<int>('specimen_count'),
            speciesCount: row.read<int>('species_count'),
            familyCount: row.read<int>('family_count'),
          ),
        );
  }

  List<StatisticFilterOption> _mapFilterOptions(List<QueryRow> rows) => rows
      .map(
        (row) => StatisticFilterOption(
          id: row.read<int>('id'),
          label: row.read<String>('label'),
        ),
      )
      .toList(growable: false);

  _StatisticsSql _statisticsSql(StatisticRequest request) {
    final variables = <Variable>[Variable(request.projectUuid)];
    late String sql;
    late final Set<ResultSetImplementation> tables;

    switch (request.kind) {
      case StatisticKind.species:
        sql = _groupedSpecimenSql(_speciesLabel);
        tables = {db.specimen, db.taxonomy};
      case StatisticKind.families:
        sql = _groupedSpecimenSql(_familyLabel);
        tables = {db.specimen, db.taxonomy};
      case StatisticKind.speciesBySite:
        variables.add(Variable(request.filterId!));
        sql = '''
          SELECT $_speciesLabel AS label, COUNT(*) AS count
          FROM specimen
          INNER JOIN collEvent ON collEvent.id = specimen.collEventID
          LEFT JOIN taxonomy ON taxonomy.id = specimen.speciesID
          WHERE specimen.projectUuid = ? AND collEvent.siteID = ?
          GROUP BY label
        ''';
        tables = {db.specimen, db.collEvent, db.taxonomy};
      case StatisticKind.partTypes:
        sql = _groupedPartSql(_partTypeLabel);
        tables = {db.specimen, db.specimenPart};
      case StatisticKind.partTypesBySpecies:
        variables.add(Variable(request.filterId!));
        sql = '''
          SELECT $_partTypeLabel AS label, SUM($_partQuantity) AS count
          FROM specimenPart
          INNER JOIN specimen ON specimen.uuid = specimenPart.specimenUuid
          WHERE specimen.projectUuid = ? AND specimen.speciesID = ?
          GROUP BY label
        ''';
        tables = {db.specimen, db.specimenPart};
      case StatisticKind.partTreatments:
        sql = _groupedPartSql(_treatmentLabel);
        tables = {db.specimen, db.specimenPart};
    }

    sql += ' ORDER BY count DESC, label COLLATE NOCASE ASC';
    if (request.limit != null) {
      sql += ' LIMIT ?';
      variables.add(Variable(request.limit!));
    }
    return _StatisticsSql(sql: sql, variables: variables, tables: tables);
  }

  String _groupedSpecimenSql(String label) => '''
    SELECT $label AS label, COUNT(*) AS count
    FROM specimen
    LEFT JOIN taxonomy ON taxonomy.id = specimen.speciesID
    WHERE specimen.projectUuid = ?
    GROUP BY label
  ''';

  String _groupedPartSql(String label) => '''
    SELECT $label AS label, SUM($_partQuantity) AS count
    FROM specimenPart
    INNER JOIN specimen ON specimen.uuid = specimenPart.specimenUuid
    WHERE specimen.projectUuid = ?
    GROUP BY label
  ''';
}

class _StatisticsSql {
  const _StatisticsSql({
    required this.sql,
    required this.variables,
    required this.tables,
  });

  final String sql;
  final List<Variable> variables;
  final Set<ResultSetImplementation> tables;
}
