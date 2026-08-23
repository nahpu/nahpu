import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
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

  static const _identifiedSpecies = '''
    CASE
      WHEN taxonomy.id IS NOT NULL
        AND trim(coalesce(taxonomy.genus, '')) != ''
        AND trim(coalesce(taxonomy.specificEpithet, '')) != ''
      THEN lower(trim(taxonomy.genus)) || ' ' ||
        lower(trim(taxonomy.specificEpithet))
    END
  ''';

  static const _familyLabel = '''
    CASE
      WHEN trim(coalesce(taxonomy.taxonFamily, '')) = '' THEN 'No family'
      ELSE trim(taxonomy.taxonFamily)
    END
  ''';

  static const _siteLabel = '''
    CASE
      WHEN site.id IS NULL THEN 'No site'
      WHEN trim(coalesce(site.siteID, '')) = ''
      THEN 'Unnamed site (' || site.id || ')'
      ELSE trim(site.siteID)
    END
  ''';

  static const _dateLabel = '''
    CASE
      WHEN trim(coalesce(specimen.captureDate, '')) = '' THEN 'No date'
      ELSE trim(specimen.captureDate)
    END
  ''';

  static const _methodLabel = '''
    CASE
      WHEN trim(coalesce(collEffort.method, '')) = '' THEN 'No method'
      ELSE trim(collEffort.method)
    END
  ''';

  static const _sexLabel = '''
    CASE normalized_attributes.sex
      WHEN 0 THEN 'Male'
      WHEN 1 THEN 'Female'
      WHEN 2 THEN 'Unknown'
      WHEN 3 THEN 'Gynandromorph'
      WHEN 4 THEN 'Hermaphrodite'
      WHEN 5 THEN 'Female?'
      WHEN 6 THEN 'Male?'
      ELSE 'Not recorded'
    END
  ''';

  static const _lifeStageLabel = '''
    CASE
      WHEN trim(coalesce(normalized_attributes.life_stage, '')) = ''
      THEN 'Not recorded'
      ELSE trim(normalized_attributes.life_stage)
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

  static const _attributeCte = '''
    attribute_values AS (
      SELECT specimenUuid, sex, lifeStage AS life_stage FROM mammalAttribute
      UNION ALL
      SELECT specimenUuid, sex, lifeStage AS life_stage FROM birdAttribute
      UNION ALL
      SELECT specimenUuid, sex, lifeStage AS life_stage FROM herpAttribute
      UNION ALL
      SELECT specimenUuid, sex, lifeStage AS life_stage FROM arthropodAttribute
      UNION ALL
      SELECT specimenUuid, sex, NULL AS life_stage FROM fossilAttribute
    ),
    normalized_attributes AS (
      SELECT
        specimenUuid,
        MAX(CASE WHEN sex BETWEEN 0 AND 6 THEN sex END) AS sex,
        MAX(NULLIF(trim(life_stage), '')) AS life_stage
      FROM attribute_values
      GROUP BY specimenUuid
    )
  ''';

  Stream<List<StatisticDatum>> watchStatistics(StatisticRequest request) {
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
              seriesLabel: row.readNullable<String>('series_label'),
              count: row.read<int>('count'),
            ),
          )
          .toList(growable: false),
    );
  }

  Stream<List<StatisticFilterOption>> watchFilterOptions(
    String projectUuid,
    StatisticFilterKind kind,
  ) {
    switch (kind) {
      case StatisticFilterKind.site:
        return customSelect(
          '''
            SELECT DISTINCT
              site.id AS id,
              CASE
                WHEN trim(coalesce(site.siteID, '')) = ''
                THEN 'Unnamed site (' || site.id || ')'
                ELSE trim(site.siteID)
              END AS label
            FROM specimen
            LEFT JOIN collEvent ON collEvent.id = specimen.collEventID
            LEFT JOIN coordinate specimenCoordinate
              ON specimenCoordinate.id = specimen.coordinateID
            INNER JOIN site
              ON site.id = coalesce(collEvent.siteID, specimenCoordinate.siteID)
            WHERE specimen.projectUuid = ?
            ORDER BY label COLLATE NOCASE ASC
          ''',
          variables: [Variable(projectUuid)],
          readsFrom: {db.specimen, db.collEvent, db.coordinate, db.site},
        ).watch().map(_mapFilterOptions);
      case StatisticFilterKind.species:
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
  }

  Stream<StatisticAvailability> watchAvailability(String projectUuid) {
    return customSelect(
      '''
        WITH $_attributeCte
        SELECT
          coalesce(MAX(CASE
            WHEN normalized_attributes.sex BETWEEN 0 AND 6 THEN 1 ELSE 0
          END), 0) AS has_sex,
          coalesce(MAX(CASE
            WHEN trim(coalesce(normalized_attributes.life_stage, '')) != ''
            THEN 1 ELSE 0
          END), 0) AS has_life_stage
        FROM specimen
        LEFT JOIN normalized_attributes
          ON normalized_attributes.specimenUuid = specimen.uuid
        WHERE specimen.projectUuid = ?
      ''',
      variables: [Variable(projectUuid)],
      readsFrom: _attributeTables,
    ).watchSingle().map(
      (row) => StatisticAvailability(
        hasSex: row.read<int>('has_sex') == 1,
        hasLifeStage: row.read<int>('has_life_stage') == 1,
      ),
    );
  }

  Stream<RecordStatisticTotals> watchRecordTotals(String projectUuid) {
    return customSelect(
      '''
        WITH RECURSIVE recorded_sites AS (
          SELECT DISTINCT coalesce(collEvent.siteID, specimenCoordinate.siteID) AS id
          FROM specimen
          LEFT JOIN collEvent ON collEvent.id = specimen.collEventID
          LEFT JOIN coordinate specimenCoordinate
            ON specimenCoordinate.id = specimen.coordinateID
          WHERE specimen.projectUuid = ?
            AND coalesce(collEvent.siteID, specimenCoordinate.siteID) IS NOT NULL
        ),
        event_ranges AS (
          SELECT
            date(trim(collEvent.startDate)) AS start_date,
            date(
              coalesce(
                nullif(trim(collEvent.endDate), ''),
                nullif(trim(collEvent.startDate), '')
              )
            ) AS end_date
          FROM specimen
          INNER JOIN collEvent ON collEvent.id = specimen.collEventID
          WHERE specimen.projectUuid = ?
            AND collEvent.projectUuid = ?
        ),
        capture_days(day) AS (
          SELECT start_date
          FROM event_ranges
          WHERE start_date IS NOT NULL
            AND end_date IS NOT NULL
            AND end_date >= start_date
          UNION
          SELECT date(capture_days.day, '+1 day')
          FROM capture_days
          INNER JOIN event_ranges
            ON capture_days.day >= event_ranges.start_date
            AND capture_days.day < event_ranges.end_date
        )
        SELECT
          (SELECT COUNT(*) FROM site WHERE projectUuid = ?) AS site_count,
          (SELECT COUNT(*) FROM collEvent WHERE projectUuid = ?) AS event_count,
          (SELECT COUNT(*) FROM specimen WHERE projectUuid = ?) AS specimen_count,
          (
            SELECT COUNT(DISTINCT $_identifiedSpecies)
            FROM specimen
            INNER JOIN taxonomy ON taxonomy.id = specimen.speciesID
            WHERE specimen.projectUuid = ?
          ) AS species_count,
          (
            SELECT COUNT(DISTINCT lower(trim(taxonomy.taxonFamily)))
            FROM specimen
            INNER JOIN taxonomy ON taxonomy.id = specimen.speciesID
            WHERE specimen.projectUuid = ?
              AND trim(coalesce(taxonomy.taxonFamily, '')) != ''
          ) AS family_count,
          (SELECT COUNT(*) FROM narrative WHERE projectUuid = ?) AS narrative_count,
          (
            SELECT MIN(coordinate.elevationInMeter)
            FROM coordinate
            INNER JOIN site ON site.id = coordinate.siteID
            WHERE site.projectUuid = ?
              AND coordinate.elevationInMeter IS NOT NULL
          ) AS minimum_recorded_elevation,
          (
            SELECT MAX(coordinate.elevationInMeter)
            FROM coordinate
            INNER JOIN site ON site.id = coordinate.siteID
            WHERE site.projectUuid = ?
              AND coordinate.elevationInMeter IS NOT NULL
          ) AS maximum_recorded_elevation,
          (
            SELECT MIN(coordinate.elevationInMeter)
            FROM coordinate
            INNER JOIN site ON site.id = coordinate.siteID
            INNER JOIN recorded_sites ON recorded_sites.id = site.id
            WHERE site.projectUuid = ?
              AND coordinate.elevationInMeter IS NOT NULL
          ) AS minimum_sampled_elevation,
          (
            SELECT MAX(coordinate.elevationInMeter)
            FROM coordinate
            INNER JOIN site ON site.id = coordinate.siteID
            INNER JOIN recorded_sites ON recorded_sites.id = site.id
            WHERE site.projectUuid = ?
              AND coordinate.elevationInMeter IS NOT NULL
          ) AS maximum_sampled_elevation,
          (SELECT startDate FROM project WHERE uuid = ?) AS project_start_date,
          (SELECT endDate FROM project WHERE uuid = ?) AS project_end_date,
          (SELECT COUNT(DISTINCT day) FROM capture_days) AS total_capture_days
      ''',
      variables: List.generate(15, (_) => Variable(projectUuid)),
      readsFrom: {
        db.project,
        db.site,
        db.coordinate,
        db.collEvent,
        db.specimen,
        db.taxonomy,
        db.narrative,
      },
    ).watchSingle().map(
      (row) => RecordStatisticTotals(
        siteCount: row.read<int>('site_count'),
        eventCount: row.read<int>('event_count'),
        specimenCount: row.read<int>('specimen_count'),
        speciesCount: row.read<int>('species_count'),
        familyCount: row.read<int>('family_count'),
        narrativeCount: row.read<int>('narrative_count'),
        minimumRecordedElevationInMeter: row.readNullable<double>(
          'minimum_recorded_elevation',
        ),
        maximumRecordedElevationInMeter: row.readNullable<double>(
          'maximum_recorded_elevation',
        ),
        minimumSampledElevationInMeter: row.readNullable<double>(
          'minimum_sampled_elevation',
        ),
        maximumSampledElevationInMeter: row.readNullable<double>(
          'maximum_sampled_elevation',
        ),
        totalDays: _inclusiveDayCount(
          row.readNullable<String>('project_start_date'),
          row.readNullable<String>('project_end_date'),
        ),
        totalCaptureDays: row.read<int>('total_capture_days'),
      ),
    );
  }

  Stream<List<SpatialStatisticDatum>> watchSpatialStatistics(
    SpatialStatisticRequest request,
  ) {
    if (!request.isReady) return Stream.value(const []);
    final query = _spatialStatisticsSql(request);
    return customSelect(
      query.sql,
      variables: query.variables,
      readsFrom: query.tables,
    ).watch().map(
      (rows) => rows
          .map(
            (row) => SpatialStatisticDatum(
              coordinateId: row.read<int>('coordinate_id'),
              name: row.readNullable<String>('name'),
              decimalLatitude: row.readNullable<double>('latitude'),
              decimalLongitude: row.readNullable<double>('longitude'),
              elevationInMeter: row.readNullable<double>('elevation'),
              datum: row.readNullable<String>('datum'),
              uncertaintyInMeters: row.readNullable<int>('uncertainty'),
              gpsUnit: row.readNullable<String>('gps_unit'),
              notes: row.readNullable<String>('notes'),
              locality: _spatialLocality(row),
              count: row.readNullable<int>('count'),
            ),
          )
          .toList(growable: false),
    );
  }

  Stream<List<StatisticFilterOption>> watchSpatialSpeciesOptions(
    String projectUuid,
  ) {
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
        INNER JOIN coordinate ON coordinate.id = specimen.coordinateID
        INNER JOIN site ON site.id = coordinate.siteID
        WHERE specimen.projectUuid = ? AND site.projectUuid = ?
        ORDER BY label COLLATE NOCASE ASC
      ''',
      variables: [Variable(projectUuid), Variable(projectUuid)],
      readsFrom: {db.taxonomy, db.specimen, db.coordinate, db.site},
    ).watch().map(_mapFilterOptions);
  }

  int? _inclusiveDayCount(String? start, String? end) {
    final startDate = _dateOnly(start);
    final endDate = _dateOnly(end);
    if (startDate == null || endDate == null || endDate.isBefore(startDate)) {
      return null;
    }
    return endDate.difference(startDate).inDays + 1;
  }

  DateTime? _dateOnly(String? value) {
    final parsed = DateTime.tryParse(value?.trim() ?? '');
    if (parsed == null) return null;
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }

  String? _spatialLocality(QueryRow row) {
    final components =
        [
              row.readNullable<String>('state_province'),
              row.readNullable<String>('county'),
              row.readNullable<String>('municipality'),
              row.readNullable<String>('locality'),
            ]
            .map((value) => value?.trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty);
    final locality = components.join(', ');
    return locality.isEmpty ? null : locality;
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
    if (request.measure == StatisticMeasure.partQuantity) {
      return _partStatisticsSql(request);
    }

    final variables = <Variable>[Variable(request.projectUuid)];
    final conditions = <String>['specimen.projectUuid = ?'];
    if (request.siteId != null) {
      conditions.add(
        'coalesce(collEvent.siteID, specimenCoordinate.siteID) = ?',
      );
      variables.add(Variable(request.siteId!));
    }

    final label = _specimenDimension(request.group);
    final series = switch (request.breakdown) {
      StatisticBreakdown.sex => _sexLabel,
      StatisticBreakdown.lifeStage => _lifeStageLabel,
      null => null,
    };
    final count = request.measure == StatisticMeasure.specimens
        ? 'COUNT(*)'
        : 'COUNT(DISTINCT $_identifiedSpecies)';
    final seriesColumn = series == null
        ? 'NULL AS series_label'
        : '$series AS series_label';
    final groupColumns = series == null ? 'label' : 'label, series_label';
    var sql =
        '''
      WITH $_attributeCte,
      grouped AS (
        SELECT $label AS label, $seriesColumn, $count AS count
        FROM specimen
        LEFT JOIN taxonomy ON taxonomy.id = specimen.speciesID
        LEFT JOIN collEvent ON collEvent.id = specimen.collEventID
        LEFT JOIN coordinate specimenCoordinate
          ON specimenCoordinate.id = specimen.coordinateID
        LEFT JOIN site
          ON site.id = coalesce(collEvent.siteID, specimenCoordinate.siteID)
        LEFT JOIN collEffort ON collEffort.id = specimen.collMethodID
        LEFT JOIN normalized_attributes
          ON normalized_attributes.specimenUuid = specimen.uuid
        WHERE ${conditions.join(' AND ')}
        GROUP BY $groupColumns
        HAVING $count > 0
      )
      SELECT label, series_label, count
      FROM grouped
      ORDER BY
        ${series == null ? 'count' : '(SELECT SUM(other.count) FROM grouped other WHERE other.label = grouped.label)'} DESC,
        label COLLATE NOCASE ASC,
        count DESC,
        series_label COLLATE NOCASE ASC
    ''';
    if (request.limit != null) {
      sql += ' LIMIT ?';
      variables.add(Variable(request.limit!));
    }
    return _StatisticsSql(
      sql: sql,
      variables: variables,
      tables: {
        db.specimen,
        db.taxonomy,
        db.collEvent,
        db.coordinate,
        db.site,
        db.collEffort,
        ..._attributeTables,
      },
    );
  }

  _StatisticsSql _partStatisticsSql(StatisticRequest request) {
    final variables = <Variable>[Variable(request.projectUuid)];
    final conditions = <String>['specimen.projectUuid = ?'];
    if (request.speciesId != null) {
      conditions.add('specimen.speciesID = ?');
      variables.add(Variable(request.speciesId!));
    }
    final label = switch (request.group) {
      StatisticGroup.partType => _partTypeLabel,
      StatisticGroup.partTreatment => _treatmentLabel,
      _ => throw ArgumentError('Unsupported part grouping: ${request.group}'),
    };
    var sql =
        '''
      SELECT $label AS label, NULL AS series_label,
        SUM($_partQuantity) AS count
      FROM specimenPart
      INNER JOIN specimen ON specimen.uuid = specimenPart.specimenUuid
      WHERE ${conditions.join(' AND ')}
      GROUP BY label
      ORDER BY count DESC, label COLLATE NOCASE ASC
    ''';
    if (request.limit != null) {
      sql += ' LIMIT ?';
      variables.add(Variable(request.limit!));
    }
    return _StatisticsSql(
      sql: sql,
      variables: variables,
      tables: {db.specimen, db.specimenPart},
    );
  }

  String _specimenDimension(StatisticGroup group) => switch (group) {
    StatisticGroup.species => _speciesLabel,
    StatisticGroup.family => _familyLabel,
    StatisticGroup.site => _siteLabel,
    StatisticGroup.date => _dateLabel,
    StatisticGroup.method => _methodLabel,
    StatisticGroup.sex => _sexLabel,
    StatisticGroup.lifeStage => _lifeStageLabel,
    StatisticGroup.partType || StatisticGroup.partTreatment =>
      throw ArgumentError('Part group used for specimen statistics'),
  };

  _StatisticsSql _spatialStatisticsSql(SpatialStatisticRequest request) {
    const coordinateColumns = '''
      coordinate.id AS coordinate_id,
      coordinate.nameId AS name,
      coordinate.decimalLatitude AS latitude,
      coordinate.decimalLongitude AS longitude,
      coordinate.elevationInMeter AS elevation,
      coordinate.datum AS datum,
      coordinate.uncertaintyInMeters AS uncertainty,
      coordinate.gpsUnit AS gps_unit,
      coordinate.notes AS notes,
      site.stateProvince AS state_province,
      site.county AS county,
      site.municipality AS municipality,
      site.locality AS locality
    ''';
    final variables = <Variable>[Variable(request.projectUuid)];
    late String sql;
    late final Set<ResultSetImplementation> tables;

    switch (request.kind) {
      case SpatialStatisticKind.specimens:
        sql = _spatialCountSql('COUNT(specimen.uuid)', coordinateColumns);
        tables = {db.coordinate, db.site, db.specimen};
      case SpatialStatisticKind.species:
        sql = _spatialCountSql(
          'COUNT(DISTINCT $_speciesLabel)',
          coordinateColumns,
          taxonomy: true,
        );
        tables = {db.coordinate, db.site, db.specimen, db.taxonomy};
      case SpatialStatisticKind.family:
        sql = _spatialCountSql(
          'COUNT(DISTINCT $_familyLabel)',
          coordinateColumns,
          taxonomy: true,
        );
        tables = {db.coordinate, db.site, db.specimen, db.taxonomy};
      case SpatialStatisticKind.coordinatesBySpecies:
        variables.add(Variable(request.speciesId!));
        sql = _spatialCountSql(
          'COUNT(specimen.uuid)',
          coordinateColumns,
          specimenCondition: 'AND specimen.speciesID = ?',
        );
        tables = {db.coordinate, db.site, db.specimen};
    }

    variables.add(Variable(request.projectUuid));
    return _StatisticsSql(sql: sql, variables: variables, tables: tables);
  }

  String _spatialCountSql(
    String countExpression,
    String coordinateColumns, {
    bool taxonomy = false,
    String specimenCondition = '',
  }) =>
      '''
        SELECT $coordinateColumns, $countExpression AS count
        FROM coordinate
        INNER JOIN site ON site.id = coordinate.siteID
        INNER JOIN specimen
          ON specimen.coordinateID = coordinate.id
          AND specimen.projectUuid = ?
          $specimenCondition
        ${taxonomy ? 'LEFT JOIN taxonomy ON taxonomy.id = specimen.speciesID' : ''}
        WHERE site.projectUuid = ?
        GROUP BY coordinate.id
        HAVING count > 0
        ORDER BY count DESC, name COLLATE NOCASE ASC, coordinate.id ASC
      ''';

  Set<ResultSetImplementation> get _attributeTables => {
    db.specimen,
    db.mammalAttribute,
    db.birdAttribute,
    db.herpAttribute,
    db.arthropodAttribute,
    db.fossilAttribute,
  };
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
