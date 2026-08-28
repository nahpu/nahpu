//! Rust FRB Boilerplate to access the archive API
use crate::frb_generated::StreamSink;
use nahpu_archive::progress::ArchiveProgress as CoreArchiveProgress;
use nahpu_archive::{archive, gzip, tar_gzip};
use std::path::{Path, PathBuf};

/// A snapshot of an archive operation, streamed to Dart while the work runs.
///
/// Compressing a media library takes minutes, so the export screens follow this stream
/// instead of waiting on a single call that reports nothing until it finishes.
pub struct ArchiveProgress {
    /// Entries fully processed so far.
    pub entries_done: u64,
    /// Entries the operation expects to process, or `0` when the count is unknown.
    pub entries_total: u64,
    /// Bytes processed so far.
    pub bytes_done: u64,
    /// Bytes the operation expects to process, or `0` when the size is unknown.
    pub bytes_total: u64,
    /// Archive-relative path of the entry being processed.
    pub current_path: String,
}

impl From<CoreArchiveProgress> for ArchiveProgress {
    fn from(progress: CoreArchiveProgress) -> Self {
        Self {
            entries_done: progress.entries_done,
            entries_total: progress.entries_total,
            bytes_done: progress.bytes_done,
            bytes_total: progress.bytes_total,
            current_path: progress.current_path,
        }
    }
}

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

    /// Writes the archive, streaming a progress snapshot as each entry is compressed.
    ///
    /// Unlike [`Self::write`], a failure here is delivered to Dart rather than raised as
    /// a panic across the FFI boundary, so a full disk becomes a message the user reads.
    pub fn write_with_progress(&self, sink: StreamSink<ArchiveProgress>) -> Result<(), String> {
        let files: Vec<PathBuf> = self.files.iter().map(PathBuf::from).collect();
        let output_path = Path::new(&self.output_path);
        let parent_dir = Path::new(&self.parent_dir);
        let alt_parent_dir = self.alt_parent_dir.as_ref().map(Path::new);
        let zip = archive::ZipArchive::new(parent_dir, alt_parent_dir, output_path, &files);
        zip.write_with_progress(&mut |progress| {
            let _ = sink.add(progress.into());
        })
        .map_err(|error| error.to_string())
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

    /// Extracts the archive, streaming a progress snapshot as each entry is written.
    pub fn extract_with_progress(&self, sink: StreamSink<ArchiveProgress>) -> Result<(), String> {
        let archive_path = Path::new(&self.archive_path);
        let output_dir = Path::new(&self.output_dir);
        let zip = archive::ZipExtractor::new(archive_path, output_dir);
        zip.extract_with_progress(&mut |progress| {
            let _ = sink.add(progress.into());
        })
        .map_err(|error| error.to_string())
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

    /// Writes the archive, streaming a progress snapshot as each entry is compressed.
    pub fn write_with_progress(&self, sink: StreamSink<ArchiveProgress>) -> Result<(), String> {
        let files: Vec<PathBuf> = self.files.iter().map(PathBuf::from).collect();
        let archive = tar_gzip::TarGzipArchive::new(
            Path::new(&self.parent_dir),
            Path::new(&self.output_path),
            &files,
        );
        archive
            .write_with_progress(&mut |progress| {
                let _ = sink.add(progress.into());
            })
            .map_err(|error| error.to_string())
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

    /// Extracts the archive, streaming a progress snapshot as each entry is unpacked.
    ///
    /// A tar stream carries no index, so the totals stay `0` until the final snapshot.
    pub fn extract_with_progress(&self, sink: StreamSink<ArchiveProgress>) -> Result<(), String> {
        let archive = tar_gzip::TarGzipExtractor::new(
            Path::new(&self.archive_path),
            Path::new(&self.output_dir),
        );
        archive
            .extract_with_progress(&mut |progress| {
                let _ = sink.add(progress.into());
            })
            .map_err(|error| error.to_string())
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

    /// Compresses the file, streaming a progress snapshot as its bytes are read.
    pub fn write_with_progress(&self, sink: StreamSink<ArchiveProgress>) -> Result<(), String> {
        gzip::compress_with_progress(
            Path::new(&self.input_path),
            Path::new(&self.output_path),
            &mut |progress| {
                let _ = sink.add(progress.into());
            },
        )
        .map_err(|error| error.to_string())
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

    /// Decompresses the file, streaming a progress snapshot as the archive is read.
    pub fn extract_with_progress(&self, sink: StreamSink<ArchiveProgress>) -> Result<(), String> {
        gzip::decompress_with_progress(
            Path::new(&self.archive_path),
            Path::new(&self.output_path),
            &mut |progress| {
                let _ = sink.add(progress.into());
            },
        )
        .map_err(|error| error.to_string())
    }
}
