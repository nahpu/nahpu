---
title: "Site coordinates"
sidebar:
  order: 0
---

A site can have multiple coordinate records. Each should describe a documented position with its coordinate system, geodetic datum, elevation, uncertainty, and source notes.

Manual entry supports decimal degrees (DD), degrees and decimal minutes (DDM), degrees-minutes-seconds (DMS), and WGS84 UTM. Import supports GeoJSON/JSON, KML, zipped Shapefile, GPX, and NAHPU coordinate QR codes.

Coordinate uncertainty is the horizontal distance in metres within which the location is expected to occur. Report realistic uncertainty and preserve the entered coordinate representation; exports map normalized values to `dwc:decimalLatitude`, `dwc:decimalLongitude`, `dwc:geodeticDatum`, and `dwc:coordinateUncertaintyInMeters`.
