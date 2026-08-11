//! GIS coordinate conversion API for Flutter.
//!
//! Provides functions to convert coordinates between DMS, DDM, UTM, and Decimal
//! Degrees, and to parse coordinate strings automatically.

use nahpu_gis::conversion::{
    CardinalDirection as CD, CoordinateConverter, DdmCoordinate as Ddm, DmsCoordinate as Dms,
    UtmCoordinate as Utm,
};
use nahpu_gis::{
    CoordinateData, CoordinateExporter, CoordinateFormat, CoordinateImportResult,
    CoordinateImporter, GeographicBounds, VectorLayerConverter,
};

/// Portable point fields supported by NAHPU GIS imports and exports.
#[derive(Clone)]
pub struct CoordinateTransferRecord {
    pub name_id: String,
    pub notes: Option<String>,
    pub decimal_longitude: Option<f64>,
    pub decimal_latitude: Option<f64>,
    pub elevation_in_meter: Option<f64>,
}

/// File formats supported by the coordinate exporter.
pub enum CoordinateExportFormat {
    GeoJson,
    Kml,
    Shapefile,
}

/// Coordinates and diagnostics returned by a file import.
pub struct CoordinateFileImportResult {
    pub coordinates: Vec<CoordinateTransferRecord>,
    pub skipped_count: u64,
    pub warnings: Vec<String>,
}

/// Exports one or more coordinates using NAHPU GIS.
pub fn export_coordinates(
    coordinates: Vec<CoordinateTransferRecord>,
    format: CoordinateExportFormat,
    output_path: String,
) -> Result<(), String> {
    let data = coordinates
        .into_iter()
        .map(CoordinateData::from)
        .collect::<Vec<_>>();
    let format = match format {
        CoordinateExportFormat::GeoJson => CoordinateFormat::GeoJson,
        CoordinateExportFormat::Kml => CoordinateFormat::Kml,
        CoordinateExportFormat::Shapefile => CoordinateFormat::Shapefile,
    };
    CoordinateExporter::new(&data)
        .and_then(|exporter| exporter.export(format, output_path))
        .map_err(|error| error.to_string())
}

/// Imports point coordinates from GeoJSON, KML, zipped Shapefile, or GPX.
pub fn import_coordinates(input_path: String) -> Result<CoordinateFileImportResult, String> {
    let result = CoordinateImporter::new(input_path)
        .import()
        .map_err(|error| error.to_string())?;
    CoordinateFileImportResult::try_from(result)
}

impl From<CoordinateTransferRecord> for CoordinateData {
    fn from(value: CoordinateTransferRecord) -> Self {
        Self {
            name_id: value.name_id,
            notes: value.notes,
            decimal_longitude: value.decimal_longitude,
            decimal_latitude: value.decimal_latitude,
            elevation_in_meter: value.elevation_in_meter,
        }
    }
}

impl From<CoordinateData> for CoordinateTransferRecord {
    fn from(value: CoordinateData) -> Self {
        Self {
            name_id: value.name_id,
            notes: value.notes,
            decimal_longitude: value.decimal_longitude,
            decimal_latitude: value.decimal_latitude,
            elevation_in_meter: value.elevation_in_meter,
        }
    }
}

impl TryFrom<CoordinateImportResult> for CoordinateFileImportResult {
    type Error = String;

    fn try_from(value: CoordinateImportResult) -> Result<Self, Self::Error> {
        if value.coordinates.is_empty() {
            return Err("No valid point coordinates were found in the selected file".to_owned());
        }
        Ok(Self {
            coordinates: value.coordinates.into_iter().map(Into::into).collect(),
            skipped_count: value.skipped_count,
            warnings: value.warnings,
        })
    }
}

/// Metadata for a user vector layer normalized by `nahpu_gis`.
pub struct ImportedVectorLayer {
    /// Number of GeoJSON features written.
    pub feature_count: u64,
    /// WGS84 bounds in west, south, east, north order.
    pub bounds: Option<GeographicBoundsFfi>,
    /// Coordinate reference system of the output.
    pub source_crs: String,
}

/// WGS84 vector bounds.
pub struct GeographicBoundsFfi {
    /// Western longitude.
    pub west: f64,
    /// Southern latitude.
    pub south: f64,
    /// Eastern longitude.
    pub east: f64,
    /// Northern latitude.
    pub north: f64,
}

impl From<GeographicBounds> for GeographicBoundsFfi {
    fn from(value: GeographicBounds) -> Self {
        Self {
            west: value.west,
            south: value.south,
            east: value.east,
            north: value.north,
        }
    }
}

/// Converts GeoJSON or a zipped WGS84 Shapefile to normalized GeoJSON.
pub fn convert_vector_layer_to_geojson(
    input_path: String,
    output_path: String,
) -> Result<ImportedVectorLayer, String> {
    let result = VectorLayerConverter::new(input_path, output_path)
        .convert()
        .map_err(|error| error.to_string())?;
    Ok(ImportedVectorLayer {
        feature_count: result.feature_count,
        bounds: result.bounds.map(Into::into),
        source_crs: result.source_crs,
    })
}

/// Represents a geographic cardinal direction.
pub enum CardinalDirection {
    /// Northern hemisphere (positive latitude)
    North,
    /// Southern hemisphere (negative latitude)
    South,
    /// Eastern hemisphere (positive longitude)
    East,
    /// Western hemisphere (negative longitude)
    West,
}

/// Axis used to choose latitude or longitude cardinal directions.
pub enum CoordinateAxis {
    /// Latitude with north or south direction.
    Latitude,
    /// Longitude with east or west direction.
    Longitude,
}

impl From<CD> for CardinalDirection {
    fn from(cd: CD) -> Self {
        match cd {
            CD::North => Self::North,
            CD::South => Self::South,
            CD::East => Self::East,
            CD::West => Self::West,
        }
    }
}

impl From<CardinalDirection> for CD {
    fn from(cd: CardinalDirection) -> Self {
        match cd {
            CardinalDirection::North => Self::North,
            CardinalDirection::South => Self::South,
            CardinalDirection::East => Self::East,
            CardinalDirection::West => Self::West,
        }
    }
}

/// Represents a coordinate in Degrees, Minutes, and Seconds (DMS) format.
pub struct DmsCoordinateFfi {
    /// Degree component.
    pub degrees: u32,
    /// Minute component.
    pub minutes: u32,
    /// Second component.
    pub seconds: f64,
    /// Cardinal direction.
    pub direction: CardinalDirection,
}

/// Represents a coordinate in Degrees and Decimal Minutes (DDM) format.
pub struct DdmCoordinateFfi {
    /// Degree component.
    pub degrees: u32,
    /// Minute component.
    pub minutes: f64,
    /// Cardinal direction.
    pub direction: CardinalDirection,
}

/// Represents a coordinate in Universal Transverse Mercator (UTM) format.
pub struct UtmCoordinateFfi {
    /// UTM Zone number.
    pub zone: u8,
    /// UTM Hemisphere (North or South).
    pub hemisphere: CardinalDirection,
    /// Easting in meters.
    pub easting: f64,
    /// Northing in meters.
    pub northing: f64,
}

/// Coordinate formats accepted by the NAHPU coordinate editor.
pub enum CoordinateInputFormat {
    DecimalDegrees,
    DegreesDecimalMinutes,
    DegreesMinutesSeconds,
    Utm,
}

/// A validated coordinate normalized for database storage.
pub struct ParsedCoordinateInput {
    pub decimal_latitude: f64,
    pub decimal_longitude: f64,
    pub verbatim_latitude: Option<String>,
    pub verbatim_longitude: Option<String>,
    pub verbatim_coordinates: Option<String>,
    pub verbatim_coordinate_system: Option<String>,
}

/// Parses a coordinate using the explicitly selected NAHPU coordinate format.
pub fn parse_coordinate_input(
    format: CoordinateInputFormat,
    primary: String,
    secondary: Option<String>,
) -> Result<ParsedCoordinateInput, String> {
    match format {
        CoordinateInputFormat::DecimalDegrees => {
            let latitude = parse_decimal_axis(&primary, CoordinateAxis::Latitude)?;
            let longitude_text = secondary
                .as_deref()
                .ok_or_else(|| "Longitude is required".to_owned())?;
            let longitude = parse_decimal_axis(longitude_text, CoordinateAxis::Longitude)?;
            Ok(ParsedCoordinateInput {
                decimal_latitude: latitude,
                decimal_longitude: longitude,
                verbatim_latitude: None,
                verbatim_longitude: None,
                verbatim_coordinates: None,
                verbatim_coordinate_system: None,
            })
        }
        CoordinateInputFormat::DegreesDecimalMinutes => {
            parse_angular_pair::<Ddm>(&primary, secondary, "degrees decimal minutes")
        }
        CoordinateInputFormat::DegreesMinutesSeconds => {
            parse_angular_pair::<Dms>(&primary, secondary, "degrees minutes seconds")
        }
        CoordinateInputFormat::Utm => parse_utm_input(primary),
    }
}

trait AngularCoordinate: std::str::FromStr<Err = nahpu_gis::GisError> {
    fn direction(&self) -> CardinalDirection;
    fn decimal(&self) -> f64;
}

impl AngularCoordinate for Ddm {
    fn direction(&self) -> CardinalDirection {
        self.direction.into()
    }

    fn decimal(&self) -> f64 {
        self.to_decimal()
    }
}

impl AngularCoordinate for Dms {
    fn direction(&self) -> CardinalDirection {
        self.direction.into()
    }

    fn decimal(&self) -> f64 {
        self.to_decimal()
    }
}

fn parse_angular_pair<T>(
    latitude_text: &str,
    longitude_text: Option<String>,
    system: &str,
) -> Result<ParsedCoordinateInput, String>
where
    T: AngularCoordinate,
{
    let longitude_text = longitude_text.ok_or_else(|| "Longitude is required".to_owned())?;
    let latitude = latitude_text
        .parse::<T>()
        .map_err(|error| error.to_string())?;
    let longitude = longitude_text
        .parse::<T>()
        .map_err(|error| error.to_string())?;
    if !matches!(
        latitude.direction(),
        CardinalDirection::North | CardinalDirection::South
    ) {
        return Err("Latitude must use a north or south direction".to_owned());
    }
    if !matches!(
        longitude.direction(),
        CardinalDirection::East | CardinalDirection::West
    ) {
        return Err("Longitude must use an east or west direction".to_owned());
    }
    Ok(ParsedCoordinateInput {
        decimal_latitude: latitude.decimal(),
        decimal_longitude: longitude.decimal(),
        verbatim_latitude: Some(latitude_text.to_owned()),
        verbatim_longitude: Some(longitude_text),
        verbatim_coordinates: None,
        verbatim_coordinate_system: Some(system.to_owned()),
    })
}

fn parse_decimal_axis(value: &str, axis: CoordinateAxis) -> Result<f64, String> {
    let decimal = value
        .trim()
        .parse::<f64>()
        .map_err(|_| "Coordinate must be a decimal number".to_owned())?;
    direction_for_decimal(decimal, axis)?;
    Ok(decimal)
}

fn parse_utm_input(value: String) -> Result<ParsedCoordinateInput, String> {
    let components = value.split_whitespace().collect::<Vec<_>>();
    if components.len() != 4 {
        return Err("UTM must contain zone, hemisphere, easting, and northing".to_owned());
    }
    let zone = components[0]
        .parse::<u8>()
        .map_err(|_| "UTM zone must be a number".to_owned())?;
    let hemisphere = match components[1].to_ascii_uppercase().as_str() {
        "N" | "NORTH" => CardinalDirection::North,
        "S" | "SOUTH" => CardinalDirection::South,
        _ => return Err("UTM hemisphere must be N or S".to_owned()),
    };
    let easting = components[2]
        .parse::<f64>()
        .map_err(|_| "UTM easting must be a number".to_owned())?;
    let northing = components[3]
        .parse::<f64>()
        .map_err(|_| "UTM northing must be a number".to_owned())?;
    let (latitude, longitude) = utm_to_dd(zone, hemisphere, easting, northing)?;
    Ok(ParsedCoordinateInput {
        decimal_latitude: latitude,
        decimal_longitude: longitude,
        verbatim_latitude: None,
        verbatim_longitude: None,
        verbatim_coordinates: Some(value),
        verbatim_coordinate_system: Some("UTM".to_owned()),
    })
}

/// Converts DMS to decimal degrees.
///
/// # Examples
///
/// ```
/// use rust_lib_nahpu::api::gis::{dms_to_dd, CardinalDirection};
///
/// let dd = dms_to_dd(41, 24, 12.2, CardinalDirection::North)?;
/// assert!((dd - 41.40338888888889).abs() < 1e-9);
/// # Ok::<(), String>(())
/// ```
pub fn dms_to_dd(
    degrees: u32,
    minutes: u32,
    seconds: f64,
    direction: CardinalDirection,
) -> Result<f64, String> {
    let dms = Dms::new(degrees, minutes, seconds, direction.into());
    dms.validate().map_err(|error| error.to_string())?;
    Ok(dms.to_decimal())
}

/// Converts DDM to decimal degrees.
///
/// # Examples
///
/// ```
/// use rust_lib_nahpu::api::gis::{ddm_to_dd, CardinalDirection};
///
/// let dd = ddm_to_dd(41, 24.2028, CardinalDirection::North)?;
/// assert!((dd - 41.40338).abs() < 1e-9);
/// # Ok::<(), String>(())
/// ```
pub fn ddm_to_dd(degrees: u32, minutes: f64, direction: CardinalDirection) -> Result<f64, String> {
    let ddm = Ddm::new(degrees, minutes, direction.into());
    ddm.validate().map_err(|error| error.to_string())?;
    Ok(ddm.to_decimal())
}

/// Converts UTM to decimal degrees latitude and longitude.
pub fn utm_to_dd(
    zone: u8,
    hemisphere: CardinalDirection,
    easting: f64,
    northing: f64,
) -> Result<(f64, f64), String> {
    let utm =
        Utm::new(zone, hemisphere.into(), easting, northing).map_err(|error| error.to_string())?;
    utm.to_lat_lon().map_err(|error| error.to_string())
}

/// Converts decimal degrees to DMS.
pub fn dd_to_dms(dd: f64, axis: CoordinateAxis) -> Result<DmsCoordinateFfi, String> {
    let direction = direction_for_decimal(dd, axis)?;
    let dms = Dms::from_decimal(dd, direction);
    Ok(DmsCoordinateFfi {
        degrees: dms.degrees,
        minutes: dms.minutes,
        seconds: dms.seconds,
        direction: dms.direction.into(),
    })
}

/// Converts decimal degrees to DDM.
pub fn dd_to_ddm(dd: f64, axis: CoordinateAxis) -> Result<DdmCoordinateFfi, String> {
    let direction = direction_for_decimal(dd, axis)?;
    let ddm = Ddm::from_decimal(dd, direction);
    Ok(DdmCoordinateFfi {
        degrees: ddm.degrees,
        minutes: ddm.minutes,
        direction: ddm.direction.into(),
    })
}

/// Converts decimal degrees latitude and longitude to UTM.
pub fn dd_to_utm(latitude: f64, longitude: f64) -> Result<UtmCoordinateFfi, String> {
    let utm = Utm::from_lat_lon(latitude, longitude).map_err(|error| error.to_string())?;
    Ok(UtmCoordinateFfi {
        zone: utm.zone,
        hemisphere: utm.hemisphere.into(),
        easting: utm.easting,
        northing: utm.northing,
    })
}

/// Automatically detects the coordinate format of a string and parses it to decimal degrees.
pub fn parse_coordinate_string(s: String) -> Result<f64, String> {
    CoordinateConverter::parse_to_decimal(&s).map_err(|error| error.to_string())
}

fn direction_for_decimal(dd: f64, axis: CoordinateAxis) -> Result<CD, String> {
    let range = match axis {
        CoordinateAxis::Latitude => -90.0..=90.0,
        CoordinateAxis::Longitude => -180.0..=180.0,
    };
    if !dd.is_finite() || !range.contains(&dd) {
        return Err("decimal coordinate is non-finite or outside its axis range".to_owned());
    }
    Ok(match (axis, dd.is_sign_negative()) {
        (CoordinateAxis::Latitude, false) => CD::North,
        (CoordinateAxis::Latitude, true) => CD::South,
        (CoordinateAxis::Longitude, false) => CD::East,
        (CoordinateAxis::Longitude, true) => CD::West,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn axis_conversion_rejects_out_of_range_values() {
        assert!(dd_to_dms(91.0, CoordinateAxis::Latitude).is_err());
        assert!(dd_to_ddm(f64::NAN, CoordinateAxis::Longitude).is_err());
    }

    #[test]
    fn coordinate_export_rejects_invalid_records() {
        let coordinate = CoordinateTransferRecord {
            name_id: "invalid".to_owned(),
            notes: None,
            decimal_longitude: Some(0.0),
            decimal_latitude: None,
            elevation_in_meter: None,
        };
        let result = export_coordinates(
            vec![coordinate],
            CoordinateExportFormat::GeoJson,
            "unused.geojson".to_owned(),
        );
        assert!(result.is_err());
    }

    #[test]
    fn parses_supported_coordinate_inputs_and_preserves_verbatim_values() {
        let decimal = parse_coordinate_input(
            CoordinateInputFormat::DecimalDegrees,
            "41.5".to_owned(),
            Some("-123.25".to_owned()),
        )
        .unwrap();
        assert_eq!(decimal.decimal_latitude, 41.5);
        assert!(decimal.verbatim_coordinate_system.is_none());

        let dms = parse_coordinate_input(
            CoordinateInputFormat::DegreesMinutesSeconds,
            "41° 24' 12.2\" N".to_owned(),
            Some("123° 15' 0\" W".to_owned()),
        )
        .unwrap();
        assert_eq!(dms.verbatim_latitude.as_deref(), Some("41° 24' 12.2\" N"));
        assert_eq!(
            dms.verbatim_coordinate_system.as_deref(),
            Some("degrees minutes seconds")
        );

        let utm = parse_coordinate_input(
            CoordinateInputFormat::Utm,
            "11 N 385153 3768853".to_owned(),
            None,
        )
        .unwrap();
        assert_eq!(
            utm.verbatim_coordinates.as_deref(),
            Some("11 N 385153 3768853")
        );
        assert_eq!(utm.verbatim_coordinate_system.as_deref(), Some("UTM"));
    }

    #[test]
    fn rejects_wrong_axis_and_incomplete_coordinates() {
        assert!(parse_coordinate_input(
            CoordinateInputFormat::DegreesDecimalMinutes,
            "41 24.2 E".to_owned(),
            Some("123 15.0 W".to_owned()),
        )
        .is_err());
        assert!(
            parse_coordinate_input(CoordinateInputFormat::Utm, "11 N 385153".to_owned(), None,)
                .is_err()
        );
    }
}
