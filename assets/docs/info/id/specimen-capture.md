---
title: "Tangkapan spesimen"
sidebar:
  order: 0
---

Informasi tangkapan menghubungkan spesimen dengan kegiatan pengumpulan yang menyediakan lokasi, konteks pengambilan sampel, rentang tanggal, dan tim lapangannya. Catat tanggal, waktu, metode, pengumpul, dan koordinat tangkapan bila hal itu khusus untuk spesimen ini atau memperinci data kegiatan.

Mengubah kegiatan pengumpulan mengubah konteks pengambilan sampel catatan ini. NAHPU mengosongkan metode, pengumpul, dan koordinat agar nilai dari kegiatan sebelumnya tidak diam-diam tertinggal; tanggal dan waktu tangkapan tetap dipertahankan. Periksa setiap kolom setelah mengubah kegiatan, dan jangan pernah menduga koordinat yang tidak didukung bukti yang ada.

Rentang koordinat menjelaskan seberapa jauh spesimen mungkin berada dari posisi yang dicatat. Gunakan bila jalur perangkap, transek, atau area pencarian lebih luas daripada koordinatnya sendiri.

## Konteks Darwin Core

Tanggal dan waktu tangkapan diekspor sebagai `dwc:eventDate` dan `dwc:eventTime`, dan memakai tanggal kegiatan bila spesimen tidak memilikinya. Koordinat yang dipilih mengisi istilah lokasi, sedangkan rentang koordinat dijumlahkan dengan ketidakpastian koordinat itu sendiri menjadi `dwc:coordinateUncertaintyInMeters`. Pengumpul mengisi `dwc:recordedBy` dan `dwc:recordedByID`.
