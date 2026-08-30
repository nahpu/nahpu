---
title: "Media"
sidebar:
  order: 0
---

Media menyimpan gambar, audio, dan video yang terkait dengan catatan proyek. Gunakan `Add` untuk mengimpor berkas atau, bila perangkat mendukung, untuk mengambil foto atau video maupun merekam audio.

Sunting nama berkas, keterangan gambar, tag, dan fotografernya agar orang lain tahu isi berkas tersebut. Kategori mengikuti tipe berkas, sedangkan tanggal pengambilan, kamera, dan lensa dibaca dari metadata berkas itu sendiri bila ada. Pastikan berkas terkelola dapat dibuka sebelum meninggalkan lapangan, dan sertakan media dalam cadangan atau transfer proyek penuh bila media harus berpindah ke perangkat lain.

Media menjelaskan sumber dayanya, bukan spesimennya. Simpan pengamatan tentang organisme pada catatan spesimen.

## Mengekspor media

Gunakan `Export` pada satu item media untuk menyimpan satu berkas, lengkap dengan pilihan mengonversinya ke JPEG, PNG, atau WebP dan mengubah ukurannya. Untuk menyimpan beberapa berkas sekaligus, buka galeri media, aktifkan seleksi, lalu pilih `Export`. Langkah itu menulis satu arsip TAR.GZ atau ZIP, dengan gambar dikonversi dan diubah ukurannya bersama-sama, sedangkan audio dan video disalin apa adanya.

## Konteks Darwin Core

Media yang terlampir pada spesimen diekspor bersama kejadiannya sebagai catatan `ac:Media` dari Audiovisual Core: keterangan gambar atau nama berkas menjadi judul, tanggal pengambilan menjadi tanggal pembuatan, dan fotografer menjadi pembuatnya. Dalam ekspor tabel, kolom media dipetakan ke istilah Dublin Core seperti `dcterms:title`, `dcterms:created`, `dcterms:type`, dan `dcterms:identifier`.
