import 'package:nahpu/services/types/analytics.dart';

/// A table of text cells ready for the tabular exporter.
typedef PcaExportTable = ({List<String> headers, List<List<String>> rows});

/// Builds the export tables of a principal component analysis.
///
/// Headers are English and unit-qualified, like the other statistics exports,
/// so a file reads the same whatever the UI language.
class PcaExportBuilder {
  const PcaExportBuilder(this.result);

  final PcaAnalysisResult result;

  static const _decimals = 6;

  /// One row per analyzed record: its identity, measurements, and scores.
  PcaExportTable scores() => (
    headers: [
      'Specimen UUID',
      'Field number',
      'Project',
      'Species',
      'Genus',
      'Family',
      'Sex',
      'Life stage',
      'Site',
      ...result.variables.map(_variableHeader),
      ..._componentHeaders,
    ],
    rows: [
      for (final (index, record) in result.records.indexed)
        [
          record.specimenUuid,
          record.fieldNumber?.toString() ?? '',
          record.project,
          record.species,
          record.genus,
          record.family,
          record.sex,
          record.lifeStage,
          record.site,
          for (final value in record.values) value?.toString() ?? '',
          ...result.scores[index].map(_number),
        ],
    ],
  );

  /// One row per variable with its loading on every component, followed by
  /// the variance each component explains.
  PcaExportTable loadings() => (
    headers: ['Variable', ..._componentHeaders],
    rows: [
      for (final (index, variable) in result.variables.indexed)
        [_variableHeader(variable), ...result.loadings[index].map(_number)],
      ['Eigenvalue', ...result.eigenvalues.map(_number)],
      [
        'Variance explained (%)',
        ...result.explainedVariance.map((share) => _number(share * 100)),
      ],
      [
        'Cumulative variance (%)',
        ...result.cumulativeVariance.map((share) => _number(share * 100)),
      ],
    ],
  );

  /// One row per variable with its descriptive statistics.
  PcaExportTable summary() => (
    headers: const [
      'Variable',
      'N',
      'Missing',
      'Mean',
      'SD',
      'Min',
      'Max',
      'Median',
    ],
    rows: [
      for (final (index, variable) in result.variables.indexed)
        [
          _variableHeader(variable),
          result.summaries[index].count.toString(),
          result.summaries[index].missing.toString(),
          _optional(result.summaries[index].mean),
          _optional(result.summaries[index].standardDeviation),
          _optional(result.summaries[index].min),
          _optional(result.summaries[index].max),
          _optional(result.summaries[index].median),
        ],
    ],
  );

  List<String> get _componentHeaders => [
    for (var index = 0; index < result.componentCount; index++)
      'PC${index + 1}',
  ];

  static String _variableHeader(AnalyticsVariable variable) {
    final column = variable.column;
    if (column == null) return variable.customFieldName ?? variable.id;
    return '${column.name} (${column.unit})';
  }

  static String _number(double value) => value.toStringAsFixed(_decimals);

  static String _optional(double? value) => value == null ? '' : _number(value);
}
