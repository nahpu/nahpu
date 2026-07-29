//! Document rendering API for Flutter.

use nahpu_export::TypstCompiler;

/// Compiles Typst source into PDF bytes using caller-provided fonts.
pub fn compile_typst_to_pdf(
    typst_content: String,
    font_bytes: Vec<Vec<u8>>,
) -> Result<Vec<u8>, String> {
    TypstCompiler::new(font_bytes)
        .compile(&typst_content)
        .map_err(|error| error.to_string())
}

/// Converts Markdown rich text into Typst markup.
pub fn markdown_to_typst(markdown_content: String) -> String {
    nahpu_export::markdown_to_typst(&markdown_content)
}
