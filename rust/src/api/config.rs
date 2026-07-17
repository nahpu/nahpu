//! Configs FFI Bridge module.
//!
//! Exposes APIs for configuring user project preferences and document export presets.

use nahpu_configs::ConfigDb;
use std::collections::HashMap;

/// Represents a combined export field configuration.
pub struct ConfigCombinedField {
    /// Unique identifier for the combined field.
    pub field_id: String,
    /// List of field names that are combined.
    pub fields: Vec<String>,
}

/// Represents an export preset containing field maps and combined fields.
pub struct ConfigExportPreset {
    /// Map of standard field keys to their export names.
    pub fields: HashMap<String, String>,
    /// List of fields that are combined during export.
    pub combined_fields: Vec<ConfigCombinedField>,
}

/// Represents a single preset entry.
pub struct ConfigPresetEntry {
    /// Name of the preset.
    pub name: String,
    /// Preset details.
    pub preset: ConfigExportPreset,
}

/// Represents a layout block within a document.
pub struct DocumentLayoutBlock {
    pub template_name: String,
    pub template_count: i32,
    pub rows: i32,
    pub cols: i32,
    pub template_pad_top_mm: f64,
    pub template_pad_left_mm: f64,
    pub template_pad_right_mm: f64,
    pub template_pad_bottom_mm: f64,
    pub page_break_after: bool,
}

/// Represents the overall configuration for document layouts.
pub struct DocumentLayoutPreset {
    pub name: String,
    pub layout_type: String, // "WholePage" or "Continuous"
    pub page_size_key: String,
    pub page_orientation: String,
    pub custom_page_width_mm: Option<f64>,
    pub custom_page_height_mm: Option<f64>,
    pub page_pad_top_mm: f64,
    pub page_pad_left_mm: f64,
    pub page_pad_right_mm: f64,
    pub page_pad_bottom_mm: f64,
    pub blocks: Vec<DocumentLayoutBlock>,
    pub fill_page: bool,
    pub multi_block_mode: String,
}

/// Represents whether a stored document layout can be read by the current schema.
pub struct DocumentLayoutStatus {
    pub name: String,
    pub is_compatible: bool,
    pub error: Option<String>,
}

/// Identifies layout blocks that reference a template preset.
pub struct TemplatePresetUsage {
    /// Name of the print layout containing the references.
    pub layout_name: String,
    /// Zero-based indexes of blocks that reference the template.
    pub block_indices: Vec<i32>,
}

/// Summarizes a template replacement and deletion operation.
pub struct TemplatePresetDeletionResult {
    /// Number of print layouts updated before deletion.
    pub updated_layout_count: i32,
    /// Number of template block references replaced.
    pub updated_block_count: i32,
}

impl From<nahpu_configs::DocumentLayoutBlock> for DocumentLayoutBlock {
    fn from(b: nahpu_configs::DocumentLayoutBlock) -> Self {
        Self {
            template_name: b.template_name,
            template_count: b.template_count,
            rows: b.rows,
            cols: b.cols,
            template_pad_top_mm: b.template_pad_top_mm,
            template_pad_left_mm: b.template_pad_left_mm,
            template_pad_right_mm: b.template_pad_right_mm,
            template_pad_bottom_mm: b.template_pad_bottom_mm,
            page_break_after: b.page_break_after,
        }
    }
}

impl From<DocumentLayoutBlock> for nahpu_configs::DocumentLayoutBlock {
    fn from(b: DocumentLayoutBlock) -> Self {
        Self {
            template_name: b.template_name,
            template_count: b.template_count,
            rows: b.rows,
            cols: b.cols,
            template_pad_top_mm: b.template_pad_top_mm,
            template_pad_left_mm: b.template_pad_left_mm,
            template_pad_right_mm: b.template_pad_right_mm,
            template_pad_bottom_mm: b.template_pad_bottom_mm,
            page_break_after: b.page_break_after,
        }
    }
}

impl From<nahpu_configs::DocumentLayoutPreset> for DocumentLayoutPreset {
    fn from(p: nahpu_configs::DocumentLayoutPreset) -> Self {
        Self {
            name: p.name,
            layout_type: p.layout_type,
            page_size_key: p.page_size_key,
            page_orientation: p.page_orientation,
            custom_page_width_mm: p.custom_page_width_mm,
            custom_page_height_mm: p.custom_page_height_mm,
            page_pad_top_mm: p.page_pad_top_mm,
            page_pad_left_mm: p.page_pad_left_mm,
            page_pad_right_mm: p.page_pad_right_mm,
            page_pad_bottom_mm: p.page_pad_bottom_mm,
            blocks: p.blocks.into_iter().map(Into::into).collect(),
            fill_page: p.fill_page,
            multi_block_mode: p.multi_block_mode,
        }
    }
}

impl From<DocumentLayoutPreset> for nahpu_configs::DocumentLayoutPreset {
    fn from(p: DocumentLayoutPreset) -> Self {
        Self {
            name: p.name,
            layout_type: p.layout_type,
            page_size_key: p.page_size_key,
            page_orientation: p.page_orientation,
            custom_page_width_mm: p.custom_page_width_mm,
            custom_page_height_mm: p.custom_page_height_mm,
            page_pad_top_mm: p.page_pad_top_mm,
            page_pad_left_mm: p.page_pad_left_mm,
            page_pad_right_mm: p.page_pad_right_mm,
            page_pad_bottom_mm: p.page_pad_bottom_mm,
            blocks: p.blocks.into_iter().map(Into::into).collect(),
            fill_page: p.fill_page,
            multi_block_mode: p.multi_block_mode,
        }
    }
}

impl From<nahpu_configs::ConfigCombinedField> for ConfigCombinedField {
    fn from(c: nahpu_configs::ConfigCombinedField) -> Self {
        Self {
            field_id: c.field_id,
            fields: c.fields,
        }
    }
}

impl From<ConfigCombinedField> for nahpu_configs::ConfigCombinedField {
    fn from(c: ConfigCombinedField) -> Self {
        Self {
            field_id: c.field_id,
            fields: c.fields,
        }
    }
}

impl From<nahpu_configs::ConfigExportPreset> for ConfigExportPreset {
    fn from(c: nahpu_configs::ConfigExportPreset) -> Self {
        Self {
            fields: c.fields,
            combined_fields: c.combined_fields.into_iter().map(Into::into).collect(),
        }
    }
}

impl From<ConfigExportPreset> for nahpu_configs::ConfigExportPreset {
    fn from(c: ConfigExportPreset) -> Self {
        Self {
            fields: c.fields,
            combined_fields: c.combined_fields.into_iter().map(Into::into).collect(),
        }
    }
}

impl From<nahpu_configs::ConfigPresetEntry> for ConfigPresetEntry {
    fn from(c: nahpu_configs::ConfigPresetEntry) -> Self {
        Self {
            name: c.name,
            preset: c.preset.into(),
        }
    }
}

impl From<nahpu_configs::DocumentLayoutStatus> for DocumentLayoutStatus {
    fn from(s: nahpu_configs::DocumentLayoutStatus) -> Self {
        Self {
            name: s.name,
            is_compatible: s.is_compatible,
            error: s.error,
        }
    }
}

impl From<nahpu_configs::TemplatePresetUsage> for TemplatePresetUsage {
    fn from(usage: nahpu_configs::TemplatePresetUsage) -> Self {
        Self {
            layout_name: usage.layout_name,
            block_indices: usage.block_indices,
        }
    }
}

impl From<nahpu_configs::TemplatePresetDeletionResult> for TemplatePresetDeletionResult {
    fn from(result: nahpu_configs::TemplatePresetDeletionResult) -> Self {
        Self {
            updated_layout_count: result.updated_layout_count,
            updated_block_count: result.updated_block_count,
        }
    }
}

/// Initializes the configuration database at the specified path.
pub fn init_config_db(path: String) -> Result<(), String> {
    ConfigDb::init(&path)
}

pub fn set_user_config_list(key: String, value: Vec<String>) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.set_user_config_list(&key, &value)
}

pub fn get_user_config_list(key: String) -> Result<Option<Vec<String>>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_user_config_list(&key)?;
    Ok(res)
}

pub fn set_user_config_string(key: String, value: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.set_user_config_string(&key, &value)
}

pub fn get_user_config_string(key: String) -> Result<Option<String>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_user_config_string(&key)?;
    Ok(res)
}

pub fn delete_user_config(key: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.delete_user_config(&key)
}

pub fn set_record_export_preset(name: String, preset: ConfigExportPreset) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.set_record_export_preset(&name, &preset.into())
}

pub fn get_record_export_preset(name: String) -> Result<Option<ConfigExportPreset>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_record_export_preset(&name)?;
    Ok(res.map(Into::into))
}

pub fn delete_record_export_preset(name: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.delete_record_export_preset(&name)
}
pub fn get_all_record_export_presets() -> Result<Vec<ConfigPresetEntry>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_all_record_export_presets()?;
    Ok(res.into_iter().map(Into::into).collect())
}

pub fn export_config_to_file(file_path: String, is_json: bool) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    let export = db.export_configs()?;

    let content = if is_json {
        serde_json::to_string_pretty(&export).map_err(|e| e.to_string())?
    } else {
        nahpu_configs::json_lines::export_to_json_lines(&export)
    };

    std::fs::write(&file_path, content).map_err(|e| e.to_string())?;
    Ok(())
}

pub fn import_config_from_file(file_path: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    let content = std::fs::read_to_string(&file_path).map_err(|e| e.to_string())?;

    let export = if let Ok(exp) =
        serde_json::from_str::<nahpu_configs::models::UserConfigsExport>(&content)
    {
        exp
    } else {
        nahpu_configs::json_lines::parse_json_lines_to_export(&content)?
    };

    if export.schema_version > nahpu_configs::USER_CONFIG_SCHEMA_VERSION {
        return Err(format!(
            "User configuration schema version {} is newer than the supported version {}.",
            export.schema_version,
            nahpu_configs::USER_CONFIG_SCHEMA_VERSION
        ));
    }
    db.import_configs(export)?;
    Ok(())
}

pub fn set_template_preset(name: String, value: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    let val: serde_json::Value = serde_json::from_str(&value).map_err(|e| e.to_string())?;
    db.set_template_preset(&name, &val)
}

pub fn get_template_preset(name: String) -> Result<Option<String>, String> {
    let db = ConfigDb::get_instance()?;
    match db.get_template_preset(&name)? {
        Some(val) => {
            let s = serde_json::to_string(&val).map_err(|e| e.to_string())?;
            Ok(Some(s))
        }
        None => Ok(None),
    }
}

pub fn delete_template_preset(name: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.delete_template_preset(&name)
}

/// Lists every print layout block that references a template preset.
pub fn get_template_preset_usages(name: String) -> Result<Vec<TemplatePresetUsage>, String> {
    let db = ConfigDb::get_instance()?;
    let usages = db.get_template_preset_usages(&name)?;
    Ok(usages.into_iter().map(Into::into).collect())
}

/// Replaces references to a template preset and deletes it atomically.
pub fn delete_template_preset_with_replacement(
    name: String,
    replacement_name: Option<String>,
) -> Result<TemplatePresetDeletionResult, String> {
    let db = ConfigDb::get_instance()?;
    let result = db.delete_template_preset_with_replacement(&name, replacement_name.as_deref())?;
    Ok(result.into())
}

pub fn list_template_presets() -> Result<Vec<String>, String> {
    let db = ConfigDb::get_instance()?;
    let presets = db.get_all_template_presets()?;
    Ok(presets.into_iter().map(|p| p.name).collect())
}

/// Exports a single template preset to a file at the specified path.
pub fn export_template_preset_to_file(name: String, file_path: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    let preset = db
        .get_template_preset(&name)?
        .ok_or_else(|| format!("Template preset '{}' not found", name))?;
    let content = serde_json::to_string_pretty(&preset).map_err(|e| e.to_string())?;
    std::fs::write(&file_path, content).map_err(|e| e.to_string())?;
    Ok(())
}

/// Saves a document layout.
pub fn set_document_layout(name: String, layout: DocumentLayoutPreset) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.set_document_layout(&name, &layout.into())
}

/// Retrieves a document layout.
pub fn get_document_layout(name: String) -> Result<Option<DocumentLayoutPreset>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_document_layout(&name)?;
    Ok(res.map(Into::into))
}

/// Deletes a document layout.
pub fn delete_document_layout(name: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.delete_document_layout(&name)
}

/// Retrieves all document layouts.
pub fn get_all_document_layouts() -> Result<Vec<DocumentLayoutPreset>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_all_document_layouts()?;
    Ok(res.into_iter().map(Into::into).collect())
}

/// Retrieves compatibility status for every stored document layout.
pub fn get_document_layout_statuses() -> Result<Vec<DocumentLayoutStatus>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_document_layout_statuses()?;
    Ok(res.into_iter().map(Into::into).collect())
}

/// Exports a single document layout preset to a JSON file at the specified path.
pub fn export_document_layout_to_file(
    layout: DocumentLayoutPreset,
    file_path: String,
) -> Result<(), String> {
    let internal: nahpu_configs::models::DocumentLayoutPreset = layout.into();
    let content = serde_json::to_string_pretty(&internal).map_err(|e| e.to_string())?;
    std::fs::write(&file_path, content).map_err(|e| e.to_string())?;
    Ok(())
}

/// Imports a single document layout preset from a JSON file.
pub fn import_document_layout_from_file(file_path: String) -> Result<DocumentLayoutPreset, String> {
    let content = std::fs::read_to_string(&file_path).map_err(|e| e.to_string())?;
    let layout: nahpu_configs::models::DocumentLayoutPreset =
        serde_json::from_str(&content).map_err(|e| e.to_string())?;
    Ok(layout.into())
}
