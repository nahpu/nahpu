//! Darwin Core header mapping APIs for tabular export presets.

use nahpu_dwc::dwc::DwcMapper;
use nahpu_dwc::package;
use std::collections::BTreeSet;

/// A resolved Darwin Core header for one NAHPU `table::field` source key.
pub struct DwcHeader {
    pub source_key: String,
    /// The first visible header, retained for compatibility with callers that
    /// only support direct mappings.
    pub header: String,
    /// All visible headers emitted for this source, in tabular order.
    pub headers: Vec<String>,
    /// Static MeasurementOrFact values, when this source is a measurement.
    pub measurement_type: Option<String>,
    pub measurement_unit: Option<String>,
}

/// Resolves a batch of NAHPU source keys to Darwin Core or Dublin Core terms.
///
/// Unmapped and malformed source keys are intentionally omitted. The caller
/// uses those omissions to generate the corresponding NAHPU namespace header.
pub fn get_dwc_headers(source_keys: Vec<String>) -> Vec<DwcHeader> {
    BTreeSet::from_iter(source_keys)
        .into_iter()
        .filter_map(|source_key| {
            DwcMapper::get_dwc_mapping_for_source_key(&source_key).map(|mapping| DwcHeader {
                header: mapping.headers[0].to_string(),
                source_key,
                headers: mapping.headers.into_iter().map(str::to_string).collect(),
                measurement_type: mapping.measurement_type.map(str::to_string),
                measurement_unit: mapping.measurement_unit.map(str::to_string),
            })
        })
        .collect()
}

/// Plans the exact package contents for the Bundle Project contents panel.
pub fn plan_dwc_bundle(request_json: String) -> Result<String, String> {
    package::plan_bundle_json(&request_json)
}

/// Validates the selected records before a Darwin Core bundle is written.
pub fn validate_dwc_bundle(request_json: String) -> Result<String, String> {
    package::validate_bundle_json(&request_json)
}

/// Writes a Darwin Core Archive file or a Darwin Core Data Package directory.
pub fn write_dwc_bundle(request_json: String, output_path: String) -> Result<String, String> {
    package::write_bundle_json(&request_json, &output_path)
}

#[cfg(test)]
mod tests {
    use super::get_dwc_headers;

    #[test]
    fn resolves_unique_mapped_source_keys_in_stable_order() {
        let headers = get_dwc_headers(vec![
            "specimen::uuid".to_string(),
            "unknown::field".to_string(),
            "specimen::uuid".to_string(),
            "site::siteID".to_string(),
        ]);

        assert_eq!(headers.len(), 2);
        assert_eq!(headers[0].source_key, "site::siteID");
        assert_eq!(headers[0].header, "dwc:siteNumber");
        assert_eq!(headers[1].source_key, "specimen::uuid");
        assert_eq!(headers[1].header, "dwc:occurrenceID");
    }
}
