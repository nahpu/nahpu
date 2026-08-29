---
title: "Coordenadas del sitio"
sidebar:
  order: 0
---

Un sitio puede tener varios registros de coordenadas. Cada uno debe describir una posición documentada, con su formato de coordenada, elevación, datum geodésico, incertidumbre, unidad GPS y notas sobre el origen.

La entrada manual acepta grados decimales (DD), grados y minutos decimales (DDM), grados-minutos-segundos (DMS) y UTM WGS84. `Select coordinate file` importa CSV, TSV, Excel, GeoJSON/JSON, KML, Shapefile comprimido y GPX; `Scan QR` lee un código QR de coordenada de NAHPU. Revise cada posición importada antes de guardarla.

La incertidumbre es la distancia horizontal, en metros, dentro de la cual se espera que se encuentre la posición real. Informe un valor realista en lugar de uno por omisión y conserve la coordenada tal como se registró en el campo: NAHPU almacena la representación ingresada junto con los valores decimales que deriva de ella.

## Contexto de Darwin Core

Los valores decimales derivados se exportan a `dwc:decimalLatitude` y `dwc:decimalLongitude`, y la entrada tal como se escribió se conserva en `dwc:verbatimCoordinates`, `dwc:verbatimLatitude`, `dwc:verbatimLongitude` y `dwc:verbatimCoordinateSystem`. El datum, la incertidumbre y las notas se convierten en `dwc:geodeticDatum`, `dwc:coordinateUncertaintyInMeters` y `dwc:georeferenceRemarks`. Una sola elevación llena tanto `dwc:minimumElevationInMeters` como `dwc:maximumElevationInMeters`.
