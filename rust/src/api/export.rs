use nahpu_db::io::export::RecordExporter;
use std::path::Path;

pub struct RecordWriter {
    /// JSON string containing the records to be exported.
    pub json_content: String,
    /// The path to the output file where the records will be written.
    pub output_path: String,
    /// The column names to be included in the export.
    pub column_names: Vec<String>,
    /// Export format, e.g., "csv", "tsv", "excel", "json".
    pub export_format: String,
    /// Whether to concatenate multi-entry records or expand them.
    pub concatenate_multi_entries: bool,
}

/// Writes positional tabular rows. This is used for Darwin Core generated
/// headers, which may intentionally contain duplicate MeasurementOrFact terms.
pub fn write_tabular_records(
    headers: Vec<String>,
    rows: Vec<Vec<String>>,
    output_path: String,
    export_format: String,
) -> Result<(), String> {
    if export_format == "json" {
        return Err("Darwin Core generated headers support CSV, TSV, and Excel only".to_string());
    }
    let exporter = nahpu_db::io::export::TabularRecordExporter::new(headers, rows)?;
    let path = Path::new(&output_path);
    match export_format.as_str() {
        "csv" => exporter.export_csv(path),
        "tsv" => exporter.export_tsv(path),
        "excel" => exporter.export_excel(path),
        _ => Err(format!(
            "Unsupported tabular export format: {}",
            export_format
        )),
    }
}

impl RecordWriter {
    pub fn new(
        json_content: String,
        output_path: String,
        column_names: Vec<String>,
        export_format: String,
        concatenate_multi_entries: bool,
    ) -> Self {
        Self {
            json_content,
            output_path,
            column_names,
            export_format,
            concatenate_multi_entries,
        }
    }

    pub fn write(&self) -> Result<(), String> {
        let data: Vec<serde_json::Value> = serde_json::from_str(&self.json_content)
            .map_err(|e| format!("Failed to parse JSON: {}", e))?;

        let exporter =
            RecordExporter::new(&data, &self.column_names, self.concatenate_multi_entries);
        let path = Path::new(&self.output_path);

        match self.export_format.as_str() {
            "csv" => exporter
                .export_csv(path)
                .map_err(|e| format!("Failed to export CSV: {}", e)),
            "tsv" => exporter
                .export_tsv(path)
                .map_err(|e| format!("Failed to export TSV: {}", e)),
            "excel" => exporter
                .export_excel(path)
                .map_err(|e| format!("Failed to export Excel: {}", e)),
            "json" => exporter
                .export_json(path)
                .map_err(|e| format!("Failed to export JSON: {}", e)),
            _ => Err(format!("Unsupported export format: {}", self.export_format)),
        }
    }
}
