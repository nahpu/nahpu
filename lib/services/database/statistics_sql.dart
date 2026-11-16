import 'package:drift/drift.dart';

/// SQL fragments shared by the statistics, network, and analytics queries.
abstract final class StatisticsSql {
  /// Species name of the joined `taxonomy` row, or an unidentified bucket.
  static const speciesLabel = '''
    CASE
      WHEN taxonomy.id IS NULL
        OR trim(coalesce(taxonomy.genus, '')) = ''
        OR trim(coalesce(taxonomy.specificEpithet, '')) = ''
      THEN 'Unidentified species'
      ELSE trim(taxonomy.genus) || ' ' || trim(taxonomy.specificEpithet)
    END
  ''';

  /// Site ID of the joined `site` row, or a bucket for a missing one.
  static const siteLabel = '''
    CASE
      WHEN site.id IS NULL THEN 'No site'
      WHEN trim(coalesce(site.siteID, '')) = ''
      THEN 'Unnamed site (' || site.id || ')'
      ELSE trim(site.siteID)
    END
  ''';

  /// Specimens with everything the specimen groupings read.
  static const specimenFrom = '''
        specimen
        LEFT JOIN taxonomy ON taxonomy.id = specimen.speciesID
        LEFT JOIN collEvent ON collEvent.id = specimen.collEventID
        LEFT JOIN coordinate specimenCoordinate
          ON specimenCoordinate.id = specimen.coordinateID
        LEFT JOIN site
          ON site.id = coalesce(collEvent.siteID, specimenCoordinate.siteID)
        LEFT JOIN collMethod ON collMethod.id = specimen.collMethodID
  ''';

  /// Condition limiting [column] to [projectUuid], or an always-true condition
  /// when [projectUuid] is null, which covers every project in the database.
  ///
  /// The condition carries one `?` placeholder for the project UUID, or none.
  static String projectFilter(String column, String? projectUuid) =>
      projectUuid == null ? '1' : '$column = ?';

  /// Condition keeping a specimen on a site of its own project, which a
  /// single-project filter on both tables already implies.
  static String sameProjectSite(String? projectUuid) =>
      projectUuid == null ? 'AND specimen.projectUuid = site.projectUuid' : '';

  /// [projectUuid] as the variables a [projectFilter] condition binds.
  static List<Variable> projectVariables(String? projectUuid) =>
      projectUuid == null ? [] : [Variable(projectUuid)];

  /// Sex label of the sex code in [column]; mirrors [sexLabel].
  static String sexLabelOf(String column) =>
      '''
    CASE $column
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

  /// Life stage label of the text in [column]; mirrors [lifeStageLabel].
  static String lifeStageLabelOf(String column) =>
      '''
    CASE
      WHEN trim(coalesce($column, '')) = '' THEN 'Not recorded'
      ELSE trim($column)
    END
  ''';

  /// Label of a `taxonomy` rank [column], with [missing] for an empty one.
  static String taxonColumnLabel(String column, String missing) =>
      '''
    CASE
      WHEN trim(coalesce(taxonomy.$column, '')) = '' THEN '$missing'
      ELSE trim(taxonomy.$column)
    END
  ''';

  /// `WITH` entries `attribute_values` and `normalized_attributes`: one row
  /// per specimen with its sex code and life stage from whichever taxon
  /// attribute table holds them.
  static const attributeCte = '''
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

  /// Sex label of `normalized_attributes.sex`.
  static const sexLabel = '''
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

  /// Life stage label of `normalized_attributes.life_stage`.
  static const lifeStageLabel = '''
    CASE
      WHEN trim(coalesce(normalized_attributes.life_stage, '')) = ''
      THEN 'Not recorded'
      ELSE trim(normalized_attributes.life_stage)
    END
  ''';
}
