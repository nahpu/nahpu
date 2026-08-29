---
title: "Site coordinates"
sidebar:
  order: 0
---

A site can have several coordinate records. Each one should describe a documented position, with its coordinate format, elevation, geodetic datum, uncertainty, GPS unit, and notes about the source.

Manual entry accepts decimal degrees (DD), degrees and decimal minutes (DDM), degrees-minutes-seconds (DMS), and WGS84 UTM. `Select coordinate file` imports CSV, TSV, Excel, GeoJSON/JSON, KML, zipped Shapefile, and GPX; `Scan QR` reads a NAHPU coordinate QR code. Review every imported position before saving it.

Uncertainty is the horizontal distance in metres within which the true position is expected to fall. Report a realistic value rather than a default one, and keep the coordinate as it was recorded in the field: NAHPU stores the entered representation alongside the decimal values it derives from it.

## Darwin Core context

Derived decimal values export to `dwc:decimalLatitude` and `dwc:decimalLongitude`, and the entry as typed is kept in `dwc:verbatimCoordinates`, `dwc:verbatimLatitude`, `dwc:verbatimLongitude`, and `dwc:verbatimCoordinateSystem`. Datum, uncertainty, and notes become `dwc:geodeticDatum`, `dwc:coordinateUncertaintyInMeters`, and `dwc:georeferenceRemarks`. A single elevation fills both `dwc:minimumElevationInMeters` and `dwc:maximumElevationInMeters`.
