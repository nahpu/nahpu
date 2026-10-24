import 'package:drift/drift.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
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

  /// Condition limiting [column] to [projectUuid], or an always-true condition
  /// when [projectUuid] is null, which covers every project in the database.
  ///
  /// The condition carries one `?` placeholder for the project UUID, or none.
  static String _projectFilter(String column, String? projectUuid) =>
      projectUuid == null ? '1' : '$column = ?';

  /// Condition keeping a specimen on a site of its own project, which a
  /// single-project filter on both tables already implies.
  static String _sameProjectSite(String? projectUuid) =>
      projectUuid == null ? 'AND specimen.projectUuid = site.projectUuid' : '';

  /// [projectUuid] as the variables a [_projectFilter] condition binds.
  static List<Variable> _projectVariables(String? projectUuid) =>
      projectUuid == null ? [] : [Variable(projectUuid)];

  /// Label expression for a taxon rank, falling back to a `No <rank>` bucket.
  static String _taxonRankLabel(StatisticTaxonRank rank) {
    if (rank == StatisticTaxonRank.species) return _speciesLabel;
    final column = 'taxonomy.${rank.column}';
    return '''
    CASE
      WHEN trim(coalesce($column, '')) = ''
      THEN 'No ${rank.label.toLowerCase()}'
      ELSE trim($column)
    END
  ''';
  }

  /// Scalar subquery counting the distinct taxa at [rank] across the specimens
  /// matching [projectFilter], a condition on `specimen.projectUuid` from
  /// [_projectFilter].
  static String _taxonRankCount(
    StatisticTaxonRank rank,
    String alias,
    String projectFilter,
  ) {
    final value = rank == StatisticTaxonRank.species
        ? _identifiedSpecies
        : 'lower(trim(taxonomy.${rank.column}))';
    final presence = rank == StatisticTaxonRank.species
        ? ''
        : "AND trim(coalesce(taxonomy.${rank.column}, '')) != ''";
    return '''
          (
            SELECT COUNT(DISTINCT $value)
            FROM specimen
            INNER JOIN taxonomy ON taxonomy.id = specimen.speciesID
            WHERE $projectFilter
              $presence
          ) AS $alias''';
  }

  /// Media categories that document a record, in the order they are reported.
  ///
  /// Personnel avatars are left out: they document people, not records.
  static const _recordMediaCategories = [
    'specimen',
    'site',
    'event',
    'narrative',
  ];

  /// Scalar subquery counting the media files in [categories], matched
  /// case-insensitively and ignoring surrounding spaces, limited by
  /// [projectFilter], a condition on `media.projectUuid` from [_projectFilter].
  static String _mediaCount(
    List<String> categories,
    String alias,
    String projectFilter,
  ) {
    final values = categories.map((category) => "'$category'").join(', ');
    return '''
          (
            SELECT COUNT(*)
            FROM media
            WHERE $projectFilter
              AND lower(trim(coalesce(media.category, ''))) IN ($values)
          ) AS $alias''';
  }

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
      WHEN trim(coalesce(collMethod.method, '')) = '' THEN 'No method'
      ELSE trim(collMethod.method)
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
      SELECT specimenUuid, sex, lifeStage AS life_stage FROM invertebrateAttribute
      UNION ALL
      SELECT specimenUuid, sex, lifeStage AS life_stage FROM fishAttribute
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
    String? projectUuid,
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
            WHERE ${_projectFilter('specimen.projectUuid', projectUuid)}
            ORDER BY label COLLATE NOCASE ASC
          ''',
          variables: _projectVariables(projectUuid),
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
            WHERE ${_projectFilter('specimen.projectUuid', projectUuid)}
            ORDER BY label COLLATE NOCASE ASC
          ''',
          variables: _projectVariables(projectUuid),
          readsFrom: {db.taxonomy, db.specimen},
        ).watch().map(_mapFilterOptions);
    }
  }

  Stream<StatisticAvailability> watchAvailability(String? projectUuid) {
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
        WHERE ${_projectFilter('specimen.projectUuid', projectUuid)}
      ''',
      variables: _projectVariables(projectUuid),
      readsFrom: _attributeTables,
    ).watchSingle().map(
      (row) => StatisticAvailability(
        hasSex: row.read<int>('has_sex') == 1,
        hasLifeStage: row.read<int>('has_life_stage') == 1,
      ),
    );
  }

  /// Record totals for [projectUuid], or across every project when null.
  ///
  /// Across projects, taxa are counted once however many projects record
  /// them, and project days add up each project's own date range.
  Stream<RecordStatisticTotals> watchRecordTotals(String? projectUuid) {
    String scoped(String column) => _projectFilter(column, projectUuid);
    final specimenScope = scoped('specimen.projectUuid');
    final mediaScope = scoped('media.projectUuid');
    final siteScope = scoped('site.projectUuid');
    final projectDates = projectUuid == null
        ? '''
          NULL AS project_start_date,
          NULL AS project_end_date,'''
        : '''
          (SELECT startDate FROM project WHERE uuid = ?) AS project_start_date,
          (SELECT endDate FROM project WHERE uuid = ?) AS project_end_date,''';
    final sql =
        '''
        WITH RECURSIVE recorded_sites AS (
          SELECT DISTINCT coalesce(collEvent.siteID, specimenCoordinate.siteID) AS id
          FROM specimen
          LEFT JOIN collEvent ON collEvent.id = specimen.collEventID
          LEFT JOIN coordinate specimenCoordinate
            ON specimenCoordinate.id = specimen.coordinateID
          WHERE $specimenScope
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
          WHERE $specimenScope
            AND ${scoped('collEvent.projectUuid')}
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
          (
            SELECT COUNT(*) FROM site WHERE ${scoped('projectUuid')}
          ) AS recorded_site_count,
          (SELECT COUNT(*) FROM recorded_sites) AS sampled_site_count,
          (SELECT COUNT(*) FROM collEvent WHERE ${scoped('projectUuid')}) AS event_count,
          (SELECT COUNT(*) FROM specimen WHERE ${scoped('projectUuid')}) AS specimen_count,
          (
            SELECT COUNT(*)
            FROM specimenPart
            INNER JOIN specimen ON specimen.uuid = specimenPart.specimenUuid
            WHERE $specimenScope
          ) AS specimen_part_count,
${_taxonRankCount(StatisticTaxonRank.taxonClass, 'class_count', specimenScope)},
${_taxonRankCount(StatisticTaxonRank.order, 'order_count', specimenScope)},
${_taxonRankCount(StatisticTaxonRank.family, 'family_count', specimenScope)},
${_taxonRankCount(StatisticTaxonRank.genus, 'genus_count', specimenScope)},
${_taxonRankCount(StatisticTaxonRank.species, 'species_count', specimenScope)},
          (SELECT COUNT(*) FROM narrative WHERE ${scoped('projectUuid')}) AS narrative_count,
${_mediaCount(_recordMediaCategories, 'media_count', mediaScope)},
${_mediaCount(const ['specimen'], 'specimen_media_count', mediaScope)},
${_mediaCount(const ['site'], 'site_media_count', mediaScope)},
${_mediaCount(const ['event'], 'event_media_count', mediaScope)},
${_mediaCount(const ['narrative'], 'narrative_media_count', mediaScope)},
          (
            SELECT MIN(coordinate.elevationInMeter)
            FROM coordinate
            INNER JOIN site ON site.id = coordinate.siteID
            WHERE $siteScope
              AND coordinate.elevationInMeter IS NOT NULL
          ) AS minimum_recorded_elevation,
          (
            SELECT MAX(coordinate.elevationInMeter)
            FROM coordinate
            INNER JOIN site ON site.id = coordinate.siteID
            WHERE $siteScope
              AND coordinate.elevationInMeter IS NOT NULL
          ) AS maximum_recorded_elevation,
          (
            SELECT MIN(coordinate.elevationInMeter)
            FROM coordinate
            INNER JOIN site ON site.id = coordinate.siteID
            INNER JOIN recorded_sites ON recorded_sites.id = site.id
            WHERE $siteScope
              AND coordinate.elevationInMeter IS NOT NULL
          ) AS minimum_sampled_elevation,
          (
            SELECT MAX(coordinate.elevationInMeter)
            FROM coordinate
            INNER JOIN site ON site.id = coordinate.siteID
            INNER JOIN recorded_sites ON recorded_sites.id = site.id
            WHERE $siteScope
              AND coordinate.elevationInMeter IS NOT NULL
          ) AS maximum_sampled_elevation,
$projectDates
          (SELECT COUNT(DISTINCT day) FROM capture_days) AS total_capture_days
      ''';
    // Every placeholder in this query is the project UUID, so the count is read
    // back off the statement instead of being kept in sync by hand. Keep it
    // that way: a fragment carrying a literal `?` (such as `_sexLabel`) would
    // inflate this count. Across projects there are no placeholders at all.
    final placeholderCount = '?'.allMatches(sql).length;
    return customSelect(
      sql,
      variables: projectUuid == null
          ? const []
          : List.filled(placeholderCount, Variable(projectUuid)),
      readsFrom: _recordTotalTables,
    ).watchSingle().asyncMap(
      (row) async => RecordStatisticTotals(
        recordedSiteCount: row.read<int>('recorded_site_count'),
        sampledSiteCount: row.read<int>('sampled_site_count'),
        eventCount: row.read<int>('event_count'),
        specimenCount: row.read<int>('specimen_count'),
        specimenPartCount: row.read<int>('specimen_part_count'),
        classCount: row.read<int>('class_count'),
        orderCount: row.read<int>('order_count'),
        familyCount: row.read<int>('family_count'),
        genusCount: row.read<int>('genus_count'),
        speciesCount: row.read<int>('species_count'),
        narrativeCount: row.read<int>('narrative_count'),
        mediaCount: row.read<int>('media_count'),
        specimenMediaCount: row.read<int>('specimen_media_count'),
        siteMediaCount: row.read<int>('site_media_count'),
        eventMediaCount: row.read<int>('event_media_count'),
        narrativeMediaCount: row.read<int>('narrative_media_count'),
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
        totalDays: projectUuid == null
            ? await _summedProjectDays()
            : _inclusiveDayCount(
                row.readNullable<String>('project_start_date'),
                row.readNullable<String>('project_end_date'),
              ),
        totalCaptureDays: row.read<int>('total_capture_days'),
      ),
    );
  }

  /// Record totals for each project, ordered by project name.
  Stream<List<ProjectRecordTotals>> watchProjectRecordTotals() {
    return customSelect(
      'SELECT uuid, name FROM project ORDER BY name COLLATE NOCASE ASC',
      readsFrom: _recordTotalTables,
    ).watch().asyncMap(
      (rows) => Future.wait([
        for (final row in rows)
          watchRecordTotals(row.read<String>('uuid')).first.then(
            (totals) => ProjectRecordTotals(
              projectUuid: row.read<String>('uuid'),
              projectName: row.read<String>('name'),
              totals: totals,
            ),
          ),
      ]),
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
    String? projectUuid,
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
        INNER JOIN coordinate
          ON coordinate.id = $kResolvedSpecimenCoordinateIdSql
        INNER JOIN site ON site.id = coordinate.siteID
        WHERE ${_projectFilter('specimen.projectUuid', projectUuid)}
          AND ${_projectFilter('site.projectUuid', projectUuid)}
          ${_sameProjectSite(projectUuid)}
        ORDER BY label COLLATE NOCASE ASC
      ''',
      variables: [
        ..._projectVariables(projectUuid),
        ..._projectVariables(projectUuid),
      ],
      readsFrom: {
        db.taxonomy,
        db.specimen,
        db.collEvent,
        db.coordinate,
        db.site,
      },
    ).watch().map(_mapFilterOptions);
  }

  /// Sum of every project's inclusive day count, or null when no project has
  /// a usable date range.
  Future<int?> _summedProjectDays() async {
    final rows = await customSelect(
      'SELECT startDate, endDate FROM project',
      readsFrom: {db.project},
    ).get();
    final days = rows
        .map(
          (row) => _inclusiveDayCount(
            row.readNullable<String>('startDate'),
            row.readNullable<String>('endDate'),
          ),
        )
        .whereType<int>();
    return days.isEmpty ? null : days.reduce((a, b) => a + b);
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

    final (:conditions, :variables) = _specimenConditions(request);
    final label = _specimenDimension(request);
    final series = _seriesDimension(request);
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
        FROM $_specimenFrom
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
      tables: _specimenTables,
    );
  }

  _StatisticsSql _partStatisticsSql(StatisticRequest request) {
    final (:conditions, :variables) = _partConditions(request);
    final label = _partDimension(request);
    var sql =
        '''
      SELECT $label AS label, NULL AS series_label,
        SUM($_partQuantity) AS count
      FROM $_partFrom
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

  /// Keys of the records counted in one group of [request]: specimen UUIDs,
  /// or part ids for part quantity.
  ///
  /// [label] and [seriesLabel] are the values a [StatisticDatum] reports, so a
  /// chart element can list the records behind it. For a species count, the
  /// group's specimens are returned.
  Future<List<Object>> groupRecordKeys(
    StatisticRequest request, {
    required String label,
    String? seriesLabel,
  }) async {
    final String sql;
    final List<Variable> variables;
    if (request.measure == StatisticMeasure.partQuantity) {
      final where = _partConditions(request);
      variables = [...where.variables, Variable(label)];
      sql =
          '''
        SELECT specimenPart.id AS k
        FROM $_partFrom
        WHERE ${where.conditions.join(' AND ')}
          AND ${_partDimension(request)} = ?
        ORDER BY specimenPart.id
      ''';
    } else {
      final where = _specimenConditions(request);
      final conditions = [
        ...where.conditions,
        '${_specimenDimension(request)} = ?',
      ];
      variables = [...where.variables, Variable(label)];
      final series = _seriesDimension(request);
      if (series != null && seriesLabel != null) {
        conditions.add('$series = ?');
        variables.add(Variable(seriesLabel));
      }
      sql =
          '''
        WITH $_attributeCte
        SELECT specimen.uuid AS k
        FROM $_specimenFrom
        WHERE ${conditions.join(' AND ')}
        ORDER BY specimen.rowid
      ''';
    }
    final rows = await customSelect(
      sql,
      variables: variables,
      readsFrom: request.measure == StatisticMeasure.partQuantity
          ? {db.specimen, db.specimenPart}
          : _specimenTables,
    ).get();
    return [for (final row in rows) row.data['k']!];
  }

  /// Specimens with everything the specimen groupings read.
  static const _specimenFrom = '''
        specimen
        LEFT JOIN taxonomy ON taxonomy.id = specimen.speciesID
        LEFT JOIN collEvent ON collEvent.id = specimen.collEventID
        LEFT JOIN coordinate specimenCoordinate
          ON specimenCoordinate.id = specimen.coordinateID
        LEFT JOIN site
          ON site.id = coalesce(collEvent.siteID, specimenCoordinate.siteID)
        LEFT JOIN collMethod ON collMethod.id = specimen.collMethodID
        LEFT JOIN normalized_attributes
          ON normalized_attributes.specimenUuid = specimen.uuid
  ''';

  static const _partFrom = '''
        specimenPart
        INNER JOIN specimen ON specimen.uuid = specimenPart.specimenUuid
  ''';

  Set<ResultSetImplementation> get _recordTotalTables => {
    db.project,
    db.site,
    db.coordinate,
    db.collEvent,
    db.specimen,
    db.specimenPart,
    db.taxonomy,
    db.narrative,
    db.media,
  };

  Set<ResultSetImplementation> get _specimenTables => {
    db.specimen,
    db.taxonomy,
    db.collEvent,
    db.coordinate,
    db.site,
    db.collMethod,
    ..._attributeTables,
  };

  ({List<String> conditions, List<Variable> variables}) _specimenConditions(
    StatisticRequest request,
  ) {
    final variables = _projectVariables(request.projectUuid);
    final conditions = <String>[
      _projectFilter('specimen.projectUuid', request.projectUuid),
    ];
    if (request.siteId != null) {
      conditions.add(
        'coalesce(collEvent.siteID, specimenCoordinate.siteID) = ?',
      );
      variables.add(Variable(request.siteId!));
    }
    return (conditions: conditions, variables: variables);
  }

  ({List<String> conditions, List<Variable> variables}) _partConditions(
    StatisticRequest request,
  ) {
    final variables = _projectVariables(request.projectUuid);
    final conditions = <String>[
      _projectFilter('specimen.projectUuid', request.projectUuid),
    ];
    if (request.speciesId != null) {
      conditions.add('specimen.speciesID = ?');
      variables.add(Variable(request.speciesId!));
    }
    return (conditions: conditions, variables: variables);
  }

  String _partDimension(StatisticRequest request) => switch (request.group) {
    StatisticGroup.partType => _partTypeLabel,
    StatisticGroup.partTreatment => _treatmentLabel,
    _ => throw ArgumentError('Unsupported part grouping: ${request.group}'),
  };

  String? _seriesDimension(StatisticRequest request) =>
      switch (request.breakdown) {
        StatisticBreakdown.sex => _sexLabel,
        StatisticBreakdown.lifeStage => _lifeStageLabel,
        null => null,
      };

  String _specimenDimension(StatisticRequest request) =>
      switch (request.group) {
        StatisticGroup.species => _speciesLabel,
        StatisticGroup.taxonRank => _taxonRankLabel(request.resolvedRank),
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
      geography.stateProvince AS state_province,
      geography.county AS county,
      geography.municipality AS municipality,
      geography.locality AS locality
    ''';
    final variables = _projectVariables(request.projectUuid);
    late String sql;
    late final Set<ResultSetImplementation> tables;

    switch (request.kind) {
      case SpatialStatisticKind.specimens:
        sql = _spatialCountSql(
          'COUNT(specimen.uuid)',
          coordinateColumns,
          request.projectUuid,
        );
        tables = {
          db.coordinate,
          db.site,
          db.geography,
          db.specimen,
          db.collEvent,
        };
      case SpatialStatisticKind.species:
        sql = _spatialCountSql(
          'COUNT(DISTINCT $_speciesLabel)',
          coordinateColumns,
          request.projectUuid,
          taxonomy: true,
        );
        tables = {
          db.coordinate,
          db.site,
          db.geography,
          db.specimen,
          db.collEvent,
          db.taxonomy,
        };
      case SpatialStatisticKind.family:
        sql = _spatialCountSql(
          'COUNT(DISTINCT ${_taxonRankLabel(StatisticTaxonRank.family)})',
          coordinateColumns,
          request.projectUuid,
          taxonomy: true,
        );
        tables = {
          db.coordinate,
          db.site,
          db.geography,
          db.specimen,
          db.collEvent,
          db.taxonomy,
        };
      case SpatialStatisticKind.coordinatesBySpecies:
        variables.add(Variable(request.speciesId!));
        sql = _spatialCountSql(
          'COUNT(specimen.uuid)',
          coordinateColumns,
          request.projectUuid,
          specimenCondition: 'AND specimen.speciesID = ?',
        );
        tables = {
          db.coordinate,
          db.site,
          db.geography,
          db.specimen,
          db.collEvent,
        };
    }

    variables.addAll(_projectVariables(request.projectUuid));
    return _StatisticsSql(sql: sql, variables: variables, tables: tables);
  }

  String _spatialCountSql(
    String countExpression,
    String coordinateColumns,
    String? projectUuid, {
    bool taxonomy = false,
    String specimenCondition = '',
  }) =>
      '''
        SELECT $coordinateColumns, $countExpression AS count
        FROM coordinate
        INNER JOIN site ON site.id = coordinate.siteID
        LEFT JOIN geography ON geography.id = site.geographyId
        INNER JOIN specimen
          ON $kResolvedSpecimenCoordinateIdSql = coordinate.id
          AND ${_projectFilter('specimen.projectUuid', projectUuid)}
          $specimenCondition
        ${taxonomy ? 'LEFT JOIN taxonomy ON taxonomy.id = specimen.speciesID' : ''}
        WHERE ${_projectFilter('site.projectUuid', projectUuid)}
          ${_sameProjectSite(projectUuid)}
        GROUP BY coordinate.id
        HAVING count > 0
        ORDER BY count DESC, name COLLATE NOCASE ASC, coordinate.id ASC
      ''';

  Set<ResultSetImplementation> get _attributeTables => {
    db.specimen,
    db.mammalAttribute,
    db.birdAttribute,
    db.herpAttribute,
    db.invertebrateAttribute,
    db.fishAttribute,
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
