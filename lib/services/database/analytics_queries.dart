import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/statistics_sql.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Reads specimen measurements for the Analytics view.
///
/// Every query covers one project, or every project when the project UUID is
/// null, and one taxon group, because each group has its own measurements.
class AnalyticsQuery extends DatabaseAccessor<Database> {
  AnalyticsQuery(super.db);

  /// Taxon groups that have specimens in [projectUuid].
  Stream<List<SpecimenRecordType>> watchTaxonGroups(String? projectUuid) {
    return customSelect(
      '''
        SELECT DISTINCT specimen.taxonGroup AS taxon_group
        FROM specimen
        WHERE ${StatisticsSql.projectFilter('specimen.projectUuid', projectUuid)}
      ''',
      variables: StatisticsSql.projectVariables(projectUuid),
      readsFrom: {db.specimen},
    ).watch().map((rows) {
      final found = {
        for (final row in rows)
          matchTaxonGroupToRecordType(row.data['taxon_group'] as String? ?? ''),
      };
      return [
        for (final group in analyticsTaxonGroups)
          if (found.contains(group)) group,
      ];
    });
  }

  /// Variables [taxonGroup] offers, each with the number of records that have
  /// a usable value. Custom fields without any numeric value are left out.
  Stream<List<AnalyticsVariableOption>> watchVariableOptions(
    String? projectUuid,
    SpecimenRecordType taxonGroup,
  ) {
    final table = MeasurementTable.of(taxonGroup);
    if (table == null) return Stream.value(const []);
    final counts = [
      for (final column in table.columns)
        'COUNT(CASE WHEN measurement.${column.name} > 0 THEN 1 END) '
            'AS ${column.name}',
    ].join(',\n          ');
    return customSelect(
      '''
        WITH measurement AS (${_measurementSource(taxonGroup, table)})
        SELECT
          $counts
        FROM specimen
        INNER JOIN measurement ON measurement.specimenUuid = specimen.uuid
        WHERE ${StatisticsSql.projectFilter('specimen.projectUuid', projectUuid)}
          AND ${_taxonGroupFilter(taxonGroup)}
      ''',
      variables: StatisticsSql.projectVariables(projectUuid),
      readsFrom: {
        db.specimen,
        ..._measurementTables(taxonGroup),
        db.customFieldValue,
        db.customFieldDefinition,
      },
    ).watchSingle().asyncMap((row) async {
      return [
        for (final column in table.columns)
          AnalyticsVariableOption(
            variable: AnalyticsVariable.column(column),
            count: row.data[column.name] as int? ?? 0,
          ),
        ...await _customFieldOptions(projectUuid, taxonGroup),
      ];
    });
  }

  /// Measured animals matching [request], with one value per requested
  /// variable. Weights are converted to grams; a weight in an unknown unit,
  /// like a custom value that is not a number, reads as missing.
  Future<List<AnalyticsRecord>> fetchRecords(PcaRequest request) async {
    final table = MeasurementTable.of(request.taxonGroup);
    if (table == null) return const [];
    final values = [
      for (final (index, variable) in request.variables.indexed)
        '${_valueExpression(variable)} AS v$index',
    ];
    final conditions = [
      StatisticsSql.projectFilter('specimen.projectUuid', request.projectUuid),
      _taxonGroupFilter(request.taxonGroup),
      if (request.siteIds.isNotEmpty)
        'site.id IN (${_placeholders(request.siteIds)})',
      if (request.speciesIds.isNotEmpty)
        'taxonomy.id IN (${_placeholders(request.speciesIds)})',
    ];
    final rows = await customSelect(
      '''
        WITH measurement AS (
          ${_measurementSource(request.taxonGroup, table)}
        )
        SELECT
          specimen.uuid AS uuid,
          specimen.fieldNumber AS field_number,
          ${StatisticsSql.speciesLabel} AS species,
          ${StatisticsSql.taxonColumnLabel('genus', 'No genus')} AS genus,
          ${StatisticsSql.taxonColumnLabel('taxonFamily', 'No family')} AS family,
          ${StatisticsSql.sexLabelOf('measurement.sex')} AS sex,
          ${StatisticsSql.lifeStageLabelOf('measurement.lifeStage')} AS life_stage,
          ${StatisticsSql.siteLabel} AS site,
          coalesce(project.name, '') AS project,
          measurement.weightUnit AS weight_unit
          ${values.map((value) => ',\n          $value').join()}
        FROM ${StatisticsSql.specimenFrom}
        INNER JOIN measurement ON measurement.specimenUuid = specimen.uuid
        LEFT JOIN project ON project.uuid = specimen.projectUuid
        WHERE ${conditions.join(' AND ')}
        ORDER BY specimen.uuid, measurement.position
      ''',
      variables: [
        ...StatisticsSql.projectVariables(request.projectUuid),
        for (final id in request.siteIds) Variable.withInt(id),
        for (final id in request.speciesIds) Variable.withInt(id),
      ],
    ).get();
    return [for (final row in rows) _mapRecord(row.data, request.variables)];
  }

  Future<List<AnalyticsVariableOption>> _customFieldOptions(
    String? projectUuid,
    SpecimenRecordType taxonGroup,
  ) async {
    final rows = await customSelect('''
        SELECT definition.id AS id, definition.name AS name,
          COUNT(DISTINCT specimen.uuid) AS count
        FROM customFieldValue
        INNER JOIN customFieldDefinition definition
          ON definition.id = customFieldValue.fieldDefinitionId
        INNER JOIN specimen ON specimen.uuid = customFieldValue.specimenUuid
        WHERE definition.type = '${FieldType.number.name}'
          AND definition.isArchived = 0
          AND CAST(customFieldValue.value AS REAL) > 0
          AND ${StatisticsSql.projectFilter('specimen.projectUuid', projectUuid)}
          AND ${_taxonGroupFilter(taxonGroup)}
        GROUP BY definition.id
        ORDER BY definition.sortOrder, definition.name COLLATE NOCASE
      ''', variables: StatisticsSql.projectVariables(projectUuid)).get();
    return [
      for (final row in rows)
        AnalyticsVariableOption(
          variable: AnalyticsVariable.customField(
            id: row.data['id'] as int,
            name: row.data['name'] as String,
          ),
          count: row.data['count'] as int,
        ),
    ];
  }

  AnalyticsRecord _mapRecord(
    Map<String, dynamic> data,
    List<AnalyticsVariable> variables,
  ) {
    final weightUnit = data['weight_unit'] as String?;
    return AnalyticsRecord(
      specimenUuid: data['uuid'] as String,
      fieldNumber: data['field_number'] as int?,
      species: data['species'] as String,
      genus: data['genus'] as String,
      family: data['family'] as String,
      sex: data['sex'] as String,
      lifeStage: data['life_stage'] as String,
      site: data['site'] as String,
      project: data['project'] as String,
      values: [
        for (final (index, variable) in variables.indexed)
          _readValue(data['v$index'], variable, weightUnit),
      ],
    );
  }

  static double? _readValue(
    Object? raw,
    AnalyticsVariable variable,
    String? weightUnit,
  ) {
    final value = switch (raw) {
      final num number => number.toDouble(),
      final String text => parseMeasurement(text),
      _ => null,
    };
    if (value == null || !value.isFinite) return null;
    if (variable.column?.isWeight ?? false) {
      return convertSpecimenWeight(value, weightUnit, analyticsWeightUnit);
    }
    return value;
  }

  static String _placeholders(Set<int> ids) =>
      List.filled(ids.length, '?').join(', ');

  static String _valueExpression(AnalyticsVariable variable) {
    final column = variable.column;
    if (column != null) return 'measurement.${column.name}';
    // The ID is an integer read from the database, so it is safe to inline.
    return '''
          (
            SELECT customFieldValue.value
            FROM customFieldValue
            WHERE customFieldValue.fieldDefinitionId = ${variable.customFieldId}
              AND customFieldValue.specimenUuid = specimen.uuid
            LIMIT 1
          )''';
  }

  /// The select item of [column] in the measurement source.
  ///
  /// Head and body length needs a total length longer than the tail, like
  /// the specimen form; otherwise it reads as missing.
  static String _columnSelect(MeasurementColumn column) => switch (column) {
    MeasurementColumn.headBodyLength =>
      'CASE WHEN tailLength > 0 AND totalLength > tailLength '
          'THEN totalLength - tailLength END AS ${column.name}',
    _ => column.name,
  };

  /// One row per measured animal with its sex, life stage, and measurements.
  ///
  /// Attribute tables have no unique key on the specimen, so the first row
  /// stands for the specimen. A fish lot contributes its individuals instead
  /// of its range columns.
  static String _measurementSource(
    SpecimenRecordType taxonGroup,
    MeasurementTable table,
  ) {
    final columns = table.columns.map(_columnSelect).join(', ');
    final weightUnit = table.hasWeightUnit
        ? 'weightUnit'
        : 'NULL AS weightUnit';
    final name = table.table;
    final first =
        'rowid IN (SELECT MIN(rowid) FROM $name GROUP BY specimenUuid)';
    if (taxonGroup != SpecimenRecordType.fishes) {
      return '''
          SELECT specimenUuid, sex, lifeStage, $weightUnit, 0 AS position,
            $columns
          FROM $name
          WHERE $first
      ''';
    }
    final lot = FishSpecimenType.lot.index;
    return '''
          SELECT specimenUuid, sex, lifeStage, $weightUnit, 0 AS position,
            $columns
          FROM $name
          WHERE coalesce(specimenType, 0) != $lot AND $first
          UNION ALL
          SELECT specimenUuid, sex, lifeStage, weightUnit, id AS position,
            $columns
          FROM specimenIndividual
          WHERE specimenUuid IN (
            SELECT specimenUuid FROM $name WHERE specimenType = $lot
          )
    ''';
  }

  /// Condition on `specimen.taxonGroup` matching [matchTaxonGroupToRecordType]:
  /// mammals take every label no other group claims, including a missing one.
  static String _taxonGroupFilter(SpecimenRecordType taxonGroup) {
    String quoted(Iterable<String> labels) =>
        labels.map((label) => "'$label'").join(', ');
    if (taxonGroup == SpecimenRecordType.mammals) {
      final others = {
        for (final group in analyticsTaxonGroups)
          if (group != SpecimenRecordType.mammals) ..._storedLabels(group),
      };
      return '(specimen.taxonGroup IS NULL '
          'OR specimen.taxonGroup NOT IN (${quoted(others)}))';
    }
    return 'specimen.taxonGroup IN (${quoted(_storedLabels(taxonGroup))})';
  }

  static Set<String> _storedLabels(SpecimenRecordType taxonGroup) => {
    ...taxonGroupsForRecordType(taxonGroup),
    // The pre-v22 label, still read as invertebrates.
    if (taxonGroup == SpecimenRecordType.invertebrates) 'Arthropods',
  };

  Set<ResultSetImplementation<dynamic, dynamic>> _measurementTables(
    SpecimenRecordType taxonGroup,
  ) => switch (taxonGroup) {
    SpecimenRecordType.mammals => {db.mammalAttribute},
    SpecimenRecordType.birds => {db.birdAttribute},
    SpecimenRecordType.herpetofauna => {db.herpAttribute},
    SpecimenRecordType.invertebrates => {db.invertebrateAttribute},
    SpecimenRecordType.fishes => {db.fishAttribute, db.specimenIndividual},
    SpecimenRecordType.allTaxa => const {},
  };
}
