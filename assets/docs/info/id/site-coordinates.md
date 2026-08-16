---
title: "Koordinat site"
sidebar:
  order: 0
---

Satu site dapat memiliki beberapa coordinate record. Setiap record sebaiknya menjelaskan posisi terdokumentasi beserta sistem koordinat, geodetic datum, elevation, uncertainty, dan catatan sumber.

Entri manual mendukung decimal degrees (DD), degrees and decimal minutes (DDM), degrees-minutes-seconds (DMS), serta WGS84 UTM. Impor mendukung GeoJSON/JSON, KML, zipped Shapefile, GPX, dan QR code koordinat NAHPU.

Coordinate uncertainty adalah jarak horizontal dalam meter tempat lokasi diperkirakan berada. Laporkan uncertainty yang realistis dan pertahankan representasi koordinat yang dimasukkan; ekspor memetakan nilai normal ke `dwc:decimalLatitude`, `dwc:decimalLongitude`, `dwc:geodeticDatum`, dan `dwc:coordinateUncertaintyInMeters`.
