---
title: "Prasetel ekspor tabel"
sidebar:
  order: 0
---

Prasetel ekspor tabel menyimpan definisi yang dapat diulang: jenis catatan, kelompok takson spesimen, kolom yang dipilih beserta urutannya, format tajuk yang dihasilkan, dan cara nilai berulang dituliskan. Format keluaran, nama berkas, dan tujuan penyimpanan dipilih saat ekspor dijalankan.

Nilai berulang dapat ditulis dalam satu kolom dengan pemisah, atau disebar menjadi kolom berindeks seperti `field_1`, `field_2`. Uji sebuah prasetel dengan catatan yang representatif, termasuk nilai yang kosong dan berulang, sebelum mengandalkannya, lalu pindahkan konfigurasi pengguna bila kolaborator memerlukan definisi yang sama.

## Konteks Darwin Core

`Generated header format` menentukan penamaan tajuk: `table::fieldName`, `fieldName`, Darwin Core (`dwc:`/`dcterms:`), atau namespace NAHPU. Tajuk Darwin Core hanya dihasilkan untuk keluaran CSV, TSV, dan Excel, dan hanya untuk kolom yang memiliki padanan Darwin Core; kolom tanpa padanan tetap memakai nama NAHPU. Nilai berulang dalam ekspor Darwin Core selalu memakai pemisah " | " yang direkomendasikan.

Petakan kolom kustom ke istilah Darwin Core hanya bila maknanya memang sama dengan istilah tersebut. Label yang mirip tidaklah cukup: istilah yang dipakai ulang untuk konsep lain membuat hasil ekspor lebih sulit ditafsirkan daripada kolom NAHPU yang tidak dipetakan.
