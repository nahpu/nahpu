//! Image inspection and export API for Flutter.

use std::sync::mpsc;

use crate::frb_generated::StreamSink;
use nahpu_images::{
    ImageFileFormat as CoreImageFileFormat, ImageOptions, ImageProcessor, ResizeOptions,
};
use rayon::prelude::*;

/// Static image formats supported for conversion and export.
#[derive(Clone, Copy)]
pub enum ImageExportFormat {
    Jpeg,
    Png,
    WebP,
}

/// Source properties needed to present aspect-locked resize controls.
pub struct ImageSourceInfo {
    pub format: ImageExportFormat,
    pub width: u32,
    pub height: u32,
}

/// Properties of a completed image export.
pub struct ImageExportResult {
    pub width: u32,
    pub height: u32,
    pub bytes: u64,
    pub resized: bool,
}

/// One image conversion requested by the batch media exporter.
pub struct BatchImageExportRequest {
    pub input_path: String,
    pub output_path: String,
    pub output_format: ImageExportFormat,
    pub resize_width: Option<u32>,
    pub resize_height: Option<u32>,
    pub jpeg_quality: u8,
}

/// Completion event for one image in a parallel conversion batch.
pub struct BatchImageExportEvent {
    pub output_path: String,
    pub width: Option<u32>,
    pub height: Option<u32>,
    pub bytes: Option<u64>,
    pub resized: bool,
    pub error: Option<String>,
}

/// Inspects a static JPEG, PNG, or WebP without re-encoding it.
pub fn inspect_image(input_path: String) -> Result<ImageSourceInfo, String> {
    let info = ImageProcessor::inspect_file(input_path).map_err(|error| error.to_string())?;
    Ok(ImageSourceInfo {
        format: info.format.into(),
        width: info.width,
        height: info.height,
    })
}

/// Converts and optionally resizes a static image into a new file.
pub fn export_image(
    input_path: String,
    output_path: String,
    output_format: ImageExportFormat,
    resize_width: Option<u32>,
    resize_height: Option<u32>,
    jpeg_quality: u8,
) -> Result<ImageExportResult, String> {
    let mut options = ImageOptions::new(output_format.into()).with_jpeg_quality(jpeg_quality);
    match (resize_width, resize_height) {
        (Some(width), Some(height)) => {
            options = options.with_resize(ResizeOptions::fit(Some(width), Some(height)));
        }
        (None, None) => {}
        _ => return Err("resize requires both width and height".to_owned()),
    }
    let info = ImageProcessor::process_file(input_path, output_path, &options, false)
        .map_err(|error| error.to_string())?;
    Ok(ImageExportResult {
        width: info.output_width,
        height: info.output_height,
        bytes: info.output_bytes,
        resized: info.resized,
    })
}

/// Converts images on Rayon's worker pool and streams each result as it completes.
pub fn export_images_batch(
    requests: Vec<BatchImageExportRequest>,
    sink: StreamSink<BatchImageExportEvent>,
) -> Result<(), String> {
    if requests.is_empty() {
        return Ok(());
    }
    let request_count = requests.len();
    let (sender, receiver) = mpsc::channel();
    rayon::spawn(move || {
        requests
            .into_par_iter()
            .for_each_with(sender, |sender, request| {
                let _ = sender.send(export_batch_image(request));
            });
    });

    for _ in 0..request_count {
        let event = receiver
            .recv()
            .map_err(|error| format!("parallel image conversion stopped: {error}"))?;
        let _ = sink.add(event);
    }
    Ok(())
}

fn export_batch_image(request: BatchImageExportRequest) -> BatchImageExportEvent {
    let BatchImageExportRequest {
        input_path,
        output_path,
        output_format,
        resize_width,
        resize_height,
        jpeg_quality,
    } = request;
    let event_path = output_path.clone();
    match export_image(
        input_path,
        output_path,
        output_format,
        resize_width,
        resize_height,
        jpeg_quality,
    ) {
        Ok(result) => BatchImageExportEvent {
            output_path: event_path,
            width: Some(result.width),
            height: Some(result.height),
            bytes: Some(result.bytes),
            resized: result.resized,
            error: None,
        },
        Err(error) => BatchImageExportEvent {
            output_path: event_path,
            width: None,
            height: None,
            bytes: None,
            resized: false,
            error: Some(error),
        },
    }
}

impl From<ImageExportFormat> for CoreImageFileFormat {
    fn from(format: ImageExportFormat) -> Self {
        match format {
            ImageExportFormat::Jpeg => Self::Jpeg,
            ImageExportFormat::Png => Self::Png,
            ImageExportFormat::WebP => Self::WebP,
        }
    }
}

impl From<CoreImageFileFormat> for ImageExportFormat {
    fn from(format: CoreImageFileFormat) -> Self {
        match format {
            CoreImageFileFormat::Jpeg => Self::Jpeg,
            CoreImageFileFormat::Png => Self::Png,
            CoreImageFileFormat::WebP => Self::WebP,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn maps_every_export_format() {
        assert_eq!(
            CoreImageFileFormat::from(ImageExportFormat::Jpeg),
            CoreImageFileFormat::Jpeg
        );
        assert_eq!(
            CoreImageFileFormat::from(ImageExportFormat::Png),
            CoreImageFileFormat::Png
        );
        assert_eq!(
            CoreImageFileFormat::from(ImageExportFormat::WebP),
            CoreImageFileFormat::WebP
        );
    }

    #[test]
    fn rejects_incomplete_resize_dimensions_before_reading_input() {
        let error = match export_image(
            "missing.png".to_owned(),
            "output.png".to_owned(),
            ImageExportFormat::Png,
            Some(100),
            None,
            85,
        ) {
            Ok(_) => panic!("incomplete dimensions should fail"),
            Err(error) => error,
        };

        assert_eq!(error, "resize requires both width and height");
    }
}
