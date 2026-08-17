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
    pub measurement_unit_source: Option<String>,
}

/// Resolves a batch of NAHPU source keys to Darwin Core or Dublin Core terms
/// through the published `nahpu_dwc` mapper.
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
                measurement_unit_source: mapping.measurement_unit_source.map(str::to_string),
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
        assert_eq!(headers[0].header, "dwc:locationID");
        assert_eq!(headers[1].source_key, "specimen::uuid");
        assert_eq!(headers[1].header, "dwc:occurrenceID");
    }

    #[test]
    fn resolves_v19_fields_through_the_published_mapper() {
        let headers = get_dwc_headers(vec![
            "site::islandGroup".to_string(),
            "siteAttribute::habitatType".to_string(),
            "siteAttribute::canopyCover".to_string(),
            "environment::cloudCover".to_string(),
            "weather::cloudCover".to_string(),
            "mammalAttribute::lifeStage".to_string(),
            "arthropodAttribute::caste".to_string(),
            "fossilAttribute::sex".to_string(),
            "fossilAttribute::ontogeneticStage".to_string(),
            "fossilAttribute::weight".to_string(),
            "fossilAttribute::remark".to_string(),
            "specimen::iDMethod".to_string(),
        ]);

        assert_eq!(headers.len(), 12);
        let header_for = |source_key: &str| {
            headers
                .iter()
                .find(|header| header.source_key == source_key)
                .unwrap_or_else(|| panic!("missing mapping for {source_key}"))
        };

        assert_eq!(header_for("arthropodAttribute::caste").header, "dwc:caste");
        assert_eq!(
            header_for("environment::cloudCover").measurement_unit,
            Some("okta".to_string())
        );
        assert_eq!(
            header_for("weather::cloudCover").measurement_unit,
            Some("okta".to_string())
        );
        assert_eq!(
            header_for("fossilAttribute::weight").measurement_unit_source,
            Some("fossilAttribute::weightUnit".to_string())
        );
        assert_eq!(
            header_for("siteAttribute::canopyCover").measurement_type,
            Some("canopy cover".to_string())
        );
        assert_eq!(
            header_for("mammalAttribute::lifeStage").header,
            "dwc:lifeStage"
        );
        assert_eq!(header_for("fossilAttribute::sex").header, "dwc:sex");
        assert_eq!(
            header_for("fossilAttribute::ontogeneticStage").header,
            "dwc:lifeStage"
        );
        assert_eq!(
            header_for("fossilAttribute::remark").header,
            "dwc:materialEntityRemarks"
        );
        assert_eq!(
            header_for("specimen::iDMethod").header,
            "dwc:identificationType"
        );
        assert_eq!(header_for("site::islandGroup").header, "dwc:islandGroup");
        assert_eq!(
            header_for("siteAttribute::habitatType").header,
            "dwc:habitat"
        );
    }
}
