---
title: "Coordenadas del sitio"
sidebar:
  order: 0
---

Un sitio puede tener varios registros de coordenadas. Cada uno debe describir una posición documentada con sistema de coordenadas, datum geodésico, elevación, incertidumbre y notas sobre la fuente.

La entrada manual admite grados decimales (DD), grados y minutos decimales (DDM), grados-minutos-segundos (DMS) y WGS84 UTM. La importación admite GeoJSON/JSON, KML, Shapefile comprimido, GPX y códigos QR de coordenadas de NAHPU.

Coordinate uncertainty es la distancia horizontal, en metros, dentro de la cual se espera encontrar la ubicación. Informe una incertidumbre realista y conserve la representación introducida; las exportaciones asignan valores normalizados a `dwc:decimalLatitude`, `dwc:decimalLongitude`, `dwc:geodeticDatum` y `dwc:coordinateUncertaintyInMeters`.
