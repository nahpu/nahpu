---
title: "Koordinat lokasi"
sidebar:
  order: 0
---

Satu lokasi dapat memiliki beberapa catatan koordinat. Masing-masing sebaiknya menjelaskan posisi terdokumentasi beserta sistem koordinat, datum geodetik, ketinggian, ketidakpastian, dan catatan sumbernya.

Masukan manual mendukung derajat desimal (DD), derajat dan menit desimal (DDM), derajat-menit-detik (DMS), serta UTM WGS84. Impor mendukung GeoJSON/JSON, KML, Shapefile terkompresi, GPX, dan kode QR koordinat NAHPU.

Ketidakpastian koordinat adalah jarak horizontal, dalam meter, yang diperkirakan mencakup lokasi sebenarnya. Laporkan ketidakpastian yang realistis dan pertahankan bentuk koordinat sebagaimana dimasukkan; hasil ekspor memetakan nilai yang dibakukan ke `dwc:decimalLatitude`, `dwc:decimalLongitude`, `dwc:geodeticDatum`, dan `dwc:coordinateUncertaintyInMeters`.
