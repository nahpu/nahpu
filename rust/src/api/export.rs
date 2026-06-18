//! Module for exporting database records
use nahpu_db::io::export::{export_csv, export_excel, export_tsv};
use polars::prelude::*;
use std::io::Cursor;
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
        let mut df = JsonReader::new(Cursor::new(self.json_content.as_bytes()))
            .finish()
            .map_err(|e| format!("Failed to parse JSON: {}", e))?;

        // Reorder columns based on column_names if needed, but assuming json already has them.
        let path = Path::new(&self.output_path);

        match self.export_format.as_str() {
            "csv" => export_csv(&mut df, path).map_err(|e| format!("Failed to export CSV: {}", e)),
            "tsv" => export_tsv(&mut df, path).map_err(|e| format!("Failed to export TSV: {}", e)),
            "excel" => {
                export_excel(&mut df, path).map_err(|e| format!("Failed to export Excel: {}", e))
            }
            _ => Err(format!("Unsupported export format: {}", self.export_format)),
        }
    }
}
