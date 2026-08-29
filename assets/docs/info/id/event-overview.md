---
title: "Ikhtisar kegiatan"
sidebar:
  order: 0
---

Kegiatan pengumpulan mencatat satu upaya pengambilan sampel tertentu pada satu lokasi dan waktu. Spesimen ditautkan ke kegiatan untuk memperoleh lokasi, tanggal, konteks pengambilan sampel, dan tim lapangannya, sehingga banyak catatan spesimen dapat berbagi satu kegiatan.

NAHPU menyusun Event ID dari Site ID dan tanggal mulai; tambahkan akhiran hanya bila kegiatan lain akan memiliki pengenal yang sama. Buat kegiatan terpisah bila lokasi, rentang waktu, protokol pengambilan sampel, upaya, atau tim yang terlibat berubah secara berarti.

Menggandakan kegiatan akan memakai ulang pengaturan yang relevan, tetapi memajukan tanggal dan mengosongkan data cuaca. Periksa setiap nilai yang tersalin sebelum digunakan.

## Konteks Darwin Core

Kegiatan diekspor sebagai sampling event: Event ID menjadi `dwc:eventID`, lokasi menjadi `dwc:locationID`, serta tanggal dan waktu menjadi `dwc:eventDate` dan `dwc:eventTime`. Rentang tanggal diekspor sebagai satu interval ISO 8601.
