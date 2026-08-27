---
title: "Coordenadas del sitio"
sidebar:
  order: 0
---

Un sitio puede tener varios registros de coordenadas. Cada uno debe describir una posición documentada con su sistema de coordenadas, datum geodésico, elevación, incertidumbre y notas de origen.

La entrada manual admite grados decimales (DD), grados y minutos decimales (DDM), grados-minutos-segundos (DMS) y UTM WGS84. La importación admite GeoJSON/JSON, KML, Shapefile comprimido, GPX y códigos QR de coordenada de NAHPU.

La incertidumbre de la coordenada es la distancia horizontal, en metros, dentro de la cual se espera que se encuentre la ubicación. Informe una incertidumbre realista y conserve la representación de la coordenada tal como se ingresó; las exportaciones asignan los valores normalizados a `dwc:decimalLatitude`, `dwc:decimalLongitude`, `dwc:geodeticDatum` y `dwc:coordinateUncertaintyInMeters`.
