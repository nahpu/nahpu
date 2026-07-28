//! Rust FRB Boilerplate to access the archive API
use nahpu_archive::{archive, gzip, tar_gzip};
use std::path::{Path, PathBuf};

pub struct ZipWriter {
    pub parent_dir: String,
    pub alt_parent_dir: Option<String>,
    pub files: Vec<String>,
    pub output_path: String,
}

impl ZipWriter {
    pub fn new(parent_dir: String, files: Vec<String>, output_path: String) -> Self {
        Self {
            parent_dir,
            alt_parent_dir: None,
            files,
            output_path,
        }
    }

    pub fn write(&self) {
        let files: Vec<std::path::PathBuf> = self.files.iter().map(PathBuf::from).collect();
        let output_path = Path::new(&self.output_path);
        let parent_dir = Path::new(&self.parent_dir);
        let alt_parent_dir = self.alt_parent_dir.as_ref().map(Path::new);
        let zip = archive::ZipArchive::new(parent_dir, alt_parent_dir, output_path, &files);
        zip.write().expect("Failed writing zip file");
    }
}

pub struct ZipExtractor {
    pub archive_path: String,
    pub output_dir: String,
}

impl ZipExtractor {
    pub fn new(archive_path: String, output_dir: String) -> Self {
        Self {
            archive_path,
            output_dir,
        }
    }

    pub fn extract(&self) {
        let archive_path = Path::new(&self.archive_path);
        let output_dir = Path::new(&self.output_dir);
        let zip = archive::ZipExtractor::new(archive_path, output_dir);
        zip.extract().expect("Failed extracting zip file");
    }
}

pub struct TarGzipWriter {
    pub parent_dir: String,
    pub files: Vec<String>,
    pub output_path: String,
}

impl TarGzipWriter {
    pub fn new(parent_dir: String, files: Vec<String>, output_path: String) -> Self {
        Self {
            parent_dir,
            files,
            output_path,
        }
    }

    pub fn write(&self) {
        let files: Vec<PathBuf> = self.files.iter().map(PathBuf::from).collect();
        let archive = tar_gzip::TarGzipArchive::new(
            Path::new(&self.parent_dir),
            Path::new(&self.output_path),
            &files,
        );
        archive.write().expect("Failed writing tar.gz file");
    }
}

pub struct TarGzipExtractor {
    pub archive_path: String,
    pub output_dir: String,
}

impl TarGzipExtractor {
    pub fn new(archive_path: String, output_dir: String) -> Self {
        Self {
            archive_path,
            output_dir,
        }
    }

    pub fn extract(&self) {
        let archive = tar_gzip::TarGzipExtractor::new(
            Path::new(&self.archive_path),
            Path::new(&self.output_dir),
        );
        archive.extract().expect("Failed extracting tar.gz file");
    }
}

pub struct GzipWriter {
    pub input_path: String,
    pub output_path: String,
}

impl GzipWriter {
    pub fn new(input_path: String, output_path: String) -> Self {
        Self {
            input_path,
            output_path,
        }
    }

    pub fn write(&self) {
        gzip::compress(Path::new(&self.input_path), Path::new(&self.output_path))
            .expect("Failed writing gzip file");
    }
}

pub struct GzipExtractor {
    pub archive_path: String,
    pub output_path: String,
}

impl GzipExtractor {
    pub fn new(archive_path: String, output_path: String) -> Self {
        Self {
            archive_path,
            output_path,
        }
    }

    pub fn extract(&self) {
        gzip::decompress(Path::new(&self.archive_path), Path::new(&self.output_path))
            .expect("Failed extracting gzip file");
    }
}
