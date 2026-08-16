---
title: "Coordenadas do site"
sidebar:
  order: 0
---

Um site pode ter vários registros de coordenadas. Cada um deve descrever uma posição documentada com sistema de coordenadas, datum geodésico, elevação, incerteza e notas sobre a fonte.

A entrada manual aceita graus decimais (DD), graus e minutos decimais (DDM), graus-minutos-segundos (DMS) e WGS84 UTM. A importação aceita GeoJSON/JSON, KML, Shapefile compactado, GPX e QR codes de coordenadas do NAHPU.

Coordinate uncertainty é a distância horizontal, em metros, dentro da qual se espera encontrar a localização. Informe incerteza realista e preserve a representação inserida; as exportações mapeiam valores normalizados para `dwc:decimalLatitude`, `dwc:decimalLongitude`, `dwc:geodeticDatum` e `dwc:coordinateUncertaintyInMeters`.
