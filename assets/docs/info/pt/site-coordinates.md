---
title: "Coordenadas do local"
sidebar:
  order: 0
---

Um local pode ter vários registros de coordenadas. Cada um deve descrever uma posição documentada, com seu formato de coordenada, altitude, datum geodésico, incerteza, unidade de GPS e notas sobre a origem.

A entrada manual aceita graus decimais (DD), graus e minutos decimais (DDM), graus-minutos-segundos (DMS) e UTM WGS84. `Select coordinate file` importa CSV, TSV, Excel, GeoJSON/JSON, KML, Shapefile compactado e GPX; `Scan QR` lê um código QR de coordenada do NAHPU. Revise cada posição importada antes de salvá-la.

A incerteza é a distância horizontal, em metros, dentro da qual se espera que a posição real esteja. Informe um valor realista em vez de um valor padrão e preserve a coordenada como foi registrada em campo: o NAHPU armazena a representação digitada junto com os valores decimais que deriva dela.

## Contexto do Darwin Core

Os valores decimais derivados são exportados para `dwc:decimalLatitude` e `dwc:decimalLongitude`, e a entrada como foi digitada é mantida em `dwc:verbatimCoordinates`, `dwc:verbatimLatitude`, `dwc:verbatimLongitude` e `dwc:verbatimCoordinateSystem`. Datum, incerteza e notas viram `dwc:geodeticDatum`, `dwc:coordinateUncertaintyInMeters` e `dwc:georeferenceRemarks`. Uma única altitude preenche tanto `dwc:minimumElevationInMeters` quanto `dwc:maximumElevationInMeters`.
