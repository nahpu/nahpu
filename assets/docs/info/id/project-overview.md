---
title: "Gambaran umum proyek"
authors: []
sidebar:
  order: 0
---

Proyek mengelompokkan lokasi, kegiatan pengumpulan, spesimen, personel, takson, narasi, dan berkas pendukung untuk satu pekerjaan berbasis lapangan atau spesimen. Gunakan `Edit` di bagian bawah panel Ringkasan proyek untuk memperbarui informasi proyek.

Atur zona waktu proyek untuk menjelaskan waktu lokal yang dicatat. Mengubah zona waktu proyek tidak mengonversi nilai tanggal dan waktu yang sudah ada. Zona waktu disimpan bersama proyek dan disertakan dalam ekspor, sehingga aplikasi pihak ketiga dapat menafsirkan waktu yang dicatat. Zona waktu dicantumkan relatif terhadap Waktu Universal Terkoordinasi (UTC), standar waktu utama di seluruh dunia, dari UTC−12:00 hingga UTC+14:00, masing-masing dengan nama Benua/Kota. Misalnya, Waktu Indonesia Barat ditampilkan sebagai `(UTC+07:00) Asia/Jakarta`.

UUID proyek adalah pengenal unik proyek di berbagai perangkat. Untuk membagikan proyek kepada kolaborator, pilih kode QR pada panel Ringkasan proyek untuk memperbesar atau menyimpannya, atau pilih `Export info` di bagian bawah panel. Kolaborator memindai kode QR saat membuat proyek baru. Kedua pilihan membagikan UUID dan metadata proyek, tanpa catatan atau media.

Untuk cadangan harian di lapangan, buka menu dan pilih `Export project`. ZIP dan TAR.GZ menyertakan semua catatan dan media lampiran yang tersedia; format ringan JSON.GZ berisi catatan tanpa media.

## Pelajari lebih lanjut

- [Proyek](https://nahpu.app/id/usages/projects/)
- [Ekspor](https://nahpu.app/id/usages/export/#backup-strategy)
