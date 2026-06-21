//! Module for exporting database records
use nahpu_db::io::export::RecordExporter;
use std::path::Path;

pub struct RecordWriter {
    /// JSON string containing the records to be exported.
    pub json_content: String,
    /// The path to the output file where the records will be written.
    pub output_path: String,
    /// The column names to be included in the export.
    pub column_names: Vec<String>,
    /// Export format, e.g., "csv", "tsv", "excel".
    pub export_format: String,
}

impl RecordWriter {
    pub fn new(
        json_content: String,
        output_path: String,
        column_names: Vec<String>,
        export_format: String,
    ) -> Self {
        Self {
            json_content,
            output_path,
            column_names,
            export_format,
        }
    }

    pub fn write(&self) -> Result<(), String> {
        let data: Vec<serde_json::Value> = serde_json::from_str(&self.json_content)
            .map_err(|e| format!("Failed to parse JSON: {}", e))?;

        let exporter = RecordExporter::new(&data, &self.column_names);
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
            _ => Err(format!("Unsupported export format: {}", self.export_format)),
        }
    }
}
