/// SQL fragments shared by the statistics and network queries.
abstract final class StatisticsSql {
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
