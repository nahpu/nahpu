//! GIS coordinate conversion API for Flutter.
//!
//! Provides functions to convert coordinates between DMS, DDM, UTM, and Decimal
//! Degrees, and to parse coordinate strings automatically.

use nahpu_gis::conversion::{
    CardinalDirection as CD, CoordinateConverter, DdmCoordinate as Ddm, DmsCoordinate as Dms,
    UtmCoordinate as Utm,
};
use nahpu_gis::io::{
    coordinates::CoordinateImportResult as GisCoordinateImportResult, geojson::GeoJsonExporter,
    kml::KmlExporter, shp::ShapefileExporter,
};
use nahpu_gis::types::CoordinateData;
use std::path::Path;

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
    let path = Path::new(&output_path);
    match format {
        CoordinateExportFormat::GeoJson => GeoJsonExporter::new(&data).export_geojson(path),
        CoordinateExportFormat::Kml => KmlExporter::new(&data).export_kml(path),
        CoordinateExportFormat::Shapefile => ShapefileExporter::new(&data).export_shp(path),
    }
}

/// Imports point coordinates from GeoJSON, KML, zipped Shapefile, or GPX.
pub fn import_coordinates(input_path: String) -> Result<CoordinateFileImportResult, String> {
    CoordinateFileImportResult::try_from(GisCoordinateImportResult::import(input_path)?)
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

impl TryFrom<GisCoordinateImportResult> for CoordinateFileImportResult {
    type Error = String;

    fn try_from(value: GisCoordinateImportResult) -> Result<Self, Self::Error> {
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
    pub bounds: Option<Vec<f64>>,
    /// Coordinate reference system of the output.
    pub source_crs: String,
}

/// Converts GeoJSON or a zipped WGS84 Shapefile to normalized GeoJSON.
pub fn convert_vector_layer_to_geojson(
    input_path: String,
    output_path: String,
) -> Result<ImportedVectorLayer, String> {
    let result = nahpu_gis::io::layers::convert_vector_to_geojson(input_path, output_path)?;
    Ok(ImportedVectorLayer {
        feature_count: result.feature_count,
        bounds: result.bounds,
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

/// Converts DMS to decimal degrees.
///
/// # Examples
///
/// ```
/// use rust_lib_nahpu::api::gis::{dms_to_dd, CardinalDirection};
///
/// let dd = dms_to_dd(41, 24, 12.2, CardinalDirection::North);
/// assert!((dd - 41.40338888888889).abs() < 1e-9);
/// ```
pub fn dms_to_dd(degrees: u32, minutes: u32, seconds: f64, direction: CardinalDirection) -> f64 {
    let dms = Dms::new(degrees, minutes, seconds, direction.into());
    dms.to_decimal()
}

/// Converts DDM to decimal degrees.
///
/// # Examples
///
/// ```
/// use rust_lib_nahpu::api::gis::{ddm_to_dd, CardinalDirection};
///
/// let dd = ddm_to_dd(41, 24.2028, CardinalDirection::North);
/// assert!((dd - 41.40338).abs() < 1e-9);
/// ```
pub fn ddm_to_dd(degrees: u32, minutes: f64, direction: CardinalDirection) -> f64 {
    let ddm = Ddm::new(degrees, minutes, direction.into());
    ddm.to_decimal()
}

/// Converts UTM to decimal degrees latitude and longitude.
pub fn utm_to_dd(
    zone: u8,
    hemisphere: CardinalDirection,
    easting: f64,
    northing: f64,
) -> Result<(f64, f64), String> {
    let utm = Utm::new(zone, hemisphere.into(), easting, northing)?;
    utm.to_lat_lon()
}

/// Converts decimal degrees to DMS.
pub fn dd_to_dms(dd: f64, is_latitude: bool) -> DmsCoordinateFfi {
    let direction = if is_latitude {
        if dd >= 0.0 {
            CD::North
        } else {
            CD::South
        }
    } else {
        if dd >= 0.0 {
            CD::East
        } else {
            CD::West
        }
    };
    let dms = Dms::from_decimal(dd, direction);
    DmsCoordinateFfi {
        degrees: dms.degrees,
        minutes: dms.minutes,
        seconds: dms.seconds,
        direction: dms.direction.into(),
    }
}

/// Converts decimal degrees to DDM.
pub fn dd_to_ddm(dd: f64, is_latitude: bool) -> DdmCoordinateFfi {
    let direction = if is_latitude {
        if dd >= 0.0 {
            CD::North
        } else {
            CD::South
        }
    } else {
        if dd >= 0.0 {
            CD::East
        } else {
            CD::West
        }
    };
    let ddm = Ddm::from_decimal(dd, direction);
    DdmCoordinateFfi {
        degrees: ddm.degrees,
        minutes: ddm.minutes,
        direction: ddm.direction.into(),
    }
}

/// Converts decimal degrees latitude and longitude to UTM.
pub fn dd_to_utm(latitude: f64, longitude: f64) -> Result<UtmCoordinateFfi, String> {
    let utm = Utm::from_lat_lon(latitude, longitude)?;
    Ok(UtmCoordinateFfi {
        zone: utm.zone,
        hemisphere: utm.hemisphere.into(),
        easting: utm.easting,
        northing: utm.northing,
    })
}

/// Automatically detects the coordinate format of a string and parses it to decimal degrees.
pub fn parse_coordinate_string(s: String) -> Result<f64, String> {
    CoordinateConverter::parse_to_decimal(&s)
}
