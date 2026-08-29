---
title: "Coordenadas do local"
sidebar:
  order: 0
---

Um local pode ter vários registros de coordenadas. Cada um deve descrever uma posição documentada com seu sistema de coordenadas, datum geodésico, altitude, incerteza e notas de origem.

A entrada manual aceita graus decimais (DD), graus e minutos decimais (DDM), graus-minutos-segundos (DMS) e UTM WGS84. A importação aceita GeoJSON/JSON, KML, Shapefile compactado, GPX e códigos QR de coordenada do NAHPU.

A incerteza da coordenada é a distância horizontal, em metros, dentro da qual se espera que a localização esteja. Informe uma incerteza realista e preserve a representação da coordenada como foi digitada; as exportações mapeiam os valores normalizados para `dwc:decimalLatitude`, `dwc:decimalLongitude`, `dwc:geodeticDatum` e `dwc:coordinateUncertaintyInMeters`.
