//! Image inspection and export API for Flutter.

use nahpu_images::{
    ImageFileFormat as CoreImageFileFormat, ImageOptions, ImageProcessor, ResizeOptions,
};

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
