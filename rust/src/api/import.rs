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
}
