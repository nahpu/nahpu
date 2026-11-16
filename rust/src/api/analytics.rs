use nahpu_ml::pca::{Pca, PcaOptions, PcaResult, PcaScaling};
use nahpu_ml::stats::ColumnSummary;
use nahpu_ml::MlError;

/// Matrix the principal components are extracted from.
#[derive(Clone, Copy)]
pub enum PcaScalingFfi {
    /// Standardize every variable.
    Correlation,
    /// Keep the original variances.
    Covariance,
}

/// Why a principal component analysis could not run.
#[derive(Clone, Copy)]
pub enum PcaErrorKindFfi {
    /// Fewer complete rows than the analysis needs.
    TooFewRows,
    /// Fewer variables than the analysis needs.
    TooFewVariables,
    /// A variable has the same value in every complete row.
    ConstantVariable,
    /// Any other failure; see the message.
    Other,
}

/// Failure of a principal component analysis.
pub struct PcaErrorFfi {
    pub kind: PcaErrorKindFfi,
    /// Complete rows found, variables given, or the constant variable's index.
    pub detail: Option<u32>,
    /// Smallest count the analysis accepts, for the count failures.
    pub minimum: Option<u32>,
    pub message: String,
}

/// Summary of the usable values in one measurement column.
pub struct ColumnSummaryFfi {
    pub n: u32,
    pub missing: u32,
    pub mean: Option<f64>,
    pub sd: Option<f64>,
    pub min: Option<f64>,
    pub max: Option<f64>,
    pub median: Option<f64>,
}

/// Outcome of a principal component analysis.
pub struct PcaResultFfi {
    /// Indexes of the input rows used in the analysis.
    pub kept_rows: Vec<u32>,
    /// Number of input rows dropped for a missing value.
    pub excluded_rows: u32,
    pub column_summaries: Vec<ColumnSummaryFfi>,
    pub eigenvalues: Vec<f64>,
    pub explained_variance: Vec<f64>,
    pub cumulative_variance: Vec<f64>,
    /// Loadings indexed `[variable][component]`.
    pub loadings: Vec<Vec<f64>>,
    /// Scores indexed `[kept row][component]`.
    pub scores: Vec<Vec<f64>>,
    /// Correlations indexed `[variable][variable]`.
    pub correlations: Vec<Vec<f64>>,
}

/// Principal component analysis of measurement rows collected by the app.
pub struct PcaAnalysis {
    /// One row per record and one value per variable; `None` marks a missing measurement.
    pub rows: Vec<Vec<Option<f64>>>,
    pub scaling: PcaScalingFfi,
    /// Take the natural logarithm of every value first.
    pub log_transform: bool,
}

impl PcaAnalysis {
    pub fn new(rows: Vec<Vec<Option<f64>>>, scaling: PcaScalingFfi, log_transform: bool) -> Self {
        Self {
            rows,
            scaling,
            log_transform,
        }
    }

    /// Runs the analysis on complete rows; zero and negative values count as missing.
    pub fn run(&self) -> Result<PcaResultFfi, PcaErrorFfi> {
        let options = PcaOptions {
            scaling: self.scaling.into(),
            log_transform: self.log_transform,
            ..PcaOptions::default()
        };
        Pca::new(options)
            .fit(&self.rows)
            .map(PcaResultFfi::from)
            .map_err(PcaErrorFfi::from)
    }
}

impl From<PcaScalingFfi> for PcaScaling {
    fn from(scaling: PcaScalingFfi) -> Self {
        match scaling {
            PcaScalingFfi::Correlation => Self::Correlation,
            PcaScalingFfi::Covariance => Self::Covariance,
        }
    }
}

impl From<MlError> for PcaErrorFfi {
    fn from(error: MlError) -> Self {
        let message = error.to_string();
        let (kind, detail, minimum) = match error {
            MlError::TooFewRows { complete, required } => (
                PcaErrorKindFfi::TooFewRows,
                Some(count(complete)),
                Some(count(required)),
            ),
            MlError::TooFewVariables { found, required } => (
                PcaErrorKindFfi::TooFewVariables,
                Some(count(found)),
                Some(count(required)),
            ),
            MlError::ConstantVariable { index } => {
                (PcaErrorKindFfi::ConstantVariable, Some(count(index)), None)
            }
            _ => (PcaErrorKindFfi::Other, None, None),
        };
        Self {
            kind,
            detail,
            minimum,
            message,
        }
    }
}

impl From<ColumnSummary> for ColumnSummaryFfi {
    fn from(summary: ColumnSummary) -> Self {
        Self {
            n: count(summary.n),
            missing: count(summary.missing),
            mean: summary.mean,
            sd: summary.sd,
            min: summary.min,
            max: summary.max,
            median: summary.median,
        }
    }
}

impl From<PcaResult> for PcaResultFfi {
    fn from(result: PcaResult) -> Self {
        Self {
            kept_rows: result.kept_rows.into_iter().map(count).collect(),
            excluded_rows: count(result.excluded_rows),
            column_summaries: result
                .column_summaries
                .into_iter()
                .map(ColumnSummaryFfi::from)
                .collect(),
            eigenvalues: result.eigenvalues,
            explained_variance: result.explained_variance,
            cumulative_variance: result.cumulative_variance,
            loadings: result.loadings,
            scores: result.scores,
            correlations: result.correlations,
        }
    }
}

/// Narrows a row count for Dart, which reads `u32` as a plain `int`.
fn count(value: usize) -> u32 {
    u32::try_from(value).unwrap_or(u32::MAX)
}
