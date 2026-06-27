//! Module for exporting database records
use nahpu_db::io::export::RecordExporter;
use nahpu_export::DocumentExport;
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

pub fn export_coordinates(
    json_content: String,
    output_path: String,
    export_format: String,
) -> Result<(), String> {
    let data: Vec<nahpu_gis::types::CoordinateData> = serde_json::from_str(&json_content)
        .map_err(|e| format!("Failed to parse Coordinate JSON: {}", e))?;

    let path = Path::new(&output_path);

    match export_format.as_str() {
        "kml" => {
            let exporter = nahpu_gis::io::kml::KmlExporter::new(&data);
            exporter.export_kml(path)
        }
        "geojson" => {
            let exporter = nahpu_gis::io::geojson::GeoJsonExporter::new(&data);
            exporter.export_geojson(path)
        }
        "topojson" => {
            let exporter = nahpu_gis::io::topojson::TopoJsonExporter::new(&data);
            exporter.export_topojson(path)
        }
        "shp" => {
            let exporter = nahpu_gis::io::shp::ShapefileExporter::new(&data);
            exporter.export_shp(path)
        }
        _ => Err(format!("Unsupported export format: {}", export_format)),
    }
}

pub fn generate_document(
    json_content: String,
    export_format: String,
    font_bytes: Vec<Vec<u8>>,
) -> Result<Vec<u8>, String> {
    let exporter = DocumentExport::new(&json_content)
        .map_err(|e| format!("Failed to parse Document JSON: {}", e))?;

    match export_format.as_str() {
        "md" => Ok(exporter.to_markdown().into_bytes()),
        "typ" => Ok(exporter.to_typst().into_bytes()),
        "pdf" => exporter.to_pdf(font_bytes),
        _ => Err(format!("Unsupported export format: {}", export_format)),
    }
}
