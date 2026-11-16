import 'package:nahpu/services/database/analytics_queries.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/src/rust/api/analytics.dart';

/// Runs principal component analyses on specimen measurements.
///
/// The database rows are read here and the numerics run in Rust.
class PcaService {
  const PcaService(this._query);

  final AnalyticsQuery _query;

  /// Analyzes the records matching [request].
  ///
  /// Throws a [PcaFailure] when the data cannot be analyzed.
  Future<PcaAnalysisResult> run(PcaRequest request) async {
    if (request.variables.length < pcaMinVariables) {
      throw PcaFailure(
        PcaFailureKind.tooFewVariables,
        minimum: pcaMinVariables,
      );
    }
    final records = await _query.fetchRecords(request);
    final PcaResultFfi result;
    try {
      result = await PcaAnalysis(
        rows: [for (final record in records) record.values],
        scaling: switch (request.scaling) {
          PcaScalingMode.correlation => PcaScalingFfi.correlation,
          PcaScalingMode.covariance => PcaScalingFfi.covariance,
        },
        logTransform: request.logTransform,
      ).run();
    } on PcaErrorFfi catch (error) {
      throw _failure(error, request);
    }
    return PcaAnalysisResult(
      variables: request.variables,
      records: [for (final index in result.keptRows) records[index]],
      excludedCount: result.excludedRows,
      summaries: [
        for (final summary in result.columnSummaries)
          AnalyticsColumnSummary(
            count: summary.n,
            missing: summary.missing,
            mean: summary.mean,
            standardDeviation: summary.sd,
            min: summary.min,
            max: summary.max,
            median: summary.median,
          ),
      ],
      eigenvalues: result.eigenvalues,
      explainedVariance: result.explainedVariance,
      cumulativeVariance: result.cumulativeVariance,
      loadings: result.loadings,
      scores: result.scores,
      correlations: result.correlations,
    );
  }

  static PcaFailure _failure(PcaErrorFfi error, PcaRequest request) {
    final detail = error.detail;
    return switch (error.kind) {
      PcaErrorKindFfi.tooFewRows => PcaFailure(
        PcaFailureKind.tooFewRecords,
        completeCount: detail,
        minimum: error.minimum,
        message: error.message,
      ),
      PcaErrorKindFfi.tooFewVariables => PcaFailure(
        PcaFailureKind.tooFewVariables,
        minimum: error.minimum,
        message: error.message,
      ),
      PcaErrorKindFfi.constantVariable => PcaFailure(
        PcaFailureKind.constantVariable,
        variable: detail != null && detail < request.variables.length
            ? request.variables[detail]
            : null,
        message: error.message,
      ),
      PcaErrorKindFfi.other => PcaFailure(
        PcaFailureKind.other,
        message: error.message,
      ),
    };
  }
}
