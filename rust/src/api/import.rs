use nahpu_db::io::import::RecordImporter;
use std::path::Path;

pub struct RecordReader {
    pub file_path: String,
}

impl RecordReader {
    pub fn new(file_path: String) -> Self {
        Self { file_path }
    }

    pub fn get_excel_sheet_names(&self) -> Result<Vec<String>, String> {
        let path = Path::new(&self.file_path);
        let importer = RecordImporter::new(path);
        importer.get_excel_sheet_names()
    }

    pub fn import_excel_raw(&self, sheet_name: String) -> Result<Vec<Vec<String>>, String> {
        let path = Path::new(&self.file_path);
        let importer = RecordImporter::new(path);
        importer.import_excel_raw(&sheet_name)
    }

    pub fn import_delimited_raw(&self, delimiter: String) -> Result<Vec<Vec<String>>, String> {
        let path = Path::new(&self.file_path);
        let delim_str = match delimiter.as_str() {
            "\\t" => "\t",
            _ => delimiter.as_str(),
        };

        if delim_str.len() == 1 {
            let importer = RecordImporter::new(path);
            let delim_byte = delim_str.as_bytes()[0];
            importer.import_delimited_raw(delim_byte)
        } else {
            // Manual fallback for multi-character delimiters
            let content = std::fs::read_to_string(path).map_err(|e| e.to_string())?;
            let mut rows = Vec::new();
            for line in content.lines() {
                let string_row: Vec<String> =
                    line.split(delim_str).map(|s| s.to_string()).collect();
                if string_row.iter().any(|s| !s.trim().is_empty()) {
                    rows.push(string_row);
                }
            }
            if rows.is_empty() {
                return Err("Empty file".to_string());
            }
            Ok(rows)
        }
    }
}
