---
title: "Atribut spesimen"
sidebar:
  order: 0
---

Atribut memuat pengukuran dan pengamatan biologis yang dilakukan untuk spesimen, termasuk jenis kelamin, tahap hidup, kondisi reproduksi, morfometri, dan kolom khusus kelompok takson.

Isi hanya nilai yang teramati atau terdokumentasi, dan pertahankan satuan yang ditampilkan. Gunakan `Unknown` atau kosongkan kolom sesuai protokol proyek alih-alih menebak. Keterangan sebaiknya menjelaskan syarat, kerusakan, ketidakpastian, atau metode yang memengaruhi cara sebuah nilai ditafsirkan.

## Konteks Darwin Core

Jenis kelamin, tahap hidup, dan kondisi reproduksi dipetakan ke `dwc:sex`, `dwc:lifeStage`, dan `dwc:reproductiveCondition`; kasta artropoda dipetakan ke `dwc:caste` dan inang yang tercatat ke `dwc:associatedTaxa`. Pengukuran lainnya diekspor sebagai pengukuran, bukan sebagai kolom tersendiri: ekspor tabel menghasilkan `dwc:measurementType`, `dwc:measurementValue`, dan `dwc:measurementUnit` untuk setiap pengukuran yang dipilih, dan paket terstruktur membawa trio yang sama sebagai satu baris pengukuran per nilai.
