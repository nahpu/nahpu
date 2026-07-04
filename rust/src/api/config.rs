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

/// Initializes the configuration database at the specified path.
pub fn init_config_db(path: String) -> Result<(), String> {
    ConfigDb::init(&path)
}

/// Sets a user config list.
pub fn set_user_config_list(key: String, value: Vec<String>) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.set_user_config_list(&key, &value)
}

/// Retrieves a user config list.
pub fn get_user_config_list(key: String) -> Result<Option<Vec<String>>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_user_config_list(&key)?;
    Ok(res)
}

/// Sets a user config string.
pub fn set_user_config_string(key: String, value: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.set_user_config_string(&key, &value)
}

/// Retrieves a user config string.
pub fn get_user_config_string(key: String) -> Result<Option<String>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_user_config_string(&key)?;
    Ok(res)
}

/// Deletes a user config key.
pub fn delete_user_config(key: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.delete_user_config(&key)
}

/// Saves a record export preset.
pub fn set_record_export_preset(name: String, preset: ConfigExportPreset) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.set_record_export_preset(&name, &preset.into())
}

/// Retrieves a record export preset.
pub fn get_record_export_preset(name: String) -> Result<Option<ConfigExportPreset>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_record_export_preset(&name)?;
    Ok(res.map(Into::into))
}

/// Deletes a record export preset.
pub fn delete_record_export_preset(name: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.delete_record_export_preset(&name)
}

/// Retrieves all record export presets.
pub fn get_all_record_export_presets() -> Result<Vec<ConfigPresetEntry>, String> {
    let db = ConfigDb::get_instance()?;
    let res = db.get_all_record_export_presets()?;
    Ok(res.into_iter().map(Into::into).collect())
}

/// Exports all user configs and document presets to a file in either JSON or KDL format.
pub fn export_config_to_file(file_path: String, is_json: bool) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    let export = db.export_configs()?;

    let content = if is_json {
        serde_json::to_string_pretty(&export).map_err(|e| e.to_string())?
    } else {
        nahpu_configs::kdl::export_to_kdl(&export)
    };

    std::fs::write(&file_path, content).map_err(|e| e.to_string())?;
    Ok(())
}

/// Imports and replaces all user configs and document presets from a file.
pub fn import_config_from_file(file_path: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    let content = std::fs::read_to_string(&file_path).map_err(|e| e.to_string())?;

    let is_json = content.trim_start().starts_with('{');

    let export = if is_json {
        serde_json::from_str::<nahpu_configs::models::UserConfigsExport>(&content)
            .map_err(|e| e.to_string())?
    } else {
        nahpu_configs::kdl::parse_kdl_to_export(&content)?
    };

    db.import_configs(export)?;
    Ok(())
}

/// Saves a template preset JSON string to the config database.
pub fn set_template_preset(name: String, value: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    let val: serde_json::Value = serde_json::from_str(&value).map_err(|e| e.to_string())?;
    db.set_template_preset(&name, &val)
}

/// Retrieves a saved template preset as a JSON string.
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

/// Deletes a template preset.
pub fn delete_template_preset(name: String) -> Result<(), String> {
    let db = ConfigDb::get_instance()?;
    db.delete_template_preset(&name)
}

/// Lists all template preset names stored in the database.
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
