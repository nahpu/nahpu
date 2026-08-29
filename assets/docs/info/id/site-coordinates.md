---
title: "Koordinat lokasi"
sidebar:
  order: 0
---

Satu lokasi dapat memiliki beberapa catatan koordinat. Masing-masing sebaiknya menjelaskan posisi terdokumentasi beserta format koordinat, ketinggian, datum geodetik, ketidakpastian, unit GPS, dan catatan tentang sumbernya.

Masukan manual menerima derajat desimal (DD), derajat dan menit desimal (DDM), derajat-menit-detik (DMS), serta UTM WGS84. `Select coordinate file` mengimpor CSV, TSV, Excel, GeoJSON/JSON, KML, Shapefile terkompresi, dan GPX; `Scan QR` membaca kode QR koordinat NAHPU. Periksa setiap posisi hasil impor sebelum menyimpannya.

Ketidakpastian adalah jarak horizontal, dalam meter, yang diperkirakan mencakup posisi sebenarnya. Laporkan nilai yang realistis, bukan nilai bawaan, dan pertahankan koordinat sebagaimana dicatat di lapangan: NAHPU menyimpan bentuk yang dimasukkan bersama nilai desimal yang diturunkan darinya.

## Konteks Darwin Core

Nilai desimal hasil turunan diekspor ke `dwc:decimalLatitude` dan `dwc:decimalLongitude`, sedangkan masukan apa adanya disimpan di `dwc:verbatimCoordinates`, `dwc:verbatimLatitude`, `dwc:verbatimLongitude`, dan `dwc:verbatimCoordinateSystem`. Datum, ketidakpastian, dan catatan menjadi `dwc:geodeticDatum`, `dwc:coordinateUncertaintyInMeters`, dan `dwc:georeferenceRemarks`. Satu nilai ketinggian mengisi `dwc:minimumElevationInMeters` sekaligus `dwc:maximumElevationInMeters`.
