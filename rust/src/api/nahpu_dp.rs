//! NAHPU Data Package bridge APIs.

use std::collections::BTreeMap;

use serde_json::Value;

pub fn plan_nahpu_package(request_json: String) -> Result<String, String> {
    nahpu_dp::plan_package_json(&enrich_request(&request_json)?)
}

pub fn validate_nahpu_package(request_json: String) -> Result<String, String> {
    nahpu_dp::validate_package_json(&enrich_request(&request_json)?)
}

pub fn write_nahpu_package(request_json: String, output_path: String) -> Result<String, String> {
    nahpu_dp::write_package_json(&enrich_request(&request_json)?, &output_path)
}

fn enrich_request(request_json: &str) -> Result<String, String> {
    let mut request: Value =
        serde_json::from_str(request_json).map_err(|error| error.to_string())?;
    let object = request
        .as_object_mut()
        .ok_or_else(|| "NAHPU package request must be a JSON object".to_string())?;
    let dependencies = BTreeMap::from([
        ("nahpu_archive", nahpu_archive::VERSION),
        ("nahpu_configs", nahpu_configs::VERSION),
        ("nahpu_db", nahpu_db::VERSION),
        ("nahpu_dp", nahpu_dp::VERSION),
        ("nahpu_dwc", nahpu_dwc::VERSION),
        ("nahpu_export", "0.3.3"),
        ("nahpu_gis", "0.2.0"),
        ("rust_lib_nahpu", env!("CARGO_PKG_VERSION")),
    ]);
    object.insert(
        "dependencies".to_string(),
        serde_json::to_value(dependencies).map_err(|error| error.to_string())?,
    );
    serde_json::to_string(&request).map_err(|error| error.to_string())
}
